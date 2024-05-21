-- @version 1.0.0
-- @description: dda_RATING - Show and change rating colors
-- @about: Allows user to see as well as change rating colors that will be used to color, select, and sort items using other dda_RATING scripts
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Function to restart the script
local function restartScript()
    local scriptPath = debug.getinfo(1).source:match("@(.*)$") -- Get the path of the current script
    reaper.ExecProcess('"' .. reaper.GetExePath() .. "reaper.exe" .. '" "' .. scriptPath .. '"', 0) -- Execute the script again
    gfx.quit() -- Quit the GUI
    promptCalled = false -- Reset the promptCalled flag
    colorsChanged = false -- Reset the colorsChanged flag
    --reaper.ShowConsoleMsg("Script restarted\n")
end

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

local colorsChanged = false -- Flag to indicate if colors have been successfully changed
local colorsSet = false -- Flag to indicate if colors have been set in the current session
local colors = {} -- Initialize colors to an empty table

-- Function to prompt the user for custom colors and save them to a file
function promptAndSaveColors()
    --reaper.ShowConsoleMsg("promptAndSaveColors called\n")

    --reaper.ShowConsoleMsg("Prompting user for custom colors\n")

    local customColors = {}

    for i = 1, 5 do
        local colorSet = false
        while not colorSet do
            --reaper.ShowConsoleMsg("Select Custom Color " .. i .. ":\n")
            local r, g, b = getCustomColorRGB(1)
            if not (r and g and b) then
                local response = reaper.ShowMessageBox("Failed to select custom color " .. i .. ". Would you like to retry?", "Error", 3)
                if response == 6 then -- Retry
                    colorSet = false
                else
                    return -- Stop the function entirely if the user chooses not to retry
                end
            else
                table.insert(customColors, {r, g, b})
                colorSet = true
            end
        end
    end

    --reaper.ShowConsoleMsg("Custom colors selected\n")

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
        colors = customColors -- Assign the custom colors to the 'colors' variable
        reaper.ShowMessageBox("Rating colors set.", "Success", 0) -- Pop-up message for success
        colorsChanged = true -- Set flag to true to indicate colors have been successfully changed
        colorsSet = true -- Set flag to true to indicate colors have been set in the current session
        promptCalled = false -- Reset the promptCalled flag
        --reaper.ShowConsoleMsg("Colors changed and saved\n")
    else
        --reaper.ShowConsoleMsg("Failed to save custom colors to file.\n")
        colorsChanged = false -- Reset colorsChanged flag if saving fails
        --reaper.ShowConsoleMsg("Colors not changed\n")
    end 
end

-- Read custom colors from file
function readCustomColorsFromFile()
    local file_path = reaper.GetResourcePath() .. "\\CustomColors\\custom_colors.txt"
    local file = io.open(file_path, "r")
    if file then
        local customColors = {}
        for line in file:lines() do
            local r, g, b = line:match("(%d+),(%d+),(%d+)")
            if r and g and b then
                table.insert(customColors, {tonumber(r) / 255, tonumber(g) / 255, tonumber(b) / 255})
            end
        end
        file:close()
        return customColors
    else
        --reaper.ShowConsoleMsg("Failed to open custom colors file.\n")
        return nil
    end
end

-- Function to redraw the GUI with updated colors
function redrawGUIWithCustomColors()
    colors = readCustomColorsFromFile()
    if colors then
        createGUI() -- Reinitialize GUI with updated colors
        main() -- Start the main loop
        promptCalled = false -- Reset the promptCalled flag
        --reaper.ShowConsoleMsg("GUI redrawn with custom colors\n")
    else
        --reaper.ShowConsoleMsg("Failed to load custom colors.\n")
    end
end


-- Function to get screen dimensions
function getScreenDimensions()
    local handle = io.popen("wmic path Win32_VideoController get CurrentHorizontalResolution,CurrentVerticalResolution")
    local result = handle:read("*a")
    handle:close()

    local screenWidth, screenHeight = result:match("(%d+)%s+(%d+)")
    screenWidth = tonumber(screenWidth)
    screenHeight = tonumber(screenHeight)

    return screenWidth, screenHeight
end

local gui = {}

-- Function to create the GUI
function createGUI()
    -- Get screen dimensions
    local screenWidth, screenHeight = getScreenDimensions()
    
    -- Calculate window position
    local windowWidth = 550
    local windowHeight = 150
    gui.x = (screenWidth - windowWidth) / 2
    gui.y = (screenHeight - windowHeight) / 2

    gfx.init("Show and Set Rating Colors", windowWidth, windowHeight, 0, gui.x, gui.y)
end

-- Function to draw the red boxes with numbers (2x bigger)
function drawRedBoxes()
    local boxWidth = 60 -- Doubled the box width
    local boxHeight = 60 -- Doubled the box height
    local spacing = 10
    local totalBoxWidth = 5 * boxWidth + 4 * spacing
    local startX = (gfx.w - totalBoxWidth) / 2
    local startY = 20

    for i = 1, 5 do
        -- Draw colored box
        gfx.set(table.unpack(colors[i])) -- Set drawing color to custom color
        gfx.rect(startX + (boxWidth + spacing) * (i - 1), startY, boxWidth, boxHeight, true)

        -- Draw number
        gfx.set(0, 0, 0) -- Set drawing color to black
        gfx.x = startX + (boxWidth + spacing) * (i - 1) + (boxWidth - gfx.measurestr(tostring(i))) / 2
        gfx.y = startY + (boxHeight - gfx.texth) / 2
        gfx.drawstr(tostring(i))
    end
