whoa = {}
cfg = {}

local whoaThFaddon = IsAddOnLoaded("whoaThickFrames_Classic");
local rmhAddon = IsAddOnLoaded("RealMobHealth");
local mi2addon = IsAddOnLoaded("MobInfo2-Classic");
local lortiUIaddon = IsAddOnLoaded("Lorti-UI-Classic");

function whoaSetDefaults()
	if (cfg.smallAuraSize == nil)	then cfg.smallAuraSize = 20;	end
	if (cfg.largeAuraSize == nil)	then cfg.largeAuraSize = 25;	end
	if (cfg.classColor == nil)		then cfg.classColor = true; end
	if (cfg.reactionColor == nil)	then cfg.reactionColor = true; end
	if (cfg.BlizzardReactionColor == nil) then cfg.BlizzardReactionColor = false; end
	if (cfg.noClickFrame == nil)	then cfg.noClickFrame = false;	end
	if (cfg.blueShaman == nil)		then cfg.blueShaman = true; end		-- blueShamans
	if (cfg.usePartyFrames == nil)	then cfg.usePartyFrames = false;	end
	if (cfg.styleFont == nil)		then cfg.styleFont = true; end
	if (cfg.bigAuras == nil)		then cfg.bigAuras = true; end
	if (cfg.useBossFrames == nil)	then cfg.useBossFrames = false; end
	if (cfg.whoaTexture == nil)		then cfg.whoaTexture = true; end
	if (cfg.darkFrames == nil)		then cfg.darkFrames = false;	end
end
whoaSetDefaults();

-- CreateFont --
function whoa:CreateFont(frame, name, text, x, y, font, size )
	if size == nil then size = 15 end
	if font == nil then font = STANDARD_TEXT_FONT end
	
	local fontString = frame:CreateFontString(name) fontString:SetPoint("TOPLEFT", x, y) fontString:SetFont(font, size, "") fontString:SetText(text)
	return (fontString)
end

--	Checkbutton factory.
local uniquealyzer = 1;
function createCheckbutton(parent, x_loc, y_loc, displayname)
	uniquealyzer = uniquealyzer + 1;
	local checkbutton = CreateFrame("CheckButton", "whoaCheckButton" .. uniquealyzer, parent, "ChatConfigCheckButtonTemplate");
	checkbutton:SetPoint("TOPLEFT", x_loc, y_loc);
	getglobal(checkbutton:GetName() .. 'Text'):SetText(displayname);
	return checkbutton;
end

-- CreateButton --
function whoa:CreateButton(frame, name, text, width, height, x, y, template)
	if (template == nil) then template = "OptionsButtonTemplate"
	end
	local button = CreateFrame("Button", name, frame, template) button:SetPoint("TOPLEFT", x, y) button:SetWidth(width)
	button:SetHeight(height) button:SetText(text)
	return (button)
end

--	UI panel.
whoaUI = {}
whoaUI.panel = CreateFrame( "Frame", "whoaUI", UIParent );
whoaUI.panel.name = "whoa UnitFrames";
InterfaceOptions_AddCategory(whoaUI.panel);

local title = whoa:CreateFont(whoaUI.panel, "title", "whoa UnitFrames v1.3.2", 15, -18, font, 15)
title:SetFontObject(GameFontNormal) 
title:SetPoint("LEFT",whoaUI.panel,"TOPLEFT",0,0)

local disclaimer = whoa:CreateFont(whoaUI.panel, "disclaimer", "Most options require a /reload in order to correctly apply the changes.", 25, -40, font, 12)
disclaimer:SetPoint("LEFT",whoaUI.panel,"TOPLEFT",0,0)
	
