local open = false
local loadingCharacters = false
local selecting = false

local function setOpen(value)
    open = value
    SetNuiFocus(value, value)
    SendNUIMessage({ action = value and 'open' or 'close' })
end

local function sendLoading(value, message)
    SendNUIMessage({
        action = 'loading',
        loading = value == true,
        message = message
    })
end

local function loadCharacters()
    if loadingCharacters then return end
    loadingCharacters = true

    CreateThread(function()
        sendLoading(true, 'Karakterek betöltése...')

        local deadline = GetGameTimer() + 15000
        local lastError

        while GetGameTimer() < deadline do
            local characters, err = exports.szcore:AwaitCallback('szcore:getCharacters')

            if characters then
                SendNUIMessage({
                    action = 'characters',
                    characters = characters,
                    maxCharacters = SzCoreConfig.MaxCharacters
                })
                sendLoading(false)
                loadingCharacters = false
                return
            end

            lastError = err

            if err ~= 'core_not_ready' and err ~= 'timeout' then
                break
            end

            Wait(250)
        end

        loadingCharacters = false
        sendLoading(false)
        SendNUIMessage({
            action = 'characters',
            characters = {},
            maxCharacters = SzCoreConfig.MaxCharacters
        })
        SendNUIMessage({
            action = 'error',
            message = lastError or 'Nem sikerült betölteni a karaktereket.'
        })
    end)
end

CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(250)
    end

    Wait(500)

    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    if LocalPlayer.state.szcoreLoaded then
        return
    end

    DoScreenFadeOut(0)
    setOpen(true)
    loadCharacters()
end)

CreateThread(function()
    while true do
        if open then
            Wait(0)
            DisableAllControlActions(0)
            EnableControlAction(0, 200, true)
        else
            Wait(750)
        end
    end
end)

RegisterNUICallback('refresh', function(_, cb)
    loadCharacters()
    cb({ ok = true })
end)

RegisterNUICallback('select', function(data, cb)
    if selecting then
        cb({ ok = false, error = 'A karakter betöltése már folyamatban van.' })
        return
    end

    if type(data) ~= 'table' or type(data.citizenid) ~= 'string' then
        cb({ ok = false, error = 'Érvénytelen karakter.' })
        return
    end

    selecting = true
    sendLoading(true, 'Karakter betöltése...')

    local ok, err = exports.szcore:AwaitCallback('szcore:selectCharacter', data.citizenid)

    if not ok then
        selecting = false
        sendLoading(false)
        cb({ ok = false, error = err or 'Nem sikerült belépni a karakterrel.' })
        return
    end

    setOpen(false)
    sendLoading(false)
    selecting = false
    cb({ ok = true })
end)

RegisterNUICallback('create', function(data, cb)
    local citizenid, err = exports.szcore:AwaitCallback('szcore:createCharacter', data)

    if not citizenid then
        cb({ ok = false, error = err or 'Nem sikerült létrehozni a karaktert.' })
        return
    end

    loadCharacters()
    cb({ ok = true, citizenid = citizenid })
end)

RegisterNUICallback('delete', function(data, cb)
    local ok, err = exports.szcore:AwaitCallback('szcore:deleteCharacter', data.citizenid)

    if not ok then
        cb({ ok = false, error = err or 'Nem sikerült törölni a karaktert.' })
        return
    end

    loadCharacters()
    cb({ ok = true })
end)

AddEventHandler('szcore:client:onPlayerLoaded', function()
    selecting = false
    sendLoading(false)

    if open then
        setOpen(false)
    end
end)

AddEventHandler('szcore:client:onPlayerUnloaded', function()
    selecting = false
    DoScreenFadeOut(300)
    Wait(350)
    setOpen(true)
    loadCharacters()
end)

AddEventHandler('szcore:client:spawnFailed', function(reason)
    selecting = false
    sendLoading(false)

    SendNUIMessage({
        action = 'error',
        message = ('Nem sikerült betölteni a karaktert: %s'):format(tostring(reason))
    })
end)
