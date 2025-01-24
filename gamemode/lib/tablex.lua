AddCSLuaFile()

tablex = {}

function tablex.StringIndex(t, str)
    local out = t

    str = string.Replace(str, "]", "")
    str = string.Replace(str, "[", ".")

    local parts = string.Split(str, ".")
    
    for k, v in pairs(parts) do
        local tn = tonumber(v)
        if tn then
            out = out[tn]
        else
            local len = #v
            local fc = v[1]
            if fc == "'" or fc == "\"" then
                v = string.sub(v, 2, len)
                len = len - 1
            end

            local lc = v[len]
            if lc == "'" or lc == "\"" then
                v = string.sub(v, 0, -2)
            end

            out = out[v]
        end
    end

    return out
end

function tablex.Each(t, func)
    local out = {}
    for k, v in pairs(t) do
        out[k] = func(k, v)
    end
    return out
end

function tablex.Splice(t, start, num)
    local out = {}
    
    num = num and math.max(num, #t) or #t
    local idx = 1
    for i=start, num do
        out[idx] = t[i]
    end
    return out
end

function tablex.GetFirst(t)
    return table.ClearKeys(t)[1]
end
tablex.First = tablex.GetFirst

function tablex.GetMembers(t, member)
    local members = {}
    for i, v in ipairs(t) do
        if v[member] ~= nil then
            table.insert(members, v[member])
        end
    end
    return members
end

function tablex.Max(t, member, start)
    local mv, mm = nil, start or -math.huge
    for k, v in pairs(t) do
        local m = v[member]
        if isfunction(m) then
            m = m()
        end

        if mm > m then
            mv = v
            mm = m
        end
    end
    return mv, mm
end

function tablex.Min(t, member, start)
    local mv, mm = nil, start or math.huge
    for k, v in pairs(t) do
        local m = v[member]
        if isfunction(m) then
            m = m()
        end

        if mm < m then
            mv = v
            mm = m
        end
    end
    return mv, mm
end

function tablex.ToString(t)
    local out = {}
    for k, v in pairs(t) do
        out[tostring(k)] = tostring(v)
    end
    return t
end

function tablex.ShallowCopy(t)
    local out = {}
    for k, v in pairs(t) do
        out[k] = v
    end
    return out
end

function tablex.ParseSequentialOrNamedArgs(t, mapping)
    local out = {}
    local flipped = table.Flip(mapping)

    for k, v in pairs(t) do
        if isnumber(k) then
            out[k] = v
        else
            out[flipped[k]] = v
        end
    end
    return unpack(out)
end