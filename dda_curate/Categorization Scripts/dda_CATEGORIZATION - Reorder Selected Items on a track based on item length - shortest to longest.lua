-- @version 1.0.0
-- @description: dda_CATEGORIZATION - Reorder Selected Items on a track based on item length - shortest to longest (1 second apart)
-- @about: Repositions selected items on a track from the shortest to the longest item. Items are seperated from each other by 1 second.
-- @author: David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/dda_CURATE

--SCRIPT--

function compareItems(a, b)
    return reaper.GetMediaItemInfo_Value(a, "D_LENGTH") < reaper.GetMediaItemInfo_Value(b, "D_LENGTH")
end

-- Function to print selected items on a track
function printSelectedItems(track)
    local num_items = reaper.CountTrackMediaItems(track)
    if num_items == 0 then
        return
    end

    local track_name = reaper.GetTrackName(track, "")
    if track_name == "" then
        track_name = "Untitled Track"
    end

    --reaper.ShowConsoleMsg("Selected items on track '" .. tostring(track_name) .. "':\n")
    for i = 0, num_items - 1 do
        local item = reaper.GetTrackMediaItem(track, i)
        if reaper.IsMediaItemSelected(item) then
            local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            --reaper.ShowConsoleMsg("  Item: Position = " .. tostring(item_pos) .. "\n")
        end
    end
end

function main()
    local total_selected_items = 0
    local processed_tracks = {}

    local num_sel_items = reaper.CountSelectedMediaItems(0)
    if num_sel_items == 0 then
        reaper.ShowMessageBox("No items selected.", "Error", 0)
        return
    end

    for i = 0, num_sel_items - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        if item then
            local track = reaper.GetMediaItem_Track(item)
            if track then
                local track_guid = reaper.GetTrackGUID(track)
                if not processed_tracks[track_guid] then
                    processed_tracks[track_guid] = true
                    printSelectedItems(track)

                    local selected_items = {}
                    local num_items = reaper.CountTrackMediaItems(track)
                    local first_selected_item_pos

                    -- Find the position of the first selected item on the track
                    for j = 0, num_items - 1 do
                        local item = reaper.GetTrackMediaItem(track, j)
                        if reaper.IsMediaItemSelected(item) then
                            table.insert(selected_items, item)
                            total_selected_items = total_selected_items + 1
                            if not first_selected_item_pos then
                                first_selected_item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
                            end
                        end
                    end

                    if #selected_items > 0 then
                        table.sort(selected_items, compareItems)
                        local initial_pos = first_selected_item_pos
                        local current_pos = initial_pos
                        for j, item in ipairs(selected_items) do
                            local item_len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
                            reaper.SetMediaItemInfo_Value(item, "D_POSITION", current_pos)
                            current_pos = current_pos + item_len + 1.0
                        end
                    end
                end
            end
        end
    end

    --reaper.ShowConsoleMsg("Total selected items: " .. tostring(total_selected_items) .. "\n")
    reaper.UpdateArrange()
end

reaper.Undo_BeginBlock()
main()
reaper.Undo_EndBlock("Organize Selected Items by Length", -1)

