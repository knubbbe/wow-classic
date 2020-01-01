local HonorTracker = select(2, ...)
local ResetTime = HonorTracker:RegisterModule("ResetTime")

function ResetTime:GetUTCTime(override, value)
	local utcParts = date("!*t")
	utcParts.min = 0
	utcParts.sec = 0

	if( override ) then
		utcParts[override] = value
	end

	return time(utcParts)
end

function ResetTime:NowUTC()
	return time(date("!*t"))
end

function ResetTime:UTCToServer(utcTime)
	local timeOffset = GetServerTime() - time(date("!*t"))
	return utcTime + timeOffset
end

function ResetTime:ServerToLocal(serverTime)
	local timeOffset = time() - GetServerTime()
	return serverTime + timeOffset
end

-- In US locales, Monday is wday 1, while Lua documentation says Sunday is wday 1.
-- I'm guessing this is localization semantics, so we take UTC Monday, and if it's wday 1
-- then we're ok, otherwise we assume it's wday 2 and we need to shift back one
function ResetTime:ProperDayOfWeek(utcTime)
	if( not self.dayOfWeekOffset ) then
		if( date("%w", 1577760000) == "1" ) then
			self.dayOfWeekOffset = 0
		else
			self.dayOfWeekOffset = -1
		end
	end

	dayOfWeek = tonumber(date("%w", utcTime)) + self.dayOfWeekOffset
	-- If it's Sunday in a locale where Sunday is wday=1, then our offset is -1
	-- which puts us at 0 and that's obviously invalid, we need to shift Sunday to be 7 in this case.
	if( dayOfWeekOffset == 0 ) then
		return 7
	else
		return dayOfWeek
	end
end

-- For the purposes of this function, Monday is wday=1 and Sunday is wday=7
function ResetTime:WeeklyWindow(withServerTime)
	local maintenanceDay
	-- United States, Oceania and Brazil are all on Tuesday
	if( GetCurrentRegion() == 1 ) then
		maintenanceDay = 2 -- Tuesday
	else
		maintenanceDay = 3 -- Wednesday
	end
	
	local dailyWindowStart = self:DailyWindow()
	local utcDayofWeek = self:ProperDayOfWeek(dailyWindowStart)
	local utcStart, utcEnd

	-- Maintenance day!
	if( utcDayofWeek == maintenaceDay ) then
		utcStart = dailyWindowStart
		utcEnd = utcStart + (86400 * 7)
	-- Similar to DailyWindow, if week day is less than to maintenance day
	-- it's the prior week still and the offset needs to be the missing number of days
	--
	-- If it's Monday in the US (wday=1), then we need to add 1 day because maintenaceDay-wday=1
	-- and that will get us to the weekly window end, and then we subtract 7 days and it gets us the start
	elseif( utcDayofWeek < maintenanceDay ) then
		daysBeforeMaintenance = maintenanceDay - utcDayofWeek
		utcEnd = dailyWindowStart + (daysBeforeMaintenance * 86400)
		utcStart = utcEnd - (86400 * 7)
	-- Otherwise if it's Thursday (wday=4), then we need to figure out the days after maintenance
	-- which is (utcDayofWeek - maintenanceDay) or 2 in this case, and then shift backwards 2 days
	-- to get utcStart, and add 7 days to get utcEnd
	else
		daysAfterMaintenance = utcDayofWeek - maintenanceDay

		utcStart = dailyWindowStart - (daysAfterMaintenance * 86400)
		utcEnd = utcStart + (86400 * 7)
	end

	local timeOffset = 0
	if( withServerTime ) then
		timeOffset = (GetServerTime() - time(date("!*t")))
	end

	return utcStart + timeOffset, utcEnd + timeOffset
end

function ResetTime:DailyWindow(withServerTime)
	-- Default to US
	local resetHour = 16

	-- United States, Oceania, Brazil
	if( GetCurrentRegion() == 1 ) then
		resetHour = 16
	-- Europe, Russia
	elseif( GetCurrentRegion() == 3 ) then
		resetHour = 7
	-- China
	elseif( GetCurrentRegion() == 5 ) then 
		resetHour = 8
	-- Korea
	elseif( GetCurrentRegion() == 2 ) then 
		-- Guessing off of China
		resetHour = 9
	-- Taiwan
	elseif( GetCurrentRegion() == 4 ) then
		-- Guessing off of China
		resetHour = 8
	end

	-- Assuming an US server where utcNow is Monday at 14:00 UTC
	local utcNow = self:GetUTCTime()

	-- Then utcReset would be Monday at 16:00 UTC
	local utcReset = self:GetUTCTime("hour", resetHour)

	local utcStart, utcEnd

	-- Meaning if utcNow is less than utcReset, then utcReset is the end time and we subtract 24 hours
	-- to get the start
	if( utcNow <= utcReset ) then
		utcStart = utcReset - 86400
		utcEnd = utcReset
	-- while if utcNow is greater than utcReset, then we flip that
	else
		utcStart = utcReset
		utcEnd = utcReset + 86400
	end

	local timeOffset = 0
	if( withServerTime ) then
		timeOffset = (GetServerTime() - time(date("!*t")))
	end

	return utcStart + timeOffset, utcEnd + timeOffset
end
