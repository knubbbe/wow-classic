local _, Addon = ...

-- Debugging facilities

function Addon.messages:GetDebugName()
	local debugString = #self.." messages"
	local latestMessage = self[#self]
	if latestMessage then
		debugString = debugString..". Latest message: ["..latestMessage.player.name.."]: "..latestMessage.text
	end
	return debugString
end
function Addon.players:GetDebugName()
	local debugString = #self.." players"
	local newestPlayer = self[#self]
	if newestPlayer then
		debugString = debugString..". Newest player: ["..newestPlayer.name.."]"
	end
	return debugString
end
function Addon.tags:GetDebugName()
	return #self.." tags"
end
LFGFrameTables = {
	messages = Addon.messages,
	players = Addon.players,
	tags = Addon.tags,
 -- history = SlashFourDBChar.history in Store.lua
}

--
-- Debugging & profiling performance
--

function Addon:SetDebugName(object, keyName, includeKeyNames)

	-- https://stackoverflow.com/questions/7526223/how-do-i-know-if-a-table-is-an-array#comment92335314_52697380
	-- thanks Vlad for the base "non-special" ;) implementation
	local function SpecialIsArray(t)
		local c = 0
		local f = 0
		for k, v in pairs(t) do
			if type(k) ~= "number" then
				if k == "GetDebugName" then
					f = 1
				else
					return false
				end
			end
			c = c + 1
		end
		return c == #t + f
	end


	if SpecialIsArray(object) then
		object.GetDebugName = function(self)
			local debugString = ""
			if keyName then
				--local count = #self
				--local pluralSuffix = count > 1 and "s" or ""
				debugString = debugString..#self.." "..keyName--..pluralSuffix
			else
				debugString =  "Count: "..#self
			end
			return debugString
		end
	else
		object.GetDebugName = function(self)
			local includeKeyNames = includeKeyNames and includeKeyNames or false
			local debugString = ""
			for key, value in pairs(self) do
				local valueType = type(value)
				local keyString = tostring(key)
				local keyPrefix = keyString.."="
				if valueType == "number" or valueType == "string" or valueType == "boolean" then
					keyPrefix = includeKeyNames and keyPrefix or ""
					debugString = debugString..keyPrefix..tostring(value)
				elseif valueType == "table" then
					if SpecialIsArray(value) then
						--local count = #value
						--local pluralSuffix = count > 1 and "s" or ""
						debugString = debugString..#value.." "..keyString--..pluralSuffix
					else
						keyPrefix = includeKeyNames and keyPrefix or ""
						debugString = debugString..keyPrefix..keyString.."*"
					end
				elseif valueType == "nil" then
					debugString = debugString..keyPrefix.."nil"
				else
					--debugString = debugString..keyPrefix.."N/A"
					-- this value won't be printed, but below we'll add a ", " for it,
					-- which we have to compensate for
					debugString = debugString:sub(1, -3)
				end
				debugString = debugString..", "
			end
			return debugString:sub(1, -3) -- remove last ", "
		end
	end
end

local profiles = {}
function Addon:ProfileWithIdentifier(identifier)
	local profile = profiles[identifier]
	if profile ~= nil then
		print(identifier, string.format("%.5f", debugprofilestop() - profile))
		profiles[identifier] = nil
		return
	end
	profiles[identifier] = debugprofilestop()
end

