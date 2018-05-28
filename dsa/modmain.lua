PrefabFiles = {
	"followers",
	"followerskull", --skulls need RoG
	"dsaskeleton",
	"dsalucy",
	"dsalighter",
	"dsabooks",
	"dsaabigail",
	"dsaabigail_flower",
	"dsaballoons_empty",
}

local STRINGS = GLOBAL.STRINGS
local TUNING = GLOBAL.TUNING
local ACTIONS = GLOBAL.ACTIONS
local require = GLOBAL.require

--ADD SPEECH FOR CHARACTERS
STRINGS.CHARACTERS.DSAWILSON = require "speech_wilson"
STRINGS.CHARACTERS.DSAWILLOW = require "speech_willow"
STRINGS.CHARACTERS.DSAWOLFGANG = require "speech_wolfgang"
STRINGS.CHARACTERS.DSAWENDY = require "speech_wendy"
STRINGS.CHARACTERS.DSAWX78 = require "speech_wx78"
STRINGS.CHARACTERS.DSAWICKERBOTTOM = require "speech_wickerbottom"
STRINGS.CHARACTERS.DSAWOODIE = require "speech_woodie"
STRINGS.CHARACTERS.DSAWAXWELL = require "speech_maxwell"
STRINGS.CHARACTERS.DSAWEBBER = require "speech_webber"
STRINGS.CHARACTERS.DSAWATHGRITHR = require "speech_wathgrithr"
STRINGS.CHARACTERS.DSAWALANI = require "speech_walani"
STRINGS.CHARACTERS.DSAWARLY = require "speech_warly"
STRINGS.CHARACTERS.DSAWILBUR = require "speech_wilbur"
STRINGS.CHARACTERS.DSAWOODLEGS = require "speech_woodlegs"

--FOLLOWERCOMMANDS
STRINGS.ACTIONS.STAYCOMMAND = "Order to Stay"
STRINGS.ACTIONS.FOLLOWCOMMAND = "Order to Follow"
STRINGS.ACTIONS.DROPCOMMAND = "Order to Drop items"
STRINGS.ACTIONS.SWITCHCOMMAND = "Order to Switch weapons"

ACTIONS.STAYCOMMAND = GLOBAL.Action(2, true, true)
ACTIONS.STAYCOMMAND.fn = function(act)
	local targ = act.target
	if targ and targ.components.followercommands then
		act.doer.components.locomotor:Stop()
		targ.components.followercommands:SetStaying(true)
		targ.components.followercommands:RememberSitPos("currentstaylocation", GLOBAL.Point(targ.Transform:GetWorldPosition()))
		return true
	end
end
ACTIONS.STAYCOMMAND.str = STRINGS.ACTIONS.STAYCOMMAND
ACTIONS.STAYCOMMAND.id = "STAYCOMMAND"

ACTIONS.FOLLOWCOMMAND = GLOBAL.Action(2, true, true)
ACTIONS.FOLLOWCOMMAND.fn = function(act)
	local targ = act.target
	if targ and targ.components.followercommands then
		act.doer.components.locomotor:Stop()
		targ.components.followercommands:SetStaying(false)
		return true
	end
end
ACTIONS.FOLLOWCOMMAND.str = STRINGS.ACTIONS.FOLLOWCOMMAND
ACTIONS.FOLLOWCOMMAND.id = "FOLLOWCOMMAND"

ACTIONS.DROPCOMMAND = GLOBAL.Action(2, true, true)
ACTIONS.DROPCOMMAND.fn = function(act)
	local targ = act.target
	if targ then
		act.doer.components.locomotor:Stop()
		local items = {}
		for k = 1, targ.components.inventory.maxslots do
			local v = targ.components.inventory.itemslots[k]
			if v and not targ.components.inventory:IsItemEquipped(v) then
				targ.components.inventory:DropItem(v, true, true)
			end
		end		
		--targ.components.inventory:DropEverything()
		return true
	end
end
ACTIONS.DROPCOMMAND.str = STRINGS.ACTIONS.DROPCOMMAND
ACTIONS.DROPCOMMAND.id = "DROPCOMMAND"

