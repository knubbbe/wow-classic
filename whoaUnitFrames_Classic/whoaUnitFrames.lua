local ghostText = "Ghost";	-- for manual localization of word when you are dead and in ghost shape.

--	uncomment for Blue shamans
-- RAID_CLASS_COLORS['SHAMAN']["r"] = 0.0
-- RAID_CLASS_COLORS['SHAMAN']["g"] = 0.44
-- RAID_CLASS_COLORS['SHAMAN']["b"] = 0.87
-- RAID_CLASS_COLORS['SHAMAN']["colorStr"] = "ff0070de"
		
--	Player class colors HP.
local function whoaUnitClass(healthbar, unit)
	if UnitIsPlayer(unit) and UnitIsConnected(unit) and UnitClass(unit) and (cfg.classColor) then
		_, class = UnitClass(unit);
		local class = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];
		healthbar:SetStatusBarColor(class.r, class.g, class.b);
	elseif UnitIsPlayer(unit) and (not UnitIsConnected(unit)) then
		healthbar:SetStatusBarColor(0.5,0.5,0.5);
	else
		healthbar:SetStatusBarColor(0,0.9,0);
	end
end
hooksecurefunc("UnitFrameHealthBar_Update", whoaUnitClass)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
	whoaUnitClass(self, self.unit)
end)

	-- Enemy player color override
-- local function playerHPColorOverride(healthbar, unit)
	-- if (cfg.reactionColor == true) then
		-- if UnitIsPlayer("target") and UnitIsEnemy("player","target") then	--	Target enemy player color
			-- healthbar:SetStatusBarColor(1.0, 0.0, 0.0);		-- red color.
		-- end
	-- end
-- end
-- hooksecurefunc("UnitFrameHealthBar_Update", playerHPColorOverride)
-- hooksecurefunc("HealthBar_OnValueChanged", function(self)
	-- playerHPColorOverride(self, self.unit)
-- end)

--	Whoa´s customs target unit reactions HP colors.
local function whoaUnitReaction(healthbar, unit)
	if (cfg.reactionColor == true) and (cfg.BlizzardReactionColor == false) then
		if UnitExists(unit) and (not UnitIsPlayer(unit)) and (cfg.reactionColor) then
			if (UnitIsTapDenied(unit)) and not UnitPlayerControlled(unit) then
				healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
			elseif (not UnitIsTapDenied(unit)) then
				local reaction = FACTION_BAR_COLORS[UnitReaction(unit,"player")];
				if reaction then
					healthbar:SetStatusBarColor(reaction.r, reaction.g, reaction.b);
				else
					healthbar:SetStatusBarColor(0,0.6,0.1)
				end
			end
		elseif UnitExists(unit) and (not UnitIsPlayer(unit)) and not (cfg.reactionColor) then
			if (UnitIsTapDenied(unit)) and not UnitPlayerControlled(unit) then
				healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
			end
		end
	end
end
hooksecurefunc("TargetFrame_CheckFaction", whoaUnitReaction)
hooksecurefunc("UnitFrameHealthBar_Update", whoaUnitReaction)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
	whoaUnitReaction(self, self.unit)
end)

--	Blizzard´s target unit reactions HP color
local function BlizzardUnitReactionColors(healthbar, unit)
	if (cfg.reactionColor == true) and (cfg.BlizzardReactionColor == true) then
		if UnitExists(unit) and (not UnitIsPlayer(unit)) and (cfg.reactionColor) then
			if (UnitIsTapDenied(unit)) and not UnitPlayerControlled(unit) then
				healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
			elseif (not UnitIsTapDenied(unit)) and not UnitPlayerControlled(unit) then
				if UnitIsFriend("target","player") then
					healthbar:SetStatusBarColor(0.0, 1.0, 0.0);
				elseif UnitIsEnemy("target","player") then
					healthbar:SetStatusBarColor(1.0, 0.0, 0.0);
				elseif not  UnitIsFriend("target","player") and not  UnitIsEnemy("target","player") then
					healthbar:SetStatusBarColor(1,1,0);
				end
			end
		elseif UnitExists(unit) and (not UnitIsPlayer(unit)) and not (cfg.reactionColor) then
			if (UnitIsTapDenied(unit)) and not UnitPlayerControlled(unit) then
				healthbar:SetStatusBarColor(0.9, 0.7, 0.5)
			end
		end
	end
