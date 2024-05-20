-- @noindex
-- ReaScript Name: dda_METADATA - Add project copyright metadata region to selected items
-- description: Adds a single region around all selected items and renames the region to user defined text. This region will be used to fill the copyright message and copyright holder metadata when exporting.
-- author: David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT—

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

    local year = os.date("%Y")  -- Get current year
    local retval, userInput = reaper.GetUserInputs("Rename Region", 2, "Year:,Designer/Company:,extrawidth=200", year .. ",")

    if retval then
        local inputs = {}  -- Split user input into separate fields
        for input in userInput:gmatch("[^,]+") do
            table.insert(inputs, input)
        end
        local regionName = "copyright=© " .. inputs[1] .. " "
        if inputs[2] then
            regionName = regionName .. inputs[2]
        end
        reaper.AddProjectMarker2(0, true, startTime, endTime, regionName, -1, 0)
    end
end

-- Main script execution
reaper.Undo_BeginBlock()

-- Create a single region around all selected items and rename based on user input with 'artist=' prepended
createSingleRegionAndRename()

reaper.Undo_EndBlock("Create Single Region and Rename", -1)

