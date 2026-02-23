local ItemList = import('/lua/maui/itemlist.lua').ItemList
local LayoutHelpers = import('/lua/maui/layouthelpers.lua')
local Group = import('/lua/maui/group.lua').Group
local Text = import('/lua/maui/text.lua').Text
local Border = import('/lua/maui/border.lua').Border
local Bitmap = import('/lua/maui/bitmap.lua').Bitmap
local Checkbox = import('/lua/maui/checkbox.lua').Checkbox
local RadioGroup = import('/lua/maui/mauiutil.lua').RadioGroup
local UIUtil = import('/lua/ui/uiutil.lua')

local unselectedCheckboxFile = UIUtil.UIFile('/widgets/rad_un.dds')
local selectedCheckboxFile = UIUtil.UIFile('/widgets/rad_sel.dds')

local function getItems()
    local idlist = EntityCategoryGetUnitList(categories.ALLUNITS)
    table.sort(idlist)

    local items = {}
    local separator = { text = '---' }
    local previd = ''
    local subitems
    local subsubitems

    for i,ID in idlist do
        local id = string.lower(ID)
        local bp = GetUnitBlueprintByName(ID)

        if previd != '' and string.sub(previd,1,2) != string.sub(id,1,2) then
            table.insert(items, separator)
        end

        if string.sub(previd,1,3) != string.sub(id,1,3) then
            subitems = { text = string.sub(id,1,3) }
            table.insert(items, subitems)
            subsubitems = nil
        end

        local s = ID .. ": " .. LOC(bp.General.UnitName or "") .. " - " .. LOC(bp.Description)
        table.insert(subsubitems or subitems, { text=s, blueprintid=ID} )

        previd = id
    end

    return items
end

local function getArmyList()
    local armies = GetArmiesTable()
    local r = {}
    for i=1, armies.numArmies do
        table.insert(r, string.format("%s (%s)", armies.armiesTable[i].name, i))
    end
    return r, armies.focusArmy
end

-- GetArmiesTable() returns something like this:
--{
--  armiesTable={
--    { color="ff00ff00", faction=0, iconColor="ff00ff00", name="Player", nickname="Oongawa" },
--    { color="ff0000ff", faction=1, iconColor="ff0076e4", name="Army 2", nickname="Illuminate offensive" }
--    { color="ff0000ff", faction=1, iconColor="ff0076e4", name="Army 3", nickname="Illuminate base" }
--  },
--  focusArmy=1,
--  numArmies=3
--}

