ENT.Base = "lvs_base_wheeldrive"
ENT.PrintName = "M757"
ENT.Author = "Molot"
ENT.Information = "Luna's Vehicle Script"
ENT.Category = "[LVS] Molot"

ENT.Spawnable			= true -- set to "true" to make it spawnable
ENT.AdminSpawnable		= false

ENT.SpawnNormalOffset = 90 -- spawn normal offset, raise to prevent spawning into the ground
--ENT.SpawnNormalOffsetSpawner = 0 -- offset for ai vehicle spawner

ENT.MDL = "models/sstrp/m757/m757_nochairs_test.mdl"
ENT.AITEAM = 0




ENT.MaxHealth = 9000 -- max health

--ENT.DSArmorDamageReduction = 0.1 -- damage reduction multiplier. Damage is clamped to a minimum of 1 tho
--ENT.DSArmorDamageReductionType = DMG_BULLET + DMG_CLUB -- which damage type to damage reduce

--ENT.DSArmorIgnoreDamageType = DMG_SONIC -- ignore this damage type completely
--ENT.DSArmorIgnoreForce = 1000 -- add general immunity against small firearms, 1000 = 10mm armor thickness
--ENT.DSArmorBulletPenetrationAdd = 250 -- changes how far bullets can cheat through the body to hit critical hitpoints and armor


--[[
PLEASE READ:
	Ideally you only need change:

	ENT.MaxVelocity -- to change top speed
	ENT.EngineTorque -- to change acceleration speed
	ENT.EngineIdleRPM -- optional: only used for rpm gauge. This will NOT change engine sound.
	ENT.EngineMaxRPM -- optional: only used for rpm gauge. This will NOT change engine sound.

	ENT.TransGears -- in a sane range based on maxvelocity. Dont set 10 gears for a car that only does 10kmh this will sound like garbage. Ideally use a total of 3 - 6 gears

	I recommend keeping everything else at default settings.
	(leave them commented-out or remove them from this script)
]]

ENT.MaxVelocity = 1400 -- max velocity in forward direction in gmod-units/second
ENT.MaxVelocityReverse = 700 -- max velocity in reverse

--ENT.EngineCurve = 0.65 -- value goes from 0 to 1. Get into a car and type "developer 1" into the console to see the current engine curve
--ENT.EngineCurveBoostLow = 1 -- first gear torque boost multiplier
ENT.EngineTorque = 600
ENT.EngineIdleRPM = 900
ENT.EngineMaxRPM = 2700

ENT.ThrottleRate = 1 -- modify the throttle update rate, see it as the speed with which you push the pedal

--ENT.ForceLinearMultiplier = 1 -- multiply all linear forces (such as downforce, wheel side force, ect)
--ENT.ForceAngleMultiplier = 0.5 -- multiply all angular forces such turn stability / inertia. Exception: Wheel/Engine torque. Those remain unchanged.

ENT.TransGears = 5 -- amount of gears in forward direction. NOTE: the engine sound system calculates the  gear ratios based on topspeed and amount of gears. This can not be changed.
ENT.TransGearsReverse = 1 -- amount of gears in reverse direction
ENT.TransMinGearHoldTime = 3 -- minimum time the vehicle should stay in a gear before allowing it to shift again.
ENT.TransShiftSpeed = 0.7 -- in seconds. How fast the transmission handles a shift. The transmission mimics a manual shift by applying clutch, letting off throttle, releasing clutch and applying throttle again even tho it is automatic.
--ENT.TransWobble = 40 -- basically how much "play" is in the drivedrain. 
--ENT.TransWobbleTime = 1.5 -- in seconds. How long after a shift or after applying throttle the engine will wobble up and down in rpm
--ENT.TransWobbleFrequencyMultiplier = 1 -- changes the frequency of the wobble
ENT.TransShiftSound = "kamaz/gear__3.wav"  

--ENT.SteerSpeed = 3 -- steer speed
--ENT.SteerReturnSpeed = 10 -- steer return speed to neutral steer

--ENT.FastSteerActiveVelocity = 500 -- at which velocity the steering will clamp the steer angle
--ENT.FastSteerAngleClamp = 10 -- to which the steering angle is clamped to when speed is above ENT.FastSteerActiveVelocity
--ENT.FastSteerDeactivationDriftAngle = 7 -- allowed drift angle until ENT.FastSteerActiveVelocity is ignored and the steering becomes unclamped

--ENT.SteerAssistDeadZoneAngle = 1 -- changes how much drift the counter steer system allows before interfering. 1 = 1° of drift without interfering
--ENT.SteerAssistMaxAngle = 15 -- max steering angle the counter steer system is allowed to help the player
--ENT.SteerAssistExponent = 1.5 -- an exponent to the counter steering curve. Just leave it at 1.5
--ENT.SteerAssistMultiplier = 3 -- how "quick" the counter steer system is steering

--ENT.MouseSteerAngle = 20 -- smaller value = more direct steer   bigger value = smoother steer, just leave it at 20
--ENT.MouseSteerExponent = 2 -- just leave it at 2. Fixes wobble.