local pos = 1
ACTIONS.SWITCHCOMMAND = GLOBAL.Action(2, true, true)
ACTIONS.SWITCHCOMMAND.fn = function(act)
	local targ = act.target
	if targ then
		act.doer.components.locomotor:Stop()
		local items = {}
		local hands = targ.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HANDS)
		local head = targ.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.HEAD)
		local body = targ.components.inventory:GetEquippedItem(GLOBAL.EQUIPSLOTS.BODY)
		for k = pos, targ.components.inventory.maxslots + 3 do
			if k == targ.components.inventory.maxslots + 1 and hands ~= nil then
				targ.components.inventory:Unequip(GLOBAL.EQUIPSLOTS.HANDS)
				hands.components.equippable:ToPocket()
				targ.components.inventory:GiveItem(hands)
				pos = k + 1
				return true
			elseif k == targ.components.inventory.maxslots + 2 and head ~= nil then
				targ.components.inventory:Unequip(GLOBAL.EQUIPSLOTS.HEAD)
				head.components.equippable:ToPocket()
				targ.components.inventory:GiveItem(head)
				pos = k + 1
				return true
			elseif k == targ.components.inventory.maxslots + 3 and body ~= nil then
				targ.components.inventory:Unequip(GLOBAL.EQUIPSLOTS.BODY)
				body.components.equippable:ToPocket()
				targ.components.inventory:GiveItem(body)
				pos = 1
				return true
			end
			
			local v = targ.components.inventory.itemslots[k]
			if v and v.components.equippable then
				if k == targ.components.inventory.maxslots then
					pos = 1
				else
					pos = k + 1
				end
				targ.components.inventory:Equip(v)
				return true
			end
		end		
		for k = 1, pos do
			local v = targ.components.inventory.itemslots[k]
			if v and v.components.equippable then
				if k == targ.components.inventory.maxslots then
					pos = 1
				else
					pos = k + 1
				end
				targ.components.inventory:Equip(v)
				return true
			end
		end
		return true
	end
end
ACTIONS.SWITCHCOMMAND.str = STRINGS.ACTIONS.SWITCHCOMMAND
ACTIONS.SWITCHCOMMAND.id = "SWITCHCOMMAND"

ACTIONS.GIVE.priority = 4

--ADD CHARACTER STRINGS
--WILSON 	
STRINGS.NAMES.DSAWILSON = "Wilson"
STRINGS.NAMES.DSAWILSONSKULL = "Wilson's skull."

STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWILSON = "Stars and atoms! Are you my doppelganger?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWILSON = "Hi Wilson!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWILSON = "Is tiny egghead man, Wilson! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWILSON = "How do you do, Wilson?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWILSON = "DETECTING... WILSON!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWILSON = "Greetings, dear Wilson! How are your theorems coming?"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWILSON = "Wilson! Hey buddy!"

STRINGS.NAMES.DSAWILSONSKELETON = "Wilson's skeleton."
STRINGS.NAMES.DSAWILSONSKULL = "Wilson's skull."
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWILSONSKULL = "I should bury him."

--WILLOW
STRINGS.NAMES.DSAWILLOW = "Willow"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWILLOW = "Good day to you, Willow!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWILLOW = "Hey! That's my face! Give it back!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWILLOW = "Is tiny torchlady, Willow! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWILLOW = "How do you do, Willow?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWILLOW = "DETECTING... WILLOW!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWILLOW = "Ah, greetings dear Willow!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWILLOW = "Look who it is! Willow!"

STRINGS.NAMES.DSALIGHTER = "Willow's Lighter"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LIGHTER = "It's her lucky lighter."

STRINGS.NAMES.DSAWILLOWSKELETON = "Willow's skeleton."
STRINGS.NAMES.DSAWILLOWSKULL = "Willow's skull."
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWILLOWSKULL = "I should bury her."

