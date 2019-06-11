require "prefabutil"
require "tuning"
require "modutil"

local containers = require("containers")

local composting = require("composting")

local assets=
{ 
	Asset("ANIM", "anim/compostpile.zip"),
	Asset("ANIM", "anim/flies.zip"),
	Asset("ANIM", "anim/ui_compostpile1c6x3.zip"),

	Asset("MINIMAP_IMAGE", "farm1"),
	Asset("MINIMAP_IMAGE", "farm2"),
	Asset("MINIMAP_IMAGE", "farm3"),
	
	-- for grass sounds opening (+others) the compostpile 
	-- Asset("SOUND", "sound/common.fsb"),
	
    -- Asset("ATLAS", "images/inventoryimages/compostpile.xml"),
    -- Asset("IMAGE", "images/inventoryimages/compostpile.tex"),
}

local prefabs = 
{
	"flies",
	"ash",
	"fireflies",
	
	"plant_normal",
	"farmrock",
	"farmrocktall",
	"farmrockflat",
	"stick",
	"stickleft",
	"stickright",
	"signleft",
	"signright",
	"fencepost",
	"fencepostright",
}

-- only poop obviously..
for k,v in pairs(composting.compostrecipes.compostpile) do
	table.insert(prefabs, v.name)
end

local back = -1
local front = 0
local left = 1.5
local right = -1.5

local rock_front = 1

local elements = {

		-- left side
		{ farmrock = {
				{ right + 2.3, 0, rock_front + 0.2 },
				{ right + 2.35, 0, rock_front - 1.5 },
			}
		},

		{ farmrocktall = { { right + 2.37, 0, rock_front - 1.0 }, }	},
		{ farmrockflat = { { right + 2.36, 0, rock_front - 0.4 }, }	},

		-- right side
		{ farmrock = { { left - 2.35, 0, rock_front - 1.0 }, } },
		{ farmrocktall = { { left - 2.37, 0, rock_front - 1.5 }, } },
		{ farmrockflat = { { left - 2.36, 0, rock_front - 0.4 }, } },

		-- front row
		{ farmrock = {
				{ right + 1.1, 0, rock_front + 0.21 },
				{ right + 2.4, 0, rock_front + 0.25 },
			}
		},

		{ farmrocktall = { { right + 0.5, 0, rock_front + 0.195 }, } },
		
		{ farmrockflat = {
				{ right + 1.8, 0, rock_front + 0.22 },
			}
		},

		{ fencepost = {
				{ left - 1.0,  0, back + 0.15 },
				{ right + 1, 0, back + 0.15 },
				{ left - 0.5,  0, back + 0.65 },
				{ left - 0.5,  0, back + 2.15 },
				{ right + 0.5,  0, back + 0.15 },
				{ right + 0.5,  0, back + 1.65 },
			},
		},

		{ fencepostright = {
				{ left - 0.5,  0, back + 0.15 },
				{ 0,		   0, back + 0.15 },
				{ left - 0.5,  0, back + 1.15 },
				{ left - 0.5,  0, back + 1.65 },
				{ 0,		    0, back + 0.15 },
				{ right + 0.5,  0, back + 0.65 },
				{ right + 0.5,  0, back + 1.15 },
				{ right + 0.5,  0, back + 2.15 },
			},
		},
  }


local function onopen(inst)
	if not inst:HasTag("burnt") then
		inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
	end
end

local function onclose(inst)
	if not inst:HasTag("burnt") then 
		inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
	end
end

local function onhammered(inst, worker)
	-- loot poop by destroying ur pile
	if inst.components.composter.done then
		inst.components.lootdropper:AddChanceLoot("poop", 1)
	end
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end


local slotpos = {	
	Vector3(0,			32+4,			0),
	Vector3(-(32+4),	-(32+4),		0), 
	Vector3((32+4),		-(32+4),		0),
	Vector3(-(32+4),	-(64+32+8+4),	0), 
	Vector3((32+4),		-(64+32+8+4),	0)
}

local compostpileparams =
{
	widget =
	{
		slotpos = {	
			Vector3(0,32+4,0),
			Vector3(-(32+4), -(32+4),0), 
			Vector3((32+4), -(32+4),0),
			Vector3(-(32+4), -(64+32+8+4),0), 
			Vector3((32+4), -(64+32+8+4),0)
		},
		animbank = "ui_compostpile1c6x3",
		animbuild = "ui_compostpile1c6x3",
		pos = Vector3(200, 0, 0),
		side_align_tip = 100,
		buttoninfo =
		{
			text = "Fill",
			position = Vector3(0, -170, 0),
		}
	},
	acceptsstacks = false,
	type = "cooker",
}

function compostpileparams.itemtestfn(container, item, slot)
	return composting.IsCompostIngredient(item.prefab) and not container.inst:HasTag("burnt")
end

