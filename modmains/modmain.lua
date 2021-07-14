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
	if self.isFE == false then
		str = self.owner.HUD.controls:GetTooltip()
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
						name = name .. tostring(lmb.target.replica.stackable:StackSize()).." 개"
					end
					str = name .." ".. str
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
local function GetStatus(inst, viewer)
    return (inst:HasTag("playerghost") and "GHOST")
        or (inst.hasRevivedPlayer and "REVIVER")
        or (inst.hasKilledPlayer and "MURDERER")
        or (inst.hasAttackedPlayer and "ATTACKER")
        or (inst.hasStartedFire and "FIRESTARTER")
        or nil
end

local function TryDescribe(descstrings, modifier)
    return descstrings ~= nil and (
            type(descstrings) == "string" and
            descstrings or
            descstrings[modifier] or
            descstrings.GENERIC
        ) or nil
end

local function TryCharStrings(inst, charstrings, modifier)
    return charstrings ~= nil and (
            TryDescribe(charstrings.DESCRIBE[string.upper(inst.prefab)], modifier) or
            TryDescribe(charstrings.DESCRIBE.PLAYER, modifier)
        ) or nil
end

local function GetDescription(inst, viewer)
	local modifier = inst.components.inspectable:GetStatus(viewer) or "GENERIC"
	local desc = TryCharStrings(inst, STRINGS.CHARACTERS[string.upper(viewer.prefab)], modifier) or
            TryCharStrings(inst, STRINGS.CHARACTERS.GENERIC, modifier)
	local name = inst:GetDisplayName()
	desc = pp.replacePP(desc, "%%s", name)
    
    return string.format(desc, name)
end

AddPrefabPostInit("player_common", function(inst)
	inst.components.inspectable.getspecialdescription = GetDescription
end)

--pp. handling of player name for player_skeleton
local function getdesc(inst, viewer)
    if inst.char ~= nil and not viewer:HasTag("playerghost") then
        local mod = GLOBAL.GetGenderStrings(inst.char)
        local desc = GLOBAL.GetDescription(viewer, inst, mod)
        local name = inst.playername or STRINGS.NAMES[string.upper(inst.char)]

        --no translations for player killer's name
        if inst.pkname ~= nil then
			desc = pp.replacePP(desc, "%%s", name)
            return string.format(desc, name, inst.pkname)
        end

        --permanent translations for death cause
        if inst.cause == "unknown" then
            inst.cause = "shenanigans"
        elseif inst.cause == "moose" then
            inst.cause = math.random() < .5 and "moose1" or "moose2"
        end

        --viewer based temp translations for death cause
        local cause =
            inst.cause == "nil"
            and (viewer == "waxwell" and
                "charlie" or
                "darkness")
            or inst.cause
		desc = pp.replacePP(desc, "%%s", name)
        return string.format(desc, name, STRINGS.NAMES[string.upper(cause)] or STRINGS.NAMES.SHENANIGANS)
    end
end

local function SetSkelDesc(inst, char, playername, cause, pkname)
	inst.char = char
	inst.playername = playername
	inst.pkname = pkname
	inst.cause = pkname == nil and cause:lower() or nil
	inst.components.inspectable.getspecialdescription = getdesc
end

local function onload(inst, data)
    if data ~= nil and data.anim ~= nil then
        inst.animnum = data.anim
        inst.AnimState:PlayAnimation("idle"..tostring(inst.animnum))
    end
end

local function onloadplayer(inst, data)
    onload(inst, data)

    if data ~= nil and data.char ~= nil and (data.cause ~= nil or data.pkname ~= nil) then
        inst.char = data.char
        inst.playername = data.playername --backward compatibility for nil playername
        inst.pkname = data.pkname --backward compatibility for nil pkname
        inst.cause = data.cause
        if inst.components.inspectable ~= nil then
            inst.components.inspectable.getspecialdescription = getdesc
        end
        if data.age ~= nil and data.age > 0 then
            inst.skeletonspawntime = -data.age
        end

        if data.avatar ~= nil then
            --Load legacy data
            inst.components.playeravatardata:OnLoad(data.avatar)
        end
    end
end	
	
AddPrefabPostInit("skeleton_player", function(inst)
	inst.SetSkeletonDescription = SetSkelDesc
	inst.OnLoad = onloadplayer
end)

--pp. handling for ghost speech
local Oooh_endings = { "", "우", "오" }
local Oooh_punc = { ".", "?", "!" }

local function ooohstart(isstart)
    local str = isstart and "우" or "오"
    local l = math.random(2, 4)
    for i = 2, l do
        str = str..(math.random() > 0.3 and "오" or "우")
    end
    return str
end

local function ooohspace()
    local c = math.random()
    local str =
        (c <= .1 and "! ") or
        (c <= .2 and ". ") or
        (c <= .3 and "? ") or
        (c <= .4 and ", ") or
        " "
    return str, c <= .3
end

local function ooohend()
    return Oooh_endings[math.random(#Oooh_endings)]
end

local function ooohpunc()
    return Oooh_punc[math.random(#Oooh_punc)]
end

local function CraftOooh() -- Ghost speech!
    local isstart = true
    local length = math.random(6)
    local str = ""
    for i = 1, length do
        str = str..ooohstart(isstart)..ooohend()
        if i ~= length then
            local space
            space, isstart = ooohspace()
            str = str..space
        end
    end
    return str..ooohpunc()
end

local wilton_sayings =
{
    "이에에에에에에.",
    "어어어어어어어.",
    "달그락.",
    "달그락 달그락 달그락 달그락",
    "쉬이이이이!",
    "아아아아아아아.",
    "으어어어어어어어어어어.",
    "...",
}

GLOBAL.GetSpecialCharacterString = function(character)
    if character == nil then
        return nil
    end

    character = string.lower(character)

    return (character == "mime" and "")
        or (character == "ghost" and CraftOooh())
        or (character == "wilton" and wilton_sayings[math.random(#wilton_sayings)])
        or nil
end
	

--pp. handling for Carrat Race
local function getdesc(inst, viewer)
	if inst:HasTag("burnt") then
		return GetDescription(viewer, inst, "BURNT")
	elseif inst._active and inst._winner ~= nil then
		if inst._winner.userid ~= nil and inst._winner.userid == viewer.userid then
			return GetDescription(viewer, inst, "I_WON")
		elseif inst._winner.name ~= nil then
			return subfmt(pp.replacePP(GetDescription(viewer, inst, "SOMEONE_ELSE_WON"), "{winner}", inst._winner.name), { winner = inst._winner.name })
		end
	end
	
	return GetDescription(viewer, inst) or nil
end
AddPrefabPostInit("yotc_carrat_race_finish", function(inst)
	inst.components.inspectable.getspecialdescription = getdesc
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