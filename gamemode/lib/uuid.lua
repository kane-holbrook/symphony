AddCSLuaFile()

function uuid()
    -- Generate random 128-bit number using four 32-bit parts
    local data1 = math.random(0, 0xFFFFFFFF)
    local data2 = math.random(0, 0xFFFF)
    local data3 = bit.bor(math.random(0, 0x0FFF), 0x4000) -- Set version to 4 (random)
    local data4 = bit.bor(math.random(0, 0x3FFF), 0x8000) -- Set variant to 10xx (RFC 4122)
    local data5 = math.random(0, 0xFFFFFFFF)
    local data6 = math.random(0, 0xFFFF)

    -- Format the UUID correctly
    return string.format("%08x-%04x-%04x-%04x-%08x%04x", data1, data2, data3, data4, data5, data6)
end
