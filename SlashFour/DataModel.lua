local _, Addon = ...

--
-- KVC (key value coding)
--
-- Usage: SetManyToManyRelationship(tag, "messages", message, "tags")
-- Usage: SetOneToManyRelationship(player, "messages", message, "player")
-- 'targetKey' is optional, and signifies a mutual <> relationship

local function SetManyToManyRelationship(sourceObject, sourceKey, targetObject, targetKey)
	if sourceObject[sourceKey] == nil then
		sourceObject[sourceKey] = {}
	end
	if not tContains(sourceObject[sourceKey], targetObject) then -- relationships are unique. Two things can't have the same relationship twice.
		tinsert(sourceObject[sourceKey], targetObject)
	end
	if targetKey then
		if targetObject[targetKey] == nil then
			targetObject[targetKey] = {}
		end
		if not tContains(targetObject[targetKey], sourceObject) then -- relationships are unique. Two things can't have the same relationship twice.
			tinsert(targetObject[targetKey], sourceObject)
		end
	end
end
local function RemoveManyToManyRelationship(sourceObject, sourceKey, targetObject, targetKey)
	tDeleteItem(sourceObject[sourceKey], targetObject)
	if targetKey then
		tDeleteItem(targetObject[targetKey], sourceObject)
	end
end

local function SetOneToManyRelationship(sourceObject, sourceKey, targetObject, targetKey)
	sourceObject[sourceKey] = targetObject
	if targetKey then
		SetManyToManyRelationship(targetObject, targetKey, sourceObject) -- no targetKey = non-mutually set *-to-many relationship
	end
end
local function RemoveOneToManyRelationship(sourceObject, sourceKey, targetObject, targetKey)
	sourceObject[sourceKey] = nil -- can check if (sourceObject[sourceKey] == targetObject) before removing, but whatever
	if targetKey then
		RemoveManyToManyRelationship(targetObject, targetKey, sourceObject) -- no targetKey = non-mutually remove *-to-many relationship
	end
end

--
-- OBJECT GRAPH
--
-- player <->> message (& mutual cascade deletion)
-- message <<->> tag
-- player <<->> tag    (derived from player.messages)
--

local function AddPlayerToTags(player, tags)
	-- for easy lookup, we maintain a "derived" relationship between the player & the tags of the player's messages
	for _, tag in ipairs(tags) do
		-- create player <<->> tag relationship
		SetManyToManyRelationship(player, "tags", tag, "players")
	end
end
local function RemovePlayerFromTags(player, tags)
	-- for easy lookup, we maintain a "derived" relationship between the player & the tags of the player's messages
	for _, tag in ipairs(tags) do
		-- break player <<->> tag relationship
		RemoveManyToManyRelationship(player, "tags", tag, "players")
	end
end

local function AddTagsToMessage(message, tags)
	for _, tag in ipairs(tags) do
		-- create message <<->> tag relationship
		SetManyToManyRelationship(message, "tags", tag, "messages")
	end
	-- for easy lookup, we maintain a "derived" relationship between the player & the tags of the player's messages
	AddPlayerToTags(message.player, tags)
end
local UniqueTagsForMessage -- forward declaration
local function RemoveTagsFromMessage(message, tags)
	local uniqueTags = UniqueTagsForMessage(message)
	for _, tag in ipairs(tags) do
		-- break message <<->> tag relationship
		RemoveManyToManyRelationship(message, "tags", tag, "messages")
	end
	-- remove from the player the tags that are unique to this message
	-- remove the player from the tags that are unique to this message
	RemovePlayerFromTags(message.player, uniqueTags)
end

local function AddMessagesToPlayer(player, messages)
	for _, message in ipairs(messages) do
		-- create player <->> message relationship
		SetOneToManyRelationship(message, "player", player, "messages")
		-- for easy lookup, we maintain a "derived" relationship between the player & the tags of the player's messages
		AddPlayerToTags(player, message.tags)
	end
end
local DeleteMessage -- forward declaration
local function RemoveMessagesFromPlayer(messages)
	-- note: In the case of a cascade deletion, the recursion is broken
	--       here by the fact that the following for loop will do nothing
	--       when there are 0 messages.
	for i, message in ipairs(messages) do
		-- when messages lose their player, they get deleted
		-- there should be no messages that don't have a player
		-- this is to ensure that deleting players cascades to
		-- deletion of their messages: We can remove a player,
		-- and all their messages are deleted, too.
		DeleteMessage(message) -- -> RemoveTagsFromMessage -> RemovePlayerFromTags
	end
