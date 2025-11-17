Config = {}

-- Framework
Config.Framework = 'ESX' -- ESX only for now

-- Admin Licenses (Can place storage locations)
Config.AdminLicenses = {
    'license:abc123example', -- Replace with actual FiveM licenses
    'license:def456example',
}

-- Storage System Settings
Config.StoragePrefix = 'storage_' -- Prefix for storage identifiers
Config.MaxStorageSlots = 50 -- Maximum slots per storage upgrade level
Config.DefaultWeight = 100000 -- Default weight limit (100kg)

-- Upgrade System
Config.StorageTiers = {
    [1] = {
        name = 'Basic Storage',
        slots = 25,
        weight = 100000,
        price = 50000, -- Initial purchase price
        description = 'Small storage unit with basic capacity'
    },
    [2] = {
        name = 'Medium Storage',
        slots = 50,
        weight = 200000,
        price = 500000, -- Upgrade cost
        description = 'Medium storage with expanded capacity'
    },
    [3] = {
        name = 'Large Storage',
        slots = 75,
        weight = 350000,
        price = 1500000, -- Upgrade cost
        description = 'Large storage unit for serious collectors'
    },
    [4] = {
        name = 'Premium Storage',
        slots = 100,
        weight = 500000,
        price = 3000000, -- Upgrade cost
        description = 'Maximum capacity premium storage'
    }
}

-- Password Settings
Config.PasswordMinLength = 4
Config.PasswordMaxLength = 12
Config.PasswordRequired = true -- Require password for all storages

-- Interaction Settings
Config.InteractionDistance = 2.5 -- Distance to interact with storage
Config.MarkerType = 27 -- Marker type for storage locations
Config.MarkerSize = {x = 1.0, y = 1.0, z = 1.0}
Config.MarkerColor = {r = 255, g = 255, b = 255, a = 100}
Config.UseTarget = false -- Set to true if using ox_target or qb-target

-- Storage Locations (Auto-populated by admin placement)
Config.StorageLocations = {
    -- Example format (will be added via /placestorage):
    -- {
    --     id = 1,
    --     coords = vector3(x, y, z),
    --     heading = 0.0,
    --     label = 'Downtown Storage #1',
    --     blip = true
    -- }
}

-- Blip Settings
Config.Blips = {
    enabled = true,
    sprite = 478,
    color = 5,
    scale = 0.8,
    name = 'Storage Unit'
}

-- Notifications
Config.Notifications = {
    purchaseSuccess = {
        title = 'Storage Purchased',
        message = 'You successfully purchased a storage unit for $%s',
        type = 'success',
        duration = 7500
    },
    purchaseFailed = {
        title = 'Purchase Failed',
        message = 'You don\'t have enough money ($%s required)',
        type = 'error',
        duration = 7500
    },
    upgradeSuccess = {
        title = 'Storage Upgraded',
        message = 'Storage upgraded to %s for $%s',
        type = 'success',
        duration = 7500
    },
    upgradeFailed = {
        title = 'Upgrade Failed',
        message = 'Insufficient funds or max tier reached',
        type = 'error',
        duration = 7500
    },
    passwordSet = {
        title = 'Password Set',
        message = 'Your storage password has been updated',
        type = 'success',
        duration = 7500
    },
    passwordIncorrect = {
        title = 'Access Denied',
        message = 'Incorrect password',
        type = 'error',
        duration = 7500
    },
    storageLimit = {
        title = 'Storage Limit',
        message = 'You already own the maximum number of storage units',
        type = 'error',
        duration = 7500
    },
    locationPlaced = {
        title = 'Location Placed',
        message = 'Storage location created successfully',
        type = 'success',
        duration = 7500
    }
}

-- Database Settings
Config.UseOxMySQL = true -- Set to false for mysql-async

-- Debug Mode
Config.Debug = false
