local mi2 = IsAddOnLoaded("MobInfo2-Classic");

--	Target frame
local function whoaTargetFrames (self, forceNormalTexture)
	local classification = UnitClassification(self.unit);
	self.highLevelTexture:ClearAllPoints();
	self.highLevelTexture:SetPoint("CENTER", self.levelText, "CENTER", 1,0);
	self.deadText:SetPoint("CENTER", self.healthbar, "CENTER",0,0);
	self.nameBackground:Hide();
	self.name:SetPoint("LEFT", self, 15, 36);
	self.healthbar:SetSize(119, 18);
	self.healthbar:SetPoint("TOPLEFT", 5, -24);
	self.manabar:SetPoint("TOPLEFT", 5, -45);
	self.manabar:SetSize(119, 18);
	-- TargetFrame.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Flash");
	-- TargetFrame.threatNumericIndicator:ClearAllPoints();
	-- TargetFrame.threatNumericIndicator:SetPoint("BOTTOM", PlayerFrame, "TOP", 72, -21);
	-- FocusFrame.threatNumericIndicator:SetAlpha(0);
	if not mi2 then
		self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 5, 0);
		self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -3, 0);
		self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0);
		self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 5, 0);	
		self.manabar.RightText:ClearAllPoints();
		self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -3, 0);
		self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, 0);
	end
	if ( forceNormalTexture ) then
		self.haveElite = nil;
		if ( classification == "minus" ) then
			self.Background:SetSize(119,12);
			self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 47);
			self.name:SetPoint("LEFT", self, 16, 19);
			self.healthbar:ClearAllPoints();
			self.healthbar:SetPoint("LEFT", 5, 3);
			self.healthbar:SetHeight(12);
			self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 3, 0);
			self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -2, 0);
		else
			self.Background:SetSize(119,42);
			self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35);
		end
		if ( self.threatIndicator ) then
			if ( classification == "minus" ) then
				self.threatIndicator:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Minus-Flash");
				self.threatIndicator:SetTexCoord(0, 1, 0, 1);
				self.threatIndicator:SetWidth(256);
				self.threatIndicator:SetHeight(128);
				self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0);
			else
				self.threatIndicator:SetTexCoord(0, 0.9453125, 0, 0.181640625);
				self.threatIndicator:SetWidth(242);
				self.threatIndicator:SetHeight(93);
				self.threatIndicator:SetPoint("TOPLEFT", self, "TOPLEFT", -24, 0);
			end
		end	
	else
		self.haveElite = true;
		self.Background:SetSize(119,42);
		if ( self.threatIndicator ) then
			self.threatIndicator:SetTexCoord(0, 0.9453125, 0.181640625, 0.400390625);
			self.threatIndicator:SetWidth(242);
			self.threatIndicator:SetHeight(112);
		end		
	end
	self.healthbar.lockColor = true;
	if ( cfg.whoaTexture == true) then
		self.healthbar:SetStatusBarTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\statusbar\\whoa");
	end
end
hooksecurefunc("TargetFrame_CheckClassification", whoaTargetFrames)


local function whoaTargetFramesCustoms (self, forceNormalTexture)
	local classification = UnitClassification(self.unit);
	local path = nil;
	
	if (cfg.darkFrames == true) then
		path = "Interface\\Addons\\whoaUnitFrames_Classic\\media\\dark\\"
	elseif (cfg.darkFrames == false) then
		path = "Interface\\Addons\\whoaUnitFrames_Classic\\media\\light\\"
	end
	if ( forceNormalTexture ) then
		self.borderTexture:SetTexture(path.."UI-TargetingFrame");
	elseif ( classification == "minus" ) then
		self.borderTexture:SetTexture(path.."UI-TargetingFrame-Minus");
		forceNormalTexture = true;
	elseif ( classification == "worldboss" or classification == "elite" ) then
		self.borderTexture:SetTexture(path.."UI-TargetingFrame-Elite");
	elseif ( classification == "rareelite" ) then
		self.borderTexture:SetTexture(path.."UI-TargetingFrame-Rare-Elite");
	elseif ( classification == "rare" ) then
		self.borderTexture:SetTexture(path.."UI-TargetingFrame-Rare");
	else
		self.borderTexture:SetTexture(path.."UI-TargetingFrame");
		forceNormalTexture = true;
	end
end
hooksecurefunc("TargetFrame_CheckClassification", whoaTargetFramesCustoms)

