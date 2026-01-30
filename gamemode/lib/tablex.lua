AddCSLuaFile()

tablex = {}

function tablex.SortByMemberEx(tab, memberName, bAsc, preserve)
    tab = preserve and tab or tablex.ShallowCopy(tab)

	local TableMemberSort = function( a, b, MemberName, bReverse )

		--
		-- All this error checking kind of sucks, but really is needed
		--
		if ( !istable( a ) and not getmetatable(a).__index ) then return !bReverse end
		if ( !istable( b ) and not getmetatable(b).__index ) then return bReverse end

        local a_name = a[MemberName]
        local b_name = b[MemberName]

		if ( not a_name ) then return !bReverse end
		if ( not b_name ) then return bReverse end

        if isfunction(a_name) then
            a_name = a_name(a)
        end

        if isfunction(b_name) then
            b_name = b_name(b)
        end
        

		if ( isstring( a_name ) ) then

			if ( bReverse ) then
				return a_name:lower() < b_name:lower()
			else
				return a_name:lower() > b_name:lower()
			end

		end

		if ( bReverse ) then
			return a_name < b_name
		else
			return a_name > b_name
		end

	end

	table.sort( tab, function( a, b ) return TableMemberSort( a, b, memberName, bAsc or false ) end )
    return tab
end

function tablex.SortEx(tab, desc)
    local t = table.ClearKeys(tab)
    table.sort(t)
    if desc then
        table.Reverse(t)
    end
    return t
end

function tablex.SortByKey(tab, desc)
    
    local t = {}
    local keys = table.GetKeys(tab)
    table.sort(keys, function (a, b)
        if desc then
            return a > b
        else
            return a < b
        end
    end)

    for i, k in pairs(keys) do
        local x = tab[k]
        t[i] = x
    end

    return t
end

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
        idx = idx + 1
    end
    return out
end

function tablex.GetFirst(t)
    return table.ClearKeys(t)[1]
end
tablex.First = tablex.GetFirst

function tablex.GetLast(t)
    local ct = table.ClearKeys(t)
    return ct[#ct]
end
tablex.Last = tablex.GetLast

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

function tablex.Trim(t, c)
    local out = {}
    for k, v in pairs(t) do
        out[k] = isstring(v) and string.Trim(v, c) or v
    end
    return out
end