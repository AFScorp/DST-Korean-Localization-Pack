local pp = require "pphandle"
local STRINGS = GLOBAL.STRINGS
local shuffleArray = GLOBAL.shuffleArray
local ShardSaveGameIndex = GLOBAL.ShardSaveGameIndex
local TheInput = GLOBAL.TheInput
local LOC = GLOBAL.LOC
local LANGUAGE = GLOBAL.LANGUAGE
--local pofile = GLOBAL.resolvefilepath("ko.po")

--local languagefile = CURRENT_BETA == 0 and "ko_release.po" or "ko_beta.po"

local localization_ko = {id = LANGUAGE.KOREAN,  alt_id = nil, strings = "ko.po", code = "ko", scale = 1.0, in_steam_menu = false, in_console_menu = true, shrink_to_fit_word = false}
LOC.SetCurrentLocale(localization_ko)
LOC.SwapLanguage()
--LoadPOFile("ko.po", "ko")
---------------------------------------------------------
-- Added Overriding Function --
-- Changes word order.(nouns + Verb or adjective + nouns)
---------------------------------------------------------

-- In WorldgenScreen
-- switch two tables to fit the word order into Korean
-- then force set it by current index
local function ChangeFlavourText(self)
	self.verbs = shuffleArray(STRINGS.UI.WORLDGEN.NOUNS)
	self.nouns = shuffleArray(STRINGS.UI.WORLDGEN.VERBS)
	self.flavourtext:SetString(self.verbs[self.verbidx].." "..self.nouns[self.nounidx])
end

AddClassPostConstruct("screens/worldgenscreen", ChangeFlavourText)
------------------------------------------------------------------------
-- codes that should work only on client
------------------------------------------------------------------------

-- In-Game tooltip Text.
-- Rearrange the placer tooltip
local function GetHoverTextOverride(self)
	function self:GetHoverTextOverride()
		return self.placer_recipe ~= nil and ((STRINGS.NAMES[string.upper(self.placer_recipe.name)] or STRINGS.UI.HUD.HERE) .. " " .. STRINGS.UI.HUD.BUILD) or nil
	end
end

AddComponentPostInit("playercontroller", GetHoverTextOverride)

-- Rearrange the non-overriden tooltip
local function OnUpdate(self)
	local OnUpdate_old = self.OnUpdate or function() end
	self.OnUpdate = function(self)
		OnUpdate_old(self)
		if not self.shown then
			return
		end

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

				if lmb.action.show_primary_input_left then
                	return
                end
				
				if not overriden and lmb.target ~= nil and lmb.invobject == nil and lmb.target ~= lmb.doer then
					local name = lmb.target:GetDisplayName()
					if name ~= nil then
						local adjective = lmb.target:GetAdjective()
						name = (adjective ~= nil and (adjective.." "..name)) or name
						
						if lmb.target.replica.stackable ~= nil and lmb.target.replica.stackable:IsStack() then
							name = name.." "..tostring(lmb.target.replica.stackable:StackSize()).."개"
						end
						str = name.." "..str
					end
				end
			end
			if str then
				self.text:SetString(str)
				self.str = str
			end
		end
	end
end

AddClassPostConstruct("widgets/hoverer", OnUpdate)

--Day correction on server info widget in server list in "Browse Game"
AddClassPostConstruct("screens/redux/serverlistingscreen", function(self)
	local updatedata = self.UpdateServerData or function() end
	
	function self:UpdateServerData(selected_index_actual)
		updatedata(self, selected_index_actual)
		local gamedata = self:ProcessServerGameData()
		local day = gamedata ~= nil and gamedata.day or STRINGS.UI.SERVERLISTINGSCREEN.UNKNOWN
		self.day_description.text:SetString(day..STRINGS.UI.SERVERLISTINGSCREEN.DAYDESC)
	end
end)

--Correcting season and day on server slots in "Host Game"
local function FixShardSaveIndex(self)
	local _GetSlotDayAndSeasonText = self.GetSlotDayAndSeasonText
	function self:GetSlotDayAndSeasonText(slot)
		local txt = _GetSlotDayAndSeasonText(self, slot)
		return txt:gsub(STRINGS.UI.SERVERCREATIONSCREEN.SERVERDAY.." ", "")..STRINGS.UI.SERVERCREATIONSCREEN.SERVERDAY
	end
end

FixShardSaveIndex(GLOBAL.ShardSaveIndex)

--Deprecated: now SetMultilineTruncatedString has shrink_to_fit option
--[[local function truncatespinner(self)
	local MakeSpinnerOld = self.MakeSpinner
	function self:MakeSpinner()
		local spinner_group = MakeSpinnerOld(self)
		spinner_group.spinner.UpdateText = function(self, msg)
			local _msg = tostring(msg)
			
			local width = self.textsize.width - 50
			local chars = width/4
			
			if chars > 5 and width > 10 then
				if self.auto_shrink_text then
					self.text:SetMultilineTruncatedString(_msg, 2, width, chars, true)
				else
					self.text:SetString(_msg)
				end
			end
		end
		
		return spinner_group
		
	end
end

AddClassPostConstruct("widgets/recipepopup", truncatespinner)]]

-- In-Game UI Clock
AddClassPostConstruct("widgets/uiclock", function(self)
	local UpdateDayStr = self.UpdateDayString or function() end
	local basescale = 1
	
	function self:UpdateDayString()
		UpdateDayStr(self)
		
		if self._cycles ~= nil then
			self._text:SetString(tostring(GLOBAL.ThePlayer.Network:GetPlayerAge()).." "..STRINGS.UI.HUD.CLOCKDAY)
		else
			self._text:SetString("")
		end
		self._showingcycles = false
	end
	
	local UpdateWorldStr = self.UpdateWorldString or function() end
	function self:UpdateWorldString()
		UpdateWorldStr(self)

		self._text:SetString(tostring(GLOBAL.TheWorld.state.cycles + 1).."\n"..STRINGS.UI.HUD.WORLD_CLOCKDAY)
		self._text:SetPosition(3, 0 / basescale, 0)
		self._text:SetSize(28)
		self._showingcycles = true
	end
end)

----------------------------------------------------------------------------------------
-- codes that work only on server
----------------------------------------------------------------------------------------
-- Fix on ACTIONFAIL_GENERIC and DESCRIBE_GENERIC, which was supposed to be different by characters.
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

------------------------------------------
