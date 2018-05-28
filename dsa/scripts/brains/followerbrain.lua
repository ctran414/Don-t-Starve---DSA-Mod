require "behaviours/dsafollow"
require "behaviours/dsawander"
require "behaviours/faceentity"
require "behaviours/chaseandattack"
require "behaviours/runaway"
require "behaviours/panic"
require "behaviours/dsadoaction"
require "behaviours/dsafindlight"
require "behaviours/findheat"
require "behaviours/findcold"
require "behaviours/findshelter"

local TARGET_FOLLOW_DIST = 5
local MAX_FOLLOW_DIST = 9
local MAX_CHASE_TIME = 10
local MAX_CHASE_DIST = 10
local SEE_WORK_DIST = 10
local KEEP_WORKING_DIST = 15
local RUN_AWAY_DIST = 5
local STOP_RUN_AWAY_DIST = 10
local SEE_ITEM_DIST = 10
local SEE_WALL_DIST = 10
local SEE_PLOT_DIST = 10
local MAX_WORK_DIST = 10
local MAX_FISH_DIST = 12
local MAX_PICK_DIST = 10
local MIN_WANDER_DIST = 3
local WANDER_TIMES = {minwalktime=2,randwalktime=4,minwaittime=5,randwaittime=10}
local STAY_WANDER_TIMES = {minwalktime=1,randwalktime=1,minwaittime=5,randwaittime=10}

local Follower = Class(Brain, function(self, inst)
    Brain._ctor(self, inst)
end)

local function GetFaceTargetFn(inst)
    return inst.components.follower.leader
end

local function KeepFaceTargetFn(inst, target)
    return inst.components.follower.leader == target
end

local function GetLeader(inst)
    return inst.components.follower and inst.components.follower.leader
end

local function StartChoppingCondition(inst)
	local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
    return ((item and item.components.tool and item.components.tool:CanDoAction(ACTIONS.CHOP)) or (inst.components.beaverness and inst.components.beaverness:IsBeaver())) and (inst.components.followercommands:IsCurrentlyStaying() == true or (inst.components.followercommands:IsCurrentlyStaying() == false and inst.components.follower.leader ~= nil and inst.components.follower.leader:GetDistanceSqToInst(inst) <= MAX_WORK_DIST*MAX_WORK_DIST))
end

local function FindTreeToChopAction(inst)
    local target = FindEntity(inst, SEE_WORK_DIST, function(item) 
					if inst.components.beaverness and inst.components.beaverness:IsBeaver() then
						return item.components.workable and item.components.workable.action == ACTIONS.CHOP 
					else
						return item.components.workable and item.components.workable.action == ACTIONS.CHOP and ((item.components.growable and item.components.growable.stage == 3) or item.prefab == "marsh_tree" or item:HasTag("burnt"))
					end
				end)
	local invObject = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
    if target then
        return BufferedAction(inst, target, ACTIONS.CHOP, invObject)
    end
end

local function KeepChoppingAction(inst)
	local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
    return ((item and item.components.tool and item.components.tool:CanDoAction(ACTIONS.CHOP)) or (inst.components.beaverness and inst.components.beaverness:IsBeaver())) and (inst.components.followercommands:IsCurrentlyStaying() == true or (inst.components.followercommands:IsCurrentlyStaying() == false and inst.components.follower.leader ~= nil and inst.components.follower.leader:GetDistanceSqToInst(inst) <= KEEP_WORKING_DIST*KEEP_WORKING_DIST))
end

local function StartMiningCondition(inst)	
	local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
    return ((item and item.components.tool and item.components.tool:CanDoAction(ACTIONS.MINE)) or (inst.components.beaverness and inst.components.beaverness:IsBeaver())) and (inst.components.followercommands:IsCurrentlyStaying() == true or (inst.components.followercommands:IsCurrentlyStaying() == false and inst.components.follower.leader ~= nil and inst.components.follower.leader:GetDistanceSqToInst(inst) <= MAX_WORK_DIST*MAX_WORK_DIST))
end

