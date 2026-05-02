data:extend({
    {
        type = "bool-setting",
        name = "ccr-balanced-mode",
        setting_type = "startup",
        default_value = true,
        order = "a"
    },
    {
        type = "int-setting",
        name = "ccr-fridge-capacity",
        setting_type = "startup",
        default_value = 20,
        minimum_value = 1,
        maximum_value = 80,
        order = "b"
    },
    {
        type = "int-setting",
        name = "ccr-warehouse-capacity",
        setting_type = "startup",
        default_value = 40,
        minimum_value = 1,
        maximum_value = 80,
        order = "c"
    },
    {
        type = "int-setting",
        name = "ccr-platwarehouse-capacity",
        setting_type = "startup",
        default_value = 10,
        minimum_value = 1,
        maximum_value = 40,
        hidden = true,
        order = "d"
    },
    {
        type = "int-setting",
        name = "ccr-numerator",
        setting_type = "runtime-global",
        default_value = 9,
        minimum_value = 1,
        maximum_value = 200,
        order = "e"
    },
    {
        type = "int-setting",
        name = "ccr-denominator",
        setting_type = "runtime-global",
        default_value = 10,
        minimum_value = 1,
        maximum_value = 200,
        order = "f"
    },
    {
        type = "int-setting",
        name = "ccr-tickspread",
        setting_type = "runtime-global",
        default_value = 1,
        minimum_value = 1,
        maximum_value = 200,
        order = "g"
    },
    {
        type = "bool-setting",
        name = "ccr-log",
        setting_type = "runtime-global",
        default_value = false,
        order = "h"
    },
    {
        type = "double-setting",
        name = "ccr-warehouse-power-consumption",
        setting_type = "startup",
        default_value = 10.0,
        minimum_value = 0.01,
        order = "i"
    },
    {
        type = "double-setting",
        name = "ccr-warehouse-power-capacity",
        setting_type = "startup",
        default_value = 3000,
        minimum_value = 0.1,
        order = "j"
    },
    
})
