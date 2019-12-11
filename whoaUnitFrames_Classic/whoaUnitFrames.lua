whoa = {}
cfg = {}

local whoaThFaddon = IsAddOnLoaded("whoaThickFrames_Classic");
local rmhAddon = IsAddOnLoaded("RealMobHealth");
local mi2addonaddon = IsAddOnLoaded("MobInfo2-Classic");
local lortiUIaddon = IsAddOnLoaded("Lorti-UI-Classic");

local ghostText = "Ghost";	-- for manual localization of word when you are dead and in ghost shape.
local deadText = DEAD;


--	Blue shamans instead of pink.
function blueShamans ()
	if (cfg.blueShamans == true) then
		RAID_CLASS_COLORS["SHAMAN"] = CreateColor(0.0, 0.44, 0.87);
	end
end
		
--	Player class colors HP.
local function unitClassColors(healthbar, unit)
	local classColor = cfg.classColor;
	if UnitIsPlayer(unit) and UnitClass(unit) and classColor then
		_, class = UnitClass(unit);
		local class = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class];
		healthbar:SetStatusBarColor(class.r, class.g, class.b);
		if not UnitIsConnected(unit) then
			healthbar:SetStatusBarColor(0.5,0.5,0.5);
		end
	end
end
hooksecurefunc("UnitFrameHealthBar_Update", unitClassColors)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
	unitClassColors(self, self.unit)
end)

	-- Enemy player color override
-- local function playerHPColorOverride(healthbar)
	-- if (cfg.reactionColor == true) then
		-- if UnitIsPlayer("target") and UnitIsEnemy("player","target") then	--	Target enemy player color
			-- healthbar:SetStatusBarColor(0.9,0.0,0.0);		-- red color.
		-- end
	-- end
-- end
-- hooksecurefunc("UnitFrameHealthBar_Update", playerHPColorOverride)
-- hooksecurefunc("HealthBar_OnValueChanged", function(self)
	-- playerHPColorOverride(self, self.unit)
-- end)

	--	Blizzard´s target unit reactions HP color
local function npcReactionBrightColors()
	if cfg.BlizzardReactionColor == true then
		FACTION_BAR_COLORS = {
			[1] = {r =  0.9, g = 0.0, b = 0.0},
			[2] = {r =  0.9, g = 0.0, b = 0.0},
			[3] = {r =  0.9, g = 0.0, b = 0.0},
			[4] = {r =  0.9, g =  0.9, b = 0.0},
			[5] = {r = 0.0, g = 0.9, b = 0.0},
			[6] = {r = 0.0, g = 0.9, b = 0.0},
			[7] = {r = 0.0, g = 0.9, b = 0.0},
			[8] = {r = 0.0, g = 0.9, b = 0.0},
		};
	end
end
hooksecurefunc("TargetFrame_CheckFaction", npcReactionBrightColors)
  
--	Whoa´s customs target unit reactions HP colors.
local function npcReactionColors(healthbar, unit)
	if (cfg.reactionColor == true) then
		if UnitExists(unit) and (not UnitIsPlayer(unit)) then
			local reaction = FACTION_BAR_COLORS[UnitReaction(unit,"player")];
				healthbar:SetStatusBarColor(reaction.r, reaction.g, reaction.b);
			if (UnitIsTapDenied(unit)) then
				healthbar:SetStatusBarColor(0.5, 0.5, 0.5)
			end
		end
	end
end
hooksecurefunc("UnitFrameHealthBar_Update", npcReactionColors)
hooksecurefunc("HealthBar_OnValueChanged", function(self)
	npcReactionColors(self, self.unit)
end)


--	Aura positioning constants.
local LARGE_AURA_SIZE = 25;		--	cfg.largeAuraSize;		--	Default 21.
local SMALL_AURA_SIZE = 20;		--	cfg.smallAuraSize;		--	Default 17.
local AURA_OFFSET_Y = 4;
local AURA_ROW_WIDTH = 122;
local NUM_TOT_AURA_ROWS = 2;

