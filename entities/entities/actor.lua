AddCSLuaFile()

Actor = {}

Actor.Bases = {}

function Actor.AddBase(parent, t)
    if parent then
        setmetatable(t, { __index = parent})
    end
    table.insert(Actor.Bases, t)
    return t
end

local male_ref = Actor.AddBase(nil, { 
    Model = "models/sstrp25/human/heads/male_ref.mdl",
    Torso = { "models/sstrp25/human/body/male_upper.mdl" },
    Legs = { "models/sstrp25/human/body/male_lower.mdl" },

    Defaults = {
        Torso = { "models/xalphox/mi/male_torso_trooper.mdl", "000000011" },
        Legs = { "models/xalphox/mi/male_legs_trooper.mdl" }
    },

    TexFace = 0,
    TexEyeL = 1,
    TexEyeR = 2,
    TexBrow = 3,
    --[[TexLayer1 = 6,
    TexLayer2 = 7,
    TexFacialHair = 8,
    TexHands = 9,--]]

    Beards = {
        false,
        "models/sstrp25/human/hair/beard_lower1.mdl",
        "models/sstrp25/human/hair/beard_lower2.mdl",
        "models/sstrp25/human/hair/beard_lower3.mdl",
        "models/sstrp25/human/hair/beard_lower4.mdl",
        "models/sstrp25/human/hair/beard_lower5.mdl",
        "models/sstrp25/human/hair/beard_lower6.mdl",
        "models/sstrp25/human/hair/beard_lower7.mdl",
        "models/sstrp25/human/hair/beard_lower8.mdl",
        "models/sstrp25/human/hair/beard_lower9.mdl",            
    },

    Mustaches = {
        false,
        "models/sstrp25/human/hair/beard_upper1.mdl",
        "models/sstrp25/human/hair/beard_upper2.mdl",
        "models/sstrp25/human/hair/beard_upper3.mdl",
        "models/sstrp25/human/hair/beard_upper4.mdl",
        "models/sstrp25/human/hair/beard_upper5.mdl",
        "models/sstrp25/human/hair/beard_upper6.mdl",
        "models/sstrp25/human/hair/beard_upper7.mdl",
        "models/sstrp25/human/hair/beard_upper8.mdl",
        "models/sstrp25/human/hair/beard_upper9.mdl",
    },

    Hair = { 
        "models/sstrp25/human/hair/malebasehair.mdl",
        "models/sstrp25/human/hair/malehair00.mdl",
        "models/sstrp25/human/hair/malehair06.mdl",
        "models/sstrp25/human/hair/malehair07.mdl",
        "models/sstrp25/human/hair/malehair08.mdl",
        "models/sstrp25/human/hair/malehair11.mdl",
        "models/sstrp25/human/hair/malehair22.mdl",
        "models/sstrp25/human/hair/malehair23.mdl",
        "models/sstrp25/human/hair/malehair26.mdl",
        "models/sstrp25/human/hair/malehair27.mdl",
        "models/sstrp25/human/hair/malehair30.mdl",
        "models/sstrp25/human/hair/malehair33.mdl",
        "models/sstrp25/human/hair/malehair36.mdl",
        "models/sstrp25/human/hair/malehair37.mdl",
        "models/sstrp25/human/hair/malehair41.mdl",
        "models/sstrp25/human/hair/malehair44.mdl",
        "models/sstrp25/human/hair/malehair45.mdl",
        "models/sstrp25/human/hair/malehair49.mdl",
        "models/sstrp25/human/hair/malehair51.mdl",
        "models/sstrp25/human/hair/malehair53.mdl",
        "models/sstrp25/human/hair/malehair58.mdl",
        "models/sstrp25/human/hair/malehair59.mdl",
        "models/sstrp25/human/hair/malehair60.mdl",
        "models/sstrp25/human/hair/malehair61.mdl",
        "models/sstrp25/human/hair/malehair62.mdl",
        "models/sstrp25/human/hair/malehair63.mdl",
        "models/sstrp25/human/hair/malehair73.mdl",
        "models/sstrp25/human/hair/malehair74.mdl",
        "models/sstrp25/human/hair/malehair77.mdl",
        "models/sstrp25/human/hair/malehair84.mdl",
        "models/sstrp25/human/hair/malehair89.mdl",
        "models/sstrp25/human/hair/malehair99.mdl",
        "models/sstrp25/human/hair/malehair103.mdl",
        "models/sstrp25/human/hair/malehair104.mdl",
        "models/sstrp25/human/hair/malehair112.mdl",
        "models/sstrp25/human/hair/malehair113.mdl",
        "models/sstrp25/human/hair/malehair121.mdl",
        "models/sstrp25/human/hair/malehair140.mdl",
        "models/sstrp25/human/hair/malehair141.mdl",
        "models/sstrp25/human/hair/malehair143.mdl",
        "models/sstrp25/human/hair/malehair144.mdl",
        "models/sstrp25/human/hair/malehair145.mdl",
        "models/sstrp25/human/hair/malehair146.mdl",
    },
    
    Faces = {
        { "sstrp25/human/male_ref/face01", "sstrp25/human/male_ref/body" },
        { "sstrp25/human/male_ref/face02", "sstrp25/human/male_ref/body" },
        { "sstrp25/human/male_ref/face03", "sstrp25/human/male_ref/body" },
        { "sstrp25/human/male_ref/face04", "sstrp25/human/male_ref/body" },
        { "sstrp25/human/male_ref/face05", "sstrp25/human/male_ref/body" },
        { "sstrp25/human/male_ref/face01_white", "sstrp25/human/male_ref/body_white" },
        { "sstrp25/human/male_ref/face02_white", "sstrp25/human/male_ref/body_white" },
        { "sstrp25/human/male_ref/face03_white", "sstrp25/human/male_ref/body_white" },
        { "sstrp25/human/male_ref/face04_white", "sstrp25/human/male_ref/body_white" },
        { "sstrp25/human/male_ref/face05_white", "sstrp25/human/male_ref/body_white" },
        { "sstrp25/human/male_ref/face01_black", "sstrp25/human/male_ref/body_black" },
        { "sstrp25/human/male_ref/face02_black", "sstrp25/human/male_ref/body_black" },
        { "sstrp25/human/male_ref/face03_black", "sstrp25/human/male_ref/body_black" },
        { "sstrp25/human/male_ref/face04_black", "sstrp25/human/male_ref/body_black" },
        { "sstrp25/human/male_ref/face05_black", "sstrp25/human/male_ref/body_black" },
    },

    FaceBumpMap = "sstrp25/human/male_ref/face_n",

    SkinTones = {
        Color(255, 255, 255),
    },

    HairColor = {
        Color(222, 190, 153),
        Color(170, 136, 102),
        Color(109, 79, 42),
        Color(77, 55, 30),
        Color(50, 58, 64),
        Color(80, 80, 80),
        Color(140, 140, 140),
        Color(192, 192, 192),
    
        Color(144, 84, 36),
        Color(204, 121, 53),
        Color(137, 49, 1),
    },

    Eyes = {
        "brown",
        "blue",
        "bluewhite",
        "brown2",
        "green",
        "purple",
        "biotech"
    },

    EyeBrows = {
        "sstrp25/human/shared/brows/brow01",
        "sstrp25/human/shared/brows/brow02",
        "sstrp25/human/shared/brows/brow03",
        "sstrp25/human/shared/brows/brow04",
        "sstrp25/human/shared/brows/brow05",
        "sstrp25/human/shared/brows/brow06",
        "sstrp25/human/shared/brows/brow07",
        "sstrp25/human/shared/brows/brow08",
        "sstrp25/human/shared/brows/brow09",
        "sstrp25/human/shared/brows/brow10",
        "sstrp25/human/shared/brows/brow11",
        "sstrp25/human/shared/brows/brow12",
        "sstrp25/human/shared/brows/brow13"
    },

    Blemishes = {
        false
    }
})

