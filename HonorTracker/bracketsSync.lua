local ADDON_NAME, HonorTracker = ...
local BracketsSync = HonorTracker:RegisterModule("BracketsSync")
local AceSerializer = LibStub("AceSerializer-3.0")
local Comms = HonorTracker:GetModule("Comms")
local PLAYER_NAME = UnitName("player")
local MAX_BOOTSTRAP_REQUEST_TIME = 3600 * 6
local ADDON_VERSION = GetAddOnMetadata(ADDON_NAME, "Version")
local L = HonorTracker.L

local throttles = {}
local pongsReceived
local receivedDataFrom

function BracketsSync:CountPlayerData(fromSender)
    local totalFromSender = 0
    local totalPlayers = 0
    local totalPlayersToday = 0

    for name, data in pairs(self.realmBracketDB.players) do
        totalPlayers = totalPlayers + 1
        if( data.lastChecked >= self.db.resetTime.dailyStart ) then
            totalPlayersToday = totalPlayersToday + 1
        end

        if( self.realmBracketDB.playersMeta[name].sender == fromSender ) then
            totalFromSender = totalFromSender + 1 
        end
    end

    return totalPlayers, totalPlayersToday, totalFromSender
end

function BracketsSync:OnLoad()
    if( not self.db.config.debugMode ) then
        return
    end

    -- Don't bootstrap on the weekly reset
    if( self.db.resetTime.weeklyStart == self.db.resetTime.dailyStart ) then
        self:Debug(1, "Skipping bootstrap since the week just started.")
        return
    -- Don't try and bootstrap too frequently
    elseif( self.realmBracketDB.lastBootstrapped and (GetServerTime() - self.realmBracketDB.lastBootstrapped) <= MAX_BOOTSTRAP_REQUEST_TIME ) then
        self:Debug(1, "Skipping bootstrap, it's been too soon.")
        return
    end

    self:Debug(1, "Starting bootstrap process")

    pongsReceived = {}
    Comms:SendMessage("ping", {})
    
    -- Wait 10 seconds for the first phase which is getting a player list
    self.timerFrame = self.timerFrame or CreateFrame("Frame")
    self.timerFrame.timeElapsed = 0
    self.timerFrame:SetScript("OnUpdate", function(self, elapsed)
        self.timeElapsed = self.timeElapsed + elapsed
        if( self.timeElapsed < 10 ) then return end
        self:SetScript("OnUpdate", nil)

        BracketsSync:BootstrapPingsDone()
    end)
end

function BracketsSync:BootstrapPingsDone()
    -- Summarize and figure out who we're bootstrapping from
    local totalPings = 0
    local bestCandidate
    local directWhisper = false

    for name, data in pairs(pongsReceived) do
        totalPings = totalPings + 1

        if( not self.realmBracketDB.bootstrapIgnored[bestCandidate] or (self.realmBracketDB.bootstrapIgnored[bestCandidate] < GetServerTime()) ) then
            if( not bestCandidate or data.totalPlayersToday > pongsReceived[bestCandidate].totalPlayersToday ) then
                bestCandidate = name

                -- v3.2 is broken and ignores whispers when we're in the same guild.
                -- if we see that, we will just do a guild request.
                directWhisper = data.version ~= "v3.2"
            end
        end
    end 

    if( totalPings == 0 ) then
        self:Debug(1, "Did not receive any pings within 10 seconds.")
        return
    end

    self:Debug(1, "Received %d pings after 10 seconds, picking %s who has %d players from today", totalPings, bestCandidate, pongsReceived[bestCandidate].totalPlayersToday)
    
    -- Now get ready to actually bootstrap
    pongsReceived = nil
    receivedDataFrom = {}

    if( directWhisper ) then
        Comms:SendPrivateMessage(sender, "bootstrap", {})
    else
        Comms:SendMessage("bootstrap", {})
    end

    self.realmBracketDB.lastBootstrapped = GetServerTime()

    local totalPlayers, totalPlayersToday, totalFromSender = BracketsSync:CountPlayerData(bestCandidate)

    -- Wait 60 seconds and then trigger our done phase
    self.timeElapsed = 0
    self.timerFrame:SetScript("OnUpdate", function(self, elapsed)
        self.timeElapsed = self.timeElapsed + elapsed
        if( self.timeElapsed < 30 ) then return end
        self:SetScript("OnUpdate", nil)

        BracketsSync:BootstrapDone(bestCandidate, totalPlayers, totalPlayersToday, totalFromSender)
    end)
end

function BracketsSync:BootstrapDone(requestedFrom, totalPlayers, totalPlayersToday, totalFromSender)
    local totalReceived = receivedDataFrom[requestedFrom]
    receivedDataFrom = nil

    -- No data received.
    if( not totalReceived ) then
        self:Debug(1, "Did not receive any data from %s, resetting our bootstrap timer and ignoring %s for now", requestedFrom, requestedFrom)

        self.realmBracketDB.bootstrapIgnored[requestedFrom] = GetServerTime() + MAX_BOOTSTRAP_REQUEST_TIME
        self.realmBracketDB.lastBootstrapped = nil
        return
    end

    local nowTotalPlayers, nowTotalPlayersToday, nowTotalFromSender = BracketsSync:CountPlayerData(requestedFrom)

    self:Debug(1, "Finished bootstrapping, received %d player records, %d new players, %d updated today and %d from %s specifically",
        totalReceived,
        (nowTotalPlayers - totalPlayers),
        (nowTotalPlayersToday - totalPlayersToday),
        (nowTotalFromSender - totalFromSender),
        requestedFrom
    )
