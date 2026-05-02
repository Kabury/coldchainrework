---- Mod control
-- Original author LightningMaster
-- license MIT
-- copyright 2025
-- module control
-- Kabury Fork


---- Init
local function get_max_timer(itemStack)
    maxtick = game.tick + itemStack.prototype.get_spoil_ticks(itemStack.quality)
    return maxtick
end
local kl = require("__klib__.klib")


---- Settings
local freeze_numerator = settings.global["ccr-numerator"].value
local freeze_denominator = settings.global["ccr-denominator"].value
local freeze_tickspread = settings.global["ccr-tickspread"].value
local freeze_log = settings.global["ccr-log"].value


---- Initialize or update general storages of the mod
-- Count tables keep a counter of how many entities we need to keep track of.
-- Pool store the actual entity tables.
-- RM tables just help us to mark an entity for deletion later.
local function init_storage()
    storage.FridgeCount = storage.Fridgescount or 0
    storage.WagonCount = storage.WagonCount or 0
    storage.InserterCount = storage.InserterCount or 0
    storage.WarehouseCount = storage.WarehouseCount or 0
    storage.PWSurfaceCount = storage.PWSurfaceCount or 0

    storage.FridgePool = storage.FridgePool or {}
    storage.WagonPool = storage.WagonPool or {}
    storage.InserterPool = storage.InserterPool or {}
    storage.WarehousePool = storage.WarehousePool or {}
    storage.PWSurfacePool = storage.PWSurfacePool or {}

    storage.FridgeRM = storage.FridgeRM or {}
    storage.WagonRM = storage.WagonRM or {}
    storage.InserterRM = storage.InserterRM or {}
    storage.WarehouseRM = storage.WarehouseRM or {}
    storage.PWSurfaceRM = storage.PWSurfaceRM or {}
end



--- Cool the provided fridge by the given amount
-- @fridge_id  Identifier
-- @fridge     The entity to check
-- @amount     How many ticks should the spoilage timer increase
local function cool_fridge(fridge_id, fridge, amount)
    local rmflag = storage.FridgeRM[fridge_id].removeflag

    --Entry Checking
    if rmflag then
        storage.FridgeCount = storage.FridgeCount - 1
        return nil, true
    end

    if not (fridge and fridge.valid) then
        storage.FridgeCount = storage.FridgeCount - 1
        return nil, true
    end

    --Cooling
    local inv = fridge.get_inventory(defines.inventory.chest)
    for i = 1, #inv do
        local itemStack = inv[i]

        if not (itemStack and itemStack.valid_for_read and itemStack.spoil_tick > 0) then
            goto continue 
        end

        if freeze_log then
            game.print("Item refreshed at tick "..game.tick)
        end

        local limit = get_max_timer(itemStack)
        local refresh = itemStack.spoil_tick + amount
        itemStack.spoil_tick = math.min(limit,refresh)
        ::continue::
    end

    return nil

end


--- Cool the provided wagon by the given amount
-- @wagon_id   Identifier
-- @wagon      The entity to check
-- @amount     How many ticks should the spoilage timer increase
local function cool_wagon(wagon_id, wagon, amount)
    local rmflag = storage.WagonRM[wagon_id].removeflag

    --Entry Checking
    if rmflag then
        storage.WagonCount = storage.WagonCount - 1
        return nil, true
    end

    local inv = wagon.get_inventory(defines.inventory.cargo_wagon)
    if not inv then
        storage.WagonCount = storage.WagonCount - 1
        return nil, true
    end

    --Cooling
    for i = 1, #inv do
        local itemStack = inv[i]

        if not (itemStack and itemStack.valid_for_read and itemStack.spoil_tick > 0) then
            goto continue 
        end

        local limit = get_max_timer(itemStack)
        local refresh = itemStack.spoil_tick + amount
        itemStack.spoil_tick = math.min(limit,refresh)
        ::continue::
    end

    return nil
    
end