function CreateDialog(x, y)

    local items = getItems()
    local armies, defaultArmy = getArmyList()
    if defaultArmy < 1 then defaultArmy = 1 end

    local mainFrame = GetFrame(0)
    local dialog = Group(mainFrame, 'create unit dialog')
    dialog.Depth:Set(100000)

    local border = Border(dialog)
    border:SetTextures(UIUtil.UIFile('/widgets/gen_brd_vert.dds'),
                       UIUtil.UIFile('/widgets/gen_brd_horz.dds'),
                       UIUtil.UIFile('/widgets/gen_brd_ul.dds'),
                       UIUtil.UIFile('/widgets/gen_brd_ur.dds'),
                       UIUtil.UIFile('/widgets/gen_brd_ll.dds'),
                       UIUtil.UIFile('/widgets/gen_brd_lr.dds'))
    border:LayoutAroundControl(dialog)
    border.Depth:Set(function() return dialog.Depth()-1 end)

    local backdrop = Bitmap(dialog)
    backdrop:SetSolidColor('c0000000')
    LayoutHelpers.FillParent(backdrop, dialog)
    backdrop.Depth:Set(function() return dialog.Depth()-1 end)

    local armyGroup = Group(dialog, "armyGroup")
    local leftArmyColumn = Group(armyGroup, "leftArmyColumn")
    local rightArmyColumn = Group(armyGroup, "rightArmyColumn")
    local armyItems = {}

    -- set the bottom to the top in case there are 0 or 1 columns
    rightArmyColumn.Bottom:Set(rightArmyColumn.Top)
    leftArmyColumn.Bottom:Set(leftArmyColumn.Top)

    for k,v in armies do
        local column
        if bitlib.band(k,1) == 1 then
            column = leftArmyColumn
        else
            column = rightArmyColumn
        end
        local check = Checkbox(column, unselectedCheckboxFile, selectedCheckboxFile)
        local label = Text(column)
        label:SetText(v)
        label:SetFont(UIUtil.fixedFont, 12)
        if k <= 2 then
            check.Top:Set(column.Top)
        else
            local above = armyItems[k-2]
            check.Top:Set(function()
                              local a = above
                              local c = a.checkbox
                              local l = a.label
                              local cb = c.Bottom
                              local lb = l.Bottom
                              return math.max(above.checkbox.Bottom(), above.label.Bottom())
                          end)
        end
        check.Left:Set(column.Left)

        label.Top:Set(check.Top)
        label.Left:Set(check.Right)
        label.Right:Set(column.Right)
        label.Width:Set(function() return label.Right() - label.Left() end)

        table.insert(armyItems, { checkbox=check, label=label })

        column.Bottom:Set(function() return math.max(check.Bottom(), label.Bottom()) end)
    end

    local selectedArmy = defaultArmy

    local radiogroup = RadioGroup(armyItems, defaultArmy)
    function radiogroup.OnChoose(group, index, item)
        LOG('selected army is now ' .. repr(index))
        selectedArmy = index
    end

    armyGroup.Top:Set(dialog.Top)
    armyGroup.Left:Set(dialog.Left)
    armyGroup.Right:Set(dialog.Right)
    armyGroup.Bottom:Set(function() return math.max(leftArmyColumn.Bottom(), rightArmyColumn.Bottom()) end)

    leftArmyColumn.Top:Set(armyGroup.Top)
    leftArmyColumn.Left:Set(armyGroup.Left)
    leftArmyColumn.Right:Set(function() return math.floor((armyGroup.Left() + armyGroup.Right()) / 2) end)

    rightArmyColumn.Top:Set(armyGroup.Top)
    rightArmyColumn.Left:Set(leftArmyColumn.Right)
    rightArmyColumn.Right:Set(armyGroup.Right)

    local listGroup = Group(dialog, "listGroup")

    local leftList = ItemList(listGroup, 'left list')
    leftList:ShowMouseoverItem(true)
    local middleList = ItemList(listGroup, 'middle list')
    middleList:ShowMouseoverItem(true)
    local rightList = ItemList(listGroup, 'right list')
    rightList:ShowMouseoverItem(true)

    local scrollbar = UIUtil.CreateVertScrollbarFor(rightList)

    local closeButton = UIUtil.CreateButtonStd(dialog, '/widgets/small', "cancel", 12)

    closeButton.OnClick = function(button)
        dialog:Destroy()
    end

    for k,v in items do
        leftList:AddItem(v.text)
    end

    local middleItems = {}
    local rightItems = {}

    function leftList.OnClick(list, row)
        local item = items[row+1]
        if item and table.getn(item) != 0 then
            leftList:SetSelection(row)
            middleList:DeleteAllItems()
            middleItems = {}
            rightList:DeleteAllItems()
            rightItems = {}
            for k,v in ipairs(item) do
                if table.getn(v) != 0 then
                    middleList:AddItem(v.text)
                    table.insert(middleItems, v)
                else
                    rightList:AddItem(v.text)
                    table.insert(rightItems, v)
                end
            end
        end
    end

    function middleList.OnClick(list, row)
        local item = middleItems[row+1]
        if item and table.getn(item) != 0 then
            middleList:SetSelection(row)
            rightList:DeleteAllItems()
            rightItems = {}
            for k,v in ipairs(item) do
                rightList:AddItem(v.text)
                table.insert(rightItems, v)
            end
        end
    end

    function rightList.OnClick(list, row)
        local item = rightItems[row+1]
        if item and item.blueprintid then
            cmd = 'CreateUnit ' .. item.blueprintid .. ' ' .. (selectedArmy-1) .. ' ' .. x .. ' ' .. y
            LOG('cmd=' .. repr(cmd))
            ConExecuteSave(cmd)
            dialog:Destroy()
        end
    end

    leftList:SetFont("Courier New", 12)
    leftList:SetColors("white", "transparent", "yellow", "blue")
    middleList:SetFont("Courier New", 12);
    middleList:SetColors("white", "transparent", "yellow", "blue")
    rightList:SetFont("Courier New", 12);
    rightList:SetColors("white", "transparent", "yellow", "blue")

    dialog.Left:Set(function() return math.min(x, mainFrame.Right() - 500) end)
    dialog.Top:Set(function() return math.min(y, mainFrame.Bottom() - 768) end)
    dialog.Right:Set(listGroup.Right)
    dialog.Bottom:Set(closeButton.Bottom)

    listGroup.Top:Set(armyGroup.Bottom)
    listGroup.Left:Set(dialog.Left)
    listGroup.Height:Set(600)
    listGroup.Right:Set(scrollbar.Right)

    leftList.Left:Set(listGroup.Left)
    leftList.Top:Set(listGroup.Top)
    leftList.Bottom:Set(listGroup.Bottom)
    leftList.Width:Set(30)

    middleList.Left:Set(leftList.Right)
    middleList.Top:Set(listGroup.Top)
    middleList.Bottom:Set(listGroup.Bottom)
    middleList.Width:Set(40)

    rightList.Left:Set(middleList.Right)
    rightList.Top:Set(listGroup.Top)
    rightList.Bottom:Set(listGroup.Bottom)
    rightList.Width:Set(400)

    closeButton.Top:Set(listGroup.Bottom)
    LayoutHelpers.AtHorizontalCenterIn(closeButton, dialog)

    dialog:Show()
end