end
hooksecurefunc("TargetFrame_CheckFaction", BlizzardUnitReactionColors)
hooksecurefunc("UnitFrameHealthBar_Update", BlizzardUnitReactionColors)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
	BlizzardUnitReactionColors(self, self.unit)
end)


--	Aura positioning constants.
local LARGE_AURA_SIZE = cfg.largeAuraSize;		--	Default 21.
local SMALL_AURA_SIZE = cfg.smallAuraSize;		--	Default 17.
local AURA_OFFSET_Y = 3;
local AURA_ROW_WIDTH = 122;
local NUM_TOT_AURA_ROWS = 2;

--	Set aura size.
local function whoaAuraResize(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
	if (cfg.bigAuras == true) then
		local size;
		local offsetY = AURA_OFFSET_Y;
		local rowWidth = 0;
		local firstBuffOnRow = 1;
		for i=1, numAuras do
			if ( largeAuraList[i] ) then
				size = LARGE_AURA_SIZE; --(cfg.largeAuraSize)
				offsetY = AURA_OFFSET_Y + AURA_OFFSET_Y;
			else
				size = SMALL_AURA_SIZE;	--(cfg.smallAuraSize) --
			end
			if ( i == 1 ) then
				rowWidth = size;
				self.auraRows = self.auraRows + 1;
			else
				rowWidth = rowWidth + size + offsetX;
			end
			if ( rowWidth > maxRowWidth ) then
				updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX, offsetY, mirrorAurasVertically);
				rowWidth = size;
				self.auraRows = self.auraRows + 1;
				firstBuffOnRow = i;
				offsetY = AURA_OFFSET_Y;
				if ( self.auraRows > NUM_TOT_AURA_ROWS ) then
					maxRowWidth = AURA_ROW_WIDTH;
				end
			else
				updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX, offsetY, mirrorAurasVertically);
			end
		end
	end
end
hooksecurefunc("TargetFrame_UpdateAuraPositions", whoaAuraResize)