local female_ref = Actor.AddBase(nil, 
{ 
    Model = "models/sstrp25/human/heads/female_ref.mdl",
    Torso = { "models/sstrp25/human/body/female_upper.mdl" },
    Legs = { "models/sstrp25/human/body/female_lower.mdl" },

    Defaults = {
        Torso = { "models/xalphox/mi/female_torso_trooper.mdl", "000000011" },
        Legs = { "models/xalphox/mi/female_legs_trooper.mdl" }
    },

    TexFace = 0,
    TexEyeL = 1,
    TexEyeR = 2,
    TexBrow = 3,

    Hair = { 
        "models/sstrp25/human/hair/femalebasehair.mdl",
        "models/sstrp25/human/hair/femalehair00.mdl",
        "models/sstrp25/human/hair/femalehair06.mdl",
        "models/sstrp25/human/hair/femalehair07.mdl",
        "models/sstrp25/human/hair/femalehair08.mdl",
        "models/sstrp25/human/hair/femalehair100.mdl",
        "models/sstrp25/human/hair/femalehair103.mdl",
        "models/sstrp25/human/hair/femalehair104.mdl",
        "models/sstrp25/human/hair/femalehair105.mdl",
        "models/sstrp25/human/hair/femalehair106.mdl",
        "models/sstrp25/human/hair/femalehair107.mdl",
        "models/sstrp25/human/hair/femalehair108.mdl",
        "models/sstrp25/human/hair/femalehair11.mdl",
        "models/sstrp25/human/hair/femalehair110.mdl",
        "models/sstrp25/human/hair/femalehair115.mdl",
        "models/sstrp25/human/hair/femalehair117.mdl",
        "models/sstrp25/human/hair/femalehair118.mdl",
        "models/sstrp25/human/hair/femalehair121.mdl",
        "models/sstrp25/human/hair/femalehair140.mdl",
        "models/sstrp25/human/hair/femalehair141.mdl",
        "models/sstrp25/human/hair/femalehair143.mdl",
        "models/sstrp25/human/hair/femalehair144.mdl",
        "models/sstrp25/human/hair/femalehair146.mdl",
        "models/sstrp25/human/hair/femalehair22.mdl",
        "models/sstrp25/human/hair/femalehair23.mdl",
        "models/sstrp25/human/hair/femalehair26.mdl",
        "models/sstrp25/human/hair/femalehair27.mdl",
        "models/sstrp25/human/hair/femalehair30.mdl",
        "models/sstrp25/human/hair/femalehair33.mdl",
        "models/sstrp25/human/hair/femalehair36.mdl",
        "models/sstrp25/human/hair/femalehair37.mdl",
        "models/sstrp25/human/hair/femalehair41.mdl",
        "models/sstrp25/human/hair/femalehair44.mdl",
        "models/sstrp25/human/hair/femalehair45.mdl",
        "models/sstrp25/human/hair/femalehair49.mdl",
        "models/sstrp25/human/hair/femalehair51.mdl",
        "models/sstrp25/human/hair/femalehair53.mdl",
        "models/sstrp25/human/hair/femalehair58.mdl",
        "models/sstrp25/human/hair/femalehair59.mdl",
        "models/sstrp25/human/hair/femalehair60.mdl",
        "models/sstrp25/human/hair/femalehair61.mdl",
        "models/sstrp25/human/hair/femalehair62.mdl",
        "models/sstrp25/human/hair/femalehair63.mdl",
        "models/sstrp25/human/hair/femalehair65.mdl",
        "models/sstrp25/human/hair/femalehair73.mdl",
        "models/sstrp25/human/hair/femalehair75.mdl",
        "models/sstrp25/human/hair/femalehair77.mdl",
        "models/sstrp25/human/hair/femalehair79.mdl",
        "models/sstrp25/human/hair/femalehair82.mdl",
        "models/sstrp25/human/hair/femalehair84.mdl",
        "models/sstrp25/human/hair/femalehair89.mdl",
        "models/sstrp25/human/hair/femalehair90.mdl",
        "models/sstrp25/human/hair/femalehair91.mdl",
        "models/sstrp25/human/hair/femalehair95.mdl",
    },
    
    Faces = {
        { "sstrp25/human/female_ref/face01", "sstrp25/human/female_ref/body" },
        { "sstrp25/human/female_ref/face02", "sstrp25/human/female_ref/body" },
        { "sstrp25/human/female_ref/face03", "sstrp25/human/female_ref/body" },
        { "sstrp25/human/female_ref/face04", "sstrp25/human/female_ref/body" },
        { "sstrp25/human/female_ref/face05", "sstrp25/human/female_ref/body" },
        { "sstrp25/human/female_ref/face01_white", "sstrp25/human/female_ref/body_white" },
        { "sstrp25/human/female_ref/face02_white", "sstrp25/human/female_ref/body_white" },
        { "sstrp25/human/female_ref/face03_white", "sstrp25/human/female_ref/body_white" },
        { "sstrp25/human/female_ref/face04_white", "sstrp25/human/female_ref/body_white" },
        { "sstrp25/human/female_ref/face05_white", "sstrp25/human/female_ref/body_white" },
        { "sstrp25/human/female_ref/face01_black", "sstrp25/human/female_ref/body_black" },
        { "sstrp25/human/female_ref/face02_black", "sstrp25/human/female_ref/body_black" },
        { "sstrp25/human/female_ref/face03_black", "sstrp25/human/female_ref/body_black" },
        { "sstrp25/human/female_ref/face04_black", "sstrp25/human/female_ref/body_black" },
        { "sstrp25/human/female_ref/face05_black", "sstrp25/human/female_ref/body_black" },
    },

    FaceBumpMap = "sstrp25/human/female_ref/face_n",

    SkinTones = {
        Color(255, 255, 255),
    },

    HairColor = {
        Color(222, 190, 153),
        Color(170, 136, 102),
        Color(109, 79, 42),
        Color(77, 55, 30),
        Color(50, 58, 64),
        Color(80, 80, 80),
        Color(140, 140, 140),
        Color(192, 192, 192),
    
        Color(144, 84, 36),
        Color(204, 121, 53),
        Color(137, 49, 1),
    },

    Eyes = {
        "brown",
        "blue",
        "bluewhite",
        "brown2",
        "green",
        "purple",
        "biotech"
    },

    EyeBrows = {
        "sstrp25/human/shared/brows/brow01",
        "sstrp25/human/shared/brows/brow02",
        "sstrp25/human/shared/brows/brow03",
        "sstrp25/human/shared/brows/brow04",
        "sstrp25/human/shared/brows/brow05",
        "sstrp25/human/shared/brows/brow06",
        "sstrp25/human/shared/brows/brow07",
        "sstrp25/human/shared/brows/brow08",
        "sstrp25/human/shared/brows/brow09",
        "sstrp25/human/shared/brows/brow10",
        "sstrp25/human/shared/brows/brow11",
        "sstrp25/human/shared/brows/brow12",
        "sstrp25/human/shared/brows/brow13"

    },

    Blemishes = {
        false
    }
})

