-- @version 1.0.1
-- @description dda_METADATA - Add description metadata to selected item notes
-- @about Prompts user for desription text for selected items. Inserts user text as notes to selected items.
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/l/dda_CURATE

--SCRIPT--

-- Function to add text to the notes of a specific item
function addTextToItemNotes(item, newText)
    local _, notes = reaper.GetSetMediaItemInfo_String(item, "P_NOTES", "", false)

    notes = notes:gsub("^%s*(.-)%s*$", "%1")  -- Trim leading and trailing white spaces or new lines
    newText = newText:gsub("^%s*(.-)%s*$", "%1")  -- Trim leading and trailing white spaces or new lines

    if notes ~= "" then
        newText = "description=" .. newText .. "; " .. notes  -- Prepend 'description=' and append existing notes
    else
        newText = "description=" .. newText  -- Prepend 'description=' if notes are empty
    end

    reaper.GetSetMediaItemInfo_String(item, "P_NOTES", newText, true) -- Set the updated notes
end

-- Check if at least one item is selected
local selItemCount = reaper.CountSelectedMediaItems(0)
if selItemCount > 0 then
    -- Get user input
    local userInputOK, userInput = reaper.GetUserInputs("Add description to selected media item notes", 1, "Description:,extrawidth=250", "")
    if userInputOK then
        for i = 0, selItemCount - 1 do
            local item = reaper.GetSelectedMediaItem(0, i)
            addTextToItemNotes(item, userInput)
        end

        reaper.UpdateArrange() -- Update the arrangement to reflect the changes
        --reaper.ShowConsoleMsg("Description added to selected item notes: " .. userInput .. "\n") -- Print a confirmation message to the console
    end
else
    reaper.ShowMessageBox("Please select at least one item.", "Error", 0)
end