--- Cool the provided inserter by the given amount
-- @inserter_id    Identifier
-- @inserter       The entity to check
-- @amount         How many ticks should the spoilage timer increase
local function cool_inserter(inserter_id, inserter, amount)
    local rmflag = storage.InserterRM[inserter_id].removeflag

    --Entry Checking 
    if rmflag then
        storage.InserterCount = storage.InserterCount - 1
        return nil, true
    end

    if not (inserter and inserter.valid) then
        storage.InserterCount = storage.InserterCount - 1
        return nil, true
    end

    --Cooling
    local heldStack = inserter.held_stack

    if not (heldStack and heldStack.valid_for_read and heldStack.spoil_tick > 0) then
        return nil
    end

    local limit = get_max_timer(heldStack)
    local refresh = heldStack.spoil_tick + amount
    heldStack.spoil_tick = math.min(limit,refresh)

    return nil

end



--- Cool the provided warehouse by the given amount only if it's connected to electricity
-- @warehouse_id     Identifier
-- @warehouse_dict   The compound entity of the warehouse to check
-- @amount           How many ticks should the spoilage timer increase
local function cool_warehouse(warehouse_id, warehouse_dict, amount)
    local warehouse = warehouse_dict.warehouse
    local proxy = warehouse_dict.proxy
    local rmflag = storage.WarehouseRM[warehouse_id].removeflag

    --Entry checking
    if rmflag then
        if proxy and proxy.valid then
            proxy.destroy()
        end
        storage.WarehouseCount = storage.WarehouseCount - 1
        return nil, true
    end

    if not (warehouse and warehouse.valid and proxy and proxy.valid) then
        if proxy and proxy.valid then
            proxy.destroy()
        end
        storage.WarehouseCount = storage.WarehouseCount - 1
        return nil, true
    end

    if proxy.energy < 1200000 then
        return nil
    end

    --Cooling
    local inv = warehouse.get_inventory(defines.inventory.chest)
    for i=1, #inv do
        local itemStack = inv[i]

        if not (itemStack and itemStack.valid_for_read and itemStack.spoil_tick > 0) then
            goto continue
        end

        local limit = get_max_timer(itemStack)
        local refresh = itemStack.spoil_tick + amount
        itemStack.spoil_tick = math.min(limit,refresh)
        ::continue::
    end

    return nil

end


--- Cool the provided space platform warehouse by the given amount
-- Only runs if Space Age mod is active. Applies to all hubs on surface
-- @surface_name    Surface in which platwarehouses are.
-- @warehouses      Table to count how many are active
-- @amount          How many ticks should the spoilage timer increase
local function cool_pwsurface(surface_name, surface_dict, amount)
    if not script.active_mods["space-age"] then
        return nil
    end
    --Entry Checking

    local rmflag = storage.PWSurfaceRM[surface_name].removeflag

    if rmflag then
        storage.PWSurfaceCount = storage.PWSurfaceCount - 1
        return nil, true
    end

    local surface = game.surfaces[surface_name]

    if not surface then
        storage.PWSurfaceCount = storage.PWSurfaceCount - 1
        return nil, true
    end

    -- Calculate preservation capacity for this surface
    local bonus_slots = surface_dict.PlatWarehouseInternalCounter * settings.startup["ccr-platwarehouse-capacity"].value

    -- Find and process all platform hubs
    local platform_hubs = surface.find_entities_filtered{
        name = "space-platform-hub"
    }

    -- Process each hub's inventory
    for _, hub in pairs(platform_hubs) do
        local platform_inv = hub.get_inventory(defines.inventory.hub_main)

        if not platform_inv then
            goto next_hub
        end

        -- Track preserved slots for this hub
        local items_frozen = 0

        -- Process inventory slots up to capacity
        for i = 1, #platform_inv do
            -- Stop if we've reached preservation limit
            if items_frozen >= bonus_slots then break end

            local itemStack = platform_inv[i]

            if not (itemStack and itemStack.valid_for_read and itemStack.spoil_tick > 0) then
                goto next_item
            end

            local limit = get_max_timer(itemStack)
            local refresh = itemStack.spoil_tick + amount
            itemStack.spoil_tick = math.min(limit,refresh)

            items_frozen = items_frozen + 1
            ::next_item::
        end
        ::next_hub::
    end

