AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include("shared.lua")


function ENT:OnSpawn( PObj )
	local DriverSeat = self:AddDriverSeat(Vector(105, 45, 0), Angle(0, 270, 0))
	
	
	
	self:AddEngine( Vector(100,0,45) )
	self:AddFuelTank( Vector(0,100,19), Angle(0,0,0), 600, LVS.FUELTYPE_DIESEL )
	
	
	local WheelModel = "models/sstrp/m757/m757_wheel_test.mdl"
	

	
	local FrontAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = Angle(0,0,0),
			SteerType = LVS.WHEEL_STEER_FRONT,
			SteerAngle = 30,
			TorqueFactor = 0.3,
			BrakeFactor = 1,
		},
		Wheels = {
			
			self:AddWheel( {
				pos = Vector(63, 60, -7.5),
				mdl = WheelModel,
				mdl_ang = Angle(0,180,0),
			} ),

			self:AddWheel( {
				pos = Vector(63, -60, -7.5),
				mdl = WheelModel,
				mdl_ang = Angle(0,0,0),
			} ),
			
		},
		Suspension = {
			Height = 20,
			MaxTravel = 10,
			ControlArmLength = 25,
			SpringConstant = 17000,
			SpringDamping = 1000,
			SpringRelativeDamping = 1000,
		},
	} )
	

	local RearAxle = self:DefineAxle( {
		Axle = {
			ForwardAngle = Angle(0,0,0),
			SteerType = LVS.WHEEL_STEER_REAR,
			SteerAngle = 5,
			TorqueFactor = 0.7,
			BrakeFactor = 0.5,
			UseHandbrake = true,
		},
		Wheels = {
			
			self:AddWheel( {
				pos = Vector(-103,60,-7.5),
				mdl = WheelModel,
				mdl_ang = Angle(0,180,0),
			} ),
			
			self:AddWheel( {
				pos = Vector(-103,-60, -7.5),
				mdl = WheelModel,
				mdl_ang = Angle(0,0,0),
			} )
		},
		Suspension = {
			Height = 20,
			MaxTravel = 10,
			ControlArmLength = 25,
			SpringConstant = 17000,
			SpringDamping = 1000,
			SpringRelativeDamping = 1000,
		},
	} )
	
	self:AddTrailerHitch( Vector(-76,0,25), LVS.HITCHTYPE_MALE )
	
end

