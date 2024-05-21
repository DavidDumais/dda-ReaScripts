-- @version 1.0.0
-- @description: dda_CATEGORIZATION - Move item to child track within parent folder
-- @about: Moves selected items to a child track with the parent folder track while keeping selected items positions
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Function to get the track name
local function getTrackName(track)
    local _, trackName = reaper.GetTrackName(track, "")
    return trackName or ""
end

-- Function to get the parent folder track of a given track
local function getParentFolderTrack(track)
    local parent = reaper.GetParentTrack(track)
    if parent ~= nil then
        return getParentFolderTrack(parent)  -- Recursively get the parent folder track
    else
        return track  -- This is the topmost parent track, which is the folder track
    end
end

-- Function to get all child tracks of a parent track
local function getAllChildTracks(parentTrack, allChildTracks)
    allChildTracks = allChildTracks or {}  -- Initialize allChildTracks if not provided

    local numTracks = reaper.CountTracks(0)
    for i = 0, numTracks - 1 do
        local track = reaper.GetTrack(0, i)
        local parent = reaper.GetParentTrack(track)
        if parent == parentTrack then
            table.insert(allChildTracks, track)
            -- Recursively get child tracks of this track
            getAllChildTracks(track, allChildTracks)
        end
    end

    return allChildTracks
end

-- Function to move items to the selected child track
local function moveItemsToTrack(selectedIndex, childTracks, selectedItems)
    for _, selectedItem in ipairs(selectedItems) do
        local targetTrack = childTracks[selectedIndex]
        if targetTrack then
            local selectedItemPosition = reaper.GetMediaItemInfo_Value(selectedItem, "D_POSITION")
            reaper.MoveMediaItemToTrack(selectedItem, targetTrack)
            reaper.SetMediaItemInfo_Value(selectedItem, "D_POSITION", selectedItemPosition)
            local targetTrackName = getTrackName(targetTrack)
            --reaper.ShowConsoleMsg("Moved item to track '" .. targetTrackName .. "' at position " .. selectedItemPosition .. "\n")
        else
            --reaper.ShowConsoleMsg("Failed to move item. Invalid target track.\n")
        end
    end
end

-- Function to print child tracks with buttons for the popup window
local function printChildTracksWithButtons(childTracks)
    local buttonLabels = {}
    for i, track in ipairs(childTracks) do
        local trackName = getTrackName(track)
        table.insert(buttonLabels, i .. ": " .. trackName)
    end
    return table.concat(buttonLabels, ", ")
end

-- Get the number of selected items
local numSelectedItems = reaper.CountSelectedMediaItems(0)
--reaper.ShowConsoleMsg("Number of selected items: " .. numSelectedItems .. "\n")

-- If no items are selected, print message and exit
if numSelectedItems == 0 then
    --reaper.ShowConsoleMsg("No items selected.\n")
    return
end

-- Get the parent track from the first selected item
local firstSelectedItem = reaper.GetSelectedMediaItem(0, 0)
local parentTrack = reaper.GetMediaItemTrack(firstSelectedItem)

-- Get the parent folder track of the selected item's track
local parentFolderTrack = getParentFolderTrack(parentTrack)
local parentFolderTrackName = getTrackName(parentFolderTrack)
--reaper.ShowConsoleMsg("Parent Folder Track: " .. parentFolderTrackName .. "\n")

-- Get all child tracks within the parent folder (including child folders)
local childTracks = getAllChildTracks(parentFolderTrack)

-- Print all child tracks to the Reaper console for debugging
--reaper.ShowConsoleMsg("Child Tracks within the Selected Folder:\n")
for i, track in ipairs(childTracks) do
    local trackName = getTrackName(track)
    --reaper.ShowConsoleMsg(i .. ": " .. trackName .. "\n")
end

-- If no child tracks are found, show error message in a popup window
if #childTracks == 0 then
    reaper.ShowMessageBox("No child tracks found.", "Error", 0)
    return
end

-- Prepare the track names with buttons for the GUI window
local trackNamesWithButtons = printChildTracksWithButtons(childTracks)

-- Show GUI window with track list buttons and get the selected track indices
local userInputOK, userInputResult = reaper.GetUserInputs("Select the target track", #childTracks, trackNamesWithButtons, "")
if userInputOK then
    -- Split the user input into separate values
    local selectedIndices = {}
    for index in userInputResult:gmatch("(%d+)") do
        table.insert(selectedIndices, tonumber(index))
    end

    -- Check if the selected indices are valid
    local validSelection = true
    for _, index in ipairs(selectedIndices) do
        if index < 1 or index > #childTracks then
            validSelection = false
            break
        end
    end

    if validSelection then
        local selectedItems = {}
        for i = 0, numSelectedItems - 1 do
            local selectedItem = reaper.GetSelectedMediaItem(0, i)
            table.insert(selectedItems, selectedItem)
        end

        for _, selectedIndex in ipairs(selectedIndices) do
            moveItemsToTrack(selectedIndex, childTracks, selectedItems)
        end
    else
        --reaper.ShowConsoleMsg("Invalid selection.\n")
    end
else
    --reaper.ShowConsoleMsg("No target track selected.\n")
end

