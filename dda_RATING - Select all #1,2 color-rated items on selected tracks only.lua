-- @noindex
-- ReaScript Name: dda_RATING - Select all #1,2 color-rated items on selected tracks only
-- description: Selects all items on selected tracks that are colored with the color rating #1 or #2. Run the following script to set colors: dda_RATING - Show and change rating colors.lua
-- author: David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT—

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

-- Read RGB values for color #1
local r1, g1, b1 = readCustomColor(1)
if r1 and g1 and b1 then
    -- Select items with color #1 on all selected tracks
    selectItemsWithCustomColorOnSelectedTracks(r1, g1, b1)
    
    reaper.UpdateArrange() -- Update the arrangement to reflect the selection changes
    --reaper.ShowConsoleMsg("Items with color #1 on all selected tracks have been selected.\n")
else
    --reaper.ShowConsoleMsg("Failed to read RGB values for color #1.\n")
end

-- Read RGB values for color #2
local r2, g2, b2 = readCustomColor(2)
if r2 and g2 and b2 then
    -- Select items with color #2 on all selected tracks
    selectItemsWithCustomColorOnSelectedTracks(r2, g2, b2)
    
    reaper.UpdateArrange() -- Update the arrangement to reflect the selection changes
    --reaper.ShowConsoleMsg("Items with color #2 on all selected tracks have been selected.\n")
else
    --reaper.ShowConsoleMsg("Failed to read RGB values for color #2.\n")
end

