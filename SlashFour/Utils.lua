local _, Addon = ...

--
-- Utils
--

function Addon:TimeAgoSince(timestamp)
	local secondsAgo = time() - timestamp
	local minutesAgo = math.modf(secondsAgo / 60)
	local hoursAgo = math.modf(minutesAgo / 60)
	local largestNonZeroUnit = ""

	local timeAgoString = ""
	if hoursAgo > 0 then
		timeAgoString = hoursAgo.." hour ago"
		largestNonZeroUnit = hoursAgo.."h"
	elseif minutesAgo > 0 then
		timeAgoString = minutesAgo.." min ago"
		largestNonZeroUnit = minutesAgo.."m"
	else
		timeAgoString = secondsAgo.." sec ago"
		largestNonZeroUnit = secondsAgo.."s"
	end

	return secondsAgo, minutesAgo, hoursAgo, timeAgoString, largestNonZeroUnit
end

function Addon:DifficultyForLevelRange(minLevel, maxLevel, referenceLevel)
	-- lvl 20 example:
	-- skull     30≥
	-- red    25-29
	-- orange 23-24
	-- yellow 18-22  <--
	-- green  14-17
	-- gray  ≤13
	if not referenceLevel then
		referenceLevel = UnitLevel("player")
	end
	local treshold
	    if referenceLevel < minLevel then treshold = minLevel
	elseif referenceLevel > maxLevel then treshold = maxLevel-2 --subtract 2 from the maxLevel so zones entirely below the player's level won't be yellow
	else                                  treshold = referenceLevel
	end
	local levelDiff = treshold - referenceLevel
		if levelDiff >= 10 then return  3, "impossible",    "red" -- skull
	elseif levelDiff >= 5  then return  2, "impossible",    "red"
	elseif levelDiff >= 3  then return  1, "verydifficult", "orange"
	elseif levelDiff >= -2 then return  0, "difficult",     "yellow"
	elseif levelDiff >= -6 then return -1, "standard",      "green"
	else                        return -2, "trivial",       "gray"
	end
end
function Addon:IsLevelAppropriate(minLevel, maxLevel, reqLevel, referenceLevel)
	if not referenceLevel then
		referenceLevel = UnitLevel("player")
	end
	local isLevelAppropriate
	if minLevel and maxLevel then
		local difficultyLevel = Addon:DifficultyForLevelRange(minLevel, maxLevel, referenceLevel)
		isLevelAppropriate = difficultyLevel > -2 and difficultyLevel < 2 -- <- important definition
	elseif reqLevel then
		isLevelAppropriate = referenceLevel >= reqLevel
	else
		isLevelAppropriate = true
	end
	return isLevelAppropriate
end
function Addon:IsLevelTooHigh(tag)
	local IsLevelTooHigh = false
	if tag.reqLevel then
		IsLevelTooHigh = UnitLevel("player") < tag.reqLevel
	end
	return IsLevelTooHigh
end
function Addon:LevelRangeStringForTag(tag)
	local levelRangeString = ""
	if tag.minLevel and tag.maxLevel then
		levelRangeString = " ("..tag.minLevel.."-"..tag.maxLevel..")"
	end
	return levelRangeString
end

