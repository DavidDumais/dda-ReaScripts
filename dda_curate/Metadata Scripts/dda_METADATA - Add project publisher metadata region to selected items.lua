-- @version 1.0.0
-- @description: dda_METADATA - Add project publisher metadata region to selected items
-- @about: Adds a single region around all selected items and renames the region to user defined text. This region will be used to fill the publisher metadata when exporting.
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

-- Function to create a single region around all selected items and rename it based on user input with 'artist=' prepended
function createSingleRegionAndRename()
    -- Check if any items are selected
    if reaper.CountSelectedMediaItems(0) == 0 then
    reaper.ShowMessageBox("Please select items.", "No Items Selected", 0)
        return -- Exit the function if no items are selected
    end
    
    local startTime, endTime = math.huge, 0

    for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local itemStartTime = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local itemEndTime = itemStartTime + reaper.GetMediaItemInfo_Value(item, "D_LENGTH")

        if itemStartTime < startTime then
            startTime = itemStartTime
        end
        if itemEndTime > endTime then
            endTime = itemEndTime
        end
    end

    local retval, userInput = reaper.GetUserInputs("Rename Region", 1, "Project Publisher (company):,extrawidth=200", "")

    if retval then
        local regionName = "publisher=" .. userInput
        reaper.AddProjectMarker2(0, true, startTime, endTime, regionName, -1, 0)
    end
end

-- Main script execution
reaper.Undo_BeginBlock()

-- Create a single region around all selected items and rename based on user input with 'artist=' prepended
createSingleRegionAndRename()

reaper.Undo_EndBlock("Create Single Region and Rename", -1)