local function FindRockToMineAction(inst)
    local target = FindEntity(inst, SEE_WORK_DIST, function(item) return item.components.workable and item.components.workable.action == ACTIONS.MINE end)
	local invObject = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
    if target then
        return BufferedAction(inst, target, ACTIONS.MINE, invObject)
    end
end

local function KeepMiningAction(inst)
	local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
    return ((item and item.components.tool and item.components.tool:CanDoAction(ACTIONS.MINE)) or (inst.components.beaverness and inst.components.beaverness:IsBeaver())) and (inst.components.followercommands:IsCurrentlyStaying() == true or (inst.components.followercommands:IsCurrentlyStaying() == false and inst.components.follower.leader ~= nil and inst.components.follower.leader:GetDistanceSqToInst(inst) <= MAX_WORK_DIST*MAX_WORK_DIST))
end

local function RepairAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end	
	
	local hayWall = FindEntity(inst, SEE_WALL_DIST, function(item) return item.prefab == "wall_hay" and item.components.health:GetPercent() < 1.0 end)
	if hayWall then
		local hayObject = inst.components.inventory:FindItem(function(item) return item.prefab == "cutgrass" or item.prefab == "wall_hay_item" end)
		if hayObject then
			return BufferedAction(inst, hayWall, ACTIONS.REPAIR, hayObject)
		end
	end
	
	local woodWall = FindEntity(inst, SEE_WALL_DIST, function(item) return item.prefab == "wall_wood" and item.components.health:GetPercent() < 1.0 end)
	if woodWall then
		local woodObject = inst.components.inventory:FindItem(function(item) return item.prefab == "log" or item.prefab == "twigs" or item.prefab == "boards" or item.prefab == "wall_wood_item" end)
		if woodObject then
			return BufferedAction(inst, woodWall, ACTIONS.REPAIR, woodObject)
		end
	end	
	
	local stoneWall = FindEntity(inst, SEE_WALL_DIST, function(item) return item.prefab == "wall_stone" and item.components.health:GetPercent() < 1.0 end)
	if stoneWall then
		local stoneObject = inst.components.inventory:FindItem(function(item) return item.prefab == "rocks" or item.prefab == "cutstone" or item.prefab == "wall_stone_item" end)
		if stoneObject then
			return BufferedAction(inst, stoneWall, ACTIONS.REPAIR, stoneObject)
		end
	end
	
	local ruinsWall = FindEntity(inst, SEE_WALL_DIST, function(item) return item.prefab == "wall_ruins" and item.components.health:GetPercent() < 1.0 end)
	if ruinsWall then
		local ruinsObject = inst.components.inventory:FindItem(function(item) return item.prefab == "thulecite_pieces" or item.prefab == "thulecite" or item.prefab == "wall_ruins_item" end)
		if ruinsObject then
			return BufferedAction(inst, ruinsWall, ACTIONS.REPAIR, ruinsObject)
		end
	end
end

local function FarmAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end	
			
	local seeds = inst.components.inventory:FindItem(function(item) return item.components.edible and item.components.edible.foodtype == "SEEDS" end)
	if seeds then
		local plot = FindEntity(inst, SEE_PLOT_DIST, function(item) return item.components.grower and item.components.grower:IsEmpty() end)
		if plot then
			return BufferedAction(inst, plot, ACTIONS.PLANT, seeds)
		end
	
		local crop = FindEntity(inst, SEE_PLOT_DIST, function(item) return item.components.crop and item.components.crop:IsReadyForHarvest() end)
		if crop then
			return BufferedAction(inst, crop, ACTIONS.HARVEST)
		end
	end	
end

local function TrapAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end	
	local trap = inst.components.inventory:FindItem(function(item) return item.components.trap end)
	if trap then
		inst.components.inventory:DropItem(trap)
	end
	
	trap = FindEntity(inst, SEE_PLOT_DIST, function(item) return item.components.trap and item.components.trap:IsSprung() end)
	if trap then
		return BufferedAction(inst, trap, ACTIONS.CHECKTRAP)
	end	
	
	local bait = inst.components.inventory:FindItem(function(item) return item.components.edible and item.components.edible.foodtype == "SEEDS" end)
	if bait then
		trap = FindEntity(inst, SEE_PLOT_DIST, function(item) return item.components.trap and item.components.trap.targettag == "bird" and not item.components.trap:IsSprung() end)	
		if trap then
			return BufferedAction(inst, trap, ACTIONS.BAIT, bait)
		end	
	end	
