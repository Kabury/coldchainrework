local kl = require("__klib__.klib")
local logistic_fridges = {"logistic-refrigerator-passive-provider","logistic-refrigerator-requester","logistic-refrigerator-buffer"}



kl.qrecipe("refrigerator",{"steel-chest",1,"electric-engine-unit",1,"processing-unit",1,"uranium-fuel-cell",1,"plastic-bar",10,})
for k,v in pairs(logistic_fridges) do
    kl.qrecipe(v,{"refrigerator",1,"processing-unit",1,"advanced-circuit",2})
end

kl.qrecipe("preservation-wagon",{"cargo-wagon",1,"refrigerator",2,"advanced-circuit",5})

kl.qrecipe("preservation-inserter",{"fast-inserter",1,"electronic-circuit",2,"refrigerator",1})
kl.qrecipe("preservation-long-inserter",{"long-handed-inserter",1,"electronic-circuit",3,"refrigerator",1})
kl.qrecipe("preservation-bulk-inserter",{"bulk-inserter",1,"advanced-circuit",2,"refrigerator",1})

kl.qrecipe("preservation-warehouse",{"concrete",200,"plastic-bar",100,"steel-plate",50,"battery",50,"processing-unit",10,"electric-engine-unit",5})

if mods["space-age"] then
    kl.qrecipe("preservation-stack-inserter",{"stack-inserter",1,"advanced-circuit",4,"processing-unit",1,"refrigerator",1})

    kl.qrecipe("preservation-platform-warehouse",{"preservation-warehouse",1,"iron-plate",100})
end



local check = (not settings.startup["ccr-balanced-mode"].value) and mods["pypostprocessing"]
if check then
    kl.qrecipe("refrigerator",{"steel-chest",1,"petri-dish",1,"plastic-bar",10})
    for k,v in pairs(logistic_fridges) do
        kl.qrecipe(v,{"refrigerator",1,"electronic-circuit",2})
    end

    kl.qrecipe("preservation-wagon",{"cargo-wagon",1,"refrigerator",2,"electronic-circuit",5})

    kl.qrecipe("preservation-warehouse",{"concrete",200,"plastic-bar",100,"steel-plate",50,"battery",50,"electronic-circuit",10,"nichrome",5,"engine-unit",5})
end