--WOLFGANG	
STRINGS.NAMES.DSAWOLFGANG = "Wolfgang"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWOLFGANG = "It's good to see you, Wolfgang!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWOLFGANG = "Hi Wolfgang!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWOLFGANG = "Hello friend! We must arm wrestle!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWOLFGANG = "Hi Wolfgang. Why are you shaking?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWOLFGANG = "DETECTING... WOLFGANG!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWOLFGANG = "Ah, greetings dear Wolfgang!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWOLFGANG = "That's my buddy, Wolfgang! Hey!"

STRINGS.NAMES.DSAWOLFGANGSKELETON = "Wolfgang's skeleton."
STRINGS.NAMES.DSAWOLFGANGSKULL = "Wolfgang's skull."
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWOLFGANGSKULL = "I should bury him."

--WENDY	
STRINGS.NAMES.DSAWENDY = "Wendy"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWENDY = "Greetings, Wendy!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWENDY = "Hi Wendy!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWENDY = "Is very tiny, scary Wendy! H-hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWENDY = "She looks sad..."
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWENDY = "DETECTING... WENDY!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWENDY = "Ah, greetings dear Wendy!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWENDY = "Wendy! Hi little buddy!"

STRINGS.NAMES.DSAABIGAIL_FLOWER = "Abigail's Flower"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ABIGAIL_FLOWER = 
		{ 
			GENERIC ="It's hauntingly beautiful.",
			LONG = "It hurts my soul to look at that thing.",
			MEDIUM = "It's giving me the creeps.",
			SOON = "Something is up with that flower!",
			HAUNTED_POCKET = "I don't think I should hang on to this.",
			HAUNTED_GROUND = "I'd die to find out what it does.",
		}
STRINGS.NAMES.DSAABIGAIL = "Abigail"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ABIGAIL = "Awww, she has a cute little bow."
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.ABIGAIL = "What do you desire, apparition?"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.ABIGAIL = "Why won't these mortals just stay dead?"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.ABIGAIL = "That's no party poltergeist!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.ABIGAIL = "Fascinating. Can you speak, specter?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.ABIGAIL = "So, what happened to you?"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.ABIGAIL = "Are you friendly ghost?"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.ABIGAIL = "That ain't right."
STRINGS.CHARACTERS.WX78.DESCRIBE.ABIGAIL = "UNDEAD ALERT"

STRINGS.NAMES.DSAWENDYSKELETON = "Wendy's skeleton."
STRINGS.NAMES.DSAWENDYSKULL = "Wendy's skull."
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWENDYSKULL = "I should bury her."

--WX78 	
STRINGS.NAMES.DSAWX78 = "WX-78"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWX78 = "Good day to you, WX-78!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWX78 = "Hi WX-78!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWX78 = "Is tiny robot, WX-78! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWX78 = "How do you do, WX-78?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWX78 = "GREETINGS. YOU LOOK MORE INTELLIGENT THAN THE OTHERS"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWX78 = "Ah, the automaton. Greetings, dear WX-78!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWX78 = "It's my metal buddy, WX-78!"

STRINGS.NAMES.DSAWX78SKELETON = "WX-78's skeleton."
STRINGS.NAMES.DSAWX78SKULL = "WX-78's skull."
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWX78SKULL = "I should bury him."

--WICKERBOTTOM 
STRINGS.NAMES.DSAWICKERBOTTOM = "Wickerbottom"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWICKERBOTTOM = "Good day, Wickerbottom!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWICKERBOTTOM = "Hi Wickerbottom!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWICKERBOTTOM = "Is strong brainlady! Hello, tiny Wickerbottom!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWICKERBOTTOM = "How do you do, Ms. Wickerbottom?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWICKERBOTTOM = "DETECTING... WICKERBOTTOM!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWICKERBOTTOM = "Ah, greetings! Fancy seeing you here."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWICKERBOTTOM = "Wickerbottom. Ma'am."

STRINGS.NAMES.DSAWICKERBOTTOMSKELETON = "Wickerbottom's skeleton."
STRINGS.NAMES.DSAWICKERBOTTOMSKULL = "Wickerbottom's skull."
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWICKERBOTTOMSKULL = "I should bury her."

