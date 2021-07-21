local pp = require "pphandle"
local STRINGS = GLOBAL.STRINGS
LoadPOFile("ko.po", "ko")
---------------------------------------------------------
-- Added Overriding Function --
-- Change word order.(nouns + Verb or adjective + nouns)
---------------------------------------------------------

-- In WorldgenScreen
local worldgenscreen = GLOBAL.require "screens/worldgenscreen"
local ChangeFlavourText_Old = worldgenscreen.ChangeFlavourText or function() end
	
function worldgenscreen:ChangeFlavourText()
	self.flavourtext:SetString(self.nouns[self.nounidx].." "..self.verbs[self.verbidx])
	ChangeFlavourText_Old(self)
	self.flavourtext:SetString(self.nouns[self.nounidx].." "..self.verbs[self.verbidx])
end

-- Fix for ACTIONFAIL_GENERIC and DESCRIBE_GENERIC

--code from Tykvesh's patch
local GetActionFailString = GLOBAL.GetActionFailString

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

local GetDescOld = GLOBAL.GetDescription

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

-- pp. handling of player name for player
AddPrefabPostInit("player_common", function(inst)
	local getspecialdesc_old = inst.components.inspectable.getspecialdescription
	if getspecialdesc_old then
		inst.components.inspectable.getspecialdescription = function(inst, viewer)
			return pp.replacePP(getspecialdesc_old(inst,viewer), nst:GetDisplayName())
		end
	end
end)

--pp. handling for player skeleton & ghost
AddPrefabPostInit("skeleton_player", function(inst)
	local getspecialdesc_old = inst.components.inspectable.getspecialdescription
	if getspecialdesc_old then
		inst.components.inspectble.getspecialdescription = function(inst,viewer)
			return pp.replacePP(getspecialdesc_old(inst, viewer), inst.playername)
		end
	end
end)


local oldGetSpecialCharacterString = GLOBAL.GetSpecialCharacterString
GLOBAL.GetSpecialCharacterString = function(character)
	character = string.lower(character)
	str = oldGetSpecialCharacterString(character)
	if character == "ghost" then
		str = str:gsub("ohhh", "우"):gsub("ohh", "오"):gsub("h", ""):gsub("o", "우"):gsub("O", "오")
	end
	return str
end
	

--pp. handling for Carrat Race
AddPrefabPostInit("yotc_carrat_race_finish", function(inst)
	oldgetspecialdesc = inst.components.inspectable.getspecialdescription
	local function getdesc(inst, viewer)
		local str = oldgetspecialdesc(inst, viewer)
		local name = inst._winner.name
		str = name and pp.replacePP(str, name) or str
		return str
	end
	inst.components.inspectable.getspecialdescription = getdesc
end)

-- correcting world day count printing on server list screen.
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

		self._text:SetString("세계 날짜\n"..tostring(GLOBAL.TheWorld.state.cycles + 1).." "..STRINGS.UI.HUD.WORLD_CLOCKDAY)
		self._text:SetPosition(3, 0 / basescale, 0)
		self._text:SetSize(28)
		self._showingcycles = true
	end
end)

------------------------------------------