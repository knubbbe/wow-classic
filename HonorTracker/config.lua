local HonorTracker = select(2, ...)
local Config = HonorTracker:RegisterModule("Config")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")
local AceConfig = LibStub("AceConfig-3.0")
local AceRegistry = LibStub("AceConfigRegistry-3.0")
local Brackets = HonorTracker:GetModule("Brackets")
local ResetTime = HonorTracker:GetModule("ResetTime")

local L = HonorTracker.L
local initialOptionsFrame, options

function Config:UpdateOptions()
	local totalBlacklisted = 0
	for name, _ in pairs(self.realmBracketDB.senderBlacklist) do
		totalBlacklisted = totalBlacklisted + 1

		options.args.blacklist.args.list.args[name] = {
			order = 1,
			type = "execute",
			name = name,
			func = function(info)
				Config.realmBracketDB.senderBlacklist[name] = nil
				Config:UpdateOptions()
			end,
		}
	end

	for name, _ in pairs(options.args.blacklist.args.list.args) do
		if( name ~= "_help" and not self.realmBracketDB.senderBlacklist[name] ) then
			options.args.blacklist.args.list.args[name] = nil
		end
	end

	if( totalBlacklisted == 0 ) then
		options.args.blacklist.args.list.args._help.name = L["You have not blacklisted data from anyone yet."]
	else
		options.args.blacklist.args.list.args._help.name = string.format(L["Below is the %d |4player:players; you have blacklisted receiving data from."], totalBlacklisted)
	end

	AceRegistry:NotifyChange("HonorTracker")
end

function Config:Show()
	if( not InterfaceOptionsFrame:IsVisible() ) then
		InterfaceOptionsFrame_Show()
	end

	self:UpdateOptions()
	InterfaceOptionsFrame_OpenToCategory(initialOptionsFrame)
end

-- Setup the options frame parent
local containerFrame = CreateFrame("Frame", nil, InterfaceOptionsFrame)
containerFrame.name = "HonorTracker"
containerFrame:SetScript("OnShow", function() Config:Show() end)
containerFrame:Hide()
InterfaceOptions_AddCategory(containerFrame)

-- Create the options menu child frames
options = {
	type = "group",
    args = {
		general = {
			type = "group",
			name = L["General"],
			set = function(info, value)
				HonorTracker.db.config[info[#(info)]] = value
			end,
			get = function(info)
				return HonorTracker.db.config[info[#(info)]]
			end,
			args = {
				tooltips = {
					order = 1,
					type = "toggle",
					name = L["Show DR Tooltips"],
					desc = L["Displays how many times you have killed someone on mouseover tooltips."],
					width = "full",
				},				
				internalComms = {
					order = 2,
					type = "toggle",
					name = L["Sync using only guild channels"],
					desc = L["Only syncs new player data using guild channels, useful when random people are spamming bad data."],
					width = "full",
				},
				batchHonor = {
					order = 3,
					type = "toggle",
					name = L["Batch honor gain messages together in combat"],
					desc = L["While in combat, you will not see any honor gain messages, and once you leave combat you'll get a summary of honor gained."],
					width = "full",
				},
			}
		},
		dailyReset = {
			type = "group",
			name = L["Daily Reset"],
			args = {
				help = {
					order = 0,
					type = "group",
					inline = true,
					name = L["Help"],
					args = {
						help1 = {
							order = 0,
							type = "description",
							name = L["Blizzard periodically has problems during their resets, and they will have happened without the in-game values updating."],
						},
						help2 = {
							order = 0,
							type = "description",
							name = L["In some areas we will use the actual time it's supposed to roll over, as a way of detecting a day change without relying on 'Yesterday' data updating."],
						},
					},
				},
				timing = {
					order = 1,
					type = "group",
					inline = true,
					name = L["Reset Window"],
					args = {
						now = {
							order = 0,
							type = "description",
							name = function()
								return string.format(L["Your Time: |cffffd100%s|r\n\nServer Time: |cffffd100%s|r\nNext Daily Reset: |cffffd100%s|r\nNext Weekly Reset: |cffffd100%s|r"],
									date("%x %X", time()),
									date("%x %X", GetServerTime()),
									date("%x %X", HonorTracker.db.resetTime.dailyEnd),
									date("%x %X", HonorTracker.db.resetTime.weeklyEnd)
								)
							end,
						},
						help = {
							order = 1,
							type = "description",
							name = string.format(L["If the values for the above are not correct, please let us know on CurseForge and give your region ID of '%d'."], GetCurrentRegion())
						}
					},
				},
			}
		},
		blacklist = {
			type = "group",
			name = L["Blacklist"],
			set = function(info, value)
				HonorTracker.db.config[info[#(info)]] = value
			end,
			get = function(info)
				return HonorTracker.db.config[info[#(info)]]
			end,
			args = {
				help = {
					order = 0,
					type = "group",
					inline = true,
					name = L["Help"],
					args = {
						help = {
							order = 0,
							type = "description",
							name = L["On some servers, people will send fake data which corrupts your database. You can ignore their data here, which will also automatically delete any recorded data from them."],
						},
					},
				},
				add = {
					order = 1,
					name = L["Add to Blacklist"],
					inline = true,
					type = "group",
					set = function(info, value) Config.addToBlacklistName = value end,
					get = function(info) return Config.addToBlacklistName end,
					args = {
						name = {
							order = 0,
							type = "input",
							name = L["Player name"],
							desc = L["The player name to blacklist receiving data from."],
						},
						add = {
							order = 1,
							type = "execute",
							name = L["Add"],
							disabled = function() return not Config.addToBlacklistName or Config.addToBlacklistName == "" or Config.addToBlacklistName == UnitName("player") end,
							func = function(info)
								name = string.trim(Config.addToBlacklistName)
								name = name ~= "" and name or nil

								Config.realmBracketDB.senderBlacklist[name] = true
								Config.addToBlacklistName = nil

								Brackets:PurgeBlacklistedData()
								Config:UpdateOptions()
							end,
						},
					},
				},
				list = {
					order = 2,
					name = L["Blacklist"],
					inline = true,
					type = "group",
					args = {
						_help = {
							order = 0,
							type = "description",
							name = "",
						}
					}
				}
			}
		}
    }
}

AceConfig:RegisterOptionsTable("HonorTracker", options)
initialOptionsFrame = AceConfigDialog:AddToBlizOptions("HonorTracker", options.args.general.name, "HonorTracker", "general")
AceConfigDialog:AddToBlizOptions("HonorTracker", options.args.dailyReset.name, "HonorTracker", "dailyReset")
AceConfigDialog:AddToBlizOptions("HonorTracker", options.args.blacklist.name, "HonorTracker", "blacklist")
