-- @version 1.0.0
-- @description dda_CATEGORIZATION - Find and select all items with user defined text notes in project
-- @about Prompts user for text, then finds and selects all items in the project whose notes match the user defined text.
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/l/dda_CURATE

--SCRIPT--

-- Function to run a Reaper action by its command ID
function runActionByID(actionID)
    reaper.Main_OnCommand(actionID, 0)
end

-- Function to prompt user for text input
function getUserTextInput(prompt)
    local userOk, userInput = reaper.GetUserInputs("Enter Text (Case Sensitive)", 1, prompt, "")
    return userOk, userInput
end

-- Function to select items that have notes containing the user text
function selectItemsWithNotesContainingText(userText)
    local numItems = reaper.CountMediaItems(0)
    
    for i = 0, numItems - 1 do
        local item = reaper.GetMediaItem(0, i)
        local _, notes = reaper.GetSetMediaItemInfo_String(item, "P_NOTES", "", false)
        
        if notes and string.find(notes, userText) then
            reaper.SetMediaItemSelected(item, true)
        end
    end
    
    reaper.UpdateArrange()
end

-- Run the "Unselect all items/tracks/envelope points" action using command ID 40289
runActionByID(40289)

-- Get user input text
local userOk, userText = getUserTextInput("Enter the text to match in notes:")

-- Check if user input is not empty
if userOk and userText ~= "" then
    selectItemsWithNotesContainingText(userText)
    --reaper.ShowConsoleMsg("Items with notes containing '" .. userText .. "' have been selected.\n")
elseif not userOk then
    --reaper.ShowConsoleMsg("No text input provided.\n")
end