Actor.AddBase(male_ref, {
    Model = "models/sstrp25/human/heads/male12_ref.mdl",

    Beards = {
        false,
        "models/sstrp25/human/hair/beard12_lower1.mdl",
        "models/sstrp25/human/hair/beard12_lower2.mdl",
        "models/sstrp25/human/hair/beard12_lower3.mdl",
        "models/sstrp25/human/hair/beard12_lower4.mdl",
        "models/sstrp25/human/hair/beard12_lower5.mdl",
        "models/sstrp25/human/hair/beard12_lower6.mdl",
        "models/sstrp25/human/hair/beard12_lower7.mdl",
        "models/sstrp25/human/hair/beard12_lower8.mdl",
        "models/sstrp25/human/hair/beard12_lower9.mdl",            
    },

    Mustaches = {
        false,
        "models/sstrp25/human/hair/beard12_upper1.mdl",
        "models/sstrp25/human/hair/beard12_upper2.mdl",
        "models/sstrp25/human/hair/beard12_upper3.mdl",
        "models/sstrp25/human/hair/beard12_upper4.mdl",
        "models/sstrp25/human/hair/beard12_upper5.mdl",
        "models/sstrp25/human/hair/beard12_upper6.mdl",
        "models/sstrp25/human/hair/beard12_upper7.mdl",
        "models/sstrp25/human/hair/beard12_upper8.mdl",
        "models/sstrp25/human/hair/beard12_upper9.mdl",
    },
})

