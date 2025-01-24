AddCSLuaFile()

--
-- DATETIME
--
do
	local MONTHS = {
		["january"] = 1,
		["jan"] = 1,
		["february"] = 2,
		["feb"] = 2,
		["march"] = 3,
		["mar"] = 3,
		["april"] = 4,
		["apr"] = 4,
		["may"] = 5,
		["june"] = 6,
		["jun"] = 6,
		["july"] = 7,
		["jul"] = 7,
		["august"] = 8,
		["aug"] = 8,
		["september"] = 9,
		["sep"] = 9,
		["october"] = 10,
		["oct"] = 10,
		["november"] = 11,
		["nov]"] = 11,
		["december"] = 12,
		["dec"] = 12
	}

	-- Define the DateTime class
	local DateTime = sym.RegisterType("datetime")
	DateTime:AddProperty("UnixTime", sym.types.number)
	DateTime.__dbtype = "DATETIME"

	function DateTime:__tostring()
		return os.date("%Y-%m-%d %H:%M:%S", self:GetProperty("UnixTime"))
	end

	function DateTime:toFileString()
		return os.date("%Y-%m-%d %H-%M-%S", self:GetProperty("UnixTime"))
	end

	function DateTime:toDateString()
		return os.date("%Y-%m-%d", self:GetProperty("UnixTime"))
	end

	function DateTime:toTimeString()
		return os.date("%H:%M:%S", self:GetProperty("UnixTime"))
	end

	function DateTime:DbWrite(wv)
		if not wv or not wv:GetProperty("UnixTime") then
			return nil
		end

		return "\"" .. sym.db.hndl:escape(os.date("%Y-%m-%d %H:%M:%S", wv:GetUnixTime())) .. "\""
	end

	function DateTime:DbRead(value)
		if not value then
			return nil
		end
		
		local year = tonumber(value:sub(1, 4))
		local month = tonumber(value:sub(6, 7))
		local day = tonumber(value:sub(9, 10))
		local hour = tonumber(value:sub(12, 13))
		local min = tonumber(value:sub(15, 16))
		local sec = tonumber(value:sub(18, 19))

		local timestamp = os.time({
			year = year,
			month = month,
			day = day,
			hour = hour,
			min = min,
			sec = sec
		})

		return sym.datetime(timestamp)
	end

	-- Additional methods for manipulating DateTime objects using timestamps
	function DateTime:addSeconds(seconds)
		return sym.datetime(self:GetProperty("UnixTime") + seconds)
	end

	function DateTime:addMinutes(minutes)
		return self:addSeconds(minutes * 60)
	end

	function DateTime:addHours(hours)
		return self:addMinutes(hours * 60)
	end

	function DateTime:addDays(days)
		return self:addHours(days * 24)
	end

	function DateTime:subtractSeconds(seconds)
		return self:addSeconds(-seconds)
	end

	function DateTime:subtractMinutes(minutes)
		return self:addMinutes(-minutes)
	end

	function DateTime:subtractHours(hours)
		return self:addHours(-hours)
	end

	function DateTime:subtractDays(days)
		return self:addDays(-days)
	end

	function DateTime:Add(other)
		if (other.seconds) then
			return self:addSeconds(other.seconds)
		end
		return sym.timespan(self:GetProperty("UnixTime") - other:GetProperty("UnixTime"))
	end

	function DateTime:Sub(other)
		if sym.types.timespan:IsInstance(other) then return self:subtractSeconds(other:toSeconds()) end
		local timeDifference = self:GetProperty("UnixTime") - other:GetProperty("UnixTime")

		return sym.timespan(timeDifference)
	end

	function DateTime:addTimeSpan(timespan)
		return self:addSeconds(timespan:toSeconds())
	end

	function DateTime:subTimeSpan(timespan)
		return self:addSeconds(-timespan:toSeconds())
	end

	function DateTime:__add(x)
		if istable(x) then
			return self:Add(x)
		else
			return self:addSeconds(x)
		end
	end

	function DateTime:__sub(x)
		if istable(x) then
			return self:Sub(x)
		else
			return self:subtractSeconds(x)
		end
	end

	function DateTime:__lt(x)
		return self:GetProperty("UnixTime") < x.timestamp
	end

	function DateTime:__le(x)
		return self:GetProperty("UnixTime") <= x.timestamp
	end

	function DateTime:__eq(x)
		return self:GetProperty("UnixTime") == x.timestamp
	end

	function DateTime:__serialize()
		return self:GetProperty("UnixTime")
	end

	function DateTime:__deserialize(data)
		return sym.datetime(data)
	end

	function DateTime:__netwrite()		
		net.WriteUInt64(self:GetProperty("UnixTime"))
	end

	function DateTime:__netread()
		return DateTime(net.ReadUInt64())
	end

	function sym.datetime(timestamp)
		local dt = DateTime()
		dt:SetUnixTime(timestamp or os.time())
		
		return dt
	end