end

local function MurderAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end	
	
	local victim = inst.components.inventory:FindItem(function(item) return item.components.health and item.components.health.canmurder == true end)
	if victim then
		return BufferedAction(inst, victim, ACTIONS.MURDER)
	end
	
end

local function DryAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end	

	local meat = inst.components.inventory:FindItem(function(item) return item.components.dryable end)
	if meat then	
		local dryrack = FindEntity(inst, SEE_WALL_DIST, function(item) return item.components.dryer and item.components.dryer:CanDry(meat) end)
		if dryrack then
			return BufferedAction(inst, dryrack, ACTIONS.DRY, meat)
		end
		dryrack = FindEntity(inst, SEE_WALL_DIST, function(item) return item.components.dryer and item.components.dryer:IsDone() end)
		if dryrack then
			return BufferedAction(inst, dryrack, ACTIONS.HARVEST)
		end
	end
end

local function StartEatingCondition(inst)
	return inst.components.hunger:GetPercent() < .5
end

local function FindFoodAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end
	
    local target = nil
    
    if inst.components.inventory and inst.components.eater then
        target = inst.components.inventory:FindItem(function(item) 
				if item.prefab == "seeds" or item.prefab == "carrot_seeds" or item.prefab == "corn_seeds" or item.prefab == "dragonfruit_seeds" or item.prefab == "durian_seeds" or item.prefab == "eggplant_seeds" or item.prefab == "pomegranate_seeds" or item.prefab == "pumpkin_seeds" or item.prefab == "watermelon_seeds" or item.prefab == "mandrake" or item.prefab == "spoiled_food" or item.prefab == "petals" or item.prefab == "petals_evil" or item.prefab == "red_cap" or item.prefab == "blue_cap" or item.prefab == "green_cap" then 
					return false 
				end
				--No raw meats unless starving
				if not inst.components.hunger:IsStarving() and (item.prefab == 'smallmeat' or item.prefab == 'batwing' or item.prefab == 'drumstick' or item.prefab == 'froglegs' or item.prefab == 'plantmeat' or item.prefab == 'meat' or item.prefab == 'monstermeat' or item.prefab == 'cactus_meat' or item.prefab == 'durian' or item.prefab == 'minotaurhorn' or item.prefab == 'deerclops_eyeball') then
					return false
				end
				return inst.components.eater:CanEat(item) 
			end)
    end
    
    if not target then
        target = FindEntity(inst, SEE_ITEM_DIST, function(item) 
				if item.prefab == "seeds"  or item.prefab == "carrot_seeds" or item.prefab == "corn_seeds" or item.prefab == "dragonfruit_seeds" or item.prefab == "durian_seeds" or item.prefab == "eggplant_seeds" or item.prefab == "pomegranate_seeds" or item.prefab == "pumpkin_seeds" or item.prefab == "watermelon_seeds" or item.prefab == "mandrake" or item.prefab == "spoiled_food" or item.prefab == "petals" or item.prefab == "petals_evil" or item.prefab == "red_cap" or item.prefab == "blue_cap" or item.prefab == "green_cap" or not item:IsOnValidGround() then 
					return false 
				end				
				--No raw meats unless starving
				if not inst.components.hunger:IsStarving() and (item.prefab == 'smallmeat' or item.prefab == 'batwing' or item.prefab == 'drumstick' or item.prefab == 'froglegs' or item.prefab == 'plantmeat' or item.prefab == 'meat' or item.prefab == 'monstermeat' or item.prefab == 'cactus_meat' or item.prefab == 'durian' or item.prefab == 'minotaurhorn' or item.prefab == 'deerclops_eyeball') then
					return false
				end
				return inst.components.eater:CanEat(item) 
			end)
    end
    if target then
        return BufferedAction(inst, target, ACTIONS.EAT)
    end

    if not target then
        target = FindEntity(inst, SEE_ITEM_DIST, function(item) 
                if not item.components.shelf then return false end
                if not item.components.shelf.itemonshelf or not item.components.shelf.cantakeitem then return false end
                if not item:IsOnValidGround() then
                    return false
                end
                return inst.components.eater:CanEat(item.components.shelf.itemonshelf) 
            end)
    end

    if target then
        return BufferedAction(inst, target, ACTIONS.TAKEITEM)
    end