--	UI panel
function whoa:CreateUI(frame)
	local xOffset = -80;
	
	local mainOptions = whoa:CreateFont(whoaUI.panel, "mainOptions", "Main frames options.", 25, xOffset, font, 13)
	mainOptions:SetPoint("LEFT",whoaUI.panel,"TOPLEFT",0,0)
	
	--	Players class colored HP.
	myCheckButton = createCheckbutton(whoaUI.panel, 40, xOffset-30, " Players class colors.");
	myCheckButton.tooltip = "Displays class colored HP bars for player frame and targeted players frames.";
	myCheckButton:SetScript("OnClick",
	function(self)
		-- if whoaCheckButton2:GetChecked() then
		if (cfg.classColor == false) then
			cfg.classColor = true;
			PlayerFrame:Hide();
			PlayerFrame:Show();
		else
			cfg.classColor = false;
			PlayerFrame:Hide();
			PlayerFrame:Show();
		end
	end );

	--	Unit reaction color HP.
	myCheckButton = createCheckbutton(whoaUI.panel, 40, xOffset-60, " Target reaction colors.");
	myCheckButton.tooltip = "Displays reaction colors on non-player enemies HP bars.";
	myCheckButton:SetScript("OnClick",
	function(self)
			if (cfg.reactionColor == true) then
				cfg.reactionColor = false;
				cfg.BlizzardReactionColor = false;
				whoaCheckButton4:SetChecked(false)
			elseif (cfg.reactionColor == false) then
				cfg.reactionColor = true;
			end
	end );
	
	--	Unit bright reaction color HP.
	myCheckButton = createCheckbutton(whoaUI.panel, 280, xOffset-60, " Bright reaction colors.");
	myCheckButton.tooltip = "Displays bright reaction colors on non-player enemies HP bars.";
	myCheckButton:SetScript("OnClick",
	function(self)
		if (cfg.BlizzardReactionColor == true) then
			cfg.BlizzardReactionColor = false;
		elseif (cfg.BlizzardReactionColor == false) then
			cfg.BlizzardReactionColor = true;
			cfg.reactionColor = true;
			whoaCheckButton3:SetChecked(true)
		end
	end );
	
	--	Enlarge auras.
	myCheckButton = createCheckbutton(whoaUI.panel, 40, xOffset-90, " Enlarge auras.");
	myCheckButton.tooltip = "Displays bigger debuffs on enemy frames and buffs on allied frames to 4 in a row.";
	myCheckButton:SetScript("OnClick",
	function(self)
		if (cfg.bigAuras == false) then
			cfg.bigAuras = true;
		else
			cfg.bigAuras = false;
		end
	end );
	
	local styleOptions = whoa:CreateFont(whoaUI.panel, "styleOptions", "Styling options.", 25, xOffset-140, font, 13)
	styleOptions:SetPoint("LEFT",whoaUI.panel,"TOPLEFT",0,0)


	--	Dark Frames
	myCheckButton = createCheckbutton(whoaUI.panel, 40, xOffset-170, " Enable dark frames.");
	-- myCheckButton:SetEnabled(false);
	myCheckButton.tooltip = "Enables dark textures frames for dark themed ui.";
	myCheckButton:SetScript("OnClick",
	function(self)
		if (cfg.darkFrames == true) then
			cfg.darkFrames = false;
		else
			cfg.darkFrames = true;
		end
	end );
		
	--	Blizzard status text.
	myCheckButton = createCheckbutton(whoaUI.panel, 40, xOffset-200, " Use Blizzard default status bar text.");
	-- myCheckButton:SetEnabled(false);
	myCheckButton.tooltip = "Displays Blizzard´s default font style for player and target frames status text.";
	myCheckButton:SetScript("OnClick",
	function(self)
		if (cfg.styleFont == true) then
			cfg.styleFont = false;
		else
			cfg.styleFont = true;
		end
	end );
		
	-- whoa custom statusbar texture.
	myCheckButton = createCheckbutton(whoaUI.panel, 40, xOffset-230, " Use Blizzard´s default status bar texture.");
	myCheckButton.tooltip = "Use Blizzard´s default health and mana bar texture.";
	myCheckButton:SetScript("OnClick",
	function(self)
		-- if whoaCheckButton6:GetChecked() then
		if (cfg.whoaTexture == false) then
			cfg.whoaTexture = true;
		else
			cfg.whoaTexture = false;
		end
	end );			

	local otherOptions = whoa:CreateFont(whoaUI.panel, "otherOptions", "Other extra options.", 25, xOffset-280, font, 13)
	otherOptions:SetPoint("LEFT",whoaUI.panel,"TOPLEFT",0,0)
	
	--	Unclikeable frames
	myCheckButton = createCheckbutton(whoaUI.panel, 40, xOffset-310, "Disable mouse clicks over player and target frames.");
	-- myCheckButton:SetEnabled(false);
	myCheckButton.tooltip = "Disable mouse clicks over player and target frames.";
	myCheckButton:SetScript("OnClick",
	function(self)
		if (cfg.noClickFrame == false) then
			cfg.noClickFrame = true;
		else
			cfg.noClickFrame = false;
		end
	end );
	
	-- --	whoa Party frames.
	-- myCheckButton = createCheckbutton(whoaUI.panel, 40, xOffset-120, "whoa´s party frame style.");
	-- -- myCheckButton:SetEnabled(false);
	-- myCheckButton.tooltip = "Use whoa´s party frames style when not using Compact Raid Frames. Works for whoa´s and Blizzard´s default frames.";
	-- myCheckButton:SetScript("OnClick",
	-- function(self)
		-- -- if whoaCheckButton5:GetChecked() then
		-- if (cfg.usePartyFrames == false) then
			-- cfg.usePartyFrames = true;
		-- else
			-- cfg.usePartyFrames = false;
		-- end
	-- end );
	
	-- local fancyOptions = whoa:CreateFont(whoaUI.panel, "fancyOptions", "Other fancy options.", 15, xOffset-160, font, 12)
	-- fancyOptions:SetPoint("LEFT",whoaUI.panel,"TOPLEFT",0,0)
	

	

		
	-- --	Old threat numeric indicator.
	-- myCheckButton = createCheckbutton(whoaUI.panel, 40, xOffset-250, "Classic pink color for Shamans.");
	-- -- myCheckButton:SetEnabled(false);
	-- myCheckButton.tooltip = "Sets Shamans class color to pink.";
	-- myCheckButton:SetScript("OnClick",
	-- function(self)
		-- if (cfg.blueShaman == false) then
			-- cfg.blueShaman = true;
		-- else
			-- cfg.blueShaman = false;
		-- end
	-- end );
	

