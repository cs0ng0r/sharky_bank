RegisterServerEvent('mta_bank:getBalance')
AddEventHandler('mta_bank:getBalance', function(coords)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

    if xPlayer then
        TriggerClientEvent('mta_bank:sendBalance', _source)
    end
end)

ESX.RegisterServerCallback('mta_bank:getPlayerBalance', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer then
        cb(xPlayer.getAccount('bank').money)
    end
end)

ESX.RegisterServerCallback('mta_bank:deposit', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    if amount > 0 and xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        xPlayer.addAccountMoney('bank', amount)
        cb({ success = true, newBalance = xPlayer.getAccount('bank').money })
    else
        cb({ success = false, message = 'Nincs elég pénzed!' })
    end
end)

ESX.RegisterServerCallback('mta_bank:withdraw', function(source, cb, amount)
    local xPlayer = ESX.GetPlayerFromId(source)
    local balance = xPlayer.getAccount('bank').money

    if amount > 0 and balance >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        xPlayer.addMoney(amount)
        cb({ success = true, newBalance = xPlayer.getAccount('bank').money })
    else
        cb({ success = false, message = 'Nincs elég pénzed a számládon!' })
    end
end)