end

local function HasValue(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

local function StartPickingCondition(inst)
	return (inst.components.inventory and not inst.components.inventory:IsFull()) and inst.components.followercommands and (inst.components.followercommands:IsCurrentlyStaying() == true or (inst.components.followercommands:IsCurrentlyStaying() == false and inst.components.follower.leader ~= nil and inst.components.follower.leader:GetDistanceSqToInst(inst) <= MAX_PICK_DIST*MAX_PICK_DIST))
end

local function PickItemAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end
	
	local items = {}
	for k = 1,inst.components.inventory.maxslots do
        local v = inst.components.inventory.itemslots[k]
        if v then
			if v.prefab == "cutgrass" then
				table.insert(items, "grass")
			elseif v.prefab == "cutreeds" then
				table.insert(items, "reeds")
			elseif v.prefab == "twigs" then
				table.insert(items, "sapling")
				table.insert(items, "marsh_bush")
			elseif v.prefab == "petals" then
				table.insert(items, "flower")
			elseif v.prefab == "carrot" then
				table.insert(items, "carrot_planted")
			elseif v.prefab == "berries" then
				table.insert(items, "berrybush")
				table.insert(items, "berrybush2")
			elseif v.prefab == "cactus_meat" then
				table.insert(items, "cactus")
			elseif v.prefab == "lightbulb" then
				table.insert(items, "flower_cave")
				table.insert(items, "flower_cave_double")
				table.insert(items, "flower_cave_triple")
			elseif v.prefab == "cave_banana" then
				table.insert(items, "cave_banana_tree")
			elseif v.prefab == "cutlichen" then
				table.insert(items, "lichen")
			elseif v.prefab == "foliage" then
				table.insert(items, "cave_fern")
			end
        end
    end
	
	if items then
		local target = FindEntity(inst, SEE_ITEM_DIST, function(item) return HasValue(items, item.prefab) and item.components.pickable and item.components.pickable:CanBePicked()
			end)
		if target then
			return BufferedAction(inst, target, ACTIONS.PICK)
		end
	end
end

local function PickUpItemAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end
	
	if inst.prefab == 'dsawoodie' and inst.components.inventory:Has('dsalucy',0) and (inst.components.beaverness and not inst.components.beaverness:IsBeaver()) then
		local target = FindEntity(inst, SEE_ITEM_DIST, function(item) return item.prefab == 'dsalucy' end)
		if target then
			return BufferedAction(inst, target, ACTIONS.PICKUP)
		end
	end

	if inst.prefab == 'dsawillow' and inst.components.inventory:Has('dsalighter',0) then
		local target = FindEntity(inst, SEE_ITEM_DIST, function(item) return item.prefab == 'dsalighter' end)
		if target then
			return BufferedAction(inst, target, ACTIONS.PICKUP)
		end
	end
	
	if inst.prefab == 'dsawendy' and inst.components.inventory:Has('dsaabigail_flower',0) then
		local target = FindEntity(inst, SEE_ITEM_DIST, function(item) return item.prefab == 'dsaabigail_flower' and item.components.inspectable and item.components.inspectable.getstatus(item) ~= "HAUNTED_GROUND" end)
		if target then
			return BufferedAction(inst, target, ACTIONS.PICKUP)
		end
	end
	
    local items = {}
	for k = 1,inst.components.inventory.maxslots do
        local v = inst.components.inventory.itemslots[k]
        if v and v.components.stackable then
            table.insert(items, v.prefab)
        end
    end
	
	if items then
		local target = FindEntity(inst, SEE_ITEM_DIST, function(item) return HasValue(items, item.prefab) and item.growtime == nil and item.components.stackable and not item.components.stackable:IsStack() end)
		if target then
			return BufferedAction(inst, target, ACTIONS.PICKUP)
		end		
	end
end

local function DropAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end	
	local stack = inst.components.inventory:FindItem(function(item) return item.components.stackable and item.components.stackable:IsFull() end)
	if stack then
		inst.components.inventory:DropItem(stack,true)
	end
end

local function StartDiggingCondition(inst)
	local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
	return ((item and item.components.tool and item.components.tool:CanDoAction(ACTIONS.DIG)) or (inst.components.beaverness and inst.components.beaverness:IsBeaver())) and inst.components.followercommands and (inst.components.followercommands:IsCurrentlyStaying() == true or (inst.components.followercommands:IsCurrentlyStaying() == false and inst.components.follower.leader ~= nil and inst.components.follower.leader:GetDistanceSqToInst(inst) <= MAX_WORK_DIST*MAX_WORK_DIST))
end

local function DigAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end
	local items = {}
	table.insert(items, "mound")
	if inst.components.beaverness and inst.components.beaverness:IsBeaver() then
		table.insert(items, "evergreen")
		table.insert(items, "evergreen_sparse")
		table.insert(items, "deciduoustree")
		table.insert(items, "marsh_tree")
		table.insert(items, "livingtree")
	else
		for k = 1,inst.components.inventory.maxslots do
			local v = inst.components.inventory.itemslots[k]
			if v then
				if v.prefab == "log" then
					table.insert(items, "evergreen")
					table.insert(items, "evergreen_sparse")
					table.insert(items, "deciduoustree")
					table.insert(items, "marsh_tree")
					table.insert(items, "livingtree")
				elseif v.prefab == "dug_grass" then
					table.insert(items, "grass")
				elseif v.prefab == "dug_sapling" then
					table.insert(items, "sapling")
				elseif v.prefab == "dug_berrybush" then
					table.insert(items, "berrybush")
				elseif v.prefab == "dug_berrybush2" then
					table.insert(items, "berrybush2")
				elseif v.prefab == "dug_marsh_bush" then
					table.insert(items, "marsh_bush")
				else
					table.insert(items, v.prefab)
				end
			end
		end
	end
	local target = FindEntity(inst, SEE_WORK_DIST, function(item) return HasValue(items, item.prefab) and item.components.workable and item.components.workable.action == ACTIONS.DIG end)
	local invObject = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
	if target then
		return BufferedAction(inst, target, ACTIONS.DIG, invObject)
	end
end

local function StartNettingCondition(inst)
	local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
	return (item and item.components.tool and item.components.tool:CanDoAction(ACTIONS.NET)) and inst.components.followercommands and (inst.components.followercommands:IsCurrentlyStaying() == true or (inst.components.followercommands:IsCurrentlyStaying() == false and inst.components.follower.leader ~= nil and inst.components.follower.leader:GetDistanceSqToInst(inst) <= MAX_WORK_DIST*MAX_WORK_DIST))
end

local function NetAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end

	local target = FindEntity(inst, SEE_WORK_DIST, function(item) return item.components.workable and item.components.workable.action == ACTIONS.NET end)
	local invObject = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
	if target then
		return BufferedAction(inst, target, ACTIONS.NET, invObject)
	end
end

local function StartFishingCondition(inst)
	local item = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	
	return (item and item.components.fishingrod) and inst.components.followercommands and (inst.components.followercommands:IsCurrentlyStaying() == true or (inst.components.followercommands:IsCurrentlyStaying() == false and inst.components.follower.leader ~= nil and inst.components.follower.leader:GetDistanceSqToInst(inst) <= MAX_FISH_DIST*MAX_FISH_DIST))
end

local function FishAction(inst)
	if inst.sg:HasStateTag("busy") then
		return
	end
	
	local invObject = inst.components.inventory:GetEquippedItem(EQUIPSLOTS.HANDS)
	if not invObject or not invObject.components.fishingrod then
		return
	end
	
	local target = FindEntity(inst, SEE_WORK_DIST, function(item) return item.components.fishable and item.components.fishable:GetFishPercent() > .90 end)
	if not target then
		target = FindEntity(inst, SEE_WORK_DIST, function(item) return item.components.fishable and item.components.fishable:GetFishPercent() > .80 end)
	end
	if not target then
		target = FindEntity(inst, SEE_WORK_DIST, function(item) return item.components.fishable and item.components.fishable:GetFishPercent() > .70 end)
	end
	if not target then
		target = FindEntity(inst, SEE_WORK_DIST, function(item) return item.components.fishable and item.components.fishable:GetFishPercent() > .60 end)
	end
	if not target then
		target = FindEntity(inst, SEE_WORK_DIST, function(item) return item.components.fishable and item.components.fishable:GetFishPercent() > .50 end)
	end
	if not target then
		target = FindEntity(inst, SEE_WORK_DIST, function(item) return item.components.fishable end)
	end

	if target then
		if invObject.components.fishingrod:IsFishing() then
			if inst.components.followercommands:IsCurrentlyStaying() == false and inst.components.follower.leader:GetDistanceSqToInst(inst) > MAX_FISH_DIST*MAX_FISH_DIST*.90 then
				return invObject.components.fishingrod:StopFishing()
			elseif invObject.components.fishingrod:FishIsBiting() then
				return BufferedAction(inst, target, ACTIONS.REEL, invObject)
			elseif invObject.components.fishingrod:HasHookedFish() then
				return BufferedAction(inst, target, ACTIONS.REEL, invObject)
			end
		elseif inst.components.followercommands:IsCurrentlyStaying() == true or (inst.components.followercommands:IsCurrentlyStaying() == false and inst.components.follower.leader:GetDistanceSqToInst(inst) <= MAX_FISH_DIST*MAX_FISH_DIST*.75) then
			return BufferedAction(inst, target, ACTIONS.FISH, invObject)
		end
	end
end

function Follower:OnStart()
    local beaver = WhileNode( function() return self.inst.components.beaverness and self.inst.components.beaverness:IsBeaver() end, "IsBeaver",
        PriorityNode{
            WhileNode(function() return self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown() end, "AttackMomentarily",
                ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),
			
			IfNode(function() return self.inst.components.beaverness:GetPercent() < .4 end, "IsStarving",
				DoAction(self.inst, FindFoodAction)),
				
			WhileNode(function() return self.inst.components.follower.leader ~= nil and
				self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) <= MAX_WORK_DIST*MAX_WORK_DIST end, "Dig",		
					DoAction(self.inst, DigAction)),
						
			IfNode(function() return StartChoppingCondition(self.inst) end, "Chop", 
				WhileNode(function() return KeepChoppingAction(self.inst) end, "KeepChopping",
					LoopNode{ 
						DoAction(self.inst, FindTreeToChopAction)})),
							
			IfNode(function() return StartMiningCondition(self.inst) end, "Mine", 
				WhileNode(function() return KeepMiningAction(self.inst) end, "KeepMining",
					LoopNode{ 
						DoAction(self.inst, FindRockToMineAction )})),				
			
			IfNode(function() return self.inst.components.follower.leader ~= nil and (self.inst.components.followercommands and self.inst.components.followercommands:IsCurrentlyStaying() == false) end, "FollowLeader",			
				DSAFollow(self.inst, GetLeader, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST)),
				
			DSAWander(self.inst, function() return Point(self.inst.Transform:GetWorldPosition()) end, MIN_WANDER_DIST, WANDER_TIMES),
			
			FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)	
        },.5)
		
    local root = 
		PriorityNode(
		{
			beaver,
			WhileNode(function() return self.inst.components.health.takingfiredamage end, "OnFire",
				Panic(self.inst)),
				
			WhileNode(function() return not self.inst.LightWatcher:IsInLight() end, "IsDark",
                DSAFindLight(self.inst)),
				
			WhileNode(function() return self.inst.components.combat.target and self.inst.components.combat.target:GetDistanceSqToInst(self.inst) <= STOP_RUN_AWAY_DIST*STOP_RUN_AWAY_DIST and self.inst.components.health:GetPercent() < .25 end, "LowHealth",
				RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),
		
            WhileNode(function() return (self.inst.components.combat.target == nil or not self.inst.components.combat:InCooldown()) and (self.inst.components.followercommands:IsCurrentlyStaying() == true or (self.inst.components.followercommands:IsCurrentlyStaying() == false and self.inst.components.follower.leader ~= nil and self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) <= MAX_CHASE_DIST*MAX_CHASE_DIST)) end, "AttackMomentarily",
                ChaseAndAttack(self.inst, MAX_CHASE_TIME, MAX_CHASE_DIST)),
			
			WhileNode(function() return self.inst.components.combat.target and self.inst.components.combat:InCooldown() end, "Dodge",
                RunAway(self.inst, function() return self.inst.components.combat.target end, RUN_AWAY_DIST, STOP_RUN_AWAY_DIST)),
			
			IfNode(function() return self.inst.components.temperature:IsFreezing() end, "IsFreezing",
				WhileNode(function() return self.inst.components.temperature:GetCurrent() < 20 end, "StayWarm",
					FindHeat(self.inst))),
					
			IfNode(function() return self.inst.components.temperature:IsOverheating() end, "IsOverheating",
				WhileNode(function() return self.inst.components.temperature:GetCurrent() > 50 end, "StayCool",
					FindCold(self.inst))),
					
			IfNode(function() return StartEatingCondition(self.inst) end, "IsStarving",
				DoAction(self.inst, FindFoodAction)),
	
			DoAction(self.inst, RepairAction),
			DoAction(self.inst, FarmAction),
			DoAction(self.inst, MurderAction),
			DoAction(self.inst, TrapAction),
			DoAction(self.inst, DryAction),
			DoAction(self.inst, DropAction),
	
			IfNode(function() return StartPickingCondition(self.inst) end, "PickUp",
				DoAction(self.inst, PickUpItemAction)),
			
			IfNode(function() return StartPickingCondition(self.inst) end, "Pick",		
				DoAction(self.inst, PickItemAction)),
			
			IfNode(function() return StartNettingCondition(self.inst) end, "Net",		
				DoAction(self.inst, NetAction)),
			
			IfNode(function() return StartDiggingCondition(self.inst) end, "Dig",		
				DoAction(self.inst, DigAction)),
				
			IfNode(function() return StartFishingCondition(self.inst) end, "Fish",		
				DoAction(self.inst, FishAction)),
					
			IfNode(function() return StartChoppingCondition(self.inst) end, "Chop", 
				WhileNode(function() return KeepChoppingAction(self.inst) end, "KeepChopping",
					LoopNode{ 
						DoAction(self.inst, FindTreeToChopAction)})),
							
			IfNode(function() return StartMiningCondition(self.inst) end, "Mine", 
				WhileNode(function() return KeepMiningAction(self.inst) end, "KeepMining",
					LoopNode{ 
						DoAction(self.inst, FindRockToMineAction )})),				
			
			IfNode(function() return self.inst.components.follower.leader ~= nil and (self.inst.components.followercommands and self.inst.components.followercommands:IsCurrentlyStaying() == false) end, "FollowLeader",			
				DSAFollow(self.inst, GetLeader, TARGET_FOLLOW_DIST, MAX_FOLLOW_DIST)),
			
			IfNode(function() return (self.inst.components.moisture:GetMoisture() > 0 and GetSeasonManager():IsRaining()) or self.inst.components.temperature:GetCurrent() > 65 end, "IsWetAndRaining",
				FindShelter(self.inst)),
			
			DSAWander(self.inst, function() return Point(self.inst.Transform:GetWorldPosition()) end, MIN_WANDER_DIST, WANDER_TIMES),
			
			FaceEntity(self.inst, GetFaceTargetFn, KeepFaceTargetFn)
			
		}, .1)
    
    self.bt = BT(self.inst, root)
end

function Follower:OnInitializationComplete()
end

return Follower