-- @version 1.0.1
-- @description dda_CATEGORIZATION - Find and select all items with user defined text notes from selected items selection
-- @about Prompts user for text, then finds and selects only items from the selected items whose notes match the user defined text.
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/l/dda_CURATE

--SCRIPT--

-- Function to prompt user for text input
function getUserTextInput(prompt)
    local userOk, userInput = reaper.GetUserInputs("Enter Text (Case Sensitive)", 1, prompt, "")
    return userOk, userInput
end

-- Function to select items that have notes containing the user text
function selectItemsWithNotesContainingText(userText)
    local selectedItems = {}
    local numSelectedItems = reaper.CountSelectedMediaItems(0)
    local anyItemSelected = false
    
    for i = 0, numSelectedItems - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local _, notes = reaper.GetSetMediaItemInfo_String(item, "P_NOTES", "", false)
        
        if notes and string.find(notes, userText) then
            table.insert(selectedItems, item)
            anyItemSelected = true
        end
    end
    
    if anyItemSelected then
        reaper.Main_OnCommand(40289, 0) -- Deselect all items before selecting the matched ones
        for _, item in ipairs(selectedItems) do
            reaper.SetMediaItemSelected(item, true)
        end
        reaper.UpdateArrange()
    else
        reaper.Main_OnCommand(40289, 0) -- Deselect all items
    end
    
    return anyItemSelected
end

-- Check if any items are selected
local numSelectedItems = reaper.CountSelectedMediaItems(0)
if numSelectedItems == 0 then
    reaper.ShowMessageBox("Please select items before running this script.", "Error", 0)
    return
end

-- Get user input text
local userOk, userText = getUserTextInput("Enter the text to match in notes:")

-- Check if user input is not empty
if userOk and userText ~= "" then
    local anyItemSelected = selectItemsWithNotesContainingText(userText)
    if not anyItemSelected then
        --reaper.ShowConsoleMsg("No selected items contain the input text.\n")
    else
        --reaper.ShowConsoleMsg("Items with notes containing '" .. userText .. "' have been selected.\n")
    end
elseif not userOk then
    --reaper.ShowConsoleMsg("No text input provided.\n")
end

