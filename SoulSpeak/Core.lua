--[[

    
    SoulSpeak reacts to various soul events using emotes and quotes!
    Copyright (C) 2007-2019 Lilih @ Zandalar Tribe(EU) - Lilih @ Defias Brotherhood (EU)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.

    
--]]

SoulSpeak = {}
local SoulSpeakBlock = {}

local _, class = UnitClass("player")
if class ~= "WARLOCK" then return end

local L = LibStub("AceLocale-3.0"):GetLocale("SoulSpeak")
SoulSpeak = LibStub("AceAddon-3.0"):NewAddon("SoulSpeak", 'AceEvent-3.0', 'AceConsole-3.0', 'AceTimer-3.0')
local ssMMicon = LibStub("LibDBIcon-1.0")

BINDING_HEADER_SOULSPEAK = "SoulSpeak";
BINDING_NAME_SSOPTIONS = "Options";
BINDING_NAME_SSRELOADGFX = "Restart GFX engine";
BINDING_NAME_SSRELOADUI = "Reload UI";

--[[
*******************
* Local variables *
--]]
local db
local ss_target = ""
local ss_res = 0
local targetClass, englishClass
local genderTable
local	SSgenderTable1
local	SSgenderTable2
local	SSgenderTable3
local	SSgenderTable4
local DemonName = ""
local ssr_spell = GetSpellInfo(20707)
--local ssr_spell = GetSpellInfo(5697)  -- debug 'unending breath' spell
--local ssr_spell = GetSpellInfo(696)  -- debug 'demon skin ' spell

--[[
************************
* Local icon variables *
--]]
local icon = {
	"\124TInterface\\Icons\\Inv_misc_book_09:",
	"\124TInterface\\Icons\\inv_misc_rune_01:",
	"\124TInterface\\Icons\\spell_shadow_twilight:",
	"\124TInterface\\Icons\\Spell_holy_resurrection:",
	"\124TInterface\\Icons\\Spell_Shadow_SoulGem:",
	"\124TInterface\\Icons\\Spell_holy_resurrection:",
	"\124TInterface\\Icons\\inv_gizmo_01:",
}

--[[
************************
* Local styles for GUI *
--]]
local HearthstoneStyles = {
	"|cff00ff00"..L.ESBLINK, "|cffffd200"..L.ESSMILE, "|cffff2f32"..L.ESYAWN,
	"|cfff58cba"..L.ESWAVE, "|cffffdbad"..L.ESFAREWELL, "|cff7777aa"..L.ESTIRED, "|cff00ff00"..L.ESSMIRK,
	"|cffffd200"..L.ESPRAISE, "|cffff6b00"..L.ESLOVE,	"|cffff2f32"..L.ESLOST, "|cfff58cba"..L.ESKISS,
	"|cffffdbad"..L.ESGAZE,
}
local ResurrectedStyles = {
	"|cff00ff00"..L.ETTHANK, "|cffffd200"..L.ETHUG, "|cffff6b00"..L.ETBLINK, "|cffff2f32"..L.ETKISS,
	"|cfff58cba"..L.ETSMILE, "|cffffdbad"..L.ETPRAISE, "|cff7777aa"..L.ETLOVE, "|cff00ff00"..L.ETGAZE,
	"|cffffd200"..L.ETABSENT, "|cffff6b00"..L.ETPURR, "|cffff2f32"..L.ETSEXY, "|cfff58cba"..L.ETDANCE,
	"|cffffdbad"..L.ETBOW, "|cff7777aa"..L.ETCHEER,
}
local rrStyles = {
	"|cff00ff00"..L.ETCALM, "|cffffd200"..L.ETCOMFORT, "|cffff6b00"..L.ETCOMMEND, "|cffff2f32"..L.ETCONFUSED,
	"|cfff58cba"..L.ETCRY, "|cffffdbad"..L.ETCURIOUS, "|cff7777aa"..L.ETDROOL,
	"|cffffd200"..L.ETDISAPPOINMENT, "|cffff6b00"..L.ETMOURN, "|cffff2f32"..L.ETPANIC, "|cfff58cba"..L.ETPITTY,
	"|cffffdbad"..L.ETPRAYER, "|cff7777aa"..L.ETSURPRISED, "|cff00ff00"..L.ETVIOLIN, "|cffffd200"..L.ETWAIT,
}
local rsStyles = {
	"|cff00ff00"..L.ESBECKON, "|cffffd200"..L.ESBLINK, "|cffff6b00"..L.ESBOGGLE, "|cffff2f32"..L.ESBOUNCE, "|cfff58cba"..L.ESCACKLE, "|cffffdbad"..L.ESCHEER, "|cff7777aa"..L.ESCLAP,
	"|cff00ff00"..L.ESGRIN, "|cffffd200"..L.ESSMILE, "|cffff6b00"..L.ESSMIRK, "|cffff2f32"..L.ESSNICKER, "|cfff58cba"..L.ESWAIT, "|cffffdbad"..L.ESWELCOME, "|cff7777aa"..L.ESWHISTLE,
}
local rsuStyles = {
	"|cff00ff00"..L.ESBECKON, "|cffffd200"..L.ESBLINK, "|cffff6b00"..L.ESBOGGLE, "|cffff2f32"..L.ESBOUNCE, "|cfff58cba"..L.ESCACKLE, "|cffffdbad"..L.ESCHEER, "|cff7777aa"..L.ESCLAP,
	"|cff00ff00"..L.ESGRIN, "|cffffd200"..L.ESSMILE, "|cffff6b00"..L.ESSMIRK, "|cffff2f32"..L.ESSNICKER, "|cfff58cba"..L.ESWAIT, "|cffffdbad"..L.ESWELCOME, "|cff7777aa"..L.ESWHISTLE,
}
local SUMpEmoteStyles = {
	"|cff00ff00"..L.ESBLINK, "|cffffd200"..L.ESBOUNCE, "|cffff6b00"..L.ESCACKLE, "|cffff2f32"..L.ESCHEER, "|cfff58cba"..L.ESCLAP, "|cffffdbad"..L.ESGRIN,
	"|cff7777aa"..L.ESSMILE, "|cff00ff00"..L.ESSHRUG, "|cffffd200"..L.ESSIGH, "|cffff6b00"..L.ESSNICKER, "|cffff2f32"..L.ESSMIRK, "|cfff58cba"..L.ESWHISTLE,
}
local Channels = {
	"|cffaaeeff"..L.PARTY, "|cffff6b00"..L.RAID, L.SOLO,
}
local PartyQuoteChannels = {
	"|cffaaeeff"..L.PARTY, L.SAY, "|cffff2f32"..L.YELL,
}
local RaidQuoteChannels = {
	"|cffaaeeff"..L.PARTY, "|cffff6b00"..L.RAID, L.SAY, "|cffff2f32"..L.YELL,
}
local SoloQuoteChannels = {
	"|cffffdbad"..L.CHAT, L.SAY, "|cffff2f32"..L.YELL,
}
local SoulSoloQuoteChannels = {
	"|cffffdbad"..L.CHAT, L.SAY, L.SAYWHISPER, "|cffff2f32"..L.YELL, "|cffff2f32"..L.YELLWHISPER,
}
local SoulPartyQuoteChannels = {
	"|cffaaeeff"..L.PARTY, "|cffaaeeff"..L.PARTYWHISPER, L.SAY, L.SAYWHISPER, "|cffff2f32"..L.YELL, "|cffff2f32"..L.YELLWHISPER,
}
local SoulRaidQuoteChannels = {
	"|cffaaeeff"..L.PARTY, "|cffaaeeff"..L.PARTYWHISPER, "|cffff6b00"..L.RAID, "|cffff6b00"..L.RAIDWHISPER, L.SAY,
	L.SAYWHISPER, "|cffff2f32"..L.YELL, "|cffff2f32"..L.YELLWHISPER,
}