end

SlashCmdList.whoaUI = function()
	InterfaceOptionsFrame_OpenToCategory(whoaUI.panel)
	InterfaceOptionsFrame_OpenToCategory(whoaUI.panel)
end
SLASH_whoaUI1 = "/whoaUI"
SLASH_whoaUI1 = "/wuf"
SlashCmdList['RELOAD'] = function() ReloadUI() end
LASH_RELOAD1 = '/rl'

whoa:CreateUI()
--	Events
function whoa:Init(event, addon, ...)
	if (cfg.classColor == true) then
		whoaCheckButton2:SetChecked(true)
	end
	if ( cfg.reactionColor == true ) then
		whoaCheckButton3:SetChecked(true)
	end
	if ( cfg.BlizzardReactionColor == true ) then
		whoaCheckButton4:SetChecked(true)
	end
	if ( cfg.bigAuras == true) then
		whoaCheckButton5:SetChecked(true)
	end
	if ( cfg.darkFrames == true) then
		whoaCheckButton6:SetChecked(true)
	end
	if ( cfg.styleFont == false) then
		whoaCheckButton7:SetChecked(true)
	end
	if ( cfg.whoaTexture == false) then
		whoaCheckButton8:SetChecked(true)
	end
	if ( cfg.noClickFrame == true) then
		whoaCheckButton9:SetChecked(true)
	end
	-- if ( cfg.usePartyFrames == true) then
		-- whoaCheckButton7:SetChecked(true)
	-- end	
	-- if ( cfg.blueShaman == false) then
		-- whoaCheckButton10:SetChecked(true)
	-- end
	-- if ( cfg.useBossFrames == true) then
		-- whoaCheckButton9:SetChecked(false)
	-- end
	if (event == "ADDON_LOADED" and addon == "whoaUnitFrames_Classic") then
		if rmhAddon then
			print("|cff00ccff[whoa UnitFrames]:|cff00ff00 RealMobHealth detected.");
		end
		if mi2addon then
			print("|cff00ccff[whoa UnitFrames:|cff00ff00 MobInfo2 detected.");
		end
		if whoaThFaddon then
			print("|cff00ccff[whoa UnitFrames]:|cffff0000 Whoa ThickFrames detected. |cffffffffPlease enable just one of both addons.");
		end
		if lortiUIaddon then
			print("|cff00ccff[whoa UnitFrames]:|cffffff00 Lorti-UI-Classic detected. |cffffffffMake sure to enable whoa´s dark frames with /wtf to match with LortiUI.");
		end
		print("|cff00ccff[whoa UnitFrames] |cffffffffis now |cff00ff00loaded. |cffffffffUse |cffffff00'/wuf' |cffffffff open options.")
	end
	
	if (cfg.noClickFrame == true) then
		if (event == "PLAYER_ENTERING_WORLD") then
			PlayerFrame:SetMouseClickEnabled(false);
			PetFrame:SetMouseClickEnabled(false);
			TargetFrame:SetMouseClickEnabled(false)
		elseif (event == "PLAYER_TARGET_CHANGED") then
			-- TargetFrame:SetMouseClickEnabled(false);
			if UnitExists("target") then
				TargetFrameToTFrame:SetMouseClickEnabled(false);
			end
		end
	end
end
-- create addon frame
local whoaUI = CreateFrame("Frame", "whoaUI", UIParent)
whoaUI:SetScript("OnEvent", whoa.Init)
whoaUI:RegisterEvent("ADDON_LOADED")
whoaUI:RegisterEvent("PLAYER_ENTERING_WORLD")