ENT.PhysicsWeightScale = 1 -- this is the value you need to change in order to make a vehicle feel heavier. Just leave it at 1 unless you really need to change it
--ENT.PhysicsMass = 1000 -- do not mess with this unless you can balance everything yourself again.
--ENT.PhysicsInertia = Vector(1500,1500,750) -- do not mess with this unless you can balance everything yourself again.
--ENT.PhysicsDampingSpeed = 4000 -- do not mess with this unless you can balance everything yourself again.

--ENT.PhysicsDampingForward = true -- internal physics damping to reduce wobble. Just keep it enabled in forward direction.
--ENT.PhysicsDampingReverse = false -- disabling this in reverse allows for a reverse 180° turn. If you want to go fast in reverse you should set this to true in order to get good stability

--ENT.WheelPhysicsMass = 100 -- do not mess with this unless you can balance everything yourself again.
--ENT.WheelPhysicsInertia = Vector(10,8,10) -- do not mess with this unless you can balance everything yourself again.

--ENT.WheelBrakeAutoLockup = false -- set this to true for offroad vehicles. This will engage the brake automatically so you dont have to keep holding the brake/handbrake button
--ENT.WheelBrakeAutoLockupReverseVelocity = 50 -- below/above this velocity, the transmission will auto shift into forward/reverse when ENT.WheelBrakeAutoLockup = true
--ENT.WheelBrakeLockupRPM = 50 -- wheel rpm in which the auto-brake is enabled

--ENT.WheelBrakeForce = 400 -- how strong the brakes are. Just leave at 400. Allows for good braking while still allowing some turning. It has some build in ABS but it isnt perfect because even tho velocities say it isnt sliding the wheel will still visually slide in source...

--ENT.WheelSideForce = 800 -- basically a sideways cheatforce that gives you better stability in turns. You shouldn't have to edit this.
--ENT.WheelDownForce = 500 -- wheels use jeeptire as physprop. To this a downward force is applied to increase traction. You shouldn't have to edit this.

--ENT.AllowSuperCharger = true -- allow this vehicle to equip a supercharger?
--ENT.SuperChargerVolume = 1 -- change superchager sound volume
--ENT.SuperChargerSound = "lvs/vehicles/generic/supercharger_loop.wav" -- change supercharger sound file

ENT.AllowTurbo = false -- allow this vehilce to equip a turbocharger?
ENT.TurboVolume = 1 -- change turbocharger sound volume
--ENT.TurboSound = "maz/maz_turbo.wav" -- change turbo sound file
--ENT.TurboBlowOff = {"lvs/vehicles/generic/turbo_blowoff1.wav","lvs/vehicles/generic/turbo_blowoff1.wav"} -- change blowoff sound. If you only have one file you can just pass it as a string instead of a table.

--ENT.DeleteOnExplode = false -- remove the vehicle when it explodes?

 --[[
--ENT.RandomColor = {} -- table with colors to set on spawn
	-- accepts colors and skin+color combo:

	-- example variant1:
	ENT.RandomColor = {
		Color(255,255,255),
		Color(255,255,255),
		Color(255,255,255),
		Color(255,255,255),
		Color(255,255,255),
		Color(255,255,255),
	}


	-- example variant2:
	ENT.RandomColor = {
		{
			Skin = 1,
			Color = Color(255,255,255),
			BodyGroups = {
				[1] = 3, -- set bodygroup 1 to 3
				[5] = 7, -- set bodygroup 5 to 7
			},
		},
		{
			Skin = 2,
			Color = Color(255,255,255),
		},
		{
			Skin = 3,
			Color = Color(255,255,255),
		},
		{
			Skin = 4,
			Color = Color(255,255,255),
		},
		{
			Skin = 5,
			Color = Color(255,255,255),
		},
		{
			Skin = 6,
			Color = Color(255,255,255),
			Wheels = {  -- can also color wheels in this variant
				Skin = 0,
				Color = Color(255,255,0),
			},
		},
	}
 ]]
 
ENT.HornSound = "kamaz/honk_heavy.wav"
--ENT.HornSoundInterior = "lvs/horn2.wav" -- leave it commented out, that way it uses the same as ENT.HornSound
ENT.HornPos = Vector(200,-100,0) -- horn sound position
 
 

	-- add a weapon:

function ENT:InitWeapons()
	local weapon = {}
	weapon.Icon = Material("lvs/weapons/horn.png")
	weapon.Ammo = -1
	weapon.Delay = 3
	weapon.HeatRateUp = 0
	weapon.HeatRateDown = 0
	weapon.UseableByAI = false
	weapon.Attack = function( ent ) end
	weapon.StartAttack = function( ent )
		if not IsValid( ent.HornSND ) then return end
		ent.HornSND:Play()
	end
	weapon.FinishAttack = function( ent )
		if not IsValid( ent.HornSND ) then return end
		ent.HornSND:Stop()
	end
	self:AddWeapon( weapon )