end

-- Someone is requesting our data
function BracketsSync:Ping(sender, distributionType)
    local currentTime = GetServerTime()
    local totalPlayers = 0
    local totalPlayersToday = 0
    for name, data in pairs(self.realmBracketDB.players) do
        totalPlayers = totalPlayers + 1

        if( data.lastChecked >= self.db.resetTime.dailyStart ) then
            totalPlayersToday = totalPlayersToday + 1
        end
    end

    self:Debug(1, "Received ping from %s (via %s), responding with %d players, %d from today (version %s)", sender, distributionType, totalPlayers, totalPlayersToday, ADDON_VERSION)

    local response = {
        totalPlayers = totalPlayers,
        totalPlayersToday = totalPlayersToday,
        combat = InCombatLockdown(),
        allowed = not throttles[requester] or (GetServerTime() - throttles[requester]) <= MAX_BOOTSTRAP_TIME,
        version = ADDON_VERSION
    }

    if( distributionType == "WHISPER" ) then
        Comms:SendPrivateMessage(sender, "pong", response)
    else
        Comms:SendMessage("pong", response)
    end
end

function BracketsSync:Pong(sender, distributionType, data)
    self:Debug(1, "Received pong from %s (via %s), has %d players, %d from today, in combat %s, allowed %s, version %s",
        sender,
        distributionType,
        data.totalPlayers or -1,
        data.totalPlayersToday or -1,
        data.combat == nil and "nil" or data.combat == true and "true" or "false",
        data.allowed == nil and "nil" or data.allowed == true and "true" or "false",
        data.version or "??"
    )

    if( pongsReceived ) then
        pongsReceived[sender] = data
    end
end

-- Bootstrap another players data set
function BracketsSync:BootstrapData(requester)
    -- Only allow people to request a bootstrap every 6 hours
    local currentTime = GetServerTime()
    if( throttles[requester] and (GetServerTime() - throttles[requester]) <= MAX_BOOTSTRAP_TIME) then
        self:Debug(1, "Ignoring bootstrap request from %s, as it's only been %d seconds since last request", requester, (GetServerTime() - throttles[requester]))
        return
    end

    -- Find all players we have data for
    local total = 0
    for name, data in pairs(self.realmBracketDB.players) do
        total = total + 1

        Comms:SendPrivatePlayerData(requester, name, data)
    end

    Comms:SendPrivateMessage(sender, "bootstrapped", {})

    self:Debug(1, "Sent %d players to %s", total, requester)
end

-- Convert HonorSpy into our format
function BracketsSync:HandleHonorSpy(sender, distributionType, playerName, data)
    -- Never allow someone to overwrite our own data
    if( playerName == PLAYER_NAME ) then return end

    if( type(playerName) ~= "string" ) then return end
    if( string.match(playerName, "[%p%s%c%z]") ) then return end
    if( string.len(playerName) >= 20 ) then return end
    if( type(data.last_checked) ~= "number" or data.last_checked > GetServerTime() ) then return end
    if( type(data.RP) ~= "number" or type(data.rankProgress) ~= "number" or type(data.rank) ~= "number" ) then return end
    if( type(data.class) ~= "string" or not RAID_CLASS_COLORS[data.class] ) then return end
    if( type(data.standing) ~= "number" or type(data.lastWeekHonor) ~= "number" or type(data.thisWeekHonor) ~= "number" ) then return end

    local convertedData = {
        class = data.class,
        lastChecked = data.last_checked,
        rankPoints = data.RP,
        rankProgress = data.rankProgress,
        rank = data.rank,
        thisWeek = {
            honor = data.thisWeekHonor,
            kills = 15, -- HonorSpy only gives us an assumption that they hit 15
        },
        lastWeek = {
            standing = data.standing,
            honor = data.lastWeekHonor,
        }
    }

    self:PersistData("HonorSpy", sender, distributionType, playerName, convertedData)
end

-- Save our own data format
function BracketsSync:HandleHonorTracker(sender, distributionType, playerName, data)
    if( type(playerName) ~= "string" ) then return end

    -- Never allow someone to overwrite our own data
    if( playerName == PLAYER_NAME ) then return end
    if( string.len(playerName) >= 20 ) then return end
    if( string.match(playerName, "[%p%s%c%z]") ) then return end

    data = Comms:DeserializePlayerData(data)
    if( not data ) then return end

    if( receivedDataFrom ) then
        receivedDataFrom[sender] = receivedDataFrom[sender] or 0
        receivedDataFrom[sender] = receivedDataFrom[sender] + 1
    end

    self:PersistData("HonorTracker", sender, distributionType, playerName, data)
