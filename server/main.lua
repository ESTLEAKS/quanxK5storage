ESX = nil
local storageLocations = {}
local playerStorages = {}

-- Initialize ESX
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Load storage locations from database
CreateThread(function()
    Wait(1000)
    LoadStorageLocations()
    LoadPlayerStorages()
end)

function LoadStorageLocations()
    local result = MySQL.Sync.fetchAll('SELECT * FROM storage_locations', {})
    if result then
        for _, location in pairs(result) do
            local coords = json.decode(location.coords)
            storageLocations[location.id] = {
                id = location.id,
                coords = vector3(coords.x, coords.y, coords.z),
                heading = location.heading or 0.0,
                label = location.label,
                blip = location.blip == 1
            }
        end
        Config.StorageLocations = storageLocations
        TriggerClientEvent('quanxk5_storage:client:updateLocations', -1, storageLocations)
        print('[QuanXk5 Storage] Loaded ' .. #result .. ' storage locations')
    end
end

function LoadPlayerStorages()
    local result = MySQL.Sync.fetchAll('SELECT * FROM player_storages', {})
    if result then
        for _, storage in pairs(result) do
            playerStorages[storage.identifier] = playerStorages[storage.identifier] or {}
            table.insert(playerStorages[storage.identifier], {
                id = storage.id,
                location_id = storage.location_id,
                tier = storage.tier,
                password = storage.password
            })
        end
        print('[QuanXk5 Storage] Loaded player storages')
    end
end

-- Check if player is admin
function IsPlayerAdmin(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return false end
    
    local license = xPlayer.identifier
    for _, adminLicense in pairs(Config.AdminLicenses) do
        if license == adminLicense then
            return true
        end
    end
    return false
end

-- Place Storage Location Command
RegisterCommand('placestorage', function(source, args, rawCommand)
    if not IsPlayerAdmin(source) then
        TriggerClientEvent('quan_notify:client:notify', source, {
            title = 'Access Denied',
            message = 'You don\'t have permission to use this command',
            type = 'error',
            duration = 5000
        })
        return
    end
    
    TriggerClientEvent('quanxk5_storage:client:startPlacement', source)
end, false)

-- Create Storage Location
RegisterNetEvent('quanxk5_storage:server:createLocation')
AddEventHandler('quanxk5_storage:server:createLocation', function(data)
    local source = source
    if not IsPlayerAdmin(source) then return end
    
    local coords = json.encode({x = data.coords.x, y = data.coords.y, z = data.coords.z})
    
    MySQL.Async.insert('INSERT INTO storage_locations (coords, heading, label, blip) VALUES (@coords, @heading, @label, @blip)', {
        ['@coords'] = coords,
        ['@heading'] = data.heading,
        ['@label'] = data.label,
        ['@blip'] = data.blip and 1 or 0
    }, function(id)
        storageLocations[id] = {
            id = id,
            coords = data.coords,
            heading = data.heading,
            label = data.label,
            blip = data.blip
        }
        
        Config.StorageLocations = storageLocations
        TriggerClientEvent('quanxk5_storage:client:updateLocations', -1, storageLocations)
        
        TriggerClientEvent('quan_notify:client:notify', source, Config.Notifications.locationPlaced)
    end)
end)

-- Purchase Storage
RegisterNetEvent('quanxk5_storage:server:purchaseStorage')
AddEventHandler('quanxk5_storage:server:purchaseStorage', function(locationId, password)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    -- Check if player already owns storage at this location
    local playerStorageList = playerStorages[xPlayer.identifier] or {}
    for _, storage in pairs(playerStorageList) do
        if storage.location_id == locationId then
            TriggerClientEvent('quan_notify:client:notify', source, {
                title = 'Already Owned',
                message = 'You already own a storage unit at this location',
                type = 'error',
                duration = 7500
            })
            return
        end
    end
    
    local tier = 1
    local price = Config.StorageTiers[tier].price
    
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        
        MySQL.Async.insert('INSERT INTO player_storages (identifier, location_id, tier, password) VALUES (@identifier, @location_id, @tier, @password)', {
            ['@identifier'] = xPlayer.identifier,
            ['@location_id'] = locationId,
            ['@tier'] = tier,
            ['@password'] = password
        }, function(id)
            playerStorages[xPlayer.identifier] = playerStorages[xPlayer.identifier] or {}
            table.insert(playerStorages[xPlayer.identifier], {
                id = id,
                location_id = locationId,
                tier = tier,
                password = password
            })
            
            -- Create storage inventory
            local storageId = Config.StoragePrefix .. id
            exports.ox_inventory:RegisterStash(storageId, 'Storage Unit #' .. id, Config.StorageTiers[tier].slots, Config.StorageTiers[tier].weight)
            
            local notification = Config.Notifications.purchaseSuccess
            TriggerClientEvent('quan_notify:client:notify', source, {
                title = notification.title,
                message = string.format(notification.message, ESX.Math.GroupDigits(price)),
                type = notification.type,
                duration = notification.duration
            })
            
            TriggerClientEvent('quanxk5_storage:client:refreshStorage', source)
        end)
    else
        local notification = Config.Notifications.purchaseFailed
        TriggerClientEvent('quan_notify:client:notify', source, {
            title = notification.title,
            message = string.format(notification.message, ESX.Math.GroupDigits(price)),
            type = notification.type,
            duration = notification.duration
        })
    end
end)

-- Upgrade Storage
RegisterNetEvent('quanxk5_storage:server:upgradeStorage')
AddEventHandler('quanxk5_storage:server:upgradeStorage', function(storageId)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    MySQL.Async.fetchAll('SELECT * FROM player_storages WHERE id = @id AND identifier = @identifier', {
        ['@id'] = storageId,
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            local currentTier = result[1].tier
            local newTier = currentTier + 1
            
            if Config.StorageTiers[newTier] then
                local price = Config.StorageTiers[newTier].price
                
                if xPlayer.getMoney() >= price then
                    xPlayer.removeMoney(price)
                    
                    MySQL.Async.execute('UPDATE player_storages SET tier = @tier WHERE id = @id', {
                        ['@tier'] = newTier,
                        ['@id'] = storageId
                    }, function(affectedRows)
                        -- Update local cache
                        for _, storage in pairs(playerStorages[xPlayer.identifier]) do
                            if storage.id == storageId then
                                storage.tier = newTier
                                break
                            end
                        end
                        
                        -- Update inventory stash
                        local stashId = Config.StoragePrefix .. storageId
                        exports.ox_inventory:RegisterStash(stashId, 'Storage Unit #' .. storageId, Config.StorageTiers[newTier].slots, Config.StorageTiers[newTier].weight)
                        
                        local notification = Config.Notifications.upgradeSuccess
                        TriggerClientEvent('quan_notify:client:notify', source, {
                            title = notification.title,
                            message = string.format(notification.message, Config.StorageTiers[newTier].name, ESX.Math.GroupDigits(price)),
                            type = notification.type,
                            duration = notification.duration
                        })
                        
                        TriggerClientEvent('quanxk5_storage:client:refreshStorage', source)
                    end)
                else
                    TriggerClientEvent('quan_notify:client:notify', source, Config.Notifications.upgradeFailed)
                end
            else
                TriggerClientEvent('quan_notify:client:notify', source, Config.Notifications.upgradeFailed)
            end
        end
    end)
end)

-- Access Storage
RegisterNetEvent('quanxk5_storage:server:accessStorage')
AddEventHandler('quanxk5_storage:server:accessStorage', function(storageId, password)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    MySQL.Async.fetchAll('SELECT * FROM player_storages WHERE id = @id AND identifier = @identifier', {
        ['@id'] = storageId,
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            if result[1].password == password or password == nil then
                local stashId = Config.StoragePrefix .. storageId
                exports.ox_inventory:forceOpenInventory(source, 'stash', stashId)
            else
                TriggerClientEvent('quan_notify:client:notify', source, Config.Notifications.passwordIncorrect)
            end
        end
    end)
end)

-- Change Password
RegisterNetEvent('quanxk5_storage:server:changePassword')
AddEventHandler('quanxk5_storage:server:changePassword', function(storageId, newPassword)
    local source = source
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    MySQL.Async.execute('UPDATE player_storages SET password = @password WHERE id = @id AND identifier = @identifier', {
        ['@password'] = newPassword,
        ['@id'] = storageId,
        ['@identifier'] = xPlayer.identifier
    }, function(affectedRows)
        if affectedRows > 0 then
            -- Update local cache
            for _, storage in pairs(playerStorages[xPlayer.identifier]) do
                if storage.id == storageId then
                    storage.password = newPassword
                    break
                end
            end
            
            TriggerClientEvent('quan_notify:client:notify', source, Config.Notifications.passwordSet)
        end
    end)
end)

-- Get Player Storages
ESX.RegisterServerCallback('quanxk5_storage:getPlayerStorages', function(source, cb, locationId)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then cb(nil) return end
    
    if locationId then
        -- Get specific location storage
        MySQL.Async.fetchAll('SELECT * FROM player_storages WHERE identifier = @identifier AND location_id = @location_id', {
            ['@identifier'] = xPlayer.identifier,
            ['@location_id'] = locationId
        }, function(result)
            cb(result[1])
        end)
    else
        -- Get all player storages
        MySQL.Async.fetchAll('SELECT * FROM player_storages WHERE identifier = @identifier', {
            ['@identifier'] = xPlayer.identifier
        }, function(result)
            cb(result)
        end)
    end
end)

-- Delete Storage Location (Admin)
RegisterNetEvent('quanxk5_storage:server:deleteLocation')
AddEventHandler('quanxk5_storage:server:deleteLocation', function(locationId)
    local source = source
    if not IsPlayerAdmin(source) then return end
    
    MySQL.Async.execute('DELETE FROM storage_locations WHERE id = @id', {
        ['@id'] = locationId
    }, function(affectedRows)
        storageLocations[locationId] = nil
        Config.StorageLocations = storageLocations
        TriggerClientEvent('quanxk5_storage:client:updateLocations', -1, storageLocations)
        
        TriggerClientEvent('quan_notify:client:notify', source, {
            title = 'Location Deleted',
            message = 'Storage location removed successfully',
            type = 'success',
            duration = 5000
        })
    end)
end)