STRINGS.NAMES.DSABOOK_BIRDS = "Birds of the World"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_BIRDS = "No point studying when I can just wing it."

STRINGS.NAMES.DSABOOK_BRIMSTONE = "The End is Nigh!"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_BRIMSTONE = "The beginning was dull, but got better near the end."

STRINGS.NAMES.DSABOOK_SLEEP = "Sleepytime Stories"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_SLEEP = "Strange, it's just 500 pages of telegraph codes."

STRINGS.NAMES.DSABOOK_GARDENING = "Applied Horticulture"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_GARDENING = "I see no farm in reading that."

STRINGS.NAMES.DSABOOK_TENTACLES = "On Tentacles"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_TENTACLES = "Someone'll get suckered into reading this."

--WOODIE
STRINGS.NAMES.DSAWOODIE = "Woodie"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWOODIE = "Greetings, Woodie!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWOODIE = "Hi Woodie!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWOODIE = "Is beard! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWOODIE = "How do you do, Woodie?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWOODIE = "DETECTING... WOODIE!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWOODIE = "Ah, greetings dear Woodie!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWOODIE = "Fancy seeing another Canadian here."

STRINGS.NAMES.DSALUCY = "Lucy the Axe"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.LUCY = "That's a prettier axe than I'm used to."

STRINGS.NAMES.DSAWOODIESKELETON = "Woodie's skeleton."
STRINGS.NAMES.DSAWOODIESKULL = "Woodie's skull."
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWOODIESKULL = "I should bury him."

--WES
STRINGS.NAMES.DSAWES = "Wes"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWES = "Greetings, Wes!"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.DSAWES = "Hi Wes!"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.DSAWES = "Is tiny oddman, Wes! Hello!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.DSAWES = "How do you do, Wes?"
STRINGS.CHARACTERS.WX78.DESCRIBE.DSAWES = "DETECTING... WES!"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.DSAWES = "Ah, the mime lad. Greetings, dear Wes!"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.DSAWES = "Wes! How ya doin', buddy?"

STRINGS.NAMES.DSABALLOONS_EMPTY = "Pile o' Balloons"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSABALLOONS_EMPTY = "It looks like clown currency."
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BALLOON = "How are they floating?"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.BALLOONS_EMPTY = "I could fill them with flammable gas."
STRINGS.CHARACTERS.WILLOW.DESCRIBE.BALLOON = "That's just asking to be popped."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.BALLOONS_EMPTY = "Wolfgang will make balloon muscles."
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.BALLOON = "Is full of clown breath!"
STRINGS.CHARACTERS.WENDY.DESCRIBE.BALLOONS_EMPTY = "These look as deflated as I feel..."
STRINGS.CHARACTERS.WENDY.DESCRIBE.BALLOON = "A colorful reminder that my childhood is no more."
STRINGS.CHARACTERS.WX78.DESCRIBE.BALLOONS_EMPTY = "USELESS RUBBER SACKS"
STRINGS.CHARACTERS.WX78.DESCRIBE.BALLOON = "WX-78 CANNOT BE FOOLED. THESE ANIMALS ARE NOT REAL."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.BALLOONS_EMPTY = "These seem frivolous."
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.BALLOON = "Could serve as a suitable diversion."
STRINGS.CHARACTERS.WOODIE.DESCRIBE.BALLOONS_EMPTY = "Are those balloons?"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.BALLOON = "It's squeaky. Just like a real woodland creature."

STRINGS.NAMES.DSAWESSKELETON = "Wes's skeleton."
STRINGS.NAMES.DSAWESSKULL = "Wes's skull."
--STRINGS.CHARACTERS.GENERIC.DESCRIBE.DSAWESSKULL = "I should bury him."