end

function BracketsSync:PersistData(sourceType, sender, distributionType, playerName, data)
    -- Do basic sanity checks and if we see anything unusual then just automatically ban them.
    if( data.thisWeek.kills >= 100000 or
        data.thisWeek.kills < 0 or
        data.thisWeek.honor >= 10000000 or
        data.thisWeek.honor < 0 or
        data.rankPoints > 70000 or
        data.rankPoints < 0 or
        data.rank > 14 or
        data.rank < 0 or
        data.rankProgress < 0 or
        data.rankProgress > 1 or
        data.lastWeek.standing < 0 or
        data.lastWeek.standing > 100000 or
        data.lastWeek.honor > 10000000 or
        data.lastWeek.honor < 0
    ) then
        self:Print(string.format(L["Detected bad data from %s, auto-banning them."], sender))
        self.realmBracketDB.senderBlacklist[sender] = true
        return
    end

    if( self.realmBracketDB.disableDataSyncing ) then
        self:Debug(3, "Rejecting %s from %s (via %s, %s) because data syncing is disabled for a day", playerName, sender, sourceType, distributionType)
        return
    elseif( data.lastChecked <= (self.db.resetTime.weeklyStart + 86400) ) then
        self:Debug(3, "Rejecting %s from %s (via %s, %s) because it's from last weeks reset", playerName, sender, sourceType, distributionType)
        return
    end

    local existingData = self.realmBracketDB.players[playerName]

    -- Filter out data when ours is newer
    if( existingData and existingData.lastChecked >= data.lastChecked ) then
        if( sourceType == "HonorTracker" ) then
            self:Debug(3, "Skipping %s from %s (via %s, %s) because our own data is newer (%d vs %d)", playerName, sender, sourceType, distributionType, existingData.lastChecked, data.lastChecked)
        end
        return
    end

    local trustedSource = distributionType == "GUILD"
    local metadata = self.realmBracketDB.playersMeta[playerName]
    if( metadata ) then
        -- If we've seen the person today then our data takes priority
        if( metadata.seenToday ) then
            if( sourceType == "HonorTracker" ) then
                self:Debug(2, "Skipping %s from %s (via %s, %s) because our own data is fresh", playerName, sender, sourceType, distributionType)
            end
            return
        end

        if( metadata.trustedSource and not trustedSource ) then
            -- We have trusted data which is current as of todays reset
            if( existingData and existingData.lastChecked >= self.db.resetTime.dailyStart ) then
                if( sourceType == "HonorTracker" ) then
                    self:Debug(3, "Skipping %s from %s (via %s, %s) because our trusted data is current", playerName, sender, sourceType, distributionType)
                end
                return
            else
                if( sourceType == "HonorTracker" ) then
                    self:Debug(2, "Syncing %s from %s (via %s, %s) because our trusted data is not current to the reset", playerName, sender, sourceType, distributionType)
                end
            end
        end
    end
    
    if( not existingData or existingData.thisWeek.honor ~= data.thisWeek.honor or sourceType == "HonorTracker" ) then
        self:Debug(1, "Recording %s (RP = %d, HK = %d, Honor = %d) from %s (via %s, %s), data is %s seconds old", playerName, data.rankPoints, data.thisWeek.kills, data.thisWeek.honor, sender, sourceType, distributionType, (GetServerTime() - data.lastChecked))
    end

    self.realmBracketDB.playersMeta[playerName] = self.realmBracketDB.playersMeta[playerName] or {}
    self.realmBracketDB.playersMeta[playerName].sender = sender
    self.realmBracketDB.playersMeta[playerName].trustedSource = trustedSource
    self.realmBracketDB.players[playerName] = data
    HonorTracker:Trigger("OnBracketDBUpdate", playerName)
end

function BracketsSync:OnMessage(sender, distributionType, type, ...)
    -- Resync against HonorSpy format
    if( type == "HonorSpy" ) then
        -- Only use GUILD if internal comms are enabled
        if( self.db.config.internalComms and distributionType ~= "GUILD" ) then return end

        local playerName, data = ...
        if( playerName == "filtered_players" ) then
            for playerName, player in pairs(data) do
                self:HandleHonorSpy(sender, distributionType, playerName, player)
            end
        else
            self:HandleHonorSpy(sender, distributionType, playerName, data)
        end
    elseif( type == "push" ) then
        -- Only use GUILD if internal comms are enabled
        if( self.db.config.internalComms and distributionType ~= "GUILD" ) then return end

        self:HandleHonorTracker(sender, distributionType, unpack(...))
    elseif( type == "bootstrap" ) then
        self:BootstrapData(sender)
    elseif( type == "bootstrapped" ) then
        -- TODO
    elseif( type == "ping" ) then
        self:Ping(sender, distributionType)
    elseif( type == "pong" ) then
        -- Only use GUILD if internal comms are enabled
        if( self.db.config.internalComms and distributionType ~= "GUILD" ) then return end

        self:Pong(sender, distributionType, ...)
    end
end