end

-- Function to draw the buttons
function drawButtons()
    local buttonWidth = 200
    local buttonHeight = 40
    local spacing = 10
    local totalButtonWidth = 2 * buttonWidth + spacing
    local startX = (gfx.w - totalButtonWidth) / 2
    local startY = 100 -- Adjusted startY

    -- Draw Close button
    gfx.set(0, 0, 0) -- Set drawing color to black
    gfx.rect(startX, startY, buttonWidth, buttonHeight, true) -- Draw black rectangle for button
    gfx.set(1, 1, 1) -- Set text color to white
    local textWidth = gfx.measurestr("Close")
    gfx.x = startX + (buttonWidth - textWidth) / 2
    gfx.y = startY + (buttonHeight - gfx.texth) / 2
    gfx.drawstr("Close")

    -- Draw Change Rating Colors button
    gfx.set(0, 0, 0) -- Set drawing color to black
    gfx.rect(startX + buttonWidth + spacing, startY, buttonWidth, buttonHeight, true) -- Draw black rectangle for button
    gfx.set(1, 1, 1) -- Set text color to white
    textWidth = gfx.measurestr("Change Rating Colors")
    gfx.x = startX + buttonWidth + spacing + (buttonWidth - textWidth) / 2
    gfx.y = startY + (buttonHeight - gfx.texth) / 2
    gfx.drawstr("Change Rating Colors")
end

local promptCalled = false -- Flag to indicate if the prompt function has been called

local lastClickTime = 0
local debounceDelay = 0.5 -- Adjust this value as needed

-- Function to handle button clicks
function onClick(x, y)
    -- Handle button clicks only if GUI is initialized
    if not gfx.w or not gfx.h then return end

    local currentTime = reaper.time_precise()
    if currentTime - lastClickTime < debounceDelay then
        return -- Ignore subsequent clicks within debounceDelay time
    end
    lastClickTime = currentTime

    --reaper.ShowConsoleMsg("Mouse clicked at x: " .. x .. ", y: " .. y .. "\n") -- Debug statement

    local buttonWidth = 200
    local buttonHeight = 40
    local spacing = 10
    local totalButtonWidth = 2 * buttonWidth + spacing
    local startX = (gfx.w - totalButtonWidth) / 2
    local startY = 100 -- Adjusted startY

    -- Check if Close button was clicked
    if x >= startX and x <= startX + buttonWidth and
        y >= startY and y <= startY + buttonHeight then
        --reaper.ShowConsoleMsg("Close button clicked\n") -- Debug statement
        gfx.quit() -- Close the GUI if Close button is clicked
        return
    end

    -- Check if Change Rating Colors button was clicked
    if x >= startX + buttonWidth + spacing and x <= startX + 2 * buttonWidth + spacing and
        y >= startY and y <= startY + buttonHeight then
        --reaper.ShowConsoleMsg("Change Rating Colors button clicked\n") -- Debug statement
        --reaper.ShowConsoleMsg("Before promptCalled: " .. tostring(promptCalled) .. "\n") -- Debug statement
        if not promptCalled then
            --reaper.ShowConsoleMsg("promptAndSaveColors called\n") -- Debug statement
            promptAndSaveColors() -- Prompt the user to select custom colors
            --reaper.ShowConsoleMsg("After promptCalled: " .. tostring(promptCalled) .. "\n") -- Debug statement
            if colorsChanged then
                redrawGUIWithCustomColors() -- Refresh GUI with updated colors only if colors have changed
            end
        else
            --reaper.ShowConsoleMsg("Prompt already called\n") -- Debug statement
        end
        return
    end
end

-- Function to handle mouse events
function handleMouseEvents()
    if gfx.mouse_cap & 1 == 1 then -- Check if left mouse button is pressed
        if not mousePressed then -- Only handle mouse press events
            mousePressed = true
            local x = gfx.mouse_x
            local y = gfx.mouse_y
            onClick(x, y) -- Handle mouse click event
        end
    else
        mousePressed = false
    end
end

-- Main function
function main()
    gfx.clear = 0xFFFFFF -- Set background color to white
    drawRedBoxes() -- Draw the colored boxes with numbers
    drawButtons() -- Draw the buttons
    gfx.update()

    handleMouseEvents() -- Handle mouse events

   reaper.defer(function() main() end)
   
end

-- Entry point
local customColors = readCustomColorsFromFile() -- Read custom colors from file
if customColors then
    colors = customColors -- Assign the custom colors to the 'colors' variable
    colorsSet = true -- Set flag to true to indicate colors have been set in the current session
    createGUI() -- Initialize GUI
    main() -- Start the main loop
else
    local response = reaper.ShowMessageBox("No custom colors found. Would you like to set custom colors now?", "No Custom Colors", 3)
    if response == 6 then -- User clicked "Yes"
        promptAndSaveColors() -- Prompt the user to set custom colors
        redrawGUIWithCustomColors() -- Refresh GUI with updated colors
    else
        return -- Stop the script
    end
end

