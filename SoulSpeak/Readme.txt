SoulSpeak is a small Ace3/LDB automatic chat/emote addon.
For time being warlocks only!

Current features;

Does a;
..fixed or random pre-emote & quote on Ritual of Summoning.
..fixed or random pre-emote & quote incl. whisper to target for Soulstone Resurrection.
..fixed or random pre-emote & quote when summoning the warlock demon pets.

Events is split in party/raid/solo with almost 200 editable quotes:)

Support <player>,<pet>,<target>,<targetclass>,<he/she>,<him/her>,<his/her>,<his/hers>
Gender tags is NOT case sensitive, see what you type:)

Does a fixed or random emote when using the infamous Hearthstone:P
Events is split in morning, afternoon, evening and night.

And since we all are polite warlocks:P
Does a fixed or random emote to the person rez'ing you:)

How frequent SoulSpeak announces can be set in options.
Use hotkeys on minimap/LDB-panel, type /ss or bind a key for options.

Builtin support for multiple localizations, need translators!

French translation is complete. Thanks to cheremy16, encyclo06 & Kiala!
German translation is complete. Thanks to Royomunu!

Russian translation is complete. Thanks to Anisimml & Worondo!

If you got any cool quotes PM @ www.wowinterface.com/forums/member.php?u=88411

This is my first addon and previously I had no experience with LUA-scripting.
SoulSpeak came to life by using countless hours learning how others did it.
Thanks to all of you and thanks to the community!:)

Lilih @ Zandalar Tribe (EU)
Lilih @ Defias Brotherhood (EU)

