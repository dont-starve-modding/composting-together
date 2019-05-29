local composting = require("composting")

-- Scene action callbacks

local function ondone(inst, done)
	if done then
			inst:AddTag("donecomposting")
	else
			inst:RemoveTag("donecomposting")
	end
end

local function oncheckready(inst)
	if inst.components.container ~= nil and
				not inst.components.container:IsOpen() and
			inst.components.composter:CanCompost() then
			inst:AddTag("readytocompost")
	end
end

local function onnotready(inst)
	if inst.components.container ~= nil and
			not inst.components.composter:CanCompost() then
		inst:RemoveTag("readytocompost")
	end
end

---------------------------

local Composter = Class(function(self, inst)
		self.inst = inst
		
		self.task = nil

    self.composting = false
    self.done = false
    
		self.poopamount = 0
		self.rotamount = 0
		self.rottyness = 0
		self.fertilesoil = false
		self.spawnfireflies = 0
    self.recipes = nil
		self.default_recipe = nil

		inst:ListenForEvent("itemget", oncheckready)
    inst:ListenForEvent("onclose", oncheckready)

    inst:ListenForEvent("itemlose", onnotready)
    inst:ListenForEvent("onopen", onnotready)
		
		self.inst:AddTag("composter")
end)

function Composter:OnRemoveFromEntity()
	self.inst:RemoveTag("donecomposting")
	self.inst:RemoveTag("readytocompost")
end

local function docompost(inst)
	print("docompost")
	inst.components.composter.task = nil
	
	if inst.components.composter.ondonecomposting then
		inst.components.composter.ondonecomposting(inst)
	end
	
	inst.components.composter.done = true
	inst.components.composter.composting = nil

	ondone(inst, inst.components.composter.done)
end

function Composter:GetTimeToCompost()
	if self.composting then
		return self.targettime - GetTime()
	end
	return 0
end

function Composter:IsComposting()
	return not self.done and self.targettime ~= nil
end

function Composter:GetTimeToCompost()
	return not self.done and self.targettime ~= nil and self.targettime - GetTime() or 0
end

function Composter:LongUpdate(dt)
	if self:IsComposting() then
			if self.task ~= nil then
					self.task:Cancel()
			end
			if self.targettime - dt > GetTime() then
					self.targettime = self.targettime - dt
					self.task = self.inst:DoTaskInTime(self.targettime - GetTime(), docompost, self)
					dt = 0            
			else
					dt = dt - self.targettime + GetTime()
					docompost(self.inst, self)
			end
	end
end


function Composter:CanCompost()
	local num = 0
	for k,v in pairs (self.inst.components.container.slots) do
		num = num + 1 
	end
	return num > 2
end


function Composter:StartComposting(time)
	if not self.done and not self.composting then
		if self.inst.components.container then
		
			self.done = nil
			self.composting = true
			
			if self.onstartcomposting then
				self.onstartcomposting(self.inst)
			end
		
			local spoilage_total = 0
			local spoilage_n = 0
			local compostables = {}			
			for k,v in pairs (self.inst.components.container.slots) do
				table.insert(compostables, v.prefab)
				if v.components.perishable then
					spoilage_n = spoilage_n + 1
					spoilage_total = spoilage_total + v.components.perishable:GetPercent()
				end
			end
			
			local composttime = TUNING.TOTAL_DAY_TIME*5
			self.poopamount, self.rotamount, composttime, self.spawnfireflies = composting.CalculateRecipe(self.inst.prefab, compostables)
						
			-- lower the composting time by given spoilage grade. spoilage total average spoilage of 50% lowers compost time by 25% (avg 20% -> 40%)
			-- maximum lowering-grade is 50% here
			if(spoilage_n > 0) then
				composttime = (composttime * (0.5 + (spoilage_total / (2*spoilage_n))))
				
				-- using all slots not only spoiled slots for calculation!
				if (spoilage_total/spoilage_n) <= TUNING.COMPOSTPILE_ROTTYNESS_THRES then
					self.rottyness = TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_HIGH
				else
					self.rottyness = TUNING.COMPOSTPILE_ROTTYNESS_POOP_BONUS_LOW
				end
			end
			
			-- if the compost pile is very fertile lower composttime by 10% again
			if (self.fertilesoil) then
				composttime = composttime * (1.0-TUNING.COMPOSTPILE_FERTILE_SOIL_ADVANTAGE_PERCENT)
			end
			
			-- all together composttime lowering-grade is 55%
			
			-- when putting a huge amount of big fruits and veggies on the pile + given spoilage, the pile becomes extra fertile
			if self.poopamount + self.rottyness >= TUNING.COMPOSTPILE_FERTILESOIL_THRES then
				self.fertilesoil = true
				GetPlayer().components.talker:Say("I can see some hard working worms!")
			end

			print("receive", self.poopamount, "poop");
			print("firefly spawn rate (%):", self.spawnfireflies);
			print("composting time in days: ", composttime/TUNING.TOTAL_DAY_TIME);

			self.targettime = GetTime() + composttime
			if self.task ~= nil then
					self.task:Cancel()
			end
			self.task = self.inst:DoTaskInTime(composttime, docompost, self)

			self.inst.components.container:Close()
			self.inst.components.container:DestroyContents()
			self.inst.components.container.canbeopened = false
		end
		
	end