--[[
*******************
* toggle settings *
--]]
local toggle_option = { 
	name = function(info) return SoulSpeak.GetName(info) end,
	desc = function(info)
		local i
		for i = 1,15 do
			if db.demonSettings[i].configname == info[#info-2] then
				return db.demonSettings[i].quote[tonumber(string.match(info[#info], "%d%d"))]
			end
		end
		for i = 2,2 do
			if db.ritualSettings[i].quote_configname == info[#info-2] then
				return db.ritualSettings[i].quote[tonumber(string.match(info[#info], "%d%d"))]
			end
		end
		for i = 2,6 do
			if db.soulstoneSettings[i].configname == info[#info-2] then
				return db.soulstoneSettings[i].quote[tonumber(string.match(info[#info], "%d%d"))]
			end
		end
	end,
	type = "input", get = "getSSopt", set = "setSSopt", disabled = "disSSopt",
}

--[[
***************
* minimap/LDB *
--]]
SoulSpeakBlock = LibStub("LibDataBroker-1.1"):NewDataObject("SoulSpeak", {
	type = "data source", text = "|cff00ff00SoulSpeak", icon = "Interface\\Icons\\Spell_Shadow_SoulGem",
	OnClick = function(self, button)
		if button == "LeftButton" and IsAltKeyDown() then
				RestartGx()
		elseif button == "LeftButton" then
			SoulSpeak.ssOnOff()
		elseif button == "RightButton" then
			if IsAltKeyDown() then
				ReloadUI()
			elseif IsControlKeyDown() and not db.ssLDB_options[1] then
  			db.ssLDB_options[1] = not db.ssLDB_options[1]
  			db.ssLDBbutton.hide = db.ssLDB_options[1]
  			ssMMicon:Hide("SoulSpeakBlock")
			else
				SoulSpeak.OpenOptions()
			end
		end
	end,
	OnTooltipShow = function(tooltip)
		local i, n, tt
		local color = "|cffff0000"
		if not db.ssLDB_options[3] then
			tooltip:SetText(icon[5].."14\124t SoulSpeak v"..GetAddOnMetadata("SoulSpeak", "version"),0.5,0.5,0.5,0.5,0)
		end
		tooltip:AddLine(" ")
		
		local rsID
		local rsName = { L.RITUALSOULS, L.RITUALSUMMONING }
		for rsID = 2,2 do
			color = "|cffff0000"
			if db.ritualSettings[rsID].ritual == true then
				tt = ""
				if db.ritualSettings[rsID].emote == true then
					n = 0
					for i = 1, 3 do
						if db.ritualSettings[rsID].emote_channels[i] == true then n = n + 1 end
					end
					if n == 3 then color = "|cff00ff00"
					elseif n == 2 then color = "|cffffff00"
					else color = "|cffff6b00"
					end
					tt = tt.."|cff888888".."p"..L.EMOTE:gsub("^%l", string.upper).."|cffbbbbbb("..color..L.ON.."|cffbbbbbb)"
				else
					tt = tt.."|cff888888".."p"..L.EMOTE:gsub("^%l", string.upper).."|cffbbbbbb("..color..L.OFF.."|cffbbbbbb)"
				end				
				color = SoulSpeak.color_frequency(db.ritualSettings[rsID].frequency)
				tt = tt.." |cff888888"..L.QUOTE:gsub("^%l", string.upper).."|cffbbbbbb("..color..(db.ritualSettings[rsID].frequency * 100).."%|cffbbbbbb)"
				tooltip:AddDoubleLine(icon[3].."14\124t |cffffffff"..rsName[rsID].." ",tt)
			else
				tooltip:AddDoubleLine(icon[3].."14\124t |cffffffff"..rsName[rsID].." ",color..L.OFF)
			end
		end

		color = "|cffff0000"
		if db.soulstoneSettings[1].soulstone == true then
			tt = ""
			if db.soulstoneSettings[1].self == true then
				color = SoulSpeak.color_frequency(db.soulstoneSettings[2].frequency)
				tt = tt.."|cff888888"..L.EMOTE:gsub("^%l", string.upper).."|cffbbbbbb("..color..(db.soulstoneSettings[2].frequency * 100).."%|cffbbbbbb)"
			else
				color = "|cffff0000"
				tt = tt.."|cff888888"..L.EMOTE:gsub("^%l", string.upper).."|cffbbbbbb("..color..L.OFF.."|cffbbbbbb)"
			end
			local ssID
			local ssName = { L.QUOTE, L.WHISPER }
			for ssID = 3,4 do
				if db.soulstoneSettings[ssID].frequency > 0 then
					color = SoulSpeak.color_frequency(db.soulstoneSettings[ssID].frequency)
					tt = tt.." |cff888888"..ssName[ssID-2]:gsub("^%l", string.upper).."|cffbbbbbb("..color..(db.soulstoneSettings[ssID].frequency * 100).."%|cffbbbbbb)"
				else
					color = "|cffff0000"
					tt = tt.." |cff888888"..ssName[ssID-2]:gsub("^%l", string.upper).."|cffbbbbbb("..color..L.OFF.."|cffbbbbbb)"
				end
			end			
			tooltip:AddDoubleLine(icon[5].."14\124t |cffffffff"..L.SSR.." ",tt)
			

			tt = ""
			color = "|cffff0000"
			if db.soulstoneSettings[1].emote == true then
				n = 0
				for i = 1, 3 do
					if db.soulstoneSettings[1].emote_channels[i] == true then n = n + 1 end
				end
				if n == 3 then color = "|cff00ff00"
				elseif n == 2 then color = "|cffffff00"
				else color = "|cffff6b00"
				end
				tt = tt.."|cff888888".."p"..L.EMOTE:gsub("^%l", string.upper).."|cffbbbbbb("..color..L.ON.."|cffbbbbbb)"
			else
				tt = tt.."|cff888888".."p"..L.EMOTE:gsub("^%l", string.upper).."|cffbbbbbb("..color..L.OFF.."|cffbbbbbb)"
			end
			local ssID
			local ssName = { L.QUOTE, L.WHISPER }
			for ssID = 5,6 do
				if db.soulstoneSettings[ssID].frequency > 0 then
					color = SoulSpeak.color_frequency(db.soulstoneSettings[ssID].frequency)
					tt = tt.." |cff888888"..ssName[ssID-4]:gsub("^%l", string.upper).."|cffbbbbbb("..color..(db.soulstoneSettings[ssID].frequency * 100).."%|cffbbbbbb)"
				else
					color = "|cffff0000"
					tt = tt.." |cff888888"..ssName[ssID-4]:gsub("^%l", string.upper).."|cffbbbbbb("..color..L.OFF.."|cffbbbbbb)"
				end
			end
--			tooltip:AddDoubleLine(icon[5].."14\124t |cffffffff"..L.RESURRECTION.." ",tt)


		else
			tooltip:AddDoubleLine(icon[5].."14\124t |cffffffff"..L.SSR,color..L.OFF)
--			tooltip:AddDoubleLine(icon[5].."14\124t |cffffffff"..L.RESURRECTION,color..L.OFF)
		end

		color = "|cffff0000"
		if db.demonSettings[16].summon == true then
			local average_frequency = 0
			n = 0
			for i = 1, 15 do
				average_frequency = average_frequency + (db.demonSettings[i].frequency * 100)
				if db.demonSettings[i].frequency > 0 then n = n + 1 end
			end
			average_frequency = average_frequency / n
			average_frequency = math.floor(average_frequency + 0.5)
			tt = ""
			color = "|cffff0000"
			if db.demonSettings[16].combat == true then
				n = 0
				for i = 1, 3 do
					if db.demonSettings[16].combat_channels[i] == true then n = n + 1 end
				end
				if n == 3 then color = "|cff00ff00"
				elseif n == 2 then color = "|cffffff00"
				else color = "|cffff6b00"
				end
				tt = tt.."|cff888888"..L.COMBAT:gsub("^%l", string.upper).."|cffbbbbbb("..color..L.ON.."|cffbbbbbb)"
			else
				tt = tt.."|cff888888"..L.COMBAT:gsub("^%l", string.upper).."|cffbbbbbb("..color..L.OFF.."|cffbbbbbb)"
			end
			color = "|cffff0000"
			local average_emote = 0
			n = 0
			for i = 1, 15 do
				if db.demonSettings[i].emote == true then n = n + 1 end
			end
			if n > 0 == true then
				if n == 14 then color = "|cff00ff00"
				elseif n >= 10 and n < 14 then color = "|cff7fff7f"
				elseif n >= 7 and n < 10 then color = "|cffffff00"
				elseif n >= 4 and n < 7 then color = "|cffffff78"
				elseif n >= 1 and n < 4 then color = "|cffff6b00"
				end
				tt = tt.." |cff888888".."p"..L.EMOTE:gsub("^%l", string.upper).."|cffbbbbbb("..color..L.ON.."|cffbbbbbb)"
			else
				tt = tt.." |cff888888".."p"..L.EMOTE:gsub("^%l", string.upper).."|cffbbbbbb("..color..L.OFF.."|cffbbbbbb)"
			end
			color = SoulSpeak.color_frequency(average_frequency/100)
			tt = tt.." |cff888888"..L.QUOTE:gsub("^%l", string.upper).."|cffbbbbbb("..color..average_frequency.."%|cffbbbbbb)"
			tooltip:AddDoubleLine(db.lastSUMicon.."4\124t |cffffffff"..L.SUMMONS.." ",tt)
		else
			tooltip:AddDoubleLine(db.lastSUMicon.."4\124t |cffffffff"..L.SUMMONS.." ",color..L.OFF)
		end

		local hs_res = {
			{ db.hearthstoneSettings.hearthstone, db.hearthstoneSettings.frequency, L.HEARTHSTONE,
				emote = { db.hearthstoneSettings.random_morning, db.hearthstoneSettings.random_afternoon, db.hearthstoneSettings.random_evening, db.hearthstoneSettings.random_night } },
			{ db.resurrectedSettings.resurrected, db.resurrectedSettings.frequency, L.RESURRECTED,
				emote = { db.resurrectedSettings.random_party, db.resurrectedSettings.random_raid, db.resurrectedSettings.random_solo } }
		}
		local hrID
		for hrID = 1,2 do
			color = "|cffff0000"
			if hs_res[hrID][1] == true then
				n = 0
				for i = 1, 4 do
					if hs_res[hrID].emote[i] == true then n = n + 1 end
				end
				if hrID == 2 and n == 3 then n = 4 end
				if hrID == 2 and n == 2 then n = 3 end
				if n > 0 == true then
					if n == 4 then rcolor = "|cff00ff00" fcolor = "|cffff2f32"
					elseif n == 3 then rcolor = "|cff7fff7f" fcolor = "|cffff6b00"
					elseif n == 2 then rcolor = "|cffffff00" fcolor = "|cffffff00"
					elseif n == 1 then rcolor = "|cffff6b00" fcolor = "|cff7fff7f"
					end
				else
					rcolor = "|cffff2f32" fcolor = "|cff00ff00"
				end
				color = SoulSpeak.color_frequency(hs_res[hrID][2])
				local tt = ""
				tt = tt..fcolor..string.lower(L.FIXED).."|cffffffff/"..rcolor..L.RANDOM
				tt = tt.." |cff888888"..L.EMOTE:gsub("^%l", string.upper).."|cffbbbbbb("..color..(hs_res[hrID][2] * 100).."%|cffbbbbbb)"
				tooltip:AddDoubleLine(icon[(hrID+1)*hrID].."14\124t |cffffffff"..hs_res[hrID][3].." ",tt)
			else
				tooltip:AddDoubleLine(icon[hrID+1*hrID].."14\124t |cffffffff"..hs_res[hrID][3].." ",color..L.OFF)
			end
		end

		if not db.ssLDB_options[2] then
			tooltip:AddLine(" ")
			tooltip:AddLine("|cffeda55f"..L.LEFTCLICK.."|r "..L.TODISENL.." SoulSpeak", 0.2, 1, 0.2)
			tooltip:AddLine("|cffeda55f"..L.RIGHTCLICK.."|r "..L.FOROPTIONS, 0.2, 1, 0.2)
			tooltip:AddLine("|cffeda55f"..L.ALTCLICK.."|r "..L.RESTARTGFX, 0.2, 1, 0.2)
			tooltip:AddLine("|cffeda55f"..L.ALTRIGHTCLICK.."|r "..L.RELOADUI, 0.2, 1, 0.2)
			if not db.ssLDB_options[1] then tooltip:AddLine("|cffeda55f"..L.CTRLRIGHTCLICK.."|r "..string.lower(L.HIDEMB), 0.2, 1, 0.2) end
		end
	end,
})

--[[
*************************
* function OnInitialize *
--]]
function SoulSpeak:OnInitialize()
	self.db = LibStub("AceDB-3.0"):New("SoulSpeakDB", SoulSpeak.defaults)
  db = self.db.profile
	SoulSpeak.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	SoulSpeak.db.RegisterCallback(self, "OnProfileCopied", "OnProfileChanged")
	SoulSpeak.db.RegisterCallback(self, "OnProfileReset", "OnProfileChanged")	
	local AceConfig = LibStub("AceConfig-3.0")
	local AceConfigDialog = LibStub("AceConfigDialog-3.0")
  local about_panel = LibStub:GetLibrary("LibAboutPanel", true)
  
	if about_panel then
		self.optionsFrame = about_panel.new(nil, "SoulSpeak")
	end
	
	AceConfig:RegisterOptionsTable("SoulSpeak.Options", SoulSpeak.Options)
--	AceConfig:RegisterOptionsTable("SoulSpeak.RitualSoulsOptions", SoulSpeak.RitualSoulsOptions)
  AceConfig:RegisterOptionsTable("SoulSpeak.RitualSummoningOptions", SoulSpeak.RitualSummoningOptions)
  AceConfig:RegisterOptionsTable("SoulSpeak.SoulstoneOptions", SoulSpeak.SoulstoneOptions)
  AceConfig:RegisterOptionsTable("SoulSpeak.sumOptions", SoulSpeak.sumOptions)
  AceConfig:RegisterOptionsTable("SoulSpeak.HearthstoneOptions", SoulSpeak.HearthstoneOptions)
  AceConfig:RegisterOptionsTable("SoulSpeak.ResurrectedOptions", SoulSpeak.ResurrectedOptions)
  AceConfig:RegisterOptionsTable("SoulSpeak Profiles", LibStub("AceDBOptions-3.0"):GetOptionsTable(SoulSpeak.db))

	AceConfigDialog:AddToBlizOptions("SoulSpeak.Options", L.OPTIONS, "SoulSpeak")
--  AceConfigDialog:AddToBlizOptions("SoulSpeak.RitualSoulsOptions", L.RITUALSOULS, "SoulSpeak")
  AceConfigDialog:AddToBlizOptions("SoulSpeak.RitualSummoningOptions", L.RITUALSUMMONING, "SoulSpeak")
  AceConfigDialog:AddToBlizOptions("SoulSpeak.SoulstoneOptions", L.SSR, "SoulSpeak")
  AceConfigDialog:AddToBlizOptions("SoulSpeak.sumOptions", L.SUMMONS, "SoulSpeak")
  AceConfigDialog:AddToBlizOptions("SoulSpeak.HearthstoneOptions", L.HEARTHSTONE, "SoulSpeak")
  AceConfigDialog:AddToBlizOptions("SoulSpeak.ResurrectedOptions", L.RESURRECTED, "SoulSpeak")
  AceConfigDialog:AddToBlizOptions("SoulSpeak Profiles", L.PROFILES, "SoulSpeak")

	ssMMicon:Register("SoulSpeakBlock", SoulSpeakBlock, db.ssLDBbutton)
	if db.SoulSpeak == false then SoulSpeakBlock.text = "|cffff2f32SoulSpeak|r" end

	LibStub("AceConfig-3.0"):RegisterOptionsTable("SoulSpeak commands", SoulSpeak.OptionsSlash, "ss")
	LibStub("AceConfig-3.0"):RegisterOptionsTable("SoulSpeak commands", SoulSpeak.OptionsSlash, "soulspeak")
  DEFAULT_CHAT_FRAME:AddMessage("\124TInterface\\Icons\\Spell_Shadow_SoulGem:12\124t |cffffffff<|cffB0A0ffSoulSpeak|cffffffff>|r v"..GetAddOnMetadata("SoulSpeak", "version").."|r initialized. Type |cffB0A0ff/ss|r for command arguments.")
end

--[[
*****************************
* function OnProfileChanged *
--]]
function SoulSpeak.OnProfileChanged(event, database, newProfileKey)
	SoulSpeak.db = LibStub("AceDB-3.0"):New("SoulSpeakDB", defaults)
  db = SoulSpeak.db.profile
 	SoulSpeak.db.RegisterCallback(SoulSpeak, "OnProfileChanged", "OnProfileChanged")
	SoulSpeak.db.RegisterCallback(SoulSpeak, "OnProfileCopied", "OnProfileChanged")
	SoulSpeak.db.RegisterCallback(SoulSpeak, "OnProfileReset", "OnProfileChanged")
	LibStub("LibDBIcon-1.0"):Refresh("SoulSpeakBlock", db.ssLDBbutton)
	SoulSpeakBlock.text = "|cff00ff00SoulSpeak"

end

--[[
*********************
* function OnEnable *
--]]
function SoulSpeak:OnEnable()
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("PLAYER_ALIVE")
	self:RegisterEvent("PLAYER_UNGHOST")
	self:RegisterEvent("RESURRECT_REQUEST")
	self:RegisterEvent("UNIT_SPELLCAST_SENT")
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
end

--[[
********************************
* function UNIT_SPELLCAST_SENT *
--]]
function SoulSpeak:UNIT_SPELLCAST_SENT(arg1,arg2,arg3,arg4, arg5)
--	self:Print("|cffff0000"..L.CHATONLY.." |rarg2: "..arg2)
--	self:Print("|cffff0000"..L.CHATONLY.." |rarg5: "..arg5)
	local i
	local PartyChannels = {
		('PARTY'), ('SAY'), ('YELL'),
	}
	local RaidChannels = {
		('PARTY'), ('RAID'), ('SAY'), ('YELL'),
	}
	local SoloChannels = {
		('CHAT'), ('SAY'), ('YELL'),
	}
	--[[
	***************
	* hearthstone *
	--]]
	--if (arg3 == HSspell or arg3 == GHSspell or arg3 == IDspell) and db.Hearthstone == true and random(1,100) <= (db.HearthstoneFrequency * 100) then
	if (GetSpellInfo(arg5) == GetSpellInfo(8690) or GetSpellInfo(arg5) == GetSpellInfo(171253) or GetSpellInfo(arg5) == GetSpellInfo(91226) or GetSpellInfo(arg5) == GetSpellInfo(222695)) and db.hearthstoneSettings.hearthstone == true and random(1,100) <= (db.hearthstoneSettings.frequency * 100) then
		local HearthstoneEmotes = {"BLINK", "SMILE", "YAWN", "WAVE", "BYE", "TIRED","SMIRK", "PRAISE", "LOVE", "LOST", "KISS", "GAZE"}
		local hour,minute = GetGameTime()
		local second = (hour * 3600) + (minute * 60)
		if (second >= 0 and second < 21600) and db.hearthstoneSettings.night == true  then
			if db.hearthstoneSettings.random_night == true then DoEmote(HearthstoneEmotes[random(1,12)])
			else
				DoEmote(HearthstoneEmotes[db.hearthstoneSettings.night_emotes])
			end
		elseif (second >= 21600 and second < 43200) and db.hearthstoneSettings.morning == true then
			if db.hearthstoneSettings.random_morning == true then DoEmote(HearthstoneEmotes[random(1,12)])
			else
				DoEmote(HearthstoneEmotes[db.hearthstoneSettings.morning_emotes])
			end
		elseif (second >= 43200 and second < 64800) and db.hearthstoneSettings.afternoon == true then
			if db.hearthstoneSettings.random_afternoon == true then DoEmote(HearthstoneEmotes[random(1,12)])
			else
				DoEmote(HearthstoneEmotes[db.hearthstoneSettings.afternoon_emotes])
			end
		elseif (second >= 64800 and second <= 86400) and db.hearthstoneSettings.evening == true then
			if db.hearthstoneSettings.random_evening == true then DoEmote(HearthstoneEmotes[random(1,12)])
			else
				DoEmote(HearthstoneEmotes[db.hearthstoneSettings.evening_emotes])
			end
		end
	end
	
	--[[
	**************************
	* soulstone resurrection *
	--]]
	
--	if UnitName("target") ~= nil then
--		self:Print("|cffff0000"..L.CHATONLY.." |rtarget: "..UnitName("target"))
--	end
--	if UnitName("player") ~= nil then
--		self:Print("|cffff0000"..L.CHATONLY.." |rplayer: "..UnitName("player"))
--	end
	
	if db.soulstoneSettings[1].soulstone == true and arg2 == "player" and GetSpellInfo(arg5) == ssr_spell then
		ss_target = UnitName("player")
		if UnitName("target") and UnitName("target") ~= UnitName("player") then
			ss_target = UnitName("target")
		end
		if UnitIsDeadOrGhost("target") then
			ss_res = 2
			if UnitIsDead("target") then
				ss_res = 1
			end
		else
			ss_res = 0
		end
		targetClass, englishClass = UnitClass("target")
		genderTable = { L.IT, L.HE, L.SHE }
		SSgenderTable1 = genderTable[UnitSex("target")]
		genderTable = { L.ITS, L.HIM, L.HER }
		SSgenderTable2 = genderTable[UnitSex("target")]
		genderTable = { L.ITS, L.HIS, L.HER }
		SSgenderTable3 = genderTable[UnitSex("target")]
		genderTable = { L.ITS, L.HIS, L.HERS }
		SSgenderTable4 = genderTable[UnitSex("target")]
	else
		ss_target = ""
	end
	
	--[[
	*************************
	* function ritual_quote *
	--]]
	function ritual_quote(rsID)
		local rsEmotes = {"BECKON","BLINK","BOGGLE","BOUNCE","CACKLE","CHEER","CLAP","GRIN","SMILE","SMIRK","SNICKER","WAIT","WELCOME","WHISTLE"}
		i = 0
		if db.ritualSettings[rsID].quotesmaxscale == 1 then i = 1
		else
			repeat 
				i = random(1,db.ritualSettings[rsID].quotesmaxscale)
 			until i ~= db.ritualSettings[rsID].last_quote
		end
		db.ritualSettings[rsID].last_quote = i
		if GetNumGroupMembers() > 5 and db.ritualSettings[rsID].raid == true then
			if db.ritualSettings[rsID].quote[i] ~= "" then
				if db.ritualSettings[rsID].emote == true and db.ritualSettings[rsID].emote_channels[2] == true then
					if db.ritualSettings[rsID].random == true then
						DoEmote(rsEmotes[random(1,14)])
					else
						DoEmote(rsEmotes[db.ritualSettings[rsID].emotelist])
					end
				end
				if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and RaidChannels[db.ritualSettings[rsID].raid_channel] ~= "SAY" and RaidChannels[db.ritualSettings[rsID].raid_channel] ~= "YELL" then
					if db.ritualSettings[rsID].emote == true and db.ritualSettings[rsID].emote_channels[2] == true and db.ritualSettings[rsID].delay == true then
						self:ScheduleTimer(function() for n = 1, 1 do SendChatMessage(SoulSpeak.txtReplace(db.ritualSettings[rsID].quote[i]),"INSTANCE_CHAT") end end, 2)
					else
						SendChatMessage(SoulSpeak.txtReplace(db.ritualSettings[rsID].quote[i]),"INSTANCE_CHAT")
					end
				else
					if db.ritualSettings[rsID].emote == true and db.ritualSettings[rsID].delay == true then
						self:ScheduleTimer(function() for n = 1, 1 do SendChatMessage(SoulSpeak.txtReplace(db.ritualSettings[rsID].quote[i]),RaidChannels[db.ritualSettings[rsID].raid_channel]) end end, 2)
					else
						SendChatMessage(SoulSpeak.txtReplace(db.ritualSettings[rsID].quote[i]),RaidChannels[db.ritualSettings[rsID].raid_channel])
					end
				end
			else
				self:Print("|cffff0000"..L.WARNING.." |cffB0A0ff"..L.EMPTYQUOTE)				
			end
		elseif GetNumGroupMembers() > 0 and GetNumGroupMembers() < 6 and db.ritualSettings[rsID].party == true then
			if db.ritualSettings[rsID].quote[i] ~= "" then
				if db.ritualSettings[rsID].emote == true and db.ritualSettings[rsID].emote_channels[1] == true then
					if db.ritualSettings[rsID].random == true then
						DoEmote(rsEmotes[random(1,14)])
					else
						DoEmote(rsEmotes[db.ritualSettings[rsID].emotelist])
					end
				end
				if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and PartyChannels[db.ritualSettings[rsID].party_channel] ~= "SAY" and PartyChannels[db.ritualSettings[rsID].party_channel] ~= "YELL" then
					if db.ritualSettings[rsID].emote == true and db.ritualSettings[rsID].emote_channels[1] == true and db.ritualSettings[rsID].delay == true then
						self:ScheduleTimer(function() for n = 1, 1 do SendChatMessage(SoulSpeak.txtReplace(db.ritualSettings[rsID].quote[i]),"INSTANCE_CHAT") end end, 2)
					else
						SendChatMessage(SoulSpeak.txtReplace(db.ritualSettings[rsID].quote[i]),"INSTANCE_CHAT")
					end
				else
					if db.ritualSettings[rsID].emote == true and db.ritualSettings[rsID].delay == true then
						self:ScheduleTimer(function() for n = 1, 1 do SendChatMessage(SoulSpeak.txtReplace(db.ritualSettings[rsID].quote[i]),PartyChannels[db.ritualSettings[rsID].party_channel]) end end, 2)
			  	else
			  		SendChatMessage(SoulSpeak.txtReplace(db.ritualSettings[rsID].quote[i]),PartyChannels[db.ritualSettings[rsID].party_channel])
			  	end
				end
			else
				self:Print("|cffff0000"..L.WARNING.." |cffB0A0ff"..L.EMPTYQUOTE)				
			end
		elseif db.ritualSettings[rsID].chat == true then
			if db.ritualSettings[rsID].quote[i] ~= "" then
				if db.ritualSettings[rsID].emote == true and db.ritualSettings[rsID].emote_channels[3] == true then
					if db.ritualSettings[rsID].random == true then
						DoEmote(rsEmotes[random(1,14)])
					else
						DoEmote(rsEmotes[db.ritualSettings[rsID].emotelist])
					end
				end
				if db.ritualSettings[rsID].emote == true and db.ritualSettings[rsID].emote_channels[3] == true and db.ritualSettings[rsID].delay == true then
					self:ScheduleTimer(function() for n = 1, 1 do self:Print("|cffff0000"..L.CHATONLY.." |r"..SoulSpeak.txtReplace(db.ritualSettings[rsID].quote[i])) end end, 2)
				else
					self:Print("|cffff0000"..L.CHATONLY.." |r"..SoulSpeak.txtReplace(db.ritualSettings[rsID].quote[i]))
				end
			else
				self:Print("|cffff0000"..L.WARNING.." |cffB0A0ff"..L.EMPTYQUOTE)
			end
		end
	end
	--[[
	*****************************
	* ritual of souls/summoning *
	--]]
	local ritualSpell = {
		GetSpellInfo(29893), GetSpellInfo(698)
	}
	for i = 2,2 do
		local start, duration, enabled = GetSpellCooldown(ritualSpell[i])
		--if db.ritualSettings[i].ritual == true and arg3 == ritualSpell[i] and duration == 0 and random(1,100) <= (db.ritualSettings[i].frequency * 100) then
		if db.ritualSettings[i].ritual == true and GetSpellInfo(arg5) == ritualSpell[i] and random(1,100) <= (db.ritualSettings[i].frequency * 100) then
			ritual_quote(i)
		end
	end	
	
	--[[
	****************
	* summon demon *
	--]]
	if UnitAffectingCombat("player") and db.demonSettings[16].combat == false then return elseif db.demonSettings[16].summon == true then
		local summonSpell = {
			GetSpellInfo(30146), GetSpellInfo(112870), GetSpellInfo(691), GetSpellInfo(112869), GetSpellInfo(688), GetSpellInfo(112866),
			GetSpellInfo(712), GetSpellInfo(112868), GetSpellInfo(697), GetSpellInfo(25112), GetSpellInfo(112867), GetSpellInfo(18540),
			GetSpellInfo(112927), GetSpellInfo(1122), GetSpellInfo(112921),
		}
		--[[
		************************
		* function demon_quote *
		--]]
		function demon_quote(sumID)
--			self:Print("|cffff0000"..L.CHATONLY.." |rG.members: "..GetNumGroupMembers())
			local SUMpEmotes = {"BLINK","BOUNCE","CACKLE","CHEER","CLAP","GRIN","SMILE","SHRUG","SIGH","SNICKER","SMIRK","WHISTLE"}
			i = 0
			if db.demonSettings[sumID].quotesmaxscale == 1 then
				i = 1
			else
				repeat 
				i = random(1,db.demonSettings[sumID].quotesmaxscale)
  			until i ~= db.lastSMquote[sumID]
			end
			db.lastSMquote[sumID] = i
			DemonName = db.demonSettings[sumID].name
			if db.demonSettings[sumID].emote == true and db.demonSettings[sumID].quote[i] ~= "" then
				if db.demonSettings[sumID].random == true then
--					self:ScheduleTimer(function() for n = 1, 1 do DoEmote(SUMpEmotes[random(1,12)]) end end, 2)
					DoEmote(SUMpEmotes[random(1,12)])
				else
--					self:ScheduleTimer(function() for n = 1, 1 do DoEmote(SUMpEmotes[db.demonSettings[sumID].emotelist]) end end, 2)
					DoEmote(SUMpEmotes[db.demonSettings[sumID].emotelist])
				end
			end
			if GetNumGroupMembers() > 5 and db.demonSettings[16].raid == true and db.demonSettings[16].combat_channels[2] == true then
				if db.demonSettings[sumID].quote[i] ~= "" then
					if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and RaidChannels[db.demonSettings[16].raid_channel] ~= "SAY" and RaidChannels[db.demonSettings[16].raid_channel] ~= "YELL" then
						if db.demonSettings[sumID].emote == true and db.demonSettings[sumID].delay == true then
							self:ScheduleTimer(function() for n = 1, 1 do SendChatMessage(SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i]),"INSTANCE_CHAT") end end, 5)
						else
							SendChatMessage(SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i]),"INSTANCE_CHAT")
						end
					else
						if db.demonSettings[sumID].emote == true and db.demonSettings[sumID].delay == true then
							self:ScheduleTimer(function() for n = 1, 1 do SendChatMessage(SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i]),RaidChannels[db.demonSettings[16].raid_channel]) end end, 5)
						else
							SendChatMessage(SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i]),RaidChannels[db.demonSettings[16].raid_channel])
						end
					end
				else
					self:Print("|cffff0000"..L.WARNING.." |cffB0A0ff"..L.EMPTYQUOTE)				
				end
			elseif GetNumGroupMembers() > 0 and GetNumGroupMembers() < 6 and db.demonSettings[16].party == true and db.demonSettings[16].combat_channels[1] == true then
				if db.demonSettings[sumID].quote[i] ~= "" then
					if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and PartyChannels[db.demonSettings[16].party_channel] ~= "SAY" and PartyChannels[db.demonSettings[16].party_channel] ~= "YELL" then
						if db.demonSettings[sumID].emote == true and db.demonSettings[sumID].delay == true then
							self:ScheduleTimer(function() for n = 1, 1 do SendChatMessage(SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i]),"INSTANCE_CHAT") end end, 5)
						else
							SendChatMessage(SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i]),"INSTANCE_CHAT")
						end
					else
						if db.demonSettings[sumID].emote == true and db.demonSettings[sumID].delay == true then
							self:ScheduleTimer(function() for n = 1, 1 do SendChatMessage(SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i]),PartyChannels[db.demonSettings[16].party_channel]) end end, 5)
						else
							SendChatMessage(SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i]),PartyChannels[db.demonSettings[16].party_channel])
						end
					end					
				else
					self:Print("|cffff0000"..L.WARNING.." |cffB0A0ff"..L.EMPTYQUOTE)				
				end
			elseif GetNumGroupMembers() == 0 and db.demonSettings[16].solo == true and db.demonSettings[16].combat_channels[3] == true then
				if db.demonSettings[16].solo_channel == 1 then
					if db.demonSettings[sumID].quote[i] ~= "" then
						if db.demonSettings[sumID].emote == true and db.demonSettings[sumID].delay == true then
							self:ScheduleTimer(function() for n = 1, 1 do self:Print("|cffff0000"..L.CHATONLY.." |r"..SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i])) end end, 5)
						else
							self:Print("|cffff0000"..L.CHATONLY.." |r"..SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i]))
						end
					else
						self:Print("|cffff0000"..L.WARNING.." |cffB0A0ff"..L.EMPTYQUOTE)
					end					
				else
					if db.demonSettings[sumID].quote[i] ~= "" then
						if db.demonSettings[sumID].emote == true and db.demonSettings[sumID].delay == true then
							self:ScheduleTimer(function() for n = 1, 1 do SendChatMessage(SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i]),SoloChannels[db.demonSettings[16].solo_channel]) end end, 5)
						else
							SendChatMessage(SoulSpeak.txtReplace(db.demonSettings[sumID].quote[i]),SoloChannels[db.demonSettings[16].solo_channel])
						end
					else
						self:Print("|cffff0000"..L.WARNING.." |cffB0A0ff"..L.EMPTYQUOTE)												
					end
				end
			end
		end
		--[[
		**************
		* demon core *
		--]]
		for i = 1,15 do
			if GetSpellInfo(arg5) == summonSpell[i] and random(1,100) <= (db.demonSettings[i].frequency * 100) then
				if i == 10 then i = 9 end -- replace voidwalker no mana with voidwalker normal
				demon_quote(i)
			end
		end
	end
