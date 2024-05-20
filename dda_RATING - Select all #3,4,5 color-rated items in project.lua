-- @noindex
-- ReaScript Name: dda_RATING - Select all #3,4,5 color-rated items in project
-- description: Selects all items in project that are colored with the color rating #3, #4, or #5. Run the following script to set colors: dda_RATING - Show and change rating colors.lua
-- author: David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT—

-- Function to run a Reaper action by its command ID
function runActionByID(actionID)
    reaper.Main_OnCommand(actionID, 0)
end

-- Function to read RGB values from the custom_colors.txt file for the third to fifth custom colors
function readThirdToFifthCustomColors()
    local file_path = reaper.GetResourcePath() .. "\\CustomColors\\custom_colors.txt"
    local file = io.open(file_path, "r")

    if file then
        local customColors = {}
        local count = 0
        for line in file:lines() do
            count = count + 1
            if count >= 3 and count <= 5 then
                local r, g, b = line:match("(%d+),(%d+),(%d+)")
                if r and g and b then
                    customColors[count] = {tonumber(r), tonumber(g), tonumber(b)}
                end
            end
        end
        file:close()
        return customColors
    end

    return nil
end

-- Function to select items with a specific custom color
function selectItemsWithCustomColor(r, g, b)
    for i = 0, reaper.CountMediaItems(0) - 1 do
        local item = reaper.GetMediaItem(0, i)
        if item then
            local itemColor = reaper.GetDisplayedMediaItemColor(item)
            local itemR, itemG, itemB = reaper.ColorFromNative(itemColor)
            if itemR == r and itemG == g and itemB == b then
                                reaper.SetMediaItemSelected(item, true)
                            end
                        end
                    end
                    reaper.PreventUIRefresh(-1)
            end
            
            -- Read RGB values for the third to fifth custom colors
            local customColors = readThirdToFifthCustomColors()
            if customColors then
                -- Run the "Unselect all items/tracks/envelope points" command
                runActionByID(40289)
                
                -- Select items with the third custom color
                selectItemsWithCustomColor(customColors[3][1], customColors[3][2], customColors[3][3])
                
                -- Select items with the fourth custom color
                selectItemsWithCustomColor(customColors[4][1], customColors[4][2], customColors[4][3])
                
                -- Select items with the fifth custom color
                selectItemsWithCustomColor(customColors[5][1], customColors[5][2], customColors[5][3])
                
                reaper.UpdateArrange() -- Update the arrangement to reflect the selection changes
                --reaper.ShowConsoleMsg("Items with the third, fourth, and fifth custom colors have been selected.\n")
            else
                --reaper.ShowConsoleMsg("Failed to read RGB values for the third to fifth custom colors.\n")
            end