function Addon:SetPlayerToTooltip(tooltip, button, player)
	GameTooltip:SetOwner(button, "ANCHOR_NONE", 0, 0)
	GameTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 32, 0);

	--print("friendInfo:", C_FriendList.GetFriendInfo(player.name), player.name, Ambiguate(player.name, "mail"), GetUnitName("player"), UnitFullName("player"))

	local nameColor = CreateColor(0, 0.6, 0.1) -- green
	--if C_FriendList.GetFriendInfo(player.name) or (player.name == GetUnitName("player")) then -- C_AccountInfo.IsGUIDRelatedToLocalAccount(guid)
		--nameColor = CreateColor(0, 0.749, 0.953) -- blue
	--else
		--nameColor = CreateColor(0, 0.6, 0.1) -- green
	--end

	local suffix = ""
	--if C_FriendList.IsFriend(guid) or (guid == UnitGUID("player")) then -- C_AccountInfo.IsGUIDRelatedToLocalAccount(guid)
		--suffix = BNet_GetClientEmbeddedTexture(nil, 12, nil, 5) -- client, width, height, xOffset, yOffset
	--end

	GameTooltip_SetTitle(GameTooltip, Ambiguate(player.name, "short")..suffix, nameColor) -- Green

	local _, _, _, timeAgoString = Addon:TimeAgoSince(player.messages[#player.messages].time)
	local localizedClass = player.info[1]
	local localizedRace = player.info[3]
	local playerDesc = localizedRace.." ".. localizedClass
	if player.level then
		playerDesc = "Level "..player.level.." "..playerDesc
	end
	local playerDescFontColor = HIGHLIGHT_FONT_COLOR
	local timeAgoFontColor = HIGHLIGHT_FONT_COLOR

	GameTooltip:AddDoubleLine(playerDesc, timeAgoString, playerDescFontColor.r, playerDescFontColor.g, playerDescFontColor.b, timeAgoFontColor.r, timeAgoFontColor.g, timeAgoFontColor.b)

	if player.guild then
		GameTooltip_AddColoredLine(GameTooltip, "<"..player.guild..">", HIGHLIGHT_FONT_COLOR)
	end

	-- chat messages
	local channelInfo = ChatTypeInfo["CHANNEL"]
	local channelColor = format("|cff%02x%02x%02x", channelInfo.r * 255, channelInfo.g * 255, channelInfo.b * 255);
	for i = #player.messages, 1, -1 do
		local message = player.messages[i]

		if i == #player.messages then
			-- newest message
		elseif i == 1 then
			-- oldest message
		else
			-- middle messages
		end

		local messageTextWithTextureReplacements = ChatFrame_ReplaceIconAndGroupExpressions(message.text)
		local displayedMessageText = channelColor..messageTextWithTextureReplacements..FONT_COLOR_CODE_CLOSE
		local tooltipTextWidth =  GameTooltipTextLeft3:GetStringWidth() -- measure the width of the third string. 1st string is title, set to player name, 2nd string is level/race/class/time ago.
		local shouldWrapTooltipText = tooltipTextWidth > 500 or tooltipTextWidth == 0
		GameTooltip_AddColoredLine(GameTooltip, displayedMessageText, CreateColor(channelInfo.r, channelInfo.g, channelInfo.b), shouldWrapTooltipText)
		--button.Text:SetFont(DEFAULT_CHAT_FRAME:GetFont())
	end

	--GameTooltip_AddInstructionLine(GameTooltip, "<Shift Click to get level for player>")
	--GameTooltip_AddInstructionLine(GameTooltip, "<Hold Shift to view message history>")
	if not player.level then
		GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
		GameTooltip_AddColoredLine(GameTooltip, "Shift Click to get Level & Guild", LIGHTBLUE_FONT_COLOR)
	end
	--GameTooltip_AddColoredLine(GameTooltip, "Hold Shift to view message history", LIGHTBLUE_FONT_COLOR)

	GameTooltip.__lfgplayer = player

	GameTooltip:Show()




	if false then
		--local isButtonTextTruncated = button.Text:IsTruncated()

		local tooltipText = ""

		-- reverse iteration, to get newest message first
		for i = #player.messages, 1, -1 do
			local message = player.messages[i]

			if i == #player.messages then
				-- latest message

				local _, _, _, timeAgoString = Addon:TimeAgoSince(message.time)

				local _, locs = Addon:TagsForText(Addon.tags, message.text)
				local tagsString = Addon:PrintTagsForText(message.text, message.tags, locs)

				tooltipText = tooltipText..timeAgoString
				tooltipText = tooltipText.."\n"..message.text
				if string.len(tagsString) > 0 then
					tooltipText = tooltipText.."\n"..tagsString
				end
				if #player.messages > 1 then
					tooltipText = tooltipText.."\n"
				end
			elseif i == 1 then
				-- oldest message
				tooltipText = tooltipText.."\n"..message.text
				--tooltipText = tooltipText.."\n"..timeAgoString
			else
				tooltipText = tooltipText.."\n"..message.text
			end
		end

		--GameTooltipTextLeft1:SetText(tooltipText)
		local tooltipTextWidth =  GameTooltipTextLeft1:GetStringWidth()
		local shouldWrapTooltipText = tooltipTextWidth > 700

		GameTooltip:SetOwner(button, "ANCHOR_NONE", 0, 0)
		GameTooltip:SetPoint("TOPLEFT", button, "TOPRIGHT", 32, 0);
		--GameTooltip:AddLine(tooltipText, 0.8, 0.8, 0.8, shouldWrapTooltipText)

		--FACTION_BAR_COLORS-- 1-8

		--GameTooltip_AddColoredLine(GameTooltip, ""..player.info[3].." ".. player.info[1], HIGHLIGHT_FONT_COLOR)
		--GameTooltip_AddColoredLine(GameTooltip, "Last Message "..timeAgoString, HIGHLIGHT_FONT_COLOR)

		--GameTooltip_AddInstructionLine(GameTooltip, "<Shift Click to get level for player>")
		--GameTooltip_AddInstructionLine(GameTooltip, "<Hold Shift to view message history>")
		GameTooltip_AddBlankLinesToTooltip(GameTooltip, 1)
		GameTooltip_AddColoredLine(GameTooltip, "Shift Click to get level for player", LIGHTBLUE_FONT_COLOR)
		GameTooltip_AddColoredLine(GameTooltip, "Hold Shift to view message history", LIGHTBLUE_FONT_COLOR)

		--GameTooltip_AddInstructionLine(GameTooltip, "AddInstructionLine")
		--GameTooltip_AddColoredLine(GameTooltip, "AddColoredLine", LIGHTBLUE_FONT_COLOR)
		--GameTooltip_SetBottomText(GameTooltip, "SetBottomText", ORANGE_FONT_COLOR)

		--GameTooltip_AddColoredLine(GameTooltip, "Faction1", CreateColor(FACTION_BAR_COLORS[1].r, FACTION_BAR_COLORS[1].g, FACTION_BAR_COLORS[1].b))
		--GameTooltip_AddColoredLine(GameTooltip, "Faction2", CreateColor(FACTION_BAR_COLORS[2].r, FACTION_BAR_COLORS[2].g, FACTION_BAR_COLORS[2].b))
		--GameTooltip_AddColoredLine(GameTooltip, "Faction3", CreateColor(FACTION_BAR_COLORS[3].r, FACTION_BAR_COLORS[3].g, FACTION_BAR_COLORS[3].b))
		--GameTooltip_AddColoredLine(GameTooltip, "Faction4", CreateColor(FACTION_BAR_COLORS[4].r, FACTION_BAR_COLORS[4].g, FACTION_BAR_COLORS[4].b))
		--GameTooltip_AddColoredLine(GameTooltip, "Faction5", CreateColor(FACTION_BAR_COLORS[5].r, FACTION_BAR_COLORS[5].g, FACTION_BAR_COLORS[5].b))
		--GameTooltip_AddColoredLine(GameTooltip, "Faction6", CreateColor(FACTION_BAR_COLORS[6].r, FACTION_BAR_COLORS[6].g, FACTION_BAR_COLORS[6].b))
		--GameTooltip_AddColoredLine(GameTooltip, "Faction7", CreateColor(FACTION_BAR_COLORS[7].r, FACTION_BAR_COLORS[7].g, FACTION_BAR_COLORS[7].b))
		--GameTooltip_AddColoredLine(GameTooltip, "Faction8", CreateColor(FACTION_BAR_COLORS[8].r, FACTION_BAR_COLORS[8].g, FACTION_BAR_COLORS[8].b))


		--GameTooltip_AddColoredLine(GameTooltip, "Roald", CreateColor(0, 0.749, 0.953))





		GameTooltip:Show()


		--print("hovering row", index, buttonIndex)
	end

end

-- Thanks to G_P_I, owner of Group Bulletin Board addon: https://www.curseforge.com/wow/addons/group-bulletin-board
-- for the gsub patterns
function Addon:ParseWhoResponse(...)

	local function CreatePattern(pattern)
		pattern = string.gsub(pattern, "[%(%)%-%+%[%]]", "%%%1")
		pattern = string.gsub(pattern, "%%s", "(.-)")
		pattern = string.gsub(pattern, "%%d", "%(%%d-%)")
		pattern = string.gsub(pattern, "%%%d%$s", "(.-)")
		pattern = string.gsub(pattern, "%%%d$d", "%(%%d-%)")
		--pattern = string.gsub(pattern, "%[", "%|H%(%.%-%)%[")
		--pattern = string.gsub(pattern, "%]", "%]%|h")
		return pattern

	end

	local whoPattern = CreatePattern(WHO_LIST_FORMAT)
	local whoPatternGuild = CreatePattern(WHO_LIST_GUILD_FORMAT)

	local arg1 = select(1, ...)

	local d, name, level, race, class, guild = string.match(arg1, whoPatternGuild)

	if not name or not level then
		d, name, level, race, class, guild = string.match(arg1, whoPattern)
	end

	-- don't return garbage, nil out if there's no real info
	if name and name:match("%S") == nil then
		name = nil
	end
	if level and level:match("%S") == nil then
		level = nil
	end
	if guild and guild:match("%S") == nil then
		guild = nil
	end

	--print(d, name, level, race, class, guild)
	return name, level, guild
end

-- TAGS: Keyword Parsing & Tagging

local function EnumerateKeywordsForTags(tags, func, locale) -- 'locale' is optional
	for i, tag in ipairs(tags) do
		if (not locale) or (locale and locale == tag.locale) then
			for _, keyword in ipairs(tag.keywords) do
				func(tag, keyword)
			end
		end
	end
end
local function TextContainsKeyword(text, keyword)
	local i, j = string.find(string.lower(text), '%f[%w]'..string.lower(keyword)..'%f[%W]')
	return (i and j), i, j
end

function Addon:TagsForText(availableTags, text)
	local tags = {}
	local locs = {} -- text locations for the tags
	EnumerateKeywordsForTags(availableTags, function(tag, keyword)
		local hasKeyword, startLoc, endLoc = TextContainsKeyword(text, keyword)
		if hasKeyword then
			if locs[tag] == nil then locs[tag] = {} end
			tinsert(locs[tag], {startLoc, endLoc}) -- the same tag can appear multiple places in the text, for different substrings
		end
		if hasKeyword and tContains(tags, tag) == false then
			tinsert(tags, tag) -- the returned list of tags is uniqued (doesn't contain same tags multiple times)
		end
	end)
	return tags, locs
end
function Addon:PrintTagsForText(text, tags, locs)
	local tagsString = ""
	for i, tag in ipairs(tags) do
		local keywords = ""
		for j, loc in ipairs(locs[tag]) do
			keywords = keywords..string.sub(text, loc[1], loc[2])
			if j ~= #locs[tag] then
				keywords = keywords..", "
			end
		end
		if string.len(keywords) > 0 then
			tagsString = tagsString..keywords.."="..tag.category
			if i ~= #tags then
				tagsString = tagsString.." "
			end
		end
	end

	--local blank = tagsString:match("%S") == nil
	local blank = tagsString == ""
	if not blank then
		tagsString = YELLOW_FONT_COLOR_CODE..tagsString..FONT_COLOR_CODE_CLOSE
	end

	return tagsString
end

-- TAGS: Filtering & Ignoring

-- ...

--
-- Lua stuff
--

function tInsertTable(t1, pos, t2)
	for i=1, #t2 do
		tinsert(t1, pos+i-1, t2[i])
	end
end