--COMPONENT POSTINITS
function addLightningStrikeToFollowers(inst)
	inst.DoLightningStrike = function(self, pos, ignoreRods)
		local rod = nil
		local player = nil
		if not ignoreRods then
			local rods = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 40, {"lightningrod"}, {"dead"})
			for k,v in pairs(rods) do -- Find nearby lightning rods, prioritize battery-charging rods and closer rods
				if not rod or (v.lightningpriority > rod.lightningpriority or GLOBAL.distsq(pos, Vector3(v.Transform:GetWorldPosition())) < GLOBAL.distsq(pos, GLOBAL.Vector3(rod.Transform:GetWorldPosition()))) then
					rod = v
				end
			end			
		end
		
		local followers = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 10, {"summonedbyplayer"})
		for k,v in pairs(followers) do 
			if not follower or GLOBAL.distsq(pos, GLOBAL.Vector3(v.Transform:GetWorldPosition())) < GLOBAL.distsq(pos, GLOBAL.Vector3(follower.Transform:GetWorldPosition())) then
				follower = v
			end
		end
		local rand = math.random()
		if rod then
			pos = GLOBAL.Vector3(rod.Transform:GetWorldPosition() )
		elseif follower and rand <= follower.components.playerlightningtarget:GetHitChance() then
			pos = GLOBAL.Vector3(follower.Transform:GetWorldPosition()) 
		elseif GLOBAL.GetPlayer().components.playerlightningtarget 
		  and rand <= GLOBAL.GetPlayer().components.playerlightningtarget:GetHitChance() then
			player = GLOBAL.GetPlayer()
			pos = GLOBAL.Vector3(GLOBAL.GetPlayer().Transform:GetWorldPosition() )
		end

		local lightning = GLOBAL.SpawnPrefab("lightning")
		lightning.Transform:SetPosition(pos:Get())

		if rod then
			rod:PushEvent("lightningstrike", {rod=rod})
		else
			if player then
				player.components.playerlightningtarget:DoStrike()
			elseif follower and rand <= follower.components.playerlightningtarget:GetHitChance() then
				follower.components.playerlightningtarget:DoStrike()
			end
			local ents = GLOBAL.TheSim:FindEntities(pos.x, pos.y, pos.z, 3)
			for k,v in pairs(ents) do 
				if not v:IsInLimbo() then
					if v.components.burnable and not v.components.fueled and not v.components.burnable.lightningimmune then
						v.components.burnable:Ignite()
					end
				end
			end
		end
	end
end
AddComponentPostInit("seasonmanager", addLightningStrikeToFollowers)

function adjustGuarantee(inst)
	inst.GuaranteeItems = function(self, items)

		self.inst:DoTaskInTime(0,function()
			for k,v in pairs(items) do
				local item = v
				
				local equipped = false
				for k,v in pairs (self.equipslots) do
					if v and v.prefab == item then
						equipped = true
					end
				end

				if self == GLOBAL.GetPlayer() and (equipped or self:Has(item, 1)) then
					for k,v in pairs(Ents) do
						if v.prefab == item and v.components.inventoryitem:GetGrandOwner() ~= GetPlayer() then
							v:Remove()
						end
					end
				else
					for k,v in pairs(GLOBAL.Ents) do
						if v.prefab == item then
							item = nil
							break
						end
					end
					if item then
						self:GiveItem(GLOBAL.SpawnPrefab(item))
					end
				end
			end
		end)
	end
end
AddComponentPostInit("inventory", adjustGuarantee)

function removeDistortionFromFollower(inst)
	inst.OnUpdate = function(self, dt)
		if self.inst:HasTag("player") then	
			local t = 1 - self:GetPercent()
			local b = 0
			local c = .2
			local d =1
			t = t / d
			local speed = -c * t * (t - 2) + b
			self.fxtime = self.fxtime + dt*speed
			
			GLOBAL.PostProcessor:SetEffectTime(self.fxtime)
		
			t = self:GetPercent()
			c = 1
			t = t / d
			local distortion_value = -c * t * (t - 2) + b
			GLOBAL.PostProcessor:SetDistortionFactor(distortion_value)
			GLOBAL.PostProcessor:SetDistortionRadii( 0.5, 0.685 )
		end

		if self.inst.components.health.invincible == true or self.inst.is_teleporting == true then
			return
		end
		
		self:Recalc(dt)	
	end