end


--- Main tick handler that extends spoil time for items in fridges
-- @event            Event data from Factorio runtime
-- @field game.tick  Current game tick
local function on_tick(event)
    if game.tick % freeze_denominator == 0 then
        local FridgeRate = math.ceil( storage.FridgeCount / freeze_tickspread )
        local FridgeTick = math.ceil( storage.FridgeCount / FridgeRate ) * freeze_numerator

        storage.FridgeK = kl.for_n_of(storage.FridgePool, storage.FridgeK, FridgeRate, function(frid,numb) return cool_fridge(numb,frid,FridgeTick) end)
        if next(storage.FridgePool, storage.FridgeK) == nil then
            storage.FridgeK = kl.for_n_of(storage.FridgePool, storage.FridgeK, 1, function(frid,numb) return cool_fridge(numb,frid,FridgeTick) end)
        end

        if freeze_log then
            game.print("We want at most "..freeze_tickspread.." batches. We have "..storage.FridgeCount.." fridges. We will check "..FridgeRate.." each time. We will refresh by "..FridgeTick)
        end

        local WagonRate = math.ceil( storage.WagonCount / freeze_tickspread )
        local WagonTick = math.ceil( storage.WagonCount /  WagonRate ) * freeze_numerator
        storage.WagonK = kl.for_n_of(storage.WagonPool, storage.WagonK, WagonRate, function(wgn,numb) return cool_wagon(numb,wgn,WagonTick) end)
        if next(storage.WagonPool, storage.WagonK) == nil then
            storage.WagonK = kl.for_n_of(storage.WagonPool, storage.WagonK, 1, function(wgn,numb) return cool_wagon(numb,wgn,WagonTick) end)
        end

        local InserterRate = math.ceil( storage.InserterCount / freeze_tickspread )
        local InserterTick = math.ceil( storage.InserterCount /InserterRate ) * freeze_numerator
        storage.InserterK = kl.for_n_of(storage.InserterPool, storage.InserterK, InserterRate, function(pin,numb) return cool_inserter(numb,pin,InserterTick) end)
        if next(storage.InserterPool, storage.InserterK) == nil then
            storage.InserterK = kl.for_n_of(storage.InserterPool, storage.InserterK, 1, function(pin,numb) return cool_inserter(numb,pin,InserterTick) end)
        end

        local WarehouseRate = math.ceil( storage.WarehouseCount / freeze_tickspread )
        local WarehouseTick = math.ceil( storage.WarehouseCount / WarehouseRate ) * freeze_denominator
        storage.WarehouseK = kl.for_n_of(storage.WarehousePool, storage.WarehouseK, WarehouseRate, function(whd,numb) return cool_warehouse(numb,whd,WarehouseTick) end)
        if next(storage.WarehousePool, storage.WarehouseK) == nil then
            storage.WarehouseK = kl.for_n_of(storage.WarehousePool, storage.WarehouseK, 1, function(whd,numb) return cool_warehouse(numb,whd,WarehouseTick) end)
        end

        local PWSurfaceRate =  math.ceil( storage.PWSurfaceCount / freeze_tickspread )
        local PWSurfaceTick = math.ceil( storage.PWSurfaceCount / PWSurfaceRate ) * freeze_denominator
        storage.PWSurfaceK = kl.for_n_of(storage.PWSurfacePool, storage.PWSurfaceK, PWSurfaceRate, function(pwsurf,surfn) return cool_pwsurface(surfn,pwsurf,PWSurfaceTick) end)
        if next(storage.PWSurfacePool, storage.PWSurfaceK) == nil then
            storage.PWSurfaceK = kl.for_n_of(storage.PWSurfacePool, storage.PWSurfaceK, 1, function(pwsurf,surfn) return cool_pwsurface(surfn,pwsurf,PWSurfaceTick) end)
        end
    end
