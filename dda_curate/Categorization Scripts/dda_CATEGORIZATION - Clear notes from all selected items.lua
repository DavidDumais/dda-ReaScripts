-- @version 1.0.0
-- @description: dda_CATEGORIZATION - Clear notes from all selected items
-- @about removes all notes from all selected items
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

local userInput = "" -- Set userInput to an empty string

for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
    local item = reaper.GetSelectedMediaItem(0, i)
    reaper.ULT_SetMediaItemNote(item, userInput) -- Set the item notes to an empty string
end

reaper.UpdateArrange() -- Update the arrangement to reflect the changes
--reaper.ShowConsoleMsg("Item notes set to empty for selected items.\n") -- Print a confirmation message to the console

