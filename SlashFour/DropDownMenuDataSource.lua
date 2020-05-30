local _, Addon = ...

-- Util

local function predicateWithValue(value, func) -- value is optional and can be omitted eniterly when calling
    --if not func then func = value end
    local predicate = {
        b = value,
        eval = func,
    }
    setmetatable(predicate, {
        __call = function(self, a)
            return self.eval(a, self.b)
        end,
    })
    return predicate
end
local function compoundPredicate(predicate1, predicate2, func)
    local predicate = {
        p1 = predicate1,
        p2 = predicate2,
        eval = func,
    }
    setmetatable(predicate, {
        __call = function(self, a)
            return self.eval(self.p1(a), self.p2(a))
        end,
    })
    return predicate
end
local function notPredicate(predicate)
    local notPredicate = {
        b = predicate.b,
        eval = predicate.eval,
    }
    setmetatable(notPredicate, {
        __call = function(self, a)
            return not self.eval(a, self.b)
        end,
    })
    return notPredicate
end

local predicates = {
    TRUE = function()
        return true
    end,
    FALSE = function()
        return false
    end,
    NOT = function(a)
        return not a
    end,
    AND = function(a, b)
        return a and b
    end,
    OR = function(a, b)
        return a or b
    end,

	isEqual = function(a, b)
		return a == b
    end,
    isNil = function(a)
		return a == nil
	end,
    isEmpty = function(a)
        return #a == 0
    end,
    isMember = function(a, b)
        for k, v in pairs(b) do
            if v == a then
                return true
            end
        end
    end,
}



-- TagsDataSource

local tagPredicates = {
    isDungeon = function(tag)
		return tag.category == "dungeon"
    end,
    isRaid = function(tag)
		return tag.category == "raid"
    end,
    isBattleground = function(tag)
		return tag.category == "battleground"
    end,
    isActive = function(tag)
        return #tag.players > 0
    end,
    isLevelAppropriate = function(tag)
		return Addon:IsLevelAppropriate(tag.minLevel, tag.maxLevel, tag.reqLevel)
	end,
}


local filterForName = {
    ["Dungeons"] =      {predicate = predicateWithValue(nil, tagPredicates.isDungeon),      operator = "AND"},
    ["Raids"] =         {predicate = predicateWithValue(nil, tagPredicates.isRaid),         operator = "AND"},
    ["Battlegrounds"] = {predicate = predicateWithValue(nil, tagPredicates.isBattleground), operator = "AND"},
    --
    -- for the following two filters, the predicate is set to whichever of the three filters above is active
    ["All"] =           {predicate = nil, operator = "OR"},
    -- "None" is a hidden filter that becomes active when "All", "Active" & "Recommended" are all disabled/unchecked/unactive
    ["None"] =          {predicate = nil, operator = "NOT"},
    --
    ["Active"] =        {predicate = predicateWithValue(nil, tagPredicates.isActive),           operator = "AND"},
    ["Recommended"] =   {predicate = predicateWithValue(nil, tagPredicates.isLevelAppropriate), operator = "AND"},
    --
}
filterForName["All"].predicate = filterForName["Dungeons"].predicate
filterForName["None"].predicate = filterForName["Dungeons"].predicate



local activePredicates = {
    NOT = {},
    AND = {},
    OR = {},
}


local function activeFilters()
    local activeFilters = {}
    for filterName, filter in pairs(filterForName) do
        if activePredicates[filter.operator][filter.predicate] ~= nil then
            tinsert(activeFilters, filterName)
        end
    end
    return activeFilters
end


local DesaturateChecks
function Addon:Refilter(onlyData)
    local func = function()
        return tFilterWithPredicates(Addon.tags, activePredicates.NOT, activePredicates.AND, activePredicates.OR)
    end
    Addon:SetDataSourceFunc(func)

    if onlyData then return end

    --
    ScrollListDataSource_ClearCache()
	if LFGFrame.scrollFrame.isInitialized then
        LFGFrame.scrollFrame.update()
    end
    --
    UIDropDownMenu_RefreshAll(LFGFrameDropDownMenu41)
    DesaturateChecks(DropDownList1)
    UIDropDownMenu_SetText(LFGFrameDropDownMenu41, table.concat(activeFilters()," "))
end
local function ResetFilters()
    wipe(activePredicates.NOT)
    wipe(activePredicates.AND)
    wipe(activePredicates.OR)
end
local function PrintActivePredicatesCount()
    local NOTcounter = 0
    local ANDcounter = 0
    local ORcounter = 0
    for _, v in pairs(activePredicates.NOT) do
        if v ~= nil then
            NOTcounter = NOTcounter+1
        end
    end
    for _, v in pairs(activePredicates.AND) do
        if v ~= nil then
            ANDcounter = ANDcounter+1
        end
    end
    for _, v in pairs(activePredicates.OR) do
        if v ~= nil then
            ORcounter = ORcounter+1
        end
    end
    print(NOTcounter, "NOT", ANDcounter, "AND", ORcounter, "OR")
