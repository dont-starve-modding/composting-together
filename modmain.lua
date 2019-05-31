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

TUNING.COMPOSTPILE_COST_ROCKS = 6
TUNING.COMPOSTPILE_COST_POOP = 4
TUNING.COMPOSTPILE_COST_LOG = 3

if (GetModConfigData("poop_amount") == "low") then
    TUNING.COMPOSTPILE_COST_ROCKS = 2
    TUNING.COMPOSTPILE_COST_POOP = 1
    TUNING.COMPOSTPILE_COST_LOG = 2
end
if (GetModConfigData("poop_amount") == "high") then
    TUNING.COMPOSTPILE_COST_ROCKS = 10
    TUNING.COMPOSTPILE_COST_POOP = 5
    TUNING.COMPOSTPILE_COST_LOG = 8
end

local recipe = AddRecipe("compostpile", {
        GLOBAL.Ingredient("rocks", COMPOSTPILE_COST_ROCKS),
        GLOBAL.Ingredient("log", COMPOSTPILE_COST_LOG),
        GLOBAL.Ingredient("poop", COMPOSTPILE_COST_POOP)
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
                then
            table.insert(actions, GLOBAL.ACTIONS.COMPOST)
        end
    end
end)

-- constants

-- composting times
TUNING.COMPOSTPILE_SMALLCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 3
TUNING.COMPOSTPILE_MEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 2
TUNING.COMPOSTPILE_LARGECOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 2.2
TUNING.COMPOSTPILE_ENLIGHTEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 4

-- TUNING.COMPOSTPILE_SMALLCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.025
-- TUNING.COMPOSTPILE_MEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.025
-- TUNING.COMPOSTPILE_LARGECOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.025
-- TUNING.COMPOSTPILE_ENLIGHTEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 0.025

if (GetModConfigData("compost_duration") == "realistic") then
    TUNING.COMPOSTPILE_SMALLCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 5
    TUNING.COMPOSTPILE_MEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 3.5
    TUNING.COMPOSTPILE_LARGECOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 4
    TUNING.COMPOSTPILE_ENLIGHTEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 7
end
if (GetModConfigData("compost_duration") == "efficient") then
    TUNING.COMPOSTPILE_SMALLCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 2
    TUNING.COMPOSTPILE_MEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 1.2
    TUNING.COMPOSTPILE_LARGECOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 1.4
    TUNING.COMPOSTPILE_ENLIGHTEDCOMPOST_TIME = TUNING.TOTAL_DAY_TIME * 2.4
end

-- recipe poop values
TUNING.COMPOSTPILE_SMALLCOMPOST_POOPAMOUNT = 2
TUNING.COMPOSTPILE_MEDCOMPOST_POOPAMOUNT = 4
TUNING.COMPOSTPILE_LARGECOMPOST_POOPAMOUNT = 6
if (GetModConfigData("poop_amount") == "low") then
    TUNING.COMPOSTPILE_SMALLCOMPOST_POOPAMOUNT = 1
    TUNING.COMPOSTPILE_MEDCOMPOST_POOPAMOUNT = 2
    TUNING.COMPOSTPILE_LARGECOMPOST_POOPAMOUNT = 3
end
if (GetModConfigData("poop_amount") == "high") then
    TUNING.COMPOSTPILE_SMALLCOMPOST_POOPAMOUNT = 3
    TUNING.COMPOSTPILE_MEDCOMPOST_POOPAMOUNT = 5
    TUNING.COMPOSTPILE_LARGECOMPOST_POOPAMOUNT = 7
end

-- composting high amounts of rotted stuff triggers the bonus (if the stuff is rotted 33% or lower (avg), you receive a bonus of 1 poop)
TUNING.COMPOSTPILE_ROTTYNESS_THRES = 0.33
TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_LOW = 0
TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_HIGH = 2

if (GetModConfigData("poop_amount") == "low") then
    TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_LOW = 0
    TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_HIGH = 1
end
if (GetModConfigData("poop_amount") == "high") then
    TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_LOW = 0
    TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_HIGH = 3
end


-- composting some fruits and veggies with this value, the fertility increases permanently (UPGRADE!)
TUNING.COMPOSTPILE_FERTILESOIL_THRES = TUNING.COMPOSTPILE_LARGECOMPOST_POOPAMOUNT+TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_HIGH
TUNING.COMPOSTPILE_FERTILE_SOIL_ADVANTAGE_PERCENT = 0.2
if (GetModConfigData("fertile_soil_advantage") == "low") then
    TUNING.COMPOSTPILE_FERTILE_SOIL_ADVANTAGE_PERCENT = 0.1
end
if (GetModConfigData("fertile_soil_advantage") == "high") then
    TUNING.COMPOSTPILE_FERTILE_SOIL_ADVANTAGE_PERCENT = 0.3
end


-- composting probably allures some fireflies
TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_LOW = 0.05
if (GetModConfigData("spawn_fireflies") == "always") then
    TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_LOW = 1
end
if (GetModConfigData("spawn_fireflies") == "off") then
    TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_LOW = 0
end

TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_HIGH = 0.95
if (GetModConfigData("spawn_fireflies") == "always") then
    TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_HIGH = 1
end
if (GetModConfigData("spawn_fireflies") == "off") then
    TUNING.COMPOSTPILE_FIREFLYSPAWN_PERCENT_HIGH = 0
end