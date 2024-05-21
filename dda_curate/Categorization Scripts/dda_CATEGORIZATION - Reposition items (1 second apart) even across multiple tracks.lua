-- @version 1.0.0
-- @description: dda_CATEGORIZATION - Reposition items (1 second apart) even across multiple tracks
-- @about: Repositions all selected items to be 1 second apart from each other even if across multiple tracks
-- @author: David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Table to store initial positions of selected items
local initialPositions = {}

-- Function to get the end time of an item
function getItemEndTime(item)
    return reaper.GetMediaItemInfo_Value(item, "D_POSITION") + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
end

-- Function to find the smallest position of all selected items
function findSmallestPosition()
    local smallestPosition = math.huge
    local selectedItemCount = reaper.CountSelectedMediaItems(0)
    if selectedItemCount == 0 then
        return nil
    end

    for i = 0, selectedItemCount - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        if position < smallestPosition then
            smallestPosition = position
        end
    end

    return smallestPosition
end

-- Main function to reposition selected items
function repositionSelectedItems()
    local selectedItemCount = reaper.CountSelectedMediaItems(0)
    if selectedItemCount == 0 then
        return
    end

    -- Set the item separation length to 1 second (1000 milliseconds)
    local itemSeparationLength = 1000

    -- Find the smallest position of all selected items
    local smallestPosition = findSmallestPosition()
    if not smallestPosition then
        return
    end

    -- Initialize variables
    local prevEndTime = smallestPosition

    -- Loop through selected items
    for i = 0, selectedItemCount - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)

        -- Move item to new position
        reaper.SetMediaItemInfo_Value(item, "D_POSITION", prevEndTime)

        -- Update previous end time for the next iteration
        prevEndTime = getItemEndTime(item) + itemSeparationLength / 1000
    end
end

-- Function to store initial positions of selected items
function storeInitialPositions()
    local selectedItemCount = reaper.CountSelectedMediaItems(0)
    if selectedItemCount == 0 then
        return
    end

    for i = 0, selectedItemCount - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        initialPositions[item] = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
    end
end

-- Run the main function
reaper.Undo_BeginBlock()

-- Store initial positions if not already stored
if not next(initialPositions) then
    storeInitialPositions()
end

repositionSelectedItems()
reaper.Undo_EndBlock("Reposition selected items with specified separation length", -1)

