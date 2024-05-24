
-- @description dda_ITEM - Select next item, move cursor to item, preserve play state
-- @about Selects the next item to the right of the cursor on the selected track. It then moves the cursor to the start of that item all while preserving the play state.
-- @author David Dumais
-- @provides [main=dda_CURATE.lua] dda_CURATE
-- @package dda_CURATE
-- Store Page: https://daviddumaisaudio.gumroad.com/l/dda_CURATE

--SCRIPT--

-- Store the current play state and cursor position
local playState = reaper.GetPlayState()
local cursorPos = reaper.GetCursorPosition()

-- Get the selected track
local selectedTrack = reaper.GetSelectedTrack(0, 0)
if not selectedTrack then return end -- No track selected, exit the script

-- Get the number of media items in the project
local numItems = reaper.CountMediaItems(0)
if numItems == 0 then return end -- No items in the project, exit the script

-- Initialize variables to find the next item
local nextItem = nil
local nextItemPos = math.huge

-- Loop through all items to find the first one to the right of the cursor on the selected track
for i = 0, numItems - 1 do
    local item = reaper.GetMediaItem(0, i)
    local itemTrack = reaper.GetMediaItemTrack(item)
    local itemStartPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    
    if itemTrack == selectedTrack and itemStartPos > cursorPos and itemStartPos < nextItemPos then
        nextItem = item
        nextItemPos = itemStartPos
    end
end

-- If no next item is found, exit the script
if not nextItem then return end

-- Select the next item
reaper.SelectAllMediaItems(0, false) -- Unselect all items
reaper.SetMediaItemSelected(nextItem, true) -- Select the next item

-- Move the cursor to the start of the next item
reaper.SetEditCurPos(nextItemPos, false, false)

-- Restore the play state
if playState & 1 == 1 then -- Playing
    reaper.OnPlayButton()
elseif playState & 2 == 2 then -- Recording
    reaper.OnRecordButton()
end

-- Update the arrangement view
reaper.UpdateArrange()

