local pfix = "__coldchainrework__/graphics/icon/"
local logistic_fridges = {"logistic-refrigerator-passive-provider","logistic-refrigerator-requester","logistic-refrigerator-buffer"}
local lr_tint = {{r=1,g=0.4,b=0.4},{r=0.4,g=0.4,b=1},{r=0.4,g=1,b=0.4}}



-- Add logistic fridge items
for i, fridge_type in pairs(logistic_fridges) do
    data:extend({
        {
        type = "item",
        name = fridge_type,
        icons =
            {{
            icon = pfix.."refrigerator.png",
            icon_size = 64,
            tint = lr_tint[i]
            }},
        subgroup = "cold-chain",
        order = "a[items]-c[" .. fridge_type .. "]",
        place_result = fridge_type,
        stack_size = 50
        }
    })
end



data:extend({
    {
    type = "item-subgroup",
    name = "cold-chain",
    group = "logistics",
    order = "cold-chain"
    },
    -- Refrigerator
    {
    type = "item",
    name = "refrigerator",
    icon = pfix.."refrigerator.png",
    icon_size = 64,
    subgroup = "cold-chain",
    order = "a[items]-c[refrigerator]",
    place_result = "refrigerator",
    stack_size = 50
    },
    -- Wagon
    {
    type = "item",
    name = "preservation-wagon",
    icons = 
        {{
        icon = data.raw["cargo-wagon"]["cargo-wagon"].icon,
        icon_size = data.raw["cargo-wagon"]["cargo-wagon"].icon_size,
        tint = {r=0.6, g=0.8, b=1.0, a=0.8},
        }},
    subgroup = "cold-chain",
    order = "a[items]-d[preservation-wagon]",
    place_result = "preservation-wagon",
    stack_size = 5
    },
    -- Inserters
    {
    type = "item",
    name = "preservation-inserter",
    icons = 
        {{
        icon = data.raw["inserter"]["fast-inserter"].icon,
        icon_size = data.raw["inserter"]["fast-inserter"].icon_size,
        tint = {r=0.6, g=0.8, b=1.0, a=0.8}
        }},
    subgroup = "cold-chain",
    order = "d[preservation]-a[preservation-inserter]",
    place_result = "preservation-inserter",
    stack_size = 50
    },
    {
    type = "item",
    name = "preservation-long-inserter",
    icons =
        {{
        icon = data.raw["inserter"]["long-handed-inserter"].icon,
        icon_size = data.raw["inserter"]["long-handed-inserter"].icon_size,
        tint = {r=0.6, g=0.8, b=1.0, a=0.8}
        }},
    subgroup = "cold-chain",
    order = "d[preservation]-b[preservation-long-inserter]",
    place_result = "preservation-long-inserter",
    stack_size = 50
    },
    {
    type = "item",
    name = "preservation-bulk-inserter",
    icons =
        {{
        icon = data.raw["inserter"]["bulk-inserter"].icon,
        icon_size = data.raw["inserter"]["bulk-inserter"].icon_size,
        tint = {r=0.6, g=0.8, b=1.0, a=0.8}
        }},
    subgroup = "cold-chain",
    order = "d[preservation]-c[preservation-bulk-inserter]",
    place_result = "preservation-bulk-inserter",
    stack_size = 50
    },
    -- Preservation warehouse
    {
    type = "item",
    name = "preservation-warehouse",
    icon = pfix.."large-chest.png",
    icon_size = 256,
    subgroup = "cold-chain",
    order = "a[items]-d[preservation-warehouse]",
    place_result = "preservation-warehouse",
    stack_size = 10
    }
})



-- Add space platform warehouse item if mod is present
if mods["space-age"] then
    data:extend({
        {
        type = "item",
        name = "preservation-platform-warehouse",
        icons =
            {{
            icon = data.raw["cargo-bay"]["cargo-bay"].icon,
            icon_size = data.raw["cargo-bay"]["cargo-bay"].icon_size,
            tint = {r=0.6, g=0.8, b=1.0, a=0.8},
            }},
        subgroup = "cold-chain",
        order = "a[items]-e[preservation-platform-warehouse]",
        place_result = "preservation-platform-warehouse",
        stack_size = 10
        },
        {
        type = "item",
        name = "preservation-stack-inserter",
        icons =
            {{
            icon = data.raw["inserter"]["stack-inserter"].icon,
            icon_size = data.raw["inserter"]["stack-inserter"].icon_size,
            tint = {r=0.6, g=0.8, b=1.0, a=0.8}
            }},
        subgroup = "cold-chain",
        order = "d[preservation]-d[preservation-stack-inserter]",
        place_result = "preservation-stack-inserter",
        stack_size = 50
        }
    })
end
