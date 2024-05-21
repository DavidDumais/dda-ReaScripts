-- @version 1.0.0
-- @description: dda_CATEGORIZATION - Move item(s) to a new child track of selected track
-- @about: Moves selected items to a new child track. The selected track becomes the parent track. User is prompted to rename newly created child track.
-- @author: David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Function to check if only one track is selected
function isSingleTrackSelected()
    local selTracks = reaper.CountSelectedTracks(0)
    return selTracks == 1
end

-- Function to get selected item's name and position
function getSelectedItemsInfo()
    local selectedItemsInfo = {}
    local track = reaper.GetSelectedTrack(0, 0) -- Assuming only one track selected

    if track then
        local trackName = reaper.GetTrackName(track)
        local numItems = reaper.CountSelectedMediaItems(0)
        
        for i = 0, numItems - 1 do
            local item = reaper.GetSelectedMediaItem(0, i)
            local itemName = tostring(reaper.GetTakeName(reaper.GetActiveTake(item)))
            local itemPosition = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            table.insert(selectedItemsInfo, {name = itemName, position = itemPosition, track = trackName})
        end
    end

    return selectedItemsInfo
end

-- Function to print selected items info to console
function printSelectedItemsInfo(selectedItemsInfo)
    for _, itemInfo in ipairs(selectedItemsInfo) do
        local message = string.format("Item Name: %s, Position: %.3f, Track: %s", itemInfo.name, itemInfo.position, itemInfo.track)
        --reaper.ShowConsoleMsg(message .. "\n")
    end
end

-- Main function
function main()
    -- Check if only one track is selected
    if not isSingleTrackSelected() then
        reaper.ShowMessageBox("Please select only one track.", "Error", 0)
        return
    end

    -- Store the originally selected track
    local originalTrack = reaper.GetSelectedTrack(0, 0)

    -- Begin undo block
    reaper.Undo_BeginBlock()

    -- Run command ID 42453
    reaper.Main_OnCommand(42453, 0)

    -- Run command ID 42696
    reaper.Main_OnCommand(42696, 0)
    
    -- Run command ID _XENAKIOS_SELNEXTTRACK
    reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELNEXTTRACK"), 0)
    
    -- Check if there's only one selected track
    local num_selected_tracks = reaper.CountSelectedTracks(0)
    if num_selected_tracks ~= 1 then
        reaper.ShowMessageBox("Please select exactly one track.", "Error", 0)
        undoScript()
        return
    end
    
    -- Get the selected track
    local track = reaper.GetSelectedTrack(0, 0)
    
    -- Get the number of items on the selected track
    local num_items = reaper.CountTrackMediaItems(track)
    
    -- If there are no items, show an error message
    if num_items == 0 then
        reaper.ShowMessageBox("The selected track contains no items.", "Error", 0)
        undoScript()
        return
    end
    
    -- Iterate through each item on the track
    for i = 0, num_items - 1 do
        -- Get the item
        local item = reaper.GetTrackMediaItem(track, i)
        
        -- Check if the item is selected
        local item_selected = reaper.GetMediaItemInfo_Value(item, "B_UISEL") == 1
        
        -- Invert the selection
        reaper.SetMediaItemInfo_Value(item, "B_UISEL", item_selected and 0 or 1)
    end
    
    -- Update the arrange view
    reaper.UpdateArrange()

    -- Run command ID 40117
    reaper.Main_OnCommand(40117, 0)

    -- Get the number of selected tracks
    numSelectedTracks = reaper.CountSelectedTracks(0)
    
    -- Check if at least one track is selected
    if numSelectedTracks > 0 then
        -- Get the first selected track
        selectedTrack = reaper.GetSelectedTrack(0, 0)
        
        -- Prompt the user for a new track name
        retval, newTrackName = reaper.GetUserInputs("Rename Track", 1, "New Track Name:", "")
        
        -- Check if the user provided a new track name
        if retval then
            -- Rename the selected track with the provided name
            reaper.GetSetMediaTrackInfo_String(selectedTrack, "P_NAME", newTrackName, true)
        else
            -- If the user canceled, set the flag to true
            undoScriptFlag = true
        end
    else
        -- If no track is selected, show a message box
        reaper.ShowMessageBox("Please select a track to rename.", "No Track Selected", 0)
        undoScriptFlag = true
    end
    
    -- End undo block
    reaper.Undo_EndBlock("Script Operations", -1)
    
    -- Deselect the child track
    reaper.SetTrackSelected(track, false)
    
    -- Re-select the original track
    reaper.SetTrackSelected(originalTrack, true)

    -- Check if undo flag is set and undo the script
    if undoScriptFlag then
        undoScript()
    end
end

-- Function to undo the entire script
function undoScript()
    reaper.Undo_DoUndo2(0)
end

-- Run main function
main()

