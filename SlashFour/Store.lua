local _, Addon = ...

--
-- Storage
--

function Addon:InitializeSavedVariables()
	if SlashFourDBChar == nil then
		SlashFourDBChar = {}
		SlashFourDBChar.history = {}
	end
	Addon.savedVariablesInitialized = true
	-- debugging
	if Addon.debug then
		LFGFrameTables.history = SlashFourDBChar.history
		Addon:SetDebugName(LFGFrameTables.history, "events")
	end
end
function Addon:RecordEvent(timestamp, ...)
	if not select(12, ...) then return end -- don't record player-less chat events
	local recordedEvent = {
		timestamp = timestamp,
		args = {...},
		playerInfo = {GetPlayerInfoByGUID(select(12, ...))}
	}
	tinsert(SlashFourDBChar.history, recordedEvent)
	return recordedEvent
end
function Addon:ReplayRecordedEvents(minutesOld)
	local tooOld = time() - (minutesOld * 60)
	--local counter = 0 -- just for debugging
	for _, event in ipairs(SlashFourDBChar.history) do
		if event.timestamp > tooOld then
			-- pass saved playerInfo, since it can't necessarily be created at this (potentially very) later time, since playerGUIDs expire
			Addon:InstantiateMessageFromRecordedEvent(event)
			--counter = counter+1 -- debugging
		end
    end
    -- debugging
	--local _, _, _, timeAgoString = Addon:TimeAgoSince(tooOld)
	--print("Replayed", counter, "of", #SlashFourDBChar.history, "recorded events from within", timeAgoString)
end
function Addon:TrimRecordedEvents(minutesOld)
	local tooOld = time() - (minutesOld * 60)
	--local count = #SlashFourDBChar.history -- just for debugging
	--local counter = 0 -- just for debugging
	for i, event in ipairs(SlashFourDBChar.history) do
		if event.timestamp <= tooOld then
			tremove(SlashFourDBChar.history, i)
			--counter = counter+1
		else
			break
		end
    end
    -- debugging
	--local _, _, _, timeAgoString = Addon:TimeAgoSince(tooOld)
	--print("Trimmed", counter, "of", count, "recorded events older than", timeAgoString)
end