end
AddComponentPostInit("sanity", removeDistortionFromFollower)

function addFollowerDamageResist(inst)
	inst.CalcDamage = function(self, target, weapon, multiplier)
		if target:HasTag("alwaysblock") then
			return 0
		end
		local multiplier = multiplier or self.damagemultiplier or 1
		local bonus = self.damagebonus or 0
		if weapon then
			local weapondamage = 0
			if weapon.components.weapon.variedmodefn then
				local d = weapon.components.weapon.variedmodefn(weapon)
				weapondamage = d.damage        
			else
				weapondamage = weapon.components.weapon.damage
			end
			if not weapondamage then weapondamage = 0 end
			return weapondamage*multiplier + bonus
		end
		
		if target and (target:HasTag("player") or target:HasTag("summonedbyplayer")) then
			return self.defaultdamage * self.playerdamagepercent * multiplier + bonus
		end
		
		return self.defaultdamage * multiplier + bonus
	end
end
AddComponentPostInit("combat", addFollowerDamageResist)

--PREFAB POSTINITS
function RemoveSelfBurn(inst)
	inst.components.weapon:SetAttackCallback(nil)
end
AddPrefabPostInit("torch", RemoveSelfBurn)

function AddSkulls(inst)
	inst:DoTaskInTime(0, function() 
		local skulls = {}
		local wilson_exists = false
		local willow_exists = false
		local wolfgang_exists = false
		local wendy_exists = false
		local wx78_exists = false
		local wickerbottom_exists = false
		local woodie_exists = false
		local wes_exists = false
		for k,v in pairs(GLOBAL.Ents) do
			if v.prefab == "wilson" or v.prefab == "dsawilson" or v.prefab == "dsawilsonskull" or v.prefab == "dsawilsonskeleton" then
				wilson_exists = true
			elseif v.prefab == "willow" or v.prefab == "dsawillow" or v.prefab == "dsawillowskull" or v.prefab == "dsawillowskeleton" then
				willow_exists = true
			elseif v.prefab == "wolfgang" or v.prefab == "dsawolfgang" or v.prefab == "dsawolfgangskull" or v.prefab == "dsawolfgangskeleton" then
				wolfgang_exists = true
			elseif v.prefab == "wendy" or v.prefab == "dsawendy" or v.prefab == "dsawendyskull" or v.prefab == "dsawendyskeleton" then
				wendy_exists = true
			elseif v.prefab == "wx78" or v.prefab == "dsawx78" or v.prefab == "dsawx78skull" or v.prefab == "dsawx78skeleton" then
				wx78_exists = true
			elseif v.prefab == "wickerbottom" or v.prefab == "dsawickerbottom" or v.prefab == "dsawickerbottomskull" or v.prefab == "dsawickerbottomskeleton" then
				wickerbottom_exists = true
			elseif v.prefab == "woodie" or v.prefab == "dsawoodie" or v.prefab == "dsawoodieskull" or v.prefab == "dsawoodieskeleton" then
				woodie_exists = true
			elseif v.prefab == "wes" or v.prefab == "dsawes" or v.prefab == "dsawesskull" or v.prefab == "dsawesskeleton" then
				wes_exists = true
			end
		end
		if not wilson_exists then
			table.insert(skulls,"dsawilsonskeleton")
		end
		if not willow_exists then
			table.insert(skulls,"dsawillowskeleton")
		end
		if not wolfgang_exists then
			table.insert(skulls,"dsawolfgangskeleton")
		end
		if not wendy_exists then
			table.insert(skulls,"dsawendyskeleton")
		end
		if not wx78_exists then
			table.insert(skulls,"dsawx78skeleton")
		end
		if not wickerbottom_exists then
			table.insert(skulls,"dsawickerbottomskeleton")
		end
		if not woodie_exists then
			table.insert(skulls,"dsawoodieskeleton")
		end
		if not wes_exists then
			table.insert(skulls,"dsawesskeleton")
		end
		
		for i,v in ipairs(skulls) do
			local skull = GLOBAL.SpawnPrefab(v)
			local offset = GLOBAL.Vector3(math.random(-5,5),0,math.random(-5,5))
			local spawnPoint = inst:GetPosition()+offset
			skull.Transform:SetPosition(spawnPoint:Get())
		end
		
	end)
