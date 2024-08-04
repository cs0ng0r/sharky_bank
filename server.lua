RegisterServerEvent('mta_bank:getBalance')
AddEventHandler('mta_bank:getBalance', function()
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local balance = xPlayer.getAccount('bank').money

    TriggerClientEvent('mta_bank:sendBalance', _source, balance)
end)

ESX.RegisterServerCallback('mta_bank:getPlayerBalance', function(source, cb)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    cb(xPlayer.getAccount('bank').money)
end)

ESX.RegisterServerCallback('mta_bank:deposit', function(source, cb, amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    if amount > 0 and xPlayer.getMoney() >= amount then
        xPlayer.removeMoney(amount)
        xPlayer.addAccountMoney('bank', amount)
        cb({ success = true, newBalance = xPlayer.getAccount('bank').money })
    else
        cb({ success = false, message = 'Nincs elég pénzed!' })
    end
end)

ESX.RegisterServerCallback('mta_bank:withdraw', function(source, cb, amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    local balance = xPlayer.getAccount('bank').money

    if amount > 0 and balance >= amount then
        xPlayer.removeAccountMoney('bank', amount)
        xPlayer.addMoney(amount)
        cb({ success = true, newBalance = xPlayer.getAccount('bank').money })
    else
        cb({ success = false, message = 'Nincs elég pénzed a számládon!' })
    end
end)
