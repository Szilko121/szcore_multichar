const app = document.getElementById('app');
const charactersEl = document.getElementById('characters');
const createForm = document.getElementById('createForm');
const toast = document.getElementById('toast');
let maxCharacters = 4;
let characters = [];
let loading = false;

const post = async (name, body = {}) => {
  const response = await fetch(`https://${GetParentResourceName()}/${name}`, {
    method: 'POST', headers: { 'Content-Type': 'application/json; charset=UTF-8' }, body: JSON.stringify(body)
  });
  return response.json();
};

function setLoading(value, message) {
  loading = value === true;
  document.querySelectorAll('button, input, select').forEach(el => {
    if (el.id !== 'refresh') el.disabled = loading;
  });

  if (loading && message) {
    notify(message);
  }
}

function notify(message) {
  toast.textContent = message;
  toast.classList.remove('hidden');
  clearTimeout(notify.timer);
  notify.timer = setTimeout(() => toast.classList.add('hidden'), 3200);
}

function render() {
  charactersEl.innerHTML = '';
  const bySlot = new Map(characters.map(c => [Number(c.slot), c]));
  for (let slot = 1; slot <= maxCharacters; slot++) {
    const c = bySlot.get(slot);
    const card = document.createElement('article');
    if (!c) {
      card.className = 'card empty';
      card.innerHTML = `<div><div class="avatar">+</div><div class="name">Új karakter</div><div class="meta">${slot}. karakterhely</div></div>`;
      card.onclick = () => openCreate(slot);
    } else {
      const initials = `${c.firstname?.[0] || ''}${c.lastname?.[0] || ''}`.toUpperCase();
      card.className = 'card';
      card.innerHTML = `<div><div class="avatar">${initials}</div><div class="name">${escapeHtml(c.firstname)} ${escapeHtml(c.lastname)}</div><div class="meta">ID: ${escapeHtml(c.citizenid)}<br>${escapeHtml(c.job)} · rang ${Number(c.job_grade)}<br>Bank: $${Number(c.bank).toLocaleString('hu-HU')}</div></div><div class="actions"><button class="primary enter">Belépés</button><button class="danger delete">Törlés</button></div>`;
      card.querySelector('.enter').onclick = async () => {
        const r = await post('select', { citizenid: c.citizenid });
        if (!r.ok) notify(r.error || 'Hiba történt.');
      };
      card.querySelector('.delete').onclick = async () => {
        if (!confirm(`Biztosan törlöd: ${c.firstname} ${c.lastname}?`)) return;
        const r = await post('delete', { citizenid: c.citizenid });
        if (!r.ok) notify(r.error || 'Hiba történt.');
      };
    }
    charactersEl.appendChild(card);
  }
}

function escapeHtml(value) {
  return String(value ?? '').replace(/[&<>'"]/g, ch => ({'&':'&amp;','<':'&lt;','>':'&gt;',"'":'&#39;','"':'&quot;'}[ch]));
}
function openCreate(slot) {
  document.getElementById('slot').value = slot;
  createForm.classList.remove('hidden');
}
document.getElementById('cancelCreate').onclick = () => createForm.classList.add('hidden');
document.getElementById('refresh').onclick = () => post('refresh');
createForm.addEventListener('submit', async (e) => {
  e.preventDefault();
  const data = {
    slot: Number(document.getElementById('slot').value),
    firstname: document.getElementById('firstname').value.trim(),
    lastname: document.getElementById('lastname').value.trim(),
    birthdate: document.getElementById('birthdate').value,
    gender: document.getElementById('gender').value,
    nationality: document.getElementById('nationality').value.trim()
  };
  const r = await post('create', data);
  if (!r.ok) return notify(r.error || 'Hiba történt.');
  createForm.reset();
  createForm.classList.add('hidden');
});
window.addEventListener('message', (event) => {
  const data = event.data || {};
  if (data.action === 'open') app.classList.remove('hidden');
  if (data.action === 'close') app.classList.add('hidden');
  if (data.action === 'loading') {
    setLoading(data.loading, data.message);
  }
  if (data.action === 'characters') {
    characters = Array.isArray(data.characters) ? data.characters : [];
    maxCharacters = Number(data.maxCharacters) || 4;
    render();
  }
  if (data.action === 'error') notify(data.message || 'Hiba történt.');
});