end
AddPrefabPostInit("wilson", AddSkulls)
AddPrefabPostInit("willow", AddSkulls)
AddPrefabPostInit("wolfgang", AddSkulls)
AddPrefabPostInit("wendy", AddSkulls)
AddPrefabPostInit("wickerbottom", AddSkulls)
AddPrefabPostInit("wx78", AddSkulls)
AddPrefabPostInit("woodie", AddSkulls)
AddPrefabPostInit("wes", AddSkulls)

function AddTradable(inst)
	if not inst.components.tradable then
		inst:AddComponent("tradable")
	end
end
--Add Weapons
AddPrefabPostInit("torch", AddTradable)
AddPrefabPostInit("lantern", AddTradable)
AddPrefabPostInit("axe", AddTradable)
AddPrefabPostInit("goldenaxe", AddTradable)
AddPrefabPostInit("pickaxe", AddTradable)
AddPrefabPostInit("goldenpickaxe", AddTradable)
AddPrefabPostInit("shovel", AddTradable)
AddPrefabPostInit("goldenshovel", AddTradable)
AddPrefabPostInit("hammer", AddTradable)
AddPrefabPostInit("pitchfork", AddTradable)
AddPrefabPostInit("multitool_axe_pickaxe", AddTradable)
AddPrefabPostInit("umbrella", AddTradable)
AddPrefabPostInit("grass_umbrella", AddTradable)
AddPrefabPostInit("fishingrod", AddTradable)
AddPrefabPostInit("bugnet", AddTradable)
AddPrefabPostInit("cane", AddTradable)
AddPrefabPostInit("spear", AddTradable)
AddPrefabPostInit("hambat", AddTradable)
AddPrefabPostInit("batbat", AddTradable)
AddPrefabPostInit("tentaclespike", AddTradable)
AddPrefabPostInit("nightsword", AddTradable)
AddPrefabPostInit("ruins_bat", AddTradable)
AddPrefabPostInit("nightstick", AddTradable)
AddPrefabPostInit("blowdart_sleep", AddTradable)
AddPrefabPostInit("blowdart_fire", AddTradable)
AddPrefabPostInit("blowdart_pipe", AddTradable)
AddPrefabPostInit("boomerang", AddTradable)
AddPrefabPostInit("icestaff", AddTradable)
AddPrefabPostInit("firestaff", AddTradable)
AddPrefabPostInit("telestaff", AddTradable)
AddPrefabPostInit("orangestaff", AddTradable)
AddPrefabPostInit("greenstaff", AddTradable)
AddPrefabPostInit("yellowstaff", AddTradable)
AddPrefabPostInit("staff_tornado", AddTradable)
AddPrefabPostInit("spear_wathgrithr", AddTradable)

--Add Armor
AddPrefabPostInit("armorgrass", AddTradable)
AddPrefabPostInit("armorwood", AddTradable)
AddPrefabPostInit("armormarble", AddTradable)
AddPrefabPostInit("armorruins", AddTradable)
AddPrefabPostInit("armor_sanity", AddTradable)
AddPrefabPostInit("armorslurper", AddTradable)
AddPrefabPostInit("armorsnurtleshell", AddTradable)
AddPrefabPostInit("sweatervest", AddTradable)
AddPrefabPostInit("trunkvest_summer", AddTradable)
AddPrefabPostInit("trunkvest_winter", AddTradable)
AddPrefabPostInit("reflectivevest", AddTradable)
AddPrefabPostInit("hawaiianshirt", AddTradable)
AddPrefabPostInit("raincoat", AddTradable)
AddPrefabPostInit("amulet", AddTradable)
AddPrefabPostInit("blueamulet", AddTradable)
AddPrefabPostInit("purpleamulet", AddTradable)
AddPrefabPostInit("orangeamulet", AddTradable)
AddPrefabPostInit("greenamulet", AddTradable)
AddPrefabPostInit("yellowamulet", AddTradable)
AddPrefabPostInit("beargervest", AddTradable)
AddPrefabPostInit("armordragonfly", AddTradable)

