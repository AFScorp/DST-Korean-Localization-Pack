local pp = require "pphandle"
local STRINGS = GLOBAL.STRINGS
LoadPOFile("ko.po", "ko")
---------------------------------------------------------
-- Added Overriding Function --
-- Changes word order.(nouns + Verb or adjective + nouns)
---------------------------------------------------------

-- In WorldgenScreen
-- Somehow it must be like this or the word order remains same.
-- Considering the potential compatibility, this was the best as possible.
local worldgenscreen = GLOBAL.require "screens/worldgenscreen"
local ChangeFlavourText_Old = worldgenscreen.ChangeFlavourText or function() end
	
function worldgenscreen:ChangeFlavourText()
	self.flavourtext:SetString(self.nouns[self.nounidx].." "..self.verbs[self.verbidx])
	ChangeFlavourText_Old(self)
	self.flavourtext:SetString(self.nouns[self.nounidx].." "..self.verbs[self.verbidx])
end

------------------------------------------------------------------------
-- codes that should work only on client
------------------------------------------------------------------------

-- In-Game Hovering Text
local hoverer = GLOBAL.require "widgets/hoverer"
local HoveringText = hoverer.OnUpdate or function() end
function hoverer:OnUpdate()
	HoveringText(self)
	local str = nil
	if not self.isFE then
		str = self.owner.HUD.controls:GetTooltip() or self.owner.components.playercontroller:GetHoverTextOverride()
	else
		str = self.owner:GetTooltip()
	end
	
	local lmb = nil
	if str == nil and not self.isFE and self.owner:IsActionsVisible() then
		lmb = self.owner.components.playercontroller:GetLeftMouseAction()
		if lmb ~= nil then
			local overriden
			str, overriden = lmb:GetActionString()
			
			if not overriden and lmb.target ~= nil and lmb.invobject == nil and lmb.target ~= lmb.doer then
				local name = lmb.target:GetDisplayName()
				if name ~= nil then
					local adjective = lmb.target:GetAdjective()
					name = (adjective ~= nil and (adjective.." "..name)) or name
					
					if lmb.target.replica.stackable ~= nil and lmb.target.replica.stackable:IsStack() then
						name = name .. " " .. tostring(lmb.target.replica.stackable:StackSize()).."개"
					end
					str = name .. " " .. str
				end
			end
		end
		if str then
			self.text:SetString(str)
			self.str = str
		end
	end
end

----------------------------------------------------------------------------------------
-- codes that work only on mastersim
----------------------------------------------------------------------------------------
-- Fix for ACTIONFAIL_GENERIC and DESCRIBE_GENERIC
-- code brought from Tykvesh's fix
local GetActionFailString = GLOBAL.GetActionFailString or function() end

function GLOBAL.GetActionFailString(inst, ...)
	local string = GetActionFailString(inst, ...)
	if string == STRINGS.CHARACTERS.GENERIC.ACTIONFAIL_GENERIC then
		local character = type(inst) == "table" and inst.prefab or inst
		if character ~= nil and character.upper ~= nil then
			character = character:upper()
		end
		
		return STRINGS.CHARACTERS[character]
			and STRINGS.CHARACTERS[character].ACTIONFAIL_GENERIC
			or string
	end
	return string
end

local GetDescOld = GLOBAL.GetDescription or function() end

function GLOBAL.GetDescription(inst, ...)
	local string = GetDescOld(inst, ...)
	if string == STRINGS.CHARACTERS.GENERIC.DESCRIBE_GENERIC then
		local character = type(inst) == "table" and inst.prefab or inst
		if character ~= nil and character.upper ~= nil then
			character = character:upper()
		end
		
		return STRINGS.CHARACTERS[character]
			and STRINGS.CHARACTERS[character].DESCRIBE_GENERIC
			or string
	end
	return string
end