local function whoaTargetStyleFont (self)
	if not mi2 and (cfg.styleFont) then
		self.healthbar.LeftText:SetFontObject(SystemFont_Outline_Small);
		self.healthbar.RightText:SetFontObject(SystemFont_Outline_Small);
		self.manabar.LeftText:SetFontObject(SystemFont_Outline_Small);
		self.manabar.RightText:SetFontObject(SystemFont_Outline_Small);
		self.healthbar.TextString:SetFontObject(SystemFont_Outline_Small);
		self.manabar.TextString:SetFontObject(SystemFont_Outline_Small);
	end
end
hooksecurefunc("TargetFrame_CheckClassification", whoaTargetStyleFont)

-- Mana texture
local function whoaManaBar (manaBar)
	local powerType, powerToken, altR, altG, altB = UnitPowerType(manaBar.unit);
	local info = PowerBarColor[powerToken];
	if ( info ) then
		if ( not manaBar.lockColor ) then
			if not ( info.atlas ) and ( cfg.whoaTexture == true) then
				manaBar:SetStatusBarTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\statusbar\\whoa");
			end
		end
	end
end
hooksecurefunc("UnitFrameManaBar_UpdateType", whoaManaBar)

local function CreateStatusBarText(name, parentName, parent, point, x, y)
	local fontString = parent:CreateFontString(parentName..name, nil, "TextStatusBarText")
	fontString:SetPoint(point, parent, point, x, y)
	return fontString
end

local function whoaStatustextFrame()
	if not mi2 then
		TargetFrameHealthBar.TextString = CreateStatusBarText("Text", "TargetFrameHealthBar", TargetFrameTextureFrame, "CENTER", 0, 0);
		TargetFrameHealthBar.LeftText = CreateStatusBarText("TextLeft", "TargetFrameHealthBar", TargetFrameTextureFrame, "LEFT", 5, 0);
		TargetFrameHealthBar.RightText = CreateStatusBarText("TextRight", "TargetFrameHealthBar", TargetFrameTextureFrame, "RIGHT", -3, 0);
		TargetFrameManaBar.TextString = CreateStatusBarText("Text", "TargetFrameManaBar", TargetFrameTextureFrame, "CENTER", 0, 0);
		TargetFrameManaBar.LeftText = CreateStatusBarText("TextLeft", "TargetFrameManaBar", TargetFrameTextureFrame, "LEFT", 5, 0);
		TargetFrameManaBar.RightText = CreateStatusBarText("TextRight", "TargetFrameManaBar", TargetFrameTextureFrame, "RIGHT", -3, 0);
	end
end
whoaStatustextFrame()

--	ToT & ToF
local function whoaFrameToTF()
	TargetFrameToTTextureFrameDeadText:ClearAllPoints();
	TargetFrameToTTextureFrameDeadText:SetPoint("CENTER", "TargetFrameToTHealthBar","CENTER",1, 0);
	TargetFrameToTTextureFrameName:SetSize(65,10);
	TargetFrameToTHealthBar:ClearAllPoints();
	TargetFrameToTHealthBar:SetPoint("TOPLEFT", 45, -15);
    TargetFrameToTHealthBar:SetHeight(10);
    TargetFrameToTManaBar:ClearAllPoints();
    TargetFrameToTManaBar:SetPoint("TOPLEFT", 45, -25);
    TargetFrameToTManaBar:SetHeight(5);
	TargetFrameToTBackground:SetSize(50,14);
	TargetFrameToTBackground:ClearAllPoints();
	TargetFrameToTBackground:SetPoint("CENTER", "TargetFrameToT","CENTER",20, 0);
	-- FocusFrameToTTextureFrameDeadText:ClearAllPoints();
	-- FocusFrameToTTextureFrameDeadText:SetPoint("CENTER", "FocusFrameToTHealthBar" ,"CENTER",1, 0);
	-- FocusFrameToTTextureFrameName:SetSize(65,10);
	-- FocusFrameToTTextureFrameTexture:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\UI-TargetofTargetFrame");
	-- FocusFrameToTHealthBar:ClearAllPoints();
    -- FocusFrameToTHealthBar:SetPoint("TOPLEFT", 43, -15);
    -- FocusFrameToTHealthBar:SetHeight(10);
    -- FocusFrameToTManaBar:ClearAllPoints();
    -- FocusFrameToTManaBar:SetPoint("TOPLEFT", 43, -25);
    -- FocusFrameToTManaBar:SetHeight(5);
end
hooksecurefunc("TargetofTarget_Update", whoaFrameToTF)
hooksecurefunc("TargetFrame_CheckClassification", whoaFrameToTF)

