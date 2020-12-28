---------------------------------------------------------
-- Added Overiding Function --
-- Change word order.(nouns + Verb or adjective + nouns)
---------------------------------------------------------

-- In WorldgenScreen
AddClassPostConstruct("screens/worldgenscreen", function(self)
	local WorldGenScreen = self.ChangeFlavourText or function() end
	
	function self:ChangeFlavourText()
		WorldGenScreen(self)
		self.flavourtext:SetString(self.nouns[self.nounidx] .. " " .. self.verbs[self.verbidx])
	end
end)

-- Hovering Text in Game
AddClassPostConstruct("widgets/hoverer", function(self)
	local HoveringText = self.OnUpdate or function() end
	
	function self:OnUpdate()
		HoveringText(self)

		local str = nil
		if self.isFE == false then
			str = self.owner.HUD.controls:GetTooltip()
		else
			str = self.owner:GetTooltip()
		end

		if not str and self.isFE == false then
			local LeftMouseB = self.owner.components.playercontroller:GetLeftMouseAction()
			if LeftMouseB then
				str = LeftMouseB:GetActionString()
				if LeftMouseB.target and LeftMouseB.invobject == nil and LeftMouseB.target ~= LeftMouseB.doer then
					local DisplayText = LeftMouseB.target:GetDisplayName() or (LeftMouseB.target.components.named and lb.target.components.named.name)
					if DisplayText then
						local adjective = LeftMouseB.target:GetAdjective()
					
						if adjective then
							str = adjective .. " " .. DisplayText .. " " .. str
						else
							if LeftMouseB.target.components and LeftMouseB.target.components.healthinfo_copy then
								str = DisplayText .. " " .. str .. "\n" .. LeftMouseB.target.components.healthinfo_copy.text
							else
								str = DisplayText.. " " .. str
							end
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

-- In Game UI Clock
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