Actor.AddBase(male_ref, {
    Model = "models/sstrp25/human/heads/male19_ref.mdl",

    Beards = {
        false,
        "models/sstrp25/human/hair/beard19_lower1.mdl",
        "models/sstrp25/human/hair/beard19_lower2.mdl",
        "models/sstrp25/human/hair/beard19_lower3.mdl",
        "models/sstrp25/human/hair/beard19_lower4.mdl",
        "models/sstrp25/human/hair/beard19_lower5.mdl",
        "models/sstrp25/human/hair/beard19_lower6.mdl",
        "models/sstrp25/human/hair/beard19_lower7.mdl",
        "models/sstrp25/human/hair/beard19_lower8.mdl",
        "models/sstrp25/human/hair/beard19_lower9.mdl",            
    },

    Mustaches = {
        false,
        "models/sstrp25/human/hair/beard19_upper1.mdl",
        "models/sstrp25/human/hair/beard19_upper2.mdl",
        "models/sstrp25/human/hair/beard19_upper3.mdl",
        "models/sstrp25/human/hair/beard19_upper4.mdl",
        "models/sstrp25/human/hair/beard19_upper5.mdl",
        "models/sstrp25/human/hair/beard19_upper6.mdl",
        "models/sstrp25/human/hair/beard19_upper7.mdl",
        "models/sstrp25/human/hair/beard19_upper8.mdl",
        "models/sstrp25/human/hair/beard19_upper9.mdl",
    },
})

Actor.AddBase(female_ref, {
    Model = "models/sstrp25/human/heads/female03_ref.mdl"
})

Actor.AddBase(female_ref, {
    Model = "models/sstrp25/human/heads/female20_ref.mdl",
    TexFace = 3,
    TexBrow = 0
})






local rt
local queue = {}
local cache = {}

function Actor.RenderThink()
    local top = table.remove(queue, 1)
    if not top then
        return
    end

    top()
    print("Render!")
end
timer.Create("ActorRenderThink", 0.5, 0, Actor.RenderThink)

