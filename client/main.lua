local open = false

local function setOpen(value)
    open = value
    SetNuiFocus(value, value)
    SendNUIMessage({ action = value and 'open' or 'close' })
end

local function loadCharacters()
    local characters, err = exports.szcore:AwaitCallback('szcore:getCharacters')
    if not characters then
        SendNUIMessage({ action = 'error', message = err or 'Nem sikerült betölteni a karaktereket.' })
        return
    end
    SendNUIMessage({ action = 'characters', characters = characters, maxCharacters = SzCoreConfig.MaxCharacters })
end

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(250) end
    Wait(500)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    if LocalPlayer.state.szcoreLoaded then return end
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
    local ok, err = exports.szcore:AwaitCallback('szcore:selectCharacter', data.citizenid)
    if ok then
        setOpen(false)
        cb({ ok = true })
    else
        cb({ ok = false, error = err or 'Nem sikerült belépni a karakterrel.' })
    end
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

AddEventHandler('szcore:client:onPlayerUnloaded', function()
    DoScreenFadeOut(300)
    Wait(350)
    setOpen(true)
    loadCharacters()
end)
