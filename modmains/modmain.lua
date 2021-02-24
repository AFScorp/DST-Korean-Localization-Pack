--local pp = require "scripts/pphandle"

---------------------------------------------------------
-- Added Overriding Function --
-- Change word order.(nouns + Verb or adjective + nouns)
---------------------------------------------------------

-- In WorldgenScreen
AddClassPostConstruct("screens/worldgenscreen", function(self)
	local WorldGenScreen = self.ChangeFlavourText or function() end
	
	function self:ChangeFlavourText()
		WorldGenScreen(self)
		self.flavourtext:SetString(self.nouns[self.nounidx].." "..self.verbs[self.verbidx])
	end
end)

-- In-Game Hovering Text
AddClassPostConstruct("widgets/hoverer", function(self)
	local HoveringText = self.OnUpdate or function() end
	
	function self:OnUpdate()
		HoveringText(self)
		
		if self.isFE == false then
			str = self.owner.HUD.controls:GetTooltip()
		else
			str = self.owner:GetTooltip()
		end
		
		local lmb = nil
		if str == nil and self.isFE == false and self.owner:IsActionsVisible() then
			local lmb = self.owner.components.playercontroller:GetLeftMouseAction()
			if lmb ~= nil then
				local overriden
				str, overriden = lmb:GetActionString()
				
				if not overriden and lmb.target ~= nil and lmb.invobject == nil and lmb.target ~= lmb.doer then
					local name = lmb.target:GetDisplayName()
					if name ~= nil then
						local adjective = lmb.target:GetAdjective()
						if lmb.target.replica.stackable ~= nil and lmb.target.replica.stackable:IsStack() then
							str = (adjective ~= nil and (adjective.." "..name) or name).." "..tostring(lmb.target.replica.stackable:StackSize()).." 개 "..str
						else
							str = (adjective ~= nil and (adjective.." "..name) or name).." "..str
													
							--if lmb.target.components and lmb.target.components.healthinfo_copy then
							--	str = name .. " " .. str .. "\n" .. lmb.target.components.healthinfo_copy.text
							--else
							--	str = name.. " " .. str
							--end
						end
					end
				end
			end
		end

		if str then
			self.text:SetString(str)
			self.str = str
		end
	end
end)

-- ppp. Handling for Player Name

-- In-Game UI Clock
AddClassPostConstruct("widgets/uiclock", function(self)
	local UpdateDayStr = self.UpdateDayString or function() end
	local basescale = 1
	
	function self:UpdateDayString()
		UpdateDayStr(self)
		
		if self._cycles ~= nil then
			self._text:SetString(tostring( GLOBAL.ThePlayer.Network:GetPlayerAge() ).." "..GLOBAL.STRINGS.UI.HUD.CLOCKDAY)
		else
			self._text:SetString("")
		end
		self._showingcycles = false
	end
	
	local UpdateWorldStr = self.UpdateWorldString or function() end
	function self:UpdateWorldString()
		UpdateWorldStr(self)

		self._text:SetString("세계 날짜\n"..tostring(GLOBAL.TheWorld.state.cycles + 1).." "..GLOBAL.STRINGS.UI.HUD.WORLD_CLOCKDAY)
		self._text:SetPosition(3, 0 / basescale, 0)
		self._text:SetSize(28)
		self._showingcycles = true
	end
end)
------------------------------------------
LoadPOFile(MODROOT.."ko.po", "ko")