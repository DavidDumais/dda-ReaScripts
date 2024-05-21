-- @version 1.0.0
-- @description: dda_ITEM - Selected items information printout
-- @about: Prints out various information related to the selected items in project
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Function to run a specified command ID
function runCommandByID(commandID)
    reaper.Main_OnCommandEx(reaper.NamedCommandLookup(commandID), 0, 0)
end

-- Function to check if a media item is stereo or mono
function CheckItemFormat(item)
    local take = reaper.GetActiveTake(item)
    if take ~= nil then
        local source = reaper.GetMediaItemTake_Source(take)
        if source ~= nil then
            local numChannels = reaper.GetMediaSourceNumChannels(source)
            return numChannels > 1 -- Returns true if stereo, false if mono
        end
    end
    return false -- Default to mono if source not found
end

-- Function to extract the file extension from a path
function GetFileExtension(path)
    return path:match("%.([^%.]+)$") -- Match everything after the last dot
end

-- Function to count and display the number of selected items
function countSelectedItems()
    local num_items = reaper.CountSelectedMediaItems(0)
    return num_items
end

-- Function to calculate the total length of selected items
function CalculateTotalLength()
    local selectedItems = reaper.CountSelectedMediaItems(0)
    local totalLength = 0
    
    for i = 0, selectedItems - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        if item then
            local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            totalLength = totalLength + itemLength
        end
    end

    return totalLength
end

-- Function to format time from seconds to hh:mm:ss format
function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local remainingSeconds = math.floor(seconds % 60)

    return string.format("%02d:%02d:%02d", hours, minutes, remainingSeconds)
end

-- Function to unselect muted items and print selected/muted item counts
function unselectMutedItems()
    -- Get the total number of selected items
    local numSelectedItems = reaper.CountSelectedMediaItems(0)
    
    -- Initialize counters for muted items and formats
    local numMutedItems = 0
    local monoCount = 0
    local stereoCount = 0
    
    -- Loop through each selected item in reverse order
    for i = numSelectedItems - 1, 0, -1 do
        -- Get the selected item
        local selectedItem = reaper.GetSelectedMediaItem(0, i)
        
        -- Check if the item is muted
        local isMuted = reaper.GetMediaItemInfo_Value(selectedItem, "B_MUTE")
        
        -- If the item is muted, increase the muted item counter and unselect it
        if isMuted == 1 then
            numMutedItems = numMutedItems + 1
            reaper.SetMediaItemSelected(selectedItem, false)
        else
            -- Check if the item is stereo or mono and update counters
            local isStereo = CheckItemFormat(selectedItem)
            if isStereo then
                stereoCount = stereoCount + 1
            else
                monoCount = monoCount + 1
            end
        end
    end
    
    -- Return the counts for further processing
    return numMutedItems, monoCount, stereoCount
end

-- Function to check the file type of a media item
function CheckItemType(item)
    local take = reaper.GetActiveTake(item)
    if take ~= nil then
        local source = reaper.GetMediaItemTake_Source(take)
        if source ~= nil then
            local sourcePath = reaper.GetMediaSourceFileName(source, "")
            local fileType = GetFileExtension(sourcePath)
            if fileType ~= nil then
                fileType = fileType:upper() -- Convert to uppercase for consistency
                return fileType -- Return the file type
            end
        end
    end
    return "" -- Return empty string if file type not found
end

-- Function to count take markers using actions for a specific item
function countTakeMarkersWithActions(item)
    -- Initialize variables
    local num_take_markers = 0
    local num_command_42394 = 0
    
    -- Get item start and end positions
    local item_start = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    local item_end = item_start + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
    
    -- Select the specific item
    reaper.SelectAllMediaItems(0, false)
    reaper.SetMediaItemSelected(item, true)
    
    -- Split item under cursor
    reaper.Main_OnCommand(41173, 0)
    
    -- Move edit cursor to the first take marker
    local prev_position = reaper.GetCursorPosition()
    num_command_42394 = num_command_42394 + 1 -- Increment command count for initial command
    
    -- Check if cursor is already at the end of the item
    if prev_position < item_end then
        while true do
            -- Execute command to move to the next take marker
            reaper.Main_OnCommand(42394, 0) -- Move to next take marker
            num_command_42394 = num_command_42394 + 1 -- Increment command count
            
            local cur_position = reaper.GetCursorPosition()
            if cur_position > prev_position and cur_position < item_end then
                num_take_markers = num_take_markers + 1
            else
                break -- Cursor didn't move or went beyond item end time, stop counting
            end
            prev_position = cur_position
        end
    end
    
    return num_take_markers, num_command_42394
