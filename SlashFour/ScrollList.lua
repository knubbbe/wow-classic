
-- Utils to translate from button indexes to data indexes

function ScrollListFrame_GetButtonIndexForIndex(scrollFrame, index)
	local buttonIndex = index - HybridScrollFrame_GetOffset(scrollFrame)
	if buttonIndex > 0 and buttonIndex <= #HybridScrollFrame_GetButtons(scrollFrame) then
		return buttonIndex
	else
		return nil -- return nil if the index is "off-screen" / not "visible" / none of the buttons currently represent that index
	end
end
function ScrollListFrame_GetIndexForButtonIndex(scrollFrame, buttonIndex)
	return buttonIndex + HybridScrollFrame_GetOffset(scrollFrame)
end
function ScrollListFrame_GetButtonIndexForButton(scrollFrame, button)
	local buttons = HybridScrollFrame_GetButtons(scrollFrame)
	for buttonIndex = 1, #buttons do
		if buttons[buttonIndex] == button then
			return buttonIndex
		end
	end
end
function ScrollListFrame_RegisterButtonsForRightClick(scrollFrame)
	for _, button in pairs(HybridScrollFrame_GetButtons(scrollFrame)) do
		button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	end
end

-- Animations

function ScrollListFrame_InsertRowAtIndex(scrollFrame, insertedIndex, animated)
	if not scrollFrame:IsVisible() or not scrollFrame.isInitialized then
		return
	end
	local animate = true

	local buttonIndex = ScrollListFrame_GetButtonIndexForIndex(scrollFrame, insertedIndex)
	if buttonIndex then -- buttonIndex == nil means this index is out of view (no button represents it)
		if animate then
			local rowConfigFuncAnimated = function(scrollFrame, index, button)
				if index == insertedIndex then
					scrollFrame.rowConfigFunc(scrollFrame, index, button)
					UIFrameFadeIn(button, 0.1, 0, 1)
				else
					scrollFrame.rowConfigFunc(scrollFrame, index, button)
				end
			end
			ScrollListFrame_ReloadButtonsFromButtonIndex(scrollFrame, buttonIndex, scrollFrame.rowCountFunc, scrollFrame.rowHeightFunc, rowConfigFuncAnimated)
		else
			ScrollListFrame_ReloadButtonsFromButtonIndex(scrollFrame, buttonIndex, scrollFrame.rowCountFunc, scrollFrame.rowHeightFunc, scrollFrame.rowConfigFunc)
		end
	end
end
function ScrollListFrame_RemoveRowAtIndex(scrollFrame, removedIndex, animated)
	if not scrollFrame:IsVisible() or not scrollFrame.isInitialized then
		return
	end
	local animate = true

	local buttonIndex = ScrollListFrame_GetButtonIndexForIndex(scrollFrame, removedIndex)
	if buttonIndex then -- buttonIndex == nil means this index is out of view (no button represents it)
		if animate then
			local button = HybridScrollFrame_GetButtons(scrollFrame)[buttonIndex]
			UIFrameFadeOut(button, 2, button:GetAlpha(), 0)
			button.fadeInfo.finishedFunc = function()
				local rowConfigFuncAnimated = function(scrollFrame, index, button)
					if index == removedIndex then
						scrollFrame.rowConfigFunc(scrollFrame, index, button)
						button:SetAlpha(1)
					else
						scrollFrame.rowConfigFunc(scrollFrame, index, button)
					end
				end
				ScrollListFrame_ReloadButtonsFromButtonIndex(scrollFrame, buttonIndex, scrollFrame.rowCountFunc, scrollFrame.rowHeightFunc, rowConfigFuncAnimated)
			end
		else
			ScrollListFrame_ReloadButtonsFromButtonIndex(scrollFrame, buttonIndex, scrollFrame.rowCountFunc, scrollFrame.rowHeightFunc, scrollFrame.rowConfigFunc)
		end
	end
end

-- Base

function ScrollListFrame_ReloadButtonsFromButtonIndex(scrollFrame, startButtonIndex, rowCountFunc, rowHeightFunc, rowConfigFunc)
	if not scrollFrame:IsVisible() or not scrollFrame.isInitialized then
		return
	end
	local dataCount = rowCountFunc(scrollFrame)
    local buttons = HybridScrollFrame_GetButtons(scrollFrame)
    for buttonIndex = startButtonIndex, #buttons do
        local index = ScrollListFrame_GetIndexForButtonIndex(scrollFrame, buttonIndex)
        local button = buttons[buttonIndex]
		if index <= dataCount then
			button:Show()
			rowConfigFunc(scrollFrame, index, button)
        else
            button:Hide()
        end
    end
    local numDisplayed = math.min(#buttons, dataCount)
    local rowHeight = rowHeightFunc(scrollFrame, 1, buttons[1]) -- TODO make dynamic
    local displayedHeight = numDisplayed * rowHeight
    local totalHeight = dataCount * rowHeight
    HybridScrollFrame_Update(scrollFrame, totalHeight, displayedHeight)
end
function ScrollListFrame_Initialize(scrollFrame, buttonTemplateName, rowCountFunc, rowHeightFunc, rowConfigFunc)
    if scrollFrame.isInitialized then
        return
	end
	scrollFrame.rowCountFunc = rowCountFunc
	scrollFrame.rowHeightFunc = rowHeightFunc
	scrollFrame.rowConfigFunc = rowConfigFunc
	scrollFrame.update = function()
		ScrollListFrame_ReloadButtonsFromButtonIndex(scrollFrame, 1, scrollFrame.rowCountFunc, scrollFrame.rowHeightFunc, scrollFrame.rowConfigFunc)
	end
	HybridScrollFrame_CreateButtons(scrollFrame, buttonTemplateName, 0, 0)
    HybridScrollFrame_SetDoNotHideScrollBar(scrollFrame, true)
	ScrollListFrame_RegisterButtonsForRightClick(scrollFrame)
    scrollFrame.isInitialized = true
end
