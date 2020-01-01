local HonorTracker = select(2, ...)
local SlashConfig = HonorTracker:RegisterModule("SlashConfig")
local Stats = HonorTracker:GetModule("Stats")
local Brackets = HonorTracker:GetModule("Brackets")
local BracketUI = HonorTracker:GetModule("BracketUI")
local Comms = HonorTracker:GetModule("Comms")
local Config = HonorTracker:GetModule("Config")
local L = HonorTracker.L

function SlashConfig:ShowStanding(name)
    if( name == "%t" and UnitExists("target") ) then
        name = UnitName("target")
    elseif( not name or name == "" ) then
        name = UnitName("player")
	end
	
	if( UnitExists(name) and UnitRealmRelationship(name) ~= 1 ) then
		HonorTracker:Print(L["You cannot view data for %s, since they are on a different realm."])
		return
	end

    local sumAges = 0
    local totalPlayers = 0
    local topHonorName = nil
    for checkName, checkData in pairs(self.realmBracketDB.players) do
        sumAges = sumAges + (GetServerTime() - checkData.lastChecked)
        totalPlayers = totalPlayers + 1

        local topHonorData = self.realmBracketDB.players[topHonorName]
        if( not topHonorData or checkData.thisWeek.honor > topHonorData.thisWeek.honor ) then
            topHonorName = checkName
        end
    end

    if( totalPlayers == 0 ) then
        HonorTracker:Print(L["No data found yet. If the week just reset, you need to wait until other players start logging in."])
        return
    end

    local estimate = Brackets:Estimate(name)
    if( estimate ) then
        local existingData = self.realmBracketDB.players[name]
        HonorTracker:Print(
            string.format(
                L["|cff33ff99%s|r: Estimated standing %d (bracket %d), going from %s -> %s, pool size %d |4player:players;."],
                name,
                estimate.standing,
				estimate.bracket,
				Stats:RankPointsToRank(existingData.rankPoints),
				Stats:RankPointsToRank(estimate.rankPoints),
				totalPlayers
            ),
            true
        )
    else
        HonorTracker:Print(string.format(L["|cff33ff99%s|r: Cannot find any data"], name), true)
    end
end

function SlashConfig:Parse(msg)
	local type, data = string.split(" ", msg, 2)
	if( type ) then type = string.lower(type) end

	if (type == "show" ) then
		BracketUI:Show()		
	elseif (type == "standing") then
		self:ShowStanding(data)
	elseif (type == "today") then
		HonorTracker:Print(
			string.format(
				L["Estimate for today: %d (%d in objectives)"],
				math.floor(self.db.today.honor.total or 0),
				math.floor(self.db.today.honor.objectives or 0)
			)
		)
		
		local stats = Stats:CalculateToday()
		if( stats.battlegrounds and stats.battlegrounds.OVERALL ) then
			HonorTracker:Print(
				string.format(
					L["Played %d battlegrounds, won %d (%.2f%% win rate), avg %d honor/game"],
					stats.battlegrounds.OVERALL.total,
					stats.battlegrounds.OVERALL.wins,
					stats.battlegrounds.OVERALL.winPercent * 100,
					stats.battlegrounds.OVERALL.avgHonor.total
				)
			)
		end

		HonorTracker:Print(
			string.format(
				L["Recorded %d kills (avg %.2f honor per kill) across %d players (avg %.2f kills and %.2f honor per player)"],
				stats.recordedKills,
				stats.avgHonorPerKill,
				stats.uniquePlayers,
				stats.avgKillsPerPlayer,
				stats.avgHonorPerPlayer
			)
		)

	elseif (type == "week" or type == "this-week") then
		if( #(self.db.thisWeek) == 0 ) then
			HonorTracker:Print(L["No data yet, wait for the next daily honor reset for data."])
			return
		end

		HonorTracker:Print(L["This Weeks Daily Stats"])
		Stats:DumpDailySummary(self.db.thisWeek)

	elseif (type == "last-week") then
		if( #(self.db.lastWeek) == 0 ) then
			HonorTracker:Print(L["No data yet, wait for the weekly honor reset for data."])
			return
		end

		HonorTracker:Print(L["Last Weeks Daily Stats"])
		Stats:DumpDailySummary(self.db.lastWeek)
	elseif (type == "debug" ) then
		if( not data or data == "" ) then
			HonorTracker.db.config.debugMode = nil
		else
			HonorTracker.db.config.debugMode = tonumber(data)
		end

		if( HonorTracker.db.config.debugMode ) then
			HonorTracker:Print(string.format("Debug level is now %d", HonorTracker.db.config.debugMode))
		else
			HonorTracker:Print("Debug mode is now disabled.")
		end	
	elseif (type == "reset" ) then
		HonorTracker:Print(L["Honor Reset Periods (Server Time)"])
		DEFAULT_CHAT_FRAME:AddMessage(string.format(L["Now: %s"], date("%x %X", GetServerTime())))
		DEFAULT_CHAT_FRAME:AddMessage(string.format(L["Daily Reset On: %s"], date("%x %X", HonorTracker.db.resetTime.dailyEnd)))
		DEFAULT_CHAT_FRAME:AddMessage(string.format(L["Weekly Reset On: %s"], date("%x %X", HonorTracker.db.resetTime.weeklyEnd)))

	elseif (type == "config") then
		Config:Show()
	else
		HonorTracker:Print(L["/honortracker (/ht) commands:"])
		DEFAULT_CHAT_FRAME:AddMessage(L["/ht standing [name] - View an individual players standing and progression report"])
		DEFAULT_CHAT_FRAME:AddMessage(L["/ht today - Estimate of your honor earned today"])
		DEFAULT_CHAT_FRAME:AddMessage(L["/ht this-week - Show a history of your honor gains for the current week"])
		DEFAULT_CHAT_FRAME:AddMessage(L["/ht last-week - Show a history of your honor gains for the last week"])
		DEFAULT_CHAT_FRAME:AddMessage(L["/ht config - Open the configuration"])
		DEFAULT_CHAT_FRAME:AddMessage(L["/ht show - View the current standings and brackets for this week"])
	end
end

SLASH_HONORTRACKER1 = "/honortracker"
SLASH_HONORTRACKER2 = "/honortrack"
SLASH_HONORTRACKER3 = "/ht"
SLASH_HONORTRACKER4 = "/hgt"
SlashCmdList["HONORTRACKER"] = function(msg)
	SlashConfig:Parse(msg)
end
