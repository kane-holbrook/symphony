print("Starting Symphony")

include("shared.lua")

net.Receive("Symphony:NoX64", function (ply)
    ply:Kick("This server requires you to be on the x86-64 branch of Garry's Mod. Read more at https://sstrp.net/x64.")
end)

util.AddNetworkString("Symphony:NoX64")

hook.Add("PlayerInitialSpawn", "Symphony", function (ply)
	timer.Simple(1, function()
		if not IsValid(ply) then
			return
		end

		--ply:KillSilent()
		--ply:StripAmmo()
        --ply:SetNoDraw(true)
	end)
end)

rtc.Receive("Symphony:Init", function (len, ply)

    Promise.Run(function ()
        local account = Type.Account:Select(ply:SteamID64()):Await()
        account = account[1]
        
        if not account then
            account = Type.New(Type.Account)
            account:SetSteamID(ply:SteamID64())
            account:SetCreatedTime(DateTime())
        end
        account:SetName(ply:Nick())
        account:SetLastJoinTime(DateTime())

        local ip = string.Split(ply:IPAddress(), ":")[1]
        account:SetIPAddress(ip)

        local body = util.JSONToTable(http.FetchAsync("https://proxycheck.io/v2/" .. ip .. "?key=98a85m-f1h3g6-421672-488760&vpn=1&asn=1"):Await())[ip]
        local long = math.Round(tonumber(body.longitude), 1) -- To preserve privacy and comply with DPA
        local lat = math.Round(tonumber(body.latitude), 1)

        account:SetCity(body.city)
        account:SetCountry(body.country)
        account:SetTimezone(body.timezone)
        account:SetLongitude(long)
        account:SetLatitude(lat)
        account:SetProxy(body.proxy == "yes")
        account:Commit():Await()
        ply:SetAccount(account)

        local conn = Type.New(Type.Connection)
        conn:SetTime(DateTime())
        conn:SetSteamID(ply:SteamID64())
        conn:SetName(ply:Nick())
        conn:SetIPAddress(ip)
        conn:SetCity(body.city)
        conn:SetCountry(body.country)
        conn:SetTimezone(body.timezone)
        conn:SetLongitude(long)
        conn:SetLatitude(lat)
        conn:SetProxy(body.proxy == "yes")
        conn:Commit() -- Fire and forget

        local characters = Type.Character:Select("SteamID", ply:SteamID64()):Await()
        ply.Characters = characters

        local max = 0
        local mostRecent
        for k, v in pairs(characters) do
            if not v:GetInventory() then
                local inv = Type.New(Type.CharacterInventory)
                v:SetInventory(inv)
            end

            if not v:GetAttributes() then
                v:SetAttributes({})
            end

            local t = v:GetLastJoinTime():GetUnixTime()
            if t > max then
                max = t
                mostRecent = v
            end
        end

        if mostRecent then
            Type.Character.Select(ply, mostRecent:GetId())
            mostRecent:GetInventory():AddReceiver(ply)
            ply:SetCharacter(mostRecent)
            ply:SetNW2String("CharId", tostring(mostRecent:GetId()))
            ply:SetNW2String("CharName", mostRecent:GetName())
        end

        rtc.Start("Symphony:Init")
            rtc.WriteObject(account)
            rtc.WriteObject(characters)
            rtc.WriteString(mostRecent and mostRecent:GetId())
        rtc.Send(ply)
    end)
end)

function sym.Save()
    for k, v in pairs(player.GetAll()) do
        local acc = v:GetAccount()
        if acc then
            local chr = v:GetCharacter()
            if chr then
                chr:Commit()
            end
            acc:Commit()
        end
    end
end

timer.Create("Symphony.SaveTimer", 60, 0, sym.Save)