ESX = nil
local storageLocations = {}
local blips = {}
local isPlacingStorage = false
local currentStorage = nil

-- Initialize ESX
CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Wait(0)
    end
    
    while not ESX.IsPlayerLoaded() do
        Wait(100)
    end
    
    TriggerServerEvent('quanxk5_storage:client:requestLocations')
end)

-- Update storage locations
RegisterNetEvent('quanxk5_storage:client:updateLocations')
AddEventHandler('quanxk5_storage:client:updateLocations', function(locations)
    storageLocations = locations
    CreateBlips()
end)

-- Create blips for storage locations
function CreateBlips()
    -- Remove existing blips
    for _, blip in pairs(blips) do
        RemoveBlip(blip)
    end
    blips = {}
    
    if not Config.Blips.enabled then return end
    
    for _, location in pairs(storageLocations) do
        if location.blip then
            local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
            SetBlipSprite(blip, Config.Blips.sprite)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, Config.Blips.scale)
            SetBlipColour(blip, Config.Blips.color)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(location.label or Config.Blips.name)
            EndTextCommandSetBlipName(blip)
            blips[location.id] = blip
        end
    end
end

-- Start placement mode
RegisterNetEvent('quanxk5_storage:client:startPlacement')
AddEventHandler('quanxk5_storage:client:startPlacement', function()
    isPlacingStorage = true
    
    ESX.ShowNotification('~g~Storage Placement Mode~s~\n~w~LEFT CLICK: ~g~Place Location~s~\n~w~RIGHT CLICK: ~r~Cancel')
    
    CreateThread(function()
        while isPlacingStorage do
            Wait(0)
            
            local hit, coords, entity = RayCastGamePlayCamera(1000.0)
            local playerCoords = GetEntityCoords(PlayerPedId())
            local heading = GetEntityHeading(PlayerPedId())
            
            if hit then
                DrawMarker(Config.MarkerType, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                    0, 255, 0, 100, false, true, 2, false, nil, nil, false)
                
                -- Left click to place
                if IsControlJustReleased(0, 24) then -- Left Click
                    isPlacingStorage = false
                    SendNUIMessage({
                        action = 'openPlacementMenu',
                        coords = {x = coords.x, y = coords.y, z = coords.z},
                        heading = heading
                    })
                    SetNuiFocus(true, true)
                end
                
                -- Right click to cancel
                if IsControlJustReleased(0, 25) then -- Right Click
                    isPlacingStorage = false
                    ESX.ShowNotification('~r~Placement cancelled')
                end
            end
            
            -- ESC to cancel
            if IsControlJustReleased(0, 322) then -- ESC
                isPlacingStorage = false
                ESX.ShowNotification('~r~Placement cancelled')
            end
        end
    end)
end)

-- Raycast function
function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination = {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

function RotationToDirection(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

-- Storage interaction thread
CreateThread(function()
    while true do
        Wait(0)
        
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local nearStorage = false
        
        for _, location in pairs(storageLocations) do
            local distance = #(playerCoords - location.coords)
            
            if distance < 10.0 then
                nearStorage = true
                DrawMarker(Config.MarkerType, location.coords.x, location.coords.y, location.coords.z - 1.0, 
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                    Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                    false, true, 2, false, nil, nil, false)
                
                if distance < Config.InteractionDistance then
                    ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ to access storage')
                    
                    if IsControlJustReleased(0, 38) then -- E
                        OpenStorageMenu(location.id)
                    end
                end
            end
        end
        
        if not nearStorage then
            Wait(500)
        end
    end
end)

-- Open storage menu
function OpenStorageMenu(locationId)
    ESX.TriggerServerCallback('quanxk5_storage:getPlayerStorages', function(storage)
        SendNUIMessage({
            action = 'openStorageMenu',
            locationId = locationId,
            storage = storage,
            tiers = Config.StorageTiers
        })
        SetNuiFocus(true, true)
    end, locationId)
end

-- Refresh storage
RegisterNetEvent('quanxk5_storage:client:refreshStorage')
AddEventHandler('quanxk5_storage:client:refreshStorage', function()
    if currentStorage then
        OpenStorageMenu(currentStorage)
    end
end)

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    SetNuiFocus(false, false)
    currentStorage = nil
    cb('ok')
end)

RegisterNUICallback('purchaseStorage', function(data, cb)
    currentStorage = data.locationId
    TriggerServerEvent('quanxk5_storage:server:purchaseStorage', data.locationId, data.password)
    cb('ok')
end)

RegisterNUICallback('upgradeStorage', function(data, cb)
    TriggerServerEvent('quanxk5_storage:server:upgradeStorage', data.storageId)
    cb('ok')
end)

RegisterNUICallback('accessStorage', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent('quanxk5_storage:server:accessStorage', data.storageId, data.password)
    cb('ok')
end)

RegisterNUICallback('changePassword', function(data, cb)
    TriggerServerEvent('quanxk5_storage:server:changePassword', data.storageId, data.newPassword)
    cb('ok')
end)

RegisterNUICallback('createLocation', function(data, cb)
    TriggerServerEvent('quanxk5_storage:server:createLocation', data)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, blip in pairs(blips) do
            RemoveBlip(blip)
        end
        SetNuiFocus(false, false)
    end
end)