end

--[[
*************************************
* function UNIT_SPELLCAST_SUCCEEDED *
--]]
function SoulSpeak:UNIT_SPELLCAST_SUCCEEDED(arg1,arg2,arg3,arg4,arg5)
	local i
	local PartyChannels = {
		('PARTY'), ('SAY'), ('YELL'),
	}
	local RaidChannels = {
		('PARTY'), ('RAID'), ('SAY'), ('YELL'),
	}
	local SoloChannels = {
		('CHAT'), ('SAY'), ('YELL'),
	}
	--[[
	***********************
	* ritual of summoning *
	--]]
--  self:Print("|cffff0000"..L.CHATONLY.." |rarg4: "..arg4)
	if db.ritualSettings[2].ritual == true and db.ritualSettings[2].helpme == true and arg2 == "player" and GetSpellInfo(arg4) == GetSpellInfo(698) then
		if GetNumGroupMembers() > 0 and random(1,100) <= (db.ritualSettings[2].frequency * 100) then
			DoEmote("HELPME")
		end
	end
	
	--[[
	**************************
	* soulstone resurrection *
	--]]
	if db.soulstoneSettings[1].soulstone == true and arg2 == "player" and GetSpellInfo(arg4) == ssr_spell then
		local rrEmotes = {
			"CALM","COMFORT","COMMEND","CONFUSED","CRY","CURIOUS","DROOL","FROWN","MOURN","PANIC","PITY","PRAY","SURPRISED","VIOLIN","WAIT",
		}
		local SoulSoloChannels = {
			('CHAT'), ('SAY'), ('SAY'), ('YELL'), ('YELL'),
		}
		local SoulPartyChannels = {
			('PARTY'), ('PARTY'), ('SAY'), ('SAY'), ('YELL'), ('YELL'),
		}
		local SoulRaidChannels = {
			('PARTY'), ('PARTY'), ('RAID'), ('RAID'), ('SAY'), ('SAY'), ('YELL'), ('YELL'),
		}
		if ss_target == UnitName("player") and db.soulstoneSettings[1].self == true and random(1,100) <= (db.soulstoneSettings[2].frequency * 100) then
			i = 0
			if db.soulstoneSettings[2].quotesmaxscale == 1 then
				i = 1
			else
				repeat 
				i = random(1,db.soulstoneSettings[2].quotesmaxscale)
  			until i ~= db.soulstoneSettings[2].last_quote
  		end
  		if db.soulstoneSettings[2].quote[i] ~= "" then
				SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[2].quote[i]),"EMOTE",nil,"SAY")
			end
			db.soulstoneSettings[2].last_quote = i
		elseif ss_target ~= "" and ss_target ~= UnitName("player") then
			local iq, iw, irq, irw = 0, 0, 0, 0
			if db.soulstoneSettings[3].quotesmaxscale == 1 then
				iq = 1
			else
				repeat 
				iq = random(1,db.soulstoneSettings[3].quotesmaxscale)
  			until iq ~= db.soulstoneSettings[3].last_quote
  		end
  		if db.soulstoneSettings[4].quotesmaxscale == 1 then
  			iw = 1
  		else
				repeat 
				iw = random(1,db.soulstoneSettings[4].quotesmaxscale)
  			until iw ~= db.soulstoneSettings[4].last_quote
  		end
			if db.soulstoneSettings[5].quotesmaxscale == 1 then
				irq = 1
			else
				repeat 
				irq = random(1,db.soulstoneSettings[5].quotesmaxscale)
  			until irq ~= db.soulstoneSettings[5].last_quote
  		end
  		if db.soulstoneSettings[6].quotesmaxscale == 1 then
  			irw = 1
  		else
				repeat 
				irw = random(1,db.soulstoneSettings[6].quotesmaxscale)
  			until irw ~= db.soulstoneSettings[6].last_quote
  		end  		
			db.soulstoneSettings[3].last_quote = iq  		
			db.soulstoneSettings[4].last_quote = iw
			db.soulstoneSettings[5].last_quote = irq  		
			db.soulstoneSettings[6].last_quote = irw
			if GetNumGroupMembers() > 5 and db.soulstoneSettings[1].raid == true then
				if (db.soulstoneSettings[1].raid_channel == 1 or db.soulstoneSettings[1].raid_channel == 3 or db.soulstoneSettings[1].raid_channel == 5 or db.soulstoneSettings[1].raid_channel == 7) then
					if db.soulstoneSettings[3].quote[iq] ~= "" and ss_res == 0 and random(1,100) <= (db.soulstoneSettings[3].frequency * 100) then
						if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and SoulRaidChannels[db.soulstoneSettings[1].raid_channel] ~= "SAY" and SoulRaidChannels[db.soulstoneSettings[1].raid_channel] ~= "YELL" then
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[3].quote[iq]),"INSTANCE_CHAT")
						else
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[3].quote[iq]),SoulRaidChannels[db.soulstoneSettings[1].raid_channel])
						end
					elseif db.soulstoneSettings[5].quote[irq] ~= "" and ss_res == 1 and random(1,100) <= (db.soulstoneSettings[5].frequency * 100) then
						if db.soulstoneSettings[1].emote == true and db.soulstoneSettings[1].emote_channels[2] == true then
							if db.soulstoneSettings[1].random == true then
								DoEmote(rrEmotes[random(1,15)])
							else
								DoEmote(rrEmotes[db.soulstoneSettings[1].emotelist])
							end
						end
						if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and SoulRaidChannels[db.soulstoneSettings[1].raid_channel] ~= "SAY" and SoulRaidChannels[db.soulstoneSettings[1].raid_channel] ~= "YELL" then
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[5].quote[irq]),"INSTANCE_CHAT")
						else
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[5].quote[irq]),SoulRaidChannels[db.soulstoneSettings[1].raid_channel])
						end
					end
				elseif db.soulstoneSettings[1].raid_channel == 2 or db.soulstoneSettings[1].raid_channel == 4 or db.soulstoneSettings[1].raid_channel == 6 or db.soulstoneSettings[1].raid_channel == 8 then
					if db.soulstoneSettings[3].quote[iq] ~= "" and ss_res == 0 and random(1,100) <= (db.soulstoneSettings[3].frequency * 100) then
						if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and SoulRaidChannels[db.soulstoneSettings[1].raid_channel] ~= "SAY" and SoulRaidChannels[db.soulstoneSettings[1].raid_channel] ~= "YELL" then
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[3].quote[iq]),"INSTANCE_CHAT")
						else
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[3].quote[iq]),SoulRaidChannels[db.soulstoneSettings[1].raid_channel])
						end
					elseif db.soulstoneSettings[5].quote[irq] ~= "" and ss_res == 1 and random(1,100) <= (db.soulstoneSettings[5].frequency * 100) then
						if db.soulstoneSettings[1].emote == true and db.soulstoneSettings[1].emote_channels[2] == true then
							if db.soulstoneSettings[1].random == true then
								DoEmote(rrEmotes[random(1,15)])
							else
								DoEmote(rrEmotes[db.soulstoneSettings[1].emotelist])
							end
						end
						if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and SoulRaidChannels[db.soulstoneSettings[1].raid_channel] ~= "SAY" and SoulRaidChannels[db.soulstoneSettings[1].raid_channel] ~= "YELL" then
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[5].quote[irq]),"INSTANCE_CHAT")
						else
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[5].quote[irq]),SoulRaidChannels[db.soulstoneSettings[1].raid_channel])
						end
					end
					if db.soulstoneSettings[4].quote[iw] ~= "" and ss_res == 0 and random(1,100) <= (db.soulstoneSettings[4].frequency * 100) then
						SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[4].quote[iw]),"WHISPER",nil,ss_target)
					elseif  db.soulstoneSettings[6].quote[irw] ~= "" and ss_res == 1 and random(1,100) <= (db.soulstoneSettings[6].frequency * 100) then
						SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[6].quote[irw]),"WHISPER",nil,ss_target)
					end
				end
			elseif GetNumGroupMembers() > 0 and GetNumGroupMembers() < 6 and db.soulstoneSettings[1].party == true then
				if db.soulstoneSettings[1].party_channel == 1 or db.soulstoneSettings[1].party_channel == 3 or db.soulstoneSettings[1].party_channel == 5 then
					if db.soulstoneSettings[3].quote[iq] ~= "" and ss_res == 0 and random(1,100) <= (db.soulstoneSettings[3].frequency * 100) then
						if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and SoulPartyChannels[db.soulstoneSettings[1].party_channel] ~= "SAY" and SoulPartyChannels[db.soulstoneSettings[1].party_channel] ~= "YELL" then
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[3].quote[iq]),"INSTANCE_CHAT")
						else
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[3].quote[iq]),SoulPartyChannels[db.soulstoneSettings[1].party_channel])
						end
					elseif db.soulstoneSettings[5].quote[irq] ~= "" and ss_res == 1 and random(1,100) <= (db.soulstoneSettings[5].frequency * 100) then
						if db.soulstoneSettings[1].emote == true and db.soulstoneSettings[1].emote_channels[1] == true then
							if db.soulstoneSettings[1].random == true then
								DoEmote(rrEmotes[random(1,15)])
							else
								DoEmote(rrEmotes[db.soulstoneSettings[1].emotelist])
							end
						end
						if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and SoulPartyChannels[db.soulstoneSettings[1].party_channel] ~= "SAY" and SoulPartyChannels[db.soulstoneSettings[1].party_channel] ~= "YELL" then
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[5].quote[irq]),"INSTANCE_CHAT")
						else
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[5].quote[irq]),SoulPartyChannels[db.soulstoneSettings[1].party_channel])
						end	
					end
				elseif db.soulstoneSettings[1].party_channel == 2 or db.soulstoneSettings[1].party_channel == 4 or db.soulstoneSettings[1].party_channel == 6 then
					if db.soulstoneSettings[3].quote[iq] ~= "" and ss_res == 0 and random(1,100) <= (db.soulstoneSettings[3].frequency * 100) then
						if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and SoulPartyChannels[db.soulstoneSettings[1].party_channel] ~= "SAY" and SoulPartyChannels[db.soulstoneSettings[1].party_channel] ~= "YELL" then
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[3].quote[iq]),"INSTANCE_CHAT")
						else
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[3].quote[iq]),SoulPartyChannels[db.soulstoneSettings[1].party_channel])
						end
					elseif  db.soulstoneSettings[5].quote[irq] ~= "" and ss_res == 1 and random(1,100) <= (db.soulstoneSettings[5].frequency * 100) then
						if db.soulstoneSettings[1].emote == true and db.soulstoneSettings[1].emote_channels[1] == true then
							if db.soulstoneSettings[1].random == true then
								DoEmote(rrEmotes[random(1,15)])
							else
								DoEmote(rrEmotes[db.soulstoneSettings[1].emotelist])
							end
						end
						if (IsInGroup(LE_PARTY_CATEGORY_INSTANCE)) and SoulPartyChannels[db.soulstoneSettings[1].party_channel] ~= "SAY" and SoulPartyChannels[db.soulstoneSettings[1].party_channel] ~= "YELL" then
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[5].quote[irq]),"INSTANCE_CHAT")
						else
							SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[5].quote[irq]),SoulPartyChannels[db.soulstoneSettings[1].party_channel])
						end
					end
					if db.soulstoneSettings[4].quote[iw] ~= "" and ss_res == 0 and random(1,100) <= (db.soulstoneSettings[4].frequency * 100) then
						SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[4].quote[iw]),"WHISPER",nil,ss_target)
					elseif db.soulstoneSettings[6].quote[irw] ~= "" and ss_res == 1 and random(1,100) <= (db.soulstoneSettings[6].frequency * 100) then
						SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[6].quote[irw]),"WHISPER",nil,ss_target)
					end
				end
			elseif GetNumGroupMembers() == 0 and db.soulstoneSettings[1].solo == true then
				if db.soulstoneSettings[1].solo_channel == 1 then
					if db.soulstoneSettings[3].quote[iq] ~= "" and ss_res == 0 and random(1,100) <= (db.soulstoneSettings[3].frequency * 100) then
						self:Print("|cffff0000"..L.CHATONLY.." |r"..SoulSpeak.txtReplace(db.soulstoneSettings[3].quote[iq]))
					elseif  db.soulstoneSettings[5].quote[irq] ~= "" and ss_res == 1 and random(1,100) <= (db.soulstoneSettings[5].frequency * 100) then
						if db.soulstoneSettings[1].emote == true and db.soulstoneSettings[1].emote_channels[3] == true then
							if db.soulstoneSettings[1].random == true then
								DoEmote(rrEmotes[random(1,15)])
							else
								DoEmote(rrEmotes[db.soulstoneSettings[1].emotelist])
							end
						end
						self:Print("|cffff0000"..L.CHATONLY.." |r"..SoulSpeak.txtReplace(db.soulstoneSettings[5].quote[irq]))
					end
				elseif db.soulstoneSettings[1].solo_channel == 2 or db.soulstoneSettings[1].solo_channel == 4 then
					if db.soulstoneSettings[3].quote[iq] ~= "" and ss_res == 0 and random(1,100) <= (db.soulstoneSettings[3].frequency * 100) then
						SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[3].quote[iq]),SoulSoloChannels[db.soulstoneSettings[1].solo_channel])
					elseif db.soulstoneSettings[5].quote[irq] ~= "" and ss_res == 1 and random(1,100) <= (db.soulstoneSettings[5].frequency * 100) then
						if db.soulstoneSettings[1].emote == true and db.soulstoneSettings[1].emote_channels[3] == true then
							if db.soulstoneSettings[1].random == true then
								DoEmote(rrEmotes[random(1,15)])
							else
								DoEmote(rrEmotes[db.soulstoneSettings[1].emotelist])
							end
						end
						SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[5].quote[irq]),SoulSoloChannels[db.soulstoneSettings[1].solo_channel])
					end
				elseif db.soulstoneSettings[1].solo_channel == 3 or db.soulstoneSettings[1].solo_channel == 5 then
					if db.soulstoneSettings[3].quote[iq] ~= "" and ss_res == 0 and random(1,100) <= (db.soulstoneSettings[3].frequency * 100) then
						SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[3].quote[iq]),SoulSoloChannels[db.soulstoneSettings[1].solo_channel])
					elseif db.soulstoneSettings[5].quote[irq] ~= "" and ss_res == 1 and random(1,100) <= (db.soulstoneSettings[5].frequency * 100) then
						if db.soulstoneSettings[1].emote == true and db.soulstoneSettings[1].emote_channels[3] == true then
							if db.soulstoneSettings[1].random == true then
								DoEmote(rrEmotes[random(1,15)])
							else
								DoEmote(rrEmotes[db.soulstoneSettings[1].emotelist])
							end
						end
						SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[5].quote[irq]),SoulSoloChannels[db.soulstoneSettings[1].solo_channel])
					end
					if db.soulstoneSettings[4].quote[iw] ~= "" and ss_res == 0 and random(1,100) <= (db.soulstoneSettings[4].frequency * 100) then
						SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[4].quote[iw]),"WHISPER",nil,ss_target)
					elseif  db.soulstoneSettings[6].quote[irw] ~= "" and ss_res == 1 and random(1,100) <= (db.soulstoneSettings[6].frequency * 100) then
						SendChatMessage(SoulSpeak.txtReplace(db.soulstoneSettings[6].quote[irw]),"WHISPER",nil,ss_target)
					end
				end
			end	
		end
		ss_target = ""			
		ss_res = 0
	end
	--[[
	****************
	* summon demon *
	--]]
	local summonSpell = {
		GetSpellInfo(30146), GetSpellInfo(112870), GetSpellInfo(691), GetSpellInfo(112869), GetSpellInfo(688), GetSpellInfo(112866),
		GetSpellInfo(712), GetSpellInfo(112868), GetSpellInfo(697), GetSpellInfo(25112), GetSpellInfo(112867), GetSpellInfo(18540),
		GetSpellInfo(112927), GetSpellInfo(1122), GetSpellInfo(112921),
	}
	if arg2 == "player" then
		for i = 1,15 do
			if arg4 == summonSpell[i] then
				db.lastSUMicon = db.demonSettings[i].icon
			end
		end
	end