end

-- Function to print take markers for each selected item
function printTakeMarkers()
    local total_take_markers = 0
    local total_command_42394 = 0
    
    -- Get the number of selected items and store their indices
    local selected_items_indices = {}
    local num_selected_items = reaper.CountSelectedMediaItems(0)
    if num_selected_items > 0 then
        for i = 0, num_selected_items - 1 do
            selected_items_indices[i] = reaper.GetSelectedMediaItem(0, i)
        end
    end
    
    -- Iterate through selected items
    for i = 0, num_selected_items - 1 do
        local item = selected_items_indices[i]
        if item then
            local take = reaper.GetActiveTake(item)
            if take then
                local num_take_markers, num_command_42394 = countTakeMarkersWithActions(item)
                total_take_markers = total_take_markers + num_take_markers
                total_command_42394 = total_command_42394 + num_command_42394
            else
                reaper.ShowConsoleMsg("Error: No active take found for item " .. (i + 1) .. "\n")
            end
        end
    end
    
    -- Return total take markers for further processing
    return total_take_markers
end

-- Function to store selected items and cursor position
function storeSelectionAndCursor()
    local selectedItems = {}
    local numSelectedItems = reaper.CountSelectedMediaItems(0)
    for i = 0, numSelectedItems - 1 do
        selectedItems[i + 1] = reaper.GetSelectedMediaItem(0, i)
    end
    
    local cursorPos = reaper.GetCursorPosition()
    
    return selectedItems, cursorPos
end

-- Function to restore selected items and cursor position
function restoreSelectionAndCursor(selectedItems, cursorPos)
    reaper.SelectAllMediaItems(0, false)
    for _, item in ipairs(selectedItems) do
        reaper.SetMediaItemSelected(item, true)
    end
    reaper.SetEditCurPos(cursorPos, true, true)
end

-- Main function
function Main()
    -- Store selected items and cursor position
    local selectedItems, cursorPos = storeSelectionAndCursor()
    
    -- Clear the console before displaying new information
    reaper.ClearConsole()
    
    -- Unselect muted items and get counts
    local numMutedItems, monoCount, stereoCount = unselectMutedItems()
    
    -- Count the number of selected items
    local numItems = countSelectedItems()
    
    -- Calculate total length of selected items
    local totalLength = CalculateTotalLength()
    
    -- Convert total length to minutes
    local totalLengthMinutes = totalLength / 60
    
    -- Convert total length to hh:mm:ss format
    local formattedTime = FormatTime(totalLength)
    
    -- Display the information
    reaper.ShowConsoleMsg(string.format("Number of selected unmuted items: %d\n", numItems))
    reaper.ShowConsoleMsg(string.format("Total Length of Selected Items (Seconds): %.2f seconds\n", totalLength))
    reaper.ShowConsoleMsg(string.format("Total Length of Selected Items (Minutes): %.2f minutes\n", totalLengthMinutes))
    reaper.ShowConsoleMsg(string.format("Total Length of Selected Items (hh:mm:ss): %s\n", formattedTime))
    reaper.ShowConsoleMsg(string.format("Muted items: %d\n", numMutedItems))
    reaper.ShowConsoleMsg(string.format("Mono items: %d\n", monoCount))
    reaper.ShowConsoleMsg(string.format("Stereo items: %d\n", stereoCount))
    
    -- Print take markers for each selected item
    local totalTakeMarkers = printTakeMarkers()
    reaper.ShowConsoleMsg(string.format("Total Take Markers for all selected items: %d\n", totalTakeMarkers))
    
    -- Restore selected items and cursor position
    restoreSelectionAndCursor(selectedItems, cursorPos)
end

-- Run the main function
Main()

