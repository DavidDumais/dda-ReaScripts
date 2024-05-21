-- @version 1.0.0
-- @description: dda_RATING - Set selected items to color rating #1
-- @about: Changes the selected items color to the color set for rating color #1. Run the following script to set colors: dda_RATING - Show and change rating colors.lua
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Function to read RGB values from the custom_colors.txt file
function readCustomColors()
    local file_path = reaper.GetResourcePath() .. "\\CustomColors\\custom_colors.txt"
    local file = io.open(file_path, "r")

    if file then
        local customColors = {}
        for line in file:lines() do
            local r, g, b = line:match("(%d+),(%d+),(%d+)")
            if r and g and b then
                table.insert(customColors, {tonumber(r), tonumber(g), tonumber(b)})
            end
        end
        file:close()

        if #customColors > 0 then
            return customColors[1][1], customColors[1][2], customColors[1][3]
        end
    end

    return nil, nil, nil
end

-- Function to check if custom colors have been set
function checkCustomColors()
    local file_path = reaper.GetResourcePath() .. "\\CustomColors\\custom_colors.txt"
    local file = io.open(file_path, "r")

    if file then
        file:close()
        return true
    else
        return false
    end
end

-- Function to set RGBA color on selected media items
function setCustomColorOnSelectedItems(r, g, b)
    for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        if item then
            reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", reaper.ColorToNative(r, g, b) | 0x1000000) -- Set RGBA custom color
        end
    end
end

-- Check if custom colors have been set
local customColorsExist = checkCustomColors()

if not customColorsExist then
    -- Display message box if custom colors have not been set
    reaper.ShowMessageBox("No rating colors detected. Run the following script to set rating colors: dda_RATING - Show and change rating colors.lua", "No Custom Colors", 0)
else
    -- Read RGB values from custom_colors.txt file
    local r, g, b = readCustomColors()

    if r and g and b then
        -- Set the custom color on selected media items
        setCustomColorOnSelectedItems(r, g, b)
        reaper.UpdateArrange() -- Update the arrangement to reflect the color changes
    else
        -- Show message if RGB values couldn't be read
        reaper.ShowMessageBox("Failed to read RGB values from custom_colors.txt file.", "Error", 0)
    end
end

