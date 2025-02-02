MATERIAL_CACHE = MATERIAL_CACHE or {}

function sym.Material(path, pngParameters)
    local key = Tuple(path, pngParameters)
    local m = MaterialCache[key]
    if m then
        return m
    end

    m = Material(path, pngParameters)
    MaterialCache[key] = m
    return m
end