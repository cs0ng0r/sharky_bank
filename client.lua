local banks = Config.Banks

function openBank(coords)
    TriggerServerEvent('mta_bank:getBalance')
end

RegisterNetEvent('mta_bank:sendBalance')
AddEventHandler('mta_bank:sendBalance', function(balance)
    SendNUIMessage({
        type = "openBank",
        balance = balance,
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback('deposit', function(data, cb)
    local amount = data.amount
    ESX.TriggerServerCallback('mta_bank:deposit', function(response)
        if response.success then
            SendNUIMessage({
                type = "updateBalance",
                balance = response.newBalance,
            })
        else
            ESX.ShowNotification(response.message)
        end
        cb('ok')
    end, amount)
end)

RegisterNUICallback('withdraw', function(data, cb)
    local amount = data.amount
    ESX.TriggerServerCallback('mta_bank:withdraw', function(response)
        if response.success then
            SendNUIMessage({
                type = "updateBalance",
                balance = response.newBalance,
            })
        else
            ESX.ShowNotification(response.message)
        end
        cb('ok')
    end, amount)
end)

RegisterNUICallback('closeBank', function(data, cb)
    SendNUIMessage({
        type = "closeBank"
    })
    SetNuiFocus(false, false)
    cb('ok')
end)

CreateThread(function()
    for _, bank in pairs(Config.Banks) do
        RequestModel(GetHashKey(bank.ped.model))
        while not HasModelLoaded(GetHashKey(bank.ped.model)) do
            Wait(1)
        end

        local bankPed = CreatePed(4, GetHashKey(bank.ped.model), bank.coords.x, bank.coords.y, bank.coords.z, bank.heading, false, true)
        SetEntityHeading(bankPed, bank.heading)
        FreezeEntityPosition(bankPed, true)
        SetEntityAsMissionEntity(bankPed, true, true)
    end

    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        for _, bank in pairs(banks) do
            local distance = #(playerCoords - bank.coords)
            if distance < 2.0 then
                DrawText3D(bank.coords + vector3(0, 0, 2.0), bank.ped.text)
                if IsControlJustReleased(0, 38) then -- "E" key by default
                    openBank(bank.coords)
                end
            end
        end
    end
end)

function DrawText3D(coords, text)
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
