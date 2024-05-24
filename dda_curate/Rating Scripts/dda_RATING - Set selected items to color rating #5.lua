-- @version 1.0.0
-- @description dda_RATING - Set selected items to color rating #5
-- @about Changes the selected items color to the color set for rating color #5. Run the following script to set colors: dda_RATING - Show and change rating colors.lua
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/l/dda_CURATE

--SCRIPT--

-- Function to read RGB values from the custom_colors.txt file for the fifth custom color
function readFifthCustomColors()
    local file_path = reaper.GetResourcePath() .. "\\CustomColors\\custom_colors.txt"
    local file = io.open(file_path, "r")

    if file then
        local customColors = {}
        local count = 0
        for line in file:lines() do
            count = count + 1
            if count == 5 then
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

-- Read RGB values from the fifth custom color set in custom_colors.txt file
local r, g, b = readFifthCustomColors()

if not r or not g or not b then
    -- Display message box if custom colors have not been set
    reaper.ShowMessageBox("No rating colors detected. Run the following script to set rating colors: dda_RATING - Show and change rating colors.lua", "No Custom Colors", 0)
else
    -- Function to set RGBA custom color on selected items
    function setCustomColorOnSelectedItems(r, g, b)
        for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
            local item = reaper.GetSelectedMediaItem(0, i)
            if item then
                reaper.SetMediaItemInfo_Value(item, "I_CUSTOMCOLOR", reaper.ColorToNative(r, g, b) | 0x1000000)
            end
        end
    end

    -- Set the custom color on selected media items
    setCustomColorOnSelectedItems(r, g, b)
    reaper.UpdateArrange() -- Update the arrangement to reflect the color changes
end