end

local function IsFilterActive(name)
    local filter = filterForName[name]
    -- 2 users reported a crash caused by 'filter' being nil. Unsure what circumstance this occurs in. Maybe caused by rogue DropDownMenu code?
    if filter then
        return activePredicates[filter.operator][filter.predicate] ~= nil
    end
end
local function SetFilterActive(name, active)
    local filter = filterForName[name]
    if active then
        activePredicates[filter.operator][filter.predicate] = filter.predicate
    else
        activePredicates[filter.operator][filter.predicate] = nil
    end
end



local predicatesForTag = {}
local function predicateForTag(tag)
    local predicate = predicatesForTag[tag]
    if predicate then
        return predicate
    end

    local newPredicate = predicateWithValue(tag, predicates.isEqual)
    predicatesForTag[tag] = newPredicate
    return newPredicate
end

local function ResetActivatedTags()
    for tag, predicate in pairs(predicatesForTag) do
        for key, _ in pairs(activePredicates) do -- go through NOT, AND, OR
            activePredicates[key][predicate] = nil
        end
    end
    -- change operator of All filter back to OR
    --local allIsActive = IsFilterActive("All")
    --SetFilterActive("All", false)
    --filterForName["All"].operator = "OR"
    --SetFilterActive("All", allIsActive)
end



-- LFGFrameDropDownMenuDataSource

DesaturateChecks = function(parent)
    --print(parent:GetName(), LFGFrame.drowDownMenu)
    for level=UIDROPDOWNMENU_MENU_LEVEL, UIDROPDOWNMENU_MAXLEVELS do
        local list = _G["DropDownList"..level]
        if list == parent then
            for i=1, UIDROPDOWNMENU_MAXBUTTONS do
                local button = _G["DropDownList"..level.."Button"..i]
                local check = _G[button:GetName().."Check"];
                local uncheck = _G[button:GetName().."UnCheck"];

                -- update player count for tag buttons
                --[[
                if button.value then -- our filter buttons don't have .value, only the tag buttons
                    if button.value.players then
                        button.arg1 = #button.value.players
                    end
                end
                ]]--

                if button.arg1 == 0 then -- set to #tag.players in init below
                    check:SetDesaturated(true);
                    check:SetAlpha(0.5);
                    uncheck:SetDesaturated(true);
                    uncheck:SetAlpha(0.5);
                else
                    check:SetDesaturated(false);
                    check:SetAlpha(1);
                    uncheck:SetDesaturated(false);
                    uncheck:SetAlpha(1);
                end
            end
        end
    end
end

local function SetCategory(categoryName)
    -- blow away any prior filters when switching category
    ResetFilters()

    -- these three are mutually exclusive
    SetFilterActive("Dungeons", "Dungeons" == categoryName)
    SetFilterActive("Raids", "Raids" == categoryName)
    SetFilterActive("Battlegrounds", "Battlegrounds" == categoryName)

    -- for the following two filters, the predicate is set to whichever of the three filters above is active
    filterForName["All"].predicate = filterForName[categoryName].predicate
    filterForName["None"].predicate = filterForName[categoryName].predicate

    -- default to All when switching category (this is "CategoryButtonClicked" afterall)
    SetFilterActive("All", true)

    -- "None" is a hidden filter that becomes active when "All", "Active" & "Recommended" are all disabled/unchecked/unactive
    local showNone = not (IsFilterActive("All") or IsFilterActive("Active") or IsFilterActive("Recommended"))
    SetFilterActive("None", showNone)
end
local function ToggleFilter(filterName)
    -- disregard/reset "custom modifications" done to the filter by the user clicking individual tags
    ResetActivatedTags()

    SetFilterActive(filterName, not IsFilterActive(filterName))

    -- Active & Recommended are mutually exclusive with All
    if filterName == "Active" or filterName == "Recommended" then
        SetFilterActive("All", false)
    elseif filterName == "All" then
        SetFilterActive("Active", false)
        SetFilterActive("Recommended", false)
    end

    -- "None" is a hidden filter that becomes active when "All", "Active" & "Recommended" are all disabled/unchecked/unactive
    local showNone = not (IsFilterActive("All") or IsFilterActive("Active") or IsFilterActive("Recommended"))
    SetFilterActive("None", showNone)
end