local TEXTURE_FLAGS_CLAMP_S = 0x0004
local TEXTURE_FLAGS_CLAMP_T = 0x0008
function Actor.Material(b64)
    if cache[b64] then
        return cache[b64]
    else
        local hash = util.SHA256(b64)
        local fname = "sstrp/cache/actors/" .. hash .. ".png"
        if file.Exists(fname, "DATA") then
            local mat = Material("data/" .. fname, "noclamp smooth")
            cache[b64] = mat
            return mat
        else
            rt = rt or GetRenderTargetEx("ActorMaterial",
                256,
                256,
                RT_SIZE_NO_CHANGE,
                MATERIAL_RT_DEPTH_SHARED,
                bit.bor(TEXTURE_FLAGS_CLAMP_S, TEXTURE_FLAGS_CLAMP_T),
                CREATERENDERTARGETFLAGS_UNFILTERABLE_OK,
                IMAGE_FORMAT_RGBA8888
            )

            local mat = CreateMaterial(hash, "UnlitGeneric", {
                ["$basetexture"] = rt:GetName(),
                ["$translucent"] = 1,
                ["_loading"] = "1"
            })
            
            table.insert(queue, function ()
                local data = util.JSONToTable(util.Decompress(util.Base64Decode(b64)))

                if IsValid(RENDER_ACTOR) then
                    RENDER_ACTOR:Remove()
                end

                local ent = ents.CreateClientside("actor")
                RENDER_ACTOR = ent
                ent:Spawn()
                
                ent:Deserialize(data)
                ent:GiveWeapon("models/weapons/arc9/mk1rifle.mdl")
                ent:ResetSequence("idle_relaxed_shotgun_6")
                    
                ent:SetPos(Vector(0, 0, 0))
                ent:SetAngles(Angle(0, 0, 0))

                render.PushRenderTarget(rt)
                render.SuppressEngineLighting(true)
                render.ResetModelLighting(0, 0, 0)
        
                render.SetLocalModelLights({
                    {
                        type = MATERIAL_LIGHT_SPOT,
                        color = Vector(0.5, 0.5, 0.5),
                        pos = Vector(60, 0, 50),
                        dir = Vector(-1, 0, 0),
                        innerAngle = 40,
                        outerAngle = 180,
                        angularFalloff = 25
                    },
                })

                render.Clear(0, 0, 0, 0, true, true)

                render.OverrideAlphaWriteEnable(true, true) -- some playermodel eyeballs will not render without this
                render.SetWriteDepthToDestAlpha(false)
                render.SetBlend(1)
        
                
                local female = string.find(ent:GetModel(), "female")
                local CamPos = Vector(female and 140 or 135, female and 0.5 or -2, female and 63 or 65)
                local CamAngles = Angle(0, 180, 0)

                cam.Start3D(CamPos, CamAngles, 5, 0, 0, 256, 256)
                    ent:DrawModel()
                    ent:SetNoDraw(true)
                cam.End3D()

                render.SetWriteDepthToDestAlpha(true)
                render.OverrideAlphaWriteEnable(false)
                render.SuppressEngineLighting(false)

                file.CreateDir("sstrp")
                file.CreateDir("sstrp/cache")
                file.CreateDir("sstrp/cache/actors")

                file.Write(fname, render.Capture({
                    format = "png",
                    x = 0,
                    y = 0,
                    w = 256,
                    h = 256,
                    alpha = true
                }))

                render.PopRenderTarget()

                mat:SetTexture("$basetexture", Material("data/" .. fname, "noclamp smooth"):GetTexture("$basetexture"))
                mat:SetInt("_loading", 0)

                cache[b64] = mat

                timer.Simple(0, function () ent:Remove() end)
            end)

            return mat
        end
    end
end




