local _, Addon = ...

--
-- Events
--

local Events = CreateFrame("Frame")
Events:RegisterEvent("ADDON_LOADED")
Events:RegisterEvent("CHAT_MSG_CHANNEL")
Events:RegisterEvent("CHAT_MSG_SYSTEM")
Events:RegisterEvent("GROUP_ROSTER_UPDATE")
Events:SetScript("OnEvent", function(self, event, ...)
	if self[event] then
		self[event](self, ...)
	end
end)

function Events:ADDON_LOADED(name)
	if name ~= Addon.name then
		return
	end
	Addon:InitializeSavedVariables()
	Addon:InitializeTagsForLocale("enGB")
	Addon:TrimRecordedEvents(60) -- older than 60m
	Addon:ReplayRecordedEvents(15) -- newer than 15m

	Addon:RemoveExpiredMessages(15) -- older than 15m
	C_Timer.NewTicker(60, function() -- every 60s
		Addon:RemoveExpiredMessages(15) -- older than 15m
		if LFGFrame.scrollFrame.isInitialized then
			LFGFrame.scrollFrame.update()
		end
	end)
end

function Events:CHAT_MSG_CHANNEL(...)
	local timestamp = time()
	if not Addon.savedVariablesInitialized then
		return
	end
	--Addon:RemoveExpiredMessages(15) -- older than 15m
	local recordedEvent = Addon:RecordEvent(timestamp, ...)
	if recordedEvent then
		local newMessage = Addon:InstantiateMessageFromRecordedEvent(recordedEvent)
		--print("new message:", newMessage)
		--Addon:InstantiateMessageFromEvent({...}, timestamp) -- fresh, so don't have to give playerInfo

		Addon:Refilter(not LFGFrameScrollFrame:IsVisible()) -- only do a "data update", if the scroll frame isn't visible
	end
end

function Events:CHAT_MSG_SYSTEM(...)
	if not Addon.savedVariablesInitialized then
		return
	end
	local name, level, guild = Addon:ParseWhoResponse(...)
	if not name then
		return
	end
	local player = Addon:GetPlayerForName(name) -- not passing playerInfo means do not create new player if doesn't exist
	if not player then
		return
	end
	if level then
		player.level = level
	end
	if guild then
		player.guild = guild
	end
	if GameTooltip.__lfgplayer == player then
		--if GameTooltip:GetOwner() then
			Addon:SetPlayerToTooltip(GameTooltip, GameTooltip:GetOwner(), player)
		--end
	end
end

function Events:GROUP_ROSTER_UPDATE(...)
	if GetNumSubgroupMembers(LE_PARTY_CATEGORY_HOME) == MAX_PARTY_MEMBERS and LFGFrameNotifyToggleFrameCheckButton:GetChecked() then
		LFGFrameNotifyToggleFrameCheckButton:SetChecked(false)
		SendSystemMessage("No longer showing messages for selected dungeons.")
	end
end
