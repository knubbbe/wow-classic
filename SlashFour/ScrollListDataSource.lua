local _, Addon = ...

--
-- Sectioned ScrollListDataSource
-- Functionality for virtually imposing a nested section <->> rows structure on the flat button indexes
--

-- Util

local function ScrollListDataSource_GetIndexForSection(scrollFrame, sectionIndex)
	local indexMap = ScrollListDataSource_GetSectionIndexMap(scrollFrame)
	-- try a cheap shortcut and assume that the sectionIndex is displayed as one of the buttons
	local buttons = HybridScrollFrame_GetButtons(scrollFrame)
	for buttonIndex, button in ipairs(buttons) do
		local index = ScrollListFrame_GetIndexForButtonIndex(scrollFrame, buttonIndex)
		if indexMap[index].section == sectionIndex then
			return index
		end
	end
	-- the caller wants to know the base index of an arbitrary section, so we have to do a full search :(
	for index, indexPath in iparis(indexMap) do
		if indexPath.section == sectionIndex then
			return index
		end
	end
end
local function ScrollListDataSource_GetIndexForRow(scrollFrame, sectionIndex, rowIndex)
	local indexMap = ScrollListDataSource_GetSectionIndexMap(scrollFrame)
	local indexForSection = ScrollListDataSource_GetIndexForSection(scrollFrame, sectionIndex)
	-- search for row from start of section to end of section
	local index = indexForSection
	while indexMap[index].section == sectionIndex do
		if indexMap[index].row == rowIndex then
			return index
		end
		index = index+1
	end
end

local function ScrollListDataSource_GetIndexOfNearestSection(scrollFrame, index)
	local indexMap = ScrollListDataSource_GetSectionIndexMap(scrollFrame)
	-- reverse iterate from index to find nearest parent section
	for i = index, 1, -1 do
		if indexMap[i].row == nil then
			return i
		end
	end
end
local function ScrollListDataSource_GetSectionForButton(scrollFrame, button)
	local buttonIndex = ScrollListFrame_GetButtonIndexForButton(scrollFrame, button)
	if buttonIndex then
		local index = ScrollListFrame_GetIndexForButtonIndex(scrollFrame, buttonIndex)
		local indexOfSection = ScrollListDataSource_GetIndexOfNearestSection(scrollFrame, index)
		local indexPathForSection = ScrollListDataSource_GetSectionIndexMap(scrollFrame)[indexOfSection]
		return indexPathForSection.section
	end
end

-- Sectioned Data Source

local function ScrollListDataSource_NumberOfSections(scrollFrame)
	return #Addon:GetDataSource()
end
local function ScrollListDataSource_NumberOfRowsInSection(scrollFrame, sectionIndex)
	return #Addon:GetDataSource()[sectionIndex].players
end
local function ScrollListDataSource_ConfigureButtonForSection(scrollFrame, button, sectionIndex)
	local tag = Addon:GetDataSource()[sectionIndex]
	local shouldShowLevelRange = false
	local levelRange = ""

	-- false = level range display disabled for now
	if false and not scrollFrame.scrollBar:IsDraggingThumb() then
		-- since we are directly reading GetMouseFocus(), we have to explicitly ignore dragging

		-- is the mouse hovering over a row that is in this section?
		local sectionForMouseFrame = ScrollListDataSource_GetSectionForButton(scrollFrame, GetMouseFocus())
		if sectionForMouseFrame == sectionIndex then
			shouldShowLevelRange = true
			levelRange = Addon:LevelRangeStringForTag(tag)
		end
	end

	--button.Text:SetFontObject(GameFontNormalSmall)
	button.Text:SetFont("Fonts\\FRIZQT__.TTF", 11, "SHADOW")
	button.Text:SetText(tag.title..levelRange)
	button:SetHighlightTexture(nil)

	local shouldHighlightSection = false
	local textColor = HIGHLIGHT_FONT_COLOR
	if shouldHighlightSection then
		textColor = NORMAL_FONT_COLOR
	end
	button.Text:SetTextColor(textColor.r, textColor.g, textColor.b)

	button.Detail:SetText("")
end
local function ScrollListDataSource_ConfigureButtonForRow(scrollFrame, button, sectionIndex, rowIndex)
	local tagForSection = Addon:GetDataSource()[sectionIndex]
	local player = tagForSection.players[rowIndex]
	local message = player.messages[#player.messages]

	local shortPlayerName = Ambiguate(player.name, "short")
	local classColor = player.info[2] and "|c"..RAID_CLASS_COLORS[player.info[2]].colorStr or "|r"
	--local chatFont = DEFAULT_CHAT_FRAME:GetFont()
	local channelInfo = ChatTypeInfo["CHANNEL"]
	local channelColor = format("|cff%02x%02x%02x", channelInfo.r * 255, channelInfo.g * 255, channelInfo.b * 255);

	local messageTextWithTextureReplacements = ChatFrame_ReplaceIconAndGroupExpressions(message.text)
	local displayedMessageText = channelColor..messageTextWithTextureReplacements..FONT_COLOR_CODE_CLOSE
	local displayedName = channelColor.."["..FONT_COLOR_CODE_CLOSE..classColor..shortPlayerName..FONT_COLOR_CODE_CLOSE..channelColor.."]:"..FONT_COLOR_CODE_CLOSE

	local guid = message.event.args[12] -- should find a way not to depend on player GUID since it goes stale
	local prefix = "   "
	if C_FriendList.IsFriend(guid) or (guid == UnitGUID("player")) then -- C_AccountInfo.IsGUIDRelatedToLocalAccount(guid)
		prefix = BNet_GetClientEmbeddedTexture(nil, 9, nil, -2) -- client, width, height, xOffset, yOffset
	end

	button.Text:SetFont(DEFAULT_CHAT_FRAME:GetFont())
	button.Text:SetText(prefix..displayedName.." "..displayedMessageText)
	--button:SetHighlightTexture("Interface\\FriendsFrame\\UI-FriendsFrame-HighlightBar", "ADD")
	button:SetHighlightTexture(nil)

	local _, _, _, _, largestUnitString = Addon:TimeAgoSince(message.time)
	button.Detail:SetText(largestUnitString)
end

local cachedSectionIndexMap = nil
function ScrollListDataSource_GetSectionIndexMap(scrollFrame)
	-- the section map is cached since it is used tens if not hundreds of thousands of times
	-- and is expensive to create
	if cachedSectionIndexMap ~= nil then
		return cachedSectionIndexMap
	end

	local indexMap = {}
	local index = 0 -- the flat index we are mapping onto our nested rows
	for sectionIndex=1, ScrollListDataSource_NumberOfSections(scrollFrame) do
		index = index + 1
		indexMap[index] = {section=sectionIndex, row=nil}
		for rowIndex=1, ScrollListDataSource_NumberOfRowsInSection(scrollFrame, sectionIndex) do
			index = index + 1
			indexMap[index] = {section=sectionIndex, row=rowIndex}
		end
	end

	-- cache the new section map
	cachedSectionIndexMap = indexMap

	return indexMap
end

-- Interaction

local function ScrollListDataSource_OnEnterSection(scrollFrame, button, sectionIndex)
	if scrollFrame.scrollBar:IsDraggingThumb() then
		return
	end

	GameTooltip:Hide()

	local tag = Addon:GetDataSource()[sectionIndex]

	local shouldShowLevelRange = false
	local levelRange = ""
	if shouldShowLevelRange then
		levelRange = Addon:LevelRangeStringForTag(tag)
	end
	button.Text:SetText(tag.title..levelRange)

	local shouldHighlightSection = false
	local textColor = HIGHLIGHT_FONT_COLOR
	if shouldHighlightSection then
		textColor = NORMAL_FONT_COLOR
	end
	button.Text:SetTextColor(textColor.r, textColor.g, textColor.b)
end
local function ScrollListDataSource_OnLeaveSection(scrollFrame, button, sectionIndex)
	if scrollFrame.scrollBar:IsDraggingThumb() then
		return
	end

	local tag = Addon:GetDataSource()[sectionIndex]

	button.Text:SetText(tag.title)
	button.Text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end
local function ScrollListDataSource_OnClickSection(scrollFrame, button, sectionIndex, mouseButton)
	-- this should narrow the filtered tags down to just the clicked tag, and then, if clicked again,
	-- should restore to whatever the filter was before doing that
	--LFGFrameDropDownListButton_OnSetValue(LFGFrameDropDownMenu41, Addon:GetDataSource()[sectionIndex])
end

local function ScrollListDataSource_OnEnterRow(scrollFrame, button, sectionIndex, rowIndex)
	if scrollFrame.scrollBar:IsDraggingThumb() then
		return
	end

	local tag = Addon:GetDataSource()[sectionIndex]
	local player = tag.players[rowIndex]

	-- just to save the player an error message when there's a delay between trimming expired objects and scroll frame updates
	if not tag or not player then return end

	Addon:SetPlayerToTooltip(GameTooltip, button, player)

	local latestMessage = player.messages[#player.messages]
	local _, _, _, _, largestUnitString = Addon:TimeAgoSince(latestMessage.time)
	button.Detail:SetText(largestUnitString)


	local indexForSection = ScrollListDataSource_GetIndexForSection(scrollFrame, sectionIndex)
	local sectionButtonIndex = ScrollListFrame_GetButtonIndexForIndex(scrollFrame, indexForSection)
	local sectionButton = HybridScrollFrame_GetButtons(scrollFrame)[sectionButtonIndex]

	local shouldShowLevelRange = false
	local levelRange = ""
	if shouldShowLevelRange then
		levelRange = Addon:LevelRangeStringForTag(tag)
	end

	sectionButton.Text:SetText(tag.title..levelRange)
	--sectionButton.Text:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
end
local function ScrollListDataSource_OnLeaveRow(scrollFrame, button, sectionIndex, rowIndex)
	if scrollFrame.scrollBar:IsDraggingThumb() then
		return
	end

	GameTooltip:Hide()

	local tag = Addon:GetDataSource()[sectionIndex]

	local indexForSection = ScrollListDataSource_GetIndexForSection(scrollFrame, sectionIndex)
	local sectionButtonIndex = ScrollListFrame_GetButtonIndexForIndex(scrollFrame, indexForSection)
	local sectionButton = HybridScrollFrame_GetButtons(scrollFrame)[sectionButtonIndex]
	sectionButton.Text:SetText(tag.title)
	--sectionButton.Text:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
end
local function ScrollListDataSource_OnClickRow(scrollFrame, button, sectionIndex, rowIndex, mouseButton)
	local tagForSection = Addon:GetDataSource()[sectionIndex]
	local player = tagForSection.players[rowIndex]

	local longName = Ambiguate(player.name, "mail")
	local shortName = Ambiguate(player.name, "short")
	local playerLink = GetPlayerLink(longName, format("[%s]", shortName)) --("[%s]"):format(coloredName)
	SetItemRef("player:"..longName, playerLink, mouseButton, DEFAULT_CHAT_FRAME)
end

-- TODO Refactor

local lastButtonCount = 0
local function ReportNumberOfButtons(scrollFrame, numberOfButtons)
	if numberOfButtons ~= lastButtonCount then
		-- Data count has changed since last time we checked. A little naive, but whatever...
		-- So recalculate section index map & data source
		ScrollListDataSource_ClearCache(scrollFrame)
		--
		lastButtonCount = numberOfButtons
	end
end
function ScrollListDataSource_ClearCache(scrollFrame)
	cachedSectionIndexMap = nil
	--previousDataSourceFunc = dataSourceFunc
	cachedDataSource = nil -- BUG! refering to global, since this var has been moved
	--print("cleared cache")
end

--
-- ScrollListDataSource
--

-- RENAME: this isn't actually number of *buttons*.... there are only (frame.height / button.height) + 1 # of buttons
local function ScrollListDataSource_NumberOfButtons(scrollFrame)
	local sections = ScrollListDataSource_NumberOfSections(scrollFrame)
	local rows = 0
	for i=1, sections do
		rows = rows + ScrollListDataSource_NumberOfRowsInSection(scrollFrame, i)
	end
	local numberOfButtons = sections + rows

	ReportNumberOfButtons(scrollFrame, numberOfButtons)

	return numberOfButtons
end
local function ScrollListDataSource_HeightForButtonAtIndex(scrollFrame, index, button)
	-- TODO
	-- ScrollListFrame_ReloadButtonsFromButtonIndex
	--  local rowHeight = rowHeightFunc(scrollFrame, 1, buttons[1]) -- TODO make dynamic

	--local isSection = ScrollListDataSource_IndexIsSection(scrollFrame, index)
	--if isSection then
		--return button:GetHeight() * 2
	--else
		return button:GetHeight()
	--end
end
local function ScrollListDataSource_ConfigureButtonAtIndex(scrollFrame, index, button)
	local indexMap = ScrollListDataSource_GetSectionIndexMap(scrollFrame)
	local indexPath = indexMap[index]
	if indexPath.row == nil then
		ScrollListDataSource_ConfigureButtonForSection(scrollFrame, button, indexPath.section)
	else
		ScrollListDataSource_ConfigureButtonForRow(scrollFrame, button, indexPath.section, indexPath.row)
	end
end

function ScrollListButton_OnEnter(self)
	local scrollFrame = self:GetParent():GetParent()
	--print(self:GetName(), scrollFrame:GetName())
	if scrollFrame.scrollBar:IsDraggingThumb() then
		return
	end
	local buttonIndex = ScrollListFrame_GetButtonIndexForButton(scrollFrame, self)
	local index = ScrollListFrame_GetIndexForButtonIndex(scrollFrame, buttonIndex)
	local indexMap = ScrollListDataSource_GetSectionIndexMap(scrollFrame)
	local indexPath = indexMap[index]
	if indexPath.row == nil then
		ScrollListDataSource_OnEnterSection(scrollFrame, self, indexPath.section)
	else
		ScrollListDataSource_OnEnterRow(scrollFrame, self, indexPath.section, indexPath.row)
	end
end
function ScrollListButton_OnLeave(self)
	local scrollFrame = self:GetParent():GetParent()
	if scrollFrame.scrollBar:IsDraggingThumb() then
		return
	end
	local buttonIndex = ScrollListFrame_GetButtonIndexForButton(scrollFrame, self)
	local index = ScrollListFrame_GetIndexForButtonIndex(scrollFrame, buttonIndex)
	local indexMap = ScrollListDataSource_GetSectionIndexMap(scrollFrame)
	local indexPath = indexMap[index]
	if indexPath.row == nil then
		ScrollListDataSource_OnLeaveSection(scrollFrame, self, indexPath.section)
	else
		ScrollListDataSource_OnLeaveRow(scrollFrame, self, indexPath.section, indexPath.row)
	end

end
function ScrollListButton_OnClick(self, mouseButton, down)
	local scrollFrame = self:GetParent():GetParent()
	local buttonIndex = ScrollListFrame_GetButtonIndexForButton(scrollFrame, self)
	local index = ScrollListFrame_GetIndexForButtonIndex(scrollFrame, buttonIndex)
	local indexMap = ScrollListDataSource_GetSectionIndexMap(scrollFrame)
	local indexPath = indexMap[index]

	if indexPath.row == nil then
		-- clicked header button
		ScrollListDataSource_OnClickSection(scrollFrame, self, indexPath.section, mouseButton)
	else
		ScrollListDataSource_OnClickRow(scrollFrame, self, indexPath.section, indexPath.row, mouseButton)
	end
end

hooksecurefunc("HybridScrollFrame_OnValueChanged", function(self, value)
	-- augments ScrollListButton_OnEnter()
	-- update tooltip when scrolling list while mouse is over row/button
	-- we have to do this because scrolling list doesn't actually move buttons
	-- so OnLeave/OnEnter for the button--which configures tooltip--isn't called
	local mouseFrame = GetMouseFocus()
	if mouseFrame then
		local frameName = mouseFrame:GetName()
		if frameName and string.find(frameName, "ScrollFrameButton", 1, true) then
			ScrollListButton_OnEnter(mouseFrame)
		end
	end
end)

function ScrollListDataSource_InitializeScrollList(scrollFrame)
	ScrollListFrame_Initialize(scrollFrame, "ScrollListButtonTemplate", ScrollListDataSource_NumberOfButtons, ScrollListDataSource_HeightForButtonAtIndex, ScrollListDataSource_ConfigureButtonAtIndex)
	if scrollFrame.isInitialized then
		scrollFrame.update()
	end
end
