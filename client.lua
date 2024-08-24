local banks = Config.Banks

-- Event Handlers
function onBalanceReceived(balance)
    SendNUIMessage({
        type = "openBank",
        balance = balance,
    })
    SetNuiFocus(true, true)
end

function onDeposit(data, cb)
    local amount = data.amount
    ESX.TriggerServerCallback('mta_bank:deposit', function(response)
        if response.success then
            updateBalance(response.newBalance)
        else
            ESX.ShowNotification(response.message)
        end
        cb('ok')
    end, amount)
end

function onWithdraw(data, cb)
    local amount = data.amount
    ESX.TriggerServerCallback('mta_bank:withdraw', function(response)
        if response.success then
            updateBalance(response.newBalance)
        else
            ESX.ShowNotification(response.message)
        end
        cb('ok')
    end, amount)
end

function onCloseBank(_, cb)
    SendNUIMessage({ type = "closeBank" })
    SetNuiFocus(false, false)
    cb('ok')
end

-- Utility Functions
function openBank(coords)
    TriggerServerEvent('mta_bank:getBalance')
end

function updateBalance(newBalance)
    SendNUIMessage({
        type = "updateBalance",
        balance = newBalance,
    })
end

function setupPed(bank)
    RequestModel(GetHashKey(bank.ped.model))
    while not HasModelLoaded(GetHashKey(bank.ped.model)) do
        Wait(1)
    end

    for _, coords in pairs(bank.coords) do
        local ped = CreatePed(4, GetHashKey(bank.ped.model), coords.x, coords.y, coords.z, coords.w, false, true)
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetEntityInvincible(ped, true)
        FreezeEntityPosition(ped, true)
        bank.ped.ped = ped
    end
end

function drawText3D(coords, text)
    SetDrawOrigin(coords.x, coords.y, coords.z, 0)
    SetTextScale(0.0, 0.4)
    SetTextFont(4)
    SetTextCentre(true)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(0, 0)
    ClearDrawOrigin()
end

function createBlips(bank)
    for _, coords in pairs(bank.coords) do
        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blip, 108)
        SetBlipScale(blip, 0.8)
        SetBlipColour(blip, 2)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Bank")
        EndTextCommandSetBlipName(blip)
    end
end

CreateThread(function()
    for _, bank in pairs(banks) do
        setupPed(bank)
    end

    while true do
        Wait(0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        for _, bank in pairs(banks) do
            for _, coords in pairs(bank.coords) do
                local distance = #(playerCoords - vector3(coords.x, coords.y, coords.z))
                if distance < 2.0 then
                    drawText3D(vector3(coords.x, coords.y, coords.z + 2.0), bank.ped.text)
                    if IsControlJustPressed(0, 38) then
                        openBank(coords)
                    end
                end
            end
        end
    end
end)

CreateThread(function()
    for _, bank in pairs(banks) do
        createBlips(bank)
    end
end)

RegisterNetEvent('mta_bank:sendBalance', onBalanceReceived)
RegisterNUICallback('deposit', onDeposit)
RegisterNUICallback('withdraw', onWithdraw)
RegisterNUICallback('closeBank', onCloseBank)