end

--
-- TAGS
--

local function CreateTag(title, keywords, category, locale, messages, players)
	local newTag = {}
	-- set attributes
	newTag.title = title
	newTag.keywords = keywords
	newTag.category = category
	newTag.locale = locale
	newTag.messages = {}
	newTag.players = {}
	-- set up relationships
	if messages then
		-- should use AddTagsToMessage
		for _, message in ipairs(messages) do
			SetManyToManyRelationship(message, "tags", newTag, "messages")
		end
	end
	if players then
		-- should use AddPlayerToTags, which is called by AddTagsToMessage
		for _, player in ipairs(players) do
			SetManyToManyRelationship(player, "tags", newTag, "players")
		end
	end
	-- debug
	if Addon.debug then
		Addon:SetDebugName(newTag)
		Addon:SetDebugName(newTag.keywords, "keywords")
		Addon:SetDebugName(newTag.messages, "messages")
		Addon:SetDebugName(newTag.players, "players")
	end
	return newTag
end
local function InstantiatedTagFromLocalizedTemplate(locale, templateCategory, tagTemplate)
	local newTag = CreateTag(tagTemplate.title, tagTemplate.keywords, templateCategory, locale)
	for k,v in pairs(tagTemplate) do
		if newTag[k] == nil then
			newTag[k] = v
		end
	end
	return newTag
end
UniqueTagsForMessage = function(message)
	local tagsForOtherMessages = {}
	for _, otherMessage in ipairs(message.player.messages) do
		if otherMessage ~= message then
			for _, otherTag in ipairs(otherMessage.tags) do
				tagsForOtherMessages[otherTag] = true
			end
		end
	end
	-- tags that this message has & that none of the other messages from the same player have
	local uniqueTags = {}
	for _, tag in ipairs(message.tags) do
		if not tagsForOtherMessages[tag] then
			tinsert(uniqueTags, tag)
		end
	end
	return uniqueTags
end

--
-- PLAYERS
--

local function CreatePlayer(name, info, messages, tags)
	local newPlayer = {}
	-- set attributes
	newPlayer.name = name
	newPlayer.info = info
	newPlayer.messages = messages and messages or {}
	newPlayer.tags = tags and tags or {}
	-- set up relationships
	AddMessagesToPlayer(newPlayer, newPlayer.messages)
	AddPlayerToTags(newPlayer, newPlayer.tags)
	-- debug
	if Addon.debug then
		Addon:SetDebugName(newPlayer)
		Addon:SetDebugName(newPlayer.messages, "messages")
		Addon:SetDebugName(newPlayer.tags, "tags")
	end
	return newPlayer
end
local function DeletePlayer(player)
	-- break down relationships
	RemoveMessagesFromPlayer(player.messages) -- -> DeleteMessage -> RemoveTagsFromMessage -> RemovePlayerFromTags

	tDeleteItem(Addon.players, player)
	player.isDeleted = true
end
local function InstantiatePlayerFromName(name, info)
	local newPlayer = CreatePlayer(name, info)
	tinsert(Addon.players, 1, newPlayer)
	return newPlayer
end
function Addon:GetPlayerForName(name, info)
	local playerForName = nil
	for _, player in ipairs(Addon.players) do
		if Ambiguate(player.name, "short") == Ambiguate(name, "short") then
			playerForName = player
			break
		end
	end
	if playerForName == nil and info then
		playerForName = InstantiatePlayerFromName(name, info)
	end
	return playerForName
end

--
-- MESSAGES
--