end

---- Runtime Events ----

--- Handle creation of preservation entities
-- Registers newly created entities in the appropriate storage tables
-- and performs any necessary setup (like creating power proxies for warehouses).
-- @event                        Event data containing the created entity
local function OnEntityCreated(event)
    local entity = event.created_entity or event.entity --Player or script
    if not (entity and entity.valid) then return end

    -- Handle entity based on type
    if entity.name:find("refrigerator") then
        storage.FridgePool[entity.unit_number] = entity
        storage.FridgeRM[entity.unit_number] = { removeflag = false }
        storage.FridgeCount = storage.FridgeCount + 1

    elseif entity.name == "preservation-wagon" then
        storage.WagonPool[entity.unit_number] = entity
        storage.WagonRM[entity.unit_number] = { removeflag = false }
        storage.WagonCount = storage.WagonCount + 1

    elseif entity.name:find("preservation%-inserter") then
        storage.InserterPool[entity.unit_number] = entity
        storage.InserterRM[entity.unit_number] = { removeflag = false }
        storage.InserterCount = storage.InserterCount + 1

    elseif entity.name == "preservation-warehouse" then
        -- Create power proxy for warehouse
        local proxy = entity.surface.create_entity{
            name = "warehouse-power-proxy",
            position = entity.position,
            force = entity.force
        }

        -- Register warehouse with its power proxy
        if proxy then
            storage.WarehousePool[entity.unit_number] = {
                warehouse = entity,
                proxy = proxy
            }
            storage.WarehouseCount = storage.WarehouseCount + 1
            storage.WarehouseRM[entity.unit_number] = { removeflag = false }
        end

    elseif entity.name == "preservation-platform-warehouse" then
        -- Initialize surface storage if needed
        local surface_name = entity.surface.name

        storage.PWSurfacePool[surface_name] = storage.PWSurfacePool[surface_name] or {}
        storage.PWSurfaceRM[surface_name] = storage.PWSurfaceRM[surface_name] or {}
        storage.PWSurfacePool[surface_name].PlatWarehouseInternalCounter = storage.PWSurfacePool[surface_name].PlatWarehouseInternalCounter or 0

        storage.PWSurfacePool[surface_name][entity.unit_number] = entity
        storage.PWSurfaceRM[surface_name] = { removeflag = false }

        if storage.PWSurfacePool[surface_name].PlatWarehouseInternalCounter == 0 then
            storage.PWSurfaceCount = storage.PWSurfaceCount + 1
        end
        storage.PWSurfacePool[surface_name].PlatWarehouseInternalCounter = storage.PWSurfacePool[surface_name].PlatWarehouseInternalCounter + 1
    end
end

--- Handle removal of preservation entities
-- Cleans up entity references from storage tables and performs any necessary
-- cleanup operations (like destroying power proxies for warehouses).
--
-- @param event Event data containing the removed entity
local function OnEntityRemoved(event)
    -- Verify entity is valid
    local entity = event.entity
    if not (entity and entity.valid) then return end

    -- Handle entity based on type
    if entity.name:find("refrigerator") then
        storage.FridgeRM[entity.unit_number].removeflag = true

    elseif entity.name == "preservation-wagon" then
        storage.WagonRM[entity.unit_number].removeflag = true

    elseif entity.name:find("preservation%-inserter") then
        storage.InserterRM[entity.unit_number].removeflag = true

    elseif entity.name == "preservation-warehouse" then
        storage.WarehouseRM[entity.unit_number].removeflag = true

    elseif entity.name == "preservation-platform-warehouse" then
        -- Remove from surface-specific storage
        local surface_name = entity.surface.name
        if storage.PWSurfacePool[surface_name] then
            for id, warehouse in pairs(storage.PWSurfacePool[surface_name]) do
                if warehouse == entity then
                    storage.PWSurfacePool[surface_name][id] = nil
                    storage.PWSurfacePool[surface_name].PlatWarehouseInternalCounter = storage.PWSurfacePool[surface_name].PlatWarehouseInternalCounter - 1
                    if storage.PWSurfacePool[surface_name].PlatWarehouseInternalCounter == 0 then
                        storage.PWSurfaceRM[surface_name].removeflag = true
                    end
                    break
                end
            end
        end
    end