Actor.Presets = {
    "XQAAAQBoBAAAAAAAAAA9gn0iC8RbPlKedgbf32UEgsTY/Q+v2h/g0++whomcIW/PIVhGAbENoj/YZIsPTjUio9i3+BQ7ozapxwGYONx1n8rSrKtaHqQca8mgC8KXnJlE/B4gAS4XZILwXSRbr1jSr8I41glJhRdJ/RbJGTJFfe17Rq/Rxj/WLR89JZJ0WeVrQGuGMtilgc4czFFsQ/cZqw4MVahDwE2wWApS3gurNxQ+Tm3mKSSMaDg1cMM8P0epmz2kZ3zNMCXmIPJUP1ugsR1qspv9pc68ZJQ6mU0NLIhmf31fUB616u3afg==",
    "XQAAAQDcAgAAAAAAAAA9iIUGE4Vwm8wrSsIDreofuoiCoMZ2C7HnroakJ9jAZyFeor9T79vR7g9hrncV9FejPJeqLNv4ygIQQqghDz4X0ZGSf9Gz5+0dC5w0rZLsMeo+a71meU81gL3It5JMUaKb1cliaAtKeWOWdB7en1rG28FPBGy/f1NvyWwnemp4o9/1Wi3+9tIDQao+Ab4QeNs/k8nIMO9WQSiCn4x7eNvv9txNJA6AbGLaeWl/b+EudEVyhebVXAgpGhpLFJmMHad6/R7zlh80pXYUjV/bwtmV/XEE",
    "XQAAAQDTAgAAAAAAAAA9iIUGE4Vwm8wphcmf2aW7b30b1V3tKqIqYaO9ntvuD2qQaAKOBXpvdPzoiDVHtCaXJ/73fSw9ZR4oQFSC6FpINgagBMcbvWF0THDITdmmC+yYu/TLCFrGj88slfAAV6iXTxTfVb0LX+aSLVNfmWQnlfBSvdlWp7pCi0VP1UaOWmMR1BOqqWX7+zwug2gY2a2atuWmhU4yPAEIzNR9O+WOcVA8x1NF1iFijIKNPLfl5s3n7XCnwARndSdyTpTbWKDwsFgfezZF1J6GlhjTVg==",
    "XQAAAQBlBAAAAAAAAAA9gn0iC8RbPlKedgbgHhSKksTY/Q+v2h/g0+pCgn3EaJSBoAsdoTvNjfYeAxdYfHojo70pFO5fUU6c5KJ4LhGvxb+5D9P69yoBOG9qZIkQbtuGkzFtXSAq8WLtjCsRJxG8+7yEyjNZ25hIV29vUO4rvl+EpGvYEO4ZeKY3wnTziS9BZLAOxSgC9XZa+E5C1+xMUFNUgAk/R/jlUy1/0z1YyUndmHqw7TQ0woSbuGWBqAp6NCAxLdEYUEs0U0/LzTVHwntXYk37Mi9h1Zk4Ky2vHTPCwaOZuzro6LocAt6tNg==",
    "XQAAAQDVAgAAAAAAAAA9iIUGE4Vwm8wt8jmf2aW7b30b1V3LOu67EsZZn+vZ2KmkS30Btcl9rfV4pYsO2L53dX16QJra5d/hk/2y5rZZKuACVYJVsodYjxy/t5oxdfOtNRNLn44qKzAsw0V8sF6jFZ5usXL2XT25g4b5vuIleG7nb6VjqMjkbnyp2yotsphw8juvUpQ/IM+zc3naVuxmD2KRQi7akGpbbqCnAjo9UY1ejCKE5318E4Io5vJcnaKVSLp6VlHyPufocj9APUqs+s7xm9rlFiMDwAuSygsA",
    "XQAAAQDVAgAAAAAAAAA9iIUGE4Vwm8wu1LYeQrnVgUQU/kp61e67EsZZn+vZ2KmkS30Btcl9rfV4pYsO2L53cLuJu/lDeeBulLP0Z9ziGyuE6BfqwMi2WsVeU5jq26wsqsiZsZcM3D9jQp4ewBACm14WMsZY5VGV+M7yQ3lvzUDLVc0owK7qztXKx2nx0IYMOnrZ5BJb7NjGn2ym+ybcIy2+QjYEYW2d9I/6YDjDxmJPcYlJJecD11zDFOnoMkpGet5Vop9GsYcGvFuMeUfspJxa+2yYrLLQ+qEMePJg"
}

ENT.Type = "anim"
ENT.PrintName = "Actor"
ENT.Author = "Xalphox"
ENT.Spawnable = true
ENT.AdminSpawnable = false
ENT.RenderGroup = RENDERGROUP_BOTH

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSCOLOR)
    self:SetModel("models/sstrp25/human/heads/male_ref.mdl")
    --self:SetSequence("idle_relaxed_ar2_2")
    --self:ResetSequence("idle_relaxed_shotgun_9")
    self:SetSequence("idle_all_01")
    self.Children = {}
    Actor.Last = self

	if SERVER then
		self:PhysicsInitBox(Vector(-16, -16, 0.5), Vector(16, 16, 72))
	end

    if CLIENT then 
        self:SetBase(1)
        --[[self:AddPart("Helmet", "models/xalphox/mi/male_head_trooper.mdl")
        self:AddPart("Hair", "models/xalphox/hair/malebasehair1.mdl")
        self:AddPart("Torso", "models/xalphox/mi/male_torso_trooper.mdl", "000000011")
        self:AddPart("Legs", "models/xalphox/mi/male_legs_trooper.mdl")
        
        --self:GiveWeapon("models/weapons/arc9/mk1rifle.mdl")
        
        self.Face = "models/xalphox/male_ref/face"
        self:SetSkinColor(color_white)
        self:SetEyes(1)
        self:SetHairColor(Color(16, 16, 16, 255))
        self:SetFatness(1)--]]

    end
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:SetBase(id)
    local base = Actor.Bases[id]
    assert(base, "Invalid base ID: " .. tostring(id))

    self.Base = base
    self.BaseId = id

    self:SetModel(base.Model)
    --self:AddPart("Torso", "models/xalphox/mi/male_torso_trooper.mdl", "000000011")
    --self:AddPart("Legs", "models/xalphox/mi/male_legs_trooper.mdl")
    local torso = base.Defaults.Torso or base.Torso
    local legs = base.Defaults.Legs or base.Legs

    self:AddPart("Torso", torso[1], torso[2])
    self:AddPart("Legs", legs[1], legs[2])
    self.Face = 1
    self:SetEyes(1)
    self:SetHair(1)
    self:SetHairColor(base.HairColor[1])
    self:ResetSequence("idle_all_01")