end

-- TODO: what happens when the structure gets burned

-- local function StopProductPhysics(prod)
-- 	prod.Physics:Stop()
-- end

-- function Composter:StopCooking(reason)
-- 	if self.task ~= nil then
-- 			self.task:Cancel()
-- 			self.task = nil
-- 	end
-- 	if self.product ~= nil and reason == "fire" then
-- 			local prod = SpawnPrefab(self.product)
-- 			if prod ~= nil then
-- 					prod.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
-- 					prod:DoTaskInTime(0, StopProductPhysics)
-- 			end
-- 	end
-- 	self.spoiltime = nil
-- 	self.targettime = nil
-- 	self.done = nil
-- end


function Composter:OnSave()
	print("saving...")
	print(self.remainingtime)
	print(self.composting)
	print(self.done)
	print(self.fertilesoil)
	print(self.poopamount)
	print(self.rotamount)
	print(self.rottyness)
	print(self.spawnfireflies)
	return {
		remainingtime = self.targettime ~= nil and self.targettime - GetTime() or 0,
		composting = self.composting,
		done = self.done,
		
		fertilesoil = self.fertilesoil,
		poopamount = self.poopamount,
		rotamount = self.rotamount,
		rottyness = self.rottyness,
		spawnfireflies = self.spawnfireflies,
	}
end

function Composter:OnLoad(data)
	print("loading...")
	print(data.remainingtime)
	print(data.composting)
	print(data.done)
	print(data.fertilesoil)
	print(data.poopamount)
	print(data.rotamount)
	print(data.rottyness)
	print(data.spawnfireflies)

	self.fertilesoil = data.fertilesoil
	self.composting = data.composting or nil
	self.done = data.done or nil
	self.poopamount =data.poopamount;
	self.rotamount = data.rotamount;
	self.rottyness = data.rottyness;
	self.spawnfireflies = data.spawnfireflies;

	if self.task ~= nil then
			self.task:Cancel()
			self.task = nil
	end
	self.targettime = nil

	if data.remainingtime ~= nil then
		self.targettime = GetTime() + math.max(0, data.remainingtime)
		print("remainingtime " ..data.remainingtime)
		print("targettime "..self.targettime)

		if self.done then
			if self.oncontinuedone ~= nil then
					self.oncontinuedone(self.inst)
			end
		else
			self.task = self.inst:DoTaskInTime(data.remainingtime, docompost, self)
			if self.oncontinuecomposting ~= nil then
					self.oncontinuecomposting(self.inst)
			end
		end
	elseif self.oncontinuedone ~= nil then
			self.oncontinuedone(self.inst)
	end

	if self.inst.components.container ~= nil then
			self.inst.components.container.canbeopened = false
	end
end

function Composter:GetDebugString()
	local str = nil
	
	if self.composting then 
		str = "COMPOSTING" 
	elseif self.done then
		str = "FULL"
	else
		str = "EMPTY"
	end

	if self.targettime then
			str = str.." ("..tostring(self.targettime - GetTime())..")"
	end
    
	return str
end

function Composter:Harvest(harvester)
	if self.done then
		if self.onharvest then
			self.onharvest(self.inst)
		end

		self.done = nil

		local poop_stacksize = self.poopamount + self.rottyness
		local rot_stacksize = self.rotamount

		print("stack: "..poop_stacksize)
		if poop_stacksize > 0 then
			local loot = SpawnPrefab("poop")
			loot.components.stackable:SetStackSize(poop_stacksize)
			if harvester ~= nil and harvester.components.inventory ~= nil then
				harvester.components.inventory:GiveItem(loot, nil, self.inst:GetPosition())
			else
				LaunchAt(loot, self.inst, nil, 1, 1)
			end
		end

		if rot_stacksize > 0 then
			local loot_rot = SpawnPrefab("spoiled_food")
			loot.components.stackable:SetStackSize(rot_stacksize)
			if harvester ~= nil and harvester.components.inventory ~= nil then
				harvester.components.inventory:GiveItem(loot_rot, nil, self.inst:GetPosition())
			else
				LaunchAt(loot_rot, self.inst, nil, 1, 1)
			end
		end
		
		if math.random() <= self.spawnfireflies then
			local item_inst = SpawnPrefab("fireflies")
			item_inst.entity:SetParent(self.inst.entity)
			GetPlayer().components.talker:Say("I see bugs!")
		end

		if self.task ~= nil then
			self.task:Cancel()
			self.task = nil
		end
		self.targettime = nil
		self.done = nil

		if self.inst.components.container then		
			self.inst.components.container.canbeopened = true
		end

		ondone(self.inst, self.inst.components.composter.done)
		
		return true
	end
end


return Composter
