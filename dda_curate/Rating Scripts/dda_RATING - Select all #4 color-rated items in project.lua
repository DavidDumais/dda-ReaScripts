-- @version 1.0.0
-- @description dda_RATING - Select all #4 color-rated items in project
-- @about Selects all items in project that are colored with the color rating #4. Run the following script to set colors: dda_RATING - Show and change rating colors.lua
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Function to run a Reaper action by its command ID
function runActionByID(actionID)
    reaper.Main_OnCommand(actionID, 0)
end

-- Function to read RGB values from the custom_colors.txt file for the fourth custom color
function readFourthCustomColors()
    local file_path = reaper.GetResourcePath() .. "\\CustomColors\\custom_colors.txt"
    local file = io.open(file_path, "r")

    if file then
        local customColors = {}
        local count = 0
        for line in file:lines() do
            count = count + 1
            if count == 4 then
                local r, g, b = line:match("(%d+),(%d+),(%d+)")
                if r and g and b then
                    return tonumber(r), tonumber(g), tonumber(b)
                end
            end
        end
        file:close()
    end

    return nil, nil, nil
end

-- Function to select items with the fourth custom color
function selectItemsWithFourthCustomColor()
    local r, g, b = readFourthCustomColors()
    if r and g and b then
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
        reaper.UpdateArrange() -- Update the arrangement to reflect the selection changes
                --reaper.ShowConsoleMsg("Items with the fourth custom color selected.\n")
            else
                --reaper.ShowConsoleMsg("Failed to read RGB values for the fourth custom color.\n")
            end
        end
        
        -- Run the "Unselect all items/tracks/envelope points" command
        runActionByID(40289)
        
        -- Run the function to select items with the fourth custom color
        selectItemsWithFourthCustomColor()