Changelog;
Version 8.04-classic
- Increased demon summoning pre-emote <> quote delay from 2 to 5 sec
Version 8.03-classic
- Ritual of Summoning should now work as intended
- Fixed Soulstone Resurrection emote firing on player
- Removed nonworking emotes from retail
Version 8.02-classic
- Default demon quote frequencies now in sync with retail
Version 8.01-classic
- Updated command arguments for classic
- More code cleanup from retail
Version 8.00-classic
- Converted retail to classic
- Fixed several SpellID verifications
- Soulstone Resurrection should now fire correctly on player
- Increased default demon quote frequencies from 15% to 25%
- Updated all Ace3.0 libraries
- Updated TOC for patch 1.13.2
Version 7.02
- Verified detection of various demon names (ticket ID#9)
- Ritual of Souls/Summoning should now trigger correctly (ticket ID#8)
- Ritual of Souls/Summoning quotes should now be editable (ticket ID#7)
- Fixed opening of SoulSpeak settings
- Updated all Ace3.0 libraries
- Updated TOC for patch 7.3
Version 7.01
- Added check for Dalaran Hearthstone
Version 7.0
- Updated TOC for Legion
- Updated AceConfig-3.0 & AceGUI-3.0
Version 6.22
- Updated French localization file
Version 6.21
- Fixed Russian locale fault. (ticket ID#6)
Version 6.2
- Updated AceGUI-3.0 library
- Updated TOC for patch 6.2
Version 6.1
- Complete code optimization (-all- settings reset!)
- Minimap/LDB hints & title can now be hidden
- Increased Resurrection quote frequency from 15% to 50%
- Demon quotes in solo combat is now default turned on
- Localization files saved in UTF8 format
- Layout enhancements
Version 6.03
- Fixed emote bug in function ritual_quote
Version 6.02
- Minimap button no longer hide/show on '/ss a'
- Resurrected emote should now trigger on solo
Version 6.01
- Fixed typo in readme.txt
- Fixed bug in function ritual_quote (ticket ID#5)
- Fixed bug in function ritual_quote if delay is on
- Fixed bug if pre-emote is off then 2 sec delay is off
- Updated French localization file
Version 6.0
- Updated TOC for Warlords of Draenor
- Updated all Ace3.0 libraries
- Updated localization files
- Soulstone emote is now default turned off
- Support for pre-emote incl. 2 sec delay emote <> quote
- Added check for Abyssal, Infernal, Doomguard and Terrorguard
- Added check for Garrison Hearthstone
- Added 16 Resurrection pre-emotes
- Added 12 demon summoning pre-emotes
- Added 14 Ritual of Souls/Summoning pre-emotes
- Added arguments to slash command /ss and /soulspeak
- Added minimap button for players without LDB-panel
- Various layout enhancements
- Bug fixes & code optimization
Version 5.7
- Hearthstone & Resurrected random emote can now be set independently
- Increased Resurrection quotes from 54 to 66
- Increased Resurrection whispers from 33 to 36
- Corrections on Resurrection quote #1, #7
- Corrections on Soulstone emote #4, #10, #16 & quote #10
- Updated localization files
Version 5.61
- Observer quotes is now disabled if turned off
Version 5.6
- Increased Fel/Imp quotes from 22 to 23
- Increased Shivarra/Succubus quotes from 13 to 14
- Increased Resurrection quotes from 51 to 54
- Increased Resurrection whispers from 30 to 33
- Increased Resurrected emotes from 12 to 14
- Increased all 10% frequencies to 15%
- Minor layout enhancements in GUI options screen
- Demon quote frequency on LDB-panel no longer output decimals
Version 5.55
- Increased Fel/Imp quotes from 21 to 22
- Increased Fel/Wrathguard quotes from 7 to 8
- Increased Shivarra/Succubus quotes from 12 to 13
- Increased Soulstone emotes from 18 to 20
- Increased Soulstone Resurrection quotes from 48 to 51
- Increased Voidlord quotes from 9 to 10
- Increased Voidwalker quotes from 12 to 13
- Fixed Voidwalker quote #12 in German/French localization files
Version 5.5
- French clients now use english gender tags
- Added Russian translation (need testing). Thanks to Worondo!
- Increased Soulstone Resurrection quotes from 36 to 48
- Increased Soulstone Resurrection whispers from 15 to 30
- Increased Voidwalker quotes from 11 to 12
- Fixed tag error in Fel/Imp quote #21
- Fixed tag error in Soulstone Resurrection quote #4
- Updated LibAboutPanel library
Version 5.48
- Increased Soulstone Resurrection quotes from 33 to 36
- Increased Soulstone Resurrection whispers from 9 to 15
- Fixed several tag errors in German/French localization files
- Optimized LDB-panel making it less cluttered
- Optimized toggle settings in GUI options screen
- Demon quotes turned off no longer make other options disabled
- Changelog for current release is now included in 'About' screen
Version 5.47
- Redesigned LDB-panel incl. readd of version number
- Reorganized GUI options screen
- Fixed doubleclick sound in GUI options screen
- Quotes in party/raid turned off should now work as expected
- Demon quotes in combat is now default turned off
- Reduced demon quote frequency from 20% to 10%
- Reduced Soulstone emote frequency from 20% to 10%
- Reduced Soulstone quote frequency from 25% to 10%
- Reduced Soulstone Resurrection quote frequency from 25% to 10%
- Reduced Soulstone Resurrection whisper frequency from 50% to 25%
- Updated localization files
Version 5.42
- Support for Soulstone Resurrection of dead players:)
- SoulSpeak now contains 230 unique messages!
- Added 33 Soulstone Resurrection quotes
- Added 9 Soulstone Resurrection whispers
- Increased Imp quotes from 18 to 21
- Increased Soulstone quotes from 30 to 39
- Increased Soulstone whispers from 18 to 24
- Minor correction on Soulstone emote #7
- Soulstone quote/whisper tabs can now be turned off independently
- Reduced default Soulstone emote frequency from 25% to 20%
- Reduced default Soulstone whisper frequency from 75% to 25%
- Hearthstone and Resurrected emote is now default random
- Fixed Soulstone emote status view in LDB-panel
- Hotkeys and chat commands should now work as expected
- Updated French and German localization files
- Updated ingame contact info (new realm)
Version 5.41
- Updated AceGUI-3.0 library
Version 5.4
- Updated AceDB-3.0 & AceGUI-3.0 libraries
- Updated TOC for patch 5.4
Version 5.3
- All demon quotes is now on separate tabs
- Increased Soulstone emotes from 16 to 18
- Increased Observer quotes from 6 to 7
- Added <pet> to Observer quote #2, #4
- Updated French localization file
- Updated AceAddon-3.0 & LibAboutPanel libraries
- Updated TOC for patch 5.3
Version 5.2
- Felhunter/Observer quotes is now on separate tabs
- All party/raid quotes will now go to instance channel if active
- Minor layout enhancements in GUI options screen/LDB-panel
- Added missing icons in GUI options screen/LDB-panel
- Updated CallbackHandler-1.0/LibAboutPanel/LibStub libraries
- Updated AceDBOptions-3.0 & AceGUI-3.0 libraries
- Updated French and German localization files
- Updated TOC for patch 5.2
Version 5.1
- Hearthstone emote is now trigged by The Innkeeper's Daughter spell
- Removed 'Helpme' emote for Ritual of Souls
- Replaced Ritual of Souls quote #1 with #20 as #1 was outdated
- Changed Ritual of Souls quote #4, #5, #6, #7, #9, #11, #17, #19
- Fixed default Voidwalker quotes from 10 to 11
- Minor icon tweaks in LDB-panel
- Added German translation (need testing). Thanks to Royomunu!
- Updated TOC for patch 5.1
Version 5.0
- Updated TOC for Mists of Pandaria
- Updated all Ace3.0 libraries
- Added checks for Wrathguard, Observer, Fel Imp, Shivarra and Voidlord
- Fixed event variables for Pandaria API
- Fixed spellID variables for Pandaria API
- Fixed default Felguard quote #7
- Minor layout enhancements in GUI options screen
Version 4.1
- Demon quotes in combat can now be set independently for party/raid/solo
- Event will no longer trigger if Ritual of Souls/Summoning is on cooldown
- Added /soulspeak command for addons interfering with /ss
- Fixed bug in local function using AceConfigDialog (ticket ID#2)
- Minor colorization tweaks in LDB-panel
- Updated localization files
- Updated TOC for patch 4.3
- Updated AceDB-3.0 & AceGUI-3.0 libraries
Version 4.0
- Demon quotes can now be turned off while in combat
- GUI options screen is now part of Blizzard addons menu
- Complete redesign of GUI options screen incl. use of tabs
- Updated LDB-panel with new combat mode
- Restart GFX engine and Reload UI can now be binded to a key
- Fixed key binding compatibility with other addons
- Replaced Imp quote #17 with #18 as #17 was #3
- New quote active on Felguard quote #7
- New quote active on Imp quote #18
- New quote active on Voidwalker quote #11
- Increased Soulstone quotes from 24 to 30
- Increased Soulstone emote fields from 16 to 18
- Increased Ritual of Souls quote fields from 20 to 21
- Increased Ritual of Summoning quote fields from 32 to 33
- Increased all demon quote fields to minumum 15
- Added LibAboutPanel library
- Updated AceGUI-3.0 library
Version 3.42
- Demon quotes can now be turned off independently
- Resurrected emote should now trigger correctly on all events
- Fixed summon and resurrected status view in LDB-panel
- Fixed bug interfering with Tongues in Imp quote #8, #14
- Fixed bug interfering with Tongues in Succubus quote #5, #7
- Fixed bug interfering with Tongues in Voidwalker quote #8, 9
- Fixed version number typo in French localization file
- Minor code optimization
- Updated TOC for patch 4.2
Version 3.4
- Demon quotes frequency can now be set independently
- Added French translation (need testing). Thanks to Kiala!
- Updated TOC for patch 4.1
- Updated AceLocale-3.0 & AceGUI-3.0 libraries
Version 3.31
- Fixed typos in '<demon> name detected' sections
Version 3.3
- GUI options screen can now be binded to a key
- Increased Felguard/Felhunter quote fields from 8 to 10
- Increased Soulstone quote fields from 22 to 24
- New quote active on Ritual of Summoning quote #32
- New quotes active on Soulstone emote #16, quote #22, #23, #24
- Fixed Imp quote #4, #6 to better work with long Imp names
- Fixed Summoning quotes #5, #15, #25, #26 due to Shard changes
- Fixed small typo in Voidwalker quote #8
- Minor layout enhancements in GUI options screen
- Reorganized localization file in alphabetical order
- Updated AceAddon-3.0 & AceGUI-3.0 libraries
Version 3.2
- Updated TOC for Cataclysm
- Updated AceGUI-3.0 library
- Updated Ritual of Souls/Summoning quotes in localization file
- Fixed event variables for Cataclysm API
- Fixed spellID variables for Cataclysm API
- Removed autodelete of Soul Shards
- Removed Soul Shard management from GUI options screen
- Removed Soul Shard info from LDB-panel
- Removed unused variables in localization file
Version 3.1
- Fixed bug in tags parser function when changing target
Version 3.09
- Increased Imp quotes from 16 to 18
- Increased default demon quotes frequency from 10% to 20%
- Fixed default Felguard quotes from 5 to 6
- Updated Ace3 libraries
Version 3.05
- Soulstone events frequency can now be set independently
- Fixed typos in Soulstone emote #8, #9 and #15
- Increased Felguard quotes from 5 to 6
- Minor changes in LDB-panel
- Code optimization
Version 3.01
- Fixed bug interfering with Tongues and public announcements
Version 3.0
- Support for <pet> tags, see defaults for examples
- Does a random quote when summoning Felguard or Felhunter
- Increased Soulstone emotes from 14 to 16
- Increased Soulstone quotes from 20 to 22
- Increased Ritual of Summoning quotes from 22 to 32
- Increased Imp quotes from 14 to 16
- Increased Voidwalker quotes from 9 to 10
- Several demon quotes was reset due to use of <pet> tag
- Enhanced Options/LDB-panel incl. dynamic demon icons
- Version number is now located under Options/About
Version 2.61
- Fixed bug with libraries loading routine
Version 2.6
- Does a random quote when summoning Succubus
- Increased Imp quotes from 10 to 14
- Increased Voidwalker quotes from 7 to 9
- Minor changes in LDB-panel
- Removed LDB options menu
- Libraries loading routine moved from XML to TOC
- Various code layout optimization
Version 2.5
- Does a random quote when summoning Imp or Voidwalker
- How frequent all events trigger can now be set
- Hearthstone and Resurrected emotes can now be set to random
- 'Helpme' emote for the rituals can now be turned off independently
- Updated 3 Soulstone events to reflect new cooldown timer (15min)
- Removed changelog from advanced options menu
- Removed version number from LDB-panel
- Various code optimization tweaks (some variables had to reset)
- Minor GUI and sound effect changes
- Memory usage reduced 50kb
- Updated AceConfig-3.0 & AceGUI-3.0 libraries
Version 2.41
- Fixed bug in parser function for targets from other realms
Version 2.4
- Updated TOC for patch 3.3
- Updated TOC addon loading routine
- Updated Ace3/LibDataBroker libraries
- Reduced fixed width size in advanced options menu
- Minor changes in description fields
Version 2.35
- Updated TOC for patch 3.2
- Enhancements incl. sound effects in advanced options menu
- Advanced options can now be opened from Blizzard addons menu
Version 2.34
- Fixed bug with auto delete of excess Soul Shards
- Fixed bug not making the GUI options screen as intended
- Reduced Soulstone emotes from 18 to 14
- Reduced Soulstone quotes from 22 to 20
- Reduced Soulstone whispers from 21 to 18
Version 2.31
- Hearthstone emote should now trigger at all times
Version 2.3
- Resurrected emotes can now be changed
- Increased Resurrected emotes from 1 to 12
- Increased Ritual of Souls quotes from 17 to 20
- Rearranged Soulstone quotes/whispers
- Localization is now variables in core
- Minor code optimization
Version 2.21
- Fixed typos in description fields
Version 2.2
- Gender tags is no longer case sensitive, see what you type:)
- Support <his/hers> and <targetclass> tags
- Increased Soulstone emotes from 17 to 18
- Increased Soulstone quotes from 20 to 22
- Increased Soulstone whispers from 18 to 20
- Increased Ritual of Souls quotes from 16 to 17
- Increased Ritual of Summoning quotes from 20 to 22
- Increased Soul Shard view from 3 to 6 colors incl. new scales
- Fixed bug where changing profiles would force player to reload
- Fixed bug in tags function when using one of the ritual spells
- Fixed bug in tags parser function
- Minor changes in default emotes/quotes/whispers
- GUI enhancements in advanced options menu
Version 2.15
- Fixed random function causing neverending loop
- Fixed minor bug in Hearthstone timeframe
- Fixed typos in default emotes/quotes/whispers
- Enabled messages set to 1 no longer is 2 on reload
- Gender tags should now trigger correctly on all events
- Support <He/She> tags
- Increased Soulstone emotes from 10 to 17
- Increased Soulstone quotes from 18 to 20
- Increased Soulstone whispers from 12 to 18
- Increased Ritual of Souls quotes from 13 to 16
- Increased Ritual of Summoning quotes from 19 to 20
Version 2.1
- Support <he/she>,<him/her>,<his/her> tags, see defaults for examples
- Random emote/quote/whisper is now never the same twice in a row if > 1
- Increased Soulstone quotes from 10 to 18
- Increased Soulstone whispers from 10 to 12
- Increased Ritual of Souls quotes from 10 to 13
- Increased Ritual of Summoning quotes from 12 to 19
- Increased all emote/quote/whisper message fields to 20
- Soul Shard colorized view now scale 33% <> 66% previous 25% <> 75%
- Soul Shard amount on panel now updates correctly on profile reset
- GUI enhancements incl. new button to delete Soul Shards > defined value
- Reorganized config menu in LDB-panel
- Fixed bug interfering with BabelFu on French clients
Version 2.02
- Spell events now use spellID instead of spellName
Version 2.01
- Fixed emotes and spells localization
Version 2.0
- Support for the Soulstone spell incl. whisper to target:)
- Support <player> and <target> tags
- 'Helpme' emote for the rituals can now be turned off
- Max number of messages to use can now be set independently on all events
- Resurrected emote can now be enabled for party, raid and solo
- Increased Ritual of Summoning quotes from 10 to 12
- Title, status and options on tooltip can now be turned off
- Enhancements in advanced options menu
- Minor code optimization
Version 1.4
- Quotes management in advanced options has been reorganized
- Quotes can now be enabled for chat, party and raid independently
- Quote channels can now be changed (raid > party > say > yell)
- Increased all default quotes from 8 to 10
- Removed color codes from localization file
Version 1.32
- Fixed toggle of Hearthstone emotes more logical
- Fixed minor typo in morning, afternoon, evening and night descriptions
Version 1.3
- Fixed colors in panel/tooltip based on Soul Shard amount
- The 'Bye/Farewell' emote should now trigger correctly
- Quotes in chat frame if not in group can now be turned off
- Soul Shard amount on panel/tooltip can now be turned off
- Increased Hearthstone emotes from 6 to 14
- Increased Ritual of Souls quotes from 6 to 8
Version 1.2
- First public release
Version x.x
- Internal development releases