-- NOTE: Blizzards API will return targets current and max healh as a percentage instead of exact value (ex. 100/100).
-- local function whoaTextFormat(statusFrame, textString, value, valueMin, valueMax)
	-- if ( ( tonumber(valueMax) ~= valueMax or valueMax > 0 ) and not ( statusFrame.pauseUpdates ) ) then
		-- local valueDisplay = value;
		-- local valueMaxDisplay = valueMax;
		-- local k,m=1e3
		-- local m=k*k
		-- local textDisplay = GetCVar("statusTextDisplay");
		-- if ( value and valueMax > 0 and ( (textDisplay ~= "NUMERIC" and textDisplay ~= "NONE") or statusFrame.showPercentage ) and not statusFrame.showNumeric) then
			-- if ( value == 0 and statusFrame.zeroText ) then
				-- textString:SetText(statusFrame.zeroText);
				-- statusFrame.isZero = 1;
				-- textString:Show();
			-- elseif ( textDisplay == "BOTH" and not statusFrame.showPercentage) then
				-- if( statusFrame.LeftText and statusFrame.RightText ) then
					-- if(not statusFrame.powerToken or statusFrame.powerToken == "MANA") then
						-- statusFrame.LeftText:SetText(math.ceil((value / valueMax) * 100) .. "%");
						-- statusFrame.LeftText:Show();
					-- end
					-- if (value < 1e3) then
						-- valueDisplay = format(valueDisplay);
					-- elseif (value >= 1e3) and (value < 1e5) then
						-- valueDisplay = format("%1.3f",value/k);
					-- elseif (value >= 1e5) and (value < 1e6) then
						-- valueDisplay = format("%1.0f K",value/k);
					-- elseif (value >= 1e6) then
						-- valueDisplay = format("%1.1f M",value/m);
					-- end
					-- if (value == 0) then
						-- statusFrame.RightText:SetText("");
					-- elseif (value ~= 0) then
						-- statusFrame.RightText:SetText(valueDisplay);
					-- end
					-- statusFrame.RightText:Show();
					-- textString:Hide();
				-- else
					-- valueDisplay = "(" .. math.ceil((value / valueMax) * 100) .. "%) " .. valueDisplay .. " / " .. valueMaxDisplay;
				-- end
				-- textString:SetText(valueDisplay);
			-- else
				-- if (value == 0) then
					-- valueDisplay = ("");
				-- elseif (value ~= 0) then
					-- valueDisplay = math.ceil((value / valueMax) * 100) .. "%";
				-- end
				-- if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
					-- textString:SetText(statusFrame.prefix .. " " .. valueDisplay);
				-- else
					-- textString:SetText(valueDisplay);
				-- end
			-- end
		-- elseif ( value == 0 and statusFrame.zeroText ) then
			-- textString:SetText(statusFrame.zeroText);
			-- statusFrame.isZero = 1;
			-- textString:Show();
			-- return;
		-- else
			-- statusFrame.isZero = nil;
			-- if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
				-- if (value < 1e3) then
					-- valueDisplay = format(valueDisplay);
				-- elseif (value >= 1e3) and (value < 1e5) then
					-- valueDisplay = format("%1.3f",value/k);
				-- elseif (value >= 1e5) and (value < 1e6) then
					-- valueDisplay = format("%1.0f K",value/k);
				-- elseif (value >= 1e6) then
					-- valueDisplay = format("%1.1f M",value/m);
				-- end
				-- if (valueMax < 1e3) then
					-- valueMaxDisplay = format(valueMaxDisplay);
				-- elseif (valueMax >= 1e3) and (valueMax < 1e5) then
					-- valueMaxDisplay = format("%1.3f",valueMaxDisplay/k);
				-- elseif (valueMax >= 1e5) and (valueMax < 1e6) then
					-- valueMaxDisplay = format("%1.0f K",valueMaxDisplay/k);
				-- elseif (valueMax >= 1e6) then
					-- valueMaxDisplay = format("%1.1f M",valueMaxDisplay/m);
				-- end
				-- if (value == 0) then
					-- textString:SetText("");
				-- elseif (value ~= 0) then
					-- textString:SetText(statusFrame.prefix.." "..valueDisplay.." / "..valueMaxDisplay);
				-- end
			-- else
				-- if (value < 1e3) then
					-- valueDisplay = format(valueDisplay);
				-- elseif (value >= 1e3) and (value < 1e5) then
					-- valueDisplay = format("%1.3f",value/k);
				-- elseif (value >= 1e5) and (value < 1e6) then
					-- valueDisplay = format("%1.0f K",value/k);
				-- elseif (value >= 1e6) then
					-- valueDisplay = format("%1.1f M",value/m);
				-- end
				-- if (valueMax < 1e3) then
					-- valueMaxDisplay = format(valueMaxDisplay);
				-- elseif (valueMax >= 1e3) and (valueMax < 1e5) then
					-- valueMaxDisplay = format("%1.3f",valueMaxDisplay/k);
				-- elseif (valueMax >= 1e5) and (valueMax < 1e6) then
					-- valueMaxDisplay = format("%1.0f K",valueMaxDisplay/k);
				-- elseif (valueMax >= 1e6) then
					-- valueMaxDisplay = format("%1.1f M",valueMaxDisplay/m);
				-- end
				-- if (value == 0) then
					-- textString:SetText("");
				-- elseif (value ~= 0) then
					-- textString:SetText(valueDisplay.." / "..valueMaxDisplay);
				-- end
			-- end
		-- end
	-- else
		-- textString:Hide();
		-- textString:SetText("");
		-- if ( not statusFrame.alwaysShow ) then
			-- statusFrame:Hide();
		-- else
			-- statusFrame:SetValue(0);
		-- end
	-- end
-- end
-- hooksecurefunc("TextStatusBar_UpdateTextStringWithValues",whoaTextFormat)

--	Custom status text format.
hooksecurefunc("TextStatusBar_UpdateTextStringWithValues",function(self,_,value,_,maxValue)
	-- local value = 99999
	-- local maxValue = 999999
	if self.RightText and value and maxValue>0 and not self.showPercentage and GetCVar("statusTextDisplay")=="BOTH" then

		local k,m=1e3
		m=k*k
		self.RightText:SetText((value>1e3 and value<1e5 and format("%1.3f",value/k)) or (value>=1e5 and value<1e6 and format("%1.0f K",value/k)) or (value>=1e6 and value<1e9 and format("%1.1f M",value/m)) or (value>=1e9 and format("%1.1f M",value/m)) or value )
		if value == 0 then
			self.RightText:SetText(" ");
		end
	end
	if self.LeftText and value and maxValue > 0 and not self.showPercentage and GetCVar("statusTextDisplay")=="BOTH" then
		-- local k,m=1e3 
		-- m=k*k
		-- self.RightText:SetText((value>1e3 and value<1e5 and format("%1.3f",value/k)) or (value>=1e5 and value<1e6 and format("%1.0f K",value/k)) or (value>=1e6 and value<1e9 and format("%1.1f M",value/m)) or (value>=1e9 and format("%1.1f M",value/m)) or value )
		if value == 0 then
			self.LeftText:SetText(" ");
		end
	end
end)

