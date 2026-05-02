local kl = require("__klib__.klib")
local logistic_fridges = {"logistic-refrigerator-passive-provider","logistic-refrigerator-requester","logistic-refrigerator-buffer"}
local inserters = {"preservation-inserter","preservation-long-inserter","preservation-bulk-inserter"}
local pfix = "__coldchainrework__/graphics/icon/"
local wagon = data.raw["cargo-wagon"]["cargo-wagon"]
local inserter = data.raw["inserter"]["inserter"]
local _order = kl.baseorder
local lvls = {2,4,4,2,6}
local cap = 1500

if mods["space-age"] then
    table.insert(inserters,"preservation-stack-inserter")

    table.insert(data.raw["technology"]["space-platform"].effects,
        {type = "unlock-recipe", recipe = "preservation-platform-warehouse"}
    )

    _order = kl.saorder
    lvls = {2,{1,1,1,1,0,0,0,1},4,2,10}
end

if mods["pypostprocessing"] then
    _order = kl.pyorder
    lvls = {kl.pyamounts[3],kl.pyamounts[7],kl.pyamounts[7],kl.pyamounts[3],kl.pyamounts[10]}

    if not settings.startup["ccr-balanced-mode"].value then
        lvls = {kl.pyamounts[1],kl.pyamounts[3],kl.pyamounts[2],kl.pyamounts[2],kl.pyamounts[3]}
        cap = 500
    end
end



kl.qtech("refrigerator",50,lvls[1],{pi={pfix.."refrigerator.png",64},pre={"electric-engine","processing-unit","plastics"},eff={"refrigerator"},order=_order})
kl.qtech("logistic-refrigerator",200,lvls[2],{pi={pfix.."refrigerator.png",64},pre={"refrigerator","logistic-system"},eff=logistic_fridges,order=_order})

kl.qtech("preservation-wagon",100,lvls[3],{pi={wagon.icon,64,0.6,0.8,1,0.8},pre={"railway", "refrigerator"},eff={"preservation-wagon"},t=true,order=_order})

kl.qtech("preservation-inserter",50,lvls[4],{pi={inserter.icon,64,0.6,0.8,1,0.8},pre={"logistics", "refrigerator"},eff=inserters,t=true,order=_order})

kl.qtech("preservation-warehouse",cap,lvls[5],{pi={pfix.."large-chest.png",256},pre={"logistic-refrigerator"},eff={"preservation-warehouse"},time=60,order=_order})