function dump(o)
	if type(o) == 'table' then
	   local s = '{ '
	   for k,v in pairs(o) do
		  if type(k) ~= 'number' then k = '"'..k..'"' end
		  s = s .. '['..k..'] = ' .. dump(v) .. ','
	   end
	   return s .. '} '
	else
	   return tostring(o)
	end
 end

function compostpileparams.widget.buttoninfo.fn(inst)
	print("buttoninfo.fn")
	-- print(tostring(ACTIONS.COMPOST))
	print("ACTIONS.COMPOST:", dump(ACTIONS.COMPOST))
	if inst.components.container ~= nil then
		BufferedAction(inst.components.container.opener, inst, ACTIONS.COMPOST):Do()
	elseif inst.replica.container ~= nil and not inst.replica.container:IsBusy() then
		SendRPCToServer(RPC.DoWidgetButtonAction, ACTIONS.COMPOST.code, inst, ACTIONS.COMPOST.mod_name)
	end
end

-- "can 'Fill' be clicked?"
function compostpileparams.widget.buttoninfo.validfn(inst)
	print("buttoninfo.validfn")
	return inst.replica.container ~= nil and inst.replica.container:IsFull()
end

-- Overload containers.widgetsetup so we can assign widget params
local oldwidgetsetup = containers.widgetsetup
function containers.widgetsetup(container, prefab, data, ...)
	-- Without this condition, the custom override would affect all container prefabs
	if container.inst.prefab == "compostpile" then
		--data = pickle_barrel -- can't do it this way because other mods aren't carrying third param (data) through

		-- old way -- If mods ever update, we can uncomment the above assignment and get rid of this
		-- This method sucks because if Klei changes how containers.widgetsetup(...) works, this code needs to be changed too since it's a copy
        for k, v in pairs(compostpileparams) do
            container[k] = v
        end
        container:SetNumSlots(container.widget.slotpos ~= nil and #container.widget.slotpos or 0)
        return
        -- /old way
	end
	
    return oldwidgetsetup(container, prefab, data, ...)
end

--anim and sound callbacks

-- add some fancy flies flying around the dirty mess
local function addflies(inst)
	inst.flies = inst:SpawnChild("flies")
end

-- hooosh hoosh
local function removeflies(inst)
	if(inst.flies) then
		inst.flies:Remove()
		inst.flies = nil
	end
end


local function onfar(inst)
	inst.components.container:Close()
end

local function OnBurntDirty(inst)
    -- RefreshDecor(inst, inst._burnt:value())
end

local function OnBurnt(inst)
    inst._burnt:set(true)
    -- if not TheNet:IsDedicated() then
    --     -- RefreshDecor(inst, true)
    -- end
end

local function onbuilt(inst)
	inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
	-- inst.AnimState:PlayAnimation("place")
	-- inst.AnimState:PushAnimation("idle_empty")

	-- is called only on built
	inst.Transform:SetRotation(45)
end

local function makeburnable(inst)   
	local burnt_highlight_override = {.5,.5,.5}
	local function OnBurnt(inst)
		local function changes()
			if inst.components.burnable then
				inst.components.burnable:Extinguish()
			end
			inst:RemoveComponent("burnable")
			inst:RemoveComponent("propagator")
		end
			
		inst:DoTaskInTime(0.5, changes)
		for _ = 0, inst.components.composter.poopamount + 1, 1 do
			inst.components.lootdropper:SpawnLootPrefab("ash")	
		end

		inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
		inst.AnimState:PlayAnimation("idle_empty")
		inst.highlight_override = burnt_highlight_override
	end

	local function pile_burnt(inst)
		print("pile_burnt")
		OnBurnt(inst)
		removeflies(inst)
		inst.components.composter.composting = false
	end
	
	MakeLargeBurnable(inst)
	inst.components.burnable:SetFXLevel(5)
	inst.components.burnable:SetOnBurntFn(pile_burnt)
	
	MakeLargePropagator(inst)
end

local function OnHaunt(inst, haunter)
    return false
end

local function fn()
	print("fn")

	local function onsave(inst, data)
		print("onsave...")
		print(data.burnt)
		if inst:HasTag("burnt") or (inst.components.burnable ~= nil and inst.components.burnable:IsBurning()) then
			data.burnt = true
		end
	end
	
	local function onload(inst, data)
		print("onload...")
		print(data.burnt)
		if data ~= nil and data.burnt then
			inst.components.burnable.onburnt(inst)
		end
	end

	local function getstatus(inst)
		if inst:HasTag("burnt") then
			return "BURNT"
		end

		if inst.components.composter.composting then
			if inst.components.composter.rotamount > 0 then
				return "COMPOSTING_MEAT"
			end

			if inst.components.composter.poopamount + inst.components.composter.rottyness >= TUNING.COMPOSTPILE_FERTILESOIL_THRES then
				return "COMPOSTING_FERTILE"
			end

			if inst.components.composter:GetTimeToCompost() >= TUNING.TOTAL_DAY_TIME * 2 then
				return "COMPOSTING_LONG"
			else
				return "COMPOSTING_SHORT"
			end
		end

		if inst.components.composter.done then
			return "DONE"
		end
		
		return "EMPTY"
	end

	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddMiniMapEntity()
	inst.entity:AddNetwork()


	MakeObstaclePhysics(inst, 0.9)
    
    inst:AddTag("structure")
    
    inst.AnimState:SetBank("compostpile")
    inst.AnimState:SetBuild("compostpile")
	inst.AnimState:PlayAnimation("idle_empty")
	inst.AnimState:SetOrientation(ANIM_ORIENTATION.Default)
	inst.AnimState:SetLayer(LAYER_BACKGROUND)
	inst.AnimState:SetSortOrder(3)
	
	inst.MiniMapEntity:SetIcon("farm2.png")

	-- is called only on server load, not on built (see above!)
	-- inst.Transform:SetRotation(45)
	
	inst._burnt = net_bool(inst.GUID, "compostpile._burnt", "burntdirty")

	inst.decor = {}

	for k, item_info in pairs(elements) do
		for item_name, item_offsets in pairs(item_info) do
			for l, offset in pairs(item_offsets) do
				local item_inst = SpawnPrefab(item_name)
				item_inst.entity:SetParent(inst.entity)
				item_inst.Transform:SetPosition(offset[1], offset[2], offset[3])
				table.insert(inst.decor, item_inst)
			end
		end
	end

	print("ismastersim " .. tostring(TheWorld.ismastersim))
	if not TheWorld.ismastersim then
		inst:ListenForEvent("burntdirty", OnBurntDirty)

		return inst
	end

	MakeSnowCoveredPristine(inst)

	inst.entity:SetPristine()

	inst:AddComponent("inspectable")
	inst.components.inspectable.nameoverride = "COMPOSTPILE"
	inst.components.inspectable.getstatus = getstatus

	MakeLargeBurnable(inst, nil, nil, true)
	MakeMediumPropagator(inst)

    -- inst:AddComponent("playerprox") -- TODO valid in DST?
    -- inst.components.playerprox:SetDist(3,5)
    -- inst.components.playerprox:SetOnPlayerFar(onfar)
	
    -- inst.components.inventoryitem:SetOnDroppedFn(function() inst.flies = inst:SpawnChild("flies") end)
    -- inst.components.inventoryitem:SetOnPickupFn(function() if inst.flies then inst.flies:Remove() inst.flies = nil end end)
    -- inst.components.inventoryitem:SetOnPutInInventoryFn(function() if inst.flies then inst.flies:Remove() inst.flies = nil end end)

	print("makecontainer")

	inst:AddComponent("container")
	inst.components.container:WidgetSetup("compostpile", compostpileparams)
	-- inst.components.container:WidgetSetup("cookpot")
    inst.components.container.onopenfn = onopen
    inst.components.container.onclosefn = onclose

	inst:ListenForEvent("burntup", OnBurnt)  
	inst:ListenForEvent("onbuilt", onbuilt)

	print("makecomposter")

	local function startcompostfn(inst)
		if not inst:HasTag("burnt") then
			inst.AnimState:PlayAnimation("idle_empty")

			removeflies(inst)
			-- inst:RemoveComponent("burnable")
		end
	end

	local function donecompostfn(inst)
		if not inst:HasTag("burnt") then
			inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds")
			inst.AnimState:PlayAnimation("idle_full")
			addflies(inst)
		end
	end

	local function continuedonefn(inst)
		inst.AnimState:PlayAnimation("idle_full")
		addflies(inst)
	end

	local function continuecompostfn(inst)
		if not inst:HasTag("burnt") then
			removeflies(inst)
			inst.AnimState:PlayAnimation("idle_empty")
		end
	end

	local function harvestfn(inst)
		if not inst:HasTag("burnt") then
			inst.SoundEmitter:PlaySound("dontstarve/wilson/pickup_reeds") 
			inst.AnimState:PlayAnimation("idle_empty")
			-- removeflies(inst)		
		end
		removeflies(inst)
	end

    inst:AddComponent("composter")
    inst.components.composter.onstartcomposting = startcompostfn
    inst.components.composter.oncontinuecomposting = continuecompostfn
    inst.components.composter.oncontinuedone = continuedonefn
    inst.components.composter.ondonecomposting = donecompostfn
    inst.components.composter.onharvest = harvestfn

    inst:AddComponent("lootdropper")
    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)

	inst:AddComponent("savedrotation")

	inst:AddComponent("hauntable")
	inst.components.hauntable.cooldown = TUNING.HAUNT_COOLDOWN_SMALL
	inst.components.hauntable:SetOnHauntFn(OnHaunt)

    MakeSnowCovered(inst)

	inst.OnSave = onsave
	inst.OnLoad = onload

    return inst
end

return Prefab("common/compostpile", fn, assets, prefabs),
    MakePlacer("common/compostpile_placer", "compostpile", "compostpile", "idle_full")