end

--
-- TIMESPAN
--
do
	-- Define the TimeSpan class
	local TimeSpan = sym.RegisterType("timespan")

	function TimeSpan:__tostring()
		local days = math.floor(self.seconds / 86400)
		local remainingSeconds = self.seconds % 86400
		local hours = math.floor(remainingSeconds / 3600)
		remainingSeconds = remainingSeconds % 3600
		local minutes = math.floor(remainingSeconds / 60)
		local seconds = remainingSeconds % 60

		if days > 0 then
			return string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
		else
			return string.format("%02d:%02d:%02d", hours, minutes, seconds)
		end
	end

	function TimeSpan:ToRelativeString(detailed)
		local x = self:toSeconds()
		
		if not detailed then
			-- Original non-detailed logic here
			local days = math.floor(x / (3600 * 24))
			if days >= 30 then
				local months = math.floor(days / 30)
				return months .. (months == 1 and " month" or " months")
			elseif days >= 7 then
				local weeks = math.floor(days / 7)
				return weeks .. (weeks == 1 and " week" or " weeks")
			elseif days >= 1 then
				return days .. (days == 1 and " day" or " days")
			else
				-- Handle hours, minutes, seconds as before
				local hours = math.floor(x / 3600)
				if hours >= 1 then
					return hours .. (hours == 1 and " hour" or " hours")
				end

				local minutes = math.floor(x / 60)
				if minutes >= 1 then
					return minutes .. (minutes == 1 and " minute" or " minutes")
				end

				local seconds = math.floor(x)
				return seconds .. (seconds == 1 and " second" or " seconds")
			end
		end

		-- Detailed logic for breakdown
		local components = {}

		local years = math.floor(x / (3600 * 24 * 365))
		x = x % (3600 * 24 * 365)
		if years > 0 then
			table.insert(components, years .. (years == 1 and " year" or " years"))
		end

		local months = math.floor(x / (3600 * 24 * 30))
		x = x % (3600 * 24 * 30)
		if months > 0 then
			table.insert(components, months .. (months == 1 and " month" or " months"))
		end

		local weeks = math.floor(x / (3600 * 24 * 7))
		x = x % (3600 * 24 * 7)
		if weeks > 0 then
			table.insert(components, weeks .. (weeks == 1 and " week" or " weeks"))
		end

		local days = math.floor(x / (3600 * 24))
		x = x % (3600 * 24)
		if days > 0 then
			table.insert(components, days .. (days == 1 and " day" or " days"))
		end

		local hours = math.floor(x / 3600)
		x = x % 3600
		if hours > 0 then
			table.insert(components, hours .. (hours == 1 and " hour" or " hours"))
		end

		local minutes = math.floor(x / 60)
		x = x % 60
		if minutes > 0 then
			table.insert(components, minutes .. (minutes == 1 and " minute" or " minutes"))
		end

		local seconds = math.floor(x)
		x = x % 1  -- Keep the remainder (fractional seconds) for milliseconds
		if seconds > 0 then
			table.insert(components, seconds .. (seconds == 1 and " second" or " seconds"))
		end

		local milliseconds = math.floor(x * 1000) -- Convert fractional seconds to milliseconds
		if milliseconds > 0 then
			table.insert(components, milliseconds .. (milliseconds == 1 and " millisecond" or " milliseconds"))
		end

		-- Build the final string
		local result = table.concat(components, ", ")
		local lastComma = result:find(",[^,]*$")
		if lastComma then
			result = result:sub(1, lastComma - 1) .. " and" .. result:sub(lastComma + 1)
		end

		return result
	end




	-- Additional methods for manipulating TimeSpan objects
	function TimeSpan:addSeconds(seconds)
		self.seconds = self.seconds + seconds
	end

	function TimeSpan:addMinutes(minutes)
		self:addSeconds(minutes * 60)
	end

	function TimeSpan:addHours(hours)
		self:addMinutes(hours * 60)
	end

	function TimeSpan:addDays(days)
		self:addHours(days * 24)
	end

	function TimeSpan:subtractSeconds(seconds)
		self:addSeconds(-seconds)
	end

	function TimeSpan:subtractMinutes(minutes)
		self:addMinutes(-minutes)
	end

	function TimeSpan:subtractHours(hours)
		self:addHours(-hours)
	end

	function TimeSpan:subtractDays(days)
		self:addDays(-days)
	end

	function TimeSpan:toSeconds()
		return self.seconds
	end

	function TimeSpan:toMinutes()
		return self.seconds / 60
	end

	function TimeSpan:toHours()
		return self.seconds / 3600
	end

	function TimeSpan:toDays()
		return self.seconds / 86400
	end
	

	function TimeSpan:__serialize()
		return self.seconds
	end

	function TimeSpan:__deserialize(data)
		return sym.timespan(data)
	end

	function TimeSpan:__netwrite()
		return self.seconds
	end

	function TimeSpan:__netread()
		self.seconds = data
	end

	local TIME_UNITS = {}
	TIME_UNITS["ms"] = 0.001 -- Seconds
	TIME_UNITS["s"] = 1 -- Seconds
	TIME_UNITS["m"] = 60 -- Minutes
	TIME_UNITS["h"] = 3600 -- Hours
	TIME_UNITS["d"] = TIME_UNITS["h"] * 24 -- Days
	TIME_UNITS["w"] = TIME_UNITS["d"] * 7 -- Weeks
	TIME_UNITS["wk"] = TIME_UNITS["d"] * 7 -- Weeks
	TIME_UNITS["mo"] = TIME_UNITS["d"] * 30 -- Months
	TIME_UNITS["y"] = TIME_UNITS["d"] * 365 -- Years
	TIME_UNITS["yr"] = TIME_UNITS["d"] * 365 -- Years

	local function getStringTime(text)
		local time = 0

		for amount, unit in text:lower():gmatch("(%d+)(%a+)") do
			amount = tonumber(amount)

			if amount and TIME_UNITS[unit] then
				time = time + math.abs(amount * TIME_UNITS[unit])
			end
		end

		return sym.timespan(time)
	end

	function TimeSpan:FromString(s)
		return getStringTime(s)
	end

	function TimeSpan:GetParameterWrapper(panel, p, text, active)
		return "<span class='parameter " .. (active and "active" or "") .. "'><span class='parameter-hint'>🕐 " .. stringex.EscapeHTML(p:GetName() or "") .. ":</span><span class='parameter-content'>" .. stringex.EscapeHTML(text or "") .. "</span></span>"
	end

	function sym.timespan(seconds)
		local t = setmetatable({}, TimeSpan)

		if isnumber(seconds) then
			t.seconds = seconds
		else
			t.seconds = getStringTime(seconds)
		end

		return t
	end
end