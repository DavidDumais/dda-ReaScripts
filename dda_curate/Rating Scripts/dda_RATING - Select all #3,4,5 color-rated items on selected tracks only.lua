-- @version 1.0.1
-- @description dda_RATING - Select all #3,4,5 color-rated items on selected tracks only
-- @about Selects all items on selected tracks that are colored with the color rating #3, #4, or #5. Run the following script to set colors: dda_RATING - Show and change rating colors.lua
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/l/dda_CURATE

--SCRIPT--

-- Function to run a Reaper action by its command ID
function runActionByID(actionID)
    reaper.Main_OnCommand(actionID, 0)
end

-- Function to read RGB values from the custom_colors.txt file for the specified custom color index
function readCustomColor(index)
    local file_path = reaper.GetResourcePath() .. "\\CustomColors\\custom_colors.txt"
    local file = io.open(file_path, "r")

    if file then
        local count = 0
        for line in file:lines() do
            count = count + 1
            if count == index then
                local r, g, b = line:match("(%d+),(%d+),(%d+)")
                if r and g and b then
                    file:close()
                    return tonumber(r), tonumber(g), tonumber(b)
                end
            end
        end
        file:close()
    end

    return nil, nil, nil
end

-- Function to select items with the specified custom color on all selected tracks
function selectItemsWithCustomColorOnSelectedTracks(r, g, b)
    local num_sel_tracks = reaper.CountSelectedTracks(0)
    if num_sel_tracks == 0 then
        --reaper.ShowConsoleMsg("No tracks selected.\n")
        return
    end

    -- Iterate through each selected track
    for i = 0, num_sel_tracks - 1 do
        local track = reaper.GetSelectedTrack(0, i)
        if track then
            -- Iterate through each item on the track
            local num_items = reaper.CountTrackMediaItems(track)
            for j = 0, num_items - 1 do
                local item = reaper.GetTrackMediaItem(track, j)
                if item then
                    local item_color = reaper.GetDisplayedMediaItemColor(item)
                    local item_r, item_g, item_b = reaper.ColorFromNative(item_color)
                    if item_r == r and item_g == g and item_b == b then
                        reaper.SetMediaItemSelected(item, true)
                    end
                end
            end
        end
    end
    reaper.PreventUIRefresh(-1)
end

-- Run the "Unselect all items/tracks/envelope points" command
runActionByID(40289)

-- Read RGB values for color #3
local r3, g3, b3 = readCustomColor(3)
if r3 and g3 and b3 then
    -- Select items with color #3 on all selected tracks
    selectItemsWithCustomColorOnSelectedTracks(r3, g3, b3)
    
    reaper.UpdateArrange() -- Update the arrangement to reflect the selection changes
    --reaper.ShowConsoleMsg("Items with color #3 on all selected tracks have been selected.\n")
else
    --reaper.ShowConsoleMsg("Failed to read RGB values for color #3.\n")
end

-- Read RGB values for color #4
local r4, g4, b4 = readCustomColor(4)
if r4 and g4 and b4 then
    -- Select items with color #4 on all selected tracks
    selectItemsWithCustomColorOnSelectedTracks(r4, g4, b4)
    
    reaper.UpdateArrange() -- Update the arrangement to reflect the selection changes
    --reaper.ShowConsoleMsg("Items with color #4 on all selected tracks have been selected.\n")
else
    --reaper.ShowConsoleMsg("Failed to read RGB values for color #4.\n")
end

-- Read RGB values for color #5
local r5, g5, b5 = readCustomColor(5)
if r5 and g5 and b5 then
    -- Select items with color #5 on all selected tracks
    selectItemsWithCustomColorOnSelectedTracks(r5, g5, b5)
    
    reaper.UpdateArrange() -- Update the arrangement to reflect the selection changes
    --reaper.ShowConsoleMsg("Items with color #5 on all selected tracks have been selected.\n")
else
    --reaper.ShowConsoleMsg("Failed to read RGB values for color #5.\n")
end