local function ToTDarkFrameSelector()
	if ( cfg.darkFrames == true ) then
		TargetFrameToTTextureFrameTexture:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\dark\\UI-TargetofTargetFrame");
	elseif ( cfg.darkFrames == false ) then
		TargetFrameToTTextureFrameTexture:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\light\\UI-TargetofTargetFrame");
	end
end
hooksecurefunc("TargetofTarget_Update", ToTDarkFrameSelector)
hooksecurefunc("TargetFrame_CheckClassification", ToTDarkFrameSelector)



--	Boss target frames.
-- function whoaBossFrames()
	-- for i = 1, MAX_BOSS_FRAMES do
		-- _G["Boss"..i.."TargetFrameTextureFrameDeadText"]:ClearAllPoints();
		-- _G["Boss"..i.."TargetFrameTextureFrameDeadText"]:SetPoint("CENTER",_G["Boss"..i.."TargetFrameHealthBar"],"CENTER",0,0);
		-- _G["Boss"..i.."TargetFrameTextureFrameName"]:ClearAllPoints();
		-- _G["Boss"..i.."TargetFrameTextureFrameName"]:SetPoint("CENTER",_G["Boss"..i.."TargetFrameManaBar"],"CENTER",0,0);
		-- _G["Boss"..i.."TargetFrameTextureFrameTexture"]:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\UI-UNITFRAME-BOSS");
		-- _G["Boss"..i.."TargetFrameNameBackground"]:Hide();
		-- _G["Boss"..i.."TargetFrameHealthBar"]:SetSize(116,18);
		-- _G["Boss"..i.."TargetFrameHealthBar"]:ClearAllPoints();
		-- _G["Boss"..i.."TargetFrameHealthBar"]:SetPoint("CENTER",_G["Boss"..i.."TargetFrame"],"CENTER",-51,18);
		-- _G["Boss"..i.."TargetFrameManaBar"]:SetSize(116,18);
		-- _G["Boss"..i.."TargetFrameManaBar"]:ClearAllPoints();
		-- _G["Boss"..i.."TargetFrameManaBar"]:SetPoint("CENTER",_G["Boss"..i.."TargetFrame"],"CENTER",-51,-3);
		-- _G["Boss"..i.."TargetFrameTextureFrameHealthBarTextLeft"]:ClearAllPoints();
		-- _G["Boss"..i.."TargetFrameTextureFrameHealthBarTextLeft"]:SetPoint("LEFT",_G["Boss"..i.."TargetFrameHealthBar"],"LEFT",0,0);
		-- _G["Boss"..i.."TargetFrameTextureFrameHealthBarTextRight"]:ClearAllPoints();
		-- _G["Boss"..i.."TargetFrameTextureFrameHealthBarTextRight"]:SetPoint("RIGHT",_G["Boss"..i.."TargetFrameHealthBar"],"RIGHT",0,0);
		-- _G["Boss"..i.."TargetFrameTextureFrameHealthBarText"]:ClearAllPoints();
		-- _G["Boss"..i.."TargetFrameTextureFrameHealthBarText"]:SetPoint("CENTER",_G["Boss"..i.."TargetFrameHealthBar"],"CENTER",0,0);
		-- _G["Boss"..i.."TargetFrameTextureFrameManaBarTextLeft"]:ClearAllPoints();
		-- _G["Boss"..i.."TargetFrameTextureFrameManaBarTextLeft"]:SetPoint("LEFT",_G["Boss"..i.."TargetFrameManaBar"],"LEFT",0,0);
		-- _G["Boss"..i.."TargetFrameTextureFrameManaBarTextRight"]:ClearAllPoints();
		-- _G["Boss"..i.."TargetFrameTextureFrameManaBarTextRight"]:SetPoint("RIGHT",_G["Boss"..i.."TargetFrameManaBar"],"RIGHT",0,0);
		-- _G["Boss"..i.."TargetFrameTextureFrameManaBarText"]:ClearAllPoints();
		-- _G["Boss"..i.."TargetFrameTextureFrameManaBarText"]:SetPoint("CENTER",_G["Boss"..i.."TargetFrameManaBar"],"CENTER",0,0);
	-- end
-- end
-- whoaBossFrames();

-- function whoaBossFramesText()
		-- for i = 1, MAX_BOSS_FRAMES do
			-- _G["Boss"..i.."TargetFrameTextureFrameManaBarTextLeft"]:SetText(" ");
			-- _G["Boss"..i.."TargetFrameTextureFrameManaBarTextRight"]:SetText(" ");
			-- _G["Boss"..i.."TargetFrameTextureFrameManaBarText"]:SetText(" ");
		-- end
-- end
-- hooksecurefunc("TextStatusBar_UpdateTextStringWithValues", whoaBossFramesText)