--	Set aura size.
local function auraResize(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
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
hooksecurefunc("TargetFrame_UpdateAuraPositions", auraResize)

local function CreateStatusBarText(name, parentName, parent, point, x, y)
	local fontString = parent:CreateFontString(parentName..name, nil, "TextStatusBarText")
	fontString:SetPoint(point, parent, point, x, y)
	return fontString
end
local function targetFrameStatusText()
	if not mi2addon then
		TargetFrameHealthBar.TextString = CreateStatusBarText("Text", "TargetFrameHealthBar", TargetFrameTextureFrame, "CENTER", 0, 0);
		TargetFrameHealthBar.LeftText = CreateStatusBarText("TextLeft", "TargetFrameHealthBar", TargetFrameTextureFrame, "LEFT", 5, 0);
		TargetFrameHealthBar.RightText = CreateStatusBarText("TextRight", "TargetFrameHealthBar", TargetFrameTextureFrame, "RIGHT", -3, 0);
		TargetFrameManaBar.TextString = CreateStatusBarText("Text", "TargetFrameManaBar", TargetFrameTextureFrame, "CENTER", 0, 0);
		TargetFrameManaBar.LeftText = CreateStatusBarText("TextLeft", "TargetFrameManaBar", TargetFrameTextureFrame, "LEFT", 5, 0);
		TargetFrameManaBar.RightText = CreateStatusBarText("TextRight", "TargetFrameManaBar", TargetFrameTextureFrame, "RIGHT", -3, 0);
	end
end
targetFrameStatusText()

-- NOTE: Blizzards API will return targets current and max healh as a percentage instead of exact value (ex. 100/100).
local function customStatusTex(statusFrame, textString, value, valueMin, valueMax)

	if ( ( tonumber(valueMax) ~= valueMax or valueMax > 0 ) and not ( statusFrame.pauseUpdates ) ) then
		statusFrame:Show();

		local k,m=1e3
		local m=k*k
		
		valueDisplay	=	(( value >= 1e3 and value < 1e5 and format("%1.3f",value/k)) or
							( value >= 1e5 and value < 1e6 and format("%1.0f K",value/k)) or
							( value >= 1e6 and value < 1e9 and format("%1.1f M",value/m)) or
							( value >= 1e9 and format("%1.1f M",value/m)) or value )
							
		valueMaxDisplay	=	(( valueMax >= 1e3 and valueMax < 1e5 and format("%1.3f",valueMax/k)) or
							( valueMax >= 1e5 and valueMax < 1e6 and format("%1.0f K",valueMax/k)) or
							( valueMax >= 1e6 and valueMax < 1e9 and format("%1.1f M",valueMax/m)) or
							( valueMax >= 1e9 and format("%1.1f M",valueMax/m)) or valueMax )

		-- local valueDisplay = value;
		-- local valueMaxDisplay = valueMax;
		
		local textDisplay = GetCVar("statusTextDisplay");
		if ( value and valueMax > 0 and ( (textDisplay ~= "NUMERIC" and textDisplay ~= "NONE") or statusFrame.showPercentage ) and not statusFrame.showNumeric) then
			if ( value == 0 and statusFrame.zeroText ) then
				textString:SetText(statusFrame.zeroText);
				statusFrame.isZero = 1;
				textString:Show();
			elseif ( textDisplay == "BOTH" and not statusFrame.showPercentage) then
				if( statusFrame.LeftText and statusFrame.RightText ) then
					if(not statusFrame.powerToken or statusFrame.powerToken == "MANA") then		-- both HP %
						if value <= 1 then
							statusFrame.LeftText:SetText("");
						else
							statusFrame.LeftText:SetText(math.ceil((value / valueMax) * 100) .. "%");
						end
						statusFrame.LeftText:Show();
					end
					if value <= 1 then
						statusFrame.RightText:SetText("");
					else
						statusFrame.RightText:SetText(valueDisplay);
					end
					statusFrame.RightText:Show();
					textString:Hide();
				else
					if value <= 0 then
						valueDisplay = "";
					else
						valueDisplay = "(" .. math.ceil((value / valueMax) * 100) .. "%) " .. valueDisplay .. " / " .. valueMaxDisplay;
					end
				end
				textString:SetText(valueDisplay);
			else
				valueDisplay = math.ceil((value / valueMax) * 100) .. "%";
				if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
					if value <= 1 then
						textString:SetText("");
					else
						textString:SetText(statusFrame.prefix .. " " .. valueDisplay);
					end
				else
					if value <= 1 then
						textString:SetText("");
					else
						textString:SetText(valueDisplay);
					end
				end
			end
		elseif ( value == 0 and statusFrame.zeroText ) then
			textString:SetText(statusFrame.zeroText);
			statusFrame.isZero = 1;
			textString:Show();
			return;
		else
			statusFrame.isZero = nil;
			if ( statusFrame.prefix and (statusFrame.alwaysPrefix or not (statusFrame.cvar and GetCVar(statusFrame.cvar) == "1" and statusFrame.textLockable) ) ) then
				if value <= 1 then
					textString:SetText("");
				else
					textString:SetText(statusFrame.prefix.." "..valueDisplay.." / "..valueMaxDisplay);
				end
			else
				if value <= 1 then
					textString:SetText("");
				else
					textString:SetText(valueDisplay.." / "..valueMaxDisplay);
				end
			end
		end
	end
end
hooksecurefunc("TextStatusBar_UpdateTextStringWithValues",customStatusTex)

--	Player and target frames dead / ghost text.
hooksecurefunc("TextStatusBar_UpdateTextStringWithValues",function(self)
	if UnitIsDead("player") or UnitIsGhost("player") then
		PlayerFrameHealthBar.TextString:SetFontObject(SystemFont_Small);
		PlayerFrameHealthBar.TextString:SetTextColor(1.0,0.82,0,1);
		PlayerFrameHealthBar.TextString:Show();
	else
		if cfg.styleFont then
			PlayerFrameHealthBar.TextString:SetFontObject(SystemFont_Outline_Small);
		elseif not cfg.styleFont then
			PlayerFrameHealthBar.TextString:SetFontObject(TextStatusBarText);
		end
		PlayerFrameHealthBar.TextString:SetTextColor(1,1,1,1);
	end
	if UnitIsDead("player") then
		PlayerFrameHealthBar.TextString:SetText(deadText);
	elseif UnitIsGhost("player") then
		PlayerFrameHealthBar.TextString:SetText(ghostText);
	end
	if UnitIsGhost("target") then
		TargetFrame.deadText:SetText(ghostText);
		TargetFrame.deadText:Show();
	end
end)