end

--[[ engine sounds ]]
-- valid SoundType's are:
-- LVS.SOUNDTYPE_IDLE_ONLY -- only plays in idle
-- LVS.SOUNDTYPE_NONE -- plays all the time except in idle
-- LVS.SOUNDTYPE_REV_UP -- plays when revving up
-- LVS.SOUNDTYPE_REV_DOWN -- plays when revving down
-- LVS.SOUNDTYPE_ALL -- plays all the time
ENT.EngineSounds = {
	{
		sound = "kamaz/kamaz_offroad_idle.wav",
		Volume = 2,
		Pitch = 85,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_IDLE_ONLY,
	},
	{
		sound = "kamaz/kamaz_offroad_high.wav",
		--sound_int = "path/to/interior/sound.wav",
		Volume = 2, -- adjust volume
		Pitch = 100, -- start pitch value
		PitchMul = 50, -- value that gets added to Pitch at max engine rpm
		SoundLevel = 100, -- if too quiet, adjust soundlevel.
		SoundType = LVS.SOUNDTYPE_NONE,
		UseDoppler = true, -- use doppler system?
	},
	{
		sound = "kamaz/kamaz_offroad_high.wav",
		Volume = 3,
		Pitch = 85,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_REV_UP,
	},
	{
		sound = "kamaz/kamaz_offroad_low.wav",
		Volume = 3,
		Pitch = 85,
		PitchMul = 25,
		SoundLevel = 75,
		SoundType = LVS.SOUNDTYPE_REV_DOWN,
	},
}


--[[ exhaust ]]

ENT.ExhaustPositions = {
	{
		pos = Vector(-15,-50,22),
		ang = Angle(0,-160,0),
	}
}


ENT.Lights = {
	{
		Trigger = "main",
		--SubMaterialID = 0,
		Sprites = {
			[1] = {
				pos = Vector(163,37,33),
				colorB = 200,
				colorA = 150,
			},
			[2] = {
				pos = Vector(163,-37,33),
				colorB = 200,
				colorA = 150,
			},
			

			[3] = {
				pos = Vector(-217,-36,20),
				colorG = 0,
				colorB = 0,
				colorA = 0,
			},
			[4] = {
				pos = Vector(-217,36,20),
				colorG = 0,
				colorB = 0,
				colorA = 0,
			},
		},
		ProjectedTextures = {
			[1] = {
				pos = Vector(163,37,33),
				ang = Angle(0,0,0),
				colorB = 200,
				colorA = 150,
				shadows = true,
			},
			[2] = {
				pos = Vector(163,-37,33),
				ang = Angle(0,0,0),
				colorB = 200,
				colorA = 150,
				shadows = true,
			},
		},
		
	},

	-- {
		-- Trigger = "fog",
	-- },
	{
		Trigger = "high",
		Sprites = {
			[1] = {
				pos = Vector(163,37,33),
				colorB = 200,
				colorA = 150,
			},
			[2] = {
				pos = Vector(163,-37,33),
				colorB = 200,
				colorA = 150,
			},
			[3] = {
				pos = Vector(163,37,33),
				colorB = 200,
				colorA = 150,
			},
			[4] = {
				pos = Vector(163,-37,33),
				colorB = 200,
				colorA = 150,
			},
		},
		ProjectedTextures = {
			[1] = {
				pos = Vector(163,37,33),
				ang = Angle(0,0,0),
				colorB = 200,
				colorA = 150,
				shadows = true,
			},
			[2] = {
				pos = Vector(163,-37,33),
				ang = Angle(0,0,0),
				colorB = 200,
				colorA = 150,
				shadows = true,
			},
			[3] = {
				pos = Vector(163,-37,33),
				ang = Angle(0,0,0),
				colorB = 200,
				colorA = 150,
				shadows = true,
			},
			[4] = {
				pos = Vector(163,-37,33),
				ang = Angle(0,0,0),
				colorB = 200,
				colorA = 150,
				shadows = true,
			},
		},
	},
	{

		Trigger = "brake",
		--SubMaterialID = 2,
		Sprites = {
			[1] = {
				pos = Vector(-217,-36,20),
				colorG = 0,
				colorB = 0,
				colorA = 0,
			},			
			[2] = {
				pos = Vector(-217,36,20),
				colorG = 0,
				colorB = 0,
				colorA = 0,
			},
		}
	},
	{

		Trigger = "reverse",
		--SubMaterialID = 2,
		Sprites = {
			[1] = {
				pos = Vector(-217,-34,20),
				colorA = 0
			},			
			[2] = {
				pos = Vector(-217,32,20),
				colorA = 0
			},
		}
	},
	
	}
-- see: https://raw.githubusercontent.com/Blu-x92/lvs_cars/main/zzz_ENT_lights_info.lua?token=GHSAT0AAAAAACFA53CXF42NMFHSXN5VQ2I4ZHD6NBQ
-- or https://discord.com/channels/1036581288653627412/1140195565368508427/1140195750207291403
