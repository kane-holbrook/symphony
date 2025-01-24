AddCSLuaFile()

mathex = {}

function mathex.IsInteger(n)
    return math.floor(n) == n
end

function mathex.ApproachVector(current, target, change)
    local diff = (target - current)
    local fwd = diff:GetNormalized()
    return current + (fwd * math.min(diff:Length(), change))
end

function mathex.IsFloat(num)
    local singlePrecisionNum = tonumber(string.format("%.7g", num))
    return num == singlePrecisionNum
end

function mathex.GetBits(value)
    -- For negative values, convert to positive using two's complement
    if value < 0 then
        value = -value - 1
    end

    local bits = 0
    while value > 0 do
        bits = bits + 1
        value = math.floor(value / 2)
    end

    -- Add 1 bit for sign if the original value was negative
    return bits + (value < 0 and 1 or 0)
end


isinteger = mathex.IsInteger
isfloat = mathex.IsFloat