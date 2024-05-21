-- @version 1.0.0
-- @description: dda_RATING - Change rating colors
-- @about: Allows user to change rating colors that will be used to color, select, and sort items using other dda_RATING scripts
-- @author: David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Function to get RGB values from a custom color in slot 1
function getCustomColorRGB(slot)
    local _, color = reaper.GR_SelectColor()
    if color ~= 0 then
        local r, g, b = reaper.ColorFromNative(color)
        return r, g, b
    else
        return nil, nil, nil
    end
end

-- Function to prompt the user for custom colors and save them to a file
function promptAndSaveColors()
    local customColors = {}
    for i = 1, 5 do
        --reaper.ShowConsoleMsg("Select Custom Color " .. i .. ":\n")
        local r, g, b = getCustomColorRGB(1)
        if r and g and b then
            table.insert(customColors, {r, g, b})
        else
            reaper.ShowMessageBox("Failed to select custom color " .. i .. ".", "Error", 0)
            return
        end
    end

    -- Check if 5 colors were selected
    if #customColors ~= 5 then
        reaper.ShowMessageBox("Please select exactly 5 custom colors.", "Error", 0)
        return
    end

    -- Get the directory path
    local directory = reaper.GetResourcePath() .. "\\CustomColors"
    
    -- Create the directory if it doesn't exist
    local success, error_message = reaper.RecursiveCreateDirectory(directory, 0)
    if not success then
        --reaper.ShowConsoleMsg("Failed to create directory: " .. error_message .. "\n")
        return
    end

    -- Save the custom colors to a file
    local file_path = directory .. "\\custom_colors.txt"
    local file = io.open(file_path, "w")
    if file then
        for i = 1, 5 do
            file:write(table.concat(customColors[i], ",") .. "\n")
        end
        file:close()
        reaper.ShowMessageBox("Rating colors set.", "Success", 0) -- Pop-up message for success
        --reaper.ShowConsoleMsg("Custom colors saved to '" .. file_path .. "'.\n")
    else
        --reaper.ShowConsoleMsg("Failed to save custom colors to file.\n")
    end
end

-- Run the function to prompt and save custom colors
promptAndSaveColors()

