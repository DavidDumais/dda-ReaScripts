-- Check if the custom_colors.txt file exists
local custom_colors_file = reaper.GetResourcePath() .. "\\CustomColors\\custom_colors.txt"
local file_exists = reaper.file_exists(custom_colors_file)

-- If the file doesn't exist, display the error message and exit the script
if not file_exists then
    reaper.MB("Custom colors not set. Set custom colors using action 'dda_get custom color slot 1 v2'", "Error", 0)
    return
end

-- Function to move selected items on a track by their color
local function moveItemsByColor(track)
    -- Get the number of selected items on the track
    local num_items = reaper.CountTrackMediaItems(track)
    if num_items == 0 then
        --reaper.ShowConsoleMsg("No items on the track\n")
        return
    end

    -- Find the position of the first selected item
    local first_item_position = -1
    for i = 0, num_items - 1 do
        local item = reaper.GetTrackMediaItem(track, i)
        if item ~= nil and reaper.IsMediaItemSelected(item) then
            first_item_position = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            --reaper.ShowConsoleMsg(string.format("First selected item position: %.2f\n", first_item_position))
            break
        end
    end

    if first_item_position == -1 then
        --reaper.ShowConsoleMsg("No selected items on the track\n")
        return
    end

    -- Table to store selected items grouped by color
    local items_by_color = {}

    -- Table to store items with unspecified colors
    local items_unspecified_color = {}

    -- Read the order of colors from the custom_colors.txt file
    local order_of_colors = {}
    local file = io.open(custom_colors_file, "r")
    if file then
        for line in file:lines() do
            table.insert(order_of_colors, line)
        end
        file:close()
    else
        reaper.MB("Custom colors not set. Set custom colors using action 'dda_get custom color slot 1 v2'", "Error", 0)
        return
    end

    -- Iterate through each selected item on the track
    for i = 0, num_items - 1 do
        local item = reaper.GetTrackMediaItem(track, i)
        if item ~= nil and reaper.IsMediaItemSelected(item) then
            --reaper.ShowConsoleMsg("Found a selected item\n")
            -- Get the item's name
            local take = reaper.GetActiveTake(item)
            if take ~= nil then
                local _, item_name = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)

                -- Get the item's color
                local item_color = reaper.GetDisplayedMediaItemColor(item)
                --reaper.ShowConsoleMsg(string.format("Item color: %d\n", item_color))

                -- Convert color from integer to RGB
                local r = item_color & 0xFF
                local g = (item_color >> 8) & 0xFF
                local b = (item_color >> 16) & 0xFF

                -- Create a key for the color
                local color_key = string.format("%d,%d,%d", r, g, b)
                --reaper.ShowConsoleMsg(string.format("Color key: %s\n", color_key))

                -- Check if color is in the specified colors
                local color_found = false
                for _, color in ipairs(order_of_colors) do
                    if color == color_key then
                        color_found = true
                        break
                    end
                end

                -- Add item to the table under its color key
                if color_found then
                    if items_by_color[color_key] == nil then
                        items_by_color[color_key] = {}
                    end
                    table.insert(items_by_color[color_key], {name = item_name, item = item})
                else
                    table.insert(items_unspecified_color, {name = item_name, item = item})
                end
            end
        end
    end

    --reaper.ShowConsoleMsg("Grouped items by color\n")

    -- Move selected items on the track with a 1-second gap between each, starting from the first selected item's position
    local position_offset = first_item_position
    for i = #order_of_colors, 1, -1 do -- Iterate over colors in reverse order
        local color_key = order_of_colors[i]
        if items_by_color[color_key] then
            for _, item_data in ipairs(items_by_color[color_key]) do
                reaper.SetMediaItemInfo_Value(item_data.item, "D_POSITION", position_offset)
                --reaper.ShowConsoleMsg(string.format("Moved item with color %s to position %.2f\n", color_key, position_offset))
                position_offset = position_offset + 1 + reaper.GetMediaItemInfo_Value(item_data.item, "D_LENGTH")
            end
        end
    end
    

    --reaper.ShowConsoleMsg("Moved selected items by color\n")

    -- Move items with unspecified color to the end
    for _, item_data in ipairs(items_unspecified_color) do
        reaper.SetMediaItemInfo_Value(item_data.item, "D_POSITION", position_offset)
        --reaper.ShowConsoleMsg(string.format("Moved item with unspecified color to position %.2f\n", position_offset))
        position_offset = position_offset + 1 + reaper.GetMediaItemInfo_Value(item_data.item, "D_LENGTH")
    end

    --reaper.ShowConsoleMsg("Moved items with unspecified color\n")

    -- Write selected items grouped by color to the console
    for _, color_key in ipairs(order_of_colors) do
        if items_by_color[color_key] then
            --reaper.ShowConsoleMsg(string.format("Color: %s\n", color_key))
            for _, item_data in ipairs(items_by_color[color_key]) do
                --reaper.ShowConsoleMsg(string.format("- Item: %s\n", item_data.name))
            end
        end
    end

    --reaper.ShowConsoleMsg("Listed selected items by color\n")

    -- Write items with unspecified color to the console
    if #items_unspecified_color > 0 then
        --reaper.ShowConsoleMsg("Color: Unspecified\n")
        for _, item_data in ipairs(items_unspecified_color) do
            --reaper.ShowConsoleMsg(string.format("- Item: %s\n", item_data.name))
        end
    end
end

-- Cycle through each selected track
local num_sel_tracks = reaper.CountSelectedTracks(0)
if num_sel_tracks > 0 then
    --reaper.ShowConsoleMsg(string.format("Number of selected tracks: %d\n", num_sel_tracks))
    for i = 0, num_sel_tracks - 1 do
        local track = reaper.GetSelectedTrack(0, i)
        if track ~= nil then
            --reaper.ShowConsoleMsg(string.format("Processing track %d\n", i + 1))
            moveItemsByColor(track)
        end
    end
else
    --reaper.ShowConsoleMsg("No tracks selected\n")
end

-- Cycle through each selected item
local num_sel_items = reaper.CountSelectedMediaItems(0)
if num_sel_items > 0 then
    --reaper.ShowConsoleMsg(string.format("Number of selected items: %d\n", num_sel_items))
    for i = 0, num_sel_items - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)
        if item ~= nil then
            --reaper.ShowConsoleMsg(string.format("Processing item %d\n", i + 1))
            local track = reaper.GetMediaItem_Track(item)
            moveItemsByColor(track)
        end
    end
else
    --reaper.ShowConsoleMsg("No items selected\n")
end

