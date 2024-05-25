-- @version 1.0.2
-- @description dda_CATEGORIZATION - Add text to selected item notes
-- @about prompts user for text and inserts text in selected item notes
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/l/dda_CURATE

--SCRIPT--

-- Function to add text to the notes of a specific item
function addTextToItemNotes(item, newText)
    local _, notes = reaper.GetSetMediaItemInfo_String(item, "P_NOTES", "", false)

    notes = notes:gsub("^%s*(.-)%s*$", "%1")  -- Trim leading and trailing white spaces or new lines
    newText = newText:gsub("^%s*(.-)%s*$", "%1")  -- Trim leading and trailing white spaces or new lines

    if notes ~= "" then
        newText = notes .. newText  -- Append new text directly without spaces or lines if notes are already present
    end

    reaper.GetSetMediaItemInfo_String(item, "P_NOTES", newText, true) -- Set the updated notes
end

-- Check if at least one item is selected
local selItemCount = reaper.CountSelectedMediaItems(0)
if selItemCount > 0 then
    -- Specify popup window position manually
    local popupX = 100  -- X coordinate (adjust as needed)
    local popupY = 100  -- Y coordinate (adjust as needed)

    -- Get user input
    local userInputOK, userInput = reaper.GetUserInputs("Add Text to Selected Item Notes", 1, "Enter your text here:,extrawidth=250", "", popupX, popupY) -- Adjusted width
    if userInputOK then
        for i = 0, selItemCount - 1 do
            local item = reaper.GetSelectedMediaItem(0, i)
            addTextToItemNotes(item, userInput)
        end

        reaper.UpdateArrange() -- Update the arrangement to reflect the changes
        -- reaper.ShowConsoleMsg("Text added to selected item notes: " .. userInput .. "\n") -- Print a confirmation message to the console
    end
else
    reaper.ShowMessageBox("Please select at least one item.", "Error", 0)
end
