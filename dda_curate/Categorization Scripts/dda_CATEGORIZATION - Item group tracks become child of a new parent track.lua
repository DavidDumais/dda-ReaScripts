-- @version 1.0.0
-- @description dda_CATEGORIZATION - Item group tracks become child of a new parent track
-- @about Moves grouped items to a new parent track. Grouped item tracks become child tracks of newly created parent track.
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Function to select all tracks of selected items
function selectTracksOfSelectedItems()
    reaper.Main_OnCommand(40297, 0) -- Unselect all tracks
    local numSelectedItems = reaper.CountSelectedMediaItems(0)
    if numSelectedItems > 0 then
        for i = 0, numSelectedItems - 1 do
            local selectedItem = reaper.GetSelectedMediaItem(0, i)
            local track = reaper.GetMediaItem_Track(selectedItem)
            reaper.SetTrackSelected(track, true)
        end
    end
end

-- Function to run command ID 42785
function runCommand42785()
    reaper.Main_OnCommand(42785, 0)
end

-- Function to select parent track
function selectParentTrack()
    local numTracks = reaper.CountSelectedTracks(0)
    if numTracks > 0 then
        local lastTrack = reaper.GetSelectedTrack(0, numTracks - 1) -- Get the last selected track
        local parentTrack = reaper.GetParentTrack(lastTrack) -- Get parent track
        if parentTrack then
            reaper.SetTrackSelected(parentTrack, true)
        end
    end
end

-- Main function
function main()
    reaper.Undo_BeginBlock()
    reaper.PreventUIRefresh(1)
    selectTracksOfSelectedItems()
    runCommand42785()
    selectParentTrack()
    reaper.PreventUIRefresh(-1)
    reaper.Undo_EndBlock("Your Script Name", -1)
end

-- Run main function
main()