end

--[[
*********************
* function UNIT_PET *
--]]
function SoulSpeak:UNIT_PET(arg1,arg2)
	if arg2 == "player" and (UnitName("pet")) ~= "Unknown" then
		local i
		for i = 1,15 do
			if UnitCreatureFamily("pet") == db.demonSettings[i].demon and (UnitName("pet")) ~= db.demonSettings[i].name then
				db.demonSettings[i].name = (UnitName("pet"))
				DEFAULT_CHAT_FRAME:AddMessage("\124TInterface\\Icons\\Spell_Shadow_SoulGem:12\124t |cffffffff<|cffB0A0ffSoulSpeak|cffffffff>|r "..db.demonSettings[i].demon.." |cffffffffsaved as |cffff0000<|cffB0A0ff"..db.demonSettings[i].name.."|cffff0000>")
			end
		end		
	end
end

--[[
******************************
* function RESURRECT_REQUEST *
--]]
function SoulSpeak:RESURRECT_REQUEST(arg1,arg2)
	if db.resurrectedSettings.resurrected == true and arg2 ~= nil then
		db.resurrectedSettings.player = arg2
	else
		db.resurrectedSettings.player = ""
	end
end

--[[
***************************
* function PLAYER_UNGHOST *
--]]
function SoulSpeak:PLAYER_UNGHOST()
	SoulSpeak.player_resurrected()
end

--[[
*************************
* function PLAYER_ALIVE *
--]]
function SoulSpeak:PLAYER_ALIVE()
	SoulSpeak.player_resurrected()
end

--[[
*********************************
* function player_resurrected() *
--]]
function SoulSpeak.player_resurrected()
	local ResurrectedEmotes = {
	"THANK", "HUG", "BLINK", "KISS", "SMILE", "PRAISE",
	"LOVE", "GAZE", "ABSENT", "PURR", "SEXY", "DANCE",
	"BOW", "CHEER",
	}
	if db.resurrectedSettings.resurrected == true and db.resurrectedSettings.player ~= "" and random(1,100) <= (db.resurrectedSettings.frequency * 100) then
		if GetNumGroupMembers() > 5 and db.resurrectedSettings.raid == true then
			if db.resurrectedSettings.random_raid == true then
				DoEmote(ResurrectedEmotes[random(1,14)],db.resurrectedSettings.player)
			else
				DoEmote(ResurrectedEmotes[db.resurrectedSettings.raid_emotes],db.resurrectedSettings.player)
			end
		elseif GetNumGroupMembers() > 0 and GetNumGroupMembers() < 6 and db.resurrectedSettings.party == true then
			if db.resurrectedSettings.random_party == true then
				DoEmote(ResurrectedEmotes[random(1,14)],db.resurrectedSettings.player)
			else
				DoEmote(ResurrectedEmotes[db.resurrectedSettings.party_emotes],db.resurrectedSettings.player)
			end
		elseif db.resurrectedSettings.solo == true then
			if db.resurrectedSettings.random_solo == true then
				DoEmote(ResurrectedEmotes[random(1,14)],db.resurrectedSettings.player)
			else
				DoEmote(ResurrectedEmotes[db.resurrectedSettings.solo_emotes],db.resurrectedSettings.player)
			end
		end
		db.resurrectedSettings.player = ""
	end
end

--[[
*********************
* SoulSpeak options *
--]]
SoulSpeak.Options = {
	handler = SoulSpeak,
	type = 'group',
	childGroups = "tab",
	name = icon[5].."16\124t |CFF71D5FF["..L.OPTIONS.."]|r",
	order = 0,
	args = {
		options = {
			name = "\124TInterface\\Icons\\spell_shadow_auraofdarkness:16\124t "..L.OPTIONS,
			order = 1,
			type = "group",
			args = {
				SoulSpeak = {
 					type = "toggle",
   				name = L.ENABLE:gsub("^%l", string.upper).." SoulSpeak",
   				desc = "",
					descStyle = "inline",
					order = 2,
					get = "getSSopt",
					set = "ssOnOff",
				},
				ssLDB_options = {
					type = 'multiselect',
					name = "|cffbbbbbb"..L["Hide from minimap/LDB"],
					desc = "|cffbbbbbb"..L["Hide from minimap/LDB"],
					descStyle = "inline",
					order = 15,
					get = function(_, x) return db.ssLDB_options[x] end,
   				set = function(_, x)
   					db.ssLDB_options[x] = not db.ssLDB_options[x]
   					db.ssLDBbutton.hide = db.ssLDB_options[1]
   					if not db.ssLDB_options[1] then ssMMicon:Show("SoulSpeakBlock")
     				else ssMMicon:Hide("SoulSpeakBlock")
     				end
          end,
					values = { L["Button"], L["Hints"], L["Title"] },
				},
		 		ssTab4 = {
					type = "description",
					name = "",
					order = 19,
 				},
				ssLine2 = {
			  	type = "header",
			  	name = "|cffbbbbbb"..L.ABOUT,
			  	order = 20,
				},
				logdesc = {
				type = "description",
				name = L["ABOUT_TEXT"](GetAddOnMetadata("SoulSpeak", "version")),
				order = 22,
				},
 			},
 		},
	},
}

