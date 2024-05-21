-- @version 1.0.0
-- @description dda_CATEGORIZATION - Copy paste item notes
-- @about copies item notes from a single item and pastes text to all selected items
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

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

local copiedNotes = ""
local displayText = ""

-- Function to update the display text
function updateDisplayText()
    -- Truncate copiedNotes for GUI display
    local truncatedNotes = copiedNotes
    if #truncatedNotes > 30 then
        truncatedNotes = string.sub(truncatedNotes, 1, 30) .. "..."
    end
    displayText = "Copied Notes: " .. truncatedNotes
end

-- Function to copy notes from selected item
function copyNotes()
    local numSelectedItems = reaper.CountSelectedMediaItems(0)
    if numSelectedItems == 1 then
        local selectedItem = reaper.GetSelectedMediaItem(0, 0)
        if selectedItem then
            local success, notes = reaper.GetSetMediaItemInfo_String(selectedItem, "P_NOTES", "", false)
            if success then
                copiedNotes = notes
                --reaper.ShowConsoleMsg("Notes copied: " .. tostring(copiedNotes) .. "\n")
            else
                reaper.ShowMessageBox("Failed to copy notes.", "Copy Notes", 0)
                --reaper.ShowConsoleMsg("Failed to copy notes.\n")
            end
        else
            reaper.ShowMessageBox("Please select an item to copy notes from.", "Copy Notes", 0)
            --reaper.ShowConsoleMsg("No item selected to copy notes from.\n")
        end
    else
        reaper.ShowMessageBox("Please select only one item to copy notes from.", "Copy Notes", 0)
        --reaper.ShowConsoleMsg("More than one item selected.\n")
    end
    updateDisplayText()
end

-- Function to paste notes to selected items
function pasteNotesToSelectedItems()
    local numSelectedItems = reaper.CountSelectedMediaItems(0)
    if numSelectedItems > 0 then
        for i = 0, numSelectedItems - 1 do
            local selectedItem = reaper.GetSelectedMediaItem(0, i)
            if selectedItem then
                reaper.GetSetMediaItemInfo_String(selectedItem, "P_NOTES", copiedNotes, true)
            end
        end
        --reaper.ShowConsoleMsg("Notes pasted to selected items.\n")
    else
        reaper.ShowMessageBox("No items selected to paste notes to.", "Paste Notes", 0)
        --reaper.ShowConsoleMsg("No items selected to paste notes to.\n")
    end
    updateDisplayText()
end

-- Function to paste notes
function pasteNotes()
    if copiedNotes ~= "" then
        pasteNotesToSelectedItems()
    else
        reaper.ShowMessageBox("No notes copied to paste.", "Paste Notes", 0)
        --reaper.ShowConsoleMsg("No notes copied to paste.\n")
    end
end

-- Function to draw the GUI
function createGUI()
    -- Get screen dimensions
    local screenWidth, screenHeight = getScreenDimensions()
    
    -- Calculate window position
    local windowWidth = 300
    local windowHeight = 180
    local guiX = (screenWidth - windowWidth) / 2
    local guiY = (screenHeight - windowHeight) / 2

    gfx.init("Notes Actions", windowWidth, windowHeight, 0, guiX, guiY)
    gfx.setfont(1, "Arial", 16)
end

-- Function to draw the buttons
function drawButtons()
    -- Draw copy button
    gfx.set(0.8, 0.8, 0.8)
    gfx.rect(10, 20, 80, 30, true)
    gfx.set(0, 0, 0)
    gfx.x = 30
    gfx.y = 30
    gfx.drawstr("Copy")
    
    -- Draw paste button
    gfx.set(0.8, 0.8, 0.8)
    gfx.rect(110, 20, 80, 30, true)
    gfx.set(0, 0, 0)
    gfx.x = 130
    gfx.y = 30
    gfx.drawstr("Paste")
    
    -- Draw close button
    gfx.set(0.8, 0.8, 0.8)
    gfx.rect(210, 20, 80, 30, true)
    gfx.set(0, 0, 0)
    gfx.x = 230
    gfx.y = 30
    gfx.drawstr("Close")
    
    -- Draw display text area
    gfx.set(0, 0, 0) -- Set text color to black
    gfx.x = 10
    gfx.y = 80
    gfx.drawstr(displayText)
end

-- Function to handle button clicks
function onClick(x, y)
    if x >= 10 and x <= 90 and y >= 20 and y <= 50 then
        copyNotes()
    elseif x >= 110 and x <= 190 and y >= 20 and y <= 50 then
        pasteNotes()
    elseif x >= 210 and x <= 290 and y >= 20 and y <= 50 then
        gfx.quit() -- Close the GUI window
    end
end

-- Main function
function main()
    if gfx.mouse_cap & 1 == 1 then
        local x = gfx.mouse_x
        local y = gfx.mouse_y
        onClick(x, y) -- Check for button clicks
    end

    gfx.clear = 0xFFFFFF -- Set background color to white
    drawButtons() -- Draw the buttons
    gfx.update()

    if gfx.getchar() >= 0 then
        reaper.defer(main)
    end
end

-- Entry point
createGUI()
main()

