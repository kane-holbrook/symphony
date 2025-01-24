AddCSLuaFile()

filex = {}

function filex.Copy(from, to)
    return file.Write(to, file.Read(from))
end

function filex.GetRelativePath(path, stack)    
    
    if string.StartsWith(path, "/") then
        return string.TrimLeft(path, "/")
    end

    stack = stack or 0
    path = string.Replace(path, "\\", "/")
    path = string.Trim(path, "/")

    local cd = string.Replace(debug.getinfo(2 + stack).short_src, "\\", "/")

    local splitPath = string.Split(path, "/")
    local dest = string.Split(cd, "/")

    local idx = #dest
    dest[idx] = nil -- Remove the file name
    idx = idx - 1

    for k, v in pairs(splitPath) do
        if v == ".." then
            dest[idx] = nil
            idx = idx - 1
        else
            idx = idx + 1
            dest[idx] = v
        end
    end

    return table.concat(dest, "/"), "GAME"
end