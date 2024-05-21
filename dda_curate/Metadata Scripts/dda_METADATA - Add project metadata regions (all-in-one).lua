-- @version 1.0.0
-- @description dda_METADATA - Add project metadata regions (all-in-one)
-- @about Adds a single region for each of the following: project name, artist, publisher, comments/notes, copyright. These regions will be used to fill metadata when exporting.
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT—

-- Function to create a single region around all selected items and rename it based on user input
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

    -- Get current year
    local year = os.date("%Y")

    -- Get user inputs for project/library name, project artist name, project publisher name, comments/notes, and copyright
    local retval, userInput = reaper.GetUserInputs("Rename Region", 5, "Project/Library Name:,Project Artist (name):,Project Publisher (company):,Comments/Notes:,Copyright:,extrawidth=200", ",,,,© " .. year)

    if retval then
        -- Split user input into separate fields
        local inputs = {}
        local startIdx = 1
        for i = 1, #userInput do
            if string.sub(userInput, i, i) == "," then
                table.insert(inputs, string.sub(userInput, startIdx, i - 1))
                startIdx = i + 1
            elseif i == #userInput then
                table.insert(inputs, string.sub(userInput, startIdx))
            end
        end

        -- Rename region with project/library name
        if inputs[1] ~= "" then
            reaper.AddProjectMarker2(0, true, startTime, endTime, "library=" .. inputs[1], -1, 0)
        end

        -- Rename region with project artist name
        if inputs[2] ~= "" then
            reaper.AddProjectMarker2(0, true, startTime, endTime, "artist=" .. inputs[2], -1, 0)
        end

        -- Rename region with project publisher name
        if inputs[3] ~= "" then
            reaper.AddProjectMarker2(0, true, startTime, endTime, "publisher=" .. inputs[3], -1, 0)
        end

        -- Rename region with comments/notes
        if inputs[4] ~= "" then
            reaper.AddProjectMarker2(0, true, startTime, endTime, "comments=" .. inputs[4], -1, 0)
        end

        -- Rename region with copyright information
        if inputs[5] ~= nil and inputs[5] ~= "" then
            reaper.AddProjectMarker2(0, true, startTime, endTime, "copyright=" .. inputs[5], -1, 0)
        end
        
    end
end

-- Main script execution
reaper.Undo_BeginBlock()

-- Create single region around selected items and rename based on user input
createSingleRegionAndRename()

reaper.Undo_EndBlock("Create Single Region and Rename", -1)