local function LFGFrameDropDownListButton_CategoryButtonClicked(self) -- self, arg1, arg2, checked
    local filterName = self.value -- self.value = text

    --UIDropDownMenu_SetSelectedID(LFGFrameDropDownMenu41, self:GetID())
    SetCategory(filterName)
    Addon:Refilter()

    -- reload buttons after changing category + some trickery to get the drop down width not to change
    local noResize = DropDownList1.noResize
    local shouldRefresh = DropDownList1.shouldRefresh
    UIDropDownMenu_Initialize(LFGFrameDropDownMenu41, LFGFrameDropDownList_Initialize)
    DropDownList1.noResize = 1
    ToggleDropDownMenu(nil, nil, LFGFrameDropDownMenu41)
    DropDownList1.shouldRefresh = false
    -- set back, or else it affects other drop downs
    C_Timer.After(0, function()
        DropDownList1.noResize = noResize
        DropDownList1.shouldRefresh = shouldRefresh
    end)
end
local function LFGFrameDropDownListButton_IsCategoryButtonChecked(self)
    local filterName = self.value -- self.value = text
    return IsFilterActive(filterName)
end

local function LFGFrameDropDownListButton_FilterButtonClicked(self)
    local filterName = self.value -- self.value = text
    ToggleFilter(filterName)
    Addon:Refilter()
end
local function LFGFrameDropDownListButton_IsFilterButtonChecked(self)
    local filterName = self.value -- self.value = text
    return IsFilterActive(filterName)
end

local function LFGFrameDropDownListButton_TagButtonClicked(self, _, _, checked)
    local tag = self.value
    local predicateForTag = predicateForTag(tag)
    if checked then
        activePredicates.OR[predicateForTag] = predicateForTag
        activePredicates.NOT[predicateForTag] = nil
    else
        activePredicates.OR[predicateForTag] = nil
        activePredicates.NOT[predicateForTag] = predicateForTag
    end

    -- temporarily change operator of All filter to AND
    --local allIsActive = IsFilterActive("All")
    --SetFilterActive("All", false)
    --filterForName["All"].operator = "AND"
    --SetFilterActive("All", allIsActive)

    Addon:Refilter()
end
local function LFGFrameDropDownListButton_IsTagButtonChecked(self)
    --local predicateForTag = predicateForTag(self.value) -- self.value = tag
    --return activePredicates.OR[predicateForTag] ~= nil
    local tag = self.value
    return tContains(Addon:GetDataSource(), tag)
end






local function LFGFrameDropDownListButton_FilterAllClicked(self, arg1, arg2, checked)
    if filterByActive then
        UIDropDownMenu_SetText(LFGFrameDropDownMenu41, "All Active Dungeons")
    else
        UIDropDownMenu_SetText(LFGFrameDropDownMenu41, "All Dungeons")
    end
end
local function LFGFrameDropDownListButton_FilterNoneClicked(self, arg1, arg2, checked)
    UIDropDownMenu_SetText(LFGFrameDropDownMenu41, "No Dungeons")
end
function LFGFrameDropDownListButton_FilterRecommendedClicked(self, arg1, arg2, checked)
    if filterByActive then
        UIDropDownMenu_SetText(LFGFrameDropDownMenu41, "Recommended Active Dungeons")
        UIDropDownMenu_SetText(LFGFrameDropDownMenu41, "Recommended Dungeons")
    else
        UIDropDownMenu_SetText(LFGFrameDropDownMenu41, "Recommended Dungeons")
    end
end
local function LFGFrameDropDownListButton_FilterOnlyActiveClicked2(self, arg1, arg2, checked)
    local selectedFilter = UIDropDownMenu_GetSelectedID(LFGFrameDropDownMenu41)
    if selectedFilter == 2 then
        -- all
        if filterByActive then
            UIDropDownMenu_SetText(LFGFrameDropDownMenu41, "All Active Dungeons")
        else
            UIDropDownMenu_SetText(LFGFrameDropDownMenu41, "All Dungeons")
        end
    elseif selectedFilter == 3 then
        -- none
        UIDropDownMenu_SetText(LFGFrameDropDownMenu41, "No Dungeons")
    elseif selectedFilter == 4 then
        -- recommended
        if filterByActive then
            UIDropDownMenu_SetText(LFGFrameDropDownMenu41, "Recommended Dungeons")
        else
            UIDropDownMenu_SetText(LFGFrameDropDownMenu41, "Recommended Dungeons")
        end
    end
end






