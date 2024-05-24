-- @version 1.0.0
-- @description dda_RATING - Order selected grouped items by rating (high to low)
-- @about Repositions (linked) groups of items by their rating color (1 second apart) from the highest rating color to the lowest rating color.
-- @author David Dumais
-- Store Page: https://daviddumaisaudio.gumroad.com/l/dda_CURATE

--SCRIPT--

-- Function to check if items are grouped and get their colors
function getGroupInfo()
    local selItemCount = reaper.CountSelectedMediaItems(0)
    local groupSet = {}
    local ungroupedCount = 0
    local groups = {}

    -- If no items are selected, return false
    if selItemCount == 0 then
        return 0, nil, 0
    end

    -- Loop through selected items
    for i = 0, selItemCount - 1 do
        local item = reaper.GetSelectedMediaItem(0, i)

        -- Check if the item is grouped
        local itemGroup = reaper.GetMediaItemInfo_Value(item, "I_GROUPID")
        if itemGroup ~= 0 then
            if not groupSet[itemGroup] then
                groupSet[itemGroup] = {color = nil, itemCount = 0, items = {}}
                table.insert(groups, itemGroup)
            end
            groupSet[itemGroup].itemCount = groupSet[itemGroup].itemCount + 1
            table.insert(groupSet[itemGroup].items, item)

            -- Get color of the first item in the group
            local itemColor = reaper.GetDisplayedMediaItemColor(item)
            if not groupSet[itemGroup].color then
                groupSet[itemGroup].color = itemColor
            else
                -- Check if color of subsequent items matches the color of the first item
                if groupSet[itemGroup].color ~= itemColor then
                    reaper.ShowMessageBox("Please make sure all items in a group are the same color.", "Error", 0)
                    return 0, nil, 0
                end
            end
        else
            ungroupedCount = ungroupedCount + 1
        end
    end

    -- Check if any selected items are not part of any group
    if #groups == 0 and ungroupedCount > 0 then
        reaper.ShowMessageBox("Please group items before running this script.", "Error", 0)
        return 0, nil, 0
    end

    --reaper.ShowConsoleMsg("Number of selected items that are not grouped: " .. ungroupedCount .. " (BEFORE reposition)\n")

    return tableLength(groupSet), groupSet, ungroupedCount
end

-- Function to count the number of elements in a table
function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

-- Function to sort groups based on their color
function sortGroupsByColor(groupInfo, colorTable)
    local sortedGroups = {}
    local unsortedGroups = {} -- Groups with colors not in the colorTable
    for group, info in pairs(groupInfo) do
        local groupColor = info.color
        local r, g, b = reaper.ColorFromNative(groupColor)
        -- Find the index of the group's color in the color table
        local index
        local found = false
        for i, color in ipairs(colorTable) do
            if color[1] == r and color[2] == g and color[3] == b then
                index = i
                found = true
                break
            end
        end
        if found then
            table.insert(sortedGroups, {group = group, colorIndex = index})
        else
            table.insert(unsortedGroups, group)
        end
    end

    table.sort(sortedGroups, function(a, b)
        return a.colorIndex < b.colorIndex
    end)

    -- Append unsorted groups to the end
    for _, group in ipairs(unsortedGroups) do
        table.insert(sortedGroups, {group = group})
    end

    return sortedGroups
end

-- Function to get start and end positions of a group
function getGroupPositions(groupItems)
    local startPosition = math.huge
    local endPosition = -math.huge

    for _, item in ipairs(groupItems) do
        local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
        local itemLength = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
        local itemEnd = itemStart + itemLength

        if itemStart < startPosition then
            startPosition = itemStart
        end

        if itemEnd > endPosition then
            endPosition = itemEnd
        end
    end

    return startPosition, endPosition
end

-- Function to reposition groups
function repositionGroups(sortedGroups, groupInfo)
    local nextPosition = math.huge
    -- Find the smallest start position among the groups
    for _, groupData in ipairs(sortedGroups) do
        local group = groupData.group
        local groupItems = groupInfo[group].items
        local startPosition, _ = getGroupPositions(groupItems)
        if startPosition < nextPosition then
            nextPosition = startPosition
        end
    end
    -- Adjust the start position to ensure there's 1 second spacing between groups
    nextPosition = nextPosition - 1
    for _, groupData in ipairs(sortedGroups) do
        local group = groupData.group
        local groupItems = groupInfo[group].items
        local minStartPosition = math.huge
        -- Find the minimum start position within the group
        for _, item in ipairs(groupItems) do
            local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            if itemStart < minStartPosition then
                minStartPosition = itemStart
            end
        end
        -- Update next position based on the maximum end position of the previous group
        nextPosition = nextPosition + 1
        -- Calculate the offset by which to move the entire group
        local offset = nextPosition - minStartPosition
        -- Reposition each item within the group
        for _, item in ipairs(groupItems) do
            local itemStart = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            local newItemStart = itemStart + offset
            reaper.SetMediaItemInfo_Value(item, "D_POSITION", newItemStart)
        end
        -- Update next position for the next group
        local _, endPosition = getGroupPositions(groupItems)
        nextPosition = endPosition
    end

    -- Print new positions after repositioning
    --reaper.ShowConsoleMsg("\nAfter reposition:\n")
    for _, groupData in ipairs(sortedGroups) do
        local group = groupData.group
        local color = groupInfo[group].color
        if color then
            local r, g, b = reaper.ColorFromNative(color)
            local startPosition, endPosition = getGroupPositions(groupInfo[group].items)
            --reaper.ShowConsoleMsg("Group ID: " .. group .. ", Color: R=" .. r .. ", G=" .. g .. ", B=" .. b .. ", Start Position: " .. startPosition .. ", End Position: " .. endPosition .. "\n")
        else
            --reaper.ShowConsoleMsg("Group ID: " .. group .. ", Color: (No color), Positioned at the end.\n")
        end
    end
end

-- Function to read colors from custom_colors.txt file
function readCustomColors()
    local colors = {}
    local custom_colors_file = reaper.GetResourcePath() .. "\\CustomColors\\custom_colors.txt"
    local file = io.open(custom_colors_file, "r")
    if file then
        for line in file:lines() do
            local r, g, b = string.match(line, "(%d+),(%d+),(%d+)")
            if r and g and b then
                table.insert(colors, {tonumber(r), tonumber(g), tonumber(b)})
            end
        end
        file:close()
    end
    return colors
end

-- Main function
function main()
    local groupCount, groupInfo, ungroupedCount = getGroupInfo()

    -- Check if there are ungrouped items before repositioning
    if ungroupedCount > 0 then
        reaper.ShowMessageBox("Please group items before running this script.", "Error", 0)
        return -- Stop the script
    end

    if groupCount > 0 then
        -- Read colors from custom_colors.txt
        local colorTable = readCustomColors()

        -- Sort groups by color
        local sortedGroups = sortGroupsByColor(groupInfo, colorTable)

        --reaper.ShowConsoleMsg("Selected items are grouped (linked) into " .. groupCount .. " group(s), repositioned based on color.\n")
        
        -- Reposition groups
        repositionGroups(sortedGroups, groupInfo)
    else
        --reaper.ShowConsoleMsg("Selected items are not grouped (linked).\n")
    end
end

-- Run the main function
main()

