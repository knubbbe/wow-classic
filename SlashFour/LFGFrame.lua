local _, Addon = ...

local LFG_EXPIRATION_TIME_IN_MINUTES = 1

local function SetLatestMessageForStatusBar()
	local message = Addon.messages[#Addon.messages]
	if not message then
		return
	end

	local player = message.player

	local shortPlayerName = Ambiguate(player.name, "short")
	local classColor = player.info[2] and "|c"..RAID_CLASS_COLORS[player.info[2]].colorStr or "|r"
	--local chatFont = DEFAULT_CHAT_FRAME:GetFont()
	local channelInfo = ChatTypeInfo["CHANNEL"]
	local channelColor = format("|cff%02x%02x%02x", channelInfo.r * 255, channelInfo.g * 255, channelInfo.b * 255);

	local displayedName = channelColor.."["..FONT_COLOR_CODE_CLOSE..classColor..shortPlayerName..FONT_COLOR_CODE_CLOSE..channelColor.."]:"..FONT_COLOR_CODE_CLOSE
	local displayedMessageText = channelColor..message.text..FONT_COLOR_CODE_CLOSE

	LFGFrame.statusBar.text:SetFont(DEFAULT_CHAT_FRAME:GetFont())
	LFGFrame.statusBar.text:SetText(displayedName.." "..displayedMessageText)
end
local function AddMessageWithArgs(self, timestamp, ...)
	--local args = {...}
	--local messageText = args[1]
	--local tagsForMessage = Addon:TagsForText(messageText)

	--if not Addon:ContainsIgnoredTags(tagsForMessage) then

		--local expiredMessages, expiredPlayers, expiredPlayersIndexes = Addon:RemoveExpiredPlayers(LFG_EXPIRATION_TIME_IN_MINUTES)
		--local newMessageIndex, newPlayerIndex = Addon:AddMessage(args, timestamp, tagsForMessage)
		--Addon:InstantiateMessageFromEvent({...}, timestamp)
		if self.scrollFrame.isInitialized then
			-- scrollFrame isn't initialized until first time we show LFGFrame,
			-- but we still collect messages in the background

			--for i, expiredPlayerIndex in ipairs(expiredPlayersIndexes) do
				--ScrollListFrame_RemoveRowAtIndex(self.scrollFrame, expiredPlayerIndex)
			--end
			--if newPlayerIndex then
				--ScrollListFrame_InsertRowAtIndex(self.scrollFrame, newPlayerIndex)
			--end
			self.scrollFrame.update()
		end
	--end

	--for i, tag in ipairs(Addon.db.tags) do
		--if #tag.players > 0 then
			--print(tag.title, #tag.players)
		--end
	--end
end

function LFGFrame_OnLoad(self)
	UIPanelWindows["LFGFrame"] = { area = "left", pushable = 5 };

	self:RegisterEvent("CHAT_MSG_CHANNEL")
	if self:HasScript("OnEvent") then
		self:HookScript("OnEvent", LFGFrame_OnEvent)
	else
		self:SetScript("OnEvent", LFGFrame_OnEvent)
	end

	self.TitleText:SetFontObject(GameFontHighlight)
	self.TitleText:SetText("Looking For Group")
end

local function ChatFrame_ChannelMessageEventHandler(self, event, ...)
	-- just straight copy/pasted relevant functionalty from ChatFrame_MessageEventHandler()

	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17 = ...;
	local type = strsub(event, 10);
	local infoType = "CHANNEL"..arg8;
	local info = ChatTypeInfo[infoType];
	local coloredName = GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14);
	local channelLength = strlen(arg4);
	local chatGroup = Chat_GetChatCategory(type);
	local chatTarget = tostring(arg8);
	local pflag = "";
	local showLink = 1;
	arg1 = gsub(arg1, "%%", "%%%%");
	arg1 = ChatFrame_ReplaceIconAndGroupExpressions(arg1, arg17, not ChatFrame_CanChatGroupPerformExpressionExpansion(chatGroup));
	arg1 = RemoveExtraSpaces(arg1);
	local playerLink;
	local playerLinkDisplayText = coloredName;
	local usingDifferentLanguage = (arg3 ~= "") and (arg3 ~= relevantDefaultLanguage);
	if ( usingDifferentLanguage or not usingEmote ) then
		playerLinkDisplayText = ("[%s]"):format(coloredName);
	end
	local playerName, lineID, bnetIDAccount = arg2, arg11, arg13;
	playerLink = GetPlayerLink(playerName, playerLinkDisplayText, lineID, chatGroup, chatTarget);
	local message = arg1;
	if ( arg14 ) then	--isMobile
		message = ChatFrame_GetMobileEmbeddedTexture(info.r, info.g, info.b)..message;
	end

	if ( usingDifferentLanguage ) then
		local languageHeader = "["..arg3.."] ";
		if ( showLink and (arg2 ~= "") ) then
			body = format(_G["CHAT_"..type.."_GET"]..languageHeader..message, pflag..playerLink);
		else
			body = format(_G["CHAT_"..type.."_GET"]..languageHeader..message, pflag..arg2);
		end
	else
		if ( not showLink or arg2 == "" ) then
			if ( type == "TEXT_EMOTE" ) then
				body = message;
			else
				body = format(_G["CHAT_"..type.."_GET"]..message, pflag..arg2, arg2);
			end
		else
			if ( type == "EMOTE" ) then
				body = format(_G["CHAT_"..type.."_GET"]..message, pflag..playerLink);
			elseif ( type == "TEXT_EMOTE") then
				body = string.gsub(message, arg2, pflag..playerLink, 1);
			elseif (type == "GUILD_ITEM_LOOTED") then
				body = string.gsub(message, "$s", GetPlayerLink(arg2, playerLinkDisplayText));
			else
				body = format(_G["CHAT_"..type.."_GET"]..message, pflag..playerLink);
			end
		end
	end

	-- Add Channel
	if (channelLength > 0) then
		body = "|Hchannel:channel:"..arg8.."|h["..ChatFrame_ResolvePrefixedChannelName(arg4).."]|h "..body;
	end
	--Add Timestamps
	if ( CHAT_TIMESTAMP_FORMAT ) then
		body = BetterDate(CHAT_TIMESTAMP_FORMAT, time())..body;
	end

	local accessID = ChatHistory_GetAccessID(chatGroup, chatTarget);
	local typeID = ChatHistory_GetAccessID(infoType, chatTarget, arg12 or arg13);
	self:AddMessage(body, info.r, info.g, info.b, info.id, accessID, typeID);
end
function LFGFrame_OnEvent(self, event, ...)
	local timestamp = time()

	if event ~= "CHAT_MSG_CHANNEL" then
		return
	end

	--if Addon.db.players == nil or Addon.db.messages == nil then
		--return
	--end

	--AddMessageWithArgs(self, timestamp, ...)
	if self.scrollFrame.isInitialized then
		self.scrollFrame.update()
	end
	SetLatestMessageForStatusBar()

	if Addon.activePredicates and LFGFrameNotifyToggleFrameCheckButton:GetChecked() then
		local latestMessage = Addon.messages[#Addon.messages]
		local tags = tFilterWithPredicates(latestMessage.tags, Addon.activePredicates.NOT, Addon.activePredicates.AND, Addon.activePredicates.OR)
		--local messageHasActiveTags = tContains(Addon:GetDataSource()...
		--print("latest message:", latestMessage, #tags.."/"..#latestMessage.tags)
		if #tags > 0 then
			ChatFrame_ChannelMessageEventHandler(DEFAULT_CHAT_FRAME, event, ...)
		end
	end
end
function LFGFrame_OnShow(self)
	--Addon:RemoveExpiredPlayers(1) -- remove any player (and their messages) whose newest message is older than 15min

	-- TODO BUG "hack": We cache some stuff in the data source that has to update when we call RemoveExpiredPlayerS()
	-- I havn't put delegate methods/callbacks like "Will/DidRemove" in place yet, which we will use to flush the cache.
	-- For now we'll directly call ScrollListDataSource_ClearCache
	--ScrollListDataSource_ClearCache(self.scrollFrame)

	if self.scrollFrame.isInitialized then
		self.scrollFrame.update()
	end
	SetLatestMessageForStatusBar()
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_OPEN)
end
function LFGFrame_OnHide(self)
	PlaySound(SOUNDKIT.IG_CHARACTER_INFO_CLOSE)
end





function LFGFrameNotifyToggleFrameCheckButton_OnEnter(self)
	--if true then return end
	--[[
	local tooltipText = "Hide empty dungeons & dungeons that are too high or low level for your character.\n"
	GameTooltipTextLeft1:SetText(tooltipText)
	local tooltipTextWidth =  GameTooltipTextLeft1:GetStringWidth()
	local shouldWrapTooltipText = tooltipTextWidth > 700

	GameTooltip:SetOwner(self, "ANCHOR_NONE", 0, 0)
	GameTooltip:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 0);
	GameTooltip:AddLine(tooltipText, 0.8, 0.8, 0.8, shouldWrapTooltipText)
	GameTooltip:Show()


	local tooltipText = "If checked, will hide dungeons that are too high or too low level for your character, as well as hide dungeons no one is messaging about."
	tooltipText = "If checked:\nHide dungeons that are inappropriate for your level.\nHide dungeons that no one is messaging about.\n\nDungeons you are subscribed to are always shown."
	local tooltipTextWidth =  GameTooltipTextLeft1:GetStringWidth()
	local shouldWrapTooltipText = tooltipTextWidth > 700
	]]--

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	--GameTooltip:SetText(tooltipText, nil, nil, nil, nil, shouldWrapTooltipText);
	--if not self:IsEnabled() then
		--GameTooltip:AddLine(ALL_ASSIST_NOT_LEADER_ERROR, RED_FONT_COLOR.r, RED_FONT_COLOR.g, RED_FONT_COLOR.b, true);
	--end
	GameTooltip:AddLine("If checked, messages for selected dungeons are also shown in the chat.", nil, nil, nil, true)
	GameTooltip:AddLine("Automatically turns off when your party is filled.", HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	--GameTooltip:AddLine("Hide dungeons that no one is messaging about.")
	--GameTooltip:AddLine("Dungeons you are subscribed to are always shown.", LIGHTGRAY_FONT_COLOR.r, LIGHTGRAY_FONT_COLOR.g, LIGHTGRAY_FONT_COLOR.b)
	GameTooltip:Show()
end
--[[
function LFGFrameNotifyToggleFrame_OnEnter(self)
end
function LFGFrameNotifyToggleFrame_OnLeave(self)
	if true then return end
	local mouseFrame = GetMouseFocus()
	if mouseFrame then
		local frameName = mouseFrame:GetName()
		if frameName and string.find(frameName, "FilterMessages", 1, true) then
		else
			GameTooltip:Hide()
		end
	end
end
]]--

function LFGFrameNotifyToggleFrameCheckButton_OnLoad(self)
	--self:SetChecked(Addon:GetFilterMessages())
end
function LFGFrameNotifyToggleFrameCheckButton_OnClick(self)
	--SetGuildRosterSelection(0);
	if self:GetChecked() then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end
	--SetGuildRosterShowOffline(self:GetChecked());
	--GuildStatus_Update();
	--Addon:SetFilterMessages(self:GetChecked())
	--LFGFrame.scrollFrame.update()
end




