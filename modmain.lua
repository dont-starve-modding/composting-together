PrefabFiles = {
    "compostpile",
}

Assets = {
	Asset("IMAGE", "images/inventoryimages/compostpile.tex"),
	Asset("ATLAS", "images/inventoryimages/compostpile.xml"),
}

STRINGS = GLOBAL.STRINGS

function TableMerge(t1, t2)
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                TableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

NEWSTRINGS = GLOBAL.require("compostingtogetherstrings")
GLOBAL.STRINGS = TableMerge(GLOBAL.STRINGS, NEWSTRINGS)

-- Compost Pile Recipe

local recipe = AddRecipe("compostpile", {
        GLOBAL.Ingredient("rocks", 6),
        GLOBAL.Ingredient("poop", 3),
        GLOBAL.Ingredient("log", 4)
    },     
    GLOBAL.RECIPETABS.FARM,  
    GLOBAL.TECH.SCIENCE_ONE,
    "compostpile_placer"
)
recipe.atlas = "images/inventoryimages/compostpile.xml"

-- Add harvesting action to compost pile
local fn = GLOBAL.ACTIONS.HARVEST.fn
GLOBAL.ACTIONS.HARVEST.fn = function(act)
	if(act.target.components.composter) then
		act.target.components.composter:Harvest(act.doer)
		return true
	else
		return fn(act)
	end 
end

GLOBAL.ACTIONS.COMPOST = GLOBAL.Action({ priority=1, mount_valid=true })

GLOBAL.ACTIONS.COMPOST.fn  = function(act)
    if act.target.components.composter ~= nil then
        if act.target.components.composter:IsComposting() then
            return true
        end
        local container = act.target.components.container
        if container ~= nil and container:IsOpen() and not container:IsOpenedBy(act.doer) then
            return false, "INUSE"
        elseif not act.target.components.composter:CanCompost() then
            return false
        end
        act.target.components.composter:StartComposting()
        return true
    end
end

AddComponentAction("SCENE", "composter", function(inst, doer, actions, right)
    if not inst:HasTag("burnt") and
        not (doer.replica.rider ~= nil and doer.replica.rider:IsRiding()) then
        if inst:HasTag("donecomposting") then
            table.insert(actions, GLOBAL.ACTIONS.HARVEST)
        elseif right and
            -- (
            inst:HasTag("readytocompost")
            -- or (inst.replica.container ~= nil and
            --     inst.replica.container:IsFull() and
            --     inst.replica.container:IsOpenedBy(doer))) 
                then
            table.insert(actions, GLOBAL.ACTIONS.COMPOST)
        end
    end
end)

-- constants

-- composting times
-- TUNING.COMPOSTPILE_SMALLCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 3
-- TUNING.COMPOSTPILE_MEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 2
-- TUNING.COMPOSTPILE_LARGECOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 2.2
-- TUNING.COMPOSTPILE_ENLIGHTEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 4

TUNING.COMPOSTPILE_SMALLCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.025
TUNING.COMPOSTPILE_MEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.025
TUNING.COMPOSTPILE_LARGECOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.025
TUNING.COMPOSTPILE_ENLIGHTEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.025

-- recipe poop values
TUNING.COMPOSTPILE_SMALLCOMPOST_POOPAMOUNT = 2
TUNING.COMPOSTPILE_MEDCOMPOST_POOPAMOUNT = 4
TUNING.COMPOSTPILE_LARGECOMPOST_POOPAMOUNT = 6

-- composting high amounts of rotted stuff triggers the bonus (if the stuff is rotted 33% or lower (avg), you receive a bonus of 1 poop)
TUNING.COMPOSTPILE_ROTTYNESS_THRES = 0.33
TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_LOW = 0
TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_HIGH = 2

-- composting some fruits and veggies with this value, the fertility increases permanently (UPGRADE!)
TUNING.COMPOSTPILE_FERTILESOIL_THRES = TUNING.COMPOSTPILE_LARGECOMPOST_POOPAMOUNT+TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_HIGH
TUNING.COMPOSTPILE_FERTILE_SOIL_ADVANTAGE_PERCENT = 0.2

-- composting probably allures some fireflies
TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_LOW = 0.05
TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_HIGH = 0.95