--Replace pp. according to the name
--1. player skeleton
AddPrefabPostInit("skeleton_player", function(inst)
	local function reassignfn(inst)
		if inst.components.inspectable.getspecialdescription_old == nil then
			inst.components.inspectable.getspecialdescription_old = inst.components.inspectable.getspecialdescription
		end
		inst.components.inspectable.getspecialdescription = function(inst, ...)
			local str = inst.components.inspectable.getspecialdescription_old(inst, ...)
			return pp.replacePP(str, inst.playername or STRINGS.NAMES[string.upper(inst.char)])
		end
	end
	
	if inst.OldSetSkeletonDescription == nil then
		inst.OldSetSkeletonDescription = inst.SetSkeletonDescription
	end
	inst.SetSkeletonDescription = function(inst, ...)
		inst.OldSetSkeletonDescription(inst, ...)
		reassignfn(inst)
	end
				
	if inst.oldOnLoad == nil then
		inst.oldOnLoad = inst.OnLoad
	end
	inst.OnLoad = function(inst, ...)
		inst.oldOnLoad(inst, ...)
		reassignfn(inst)
	end
end)

--2. player inspection
AddPrefabPostInit("player_common", function(inst)
	if inst.components.inspectable ~= nil then
		if inst.components.inspectable.getspecialdescription_old == nil then
			inst.components.inspectable.getspecialdescription_old = inst.components.inspectable.getspecialdescription
		end

		function inst.components.inspectable.getspecialdescription(inst, ...)
			return pp.replacePP(inst.components.inspectable.getspecialdescription_old(inst, ...), inst:GetDisplayName())
		end
	end
end)

--3. carrat race winner
AddPrefabPostInit("yotc_carrat_race_finish", function(inst)
	if inst.components.inspectable ~= nil then
		if inst.components.inspectable.getspecialdescription_old == nil then
			inst.components.inspectable.getspecialdescription_old = inst.components.inspectable.getspecialdescription or function() end
		end
		function inst.components.inspectable.getspecialdescription(inst, ...)
			local str = inst.components.inspectable.getspecialdescription_old(inst, ...)
			local winner = inst._winner ~= nil and inst._winner.name
			return (winner ~= nil and pp.replacePP(str, winner)) or str
		end
	end
end)

--Localization for player ghost speech

local oldGetSpecialCharacterString = GLOBAL.GetSpecialCharacterString
GLOBAL.GetSpecialCharacterString = function(character)
	character = string.lower(character)
	local str = oldGetSpecialCharacterString(character)
	if character == "ghost" then
		str = str:gsub("ohhh", "우"):gsub("ohh", "오"):gsub("h", ""):gsub("o", "우"):gsub("O", "오")
	end
	return str
end

--Server list world day printing correction
AddClassPostConstruct("screens/redux/serverlistingscreen", function(self)
	local updatedata = self.UpdateServerData or function() end
	
	function self:UpdateServerData(selected_index_actual)
		updatedata(self, selected_index_actual)
		local gamedata = self:ProcessServerGameData()
		local day = gamedata ~= nil and gamedata.day or STRINGS.UI.SERVERLISTINGSCREEN.UNKNOWN
		self.day_description.text:SetString(day..STRINGS.UI.SERVERLISTINGSCREEN.DAYDESC)
	end
end)

-- In-Game UI Clock
AddClassPostConstruct("widgets/uiclock", function(self)
	local UpdateDayStr = self.UpdateDayString or function() end
	local basescale = 1
	
	function self:UpdateDayString()
		UpdateDayStr(self)
		
		if self._cycles ~= nil then
			self._text:SetString(tostring(GLOBAL.ThePlayer.Network:GetPlayerAge() ).." "..STRINGS.UI.HUD.CLOCKDAY)
		else
			self._text:SetString("")
		end
		self._showingcycles = false
	end
	
	local UpdateWorldStr = self.UpdateWorldString or function() end
	function self:UpdateWorldString()
		UpdateWorldStr(self)

		self._text:SetString(tostring(GLOBAL.TheWorld.state.cycles + 1).." "..STRINGS.UI.HUD.WORLD_CLOCKDAY)
		self._text:SetPosition(3, 0 / basescale, 0)
		self._text:SetSize(28)
		self._showingcycles = true
	end
end)

------------------------------------------
