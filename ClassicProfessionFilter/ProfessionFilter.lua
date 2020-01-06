local CPF, C, L = unpack(select(2, ...))
local MODULE_NAME = "ProfessionFilter"

--[===[@debug@
print(CPF.ADDON_NAME, MODULE_NAME)
--@end-debug@]===]


---------------------------------------------
-- MIXIN: SearchBar
---------------------------------------------
ClassicProfessionFilterSearchBoxMixIn = {}
function ClassicProfessionFilterSearchBoxMixIn:OnHide()
    self:SetText("") -- clear filter
end

function ClassicProfessionFilterSearchBoxMixIn:OnTextChanged(...)
    SearchBoxTemplate_OnTextChanged(self, ...);
end

function ClassicProfessionFilterSearchBoxMixIn:OnChar(...)
    -- ClearFocus if too many characters are repeated (like trying to move while typing)
    BagSearch_OnChar(self, ...)
end

function ClassicProfessionFilterSearchBoxMixIn:OnEscapePressed(...)
    self:SetText("") -- clear filter
    self:ClearFocus()
end
