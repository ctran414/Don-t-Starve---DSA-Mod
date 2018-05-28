local FollowerCommands = Class(function(self, inst)
    self.inst = inst
	self.stay = false
	self.locations = {}

    local dt = 1
    self.inst:DoPeriodicTask(dt, function() self:OnUpdate(dt) end)
end)

function FollowerCommands:CollectSceneActions(doer, actions, rightclick)
	if rightclick then
		if TheInput:IsKeyDown(KEY_ALT) then
			table.insert(actions, ACTIONS.DROPCOMMAND)
		elseif TheInput:IsKeyDown(KEY_SHIFT) then
			table.insert(actions, ACTIONS.SWITCHCOMMAND)
		elseif self.inst.components.follower and self.inst.components.follower.leader == GetPlayer() then
			if not self.inst.components.followercommands:IsCurrentlyStaying() then
				table.insert(actions, ACTIONS.STAYCOMMAND)
			else
				table.insert(actions, ACTIONS.FOLLOWCOMMAND)
			end
		end
	end
end

function FollowerCommands:IsCurrentlyStaying()
	return self.stay
end

function FollowerCommands:SetStaying(stay)
	self.stay = stay
end


function FollowerCommands:RememberSitPos(name, pos)
    self.locations[name] = pos
end

-- onsave and onload may seem cumbersome but it requires to iterate because onload doesn't accept tables as single vars
function FollowerCommands:OnSave()
	if self.stay == true then
		local data = 
			{ 
				stay = self.stay,
				varx = self.locations.currentstaylocation["x"], 
				vary = self.locations.currentstaylocation["y"], 
				varz = self.locations.currentstaylocation["z"]
			}
		return data
	end
end   
   
function FollowerCommands:OnLoad(data)

	if data then 
		self.stay = data.stay
		self.locations.currentstaylocation = { }
		self.locations.currentstaylocation["x"] = data.varx
		self.locations.currentstaylocation["y"] = data.vary
		self.locations.currentstaylocation["z"] = data.varz
	end
end
   
function FollowerCommands:OnUpdate(dt)
	
	if self.inst.components.follower.leader ~= nil and self.inst.components.follower.leader:GetDistanceSqToInst(self.inst) > 1200 then
		self.inst.components.follower:StopFollowing()
	end
	if self.inst.components.follower.leader == nil and self.inst:GetDistanceSqToInst(GetPlayer()) < 1000 then
		self.inst.components.follower.maxfollowtime = 99999999
		self.inst.components.follower:SetLeader(GetPlayer())
		--player.components.leader:AddFollower(inst)
		self.inst.components.follower:AddLoyaltyTime(9999999)
	end
end

return FollowerCommands