end

function ENT:GetBase()
    return self.BaseId
end

function ENT:SetHair(id)
    self.Hair = id

    local path = self.Base.Hair[id]

    if not path then
        if IsValid(self.Children.Hair) then
            self.Children.Hair:Remove()
            self.Children.Hair = nil
        end
        return
    end

    local mdl, bg = ModelString(path)
    if IsValid(self.Children.Hair) then
        local e = self.Children.Hair
        e:SetModel(mdl)
        if bg then
            e:SetBodyGroups(bg)
        end
    else
        self:AddPart("Hair", mdl, bg)
    end
    self:SetHairColor(self:GetHairColor() or Color(255, 255, 255, 255))
end

function ENT:GetHair()
    return self.Hair
end

function ENT:SetEyes(id)
    self.EyeID = id
    
    local path = self.Base.Eyes[id]

    self:SetSubMaterial(self.Base.TexEyeL, "sstrp25/human/shared/eyeball_sst_l_" .. path) 
    self:SetSubMaterial(self.Base.TexEyeR, "sstrp25/human/shared/eyeball_sst_r_" .. path) 
end

function ENT:GetEyes(path)
    return self.EyeID
end

function ENT:SetHairColor(col)
    self.HairColor = col
    if IsValid(self.Children.Hair) then
        self.Children.Hair:SetColor(col)
    end
    self:SetEyeBrows(self:GetEyeBrows() or 1)
    self:SetBeard(self:GetBeard())
    self:SetMustache(self:GetMustache())
end

function ENT:GetHairColor()
    return self.HairColor
end

function ENT:GetEyeBrows()
    return self.EyeBrows
end

function ENT:SetEyeBrows(path)

    self.EyeBrows = path
    if isnumber(path) then
        path = self.Base.EyeBrows[path]
    end

    local col = self.EyeBrowColor
    if not col then
        col = self:GetHairColor()
        if col then
            col = Color(col.r, col.g, col.b, col.a)
            col:AddBrightness(-0.1)
        end
    end

    local mat = CreateMaterial(uuid(), "VertexLitGeneric", { 
        ["$basetexture"] = path,
        ["$translucent"] = 1,
        ["$nocull"] = 1,
        ["$model"] = 1,
        ["$color2"] = string.format("[%f %f %f]", col.r / 255, col.g / 255, col.b / 255)
    })
    mat:Recompute()
    self:SetSubMaterial(self.Base.TexBrow, "!" .. mat:GetName())
    return mat
end

function ENT:GetFace()
    return self.Face
end

function ENT:SetFace(path)    

    self.Face = path
    if isnumber(path) then
        path = self.Base.Faces[path][1]
    end

    self:SetSubMaterial(self.Base.TexFace, path)
    return mat
end


function ENT:SetBeard(id)
    if not self.Base.Beards then
        if IsValid(self.Children.Beard) then
            self.Children.Beard:Remove()
            self.Children.Beard = nil
        end
        
        self.Beard = nil
        return
    end

    self.Beard = id

    local path = self.Base.Beards[id]

    if not path then
        if IsValid(self.Children.Beard) then
            self.Children.Beard:Remove()
            self.Children.Beard = nil
        end
        return
    end

    local mdl, bg = ModelString(path)
    if IsValid(self.Children.Beard) then
        local e = self.Children.Beard
        e:SetModel(mdl)
        e:SetColor(self:GetHairColor())
        if bg then
            e:SetBodyGroups(bg)
        end
    else
        self:AddPart("Beard", mdl, bg)
        self.Children.Beard:SetColor(self:GetHairColor())
    end
end

function ENT:GetBeard()
    return self.Beard
end


function ENT:SetMustache(id)
    if not self.Base.Mustaches then
        if self.Children.Mustache then
            self.Children.Mustache:Remove()
            self.Children.Mustache = nil
        end

        self.Mustache = nil
        return
    end

    self.Mustache = id

    local path = self.Base.Mustaches[id]

    if not path then
        if IsValid(self.Children.Mustache) then
            self.Children.Mustache:Remove()
            self.Children.Mustache = nil
        end
        return
    end

    local mdl, bg = ModelString(path)
    if IsValid(self.Children.Mustache) then
        local e = self.Children.Mustache
        e:SetModel(mdl)
        if bg then
            e:SetBodyGroups(bg)
        end
        e:SetColor(self:GetHairColor())
    else
        self:AddPart("Mustache", mdl, bg)
        self.Children.Mustache:SetColor(self:GetHairColor())
    end
