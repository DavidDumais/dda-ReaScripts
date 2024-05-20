-- @noindex
-- ReaScript Name: dda_METADATA - Create individual regions for selected items and rename region using item notes
-- description: Creates individual regions for all selected items and renames each region using respective items notes. BEst used for description metadata.
-- author: David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT—

-- Function to create regions around selected items
function createRegionsAroundItems()
    local existingRegions = {}
    local numExistingRegions = reaper.CountProjectMarkers(0)
    for i = 0, numExistingRegions - 1 do
        local _, isRegion, _, start, endPos, name = reaper.EnumProjectMarkers(i)
        if isRegion then
            existingRegions[name .. "_" .. start .. "_" .. endPos] = true
        end
    end
    
    local numSelectedItems = reaper.CountSelectedMediaItems(0)
    --reaper.ShowConsoleMsg("Number of selected items: " .. numSelectedItems .. "\n")

    local numRegionsCreated = 0

    for i = 0, numSelectedItems - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        local itemPos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        
        local _, notes = reaper.GetSetMediaItemInfo_String(item, "P_NOTES", "", false)
        
        --reaper.ShowConsoleMsg("Item " .. (i + 1) .. " notes: " .. notes .. "\n")

        if notes ~= "" then
            -- Check if a region with the same name and position already exists
            if not existingRegions[notes .. "_" .. itemPos .. "_" .. itemPos + itemLength] then
                -- Add a new region
                local regionIndex = reaper.AddProjectMarker2(0, true, itemPos, itemPos + itemLength, notes, -1, 0)
                if regionIndex ~= -1 then
                    -- Set render matrix to 'Master Mix'
                    reaper.SetRegionRenderMatrix(0, regionIndex, reaper.GetMasterTrack(0), 1)
                    existingRegions[notes .. "_" .. itemPos .. "_" .. itemPos + itemLength] = true
                    numRegionsCreated = numRegionsCreated + 1
                    --reaper.ShowConsoleMsg("Region '" .. notes .. "' created.\n")
                else
                    --reaper.ShowConsoleMsg("Failed to add region '" .. notes .. "'.\n")
                end
            else
                --reaper.ShowConsoleMsg("Region '" .. notes .. "' already exists.\n")
            end
        else
            --reaper.ShowConsoleMsg("Selected item notes are empty.\n")
        end
    end

    --reaper.ShowConsoleMsg("Number of regions created: " .. numRegionsCreated .. "\n")
end

-- Main script execution
reaper.Undo_BeginBlock()

-- Create regions around selected items
createRegionsAroundItems()

reaper.Undo_EndBlock("Create Regions Around Items", -1)

