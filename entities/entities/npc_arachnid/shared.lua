AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Arachnid"
ENT.Author = "Xalphox"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_BOTH

Arachnid = ENT

ENT.Tasks = {}
function ENT:RegisterTask(name, start, think, finish)
    assert(self == ENT, "RegisterTask must be called with ENT as self")
    self.Tasks[name] = {
        Name = name,
        Start = start,
        Think = think,
        Finish = finish
    }
end

ENT:RegisterTask("Initialize", 
    function (self, data)
        data.End = CurTime() + self:SequenceDuration(self:GetSequence("as_warriorsoldier_taunt_01"))
        if CLIENT then
            self:ResetSequence("as_warriorsoldier_taunt_01")
            timer.Simple(0.25, function ()
                self:EmitSound("sstrp/arachnids/vocals/A_WarriorSoldier_Taunt_VeryClose_01.ogg")
            end)
        end
    end,
    function (self, data)
        if CurTime() > data.End then
            return true
        end
    end,
    function (self, data)
        print("Finish!")
    end
)

ENT:RegisterTask("Taunt01", 
    function (self, data)
        data.End = CurTime() + SoundDuration("sstrp/arachnids/vocals/A_WarriorSoldier_Taunt_VeryClose_01.ogg")
        if CLIENT then
            self:EmitSound("sstrp/arachnids/vocals/A_WarriorSoldier_Taunt_VeryClose_01.ogg")
        end
    end,
    function (self, data)
        if CurTime() > data.End then
            return true
        end
    end,
    function (self, data)
        print("Finish!")
    end
)

function ENT:Initialize()
    self:SetModel("models/arachnid_warrior_soldier.mdl")
    self:UseClientSideAnimation(true)
    self:ResetSequence("as_warriorsoldier_idle_01")

	if SERVER then
		self:PhysicsInitBox(Vector(-64, -64, 0), Vector(64, 64, 110))
	end
    
    self.Queue = {}
    self:Enqueue("Initialize")
    if CLIENT then
        self:SetNextClientThink(CurTime() + engine.TickInterval() * 50)
    end

    self:SetPoseParameter("up_jaw", math.Rand(-90, 90))
    self:SetPoseParameter("lw_jaw", math.Rand(-90, 90))
end

function ENT:Enqueue(taskName, data, priority)
    local t = {
        Name = taskName,
        Data = data or {},
        Priority = priority or 0,
        Task = self.Tasks[taskName]
    }

    table.insert(self.Queue, t)
    debounce(self, 0.1, function ()
        table.SortByMember(self.Queue, "Priority", true)
    end)
end




function ENT:FindEnemy()
    for k, v in pairs(player.GetAll()) do
        if v:Alive() then
            return v
        end
    end
end

function ENT:Think()

    self:FrameAdvance()

    if not ET then
        print("ET!", engine.TickCount())
        ET = true
    end

    local enemy = player.GetAll()[1]

    if CLIENT then
        local lookAt = enemy:EyePos()
        local angle = ((self:GetPos() + Vector(0, 0, 64)) - lookAt):Angle() - self:GetAngles()

        local pitch = math.NormalizeAngle(angle.p)
        local yaw = math.NormalizeAngle(angle.y + 180)

        self:SetPoseParameter("head_pitch", -pitch * 4)
        self:SetPoseParameter("head_yaw", yaw * 2)
    end

    if not self.Task then
        local t = table.remove(self.Queue, 1)
        if t then
            t.Task.Start(self, t.Data, self.Task)
            self.Task = t
        end
    else
        if self.Task.Task.Think(self, self.Task.Data) == true then
            self.Task.Task.Finish(self, self.Task.Data, self.Task)
            self.Task = nil
        end
    end

    if CLIENT then
        self:SetNextClientThink(0)
    end
end


list.Set("NPC", "npc_arachnid", {
    Name = "Arachnid",
    Class = "npc_arachnid",
    Category = "2025 - Arachnids"
})