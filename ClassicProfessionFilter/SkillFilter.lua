local CPF, C, L = unpack(select(2, ...))
local MODULE_NAME = "SkillFilter"

--[===[@debug@
print(CPF.ADDON_NAME, MODULE_NAME)
--@end-debug@]===]


---------------------------------------------
-- CONSTANTS
---------------------------------------------
local BUTTON_HEIGHT = 16
local BUTTON_MARGIN = 0


---------------------------------------------
-- VARIABLES
---------------------------------------------
local previousTradeSkillName = nil


---------------------------------------------
-- UTILITIES
---------------------------------------------
function trim(str)
   return (str:gsub("^%s*(.-)%s*$", "%1"))
end


---------------------------------------------
-- SEARCH BAR
---------------------------------------------
local function applyFilter(filter)
    local filtered = {}
    local currentHeader = nil
    local currentHeaderIncluded = false
    local currentSelectedSkillIncluded = false
    local firstNonHeaderIndexIncluded = 0 -- used to identify the index of the top of the list

    for i = 1, GetNumTradeSkills(), 1 do
        local skillName, skillType = GetTradeSkillInfo(i)
        if ( skillType == "header" ) then
            currentHeader = {i, GetTradeSkillInfo(i)}
            currentHeaderIncluded = false
            -- add header if it matches filter
            if ( CPF:strmatch(currentHeader[2]:lower(), filter) ) then
                tinsert(filtered, currentHeader)
                currentHeaderIncluded = true
            end
        elseif ( ( currentHeader and CPF:strmatch(currentHeader[2]:lower(), filter) )
                    or CPF:strmatch(skillName:lower(), filter) ) then
            -- add header if it wasn't already added (can't add a skill without its header)
            if ( not currentHeaderIncluded ) then
                tinsert(filtered, currentHeader)
                currentHeaderIncluded = true
            end
            tinsert(filtered, {i, GetTradeSkillInfo(i)})
            firstNonHeaderIndexIncluded = firstNonHeaderIndexIncluded == 0 and i or firstNonHeaderIndexIncluded
            currentSelectedSkillIncluded = currentSelectedSkillIncluded or GetTradeSkillSelectionIndex() == i
        end
    end

    CPF:debugf("Filtered %d skills (%d remaining)", GetNumTradeSkills()-#filtered, #filtered)

    -- move selection if current selection is omitted
    if ( not currentSelectedSkillIncluded and firstNonHeaderIndexIncluded > 0 ) then
        CPF:debug("Moving selected skill to #", firstNonHeaderIndexIncluded, GetTradeSkillInfo(firstNonHeaderIndexIncluded))
        TradeSkillFrame_SetSelection(firstNonHeaderIndexIncluded)
    end

    return filtered
end

local function showFilteredSkills()
    if ( not TradeSkillFrame:IsVisible() or GetNumTradeSkills() == 0 ) then
        return
    end

    -- Hide blizzard default filters
    TradeSkillInvSlotDropDown:Hide()
    TradeSkillSubClassDropDown:Hide()

    -- Get the current list of filtered skills
    local filter = trim(TradeSkillFrame.SearchBox:GetText():lower())
    local isFiltering = filter ~= ""

    local skills = applyFilter(filter)

    -- Display the filtered skill buttons
    local numTradeSkills = #skills
    local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame);
    if ( numTradeSkills == 0 ) then
        TradeSkillFrameTitleText:SetText(format(TRADE_SKILL_TITLE, GetTradeSkillLine()));
        TradeSkillSkillName:Hide();
        TradeSkillSkillIcon:Hide();
        TradeSkillRequirementLabel:Hide();
        TradeSkillRequirementText:SetText("");
        TradeSkillCollapseAllButton:Disable();
        for i=1, MAX_TRADE_SKILL_REAGENTS, 1 do
            getglobal("TradeSkillReagent"..i):Hide();
        end
    else
        TradeSkillSkillName:Show();
        TradeSkillSkillIcon:Show();
        TradeSkillCollapseAllButton:Enable();
    end

    FauxScrollFrame_Update(TradeSkillListScrollFrame, numTradeSkills, TRADE_SKILLS_DISPLAYED, TRADE_SKILL_HEIGHT, nil, nil, nil, TradeSkillHighlightFrame, 293, 316 );

    TradeSkillHighlightFrame:Hide();
    for i=1, TRADE_SKILLS_DISPLAYED, 1 do
        local index = i + skillOffset;
        local skillButton = getglobal("TradeSkillSkill"..i);
        if ( index <= numTradeSkills ) then
            if ( skills[index] == nil ) then
                print("nil case", i, index)
            end
            local skillIndex, skillName, skillType, numAvailable, isExpanded = unpack(skills[index]);

            -- Set button widths if scrollbar is shown or hidden
            if ( TradeSkillListScrollFrame:IsVisible() ) then
                skillButton:SetWidth(293);
            else
                skillButton:SetWidth(323);
            end
            local color = TradeSkillTypeColor[skillType];
            if ( color ) then
                skillButton:SetNormalFontObject(color.font);
            end

            skillButton:SetID(skillIndex);
            skillButton:Show();
            -- Handle headers
            if ( skillType == "header" ) then
                skillButton:SetText(skillName);
                if ( isExpanded ) then
                    skillButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
                    skillButton:SetDisabledTexture("Interface\\Buttons\\UI-MinusButton-Disabled");
                else
                    skillButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
                    skillButton:SetDisabledTexture("Interface\\Buttons\\UI-PlusButton-Disabled");
                end
                skillButton:SetEnabled(not isFiltering)
                getglobal("TradeSkillSkill"..i.."Highlight"):SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
                getglobal("TradeSkillSkill"..i):UnlockHighlight();
            else
                if ( not skillName ) then
                    return;
                end
                skillButton:SetNormalTexture("");
                skillButton:SetDisabledTexture("");
                skillButton:Enable()
                getglobal("TradeSkillSkill"..i.."Highlight"):SetTexture("");
                if ( numAvailable == 0 ) then
                    skillButton:SetText(" "..skillName);
                else
                    skillButton:SetText(" "..skillName.." ["..numAvailable.."]");
                end

                -- Place the highlight and lock the highlight state
                if ( GetTradeSkillSelectionIndex() == skillIndex ) then
                    TradeSkillHighlightFrame:SetPoint("TOPLEFT", "TradeSkillSkill"..i, "TOPLEFT", 0, 0);
                    TradeSkillHighlightFrame:Show();
                    getglobal("TradeSkillSkill"..i):LockHighlight();
                else
                    getglobal("TradeSkillSkill"..i):UnlockHighlight();
                end
            end

        else
            skillButton:Hide();
        end
    end

    -- Set the expand/collapse all button texture
    local numHeaders = 0;
    local notExpanded = 0;
    for i=1, numTradeSkills, 1 do
        if ( skills[i] == nil ) then
            print("nil case", i)
        end
        local skillIndex, skillName, skillType, numAvailable, isExpanded = unpack(skills[i]);
        if ( skillName and skillType == "header" ) then
            numHeaders = numHeaders + 1;
            if ( not isExpanded ) then
                notExpanded = notExpanded + 1;
            end
        end
        if ( GetTradeSkillSelectionIndex() == skillIndex ) then
            -- Set the max makeable items for the create all button
            TradeSkillFrame.numAvailable = numAvailable;
        end
    end
    -- If all headers are not expanded then show collapse button, otherwise show the expand button
    if ( notExpanded ~= numHeaders ) then
        TradeSkillCollapseAllButton.collapsed = nil;
        TradeSkillCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
        TradeSkillCollapseAllButton:SetDisabledTexture("Interface\\Buttons\\UI-MinusButton-Disabled")
    else
        TradeSkillCollapseAllButton.collapsed = 1;
        TradeSkillCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
        TradeSkillCollapseAllButton:SetDisabledTexture("Interface\\Buttons\\UI-PlusButton-Disabled")
    end
    if ( isFiltering) then
        TradeSkillCollapseAllButton:Disable();
    end
