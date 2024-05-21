-- @version 1.0.0
-- @description dda_RATING - Select all #5 color-rated items on selected tracks only
-- @about Selects all items on selected tracks that are colored with the color rating #5. Run the following script to set colors: dda_RATING - Show and change rating colors.lua
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Function to run a Reaper action by its command ID
function runActionByID(actionID)
    reaper.Main_OnCommand(actionID, 0)
end

-- Function to read RGB values from the custom_colors.txt file for the fifth custom color
function readFifthCustomColor()
    local file_path = reaper.GetResourcePath() .. "\\CustomColors\\custom_colors.txt"
    local file = io.open(file_path, "r")

    if file then
        local count = 0
        for line in file:lines() do
            count = count + 1
            if count == 5 then -- Fifth line for the fifth custom color
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

-- Function to select items with the fifth custom color on all selected tracks
function selectItemsWithFifthCustomColorOnSelectedTracks(r, g, b)
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

-- Read RGB values for the fifth custom color
local r, g, b = readFifthCustomColor()
if r and g and b then
    -- Run the "Unselect all items/tracks/envelope points" command
    runActionByID(40289)
    
    -- Select items with the fifth custom color on all selected tracks
    selectItemsWithFifthCustomColorOnSelectedTracks(r, g, b)
    
    reaper.UpdateArrange() -- Update the arrangement to reflect the selection changes
    --reaper.ShowConsoleMsg("Items with the fifth custom color on all selected tracks have been selected.\n")
else
    --reaper.ShowConsoleMsg("Failed to read RGB values for the fifth custom color.\n")
end