end

function ENT:GetMustache()
    return self.Mustache
end

function ENT:GiveWeapon(model)
    if IsValid(self.Children.Weapon) then
        self.Children.Weapon:Remove()
    end

    local e = ents.CreateClientside("actor_part")
    e:SetMoveType(MOVETYPE_NONE)
    e:SetSolid(SOLID_NONE)
    e:Spawn()
    e:SetModel(model)

    e:SetPos(self:GetPos())
    e:SetParent(self, self:LookupBone("ValveBiped.Bip01_R_Hand"))

    self.Children.Weapon = e
end

function ENT:Serialize()
    local data = {
        Base = self:GetBase(),
        Mustache = self:GetMustache(),
        Beard = self:GetBeard(),
        --Model = self:GetModel(),
        Face = self:GetFace(),
        Hair = self:GetHair(),
        HairColor = self:GetHairColor(),
        Eyes = self:GetEyes(),
        EyeBrows = self:GetEyeBrows(),
        Hair = self:GetHair(),
    }

    data.Flex = {}
    for i = 0, self:GetFlexNum() - 1 do
        data.Flex[i] = self:GetFlexWeight(i)
    end

    return data
end

function ENT:ToBase64()
    return util.Base64Encode(util.Compress(util.TableToJSON(self:Serialize())))
end

function ENT:FromBase64(str)

    local data = util.JSONToTable(util.Decompress(util.Base64Decode(str)))
    self:Deserialize(data)
end

function ENT:Deserialize(data)
    self:SetBase(data.Base)
    self:SetHair(data.Hair or 1)
    self:SetFace(data.Face)
    self:SetHair(data.Hair)
    self:SetEyeBrows(data.EyeBrows)
    self:SetBeard(data.Beard)
    self:SetMustache(data.Mustache)
    
    self:SetHairColor(Color(data.HairColor.r, data.HairColor.g, data.HairColor.b, data.HairColor.a))
    self:SetEyes(data.Eyes)--]]

    for i = 0, self:GetFlexNum() - 1 do
        if data.Flex[i] then
            self:SetFlexWeight(i, data.Flex[i])
        end
    end
end

function ENT:SetFaceParam(flex, weight)
    local name = self:GetFlexName(flex)
    self:SetFlexWeight(flex, weight)

    print("Ent:SetFlexWeight")

    for k, v in pairs(self.Children) do
        print(v, name, v:GetFlexName(flex))
        if v:GetFlexName(flex) == name then
            v:SetFlexWeight(flex, weight)
        end
    end
end

function ENT:AddPart(name, model, bg)
    if IsValid(self.Children[name]) then
        self.Children[name]:Remove()
    end

    local e = ents.CreateClientside("actor_part")
    e:SetMoveType(MOVETYPE_NONE)
    e:Spawn()
    e:SetModel(model)
    if bg then
        e:SetBodyGroups(bg)
    end

    e:SetPos(self:GetPos())
    e:SetSolid(SOLID_NONE)
    e:SetParent(self)
    e:AddEffects(bit.bor(EF_BONEMERGE, EF_BONEMERGE_FASTCULL, EF_PARENT_ANIMATES))

    self.Children[name] = e
    return e
end

function ENT:Draw(flags)
	--[[local bone = self:LookupBone("ValveBiped.Bip01_Head1")

	if (bone) then
		self:SetEyeTarget((self:GetForward() * 128) + Vector(0, math.cos(CurTime()) * 1024, math.sin(CurTime()) * 1024))
	end--]]

    self:DrawModel(flags)
    
    for k, v in pairs(self.Children) do
        v:DrawModel(flags)
    end
end
ENT.DrawTranslucent = ENT.Draw

function ENT:Think()
    if CLIENT and IsValid(self.Children.Weapon) then
        local boneId = self:LookupBone("ValveBiped.Bip01_R_Hand")
        if boneId then
            local pos, ang = self:GetBonePosition(boneId)
            if pos and ang then
                -- Optional: adjust offset here to position the weapon correctly in the hand
                local offsetPos = pos + ang:Forward() * -16.4 + ang:Right() * 7.7 + ang:Up() * -8.6
                local offsetAng = ang
                offsetAng:RotateAroundAxis(ang:Right(), 0)   -- rotate to match grip
                offsetAng:RotateAroundAxis(ang:Up(), 0) 
                offsetAng:RotateAroundAxis(ang:Forward(), 180)

                self.Children.Weapon:SetPos(offsetPos)
                self.Children.Weapon:SetAngles(offsetAng)
            end
        end
    end

    self:NextThink(CurTime())
    return true
end

function ENT:OnRemove()
    for k, v in pairs(self.Children) do
        if IsValid(v) then
            v:Remove()
        end
    end
end