end

local function expandAllHeadersWhenFiltering()
    local filter = trim(TradeSkillFrame.SearchBox:GetText():lower())
    local isFiltering = filter ~= ""

    if ( isFiltering ) then
        ExpandTradeSkillSubClass(0) -- expand all
    end
end

local function resetFilterOnTradeSkillChange()
    if ( not TradeSkillFrame:IsVisible() ) then
        return
    end
    if ( previousTradeSkillName ~= GetTradeSkillLine() ) then
        previousTradeSkillName = GetTradeSkillLine();
        TradeSkillFrame.SearchBox:SetText("")
    end
end


---------------------------------------------
-- INITIALIZE
---------------------------------------------
CPF.RegisterCallback(MODULE_NAME, "initialize", function()
    CPF:InitializeOnDemand("Blizzard_TradeSkillUI", function()
        -- Create search bar
        TradeSkillFrame.SearchBox = CreateFrame("EditBox", nil, TradeSkillFrame, "ClassicProfessionFilterSearchBoxTemplate")
        TradeSkillFrame.SearchBox:SetPoint("BOTTOMRIGHT", TradeSkillListScrollFrame, "TOPRIGHT", 23, 3)
        TradeSkillFrame.SearchBox:Show()

        -- Reset filter when change to new skill without closing window
        CPF.RegisterEvent(MODULE_NAME, "TRADE_SKILL_UPDATE", resetFilterOnTradeSkillChange)

        -- Hook displaying to use filters
        hooksecurefunc("TradeSkillFrame_Update", showFilteredSkills)

        -- Expand all headers when we start filtering
        TradeSkillFrame.SearchBox:HookScript("OnTextChanged", expandAllHeadersWhenFiltering)

        -- Apply filter OnTextChanged
        TradeSkillFrame.SearchBox:HookScript("OnTextChanged", showFilteredSkills)
    end)
end)
