AddCSLuaFile()

function uuid()
    local data = { math.Truncate(math.Rand(0, 4294967295)), math.Truncate(math.Rand(0, 4294967295)), math.Truncate(math.Rand(0, 4294967295)), math.Truncate(math.Rand(0, 4294967295))}
    local data2 = string.format("%.8x", data[2])
    local data3 = string.format("%.8x", data[3])
    return string.format("%.8x-%s-%s-%s-%s%.8x", data[1], string.sub(data2, 0, 4), string.sub(data2, 5, 8), string.sub(data3, 0, 4), string.sub(data3, 5, 8), data[4])
end