end

---- Initialization Functions ----

--- Initialize or update mod settings
-- Updates global variables with current mod settings
--
local function init_settings()
    freeze_numerator = settings.global["ccr-numerator"].value
    freeze_denominator = settings.global["ccr-denominator"].value
    freeze_tickspread = settings.global["ccr-tickspread"].value
end

--- Find and register all preservation entities across all surfaces
-- Scans all game surfaces for preservation entities (refrigerators, warehouses,
-- wagons, etc.) and registers them in the appropriate storage tables. Also
-- handles cleanup of old power proxies and initialization of new ones.
--
-- @function init_entities
local function init_entities()
    -- Reset all storage tables
    storage.FridgeCount = 0
    storage.WagonCount = 0
    storage.InserterCount = 0
    storage.WarehouseCount = 0
    storage.PWSurfaceCount = 0

    storage.FridgePool = {}
    storage.WagonPool = {}
    storage.InserterPool = {}
    storage.WarehousePool = {}
    storage.PWSurfacePool = {}

    storage.FridgeRM = storage.FridgeRM or {}
    storage.WagonRM = storage.WagonRM or {}
    storage.InserterRM = storage.InserterRM or {}
    storage.WarehouseRM = storage.WarehouseRM or {}
    storage.PWSurfaceRM = storage.PlatWarehouseRM or {}

    -- Process each game surface
    for _, surface in pairs(game.surfaces) do

        -- Find and register basic and logistic refrigerators
        local refrigerators = surface.find_entities_filtered{
            name = {
                "refrigerator",
                "logistic-refrigerator-passive-provider",
                "logistic-refrigerator-requester",
                "logistic-refrigerator-buffer"
            }
        }
        for _, fridge in pairs(refrigerators) do
            storage.FridgePool[fridge.unit_number] = fridge
            storage.FridgeRM[fridge.unit_number] = { removeflag = false }
            storage.FridgeCount = storage.FridgeCount + 1
        end

        -- Find and register preservation wagons
        local wagons = surface.find_entities_filtered{
            name = "preservation-wagon"
        }
        for _, wagon in pairs(wagons) do
            storage.WagonPool[wagon.unit_number] = wagon
            storage.WagonRM[wagon.unit_number] = { removeflag = false }
            storage.WagonCount = storage.WagonCount + 1
        end

        -- Find and register preservation inserters
        local insertername = script.active_mods["space-age"] and {
            "preservation-inserter",
            "preservation-long-inserter",
            "preservation-bulk-inserter",
            "preservation-stack-inserter"
        } or {
            "preservation-inserter",
            "preservation-long-inserter",
            "preservation-bulk-inserter"
        }
        local inserters = surface.find_entities_filtered{ name = insertername }
        for _, inserter in pairs(inserters) do
            storage.InserterPool[inserter.unit_number] = inserter
            storage.InserterRM[inserter.unit_number] = { removeflag = false }
            storage.InserterCount = storage.InserterCount + 1
        end

        -- Clean up old power proxies first
        local old_proxies = surface.find_entities_filtered{
            name = "warehouse-power-proxy"
        }
        for _, proxy in pairs(old_proxies) do
            proxy.destroy()
        end

        -- Find and register warehouses with power proxies
        local warehouses = surface.find_entities_filtered{
            name = "preservation-warehouse"
        }
        for _, warehouse in pairs(warehouses) do
            -- Create new power proxy for warehouse
            local proxy = surface.create_entity{
                name = "warehouse-power-proxy",
                position = warehouse.position,
                force = warehouse.force
            }

            -- Register warehouse with its proxy
            if proxy then
                storage.WarehousePool[warehouse.unit_number] = {
                    warehouse = warehouse,
                    proxy = proxy
                }
            end
            storage.WarehouseRM[warehouse.unit_number] = { removeflag = false }
            storage.WarehouseCount = storage.WarehouseCount + 1
        end

        if script.active_mods["space-age"] then
            -- Find and register platform warehouses
            local platform_warehouses = surface.find_entities_filtered{
                name = "preservation-platform-warehouse"
            }
            if #platform_warehouses > 0 then
                storage.PWSurfacePool[surface.name] = {}
                for id, platwarehouse in pairs(platform_warehouses) do
                    storage.PWSurfacePool[surface.name][platwarehouse.unit_number] = platwarehouse
                end  
                storage.PWSurfacePool[surface.name].PlatWarehouseInternalCounter = #platform_warehouses
                storage.PWSurfaceRM[surface.name] = { removeflag = false }
                storage.PWSurfaceCount = storage.PWSurfaceCount + 1
            end
        end
    end
