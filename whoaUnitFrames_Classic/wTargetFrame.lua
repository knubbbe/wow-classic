--	Target frame
local function targetFrame (self, forceNormalTexture)
	local classification = UnitClassification(self.unit);
	self.highLevelTexture:ClearAllPoints();
	self.highLevelTexture:SetPoint("CENTER", self.levelText, "CENTER", 1,0);
	self.deadText:SetPoint("CENTER", self.healthbar, "CENTER",0,0);
	self.unconsciousText:SetPoint("CENTER", self.manabar, "CENTER",0,0);
	self.nameBackground:Hide();
	self.name:SetPoint("LEFT", self, 15, 36);
	self.healthbar:SetSize(119, 18);
	self.healthbar:SetPoint("TOPLEFT", 5, -24);
	self.manabar:SetPoint("TOPLEFT", 5, -45);
	self.manabar:SetSize(119, 18);
	if not mi2addon then
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
hooksecurefunc("TargetFrame_CheckClassification", targetFrame)

local function targetFrameSelector (self, forceNormalTexture)
	local classification = UnitClassification(self.unit);
	local path = "Interface\\Addons\\whoaUnitFrames_Classic\\media\\light\\";
	if (cfg.darkFrames == true) then
		path = "Interface\\Addons\\whoaUnitFrames_Classic\\media\\dark\\"
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
hooksecurefunc("TargetFrame_CheckClassification", targetFrameSelector)

local function targetFontStyle (self)
	if not mi2addon and (cfg.styleFont) then
		self.healthbar.LeftText:SetFontObject(SystemFont_Outline_Small);
		self.healthbar.RightText:SetFontObject(SystemFont_Outline_Small);
		self.manabar.LeftText:SetFontObject(SystemFont_Outline_Small);
		self.manabar.RightText:SetFontObject(SystemFont_Outline_Small);
		self.healthbar.TextString:SetFontObject(SystemFont_Outline_Small);
		self.manabar.TextString:SetFontObject(SystemFont_Outline_Small);
	end
end
hooksecurefunc("TargetFrame_CheckClassification", targetFontStyle)

-- Mana texture
local function manabarTexture (manaBar)
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
hooksecurefunc("UnitFrameManaBar_UpdateType", manabarTexture)

--	ToT
local function totFrame()
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
end
hooksecurefunc("TargetofTarget_Update", totFrame)
hooksecurefunc("TargetFrame_CheckClassification", totFrame)

local function totFrameSelector()
	if ( cfg.darkFrames == true ) then
		TargetFrameToTTextureFrameTexture:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\dark\\UI-TargetofTargetFrame");
	elseif ( cfg.darkFrames == false ) then
		TargetFrameToTTextureFrameTexture:SetTexture("Interface\\Addons\\whoaUnitFrames_Classic\\media\\light\\UI-TargetofTargetFrame");
	end
end
hooksecurefunc("TargetofTarget_Update", totFrameSelector)
hooksecurefunc("TargetFrame_CheckClassification", totFrameSelector)