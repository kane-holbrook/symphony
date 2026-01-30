AddCSLuaFile()

if SERVER then
    return
end

local PANEL = {}
AccessorFunc(PANEL, "Columns", "Columns", FORCE_NUMBER)
AccessorFunc(PANEL, "Gap", "Gap", FORCE_NUMBER)
AccessorFunc(PANEL, "RowHeight", "RowHeight", FORCE_NUMBER)

-- Initialize defaults
function PANEL:Init()
    self:SetColumns(8)
    self:SetGap(4)
end

-- Helper to determine if a panel should be laid out
local function IsAlignable(pnl)
    return pnl:GetVisible() and not pnl:GetAbsolute() and not pnl.NoLayout
end


-- Arrange children in a grid
function PANEL:LayoutChildren(w, h)
    local children = self:GetChildren()
    local columns = math.max(1, self:GetColumns())
    local gap = self:GetGap() or 0
    local rh = self:GetRowHeight()


    -- Filter alignable children
    local items = {}
    for _, child in ipairs(children) do
        if IsAlignable(child) then
            table.insert(items, child)
        end
    end
    
    local sz = math.floor((w - (columns - 1) * gap) / columns)
    local x = 0
    local y = 0
    for k, v in pairs(items) do
        v:SetComputed("Wide", false)
        v:SetComputed("Tall", false)
        v:SetComputed("Width", false)
        v:SetComputed("Height", false)

        v.SuppressSize = true
        v:SetPos(x, y)

        if rh then
            v:SetSize(sz, rh)
        else
            v:SetSize(sz, sz)
        end

        x = x + sz + gap

        if (k % columns) == 0 then
            x = 0
            y = y + (rh or sz) + gap
        end
    end

    return w, y + (rh or sz)
end

-- Register the panel
vgui.Register("Grid", PANEL, "Rect")