--	Player frame dead / ghost text.
hooksecurefunc("TextStatusBar_UpdateTextStringWithValues",function(self)
	local deadText = DEAD;
	-- local ghostText = "Ghost";
	
	if UnitIsDead("player") or UnitIsGhost("player") then
		PlayerFrameHealthBar.TextString:SetFontObject(SystemFont_Small);
		PlayerFrameHealthBar.TextString:SetTextColor(1.0,0.82,0,1);
		for i, v in pairs({	PlayerFrameHealthBar.LeftText, PlayerFrameHealthBar.RightText, PlayerFrameManaBar.LeftText, PlayerFrameManaBar.RightText, PlayerFrameManaBar.TextString, PlayerFrameManaBar }) do v:SetAlpha(0); end
		PlayerFrameHealthBar.TextString:Show();
	else
		PlayerFrameHealthBar.TextString:SetTextColor(1,1,1,1);
		for i, v in pairs({	PlayerFrameHealthBar.LeftText, PlayerFrameHealthBar.RightText, PlayerFrameManaBar.LeftText, PlayerFrameManaBar.RightText, PlayerFrameManaBar.TextString, PlayerFrameManaBar }) do v:SetAlpha(1); end
	end
	if UnitIsDead("player") then
		PlayerFrameHealthBar.TextString:SetText(deadText);
	elseif UnitIsGhost("player") then
		PlayerFrameHealthBar.TextString:SetText(ghostText);
	-- end
	elseif not UnitIsDead("player") and not UnitIsGhost("player") then
		if cfg.styleFont then
			PlayerFrameHealthBar.TextString:SetFontObject(SystemFont_Outline_Small);
		elseif not cfg.styleFont then
			PlayerFrameHealthBar.TextString:SetFontObject(TextStatusBarText);
		end
	end
	
	if UnitIsDead("target") or UnitIsGhost("target") then
		for i, v in pairs({	TargetFrameHealthBar.LeftText, TargetFrameHealthBar.RightText, TargetFrameHealthBar.TextString, TargetFrameManaBar.LeftText, TargetFrameManaBar.RightText, TargetFrameManaBar.TextString, TargetFrameManaBar }) do v:SetAlpha(0); end
	else
		for i, v in pairs({	TargetFrameHealthBar.LeftText, TargetFrameHealthBar.RightText, TargetFrameHealthBar.TextString, TargetFrameManaBar.LeftText, TargetFrameManaBar.RightText, TargetFrameManaBar.TextString, TargetFrameManaBar }) do v:SetAlpha(1); end
	end
	if UnitIsDead("target") then
		TargetFrame.deadText:SetText(deadText);
	elseif UnitIsGhost("target") then
		TargetFrame.deadText:Show();
		TargetFrame.deadText:SetText(ghostText);
	end
	if UnitIsDead("target") or UnitIsGhost("target") then
		for i, v in pairs({	TargetFrameHealthBar.LeftText, TargetFrameHealthBar.RightText, TargetFrameHealthBar.TextString, TargetFrameManaBar.LeftText, TargetFrameManaBar.RightText, TargetFrameManaBar.TextString, TargetFrameManaBar }) do v:SetAlpha(0); end
	else
		for i, v in pairs({	TargetFrameHealthBar.LeftText, TargetFrameHealthBar.RightText, TargetFrameHealthBar.TextString, TargetFrameManaBar.LeftText, TargetFrameManaBar.RightText, TargetFrameManaBar.TextString, TargetFrameManaBar }) do v:SetAlpha(1); end
	end
	
	if UnitIsDead("pet") then
		for i, v in pairs({	PetFrameHealthBar.LeftText, PetFrameHealthBar.RightText, PetFrameManaBar.LeftText, PetFrameManaBar.RightText, PetFrameManaBar.TextString, PetFrameManaBar }) do v:SetAlpha(0); end
	elseif not UnitIsDead("pet") then
		for i, v in pairs({	PetFrameHealthBar.LeftText, PetFrameHealthBar.RightText, PetFrameManaBar.LeftText, PetFrameManaBar.RightText, PetFrameManaBar.TextString, PetFrameManaBar }) do v:SetAlpha(1); end	
	end
end)