SoulSpeak.SoulstoneOptions = {
	handler = SoulSpeak,
	type = 'group',
	childGroups = "tab",
	name = icon[5].."16\124t |CFF71D5FF["..L.SSR.."]|r",
	order = 3,
	args = {
		soulstoneSettings = {
			name = "\124TInterface\\Icons\\spell_shadow_auraofdarkness:16\124t "..L.OPTIONS,
			order = 0,
			type = "group",
			args = {
				soulstone = {
     			type = "toggle",
    			name = L.USE,
    			desc = L.QUOTESCASTING,
					order = 2,
     			get = "getSSopt",
     			set = "setSSopt",
     			disabled = "disSSopt",
 				},
				ssTab = {
 					type = "description",
   				name = "",
					order = 3,
    		},
    		party = {
    			type = "toggle",
    			name = L.INPARTY,
    			desc = "",
					descStyle = "inline",
					order = 4,
     			get = "getSSopt",
    			set = "setSSopt",
     			disabled = "disSSopt",
    		},
				party_channel = {
					type = 'select',
					name = L.SELECTEDCHANNEL,
					desc = "",
					descStyle = "inline",
					order = 5,
    			get = "getSSopt",
    			set = "setSSopt",
					values = SoulPartyQuoteChannels,
     			disabled = "disSSopt",
     			width = "double",
				},
    		raid = {
		    	type = "toggle",
  	  		name = L.INRAID,
    			desc = "",
					descStyle = "inline",
					order = 7,
     			get = "getSSopt",
    			set = "setSSopt",
     			disabled = "disSSopt",
    		},
				raid_channel = {
					type = 'select',
					name = L.SELECTEDCHANNEL,
					desc = "",
					descStyle = "inline",
					order = 8,
    			get = "getSSopt",
    			set = "setSSopt",
					values = SoulRaidQuoteChannels,
     			disabled = "disSSopt",
     			width = "double",
				},
    		solo = {
    			type = "toggle",
    			name = L.BYOURSELF,
    			desc = "",
					descStyle = "inline",
					order = 10,
     			get = "getSSopt",
    			set = "setSSopt",
     			disabled = "disSSopt",
    		},
				solo_channel = {
					type = 'select',
					name = L.SELECTEDCHANNEL,
					desc = "",
					descStyle = "inline",
					order = 11,
    			get = "getSSopt",
    			set = "setSSopt",
					values = SoulSoloQuoteChannels,
     			disabled = "disSSopt",
     			width = "double",
				},
				self = {
		 			type = "toggle",
  	 			name = L.ONYOURSELF,
   				desc = "",
					descStyle = "inline",
					order = 13,
     			get = "getSSopt",
    			set = "setSSopt",
     			disabled = "disSSopt",
    		},
    		rrTab1 = {
					type = "description",
					name = "",
					order = 14,
 				},
				rrLine = {
			  	type = "header",
			  	name = "p"..L.EMOTE:gsub("^%l", string.upper),
			  	order = 15,
			  },
 				rrTab2 = {
					type = "description",
					name = "",
					order = 17,
 				},
 				random = {
 					type = "toggle",
   				name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
   				desc = "",
					descStyle = "inline",
   				order = 18,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
 				},
 				emotelist = {
					type = 'select',
					name = "",
					order = 19,
					get = "getSSopt",
    			set = "setSSopt",
					values = rrStyles,
     			disabled = "disSSopt",
     			width = "double",
				},
				emote_channels = {
					type = 'multiselect',
					name = "|cffbbbbbb.."..L.AND.." "..L.ACTIVATED.." "..L.IN,
					desc = "",
					descStyle = "inline",
					order = 20,
					get = function(_, x) return db.soulstoneSettings[1].emote_channels[x] end,
   				set = function(_, x, y)
   					local i
		      	local n = 0
						for i = 1, 3 do
							if db.soulstoneSettings[1].emote_channels[i] == false then n = n + 1 end
						end
					if n == 2 then db.soulstoneSettings[1].emote_channels[x] = true else db.soulstoneSettings[1].emote_channels[x] = y end
          end,
					values = Channels,
					disabled = "disSSopt",
				},
			},
		},
		soulstone_emoteSettings = {
			type = 'group',
			name = icon[1].."16\124t "..L.EMOTES,
			order = 10,
			args = {
				quotesmaxscale = {
					order = 1,
					type = "range",
					name = icon[1].."16\124t "..L.EMOTES,
					desc = "",
					descStyle = "inline",
					min = 1, max = 21, step = 1,
 					get = "getSSopt",
 					set = "setSSopt",
 					disabled = "disSSopt",
 				},
 				frequency = {
					order = 2,
					type = "range",
					name = icon[7].."16\124t "..L.FREQUENCY,
					desc = "",
					descStyle = "inline",
					min = 0.01, max = 1, step = 0.01,
 					get = "getSSopt",
 					set = "setSSopt",
					disabled = "disSSopt",
					width = "double",
					isPercent = true,
				},
				SoulstoneEmoteTab = {
 					type = "description",
 					name = "|cFF00FF00"..L.SUPPORT.."\n|cff7fff7f"..L.TAGDESCPLAYER.."\n|cFF00FF00"..L.GENPLAYER.." |cffff0000"..L.ONLY.." |cFF00FF00"..L.AND.." |cffff0000"..L.NOT.." |cFF00FF00"..L.CASESENSITIVE,
 					desc = " ",
 					order = 3,
				},						
				SSemoteGroup = {
					type = "group",
					name = " ",
					guiInline = true,
					order = 4,
					childGroups = "input",
					args = {
						[L.SOULSTONE.." "..L.EMOTE.." #01"] = toggle_option, [L.SOULSTONE.." "..L.EMOTE.." #02"] = toggle_option,
						[L.SOULSTONE.." "..L.EMOTE.." #03"] = toggle_option, [L.SOULSTONE.." "..L.EMOTE.." #04"] = toggle_option,
						[L.SOULSTONE.." "..L.EMOTE.." #05"] = toggle_option, [L.SOULSTONE.." "..L.EMOTE.." #06"] = toggle_option,
						[L.SOULSTONE.." "..L.EMOTE.." #07"] = toggle_option, [L.SOULSTONE.." "..L.EMOTE.." #08"] = toggle_option,
						[L.SOULSTONE.." "..L.EMOTE.." #09"] = toggle_option, [L.SOULSTONE.." "..L.EMOTE.." #10"] = toggle_option,
						[L.SOULSTONE.." "..L.EMOTE.." #11"] = toggle_option, [L.SOULSTONE.." "..L.EMOTE.." #12"] = toggle_option,
						[L.SOULSTONE.." "..L.EMOTE.." #13"] = toggle_option, [L.SOULSTONE.." "..L.EMOTE.." #14"] = toggle_option,
						[L.SOULSTONE.." "..L.EMOTE.." #15"] = toggle_option, [L.SOULSTONE.." "..L.EMOTE.." #16"] = toggle_option,
						[L.SOULSTONE.." "..L.EMOTE.." #17"] = toggle_option, [L.SOULSTONE.." "..L.EMOTE.." #18"] = toggle_option,
						[L.SOULSTONE.." "..L.EMOTE.." #19"] = toggle_option, [L.SOULSTONE.." "..L.EMOTE.." #20"] = toggle_option,
						[L.SOULSTONE.." "..L.EMOTE.." #21"] = toggle_option,
					},
				},
			},
		},
		soulstone_quoteSettings = {
			type = 'group',
			name = icon[1].."16\124t "..L.QUOTES,
			order = 12,
			args = {
				quotesmaxscale = {
					order = 1,
					type = "range",
					name = icon[1].."16\124t "..L.QUOTES,
					desc = "",
					descStyle = "inline",
					min = 1, max = 39, step = 1,
					get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
				},
				frequency = {
					order = 2,
					type = "range",
					name = icon[7].."16\124t "..L.FREQUENCY,
					desc = "",
					descStyle = "inline",
					min = 0, max = 1, step = 0.01,
 					get = "getSSopt",
 					set = "setSSopt",
					disabled = "disSSopt",
					width = "double",
					isPercent = true,
				},
				SoulstoneQuoteTab = {
					type = "description",
 					name = "|cFF00FF00"..L.SUPPORT.."\n|cff7fff7f"..L.TAGDESCTARGET.."\n|cFF00FF00"..L.GENTARGET.." |cffff0000"..L.ONLY.." |cFF00FF00"..L.AND.." |cffff0000"..L.NOT.." |cFF00FF00"..L.CASESENSITIVE,
	 				desc = " ",
 					order = 3,
				},
				SSquoteGroup = {
					type = "group",
					name = " ",
					guiInline = true,
					order = 4,
					childGroups = "input",
					args = {
						[L.SOULSTONE.." "..L.QUOTE.." #01"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #02"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #03"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #04"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #05"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #06"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #07"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #08"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #09"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #10"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #11"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #12"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #13"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #14"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #15"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #16"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #17"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #18"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #19"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #20"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #21"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #22"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #23"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #24"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #25"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #26"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #27"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #28"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #29"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #30"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #31"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #32"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #33"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #34"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #35"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #36"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #37"] = toggle_option, [L.SOULSTONE.." "..L.QUOTE.." #38"] = toggle_option,
						[L.SOULSTONE.." "..L.QUOTE.." #39"] = toggle_option,
					},
				},						
			},
		},
		soulstone_whisperSettings = {
			type = 'group',
			name = icon[1].."16\124t "..L.WHISPERS,
			order = 13,
			args = {
				quotesmaxscale = {
					order = 1,
					type = "range",
					name = icon[1].."16\124t "..L.WHISPERS,
					desc = "",
					descStyle = "inline",
					min = 1, max = 24, step = 1,
					get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
				},
				frequency = {
					order = 2,
					type = "range",
					name = icon[7].."16\124t "..L.FREQUENCY,
					desc = "",
					descStyle = "inline",
					min = 0, max = 1, step = 0.01,
 					get = "getSSopt",
 					set = "setSSopt",
					disabled = "disSSopt",
					width = "double",
					isPercent = true,
				},
				SoulstoneWhisperTab = {
					type = "description",
					name = "|cFF00FF00"..L.SUPPORT.."\n|cff7fff7f"..L.TAGDESCTARGET.."\n|cFF00FF00"..L.GENTARGET.." |cffff0000"..L.ONLY.." |cFF00FF00"..L.AND.." |cffff0000"..L.NOT.." |cFF00FF00"..L.CASESENSITIVE,
					desc = " ",
					order = 3,
				},
				SSwhisperGroup = {
					type = "group",
					name = " ",
					guiInline = true,
					order = 4,
					childGroups = "input",
					args = {
						[L.SOULSTONE.." "..L.WHISPER.." #01"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #02"] = toggle_option,
						[L.SOULSTONE.." "..L.WHISPER.." #03"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #04"] = toggle_option,
						[L.SOULSTONE.." "..L.WHISPER.." #05"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #06"] = toggle_option,
						[L.SOULSTONE.." "..L.WHISPER.." #07"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #08"] = toggle_option,
						[L.SOULSTONE.." "..L.WHISPER.." #09"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #10"] = toggle_option,
						[L.SOULSTONE.." "..L.WHISPER.." #11"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #12"] = toggle_option,
						[L.SOULSTONE.." "..L.WHISPER.." #13"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #14"] = toggle_option,
						[L.SOULSTONE.." "..L.WHISPER.." #15"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #16"] = toggle_option,
						[L.SOULSTONE.." "..L.WHISPER.." #17"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #18"] = toggle_option,
						[L.SOULSTONE.." "..L.WHISPER.." #19"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #20"] = toggle_option,
						[L.SOULSTONE.." "..L.WHISPER.." #21"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #22"] = toggle_option,
						[L.SOULSTONE.." "..L.WHISPER.." #23"] = toggle_option, [L.SOULSTONE.." "..L.WHISPER.." #24"] = toggle_option,
					},
				},
			},
		},
	},
}

SoulSpeak.RitualSummoningOptions = {
	handler = SoulSpeak,
	type = 'group',
	childGroups = "tab",
	name = icon[4].."16\124t |CFF71D5FF["..L.RITUALSUMMONING.."]|r",
	order = 2,
	args = {
		summoning_configSettings = {
			name = "\124TInterface\\Icons\\spell_shadow_auraofdarkness:16\124t "..L.OPTIONS,
			order = 0,
			type = "group",
			args = {
				ritual = {
 					type = "toggle",
   				name = L.USE,
   				desc = L.QUOTESCASTING,
					order = 1,
     			get = "getSSopt",
     			set = "setSSopt",
     			disabled = "disSSopt",
 				},
				frequency = {
					order = 2,
					type = "range",
					name = icon[7].."16\124t "..L.FREQUENCY,
					desc = "",
					descStyle = "inline",
					min = 0.01, max = 1, step = 0.01,
 					get = "getSSopt",
 					set = "setSSopt",
					disabled = "disSSopt",
					width = "double",
					isPercent = true,
				},
		 		rsuTab1 = {
					type = "description",
					name = "",
					order = 3,
 				},
 				party = {
 					type = "toggle",
   				name = L.INPARTY,
   				desc = "",
					descStyle = "inline",
					order = 5,
     			get = "getSSopt",
     			set = "setSSopt",
					disabled = "disSSopt",
 				},
				party_channel = {
					type = 'select',
					name = L.SELECTEDCHANNEL,
					desc = "",
					descStyle = "inline",
					order = 6,
   				get = "getSSopt",
   				set = "setSSopt",
					values = PartyQuoteChannels,
					disabled = "disSSopt",
					width = "double",
				},
 				raid = {
 					type = "toggle",
   				name = L.INRAID,
   				desc = "",
					descStyle = "inline",
					order = 8,
     			get = "getSSopt",
     			set = "setSSopt",
					disabled = "disSSopt",
 				},
				raid_channel = {
					type = 'select',
					name = L.SELECTEDCHANNEL,
					desc = "",
					descStyle = "inline",
					order = 9,
   				get = "getSSopt",
   				set = "setSSopt",
					values = RaidQuoteChannels,
					disabled = "disSSopt",
					width = "double",
				},
				chat = {
 					type = "toggle",
   				name = L.INCHAT,
   				desc = L.SENDCHAT,
					order = 11,
     			get = "getSSopt",
     			set = "setSSopt",
					disabled = "disSSopt",
					width = "double",
 				},
		 		rsuTab2 = {
					type = "description",
					name = "",
					order = 12,
 				},
				helpme = {
 					type = "toggle",
   				name = L.HELPME,
   				desc = L.EMOTESCASTING,
					order = 13,
    			get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
 				},
 				rsuTab3 = {
					type = "description",
					name = "",
					order = 14,
 				},
				rsuLine = {
			  	type = "header",
			  	name = "p"..L.EMOTE:gsub("^%l", string.upper),
			  	order = 15,
			  },
 				emote = {
 					type = "toggle",
   				name = L.USE.." pre-"..L.EMOTE:gsub("^%l", string.upper),
   				desc = "",
					descStyle = "inline",
					order = 16,
     			get = "getSSopt",
   				set = "setSSopt",
     			disabled = "disSSopt",
 				},
				delay = {
 					type = "toggle",
   				name = "2 "..L.SEC.." "..L.DELAY.." "..L.EMOTE.." <> "..L.QUOTE,
   				desc = "",
					descStyle = "inline",
					order = 17,
     			get = "getSSopt",
   				set = "setSSopt",
     			disabled = "disSSopt",
     			width = "double",
 				},
 				random = {
 					type = "toggle",
   				name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
   				desc = "",
					descStyle = "inline",
   				order = 18,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
 				},
 				emotelist = {
					type = 'select',
					name = "",
					order = 19,
					get = "getSSopt",
    			set = "setSSopt",
					values = rsuStyles,
     			disabled = "disSSopt",
     			width = "double",
				},
				emote_channels = {
					type = 'multiselect',
					name = "|cffbbbbbb.."..L.AND.." "..L.ACTIVATED.." "..L.IN,
					desc = "",
					descStyle = "inline",
					order = 20,
					get = function(_, x) return db.ritualSettings[2].emote_channels[x] end,
   				set = function(_, x, y)
   					local i
		      	local n = 0
						for i = 1, 3 do
							if db.ritualSettings[2].emote_channels[i] == false then n=n+1 end
						end
					if n == 2 then db.ritualSettings[2].emote_channels[x] = true else db.ritualSettings[2].emote_channels[x] = y end
          end,
					values = Channels,
					disabled = "disSSopt",
				},
 			},
 		},
		summoning_quoteSettings = {
			type = 'group',
			name = icon[1].."16\124t "..L.QUOTES,
			order = 10,
			args = {
				quotesmaxscale = {
					order = 13,
					type = "range",
					name = icon[1].."16\124t "..L.QUOTES,
					desc = "",
					descStyle = "inline",
					min = 1, max = 33, step = 1,
 					get = "getSSopt",
 					set = "setSSopt",
					disabled = "disSSopt",
				},					
				RitualSummoningQuoteTab = {
					type = "description",
					name = "|cFF00FF00"..L.SUPPORT.."\n|cff7fff7f"..L.TAGDESCPLAYER.."\n|cFF00FF00"..L.GENPLAYER.." |cffff0000"..L.ONLY.." |cFF00FF00"..L.AND.." |cffff0000"..L.NOT.." |cFF00FF00"..L.CASESENSITIVE,
					desc = " ",
					order = 14,
				},
				RSUquoteGroup = {
					type = "group",
					name = " ",
					guiInline = true,
					order = 15,
					childGroups = "input",
					args = {
						[L.RITUALSUMMONING.." #01"] = toggle_option, [L.RITUALSUMMONING.." #02"] = toggle_option,
						[L.RITUALSUMMONING.." #03"] = toggle_option, [L.RITUALSUMMONING.." #04"] = toggle_option,
						[L.RITUALSUMMONING.." #05"] = toggle_option, [L.RITUALSUMMONING.." #06"] = toggle_option,
						[L.RITUALSUMMONING.." #07"] = toggle_option, [L.RITUALSUMMONING.." #08"] = toggle_option,
						[L.RITUALSUMMONING.." #09"] = toggle_option, [L.RITUALSUMMONING.." #10"] = toggle_option,
						[L.RITUALSUMMONING.." #11"] = toggle_option, [L.RITUALSUMMONING.." #12"] = toggle_option,
						[L.RITUALSUMMONING.." #13"] = toggle_option, [L.RITUALSUMMONING.." #14"] = toggle_option,
						[L.RITUALSUMMONING.." #15"] = toggle_option, [L.RITUALSUMMONING.." #16"] = toggle_option,
						[L.RITUALSUMMONING.." #17"] = toggle_option, [L.RITUALSUMMONING.." #18"] = toggle_option,
						[L.RITUALSUMMONING.." #19"] = toggle_option, [L.RITUALSUMMONING.." #20"] = toggle_option,
						[L.RITUALSUMMONING.." #21"] = toggle_option, [L.RITUALSUMMONING.." #22"] = toggle_option,
						[L.RITUALSUMMONING.." #23"] = toggle_option, [L.RITUALSUMMONING.." #24"] = toggle_option,
						[L.RITUALSUMMONING.." #25"] = toggle_option, [L.RITUALSUMMONING.." #26"] = toggle_option,
						[L.RITUALSUMMONING.." #27"] = toggle_option, [L.RITUALSUMMONING.." #28"] = toggle_option,
						[L.RITUALSUMMONING.." #29"] = toggle_option, [L.RITUALSUMMONING.." #30"] = toggle_option,
						[L.RITUALSUMMONING.." #31"] = toggle_option, [L.RITUALSUMMONING.." #32"] = toggle_option,
						[L.RITUALSUMMONING.." #33"] = toggle_option,
					},
				},
 			},
 		},
 	},
}

SoulSpeak.sumOptions = {
	handler = SoulSpeak,
	type = 'group',
	childGroups = "tab",
	name = function(info) return db.lastSUMicon.."6\124t |CFF71D5FF["..L.SUMMONS.."]|r" end,
	order = 4,
	args = {
		demonSettings = {
			name = "\124TInterface\\Icons\\spell_shadow_auraofdarkness:16\124t "..L.OPTIONS,
			order = 0,
			type = "group",
			args = {
 				summon = {
 					type = "toggle",
   				name = L.USE,
   				desc = L.QUOTES..L.EMOTESUM,
   				order = 1,
     			get = "getSSopt",
     			set = "setSSopt",
     			disabled = "disSSopt",
 				},
 				sumTab1 = {
					type = "description",
					name = "",
					order = 3,
 				},
 				party = {
 					type = "toggle",
   				name = L.INPARTY,
   				desc = "",
					descStyle = "inline",
					order = 4,
     			get = "getSSopt",
   				set = "setSSopt",
     			disabled = "disSSopt",
 				},
				party_channel = {
					type = 'select',
					name = L.SELECTEDCHANNEL,
					desc = "",
					descStyle = "inline",
					order = 5,
   				get = "getSSopt",
   				set = "setSSopt",
					values = PartyQuoteChannels,
     			disabled = "disSSopt",
     			width = "double",
				},
 				sumTab2 = {
					type = "description",
					name = "",
					order = 6,
 				},
 				raid = {
 					type = "toggle",
   				name = L.INRAID,
   				desc = "",
					descStyle = "inline",
					order = 7,
     			get = "getSSopt",
   				set = "setSSopt",
     			disabled = "disSSopt",
 				},
				raid_channel = {
					type = 'select',
					name = L.SELECTEDCHANNEL,
					desc = "",
					descStyle = "inline",
					order = 8,
   				get = "getSSopt",
   				set = "setSSopt",
					values = RaidQuoteChannels,
     			disabled = "disSSopt",
     			width = "double",
				},
 				sumTab3 = {
					type = "description",
					name = "",
					order = 9,
 				},	
 				solo = {
 					type = "toggle",
   				name = L.BYOURSELF,
   				desc = "",
					descStyle = "inline",
					order = 10,
     			get = "getSSopt",
   				set = "setSSopt",
     			disabled = "disSSopt",
 				},
				solo_channel = {
					type = 'select',
					name = L.SELECTEDCHANNEL,
					desc = "",
					descStyle = "inline",
					order = 11,
   				get = "getSSopt",
   				set = "setSSopt",
					values = SoloQuoteChannels,
     			disabled = "disSSopt",
     			width = "double",
				},
				sumTab4 = {
					type = "description",
					name = "",
					order = 12,
 				},
				sumLine = {
			  	type = "header",
			  	name = "",
			  	order = 13,
			  },
 				combat = {
 					type = "toggle",
   				name = "Use while in combat",
   				desc = "",
					descStyle = "inline",
					order = 14,
     			get = "getSSopt",
   				set = "setSSopt",
     			disabled = "disSSopt",
 				},
				combat_channels = {
					type = 'multiselect',
					name = "|cffbbbbbb.."..L.AND.." "..L.ACTIVATED.." "..L.IN,
					desc = "",
					descStyle = "inline",
					order = 15,
					get = function(_, x) return db.demonSettings[16].combat_channels[x] end,
   				set = function(_, x, y)
   					local i
		      	local n = 0
						for i = 1, 3 do
							if db.demonSettings[16].combat_channels[i] == false then n=n+1 end
						end
						if n == 2 then db.demonSettings[16].combat_channels[x] = true else db.demonSettings[16].combat_channels[x] = y end
          end,
					values = Channels,
     			disabled = "disSSopt",
				},
			},
		},
		FELquoteOptions = {
			type = 'group',
			name = function() return db.demonSettings[3].icon.."6\124t "..db.demonSettings[3].demon.." "..string.lower(L.QUOTES) end,
			order = 5,
			args = {
				quotesmaxscale = {
					order = 2,
					type = "range",
					name = icon[1].."16\124t "..L.QUOTES,
					desc = "",
					descStyle = "inline",
					min = 1, max = 15, step = 1,
 					get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
				},
				frequency = {
					order = 3,
					type = "range",
					name = icon[7].."16\124t "..L.FREQUENCY,
					desc = "",
					descStyle = "inline",
					min = 0, max = 1, step = 0.01,
					get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
					width = "double",
					isPercent = true,
				},
				FELquoteTab = {
					type = "description",
					name = function() return "|cFF00FF00"..L.SUPPORT.."\n|cff7fff7f"..L.TAGDESCPLAYER.."\n|cFF00FF00"..L.GENPLAYER.." |cffff0000"..L.ONLY.." |cFF00FF00"..L.AND.." |cffff0000"..L.NOT.." |cFF00FF00"..L.CASESENSITIVE.."\n"..L.IFNONAME.."\n"..L.FEL..L.NAMEDETECT.."|cffff0000<|cffB0A0ff"..db.demonSettings[3].name.."|cffff0000>" end,
					desc = " ",
					order = 4,
				},
				emote = {
 					type = "toggle",
   				name = L.USE.." pre-"..L.EMOTE:gsub("^%l", string.upper),
   				desc = "",
					descStyle = "inline",
					order = 7,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
 				},
				delay = {
 					type = "toggle",
   				name = "5 "..L.SEC.." "..L.DELAY.." "..L.EMOTE.." <> "..L.QUOTE,
   				desc = "",
					descStyle = "inline",
					order = 8,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
     			width = "double",
 				},
 				random = {
 					type = "toggle",
   				name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
   				desc = "",
					descStyle = "inline",
   				order = 9,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
 				},
 				emotelist = {
					type = 'select',
					name = "",
					order = 10,
					get = "getSSopt",
					set = "setSSopt",
					values = SUMpEmoteStyles,
     			disabled = "disSSopt",
     			width = "double",
				},
				quote = {
					type = "group",
					name = " ",
					guiInline = true,
					order = 12,
					childGroups = "input",
					args = {
						[L.FEL.." #01"] = toggle_option, [L.FEL.." #02"] = toggle_option,
						[L.FEL.." #03"] = toggle_option, [L.FEL.." #04"] = toggle_option,
						[L.FEL.." #05"] = toggle_option, [L.FEL.." #06"] = toggle_option,
						[L.FEL.." #07"] = toggle_option, [L.FEL.." #08"] = toggle_option,
						[L.FEL.." #09"] = toggle_option, [L.FEL.." #10"] = toggle_option,
						[L.FEL.." #11"] = toggle_option, [L.FEL.." #12"] = toggle_option,
						[L.FEL.." #13"] = toggle_option, [L.FEL.." #14"] = toggle_option,
						[L.FEL.." #15"] = toggle_option,
					},
				},
			},
		},
		IMPquoteOptions = {
			type = 'group',
			name = function() return db.demonSettings[5].icon.."6\124t "..db.demonSettings[5].demon.." "..string.lower(L.QUOTES) end,
			order = 7,
			args = {
				quotesmaxscale = {
					order = 2,
					type = "range",
					name = icon[1].."16\124t "..L.QUOTES,
					desc = "",
					descStyle = "inline",
					min = 1, max = 30, step = 1,
 					get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
				},
				frequency = {
					order = 3,
					type = "range",
					name = icon[7].."16\124t "..L.FREQUENCY,
					desc = "",
					descStyle = "inline",
					min = 0, max = 1, step = 0.01,
					get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
					width = "double",
					isPercent = true,
				},
				IMPquoteTab = {
					type = "description",
					name = function() return "|cFF00FF00"..L.SUPPORT.."\n|cff7fff7f"..L.TAGDESCPLAYER.."\n|cFF00FF00"..L.GENPLAYER.." |cffff0000"..L.ONLY.." |cFF00FF00"..L.AND.." |cffff0000"..L.NOT.." |cFF00FF00"..L.CASESENSITIVE.."\n"..L.IFNONAME.."\n"..L.IMP..L.NAMEDETECT.."|cffff0000<|cffB0A0ff"..db.demonSettings[5].name.."|cffff0000>" end,
					desc = " ",
					order = 4,
				},
				emote = {
 					type = "toggle",
   				name = L.USE.." pre-"..L.EMOTE:gsub("^%l", string.upper),
   				desc = "",
					descStyle = "inline",
					order = 7,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
 				},
				delay = {
 					type = "toggle",
   				name = "5 "..L.SEC.." "..L.DELAY.." "..L.EMOTE.." <> "..L.QUOTE,
   				desc = "",
					descStyle = "inline",
					order = 8,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
     			width = "double",
 				},
 				random = {
 					type = "toggle",
   				name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
   				desc = "",
					descStyle = "inline",
   				order = 9,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
 				},
 				emotelist = {
					type = 'select',
					name = "",
					order = 10,
					get = "getSSopt",
					set = "setSSopt",
					values = SUMpEmoteStyles,
     			disabled = "disSSopt",
     			width = "double",
				},					
				quote = {
					type = "group",
					name = " ",
					guiInline = true,
					order = 12,
					childGroups = "input",
					args = {
						[L.IMP.." #01"] = toggle_option, [L.IMP.." #02"] = toggle_option,
						[L.IMP.." #03"] = toggle_option, [L.IMP.." #04"] = toggle_option,
						[L.IMP.." #05"] = toggle_option, [L.IMP.." #06"] = toggle_option,
						[L.IMP.." #07"] = toggle_option, [L.IMP.." #08"] = toggle_option,
						[L.IMP.." #09"] = toggle_option, [L.IMP.." #10"] = toggle_option,
						[L.IMP.." #11"] = toggle_option, [L.IMP.." #12"] = toggle_option,
						[L.IMP.." #13"] = toggle_option, [L.IMP.." #14"] = toggle_option,
						[L.IMP.." #15"] = toggle_option, [L.IMP.." #16"] = toggle_option,
						[L.IMP.." #17"] = toggle_option, [L.IMP.." #18"] = toggle_option,
						[L.IMP.." #19"] = toggle_option, [L.IMP.." #20"] = toggle_option,
						[L.IMP.." #21"] = toggle_option, [L.IMP.." #22"] = toggle_option,
						[L.IMP.." #23"] = toggle_option, [L.IMP.." #24"] = toggle_option,
						[L.IMP.." #24"] = toggle_option, [L.IMP.." #24"] = toggle_option,
						[L.IMP.." #25"] = toggle_option, [L.IMP.." #24"] = toggle_option,
						[L.IMP.." #26"] = toggle_option, [L.IMP.." #24"] = toggle_option,
						[L.IMP.." #27"] = toggle_option, [L.IMP.." #24"] = toggle_option,
						[L.IMP.." #28"] = toggle_option, [L.IMP.." #24"] = toggle_option,
						[L.IMP.." #29"] = toggle_option, [L.IMP.." #24"] = toggle_option,
						[L.IMP.." #30"] = toggle_option, [L.IMP.." #24"] = toggle_option,
					},
				},
			},
		},
		SUCquoteOptions = {
			type = 'group',
			name = function() return db.demonSettings[7].icon.."6\124t "..db.demonSettings[7].demon.." "..string.lower(L.QUOTES) end,
			order = 9,
			args = {
				quotesmaxscale = {
					order = 2,
					type = "range",
					name = icon[1].."16\124t "..L.QUOTES,
					desc = "",
					descStyle = "inline",
					min = 1, max = 15, step = 1,
 					get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
				},
				frequency = {
					order = 3,
					type = "range",
					name = icon[7].."16\124t "..L.FREQUENCY,
					desc = "",
					descStyle = "inline",
					min = 0, max = 1, step = 0.01,
					get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
					width = "double",
					isPercent = true,
				},
				SUCquoteTab = {
					type = "description",
					name = function() return "|cFF00FF00"..L.SUPPORT.."\n|cff7fff7f"..L.TAGDESCPLAYER.."\n|cFF00FF00"..L.GENPLAYER.." |cffff0000"..L.ONLY.." |cFF00FF00"..L.AND.." |cffff0000"..L.NOT.." |cFF00FF00"..L.CASESENSITIVE.."\n"..L.IFNONAME.."\n"..L.SUC..L.NAMEDETECT.."|cffff0000<|cffB0A0ff"..db.demonSettings[7].name.."|cffff0000>" end,
					desc = " ",
					order = 4,
				},				
				emote = {
 					type = "toggle",
   				name = L.USE.." pre-"..L.EMOTE:gsub("^%l", string.upper),
   				desc = "",
					descStyle = "inline",
					order = 7,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
 				},
				delay = {
 					type = "toggle",
   				name = "5 "..L.SEC.." "..L.DELAY.." "..L.EMOTE.." <> "..L.QUOTE,
   				desc = "",
					descStyle = "inline",
					order = 8,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
     			width = "double",
 				},
 				random = {
 					type = "toggle",
   				name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
   				desc = "",
					descStyle = "inline",
   				order = 9,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
 				},
 				emotelist = {
					type = 'select',
					name = "",
					order = 10,
					get = "getSSopt",
					set = "setSSopt",
					values = SUMpEmoteStyles,
     			disabled = "disSSopt",
     			width = "double",
				},				
				quote = {
					type = "group",
					name = " ",
					guiInline = true,
					order = 12,
					childGroups = "input",
					args = {
						[L.SUC.." #01"] = toggle_option, [L.SUC.." #02"] = toggle_option,
						[L.SUC.." #03"] = toggle_option, [L.SUC.." #04"] = toggle_option,
						[L.SUC.." #05"] = toggle_option, [L.SUC.." #06"] = toggle_option,
						[L.SUC.." #07"] = toggle_option, [L.SUC.." #08"] = toggle_option,
						[L.SUC.." #09"] = toggle_option, [L.SUC.." #10"] = toggle_option,
						[L.SUC.." #11"] = toggle_option, [L.SUC.." #12"] = toggle_option,
						[L.SUC.." #13"] = toggle_option, [L.SUC.." #14"] = toggle_option,
						[L.SUC.." #15"] = toggle_option,
					},
				},
			},
		},
		VOIDquoteOptions = {
			type = 'group',
			name = function() return db.demonSettings[9].icon.."6\124t "..db.demonSettings[9].demon.." "..string.lower(L.QUOTES) end,
			order = 11,
			args = {
				quotesmaxscale = {
					order = 2,
					type = "range",
					name = icon[1].."16\124t "..L.QUOTES,
					desc = "",
					descStyle = "inline",
					min = 1, max = 18, step = 1,
 					get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
				},
				frequency = {
					order = 3,
					type = "range",
					name = icon[7].."16\124t "..L.FREQUENCY,
					desc = "",
					descStyle = "inline",
					min = 0, max = 1, step = 0.01,
					get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
					width = "double",
					isPercent = true,
				},
				VOIDquoteTab = {
					type = "description",
					name = function() return "|cFF00FF00"..L.SUPPORT.."\n|cff7fff7f"..L.TAGDESCPLAYER.."\n|cFF00FF00"..L.GENPLAYER.." |cffff0000"..L.ONLY.." |cFF00FF00"..L.AND.." |cffff0000"..L.NOT.." |cFF00FF00"..L.CASESENSITIVE.."\n"..L.IFNONAME.."\n"..L.VOID..L.NAMEDETECT.."|cffff0000<|cffB0A0ff"..db.demonSettings[9].name.."|cffff0000>" end,
					desc = " ",
					order = 4,
				},				
				emote = {
 					type = "toggle",
   				name = L.USE.." pre-"..L.EMOTE:gsub("^%l", string.upper),
   				desc = "",
					descStyle = "inline",
					order = 7,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
 				},
				delay = {
 					type = "toggle",
   				name = "5 "..L.SEC.." "..L.DELAY.." "..L.EMOTE.." <> "..L.QUOTE,
   				desc = "",
					descStyle = "inline",
					order = 8,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
     			width = "double",
 				},
 				random = {
 					type = "toggle",
   				name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
   				desc = "",
					descStyle = "inline",
   				order = 9,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
 				},
 				emotelist = {
					type = 'select',
					name = "",
					order = 10,
					get = "getSSopt",
					set = "setSSopt",
					values = SUMpEmoteStyles,
     			disabled = "disSSopt",
     			width = "double",
				},				
				quote = {
					type = "group",
					name = " ",
					guiInline = true,
					order = 12,
					childGroups = "input",
					args = {
						[L.VOID.." #01"] = toggle_option, [L.VOID.." #02"] = toggle_option,
						[L.VOID.." #03"] = toggle_option, [L.VOID.." #04"] = toggle_option,
						[L.VOID.." #05"] = toggle_option, [L.VOID.." #06"] = toggle_option,
						[L.VOID.." #07"] = toggle_option, [L.VOID.." #08"] = toggle_option,
						[L.VOID.." #09"] = toggle_option, [L.VOID.." #10"] = toggle_option,
						[L.VOID.." #11"] = toggle_option, [L.VOID.." #12"] = toggle_option,
						[L.VOID.." #13"] = toggle_option, [L.VOID.." #14"] = toggle_option,
						[L.VOID.." #15"] = toggle_option,
						[L.VOID.." #16"] = toggle_option,
						[L.VOID.." #17"] = toggle_option,
						[L.VOID.." #18"] = toggle_option,																		
					},
				},
			},
		},
	},
}

SoulSpeak.HearthstoneOptions = {
	handler = SoulSpeak,
	type = 'group',
	childGroups = "tab",
	name = icon[2].."16\124t |CFF71D5FF["..L.HEARTHSTONE.."]|r",
	order = 5,
	args = {
		hearthstoneSettings = {
			type = "group",
			name = "\124TInterface\\Icons\\spell_shadow_auraofdarkness:16\124t "..L.OPTIONS,
			args = {
  			hearthstone = {
   				type = "toggle",
   				name = L.USE,
   				desc = L.EMOTEWITHYOURHS,
   				order = 1,
     			get = "getSSopt",
     			set = "setSSopt",
     			disabled = "disSSopt",
  			},
				frequency = {
					order = 2,
					type = "range",
					name = icon[7].."16\124t "..L.FREQUENCY,
					desc = "",
					descStyle = "inline",
					min = 0.01, max = 1, step = 0.01,
    			get = "getSSopt",
    			set = "setSSopt",
					disabled = "disSSopt",
					width = "double",
					isPercent = true,
				},
 				hsTab = {
					type = "description",
					name = "",
					order = 3,
 				},
				hsLine = {
					type = "header",
					name = "",
					order = 4,
				},
  			morning = {
  				type = "toggle",
    			name = L.HSMORNING,
    			desc = "",
					descStyle = "inline",
    			order = 10,
     			get = "getSSopt",
    			set = "setSSopt",
     			disabled = "disSSopt",
  			},
				morning_emotes = {
					type = 'select',
					name = L.SELECTEDEMOTE,
					desc = "",
					descStyle = "inline",
					order = 11,
     			get = "getSSopt",
    			set = "setSSopt",
					values = HearthstoneStyles,
     			disabled = "disSSopt",
     			width = "double",
				},
				random_morning = {
    			type = "toggle",
    			name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
    			desc = "",
					descStyle = "inline",
    			order = 12,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
    		},
    		hsTab2 = {
					type = "description",
					name = "",
					order = 13,
 				},
				hsLine2 = {
					type = "header",
					name = "",
					order = 14,
				},
  			afternoon = {
  				type = "toggle",
    			name = L.HSAFTERNOON,
    			desc = "",
					descStyle = "inline",
    			order = 20,
     			get = "getSSopt",
    			set = "setSSopt",
     			disabled = "disSSopt",
  			},      								
				afternoon_emotes = {
					type = 'select',
					name = L.SELECTEDEMOTE,
					desc = "",
					descStyle = "inline",
					order = 21,
     			get = "getSSopt",
    			set = "setSSopt",
					values = HearthstoneStyles,
     			disabled = "disSSopt",
     			width = "double",
				},
				random_afternoon = {
    			type = "toggle",
    			name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
    			desc = "",
					descStyle = "inline",
    			order = 22,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
    		},
				hsTab3 = {
					type = "description",
					name = "",
					order = 23,
 				},
				hsLine3 = {
					type = "header",
					name = "",
					order = 24,
				},
  			evening = {
  				type = "toggle",
    			name = L.HSEVENING,
    			desc = "",
					descStyle = "inline",
    			order = 30,
     			get = "getSSopt",
    			set = "setSSopt",
     			disabled = "disSSopt",
  			},      								
				evening_emotes = {
					type = 'select',
					name = L.SELECTEDEMOTE,
					desc = "",
					descStyle = "inline",
					order = 31,
     			get = "getSSopt",
    			set = "setSSopt",
					values = HearthstoneStyles,
     			disabled = "disSSopt",
     			width = "double",
				},
				random_evening = {
    			type = "toggle",
    			name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
    			desc = "",
					descStyle = "inline",
    			order = 32,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
    		},
    		hsTab4 = {
					type = "description",
					name = "",
					order = 33,
 				},
				hsLine4 = {
					type = "header",
					name = "",
					order = 40,
				},
    		night = {
    			type = "toggle",
    			name = L.HSNIGHT,
    			desc = "",
					descStyle = "inline",
    			order = 41,
     			get = "getSSopt",
    			set = "setSSopt",
     			disabled = "disSSopt",
    		},    
				night_emotes = {
					type = 'select',
					name = L.SELECTEDEMOTE,
					desc = "",
					descStyle = "inline",
					order = 42,
     			get = "getSSopt",
    			set = "setSSopt",
					values = HearthstoneStyles,
     			disabled = "disSSopt",
     			width = "double",
				},
    		random_night = {
    			type = "toggle",
    			name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
    			desc = "",
					descStyle = "inline",
    			order = 43,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
    		},
 			},
		},
	},
}

SoulSpeak.ResurrectedOptions = {
	handler = SoulSpeak,
	type = 'group',
	childGroups = "tab",
	name = icon[6].."16\124t |CFF71D5FF["..L.RESURRECTED.."]|r",
	order = 6,
	args = {
		resurrectedSettings = {
			type = "group",
			name = "\124TInterface\\Icons\\spell_shadow_auraofdarkness:16\124t "..L.OPTIONS,
			args = {
 				resurrected = {
 					type = "toggle",
   				name = L.USE,
   				desc = L.EMOTEREZ,
   				order = 2,
     			get = "getSSopt",
     			set = "setSSopt",
     			disabled = "disSSopt",
 				},
				frequency = {
					order = 3,
					type = "range",
					name = icon[7].."16\124t "..L.FREQUENCY,
					desc = "",
					descStyle = "inline",
					min = 0.01, max = 1, step = 0.01,
   				get = "getSSopt",
   				set = "setSSopt",
					disabled = "disSSopt",
					width = "double",
					isPercent = true,
				},
				resLine = {
					type = "header",
					name = "",
					order = 4,
				},
 				party = {
 					type = "toggle",
   				name = L.INPARTY,
   				desc = "",
					descStyle = "inline",
   				order = 5,
     			get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
 				},
				party_emotes = {
					type = 'select',
					name = L.SELECTEDEMOTE,
					desc = "",
					descStyle = "inline",
					order = 6,
     			get = "getSSopt",
					set = "setSSopt",
					values = ResurrectedStyles,
     			disabled = "disSSopt",
     			width = "double",
				},
				random_party = {
    			type = "toggle",
    			name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
    			desc = "",
					descStyle = "inline",
    			order = 7,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
    		},
    		resTab2 = {
					type = "description",
					name = "",
					order = 8,
				},
    		resLine2 = {
					type = "header",
					name = "",
					order = 9,
				},
 				raid = {
 					type = "toggle",
   				name = L.INRAID,
   				desc = "",
					descStyle = "inline",
   				order = 10,
     			get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
 				},
				raid_emotes = {
					type = 'select',
					name = L.SELECTEDEMOTE,
					desc = "",
					descStyle = "inline",
					order = 11,
     			get = "getSSopt",
					set = "setSSopt",
					values = ResurrectedStyles,
					disabled = "disSSopt",
					width = "double",
				},
				random_raid = {
    			type = "toggle",
    			name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
    			desc = "",
					descStyle = "inline",
    			order = 12,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
    		},
    		resTab3 = {
					type = "description",
					name = "",
					order = 13,
				},
				resLine3 = {
					type = "header",
					name = "",
					order = 14,
				},
 				solo = {
 					type = "toggle",
   				name = L.BYOURSELF,
   				desc = "",
					descStyle = "inline",
   				order = 15,
     			get = "getSSopt",
					set = "setSSopt",
					disabled = "disSSopt",
 				},
				solo_emotes = {
					type = 'select',
					name = L.SELECTEDEMOTE,
					desc = "",
					descStyle = "inline",
					order = 16,
     			get = "getSSopt",
					set = "setSSopt",
					values = ResurrectedStyles,
					disabled = "disSSopt",
					width = "double",
				},
 				random_solo = {
 					type = "toggle",
   				name = L.USE.." "..L.RANDOM.." "..L.EMOTE,
   				desc = "",
					descStyle = "inline",
   				order = 17,
     			get = "getSSopt",
					set = "setSSopt",
     			disabled = "disSSopt",
 				},
 			},
 		},
 	},
 }

--[[
**************************
* SoulSpeak OptionsSlash *
--]]
SoulSpeak.OptionsSlash = {
	handler = SoulSpeak,
	name = SlashCommand,
	order = -3,
	type = "group",
	args = {
		intro = {
			name = "SlashDescription",
			type = "description",
			order = 1,
			cmdHidden = true,
		},
		a = {
			name = "About",
			desc = "(|cffffff00A|r)bout",
			type = 'execute',
			order = 2,
			func = function()
				DEFAULT_CHAT_FRAME:AddMessage("|cffffffff<|cffB0A0ffSoulSpeak|cffffffff>|r v"..GetAddOnMetadata("SoulSpeak", "Version").."|cffffffff -|r "..GetAddOnMetadata("SoulSpeak", "Notes").."|r")
				DEFAULT_CHAT_FRAME:AddMessage("|cffffffff<|cffB0A0ffAuthor|cffffffff>|r "..GetAddOnMetadata("SoulSpeak", "X-Email").."|r")
				DEFAULT_CHAT_FRAME:AddMessage("|cffffffff<|cffB0A0ffWebsite|cffffffff>|r "..GetAddOnMetadata("SoulSpeak", "X-Website").."|r")
				if not db.ssLDB_options[1] then ssMMicon:Show("SoulSpeakBlock")
				else ssMMicon:Hide("SoulSpeakBlock") end
				end,
			cmdHidden = false
		},
		c = {
			name = "Config",
			desc = "(|cffffff00C|r)onfigure",
			type = 'execute',
			order = 3,
			func = "OpenOptions",
			dialogHidden = true
		},
		debug = {
			name = "Debug",
			desc = "(|cffffff00D|r)ebug on/off",
			type = 'execute',
			order = 3,
			func = function()
				if db.debug == false then
					db.debug = true
					DEFAULT_CHAT_FRAME:AddMessage(icon[5].."12\124t Debug is |cff00ff00on")
				else
					db.debug = false
					DEFAULT_CHAT_FRAME:AddMessage(icon[5].."12\124t Debug is |cffff0000off")
				end
				end,
			dialogHidden = true,
			cmdHidden = true
		},
		s = {
			name = "Status",
			desc = "(|cffffff00S|r)tatus",
			type = 'execute',
			order = 8,
			func = function()
				DEFAULT_CHAT_FRAME:AddMessage(icon[5].."12\124t |cffffffff<|cffB0A0ffSoulSpeak|cffffffff>|r")
				if db.ritualSettings[2].ritual == true then DEFAULT_CHAT_FRAME:AddMessage(icon[4].."12\124t |CFF71D5FF|Hspell:698|h[Ritual of Summoning]|h|r "..L.IS.." |cff00ff00"..L.ENABLED.."|r")
				else DEFAULT_CHAT_FRAME:AddMessage(icon[4].."12\124t |CFF71D5FF|Hspell:698|h[Ritual of Summoning]|h|r "..L.IS.." |cffff2f32"..L.DISABLED.."|r")
				end
				if db.soulstoneSettings[1].soulstone == true and (db.soulstoneSettings[3].frequency > 0 or db.soulstoneSettings[4].frequency > 0) then DEFAULT_CHAT_FRAME:AddMessage(icon[5].."12\124t |CFF71D5FF|Hspell:20707|h[Soulstone]|h|r "..L.IS.." |cff00ff00"..L.ENABLED.."|r")
				else DEFAULT_CHAT_FRAME:AddMessage(icon[5].."12\124t |CFF71D5FF|Hspell:20707|h[Soulstone]|h|r "..L.IS.." |cffff2f32"..L.DISABLED.."|r")
				end
				if db.demonSettings[16].summon == true then DEFAULT_CHAT_FRAME:AddMessage(db.lastSUMicon.."2\124t |CFF71D5FF|Hspell:101870|h[Summon demons]|h|r "..L.IS.." |cff00ff00"..L.ENABLED.."|r")
				else DEFAULT_CHAT_FRAME:AddMessage(db.lastSUMicon.."2\124t |CFF71D5FF|Hspell:101870|h[Summon demons]|h|r "..L.IS.." |cffff2f32"..L.DISABLED.."|r")
				end
				if db.hearthstoneSettings.hearthstone == true then DEFAULT_CHAT_FRAME:AddMessage(icon[2].."12\124t |CFF71D5FF|Hspell:8690|h[Hearthstone]|h|r "..L.IS.." |cff00ff00"..L.ENABLED.."|r")
				else DEFAULT_CHAT_FRAME:AddMessage(icon[2].."12\124t |CFF71D5FF|Hspell:8690|h[Hearthstone]|h|r "..L.IS.." |cffff2f32"..L.DISABLED.."|r")
				end
				if db.resurrectedSettings.resurrected == true then DEFAULT_CHAT_FRAME:AddMessage(icon[6].."12\124t |CFF71D5FF|Hspell:126171|h[Resurrected]|h|r "..L.IS.." |cff00ff00"..L.ENABLED.."|r")
				else DEFAULT_CHAT_FRAME:AddMessage(icon[6].."12\124t |CFF71D5FF|Hspell:126171|h[Resurrected]|h|r "..L.IS.." |cffff2f32"..L.DISABLED.."|r")
				end
			end,
			dialogHidden = true
		},
		t = {
			name = "Toggle",
			desc = "(|cffffff00T|r)oggle SoulSpeak on/off",
			type = 'execute',
			order = 9,
			func = "ssOnOff",
			dialogHidden = true,
		},
	},
}

--[[
*******************
* Database values *
--]]
SoulSpeak.defaults = {
	profile =  {
		SoulSpeak = true,
		debug = false,
		ssLDBbutton = { hide = false },
		ssLDB_options = { false, false, false },

		hearthstoneSettings = {
			hearthstone = true, morning = true, afternoon = true, evening = true, night = true,
			random_morning = true, random_afternoon = true, random_evening = true, random_night = true,
			morning_emotes = 1, afternoon_emotes = 2, evening_emotes = 6, night_emotes = 3, frequency = 0.5,
    	icon = "\124TInterface\\Icons\\inv_misc_rune_01:1", configname = "hearthstoneSettings"
		},

		ritualSettings = {
			{ ritual = true, party = true, raid = true, chat = false, party_channel = 1, raid_channel = 2, quotesmaxscale = 19, frequency = 1,
				emote = true, delay = true, emotelist = 1, emote_channels = { true,true,false }, random = false, last_quote = "", configname = "souls_configSettings", quote_configname = "souls_quoteSettings",
					quote = { L.RSOquote1, L.RSOquote2,	L.RSOquote3, L.RSOquote4, L.RSOquote5, L.RSOquote6, L.RSOquote7, L.RSOquote8, L.RSOquote9, L.RSOquote10,
						L.RSOquote11, L.RSOquote12, L.RSOquote13, L.RSOquote14, L.RSOquote15, L.RSOquote16, L.RSOquote17, L.RSOquote18, L.RSOquote19, L.RSOquote20, L.RSOquote21 }
				},

			{ ritual = true, party = true, raid = true, chat = false, party_channel = 1, raid_channel = 2, quotesmaxscale = 32, frequency = 1, helpme = true,
				emote = true, delay = true, emotelist = 1, emote_channels = { true,true,false }, random = false, last_quote = "", configname = "summoning_configSettings", quote_configname = "summoning_quoteSettings",
					quote = { L.RSUquote1, L.RSUquote2, L.RSUquote3, L.RSUquote4, L.RSUquote5, L.RSUquote6, L.RSUquote7, L.RSUquote8, L.RSUquote9, L.RSUquote10, L.RSUquote11,
						L.RSUquote12, L.RSUquote13, L.RSUquote14, L.RSUquote15, L.RSUquote16, L.RSUquote17, L.RSUquote18, L.RSUquote19, L.RSUquote20, L.RSUquote21, L.RSUquote22,
						L.RSUquote23, L.RSUquote24, L.RSUquote25, L.RSUquote26, L.RSUquote27, L.RSUquote28, L.RSUquote29, L.RSUquote30, L.RSUquote31, L.RSUquote32, L.RSUquote33 }
				}
		},

		soulstoneSettings = {
			{ configname = "soulstoneSettings", soulstone = true, party = true, raid = true, self = false, solo = true, random = true,
				emote = true, emotelist = 1, emote_channels = { true, true, true }, party_channel = 1, raid_channel = 4, solo_channel = 3,
 		},

			{ configname = "soulstone_emoteSettings", frequency = 0.15, quotesmaxscale = 20, last_quote = "",
					quote = { L.SSEquote1, L.SSEquote2, L.SSEquote3, L.SSEquote4, L.SSEquote5, L.SSEquote6, L.SSEquote7, L.SSEquote8, L.SSEquote9, L.SSEquote10,
						L.SSEquote11, L.SSEquote12, L.SSEquote13, L.SSEquote14, L.SSEquote15, L.SSEquote16, L.SSEquote17, L.SSEquote18, L.SSEquote19, L.SSEquote20,
						L.SSEquote21 }
				},

			{ configname = "soulstone_quoteSettings", frequency = 0.15, quotesmaxscale = 39, last_quote = "",
					quote = { L.SSQquote1, L.SSQquote2, L.SSQquote3, L.SSQquote4, L.SSQquote5, L.SSQquote6, L.SSQquote7, L.SSQquote8, L.SSQquote9, L.SSQquote10,
						L.SSQquote11, L.SSQquote12, L.SSQquote13, L.SSQquote14, L.SSQquote15, L.SSQquote16, L.SSQquote17, L.SSQquote18, L.SSQquote19, L.SSQquote20,
						L.SSQquote21, L.SSQquote22, L.SSQquote23, L.SSQquote24, L.SSQquote25, L.SSQquote26, L.SSQquote27, L.SSQquote28, L.SSQquote29, L.SSQquote30,
						L.SSQquote31, L.SSQquote32, L.SSQquote33, L.SSQquote34, L.SSQquote35, L.SSQquote36, L.SSQquote37, L.SSQquote38, L.SSQquote39 }
				},

			{ configname = "soulstone_whisperSettings", frequency = 0.25, quotesmaxscale = 24, last_quote = "",
					quote = { L.SSWquote1, L.SSWquote2, L.SSWquote3, L.SSWquote4, L.SSWquote5, L.SSWquote6, L.SSWquote7, L.SSWquote8, L.SSWquote9, L.SSWquote10,
						L.SSWquote11, L.SSWquote12, L.SSWquote13, L.SSWquote14, L.SSWquote15, L.SSWquote16, L.SSWquote17, L.SSWquote18, L.SSWquote19, L.SSWquote20,
						L.SSWquote21, L.SSWquote22, L.SSWquote23, L.SSWquote24 }
				},

			{ configname = "resurrection_quoteSettings", frequency = 0.50, quotesmaxscale = 66, last_quote = "",
					quote = { L.RRQquote1, L.RRQquote2, L.RRQquote3, L.RRQquote4, L.RRQquote5, L.RRQquote6, L.RRQquote7, L.RRQquote8, L.RRQquote9, L.RRQquote10,
						L.RRQquote11, L.RRQquote12, L.RRQquote13, L.RRQquote14, L.RRQquote15, L.RRQquote16, L.RRQquote17, L.RRQquote18, L.RRQquote19, L.RRQquote20,
						L.RRQquote21, L.RRQquote22, L.RRQquote23, L.RRQquote24, L.RRQquote25, L.RRQquote26, L.RRQquote27, L.RRQquote28, L.RRQquote29, L.RRQquote30,
						L.RRQquote31, L.RRQquote32, L.RRQquote33, L.RRQquote34, L.RRQquote35, L.RRQquote36, L.RRQquote37, L.RRQquote38, L.RRQquote39, L.RRQquote40,
						L.RRQquote41, L.RRQquote42, L.RRQquote43, L.RRQquote44,	L.RRQquote45, L.RRQquote46, L.RRQquote47, L.RRQquote48, L.RRQquote49, L.RRQquote50,
						L.RRQquote51, L.RRQquote52, L.RRQquote53, L.RRQquote54, L.RRQquote55,	L.RRQquote56, L.RRQquote57, L.RRQquote58, L.RRQquote59, L.RRQquote60,
						L.RRQquote61, L.RRQquote62, L.RRQquote63, L.RRQquote64, L.RRQquote65, L.RRQquote66 }
				},

			{ configname = "resurrection_whisperSettings", frequency = 0.25, quotesmaxscale = 36, last_quote = "",
					quote = { L.RRWquote1, L.RRWquote2, L.RRWquote3, L.RRWquote4, L.RRWquote5, L.RRWquote6, L.RRWquote7, L.RRWquote8, L.RRWquote9, L.RRWquote10,
						L.RRWquote11, L.RRWquote12, L.RRWquote13, L.RRWquote14, L.RRWquote15, L.RRWquote16, L.RRWquote17, L.RRWquote18, L.RRWquote19, L.RRWquote20,
						L.RRWquote21, L.RRWquote22, L.RRWquote23, L.RRWquote24, L.RRWquote25, L.RRWquote26, L.RRWquote27, L.RRWquote28, L.RRWquote29, L.RRWquote30,
						L.RRWquote31, L.RRWquote32, L.RRWquote33,	L.RRWquote34, L.RRWquote35, L.RRWquote36 }
				}
		},

		demonSettings = {
			{ demon = L.FGRD, name = "noname", emote = true, delay = true, emotelist = 11, random = false, frequency = 0.15, quotesmaxscale = 8,
				icon = "\124TInterface\\Icons\\spell_shadow_summonfelguard:1", configname = "FGRDquoteOptions",
					quote = { L.FGRDquote1, L.FGRDquote2, L.FGRDquote3, L.FGRDquote4, L.FGRDquote5, L.FGRDquote6,
    				L.FGRDquote7, L.FGRDquote8, L.FGRDquote9, L.FGRDquote10, L.FGRDquote11, L.FGRDquote12,
    				L.FGRDquote13, L.FGRDquote14, L.FGRDquote15 }
    		},

			{ demon = L.WGRD, name = "noname", emote = true, delay = true, emotelist = 11, random = false, frequency = 0.15, quotesmaxscale = 8,
				icon = "\124TInterface\\Icons\\spell_warlock_summonwrathguard:1", configname = "WGRDquoteOptions",
					quote = { L.WGRDquote1, L.WGRDquote2, L.WGRDquote3, L.WGRDquote4, L.WGRDquote5, L.WGRDquote6,
    				L.WGRDquote7,	L.WGRDquote8, L.WGRDquote9, L.WGRDquote10, L.WGRDquote11, L.WGRDquote12,
    				L.WGRDquote13, L.WGRDquote14, L.WGRDquote15 }
    		},

			{ demon = L.FEL, name = "noname", emote = true, delay = true, emotelist = 10, random = false, frequency = 0.15, quotesmaxscale = 13,
				icon = "\124TInterface\\Icons\\Spell_Shadow_summonfelhunter:1", configname = "FELquoteOptions",
					quote = { L.FELquote1, L.FELquote2, L.FELquote3, L.FELquote4, L.FELquote5, L.FELquote6,
    				L.FELquote7, L.FELquote8, L.FELquote9, L.FELquote10, L.FELquote11, L.FELquote12,
    				L.FELquote13, L.FELquote14, L.FELquote15 }
    		},

			{ demon = L.OBS, name = "noname", emote = true, delay = true, emotelist = 10, random = false, frequency = 0.15, quotesmaxscale = 7,
				icon = "\124TInterface\\Icons\\WARLOCK_SUMMON_ BEHOLDER:1", configname = "OBSquoteOptions",
					quote = { L.OBSquote1, L.OBSquote2, L.OBSquote3, L.OBSquote4,	L.OBSquote5, L.OBSquote6,
     				L.OBSquote7, L.OBSquote8,	L.OBSquote9, L.OBSquote10, L.OBSquote11, L.OBSquote12,
    				L.OBSquote13, L.OBSquote14, L.OBSquote15 }
    		},

			{ demon = L.IMP, name = "noname", emote = true, delay = true, emotelist = 9, random = false, frequency = 0.15, quotesmaxscale = 30,
				icon = "\124TInterface\\Icons\\Spell_Shadow_summonimp:1", configname = "IMPquoteOptions",
					quote = { L.IMPquote1, L.IMPquote2, L.IMPquote3, L.IMPquote4, L.IMPquote5, L.IMPquote6,
    				L.IMPquote7, L.IMPquote8, L.IMPquote9, L.IMPquote10, L.IMPquote11, L.IMPquote12,
    				L.IMPquote13, L.IMPquote14, L.IMPquote15, L.IMPquote16, L.IMPquote17, L.IMPquote18,
    				L.IMPquote19, L.IMPquote20, L.IMPquote21, L.IMPquote22, L.IMPquote23, L.IMPquote24,
    				L.IMPquote25, L.IMPquote26, L.IMPquote27, L.IMPquote28, L.IMPquote29, L.IMPquote30 }
    		},

			{ demon = L.FIMP, name = "noname", emote = true, delay = true, emotelist = 9, random = false, frequency = 0.15, quotesmaxscale = 23,
					icon = "\124TInterface\\Icons\\spell_warlock_summonimpoutland:1", configname = "FIMPquoteOptions",
					quote = { L.FIMPquote1, L.FIMPquote2, L.FIMPquote3, L.FIMPquote4, L.FIMPquote5, L.FIMPquote6,
						L.FIMPquote7, L.FIMPquote8, L.FIMPquote9, L.FIMPquote10, L.FIMPquote11, L.FIMPquote12,
						L.FIMPquote13, L.FIMPquote14, L.FIMPquote15, L.FIMPquote16, L.FIMPquote17, L.FIMPquote18,
						L.FIMPquote19, L.FIMPquote20,	L.FIMPquote21, L.FIMPquote22,	L.FIMPquote23, L.FIMPquote24 }
				},

			{ demon = L.SUC, name = "noname", emote = true, delay = true, emotelist = 12, random = false, frequency = 0.15, quotesmaxscale = 14,
				icon = "\124TInterface\\Icons\\Spell_Shadow_summonsuccubus:1", configname = "SUCquoteOptions",
					quote = { L.SUCquote1, L.SUCquote2, L.SUCquote3, L.SUCquote4, L.SUCquote5, L.SUCquote6,
    				L.SUCquote7, L.SUCquote8, L.SUCquote9, L.SUCquote10, L.SUCquote11, L.SUCquote12,
    				L.SUCquote13, L.SUCquote14, L.SUCquote15 }
    		},

			{ demon = L.SHI, name = "noname", emote = true, delay = true, emotelist = 12, random = false, frequency = 0.15, quotesmaxscale = 14,
				icon = "\124TInterface\\Icons\\WARLOCK_SUMMON_ SHIVAN:1", configname = "SHIquoteOptions",
					quote = { L.SHIquote1, L.SHIquote2,	L.SHIquote3, L.SHIquote4,	L.SHIquote5, L.SHIquote6,
    				L.SHIquote7, L.SHIquote8,	L.SHIquote9, L.SHIquote10, L.SHIquote11, L.SHIquote12,
    				L.SHIquote13, L.SHIquote14,	L.SHIquote15 }
    		},

			{ demon = L.VOID, name = "noname", emote = true, delay = true, emotelist = 2, random = false, frequency = 0.15, quotesmaxscale = 17,
				icon = "\124TInterface\\Icons\\Spell_Shadow_summonvoidwalker:1", configname = "VOIDquoteOptions",
					quote = { L.VOIDquote1, L.VOIDquote2, L.VOIDquote3, L.VOIDquote4, L.VOIDquote5, L.VOIDquote6,
    				L.VOIDquote7, L.VOIDquote8, L.VOIDquote9, L.VOIDquote10, L.VOIDquote11, L.VOIDquote12,
    				L.VOIDquote13, L.VOIDquote14, L.VOIDquote15, L.VOIDquote16, L.VOIDquote17, L.VOIDquote18 }
    		},

			{ demon = L.VOID, name = "noname", emote = false, delay = false, emotelist = 0, random = false, frequency = 0, quotesmaxscale = 0,
				icon = "\124TInterface\\Icons\\Spell_Shadow_summonvoidwalker:1", configname = "", quote = {}
				},

			{ demon = L.VOIDL, name = "noname", emote = true, delay = true, emotelist = 3, random = false, frequency = 0.15, quotesmaxscale = 10,
				icon = "\124TInterface\\Icons\\WARLOCK_SUMMON_ VOIDLORD:1", configname = "VOIDLquoteOptions",
					quote = { L.VOIDLquote1, L.VOIDLquote2,	L.VOIDLquote3, L.VOIDLquote4,	L.VOIDLquote5, L.VOIDLquote6,
    				L.VOIDLquote7, L.VOIDLquote8,	L.VOIDLquote9, L.VOIDLquote10, L.VOIDLquote11, L.VOIDLquote12,
    				L.VOIDLquote13,	L.VOIDLquote14,	L.VOIDLquote15 }
    		},

			{ demon = L.DGRD, name = "noname", emote = true, delay = true, emotelist = 11, random = false, frequency = 0.15, quotesmaxscale = 8,
				icon = "\124TInterface\\Icons\\warlock_summon_doomguard:1", configname = "DGRDquoteOptions",
					quote = { L.DGRDquote1, L.DGRDquote2, L.DGRDquote3, L.DGRDquote4, L.DGRDquote5, L.DGRDquote6,
    				L.DGRDquote7, L.DGRDquote8, L.DGRDquote9, L.DGRDquote10, L.DGRDquote11, L.DGRDquote12,
    				L.DGRDquote13, L.DGRDquote14, L.DGRDquote15 }
    		},

			{ demon = L.TGRD, name = "noname", emote = true, delay = true, emotelist = 11, random = false, frequency = 0.15, quotesmaxscale = 8,
				icon = "\124TInterface\\Icons\\spell_warlock_summonterrorguard:1", configname = "TGRDquoteOptions",
					quote = { L.TGRDquote1, L.TGRDquote2, L.TGRDquote3, L.TGRDquote4, L.TGRDquote5, L.TGRDquote6,
    				L.TGRDquote7, L.TGRDquote8, L.TGRDquote9, L.TGRDquote10, L.TGRDquote11, L.TGRDquote12,
    				L.TGRDquote13, L.TGRDquote14, L.TGRDquote15 }
    		},

			{ demon = L.INF, name = "noname", emote = true, delay = true, emotelist = 6, random = false, frequency = 0.15, quotesmaxscale = 8,
				icon = "\124TInterface\\Icons\\spell_shadow_summoninfernal:1", configname = "INFquoteOptions",
					quote = { L.INFquote1, L.INFquote2, L.INFquote3, L.INFquote4, L.INFquote5, L.INFquote6,
    				L.INFquote7, L.INFquote8, L.INFquote9, L.INFquote10, L.INFquote11, L.INFquote12,
    				L.INFquote13, L.INFquote14, L.INFquote15 }
    		},

			{ demon = L.ABY, name = "noname", emote = true, delay = true, emotelist = 6, random = false, frequency = 0.15, quotesmaxscale = 7,
				icon = "\124TInterface\\Icons\\achievement_boss_lordanthricyst:1", configname = "ABYquoteOptions",
					quote = { L.ABYquote1, L.ABYquote2, L.ABYquote3, L.ABYquote4, L.ABYquote5, L.ABYquote6,
    				L.ABYquote7, L.ABYquote8, L.ABYquote9, L.ABYquote10, L.ABYquote11, L.ABYquote12,
    				L.ABYquote13, L.ABYquote14, L.ABYquote15 }
    		},
    		
    	{	summon = true, combat = true, party = true, raid = true, solo = true, combat_channels = { false,false,true }, party_channel = 2, raid_channel = 3, solo_channel = 2, configname = "demonSettings" }
		},

		lastSUMicon = "\124TInterface\\Icons\\Spell_Shadow_summonimp:1",
		lastSMquote = {},

		resurrectedSettings = { resurrected = true, party = true, raid = true, solo = true, player = "", frequency = 1,
			random_party = true, random_raid = true, random_solo = true, party_emotes = 1, raid_emotes = 1, solo_emotes = 1, configname = "resurrectedSettings"	},
  },
}

--[[
***********************
* function txtReplace *
--]]
function SoulSpeak.txtReplace(txt)
	local playerClass, englishClass = UnitClass("player")
	txt = txt:gsub(L.PLAYER, UnitName("player"))
	if DemonName ~= "noname" then
		txt = txt:gsub(L.PET, DemonName)
	else
		txt = txt:gsub(L.PET, "...")
	end
	if ss_target == "" or ss_target == UnitName("player") then
		local genderTable = { L.IT, L.HE, L.SHE }
		local gender = string.match(txt, genderTable[UnitSex("player")])
		if gender ~= nil then
			txt = txt:gsub(L.HESHE, gender)
			gender = nil
		end
		genderTable = { L.ITS, L.HIM, L.HER }	
		gender = string.match(txt, genderTable[UnitSex("player")])
		if gender ~= nil then
			txt = txt:gsub(L.HIMHER, gender)
			gender = nil
		end
		genderTable = { L.ITS, L.HIS, L.HER }	
		gender = string.match(txt, genderTable[UnitSex("player")])
		if gender ~= nil then
			txt = txt:gsub(L.HISHER, gender)
			gender = nil
		end
		genderTable = { L.ITS, L.HIS, L.HERS }	
		gender = string.match(txt, genderTable[UnitSex("player")])
		if gender ~= nil then
			txt = txt:gsub(L.HISHERS, gender)
			gender = nil
		end		
		if UnitName("target") ~= nil then
			local targetClass, englishClass = UnitClass("target")	
			txt = txt:gsub(L.TARGET, (UnitName("target")))
			txt = txt:gsub(L.TARGETCLASS, targetClass)
		else
			txt = txt:gsub(L.TARGET, L.NOTARGET)
			txt = txt:gsub(L.TARGETCLASS, L.NOTARGET)
		end
	elseif ss_target ~= "" then
		txt = txt:gsub(L.TARGET, (ss_target))
		txt = txt:gsub(L.TARGETCLASS, targetClass)		
		local gender = string.match(txt, SSgenderTable1)
		if gender ~= nil then
			txt = txt:gsub(L.HESHE, gender)
			gender = nil
		end
		gender = string.match(txt, SSgenderTable2)
		if gender ~= nil then
			txt = txt:gsub(L.HIMHER, gender)
			gender = nil
		end
		gender = string.match(txt, SSgenderTable3)
		if gender ~= nil then
			txt = txt:gsub(L.HISHER, gender)
			gender = nil
		end
		gender = string.match(txt, SSgenderTable4)
		if gender ~= nil then
			txt = txt:gsub(L.HISHERS, gender)
			gender = nil
		end
	end
	return txt
end

--[[
************************
* function OpenOptions *
--]]
function SoulSpeak.OpenOptions()
--	PlaySound("igSpellBookOpen")
	-- Fix for Blizzard addon panel (http://www.wowace.com/paste/8364)
	-- Bail out if already loaded and up to date
	local MAJOR, MINOR = "InterfaceOptionsFix", 1
--	if _G[MAJOR] and _G[MAJOR].version >= MINOR then return end
	-- Reuse the existing frame or create a new one
	local frame = _G[MAJOR] or CreateFrame("Frame", MAJOR, _G.InterfaceOptionsFrame)
	frame.version = MINOR
	-- Hook once and the call the possibly upgraded methods
	if not frame.Saved_InterfaceOptionsFrame_OpenToCategory then
  	-- Save the unhooked function
    frame.Saved_InterfaceOptionsFrame_OpenToCategory = _G.InterfaceOptionsFrame_OpenToCategory
    hooksecurefunc("InterfaceOptionsFrame_OpenToCategory", function(...)
    	return frame:InterfaceOptionsFrame_OpenToCategory(...)
    end)
    -- Please note that the frame is a child of InterfaceOptionsFrame, so OnUpdate won't called before InterfaceOptionsFrame is shown
    frame:SetScript('OnUpdate', function(_, ...)
        return frame:OnUpdate(...)
    end)
	end
	-- This will be called twice on first open : 
	-- 1) with the panel which is actually wanted,
	-- 2) with the "Control" panel from InterfaceOptionsFrame_OnShow (this is what actually cause the bug). 
	function frame:InterfaceOptionsFrame_OpenToCategory(panel)
  	self.panel = panel
	end
	function frame:OnUpdate()
    local panel = self.panel   
    -- Clean up
    self:SetScript('OnUpdate', nil)
    self:Hide()
    self.panel = nil
    self.InterfaceOptionsFrame_OpenToCategory = function() end
    -- Call the original InterfaceOptionsFrame_OpenToCategory with the last panel
    self.Saved_InterfaceOptionsFrame_OpenToCategory(panel)
	end
	-- EoF
	InterfaceOptionsFrame_OpenToCategory(SoulSpeak.optionsFrame)
end

--[[
****************************
* function color frequency *
--]]
function SoulSpeak.color_frequency(f, ...)
	if f == 1 then c = "|cff00ff00"
		elseif f >= 0.75 and f < 1 then c = "|cff7fff7f"
		elseif f >= 0.50 and f < 0.75 then c = "|cffffff00"
		elseif f >= 0.25 and f < 0.50 then c = "|cffffff78"
		elseif f >= 0.01 and f < 0.25 then c = "|cffff6b00"
	end
	return c
end

--[[
********************
* function ssOnOff *
--]]
function SoulSpeak.ssOnOff()
	if db.SoulSpeak == false then
		db.ritualSettings[1].ritual, db.ritualSettings[2].ritual, db.soulstoneSettings[1].soulstone,
		db.demonSettings[16].summon, db.hearthstoneSettings.hearthstone, db.resurrectedSettings.resurrected, db.SoulSpeak = true, true, true, true, true, true, true
		SoulSpeakBlock.text = "|cff00ff00SoulSpeak"
		DEFAULT_CHAT_FRAME:AddMessage(icon[5].."12\124t |cffffffff<|cffB0A0ffSoulSpeak|cffffffff>|r "..L.IS.." |cff00ff00"..L.ENABLED.."|r")
	else
		db.ritualSettings[1].ritual, db.ritualSettings[2].ritual, db.soulstoneSettings[1].soulstone,
		db.demonSettings[16].summon, db.hearthstoneSettings.hearthstone, db.resurrectedSettings.resurrected, db.SoulSpeak = false, false, false, false, false, false, false
		SoulSpeakBlock.text = "|cffff2f32SoulSpeak|r"
		DEFAULT_CHAT_FRAME:AddMessage(icon[5].."12\124t |cffffffff<|cffB0A0ffSoulSpeak|cffffffff>|r "..L.IS.." |cffff2f32"..L.DISABLED.."|r")
	end
end

--[[
********************
* function GetName *
--]]
function SoulSpeak.GetName(info)
	local n = info[#info]
	return (n)
end

--[[
*********************
* function getSSopt *
--]]
function SoulSpeak:getSSopt(info, ...)
	local i

	--[[
	**************************
	* soulstone resurrection *
	--]]
	for i = 1,6 do
		if db.soulstoneSettings[i].configname == info[#info-1] then
			return db.soulstoneSettings[i][info[#info]]
		elseif db.soulstoneSettings[i].configname == info[#info-2] then
			return db.soulstoneSettings[i].quote[tonumber(string.match(info[#info], "%d%d"))]
		end
	end

	--[[
	*****************************
	* hearthstone & resurrected *
	--]]
	if info[#info-1] == "hearthstoneSettings"  then		
		return db.hearthstoneSettings[info[#info]]
	elseif info[#info-1] == "resurrectedSettings"  then
		return db.resurrectedSettings[info[#info]]
	end

	--[[
	*****************************
	* ritual of souls/summoning *
	--]]
	for i = 2,2 do
		if db.ritualSettings[i].configname == info[#info-1] then
			return db.ritualSettings[i][info[#info]]
		elseif db.ritualSettings[i].quote_configname == info[#info-1] and info[#info] == "quotesmaxscale" then
			return db.ritualSettings[i].quotesmaxscale
		elseif db.ritualSettings[i].quote_configname == info[#info-2] then
			return db.ritualSettings[i].quote[tonumber(string.match(info[#info], "%d%d"))]
		end
	end

	--[[
	****************
	* summon demon *
	--]]
	for i = 1,16 do
		if i == 16 and db.demonSettings[16].configname == info[#info-1] then
			return db.demonSettings[i][info[#info]]
		elseif db.demonSettings[i].configname == info[#info-1] then
			return db.demonSettings[i][info[#info]]
		elseif db.demonSettings[i].configname == info[#info-2] then
			return db.demonSettings[i].quote[tonumber(string.match(info[#info], "%d%d"))]
		end
	end
	return db[info[#info]]
end

--[[
*********************
* function setSSopt *
--]]
function SoulSpeak:setSSopt(info, newValue)
	local i
	--[[
	*****************************
	* hearthstone & resurrected *
	--]]
	if db.hearthstoneSettings.configname == info[#info-1] then		
		local n = 0
		local event = { db.hearthstoneSettings.morning, db.hearthstoneSettings.afternoon, db.hearthstoneSettings.evening, db.hearthstoneSettings.night }
		for i = 1,4 do
			if event[i] == false then n = n + 1 end
		end
		if n == 3 then
			db.hearthstoneSettings[info[#info]] = true
		else
			db.hearthstoneSettings[info[#info]] = newValue
		end
	elseif db.resurrectedSettings.configname == info[#info-1] then
		local n = 0
		local event = { db.resurrectedSettings.party, db.resurrectedSettings.raid, db.resurrectedSettings.solo }
		for i = 1,3 do
			if event[i] == false then n = n + 1 end
		end
		if n == 2 then
			db.resurrectedSettings[info[#info]] = true
		else
			db.resurrectedSettings[info[#info]] = newValue
		end
	end
	--[[
	*****************************
	* ritual of souls/summoning *
	--]]
	for i = 2,2 do
		if db.ritualSettings[i].configname == info[#info-1] then
			db.ritualSettings[i][info[#info]] = newValue
			local x
			local y = 0
			local event = { db.ritualSettings[i].party, db.ritualSettings[i].raid, db.ritualSettings[i].chat }
			for x = 1,3 do
				if event[x] == false then y = y + 1 end
			end
			if y == 3 then
				db.ritualSettings[i][info[#info]] = true
			else
				db.ritualSettings[i][info[#info]] = newValue
			end
		elseif db.ritualSettings[i].quote_configname == info[#info-1] and info[#info] == "quotesmaxscale" then
			db.ritualSettings[i].quotesmaxscale = newValue
		elseif db.ritualSettings[i].quote_configname == info[#info-2] then
			db.ritualSettings[i].quote[tonumber(string.match(info[#info], "%d%d"))] = newValue
		end		
	end
	--[[
	****************
	* summon demon *
	--]]
	for i = 1,16 do
		if i == 16 then
			local x
			local y = 0
			local event = { db.demonSettings[16].party, db.demonSettings[16].raid, db.demonSettings[16].solo }
			for x = 1,3 do
				if event[x] == false then y = y + 1 end
			end
			if y == 2 then
				db.demonSettings[i][info[#info]] = true
			else
				db.demonSettings[i][info[#info]] = newValue
			end
		elseif db.demonSettings[i].configname == info[#info-1] then
			db.demonSettings[i][info[#info]] = newValue
		elseif db.demonSettings[i].configname == info[#info-2] then
			db.demonSettings[i].quote[tonumber(string.match(info[#info], "%d%d"))] = newValue
		end
	end
	--[[
	**************************
	* soulstone resurrection *
	--]]
	for i = 1,6 do
		if db.soulstoneSettings[i].configname == info[#info-1] then
			db.soulstoneSettings[i][info[#info]] = newValue
			local e
			local ec = { "party", "raid", "solo" }
			for e = 1,3 do
				if info[#info] == ec[e] then
					db.soulstoneSettings[i].emote_channels[e] = newValue
				end
			end
		elseif db.soulstoneSettings[i].configname == info[#info-1] and info[#info] == "quotesmaxscale" then
			db.soulstoneSettings[i].quotesmaxscale = newValue
		elseif db.soulstoneSettings[i].configname == info[#info-2] then
			db.soulstoneSettings[i].quote[tonumber(string.match(info[#info], "%d%d"))] = newValue
		end		
	end
end

--[[
*********************
* function disSSopt *
--]]
function SoulSpeak:disSSopt(info, ...)
	local i
	--[[
	****************
	* summon demon *
	--]]
	for i = 1,16 do
		if i == 16 and info[#info-1] == db.demonSettings[i].configname then
			if info[#info] == "summon" then
				return (db.SoulSpeak == false)
			elseif info[#info] == "party_channel" then
				return (db.demonSettings[i].summon == false or db.demonSettings[i].party == false)
			elseif info[#info] == "raid_channel" then
				return (db.demonSettings[i].summon == false or db.demonSettings[i].raid == false)
			elseif info[#info] == "solo_channel" then
				return (db.demonSettings[i].summon == false or db.demonSettings[i].solo == false)
			elseif info[#info] == "combat_channels" then
				return (db.demonSettings[i].summon == false or db.demonSettings[i].combat == false)
			else
				return (db.demonSettings[i].summon == false)
			end
		elseif info[#info-2] == db.demonSettings[i].configname then
			return (db.demonSettings[16].summon == false or (db.demonSettings[i].frequency == 0) or (db.demonSettings[i].quotesmaxscale < tonumber(string.match(info[#info], "%d%d")) ))
		elseif info[#info-1] == db.demonSettings[i].configname and info[#info] == "frequency" then
			return (db.demonSettings[16].summon == false)
		elseif info[#info-1] == db.demonSettings[i].configname and info[#info] == "quotesmaxscale" then
			return (db.demonSettings[16].summon == false or db.demonSettings[i].frequency == 0)
		elseif info[#info-1] == db.demonSettings[i].configname and info[#info] == "emote" then
			return (db.demonSettings[16].summon == false or db.demonSettings[i].frequency == 0)
		elseif info[#info-1] == db.demonSettings[i].configname and info[#info] == "random" then
			return (db.demonSettings[16].summon == false or db.demonSettings[i].frequency == 0 or db.demonSettings[i].emote == false)
		elseif info[#info-1] == db.demonSettings[i].configname and info[#info] == "delay" then
			return (db.demonSettings[16].summon == false or db.demonSettings[i].frequency == 0 or db.demonSettings[i].emote == false)
		elseif info[#info-1] == db.demonSettings[i].configname and info[#info] == "emotelist" then
			return (db.demonSettings[16].summon == false or db.demonSettings[i].frequency == 0 or db.demonSettings[i].emote == false or db.demonSettings[i].random == true)
		end
	end
	--[[
	**************************
	* soulstone resurrection *
	--]]
	if db.soulstoneSettings[1].configname == info[#info-1] then
		if info[#info] == "soulstone" then
			return (db.SoulSpeak == false)
		elseif info[#info] == "party_channel" then
			return (db.soulstoneSettings[1].soulstone == false or db.soulstoneSettings[1].party == false)
		elseif info[#info] == "raid_channel" then
			return (db.soulstoneSettings[1].soulstone == false or db.soulstoneSettings[1].raid == false)
		elseif info[#info] == "solo_channel" then
			return (db.soulstoneSettings[1].soulstone == false or db.soulstoneSettings[1].solo == false)
		elseif info[#info] == "random" or info[#info] == "delay" then
			return (db.soulstoneSettings[1].soulstone == false or db.soulstoneSettings[1].emote == false)
		elseif info[#info] == "emotelist" then
			return (db.soulstoneSettings[1].soulstone == false or db.soulstoneSettings[1].random == true or db.soulstoneSettings[1].emote == false)
		elseif info[#info] == "emote_channels" then
			return (db.soulstoneSettings[1].soulstone == false or db.soulstoneSettings[1].emote == false)
		else
			return (db.soulstoneSettings[1].soulstone == false)
		end
	end			
	for i = 2,6 do
		if info[#info-1] == db.soulstoneSettings[i].configname and info[#info] == "frequency" then
			return (db.soulstoneSettings[1].soulstone == false)
		elseif info[#info-1] == db.soulstoneSettings[i].configname and info[#info] == "quotesmaxscale" then
			return (db.soulstoneSettings[1].soulstone == false or db.soulstoneSettings[i].frequency == 0)
		elseif db.soulstoneSettings[i].configname == info[#info-2] then
				return (db.soulstoneSettings[1].soulstone == false or db.soulstoneSettings[i].frequency == 0 or db.soulstoneSettings[i].quotesmaxscale < tonumber(string.match(info[#info], "%d%d")))
		end
	end
	--[[
	*****************************
	* ritual of souls/summoning *
	--]]
	for i = 2,2 do
		if db.ritualSettings[i].configname == info[#info-1] then
			if info[#info] == "ritual" then
				return (db.SoulSpeak == false)
			elseif info[#info] == "party_channel" then
				return (db.ritualSettings[i].ritual == false or db.ritualSettings[i].party == false)
			elseif info[#info] == "raid_channel" then
				return (db.ritualSettings[i].ritual == false or db.ritualSettings[i].raid == false)
			elseif info[#info] == "random" or info[#info] == "delay" then
				return (db.ritualSettings[i].ritual == false or db.ritualSettings[i].emote == false)
			elseif info[#info] == "emotelist" then
				return (db.ritualSettings[i].ritual == false or db.ritualSettings[i].random == true or db.ritualSettings[i].emote == false)
			elseif info[#info] == "emote_channels" then
				return (db.ritualSettings[i].ritual == false or db.ritualSettings[i].emote == false)
			else
				return (db.ritualSettings[i].ritual == false)
			end
		end
		if db.ritualSettings[i].quote_configname == info[#info-1] and info[#info] == "quotesmaxscale" then
			return (db.ritualSettings[i].ritual == false)
		elseif db.ritualSettings[i].quote_configname == info[#info-2] then
			return (db.ritualSettings[i].ritual == false or db.ritualSettings[i].quotesmaxscale < tonumber(string.match(info[#info], "%d%d")))
		end
	end
	--[[
	***************
	* hearthstone *
	--]]
	if info[#info-1] == "hearthstoneSettings"  then
		if info[#info] == "hearthstone" then
			return (db.SoulSpeak == false)
		elseif info[#info] == "frequency" or info[#info] == "morning" or info[#info] == "afternoon" or info[#info] == "evening" or info[#info] == "night" then
			return (db.hearthstoneSettings.hearthstone == false)
		elseif info[#info] == "random_morning" then
			return (db.hearthstoneSettings.hearthstone == false or db.hearthstoneSettings.morning == false)
		elseif info[#info] == "morning_emotes" then
			return (db.hearthstoneSettings.hearthstone == false or db.hearthstoneSettings.morning == false or db.hearthstoneSettings.random_morning)
		elseif info[#info] == "random_afternoon" then
			return (db.hearthstoneSettings.hearthstone == false or db.hearthstoneSettings.afternoon == false)
		elseif info[#info] == "afternoon_emotes" then
			return (db.hearthstoneSettings.hearthstone == false or db.hearthstoneSettings.afternoon == false or db.hearthstoneSettings.random_afternoon)
		elseif info[#info] == "random_evening" then
			return (db.hearthstoneSettings.hearthstone == false or db.hearthstoneSettings.evening == false)
		elseif info[#info] == "evening_emotes" then
			return (db.hearthstoneSettings.hearthstone == false or db.hearthstoneSettings.evening == false or db.hearthstoneSettings.random_evening)
		elseif info[#info] == "random_night" then
			return (db.hearthstoneSettings.hearthstone == false or db.hearthstoneSettings.night == false)
		elseif info[#info] == "night_emotes" then
			return (db.hearthstoneSettings.hearthstone == false or db.hearthstoneSettings.night == false or db.hearthstoneSettings.random_night)
		end
	--[[
	***************
	* resurrected *
	--]]
	elseif info[#info-1] == "resurrectedSettings" then
		if info[#info] == "resurrected" then
			return (db.SoulSpeak == false)
		elseif info[#info] == "frequency" then
			return (db.resurrectedSettings.resurrected == false)
		elseif info[#info] == "party_emotes" then
			return (db.resurrectedSettings.resurrected == false or db.resurrectedSettings.party == false or db.resurrectedSettings.random_party == true)
		elseif info[#info] == "raid_emotes" then
			return (db.resurrectedSettings.resurrected == false or db.resurrectedSettings.raid == false or db.resurrectedSettings.random_raid == true)
		elseif info[#info] == "solo_emotes" then
			return (db.resurrectedSettings.resurrected == false or db.resurrectedSettings.solo == false or db.resurrectedSettings.random_solo == true)
		elseif info[#info] == "random_party" then
			return (db.resurrectedSettings.resurrected == false or db.resurrectedSettings.party == false)
		elseif info[#info] == "random_raid" then
			return (db.resurrectedSettings.resurrected == false or db.resurrectedSettings.raid == false)
		elseif info[#info] == "random_solo" then
			return (db.resurrectedSettings.resurrected == false or db.resurrectedSettings.solo == false)
		end
	end
end