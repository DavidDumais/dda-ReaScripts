-- @version 1.0.0
-- @description dda_RATING - Select all #1,2,3 color-rated items in project
-- @about Selects all items in project that are colored with the color rating #1, #2, or #3. Run the following script to set colors: dda_RATING - Show and change rating colors.lua
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Function to run a Reaper action by its command ID
function runActionByID(actionID)
    reaper.Main_OnCommand(actionID, 0)
end

-- Function to read RGB values from the custom_colors.txt file for the first custom color
function readFirstCustomColors()
    local file_path = reaper.GetResourcePath() .. "\\CustomColors\\custom_colors.txt"
    local file = io.open(file_path, "r")

    if file then
        local customColors = {}
        local count = 0
        for line in file:lines() do
            count = count + 1
            if count == 1 then
                local r, g, b = line:match("(%d+),(%d+),(%d+)")
                if r and g and b then
                    customColors[1] = {tonumber(r), tonumber(g), tonumber(b)}
                end
            elseif count == 2 then
                local r, g, b = line:match("(%d+),(%d+),(%d+)")
                if r and g and b then
                    customColors[2] = {tonumber(r), tonumber(g), tonumber(b)}
                end
            elseif count == 3 then
                local r, g, b = line:match("(%d+),(%d+),(%d+)")
                if r and g and b then
                    customColors[3] = {tonumber(r), tonumber(g), tonumber(b)}
                    break
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

-- Read RGB values for the first, second, and third custom colors
local customColors = readFirstCustomColors()
if customColors then
    -- Run the "Unselect all items/tracks/envelope points" command
    runActionByID(40289)
    
    -- Select items with the first custom color
    selectItemsWithCustomColor(customColors[1][1], customColors[1][2], customColors[1][3])
    
    -- Select items with the second custom color
    selectItemsWithCustomColor(customColors[2][1], customColors[2][2], customColors[2][3])

    -- Select items with the third custom color
    selectItemsWithCustomColor(customColors[3][1], customColors[3][2], customColors[3][3])
    
    reaper.UpdateArrange() -- Update the arrangement to reflect the selection changes
    --reaper.ShowConsoleMsg("Items with the first, second, and third custom colors have been selected.\n")
else
    --reaper.ShowConsoleMsg("Failed to read RGB values for the first, second, and third custom colors.\n")
end