local function CreateMessage(text, player, time, tags)
	local newMessage = {}
	-- set attributes
	newMessage.text = text and text or ""
	newMessage.player = player
	newMessage.time = time and time or time()
	newMessage.tags = tags and tags or {}
	-- set up relationships
	AddTagsToMessage(newMessage, newMessage.tags) -- -> AddPlayerToTags() call duplication :(
	AddMessagesToPlayer(newMessage.player, {newMessage}) -- -> AddPlayerToTags() call duplication :(
	-- debug
	if Addon.debug then
		Addon:SetDebugName(newMessage)
		Addon:SetDebugName(newMessage.tags, "tags")
		Addon:SetDebugName(newMessage.player, "players")
	end
	return newMessage
end
DeleteMessage = function(message)
	local player = message.player

	RemoveTagsFromMessage(message, message.tags) -- -> RemovePlayerFromTags
	-- The following MUST BE CALLED LAST
	-- Many functions depend on message.player & this function set message.player = nil
	-- break player <-> message relationship
	RemoveOneToManyRelationship(message, "player", message.player, "messages")

	tDeleteItem(Addon.messages, message)
	message.isDeleted = true

	if #player.messages == 0 then
		-- cascade deletion of player with 0 messages
		DeletePlayer(player)
	end
end

--
-- Public interface
--

function Addon:InitializeTagsForLocale(locale)
	for templateCategory, tagTemplates in pairs(LocalizedTagTemplates[locale]) do
		for _, tagTemplate in ipairs(tagTemplates) do
			tinsert(Addon.tags, InstantiatedTagFromLocalizedTemplate(locale, templateCategory, tagTemplate))
		end
	end
end
function Addon:RemoveExpiredPlayers(minutesOld)
	-- this is an alternative to TrimRecordedEvents()
	-- instead of removing messages that are older than minutesOld like TrimRecordedEvents()
	-- RemoveExpiredPlayers() instead removes all of a player's messages when their *newest
	-- message* is older than minutesOld
	-- This allows us to better know the history of a person who's been continually looking
	-- for a group
	-- BUT! This can only be done (performantly) after the object graph has been built

	local threshold = time() - (minutesOld * 60)
	local expiredPlayers = {}

	for _, player in ipairs(Addon.players) do
		local latestMessage = player.messages[#player.messages]
		if latestMessage.time < threshold then
			tinsert(expiredPlayers, player)
		end
	end

	--[[
	-- collect the old indexes for the expired players, used to animate individual row deletions in scroll list
	local expiredPlayersIndexes = {}
	for _, expiredPlayerGUID in ipairs(expiredPlayers) do
		for expiredPlayerIndex, playerGUID in ipairs(Players) do
			if playerGUID == expiredPlayerGUID then
				tinsert(expiredPlayersIndexes, expiredPlayerIndex)
			end
		end
	end
	]]--

	local expiredMessages = 0 -- for debugging

	for _, player in ipairs(expiredPlayers) do
		expiredMessages = expiredMessages + #player.messages -- for debugging
		--RemovePlayerFromTags(player, player.tags)
		DeletePlayer(player)
		--RemovePlayerFromTags(player, player.tags)
	end

	if Addon.debug then print("Removed "..expiredMessages.." messages & "..#expiredPlayers.." players older than "..minutesOld.." minutes.") end
	--return expiredMessages, expiredPlayers, expiredPlayersIndexes
end
function Addon:InstantiateMessageFromEvent(args, time, playerInfo)
	-- regarding 'playerInfo': When messages are instantiated from saved data, playerInfo must be passed
	-- since player GUIDs expire and therefore we can't necessarily at a later time call GetPlayerInfoByGUID()
	-- with saved GUIDs
	-- When 'playerInfo' is nil, we assume that the GUID in the args is fresh and that GetPlayerInfoByGUID()
	-- will produce the playerInfo
	if not args[12] then return end -- don't record player-less chat events
	local messageText = args[1]
	local playerName = args[2]
	local playerInfo = playerInfo and playerInfo or {GetPlayerInfoByGUID(args[12])}
	local tags = Addon:TagsForText(Addon.tags, messageText)
	local player = Addon:GetPlayerForName(playerName, playerInfo) -- creates new Player instance if needed
	local newMessage = CreateMessage(messageText, player, time, tags)
	tinsert(Addon.messages, newMessage)
	return newMessage
end

function Addon:InstantiateMessageFromRecordedEvent(recordedEvent)
	local newMessage = Addon:InstantiateMessageFromEvent(recordedEvent.args, recordedEvent.timestamp, recordedEvent.playerInfo)
	newMessage.event = recordedEvent
	return newMessage
end
function Addon:RemoveExpiredMessages(minutesOld)

	--if Addon.debug then print("RemoveExpiredMessages") end
	local threshold = time() - (minutesOld * 60)
	local expiredMessages = {}
	for _, message in ipairs(Addon.messages) do
		if message.time < threshold then
			tinsert(expiredMessages, message)
		else
			-- the messages in Addon.messages are indexed chronologically,
			-- so the rest of the messages are newer than the threshold
			break
		end
	end
	for _, expiredMessage in ipairs(expiredMessages) do
		DeleteMessage(expiredMessage)
	end
end