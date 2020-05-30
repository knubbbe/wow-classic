local AddonName, Addon = ...

BINDING_HEADER_LFGKEYBINDINGS = "Looking For Group"

SLASH_FOUR1, SLASH_FOUR2 = "/four", "/lfg"
SlashCmdList["FOUR"] = function(msg)
	ToggleFrame(LFGFrame)
end

Addon.debug = false
Addon.name = AddonName
Addon.messages = {}
Addon.players = {}
Addon.tags = {}

Addon.isInitialized = true
