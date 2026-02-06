AddCSLuaFile()

stringex = {}

function stringex.Truncate(text, width)
    if #text > width then
        return text:sub(1, width - 3) .. "..."
    else
        return text
    end
end

function stringex.TitleCase(text)
    local out = text:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
    return out
end

function stringex.Count(text, substring)
    local count = 0
    local i = 1
    while true do
        i = text:find(substring, i)
        if i == nil then
            break
        end
        count = count + 1
        i = i + 1
    end
    return count
end

function stringex.EscapeCSV(text)
    if text:find('["\n,]') then
        return '"' .. text:gsub('"', '""') .. '"'
    else
        return text
    end
end

function stringex.ParseArgs(input, numArgs)
    local split = string.Split(input, " ")
    numArgs = numArgs or #split

    local out = {}

    local quote = false
    local buffer = ""
    local idx = 0
    local idx2 = 0
    for k, v in pairs(split) do
        if quote then
            if string.EndsWith(v, "\"") then
                table.insert(out, buffer .. " " .. string.Trim(string.sub(v, 0, -2)))
                buffer = ""
                quote = false
                idx = idx + 1
            else
                buffer = buffer .. " " .. string.Trim(v)
            end
        else
            if string.StartsWith(v, "\"") and not string.EndsWith(v, "\"") then
                quote = true
                buffer = string.Trim(string.sub(v, 2))
            else
                table.insert(out, string.Trim(v))
                idx = idx + 1
            end
        end
        idx2 = idx2 + 1

        if idx > numArgs then
            local remainder = table.concat(split, " ", idx2+1)
            if remainder then
                if quote then
                    buffer = string.Trim(buffer .. " " .. remainder)
                else
                    out[idx] = string.Trim(out[idx] .. " " .. remainder)
                end
            end
            break
        end
    end

    if quote then
        table.insert(out, string.Trim(buffer))
    end
    return out
end

function stringex.ConcatArgs(...)
    local args = {...}

    if #args == 1 and istable(args[1]) then
        args = args[1]
    end
    
    for k, v in pairs(args) do
        if string.find(v, " ") then
            args[k] = "\"" .. v .. "\""
        end
    end
    return table.concat(args, " ")
end

function stringex.ToString(t)
    if isstring(t) then
        return "\"" .. t .. "\""
    else
        return tostring(t)
    end
end

function stringex.Merge(str, keys)
    for k, v in pairs(keys) do
        str = string.Replace(str, k, v)
    end
    return str
end

function stringex.EscapeHTML(text)
    
    -- Renoramlize it so we don't get &&amp;amp;
    text = string.Replace(text, "&amp;", "&")
    text = string.Replace(text, "&lt;", "<")
    text = string.Replace(text, "&gt;", ">")
    text = string.Replace(text, "&apos;", "'")

    -- Then re-escape it
    text = string.Replace(text, "&", "&amp;")
    text = string.Replace(text, "<", "&lt;")
    text = string.Replace(text, ">", "&gt;")
    text = string.Replace(text, "'", "&apos;")
    return text
end

function stringex.StripHTMLTags(str)
    if not isstring(str) then 
        return str 
    end

    local r = string.gsub(str, "<.->", "")
    return r
end

function stringex.Random(n)
    local out = {}

    for i = 1, n do
        out[i] = string.char(math.floor(math.Rand(33, 126)))
    end

    return table.concat(out, "")
end

function stringex.RemoveEmojis(str)
    -- Define a pattern to match emoji characters using Unicode character ranges
    local emojiPattern = "[\240-\244][\128-\191][\128-\191][\128-\191]"
    return string.gsub(str, emojiPattern, "")
end

function stringex.Insert(text, pos, value)
    return string.Left(text, pos) .. value .. string.sub(text, pos+1)
end

function stringex.IsAllUppercase(text)
    return text:upper() == text
end

function stringex.IsAllLowercase(text)
    return text:lower() == text
end

function stringex.IsAlpha(text)
    return text:match("^[A-Za-z]+$") ~= nil
end

function stringex.IsAlphaSpace(text)
    return text:match("^[A-Za-z%s]+$") ~= nil
end

function stringex.IsAlphanumeric(text)
    return text:match("^[A-Za-z0-9]+$") ~= nil
end

function stringex.IsAlphanumericSpace(text)
    return text:match("^[A-Za-z0-9%s]+$") ~= nil
end

function stringex.IsAsciiPrintable(text)
    return text:match("^[%w%p%s]+$") ~= nil
end

function stringex.IsBlank(text)
    return text == nil or text == ""
end

function stringex.IsNumericSpace(text)
    return text:match("^[0-9%s]+$") ~= nil
end

function stringex.RemoveEnd(text, substring)
    if text:sub(-#substring) == substring then
        return text:sub(1, -#substring - 1)
    else
        return text
    end
end

function stringex.RemoveStart(text, substring)
    if text:sub(1, #substring) == substring then
        return text:sub(#substring + 1)
    else
        return text
    end
end

function stringex.SubstringAfter(text, delimiter)
    local s = string.Split(text, delimiter)
    return table.concat(s, "", 2, #s)
end

function stringex.SubstringBefore(text, delimiter)
    local s = string.Split(text, delimiter)
    if #s == 1 then
        return nil
    end
    return s[1]
end

function stringex.SubstringAfterLast(text, delimiter)
    local s = string.Split(text, delimiter)
    local len = #s
    if len == 1 then
        return nil
    end

    return s[len]
end

function stringex.SubstringBeforeLast(text, delimiter)
    local s = string.Split(text, delimiter)
    print(text, delimiter)
    return table.concat(s, delimiter, 1, #s - 1)
end

function stringex.SubstringBetween(text, open, close, start)
    start = start or text:find(open, nil, true)
    if not start then
        return nil
    end
    
    start = start + string.len(open)
    local _, end_pos = text:find(close, start, true)
    if start and end_pos then
        return text:sub(start, end_pos  - string.len(close)), start, end_pos
    else
        return nil
    end
end

function stringex.GetLevenshteinDistance(a, b)
    local len_a = #a
    local len_b = #b
    local char_a = {a:byte(1, len_a)}
    local char_b = {b:byte(1, len_b)}
    local current_row = {}
    local prev_row = {}

    -- Initialize the current row
    for i = 0, len_b do
        current_row[i] = i
    end

    -- Calculate distances
    for i = 1, len_a do
        prev_row, current_row = current_row, {}
        current_row[0] = i
        for j = 1, len_b do
            local cost = (char_a[i] == char_b[j]) and 0 or 1
            current_row[j] = math.min(prev_row[j] + 1,          -- Deletion
                                      current_row[j - 1] + 1,  -- Insertion
                                      prev_row[j - 1] + cost)  -- Substitution
        end
    end

    return current_row[len_b]
end