--Add Miscellaneous
AddPrefabPostInit("nightlight", AddTradable)
AddPrefabPostInit("bluegem", AddTradable)
AddPrefabPostInit("redgem", AddTradable)
AddPrefabPostInit("purplegem", AddTradable)
AddPrefabPostInit("orangegem", AddTradable)
AddPrefabPostInit("greengem", AddTradable)
AddPrefabPostInit("yellowgem", AddTradable)
AddPrefabPostInit("log", AddTradable)
AddPrefabPostInit("livinglog", AddTradable)
AddPrefabPostInit("marble", AddTradable)
AddPrefabPostInit("cutreeds", AddTradable)
AddPrefabPostInit("cutlichen", AddTradable)
AddPrefabPostInit("bedroll_straw", AddTradable)
AddPrefabPostInit("bedroll_furry", AddTradable)
AddPrefabPostInit("dug_grass", AddTradable)
AddPrefabPostInit("dug_sapling", AddTradable)
AddPrefabPostInit("dug_berrybush", AddTradable)
AddPrefabPostInit("dug_berrybush2", AddTradable)
AddPrefabPostInit("tentaclespots", AddTradable)
AddPrefabPostInit("poop", AddTradable)
AddPrefabPostInit("guano", AddTradable)
AddPrefabPostInit("nightmarefuel", AddTradable)
AddPrefabPostInit("slurper_pelt", AddTradable)
AddPrefabPostInit("gears", AddTradable)
AddPrefabPostInit("ash", AddTradable)
AddPrefabPostInit("stinger", AddTradable)
AddPrefabPostInit("spidergland", AddTradable)
AddPrefabPostInit("feather_crow", AddTradable)
AddPrefabPostInit("feather_robin", AddTradable)
AddPrefabPostInit("feather_robin_winter", AddTradable)
AddPrefabPostInit("beardhair", AddTradable)
AddPrefabPostInit("manrabbit_tail", AddTradable)
AddPrefabPostInit("charcoal", AddTradable)
AddPrefabPostInit("mosquitosack", AddTradable)
AddPrefabPostInit("slurtleslime", AddTradable)
AddPrefabPostInit("spidereggsack", AddTradable)
AddPrefabPostInit("heatrock", AddTradable)
AddPrefabPostInit("thulecite_pieces", AddTradable)
AddPrefabPostInit("walrus_tusk", AddTradable)
AddPrefabPostInit("coontail", AddTradable)
AddPrefabPostInit("goose_feather", AddTradable)
AddPrefabPostInit("dragon_scales", AddTradable)
AddPrefabPostInit("bearger_fur", AddTradable)
AddPrefabPostInit("lightninggoathorn", AddTradable)
AddPrefabPostInit("dsabook_sleep", AddTradable)
AddPrefabPostInit("dsabook_gardening", AddTradable)
AddPrefabPostInit("dsabook_brimstone", AddTradable)
AddPrefabPostInit("dsabook_birds", AddTradable)
AddPrefabPostInit("dsabook_tentacles", AddTradable)
AddPrefabPostInit("dsaabigail_flower", AddTradable)
AddPrefabPostInit("dsaballoons_empty", AddTradable)
AddPrefabPostInit("dsalucy", AddTradable)
AddPrefabPostInit("dsalighter", AddTradable)

local function HearPanFlute(inst, musician, instrument)
	if inst.components.sleeper and not inst:HasTag('summonedbyplayer') then
	    inst.components.sleeper:AddSleepiness(10, TUNING.PANFLUTE_SLEEPTIME)
	end
end

function BlockFollowersFromSleep(inst)
	inst.components.instrument:SetOnHeardFn(HearPanFlute)
end
AddPrefabPostInit("panflute", BlockFollowersFromSleep)