end


---- Event Registration ----

--- Register all event handlers for preservation entities
-- Sets up event handlers for entity creation, removal, and periodic updates.
-- Also handles mod settings changes.
--
-- @function init_events
local function init_events()
    -- Define entity filter for all preservation-related entities
    local entity_filter = {
        { filter = "name", name = "refrigerator" },
        { filter = "name", name = "logistic-refrigerator-passive-provider" },
        { filter = "name", name = "logistic-refrigerator-requester" },
        { filter = "name", name = "logistic-refrigerator-buffer" },
        { filter = "name", name = "preservation-warehouse" },
        { filter = "name", name = "preservation-wagon" },
        { filter = "name", name = "preservation-inserter" },
        { filter = "name", name = "preservation-long-inserter" },
        { filter = "name", name = "preservation-stack-inserter" }
    }

    if script.active_mods["space-age"] then
      table.insert(entity_filter, { filter = "name", name = "preservation-platform-warehouse" })
      table.insert(entity_filter, { filter = "name", name = "preservation-bulk-inserter" })
    end

    -- Register entity creation events
    local creation_events = {
        defines.events.on_built_entity,              -- Player built
        defines.events.on_entity_cloned,             -- Entity copied
        defines.events.on_robot_built_entity,        -- Robot built
        defines.events.on_space_platform_built_entity, -- Space platform
        defines.events.script_raised_built,          -- Script created
        defines.events.script_raised_revive          -- Entity revived
    }
    for _, event in pairs(creation_events) do
        script.on_event(event, OnEntityCreated, entity_filter)
    end

    -- Register entity removal events
    local removal_events = {
        defines.events.on_player_mined_entity,         -- Player removed
        defines.events.on_robot_mined_entity,          -- Robot removed
        defines.events.on_space_platform_mined_entity, -- Space platform
        defines.events.on_entity_died,                 -- Entity destroyed
        defines.events.script_raised_destroy           -- Script removed
    }
    for _, event in pairs(removal_events) do
        script.on_event(event, OnEntityRemoved, entity_filter)
    end

    -- Register update events
    script.on_event(defines.events.on_tick, on_tick)
    script.on_event(defines.events.on_runtime_mod_setting_changed, init_settings)
end

---- Script Lifecycle Handlers ----

-- Handle mod loading (called when save is loaded)
script.on_load(function()
    init_events()
end)

-- Handle initial mod setup (called when mod is first added to save)
script.on_init(function()
    init_storage()
    init_entities()
    init_events()
end)

-- Handle mod configuration changes
script.on_configuration_changed(function(data)
    init_settings()
    init_entities()
    init_events()
end)
