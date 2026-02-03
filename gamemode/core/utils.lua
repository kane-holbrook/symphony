AddCSLuaFile()

function isany(t, ...)
    for k, v in pairs({...}) do
        if t == v then
            return true
        end
    end
    return false
end

function currentfile(n)
    local info = debug.getinfo(2 + (n or 0), "Sl")
    assert(info, "Could not get debug info!")
    return info.short_src
end

function GetServerIP()
    return string.Split(game.GetIPAddress(), ":")[1]
end

function GetServerPort()
    return tonumber(string.Split(game.GetIPAddress(), ":")[2])
end

function GC(destructor)
    local proxy = newproxy(true)
    getmetatable(proxy).__gc = function()
        destructor(t)
    end
    return proxy
end

function uuid()
    -- Generate RFC 4122 compliant UUID v4
    local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 15) or math.random(8, 11)
        return string.format('%x', v)
    end)
end


function callable(func, t)
    local t = t or { Func = func }
    setmetatable(t, {
        __call = function (self, ...)
            return self.Func(...)
        end,
        __tostring = function (self)
            return "callable[" .. string.sub(tostring(self.Func), 11, -1) .. "]"
        end,
    })
    return t
end

function iscallable(obj)
    if isfunction(obj) then
        return true
    elseif istable(obj) then
        return getmetatable(obj).__call ~= nil
    else
        return false
    end
end



-- Hook extensions
hook.AddRaw = hook.AddRaw or hook.Add
hook.RemoveRaw = hook.RemoveRaw or hook.Remove

function hook.Add(name, identifier, func)
    if not func then
        func = identifier
        identifier = nil
    end

    identifier = identifier or currentfile(1)
    return hook.AddRaw(name, identifier, func)
end

function hook.Remove(name, identifier)
    if not func then
        func = identifier
        identifier = nil
    end
    
    identifier = identifier or currentfile(1)
    return hook.RemoveRaw(name, identifier)
end

function include_sv(path)
    if SERVER then
        return include(path)
    end
end

function include_cl(path)
    if CLIENT then
        return include(path)
    else
        AddCSLuaFile(path)
    end
end


function include_sh(path)
    AddCSLuaFile(path)
    return include(path)
end


local weakkey = { __mode = "k" }
local weakvalue = { __mode = "v" }
local weakboth = { __mode = "kv" }
function weaktable(k, v)
    local mt = weakboth
    if k and v then
        mt = weakboth
    elseif k and not v then
        mt = weakkey
    else
        mt = weakvalue
    end

    return setmetatable({}, mt)
end


function wrapfunc(f)
    if istable(f) then
        return f
    end

    local c = {}
	setmetatable(c, { __call = f })
    return c
end

function hook.Once(name, func)
    local key = uuid()
    hook.Add(name, key, function (...)
        hook.Remove(name, key)
        return func(...)
    end)
end 


local debouncers = {}
function debounce(time, identifier, func, ...)
    if not func then
        func = identifier
        identifier = nil
    end

    identifier = identifier or currentfile(1)
    debouncers[identifier] = debouncers[identifier] or true
    local args = {...}
    timer.Simple(time, function ()
        debouncers[identifier] = nil
        func(unpack(args))
    end)
end



function Deref(t, ...)
    for k, v in pairs({...}) do
        if not t then
            return nil
        end

        local n = t[v]
        if isfunction(n) then
            n = n(t)
        end
        t = n
    end
    return t
end


function http.FetchAsync(url, headers)
    local p = Promise.Create()
    http.Fetch(url, function (...)
        p:Complete(...)
    end, function (err)
        p:ThrowError(err)
    end, headers)
    return p
end

function ModelString(path)
	return unpack(string.Split(path, "?"))
end

function nticks(n, func, ...)
    local id = uuid()
    local args = {...}
    hook.Add("Tick", id, function()
        n = n - 1
        if n == 0 then
            func(unpack(args))
            hook.Remove("Tick", id)
        end
    end)
end

function MonthToNumber(month)
    local months = {
        January = 1,
        February = 2,
        March = 3,
        April = 4,
        May = 5,
        June = 6,
        July = 7,
        August = 8,
        September = 9,
        October = 10,
        November = 11,
        December = 12,
    }

    return months[month]
end

function NumberToMonth(num)
    local months = {
        [1] = "January",
        [2] = "February",
        [3] = "March",
        [4] = "April",
        [5] = "May",
        [6] = "June",
        [7] = "July",
        [8] = "August",
        [9] = "September",
        [10] = "October",
        [11] = "November",
        [12] = "December",
    }

    return months[num]
end



function CreateEffect()
    local EFFECT = {}
    EFFECT.Folder = ""
    return EFFECT
end

-- weapons.Register(SWEP, name)
function CreateSWEP()
	local SWEP = {}
	SWEP.Category = "Other"
	SWEP.Spawnable = false
	SWEP.AdminOnly = false
	SWEP.PrintName = "Scripted Weapon"
	SWEP.Base = "weapon_base"
	SWEP.m_WeaponDeploySpeed = 1
	SWEP.Author = ""
	SWEP.Contact = ""
	SWEP.Purpose = ""
	SWEP.Instructions = ""
	SWEP.ViewModel = "models/weapons/v_pistol.mdl"
	SWEP.ViewModelFlip = false
	SWEP.ViewModelFlip1 = false
	SWEP.ViewModelFlip2 = false
	SWEP.ViewModelFOV = 62
	SWEP.WorldModel = "models/weapon/w_357.mdl"
	SWEP.AutoSwitchFrom = true
	SWEP.AutoSwitchTo = true
	SWEP.Weight = 5
	SWEP.BobScale = 1
	SWEP.SwayScale = 1
	SWEP.BounceWeaponIcon = true
	SWEP.DrawWeaponInfoBox = true
	SWEP.DrawAmmo = true
	SWEP.DrawCrosshair = true
	SWEP.RenderGroup = RENDERGROUP_OPAQUE
	SWEP.Slot = 0
	SWEP.SlotPos = 10
	if CLIENT then
		SWEP.SpeechBubbleLid = surface.GetTextureID("gui/speech_lid")
		SWEP.WepSelectIcon = surface.GetTextureID("weapon/swep")
	end
	SWEP.CSMuzzleFlashes = false
	SWEP.CSMuzzleX = false
	SWEP.Primary =
	{
	--	Ammo = "Pistol",
	--	ClipSize = 0,
	--	DefaultClip = 0,
	--	Automatic = false
	}
	SWEP.Secondary = {}
	SWEP.AccurateCrosshair = false
	SWEP.DisableDuplicator = false
	SWEP.ScriptedEntityType = "weapon"
	SWEP.m_bPlayPickupSound = true
	return SWEP
end

function CreateEntity()
    local ENT = {}
    ENT.Folder = stringex.SubstringBeforeLast(currentfile(1), "/")
    return ENT
end


local ENT = FindMetaTable("Entity")
if CLIENT then
    function ENT:DeleteOnRemove(ent)
        self._DeleteOnRemove = self._DeleteOnRemove or {}
        self._DeleteOnRemove[ent] = true
    end

    function ENT:DontDeleteOnRemove(ent)
        if self._DeleteOnRemove then
            self._DeleteOnRemove[ent] = nil
        end
    end

    hook.Add("EntityRemoved", "Core_EntityDeleteOnRemove", function(ent)
        if ent._DeleteOnRemove then
            for k, v in pairs(ent._DeleteOnRemove) do
                if IsValid(k) then
                    k:Remove()
                end
            end
        end
    end)
end