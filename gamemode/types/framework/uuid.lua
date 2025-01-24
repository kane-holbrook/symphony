AddCSLuaFile()

--
-- UUID
--
do
	local UUID = sym.RegisterType("uuid")
	UUID.__dbtype = "UUID"

	function UUID:str()
		return tostring(self)
	end

	function UUID.__eq(a, b)
		return tostring(a) == tostring(b)
	end

	function UUID:__tostring()
		if self.string then return self.string end
		local data2 = string.format("%.8x", self.data[2])
		local data3 = string.format("%.8x", self.data[3])
		self.string = string.format("%.8x-%s-%s-%s-%s%.8x", self.data[1], string.sub(data2, 0, 4), string.sub(data2, 5, 8), string.sub(data3, 0, 4), string.sub(data3, 5, 8), self.data[4])

		return self.string
	end

	function UUID:DbRead(value)
		return sym.uuid(value)
	end

	function net.WriteUUID(uuid)
		net.WriteUInt(uuid.data[1], 32)
		net.WriteUInt(uuid.data[2], 32)
		net.WriteUInt(uuid.data[3], 32)
		net.WriteUInt(uuid.data[4], 32)
	end

	function net.ReadUUID()
		local a, b, c, d = net.ReadUInt(32), net.ReadUInt(32), net.ReadUInt(32), net.ReadUInt(32)

		return sym.uuid(a, b, c, d)
	end

	-- usage:
	-- sym.uuid() - generate a random UUID
	-- sym.uuid(int32, int32, int32, int32) - create a UUID from the 128-bits of 4x int32.
	-- sym.uuid(string) - create a UUID from a UUID string i.e. 20b62468-84b7-33ae-858d-df7e81691ba6
	-- tested with 10m UUIDs without conflict.
	function sym.uuid(a, b, c, d, e)
		local uuid = UUID()

		if isstring(a) then
			local v = a
			a = tonumber("0x" .. string.sub(v, 0, 8))
			b = tonumber("0x" .. string.sub(v, 10, 13) .. string.sub(v, 15, 18))
			c = tonumber("0x" .. string.sub(v, 20, 23) .. string.sub(v, 25, 28))
			d = tonumber("0x" .. string.sub(v, 29, 36))
		end

		if d then
			uuid.data = {a, b, c, d}
		else
			-- Technically could do this in two (Lua numbers are 64-bit), but I'm not
			-- confident it'll play nice.
			uuid.data = {math.Truncate(math.Rand(0, 4294967295)), math.Truncate(math.Rand(0, 4294967295)), math.Truncate(math.Rand(0, 4294967295)), math.Truncate(math.Rand(0, 4294967295))}
		end

		if a == true or e == true then return tostring(uuid) end

		return uuid
	end
end