-- @version 1.0.3
-- @description dda_ITEM - Select previous item, move cursor to item, preserve play state
-- @about Selects the previous item to the left of the cursor on the selected track. It then moves the cursor to the start of that item all while preserving the play state.
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/l/dda_CURATE

--SCRIPT--

-- Function to print the play state
local function printPlayState(state, prefix)
    local states = {
        [0] = "Stopped",
        [1] = "Playing",
        [2] = "Paused",
        [4] = "Recording"
    }
    --reaper.ShowConsoleMsg(prefix .. " Play State: " .. (states[state] or "Unknown") .. " (" .. state .. ")\n")
end

-- Function to print the track name
local function printTrackName(track)
    local trackName = reaper.GetTrackName(track)
    if type(trackName) == "string" then
        --reaper.ShowConsoleMsg("Selected Track: " .. trackName .. "\n")
    else
        --reaper.ShowConsoleMsg("Selected Track: (Unnamed Track)\n")
    end
end

-- Store the current play state and cursor position
local initialPlayState = reaper.GetPlayState()
local cursorPos = reaper.GetCursorPosition()

-- Print initial play state
printPlayState(initialPlayState, "Initial")

-- Get the selected track
local selectedTrack = reaper.GetSelectedTrack(0, 0)
if not selectedTrack then
    --reaper.ShowConsoleMsg("No track selected, exiting script.\n")
    return
end

-- Print the selected track name
printTrackName(selectedTrack)

-- Get the number of media items in the project
local numItems = reaper.CountMediaItems(0)
if numItems == 0 then
    --reaper.ShowConsoleMsg("No items in the project, exiting script.\n")
    return
end

-- Initialize variables to find the previous item
local prevItem = nil
local prevItemPos = -math.huge

-- Loop through all items to find the first one to the left of the cursor on the selected track
for i = 0, numItems - 1 do
    local item = reaper.GetMediaItem(0, i)
    local itemTrack = reaper.GetMediaItemTrack(item)
    local itemStartPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    
    if itemTrack == selectedTrack and itemStartPos < cursorPos and itemStartPos > prevItemPos then
        prevItem = item
        prevItemPos = itemStartPos
    end
end

-- If no previous item is found, exit the script
if not prevItem then
    --reaper.ShowConsoleMsg("No previous item found, exiting script.\n")
    return
end

-- Print the position of the previous item
--reaper.ShowConsoleMsg("Previous Item Position: " .. prevItemPos .. "\n")

-- Select the previous item
reaper.SelectAllMediaItems(0, false) -- Unselect all items
reaper.SetMediaItemSelected(prevItem, true) -- Select the previous item

-- Move the cursor to the start of the previous item
reaper.SetEditCurPos(prevItemPos, false, false)

-- Ensure the cursor is followed when in stop state
if initialPlayState == 0 then -- Stopped
    reaper.Main_OnCommand(40150, 0) -- View: Go to play cursor
end

-- Restore the play state
if initialPlayState & 1 == 1 then -- Playing
    reaper.Main_OnCommand(1007, 0) -- Transport: Play
elseif initialPlayState & 2 == 2 then -- Paused
    -- If the initial state is paused, we keep it paused
end

-- Print final play state
printPlayState(initialPlayState, "Final")

-- Update the arrangement view
reaper.UpdateArrange()

