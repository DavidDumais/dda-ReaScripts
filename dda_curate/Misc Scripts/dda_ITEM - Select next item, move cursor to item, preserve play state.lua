-- @version 1.0.3
-- @description dda_ITEM - Select next item, move cursor to item, preserve play state
-- @about Selects the next item to the right of the cursor on the selected track. It then moves the cursor to the start of that item all while preserving the play state.
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

-- Function to get the next item on the track
local function getNextItemOnTrack(track, cursorPos)
    local numItems = reaper.CountTrackMediaItems(track)
    local nextItem = nil
    local nextItemPos = math.huge

    for i = 0, numItems - 1 do
        local item = reaper.GetTrackMediaItem(track, i)
        local itemStartPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")

        if itemStartPos > cursorPos and itemStartPos < nextItemPos then
            nextItem = item
            nextItemPos = itemStartPos
        end
    end

    return nextItem, nextItemPos
end

-- Store the current play state and cursor position
local playState = reaper.GetPlayState()
local cursorPos = reaper.GetCursorPosition()

-- Print initial play state
printPlayState(playState, "Initial")

-- Get the selected track
local selectedTrack = reaper.GetSelectedTrack(0, 0)
if not selectedTrack then
    --reaper.ShowConsoleMsg("No track selected, exiting script.\n")
    return
end

-- Print the selected track name
printTrackName(selectedTrack)

-- Get the next item on the track
local nextItem, nextItemPos = getNextItemOnTrack(selectedTrack, cursorPos)

-- If no next item is found, exit the script
if not nextItem then
    --reaper.ShowConsoleMsg("No next item found, exiting script.\n")
    return
end

-- Print the position of the next item
--reaper.ShowConsoleMsg("Next Item Position: " .. nextItemPos .. "\n")

-- Store previous arrange view options
local arrangeViewOptions = reaper.GetToggleCommandState(40589) -- Get state of auto-scroll during playback

-- Select the next item
reaper.SelectAllMediaItems(0, false) -- Unselect all items
reaper.SetMediaItemSelected(nextItem, true) -- Select the next item

-- Move the cursor to the start of the next item
reaper.SetEditCurPos(nextItemPos, false, false)

-- Ensure the cursor is followed when in stop state
if playState == 0 then -- Stopped
    reaper.Main_OnCommand(40150, 0) -- View: Go to play cursor
elseif arrangeViewOptions == 0 then -- Check if follow mode is disabled
    reaper.Main_OnCommand(40589, 0) -- View: Toggle auto-scroll during playback
end

-- Handle the play state (move play cursor to the start of the next item when in play state)
if playState & 1 == 1 then -- Playing
    reaper.SetEditCurPos(nextItemPos, true, false) -- Move edit cursor to start of next item
    reaper.OnPlayButton() -- Start playback from new cursor position
end

-- Print final play state
local finalPlayState = reaper.GetPlayState()
printPlayState(finalPlayState, "Final")

-- Update the arrangement view
reaper.UpdateArrange()