local FilterButtonsInfo = {
    {
        -- header
        text = "Category",
        isTitle = true,
        notCheckable = true,
    },
    {
        text = "Dungeons",
        keepShownOnClick = true,
        func = LFGFrameDropDownListButton_CategoryButtonClicked,
        checked = LFGFrameDropDownListButton_IsCategoryButtonChecked,
    },
    {
        text = "Raids",
        keepShownOnClick = true,
        func = LFGFrameDropDownListButton_CategoryButtonClicked,
        checked = LFGFrameDropDownListButton_IsCategoryButtonChecked,
    },
    {
        text = "Battlegrounds",
        keepShownOnClick = true,
        func = LFGFrameDropDownListButton_CategoryButtonClicked,
        checked = LFGFrameDropDownListButton_IsCategoryButtonChecked,
    },
    {
        -- header
        text = "Filter",
        isTitle = true,
        notCheckable = true,
    },
    {
        text = "All",
        keepShownOnClick = true,
        isNotRadio = true,
        func = LFGFrameDropDownListButton_FilterButtonClicked,
        checked = LFGFrameDropDownListButton_IsFilterButtonChecked,
    },
    {
        text = "Active",
        keepShownOnClick = true,
        isNotRadio = true,
        func = LFGFrameDropDownListButton_FilterButtonClicked,
        checked = LFGFrameDropDownListButton_IsFilterButtonChecked,
    },
    {
        text = "Recommended",
        keepShownOnClick = true,
        isNotRadio = true,
        func = LFGFrameDropDownListButton_FilterButtonClicked,
        checked = LFGFrameDropDownListButton_IsFilterButtonChecked,
    },
    {
        -- header
        text = "Dungeons",
        isTitle = true,
        notCheckable = true,
    },
}
local function LFGFrameDropDownList_ConfigureInfoForTag(info, tag, index)
    local FONT_COLOR_CODE = nil
    if #tag.players > 0 then
        FONT_COLOR_CODE = HIGHLIGHT_FONT_COLOR_CODE
    else
        FONT_COLOR_CODE = GRAY_FONT_COLOR_CODE
    end
    info.text = FONT_COLOR_CODE..tag.title..FONT_COLOR_CODE_CLOSE
    info.value = tag
    info.arg1 = #tag.players -- used in DesaturateChecks()
    info.keepShownOnClick = true
    info.isNotRadio = true
    info.checked = LFGFrameDropDownListButton_IsTagButtonChecked
    info.func = LFGFrameDropDownListButton_TagButtonClicked

    -- tooltip
        info.tooltipTitle = tag.title
        if tag.minLevel and tag.maxLevel then
            local difficulty = select(2, Addon:DifficultyForLevelRange(tag.minLevel, tag.maxLevel))
            local color = QuestDifficultyColors[difficulty]
            if color then
                color = ConvertRGBtoColorString(color)
                info.tooltipText = color.."Level "..tag.minLevel.."-"..tag.maxLevel--.."\n"..#players.." players"
            else
                info.tooltipText = "Level "..tag.minLevel.."-"..tag.maxLevel--.."\n"..#players.." players"
            end
        else
            info.tooltipText = "Level 60"--.."\n"..#players.." players"
        end
        info.tooltipOnButton = true

        --info.tooltipTitle = "Title";
        --info.tooltipText = "Text";
        --info.tooltipInstruction = "Instruction";
        --info.tooltipWarning = "Warning";

end
function LFGFrameDropDownList_Initialize(self, level, menuList)
    for i, buttonInfo in ipairs(FilterButtonsInfo) do
        local info = UIDropDownMenu_CreateInfo()
        info.value = info.text
        for key, value in pairs(buttonInfo) do
            info[key] = buttonInfo[key]
        end
        UIDropDownMenu_AddButton(info)
    end

    -- TODO refactor this
    -- a little silly to do this filter every menu init (i.e. every time the menu is shown)
    local tags
    if IsFilterActive("Dungeons") then
        tags = tFilterWithPredicates(Addon.tags, {}, {tagPredicates.isDungeon}, {})
    elseif IsFilterActive("Raids") then
        tags = tFilterWithPredicates(Addon.tags, {}, {tagPredicates.isRaid}, {})
    elseif IsFilterActive("Battlegrounds") then
        tags = tFilterWithPredicates(Addon.tags, {}, {tagPredicates.isBattleground}, {})
    else
        tags = tFilterWithPredicates(Addon.tags, {}, {tagPredicates.isDungeon}, {})
    end

    for i, tag in ipairs(tags) do
        local info = UIDropDownMenu_CreateInfo()
        LFGFrameDropDownList_ConfigureInfoForTag(info, tag, i)
        UIDropDownMenu_AddButton(info)
    end

    DesaturateChecks(_G["DropDownList1"])
end

function LFGFrameDropDownList_OnLoad(self)
    Addon.activePredicates = activePredicates
    tinsert(LFGFrameTables, Addon.activePredicates) -- debug
    UIDropDownMenu_SetWidth(self, 179)
    UIDropDownMenu_Initialize(self, LFGFrameDropDownList_Initialize)
    SetCategory("Dungeons")
    Addon:Refilter(true)
    UIDropDownMenu_SetText(LFGFrameDropDownMenu41, table.concat(activeFilters()," "))
end

