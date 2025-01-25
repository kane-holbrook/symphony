AddCSLuaFile()

function uuid()
    -- Generate all 128 bits of the UUID as random numbers in one go
    local data1 = math.random() * 0xFFFFFFFF
    local data2 = math.random() * 0xFFFFFFFF
    local data3 = math.random() * 0xFFFFFFFF
    local data4 = math.random() * 0xFFFFFFFF

    -- Format the UUID directly using a more efficient string formatting
    return string.format("%08x-%04x-%04x-%04x-%08x%04x", data1, bit.rshift(data2, 16), bit.band(data2, 0xFFFF), bit.rshift(data3, 16), bit.band(data3, 0xFFFF), bit.rshift(data4, 16), bit.band(data4, 0xFFFF))
end
