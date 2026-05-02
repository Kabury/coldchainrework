local kl = require("__klib__.klib")
local ul = require("util")
local meldy = require("meld")
local pifix = "__coldchainrework__/graphics/icon/"
local pfix = "__coldchainrework__/graphics/"



local refpic=
{
  layers = {
      {
          filename = pfix.."hr-refrigerator.png",
          priority = "extra-high",
          width = 66,
          height = 74,
          shift = util.by_pixel(0, -2),
          scale = 0.5
      },
      {
          filename = pfix.."hr-refrigerator-shadow.png",
          priority = "extra-high",
          width = 112,
          height = 46,
          shift = util.by_pixel(12, 4.5),
          draw_as_shadow = true,
          scale = 0.5
      }
  }
}

local refrigerator = {name="refrigerator",icons={{icon=pifix.."refrigerator.png",icon_size = 64}},mineable={result="refrigerator"},picture=refpic,inventory_size=settings.startup["ccr-fridge-capacity"].value}

local logistic_tables=
{
  {name = "logistic-refrigerator-passive-provider", minable={result="logistic-refrigerator-passive-provider"}, logistic_mode = "passive-provider", icons = {{tint={r=0.8, g=0.4, b=0.4}}}, picture={layers={{tint={r=0.8, g=0.4, b=0.4}}}}, type = "logistic-container", trash_inventory_size = 0},
  {name = "logistic-refrigerator-requester", minable={result="logistic-refrigerator-requester"}, logistic_mode = "requester", icons = {{tint={r=0.4, g=0.4, b=0.8}}}, picture={layers={{tint={r=0.4, g=0.4, b=0.8}}}}, type = "logistic-container", trash_inventory_size = 10},
  {name = "logistic-refrigerator-buffer", minable={result="logistic-refrigerator-buffer"}, logistic_mode = "buffer", icons = {{tint={r=0.4, g=0.8, b=0.4}}}, picture={layers={{tint={r=0.4, g=0.8, b=0.4}}}}, type = "logistic-container", trash_inventory_size = 10}
}



local pres_wagon = {name="preservation-wagon",minable={result="preservation-wagon"},color={r=0.6, g=0.8, b=1.0, a=0.8},allow_manual_color=false}



local pres_inserter = {name="preservation-inserter",minable={result="preservation-inserter"},energy_per_movement = "10kJ",energy_per_rotation = "10kJ",energy_source = {drain = "0.5kW"},next_upgrade = "preservation-bulk-inserter"}

local pres_long_inserter = {name="preservation-long-inserter",minable={result="preservation-long-inserter"},energy_per_movement = "15kJ",energy_per_rotation = "15kJ",energy_source = {drain = "0.7kW"}}

local pres_bulk_inserter = {name="preservation-bulk-inserter",minable={result="preservation-bulk-inserter"},energy_per_movement = "25kJ",energy_per_rotation = "25kJ",energy_source = {drain = "1kW"}}

local pres_stack_inserter = {}
if mods["space-age"] then
  pres_bulk_inserter.next_upgrade="preservation-stack-inserter"
  pres_stack_inserter = {name="preservation-stack-inserter",minable={result="preservation-stack-inserter"},energy_per_movement = "40kJ",energy_per_rotation = "40kJ",energy_source = {drain = "2kW"}}
end



refpic= {
  layers = {
      {
          filename = pfix.."large-chest.png",
          priority = "extra-high",
          width = 1024,
          height = 1024,
          shift = util.by_pixel(0, -30),
          scale = 0.25
      },
      {
          filename = pfix.."large-chest-shadow.png",
          priority = "extra-high",
          width = 1024,
          height = 600,
          shift = util.by_pixel(64, 1.5),
          draw_as_shadow = true,
          scale = 0.31
      }
  }
}

local pres_warehouse = {name="preservation-warehouse",icon=pifix.."large-chest.png",icon_size=256,minable={mining_time=6,result="preservation-warehouse"},picture=refpic,inventory_size=settings.startup["ccr-warehouse-capacity"].value,
  collision_box={{-2.8,-2.8},{2.8,2.8}},selection_box={{-3,-3},{3,3}},flags={"placeable-neutral","placeable-player","player-creation"},collision_mask={layers={item=true,object=true,player=true,water_tile=true}},corpse="big-remnants"}


local pres_space_warehouse = {}
if mods["space-age"] then
   pres_space_warehouse = {name="preservation-platform-warehouse",minable={mining_time=8,result="preservation-platform-warehouse"},surface_conditions = meldy.overwrite({}),inventory_size_bonus=settings.startup["ccr-platwarehouse-capacity"].value}
end



kl.qmeld("container","steel-chest",refrigerator)
for _,lfridge in pairs(logistic_tables) do
  kl.qmeld("container","refrigerator",lfridge)
end

kl.qmeld("cargo-wagon","cargo-wagon",pres_wagon)

kl.qmeld("inserter","fast-inserter",pres_inserter)
kl.qmeld("inserter","long-handed-inserter",pres_long_inserter)
kl.qmeld("inserter","bulk-inserter",pres_bulk_inserter)
ul.apply_preservation_tint(data.raw["inserter"]["presevation-inserter"])
ul.apply_preservation_tint(data.raw["inserter"]["preservation-long-inserter"])
ul.apply_preservation_tint(data.raw["inserter"]["preservation-bulk-inserter"])
if mods["space-age"] then
  kl.qmeld("inserter","stack-inserter",pres_stack_inserter)
  ul.apply_preservation_tint(data.raw["inserter"]["preservation-stack-inserter"])

  kl.qmeld("cargo-bay","cargo-bay",pres_space_warehouse)
  ul.apply_preservation_tint(data.raw["cargo-bay"]["preservation-platform-warehouse"])
end

kl.qmeld("container","steel-chest",pres_warehouse)



local power_proxy=
{
  name="warehouse-power-proxy",
  type="roboport",
  icon=pfix.."large-chest.png",
  icon_size = 256,
  charge_approach_distance=0,
  charging_energy="0W",
  construction_radius=0,
  energy_source={type= "electric",
    usage_priority= "secondary-input",
    input_flow_limit = (3 * settings.startup["ccr-warehouse-power-consumption"].value).."MW",
    buffer_capacity =settings.startup["ccr-warehouse-power-capacity"].value.."MJ"},
  energy_usage=settings.startup["ccr-warehouse-power-consumption"].value.."MW",
  material_slots_count=0,
  logistics_radius=0,
  recharge_minimum=(settings.startup["ccr-warehouse-power-capacity"].value*0.05).."MJ",
  request_to_open_door_timeout=15,
  robot_slots_count=0,
  spawn_and_station_height = 0,
  flags = {"not-blueprintable","not-deconstructable","placeable-off-grid","not-on-map","not-repairable","not-upgradable"}
}

data:extend({power_proxy})