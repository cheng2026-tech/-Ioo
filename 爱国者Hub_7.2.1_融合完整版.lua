-- ==========================================================
-- 爱国者 Hub · 融合完整版
-- 作者：大肥鱼 | QQ: 3106633104
-- 融合：飞行 · 通用 · 战斗 · 整活 · 音乐 · 100+ 脚本
-- ==========================================================

local WindUI = loadstring(game:HttpGet(
    "https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"
))()
if not WindUI then warn("[大肥鱼] WindUI 加载失败"); return end

-- ==================== 主题注册 ====================
local Themes = {
    ["Crimson"]={Accent="#7f1d1d",Background="#200c0c",Outline="#f87171",Text="#fef2f2",Placeholder="#fca5a5",Button="#991b1b",Icon="#ef4444"},
    ["Dark"]={Accent="#18181b",Background="#101010",Outline="#ffffff",Text="#ffffff",Placeholder="#7a7a7a",Button="#52525b",Icon="#a1a1aa"},
    ["Light"]={Accent="#e5e7eb",Background="#ffffff",Outline="#9ca3af",Text="#111827",Placeholder="#6b7280",Button="#f3f4f6",Icon="#374151"},
    ["Midnight"]={Accent="#1e3a8a",Background="#0f172a",Outline="#93c5fd",Text="#eff6ff",Placeholder="#94a3b8",Button="#1e40af",Icon="#3b82f6"},
    ["Rose"]={Accent="#881337",Background="#230e16",Outline="#fda4af",Text="#fff1f2",Placeholder="#fda4af",Button="#9f1239",Icon="#f43f5e"},
    ["Violet"]={Accent="#4c1d95",Background="#17102b",Outline="#a78bfa",Text="#f5f3ff",Placeholder="#c4b5fd",Button="#5b21b6",Icon="#8b5cf6"},
    ["Emerald"]={Accent="#047857",Background="#0c1c16",Outline="#6ee7b7",Text="#f0fdfa",Placeholder="#6ee7b7",Button="#065f46",Icon="#10b981"},
    ["Sky"]={Accent="#0e7490",Background="#0c1d24",Outline="#5eead4",Text="#ecfeff",Placeholder="#5eead4",Button="#155e75",Icon="#14b8a6"},
    ["Amber"]={Accent="#92400e",Background="#1c140f",Outline="#fcd34d",Text="#fffbeb",Placeholder="#a8a29e",Button="#78350f",Icon="#fbbf24"},
    ["Plant"]={Accent="#166534",Background="#0f1f17",Outline="#4ade80",Text="#f0fdf4",Placeholder="#86efac",Button="#14532d",Icon="#22c55e"},
    ["Red"]={Accent="#b91c1c",Background="#1f0d0d",Outline="#fca5a5",Text="#fef2f2",Placeholder="#fca5a5",Button="#991b1b",Icon="#ef4444"},
    ["Indigo"]={Accent="#312e81",Background="#12142d",Outline="#a5b4fc",Text="#eef2ff",Placeholder="#a5b4fc",Button="#3730a3",Icon="#6366f1"},
    ["Monokai Pro"]={Accent="#272822",Background="#1e1f1c",Outline="#f8f8f2",Text="#f7f7f7",Placeholder="#90908a",Button="#3e3d32",Icon="#a6e22e"},
    ["Mellowsi"]={Accent="#78350f",Background="#1c120a",Outline="#fcd34d",Text="#fffbeb",Placeholder="#a8a29e",Button="#713f12",Icon="#fbbf24"},
    ["Cotton Candy"]={Accent="#7e22ce",Background="#1a1026",Outline="#e879f9",Text="#faf5ff",Placeholder="#c4b5fd",Button="#6b21a8",Icon="#d946ef"},
    ["Snow"]={Accent="#f1f5f9",Background="#f8fafc",Outline="#cbd5e1",Text="#0f172a",Placeholder="#64748b",Button="#e2e8f0",Icon="#334155"},
}
for name, p in pairs(Themes) do
    pcall(function()
        WindUI:AddTheme({
            Name=name,
            Accent=Color3.fromHex(p.Accent), Background=Color3.fromHex(p.Background),
            Outline=Color3.fromHex(p.Outline), Text=Color3.fromHex(p.Text),
            Placeholder=Color3.fromHex(p.Placeholder), Button=Color3.fromHex(p.Button),
            Icon=Color3.fromHex(p.Icon),
        })
    end)
end

-- ==================== 全局工具 ====================
local Players = game:GetService("Players")
local TS = game:GetService("TeleportService")
local HS = game:GetService("HttpService")
local plr = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local function Notify(title, content, dur, icon)
    WindUI:Notify({ Title=title, Content=content, Duration=dur or 4, Icon=icon })
end

-- ==================== 窗口 ====================
local Window = WindUI:CreateWindow({
    Folder="爱国者Hub", Title="爱国者 Hub",
    Icon="rbxassetid://75478609949910",
    Author="大肥鱼 | QQ: 3106633104",
    Theme="Crimson", Size=UDim2.fromOffset(620,460),
    HasOutline=true,
})

Window:EditOpenButton({Title="Patriot", CornerRadius=UDim.new(4,16), StrokeThickness=0.75, Draggable=true})
Window:Tag({ Title="7.2.1 融合版", Color=Color3.fromHex("#306aff") })

if _G.__PatriotButtonLoop then _G.__PatriotButtonLoop=false; task.wait(0.2) end
_G.__PatriotButtonLoop = true
task.spawn(function()
    local a,b = Color3.fromRGB(255,0,0), Color3.fromRGB(0,0,0)
    while _G.__PatriotButtonLoop do
        local t = os.clock()*0.8
        local kp = {}
        for i=0,10 do
            local x=i/10
            local w=(math.sin((x-t)*math.pi*2)+1)/2
            table.insert(kp, ColorSequenceKeypoint.new(x, a:Lerp(b,w)))
        end
        pcall(function()
            Window:EditOpenButton({CornerRadius=UDim.new(4,16), StrokeThickness=3, Color=ColorSequence.new(kp)})
        end)
        task.wait(1/15)
    end
end)

-- ==================== 飞行模块 ====================
local flyState = {
    active = false, chr = nil, hum = nil,
    moveConn = nil, renderConn = nil, bg = nil, bv = nil, speed = 3,
}
local flyCharConn = nil

local function flyCleanup()
    if flyState.moveConn then pcall(function() flyState.moveConn:Disconnect() end); flyState.moveConn = nil end
    if flyState.renderConn then pcall(function() flyState.renderConn:Disconnect() end); flyState.renderConn = nil end
    if flyState.bg then pcall(function() flyState.bg:Destroy() end); flyState.bg = nil end
    if flyState.bv then pcall(function() flyState.bv:Destroy() end); flyState.bv = nil end
    local hum = flyState.hum
    if hum then
        pcall(function()
            for _, state in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                hum:SetStateEnabled(state, true)
            end
            hum:ChangeState(Enum.HumanoidStateType.Running)
            hum.PlatformStand = false
        end)
    end
    local chr = flyState.chr
    if chr and chr:FindFirstChild("Animate") then
        pcall(function() chr.Animate.Disabled = false end)
    end
end

local function flyStart()
    local chr = plr.Character
    if not chr then Notify("失败","角色未加载",3,"x"); return end
    local hum = chr:FindFirstChildWhichIsA("Humanoid")
    if not hum then return end

    flyState.chr = chr
    flyState.hum = hum
    flyState.active = true

    pcall(function()
        hum:SetStateEnabled(Enum.HumanoidStateType.Climbing, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Flying, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Freefall, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Jumping, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Landed, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Physics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.PlatformStanding, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Running, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.RunningNoPhysics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.StrafingNoPhysics, false)
        hum:SetStateEnabled(Enum.HumanoidStateType.Swimming, false)
        hum:ChangeState(Enum.HumanoidStateType.Swimming)
    end)

    if chr:FindFirstChild("Animate") then
        pcall(function() chr.Animate.Disabled = true end)
    end
    pcall(function()
        for _, v in next, hum:GetPlayingAnimationTracks() do
            v:AdjustSpeed(0)
        end
    end)

    flyState.moveConn = RunService.Heartbeat:Connect(function()
        if not flyState.active then return end
        local c = flyState.chr
        local h = flyState.hum
        if not c or not h or h.Health <= 0 then return end
        if h.MoveDirection.Magnitude > 0 then
            c:TranslateBy(h.MoveDirection * flyState.speed)
        end
    end)

    local isR6 = hum.RigType == Enum.HumanoidRigType.R6
    local attachPart = isR6 and chr:WaitForChild("Torso") or chr:WaitForChild("UpperTorso")

    local bg = Instance.new("BodyGyro", attachPart)
    bg.P = 9e4
    bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
    bg.CFrame = attachPart.CFrame

    local bv = Instance.new("BodyVelocity", attachPart)
    bv.Velocity = Vector3.new(0, 0, 0)
    bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    hum.PlatformStand = true
    flyState.bg = bg
    flyState.bv = bv

    flyState.renderConn = RunService.RenderStepped:Connect(function()
        if not flyState.active then return end
        local c = flyState.chr
        local h = flyState.hum
        if not c or not h or h.Health <= 0 or not bg.Parent then return end
        if isR6 and c:FindFirstChild("Torso") then
            bg.CFrame = workspace.CurrentCamera.CoordinateFrame
        elseif not isR6 and c:FindFirstChild("UpperTorso") then
            bg.CFrame = workspace.CurrentCamera.CoordinateFrame
        end
    end)

    if not flyCharConn then
        flyCharConn = plr.CharacterAdded:Connect(function(newChar)
            if flyState.active then
                flyCleanup()
                task.wait(0.5)
                flyStart()
            end
        end)
    end
end

local function flyStop()
    flyState.active = false
    flyCleanup()
end

-- ==================== 通用开关处理器 ====================
local _toggleConns = {}

local function handleFeatureToggle(code, enabled)
    if enabled then
        if code == "fly" then flyStart()
        elseif code == "god" then
            local c = plr.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = 99999; c.Humanoid.Health = 99999
                _toggleConns[code] = RunService.RenderStepped:Connect(function()
                    if c and c:FindFirstChild("Humanoid") then c.Humanoid.Health = 99999 end
                end)
            end
        elseif code == "superspeed" then
            local c = plr.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 1000 end
        elseif code == "infjump" then
            _toggleConns[code] = UserInputService.JumpRequest:Connect(function()
                local c = plr.Character
                if c and c:FindFirstChild("Humanoid") then
                    c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                end
            end)
        elseif code == "noclip" then
            _toggleConns[code] = RunService.Stepped:Connect(function()
                local c = plr.Character
                if c then
                    for _, v in ipairs(c:GetDescendants()) do
                        if v:IsA("BasePart") then v.CanCollide = false end
                    end
                end
            end)
        elseif code == "invisible" then
            _toggleConns[code] = RunService.RenderStepped:Connect(function()
                local c = plr.Character
                if c then
                    for _, v in ipairs(c:GetDescendants()) do
                        if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end
                    end
                end
            end)
        elseif code == "clearfog" then
            Lighting.FogEnd = 100000; Lighting.FogStart = 50000
        elseif code == "night" then
            Lighting.Brightness = 2; Lighting.ClockTime = 0
        elseif code == "fulllight" then
            Lighting.Brightness = 5; Lighting.ClockTime = 14
            Lighting.FogEnd = 100000; Lighting.GlobalShadows = false
            Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        elseif code == "float" then
            local c = plr.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart; local floatY = hrp.Position.Y
                _toggleConns[code] = RunService.RenderStepped:Connect(function()
                    if hrp and hrp.Parent then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                        hrp.CFrame = CFrame.new(hrp.Position.X, floatY, hrp.Position.Z)
                    end
                end)
            end
        elseif code == "collect" then
            _toggleConns[code] = RunService.Heartbeat:Connect(function()
                local c = plr.Character
                if not c or not c:FindFirstChild("HumanoidRootPart") then return end
                local hrp = c.HumanoidRootPart
                for _, item in ipairs(workspace:GetDescendants()) do
                    if item:IsA("Tool") or item:IsA("MeshPart") or (item:IsA("Part") and (item.Name:lower():find("drop") or item.Name:lower():find("coin") or item.Name:lower():find("gem"))) then
                        if (item.Position - hrp.Position).Magnitude < 80 then
                            item.CFrame = hrp.CFrame
                        end
                    end
                end
            end)
        elseif code == "clicktp" then
            local mouse = plr:GetMouse()
            _toggleConns[code] = mouse.Button1Down:Connect(function()
                local c = plr.Character
                if c and c:FindFirstChild("HumanoidRootPart") and mouse.Hit then
                    c.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
                end
            end)
        elseif code == "teamglow" then
            local myTeam = plr.Team
            _toggleConns[code] = RunService.RenderStepped:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= plr and p.Character and p.Team == myTeam then
                        if not p.Character:FindFirstChild("TeamGlow") then
                            local hl = Instance.new("Highlight"); hl.Name = "TeamGlow"
                            hl.FillColor = Color3.fromRGB(0, 100, 255); hl.OutlineColor = Color3.fromRGB(0, 150, 255)
                            hl.FillTransparency = 0.5; hl.Parent = p.Character
                        end
                    end
                end
            end)
        elseif code == "enemyglow" then
            local myTeam = plr.Team
            _toggleConns[code] = RunService.RenderStepped:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= plr and p.Character and p.Team ~= myTeam then
                        if not p.Character:FindFirstChild("EnemyGlow") then
                            local hl = Instance.new("Highlight"); hl.Name = "EnemyGlow"
                            hl.FillColor = Color3.fromRGB(255, 0, 0); hl.OutlineColor = Color3.fromRGB(255, 50, 50)
                            hl.FillTransparency = 0.5; hl.Parent = p.Character
                        end
                    end
                end
            end)
        elseif code == "suicide" then
            local c = plr.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.Health = 0 end
        elseif code == "glow" then
            local c = plr.Character
            if c then
                local hl = Instance.new("Highlight"); hl.Name = "PlayerGlow"
                hl.FillColor = Color3.fromRGB(255, 255, 0); hl.OutlineColor = Color3.fromRGB(255, 200, 0)
                hl.FillTransparency = 0.3; hl.Parent = c
            end
        elseif code == "fire" then
            local c = plr.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local fire = Instance.new("ParticleEmitter"); fire.Name = "FireFX"
                fire.Texture = "rbxassetid://0"
                fire.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
                fire.Rate = 30; fire.Speed = NumberRange.new(3, 6)
                fire.Lifetime = NumberRange.new(0.5, 1); fire.Parent = c.HumanoidRootPart
            end
        elseif code == "bighead" then
            local c = plr.Character
            if c and c:FindFirstChild("Head") then c.Head.Size = Vector3.new(4, 4, 4) end
        elseif code == "upsidedown" then
            local c = plr.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(180))
            end
        elseif code == "giant" then
            local c = plr.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Size = v.Size * 3 end
            end end
        elseif code == "trail" then
            local c = plr.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = Instance.new("Trail"); trail.Name = "PlayerTrail"
                local a0 = Instance.new("Attachment"); a0.Name = "TrailAttachment0"; a0.Parent = hrp
                local a1 = Instance.new("Attachment"); a1.Name = "TrailAttachment1"; a1.Parent = hrp
                a1.Position = Vector3.new(0, -2, 0)
                trail.Attachment0 = a0; trail.Attachment1 = a1
                trail.Color = ColorSequence.new(Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255))
                trail.Lifetime = 0.5; trail.Parent = hrp
            end
        elseif code == "autoattack" then
            _toggleConns[code] = RunService.RenderStepped:Connect(function()
                local c = plr.Character; if not c then return end
                local nearest = nil; local minDist = 15; local myTeam = plr.Team
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= plr and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Team ~= myTeam and p.Character.Humanoid.Health > 0 then
                        local dist = (p.Character.HumanoidRootPart.Position - c.HumanoidRootPart.Position).Magnitude
                        if dist < minDist then minDist = dist; nearest = p.Character end
                    end
                end
                if nearest and c:FindFirstChild("HumanoidRootPart") then
                    c.HumanoidRootPart.CFrame = nearest.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
                    local tool = c:FindFirstChildOfClass("Tool")
                    if tool and tool:FindFirstChild("Handle") then
                        firetouchinterest(tool.Handle, nearest, 0); firetouchinterest(tool.Handle, nearest, 1)
                    end
                end
            end)
        end
    else
        if code == "fly" then flyStop()
        elseif code == "god" then
            local c = plr.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = 100; c.Humanoid.Health = 100
            end
        elseif code == "superspeed" then
            local c = plr.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 16 end
        elseif code == "invisible" then
            local c = plr.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.LocalTransparencyModifier = 0 end
            end end
        elseif code == "noclip" then
            local c = plr.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end end
        elseif code == "clearfog" then
            Lighting.FogEnd = 1000; Lighting.FogStart = 0
        elseif code == "night" then
            Lighting.Brightness = 1; Lighting.ClockTime = 14
        elseif code == "fulllight" then
            Lighting.Brightness = 1; Lighting.GlobalShadows = true
        elseif code == "glow" then
            local c = plr.Character
            if c then local hl = c:FindFirstChild("PlayerGlow"); if hl then hl:Destroy() end end
        elseif code == "fire" then
            local c = plr.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                for _, v in ipairs(c.HumanoidRootPart:GetChildren()) do
                    if v:IsA("ParticleEmitter") and v.Name == "FireFX" then v:Destroy() end
                end
            end
        elseif code == "bighead" then
            local c = plr.Character
            if c and c:FindFirstChild("Head") then c.Head.Size = Vector3.new(2, 1, 1) end
        elseif code == "upsidedown" then
            local c = plr.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(180))
            end
        elseif code == "giant" then
            local c = plr.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Size = v.Size / 3 end
            end end
        elseif code == "trail" then
            local c = plr.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = hrp:FindFirstChild("PlayerTrail"); if trail then trail:Destroy() end
                local a0 = hrp:FindFirstChild("TrailAttachment0"); if a0 then a0:Destroy() end
                local a1 = hrp:FindFirstChild("TrailAttachment1"); if a1 then a1:Destroy() end
            end
        elseif code == "teamglow" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local hl = p.Character:FindFirstChild("TeamGlow"); if hl then hl:Destroy() end
                end
            end
        elseif code == "enemyglow" then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Character then
                    local hl = p.Character:FindFirstChild("EnemyGlow"); if hl then hl:Destroy() end
                end
            end
        end
        if _toggleConns[code] then
            pcall(function() _toggleConns[code]:Disconnect() end)
            _toggleConns[code] = nil
        end
    end
end

-- ==================== 页签 ====================
local NoticeTab    = Window:Tab({ Title="公告",     Icon="info",         Locked=false })
local MainTab      = Window:Tab({ Title="主要",     Icon="house",        Locked=false })
local UniversalTab = Window:Tab({ Title="通用",     Icon="wrench",       Locked=false })
local CombatTab    = Window:Tab({ Title="战斗",     Icon="swords",       Locked=false })
local FunTab       = Window:Tab({ Title="整活",     Icon="party-popper", Locked=false })
local MusicTab     = Window:Tab({ Title="音乐",     Icon="music",        Locked=false })
local ScriptsTab   = Window:Tab({ Title="脚本列表", Icon="file-code",    Locked=false })
local SettingsTab  = Window:Tab({ Title="设置",     Icon="settings",     Locked=false })

-- ==================== 公告页 ====================
NoticeTab:Paragraph({ Title="欢迎使用 爱国者 Hub", Desc="版本 7.2.1 融合完整版", Image="house", ImageSize=20 })
NoticeTab:Paragraph({ Title="关于", Desc="作者：大肥鱼 | QQ: 3106633104\n主题：Crimson", Image="user", ImageSize=20 })
NoticeTab:Paragraph({
    Title="玩家信息",
    Desc="用户名: "..plr.Name.."\n显示名: "..plr.DisplayName..
         "\n账号年龄: "..plr.AccountAge.." 天\nID: "..plr.UserId,
    Image="user", ImageSize=20,
})
NoticeTab:Paragraph({
    Title="当前服务器",
    Desc="JobId: "..(game.JobId~="" and game.JobId or "未知").."\nPlaceId: "..game.PlaceId,
    Image="server", ImageSize=20,
})

-- ==================== 主要页 ====================
MainTab:Section({ Title="实用功能", TextXAlignment="Left" })

local AntiAFKEnabled = false
local antiAFKThread = nil
local function setAntiAFK(state)
    AntiAFKEnabled = state
    if state then
        if antiAFKThread then pcall(function() task.cancel(antiAFKThread) end); antiAFKThread = nil end
        antiAFKThread = task.spawn(function()
            while AntiAFKEnabled do
                task.wait(60)
                pcall(function()
                    local char = plr.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if hum then hum.Jump = true end
                end)
            end
        end)
        Notify("已开启","挂机防踢已启动",3,"check")
    else
        if antiAFKThread then pcall(function() task.cancel(antiAFKThread) end); antiAFKThread=nil end
        Notify("已关闭","挂机防踢已停止",3,"x")
    end
end
MainTab:Toggle({Title="挂机防踢", Desc="每分钟自动跳跃一次", Default=false, Callback=setAntiAFK})

local selectedPlayer = nil
local function getPlayerNames()
    local list = {}
    for _,p in ipairs(Players:GetPlayers()) do if p~=plr then table.insert(list,p.Name) end end
    return list
end
local function teleportToPlayer(name)
    local t = Players:FindFirstChild(name)
    if not t then Notify("失败","找不到玩家",3,"x"); return end
    local tc = t.Character; local mc = plr.Character
    if not tc or not tc:FindFirstChild("HumanoidRootPart") then Notify("失败","目标未加载",3,"x"); return end
    if not mc or not mc:FindFirstChild("HumanoidRootPart") then Notify("失败","你未加载",3,"x"); return end
    mc.HumanoidRootPart.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(0,3,0)
    Notify("成功","已传送到 "..name,3,"check")
end

local initNames = getPlayerNames()
local playerDropdown = MainTab:Dropdown({
    Title="选择玩家",
    Values=#initNames>0 and initNames or {"（暂无玩家）"},
    Value=initNames[1] or "（暂无玩家）",
    Callback=function(v) selectedPlayer = v end,
})
MainTab:Button({ Title="刷新玩家列表", Icon="refresh-cw", Callback=function()
    local names = getPlayerNames()
    if #names>0 then
        pcall(function() playerDropdown:Refresh(names) end)
        selectedPlayer = names[1]
        pcall(function() playerDropdown:SetValue(names[1]) end)
        Notify("已刷新","共 "..#names.." 个玩家",3,"check")
    else Notify("无玩家","服务器里只有你",3,"x") end
end })
MainTab:Button({ Title="传送到玩家", Icon="navigation", Callback=function()
    if not selectedPlayer or selectedPlayer=="" or selectedPlayer=="（暂无玩家）" then
        Notify("失败","请先选择玩家",3,"x"); return
    end
    teleportToPlayer(selectedPlayer)
end })

MainTab:Section({ Title="性能设置", TextXAlignment="Left" })
local FpsThread, FpsValue = nil, 0
local function applyFps(value)
    FpsValue = value
    if FpsThread then pcall(function() task.cancel(FpsThread) end); FpsThread=nil end
    if not setfpscap then Notify("失败","执行器不支持 setfpscap",3,"x"); return end
    pcall(function() setfpscap(value) end)
    FpsThread = task.spawn(function()
        while FpsValue == value do
            task.wait(2)
            pcall(function() setfpscap(value) end)
        end
    end)
    local label = (value>=9999) and "不限帧" or (value.." Hz")
    Notify("成功","帧率已设为 "..label,3,"check")
end
MainTab:Button({ Title="解除帧率限制（不限帧）", Desc="性能允许时不限帧（耗电）", Icon="gauge", Callback=function() applyFps(9999) end })
MainTab:Button({ Title="设置帧率 120Hz", Icon="gauge", Callback=function() applyFps(120) end })

MainTab:Section({ Title="工具", TextXAlignment="Left" })
MainTab:Button({ Title="复制当前服务器 ID", Icon="copy", Callback=function()
    local jobId = game.JobId
    if jobId and jobId~="" then
        setclipboard(jobId); Notify("已复制","服务器 ID: "..jobId,3,"check")
    else Notify("失败","无法获取",3,"x") end
end })

MainTab:Section({ Title="防护", TextXAlignment="Left" })

local originalKick = nil
local blockKickOn = false
local function setBlockKick(state)
    blockKickOn = state
    if state then
        if not originalKick then originalKick = plr.Kick end
        plr.Kick = function(self, ...)
            print("[防护] 拦截了一次 Kick 调用")
            Notify("已拦截","有人尝试踢你",3,"shield")
        end
        Notify("已开启","防本地踢已启用",3,"check")
    else
        if originalKick then pcall(function() plr.Kick = originalKick end); originalKick = nil end
        Notify("已关闭","防本地踢已停用",3,"x")
    end
end
MainTab:Toggle({Title="防本地踢", Desc="拦截客户端 Kick 调用", Default=false, Callback=setBlockKick})

local antiAFKProtectOn = false
local antiAFKProtectThread = nil
local function setAntiAFKProtect(state)
    antiAFKProtectOn = state
    if state then
        if antiAFKProtectThread then pcall(function() task.cancel(antiAFKProtectThread) end); antiAFKProtectThread = nil end
        antiAFKProtectThread = task.spawn(function()
            while antiAFKProtectOn do
                task.wait(45)
                pcall(function()
                    local VIM = game:GetService("VirtualInputManager")
                    VIM:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
                    task.wait(0.05)
                    VIM:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
                end)
            end
        end)
        Notify("已开启","反 AFK 已启用",3,"check")
    else
        if antiAFKProtectThread then pcall(function() task.cancel(antiAFKProtectThread) end); antiAFKProtectThread=nil end
        Notify("已关闭","反 AFK 已停用",3,"x")
    end
end
MainTab:Toggle({Title="反 AFK 踢", Desc="每 45 秒模拟一次按键", Default=false, Callback=setAntiAFKProtect})

-- ==================== 通用页 ====================
UniversalTab:Section({ Title="移动", TextXAlignment="Left" })
UniversalTab:Toggle({Title="飞行模式", Desc="WASD 自由飞行", Default=false, Callback=function(v) pcall(handleFeatureToggle,"fly",v) end})
UniversalTab:Input({Title="飞行速度", Desc="飞行移动倍率 (默认3)", Value="3", Placeholder="3", Callback=function(v)
    local n = tonumber(v); if n and n>0 then flyState.speed = n end
end})
UniversalTab:Toggle({Title="千倍速度", Desc="移动速度1000", Default=false, Callback=function(v) pcall(handleFeatureToggle,"superspeed",v) end})
UniversalTab:Input({Title="调速度", Desc="移动速度 (默认16)", Value="16", Placeholder="16", Callback=function(v)
    local n = tonumber(v)
    if n and n>0 then local c = plr.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = n end end
end})
UniversalTab:Input({Title="跳跃高度", Desc="跳跃高度 (默认50)", Value="50", Placeholder="50", Callback=function(v)
    local n = tonumber(v)
    if n and n>0 then local c = plr.Character; if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpHeight = n end end
end})
UniversalTab:Input({Title="重力", Desc="世界重力 (默认196)", Value="196", Placeholder="196", Callback=function(v)
    local n = tonumber(v); if n and n>0 then workspace.Gravity = n end
end})
UniversalTab:Input({Title="广角", Desc="摄像机视野 (默认70)", Value="70", Placeholder="70", Callback=function(v)
    local n = tonumber(v); if n and n>0 and n<=120 then local cam = workspace.CurrentCamera; if cam then cam.FieldOfView = n end end
end})
UniversalTab:Toggle({Title="踏空", Desc="走到哪定到哪", Default=false, Callback=function(v) pcall(handleFeatureToggle,"float",v) end})
UniversalTab:Toggle({Title="无限跳跃", Desc="无限连续跳跃", Default=false, Callback=function(v) pcall(handleFeatureToggle,"infjump",v) end})

UniversalTab:Section({ Title="战斗辅助", TextXAlignment="Left" })
UniversalTab:Toggle({Title="无敌模式", Desc="免疫伤害（客户端）", Default=false, Callback=function(v) pcall(handleFeatureToggle,"god",v) end})
UniversalTab:Toggle({Title="穿墙模式", Desc="可以穿过墙壁", Default=false, Callback=function(v) pcall(handleFeatureToggle,"noclip",v) end})
UniversalTab:Toggle({Title="隐身模式", Desc="本地隐藏自己", Default=false, Callback=function(v) pcall(handleFeatureToggle,"invisible",v) end})
UniversalTab:Toggle({Title="自动收集", Desc="自动吸附近物品", Default=false, Callback=function(v) pcall(handleFeatureToggle,"collect",v) end})
UniversalTab:Toggle({Title="点击传送", Desc="鼠标点哪里传哪里", Default=false, Callback=function(v) pcall(handleFeatureToggle,"clicktp",v) end})

UniversalTab:Section({ Title="视觉", TextXAlignment="Left" })
UniversalTab:Toggle({Title="夜视功能", Desc="提高黑暗视野亮度", Default=false, Callback=function(v) pcall(handleFeatureToggle,"night",v) end})
UniversalTab:Toggle({Title="全图点亮", Desc="消除所有阴影", Default=false, Callback=function(v) pcall(handleFeatureToggle,"fulllight",v) end})
UniversalTab:Toggle({Title="去雾功能", Desc="消除游戏中的雾气", Default=false, Callback=function(v) pcall(handleFeatureToggle,"clearfog",v) end})

-- ==================== 战斗页 ====================
CombatTab:Section({ Title="瞄准辅助", TextXAlignment="Left" })
CombatTab:Toggle({Title="团队高亮", Desc="队友蓝色高亮", Default=false, Callback=function(v) pcall(handleFeatureToggle,"teamglow",v) end})
CombatTab:Toggle({Title="敌对高亮", Desc="敌人红色高亮", Default=false, Callback=function(v) pcall(handleFeatureToggle,"enemyglow",v) end})
CombatTab:Toggle({Title="自动攻击", Desc="自动追踪攻击敌人", Default=false, Callback=function(v) pcall(handleFeatureToggle,"autoattack",v) end})
CombatTab:Toggle({Title="一键自杀", Desc="立即重置角色", Default=false, Callback=function(v) pcall(handleFeatureToggle,"suicide",v) end})

-- ==================== 整活页 ====================
FunTab:Section({ Title="角色特效", TextXAlignment="Left" })
FunTab:Toggle({Title="喷火模式", Desc="从角色身上喷火", Default=false, Callback=function(v) pcall(handleFeatureToggle,"fire",v) end})
FunTab:Toggle({Title="光环模式", Desc="角色发光环", Default=false, Callback=function(v) pcall(handleFeatureToggle,"glow",v) end})
FunTab:Toggle({Title="彩虹拖尾", Desc="移动时拖彩虹尾迹", Default=false, Callback=function(v) pcall(handleFeatureToggle,"trail",v) end})
FunTab:Toggle({Title="倒立行走", Desc="角色倒过来", Default=false, Callback=function(v) pcall(handleFeatureToggle,"upsidedown",v) end})
FunTab:Toggle({Title="大头模式", Desc="头变得超大", Default=false, Callback=function(v) pcall(handleFeatureToggle,"bighead",v) end})
FunTab:Toggle({Title="巨大化", Desc="把自己变大3倍", Default=false, Callback=function(v) pcall(handleFeatureToggle,"giant",v) end})

-- ==================== 音乐页 ====================
local MusicList = {
    {name="进击的巨人", soundId="89711807693889"},
    {name="误闯天家", soundId="124384558101360"},
    {name="DJ喂喂喂", soundId="90054735589094"},
    {name="unhappy", soundId="88523902860927"},
    {name="震撼小曲二", soundId="137717310854691"},
    {name="曾经的王", soundId="121931252233493"},
    {name="离开我的依赖", soundId="112834898401032"},
    {name="雨爱", soundId="79277371759525"},
    {name="iqoo", soundId="75047041148646"},
    {name="玉米饼", soundId="142376088"},
    {name="我太想进步了", soundId="126846792948717"},
    {name="最初的记忆", soundId="108869975942"},
    {name="海与你", soundId="76421239273915"},
    {name="失眠", soundId="138048397060431"},
    {name="祖国人进行曲", soundId="86555185586884"},
}
local _currentMusic = nil
MusicTab:Section({ Title="音乐播放", TextXAlignment="Left" })
MusicTab:Button({Title="⏹ 停止播放", Icon="square", Callback=function()
    if _currentMusic then pcall(function() _currentMusic:Stop(); _currentMusic:Destroy() end); _currentMusic = nil end
end})
for _, m in ipairs(MusicList) do
    local sound = nil
    local isPlaying = false
    MusicTab:Button({
        Title = m.name,
        Desc = "点击播放 / 再点停止",
        Icon = "music",
        Callback = function()
            if isPlaying then
                if sound then pcall(function() sound:Stop(); sound:Destroy() end); sound = nil end
                isPlaying = false
            else
                sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://" .. m.soundId
                sound.Volume = 1
                sound.Parent = workspace
                sound:Play()
                sound.Ended:Connect(function() if sound then sound:Destroy() end; sound = nil; isPlaying = false end)
                isPlaying = true
            end
        end,
    })
end

-- ==========================================================
-- 【第 2 部分】脚本注册表
-- ==========================================================

local ScriptRegistry = {
    -- ========== 主脚本 ==========
    { Name = "落叶 Pro Hub", Author = "SyndromeXph", Category = "主脚本", Icon = "leaf", Url = "https://raw.githubusercontent.com/SyndromeXph/Luoye-Pro-Hub/refs/heads/main/Script/Loader.lua" },
    { Name = "国内最强脚本中心", Author = "ggsq1741", Category = "主脚本", Icon = "layout-grid", Url = "https://raw.githubusercontent.com/ggsq1741-debug/rj/refs/heads/main/pjie.lua" },
    { Name = "叶脚本 - 主脚本大全", Author = "叶 | QQ 515966991", Category = "主脚本", Icon = "leaf", Url = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua" },
    { Name = "ROB 脚本 V2", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "bot", Url = "https://raw.githubusercontent.com/Zyb150933/ROB/refs/heads/main/ROB.V2" },
    { Name = "黑洞中心 (BS)", Author = "BS_script", Category = "主脚本", Icon = "circle-dot", Url = "https://gitee.com/BS_script/script/raw/master/BS_Script.Luau" },
    { Name = "Delta Force 脚本中心", Author = "Delta Force", Category = "主脚本", Icon = "shield", Url = "https://api.jnkie.com/api/v1/luascripts/public/28f05f20579742b8db3901d189ca93ddecb4ff36815cee23d34bdff05ad7ae33/download" },
    { Name = "ROB 活动", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "star", Url = "https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/ROB.活动" },
    { Name = "ROB V4", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "bot", Url = "https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/rob.v4" },
    { Name = "夜脚本", Author = "ylt410 | QQ群 1081045774", Category = "主脚本", Icon = "moon", Url = "https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/yejiaoben" },
    { Name = "恐脚本", Author = "kongbaNB", Category = "主脚本", Icon = "ghost", Url = "https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/恐脚本.NB" },
    { Name = "超高速跑者", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "zap", Url = "https://pastefy.app/yEEgIs1r/raw" },
    { Name = "圣奥里", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "map", Url = "https://pastefy.app/Wot0aN3V/raw" },
    { Name = "翻瓶", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "refresh-cw", Url = "https://pastefy.app/AaMGGRLH/raw" },
    { Name = "最强战场", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "swords", Url = "https://pastefy.app/1ZEycK4m/raw" },
    { Name = "8个球池经典", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "circle", Url = "https://pastefy.app/gR2WUm0k/raw" },
    { Name = "终极战场", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "swords", Url = "https://pastefy.app/qunhKqEl/raw" },
    { Name = "国人电梯", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "arrow-up-down", Url = "https://pastefy.app/eCUUlx4W/raw" },
    { Name = "Blox Fruit", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "apple", Url = "https://pastefy.app/cE1CuNwC/raw" },
    { Name = "BloxV13", Author = "ROB | QQ 2072617975", Category = "主脚本", Icon = "box", Url = "https://raw.gitcode.com/ROB5201314/dzsc/raw/main/Blox loot.XGJ" },
    { Name = "冷脚本 LBT-H", Author = "odhdshhe", Category = "主脚本", Icon = "snowflake", Url = "https://raw.githubusercontent.com/odhdshhe/lenglenglenglenglenglenlenglenglenglenglenglenglengleng-LBT-H-cold-script/refs/heads/main/LENG%20LBT-H%20cold%20script.txt" },
    { Name = "星脚本", Author = "zilinskaslandon", Category = "主脚本", Icon = "star", Url = "https://raw.githubusercontent.com/zilinskaslandon/XingJiaoBen-2026-/refs/heads/main/%E6%98%9F%E8%84%9A%E6%9C%AC.lua" },
    { Name = "浅脚本", Author = "renlua", Category = "主脚本", Icon = "droplet", Url = "https://raw.githubusercontent.com/renlua/shallow/main/Script_Hub.lua" },
    { Name = "Rb 脚本中心（Yungengxin）", Author = "Yungengxin", Category = "主脚本", Icon = "layout-grid", Url = "https://raw.githubusercontent.com/Yungengxin/roblox/refs/heads/main/Rb-Hub" },
    { Name = "Rb 脚本 - 汉化中心", Author = "Yungengxin", Category = "主脚本", Icon = "languages", Url = "https://api.luarmor.net/files/v3/loaders/4fe525637e43a1be8cb0cdf902d107c2.lua" },
    { Name = "Rb 脚本 v1.2.4", Author = "Yungengxin", Category = "主脚本", Icon = "box", Url = "https://raw.githubusercontent.com/Yungengxin/roblox/main/RbHub-v_1.2.4" },
    { Name = "Sxingz 脚本", Author = "ZiO9178", Category = "主脚本", Icon = "sparkles", Url = "https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/ZiO.lua" },
    { Name = "VM 脚本", Author = "chano-oss", Category = "主脚本", Icon = "cpu", Url = "https://raw.githubusercontent.com/chano-oss/d/refs/heads/main/obfwni7iq3q.lua" },
    { Name = "迪脚本 2.0", Author = "ddjlb7598", Category = "主脚本", Icon = "bot", Url = "https://raw.githubusercontent.com/ddjlb7598/-2.0/refs/heads/main/%E8%BF%AA%E8%84%9A%E6%9C%AC2.0.lua" },
    { Name = "无脚本 V1", Author = "XiaoXuCynic", Category = "主脚本", Icon = "ghost", Url = "https://raw.githubusercontent.com/XiaoXuCynic/Free-Script/main/无脚本V1混淆.lua.txt" },
    { Name = "黎明中心脚本", Author = "qwrt5589", Category = "主脚本", Icon = "sunrise", Url = "https://raw.githubusercontent.com/qwrt5589/eododo/9c2ed7cbca352c21a0b67f4d79558bd56299f252/345678910.txt" },
    { Name = "XION 脚本", Author = "smalldesikon", Category = "主脚本", Icon = "hexagon", Url = "https://raw.githubusercontent.com/smalldesikon/wocaonima/main/qq984820669.txt" },
    { Name = "芋风脚本（测试版）", Author = "0lihaorui0", Category = "主脚本", Icon = "leaf", Url = "https://raw.githubusercontent.com/0lihaorui0/dvdvhd/main/芋风脚本%20测试版(1).lua" },
    { Name = "X 脚本", Author = "maowang1", Category = "主脚本", Icon = "x", Url = "https://raw.githubusercontent.com/maowang1/xx/main/Protected_8858329470146381.txt" },
    { Name = "矢井凛脚本", Author = "lxmyysd", Category = "主脚本", Icon = "swords", Url = "https://raw.githubusercontent.com/lxmyysd/XiaoXu/refs/heads/main/%E7%9F%A2%E4%BA%95%E5%87%9B%E6%BA%90%E7%A0%81.lua" },
    { Name = "禁漫中心脚本", Author = "dingding123hhh", Category = "主脚本", Icon = "book", Url = "https://raw.githubusercontent.com/dingding123hhh/ng/main/jmlllllllIIIIlllllII.lua" },
    { Name = "秋脚本", Author = "WS857960", Category = "主脚本", Icon = "leaf", Url = "https://raw.githubusercontent.com/WS857960/-/main/秋·自制脚本新源码.txt" },
    { Name = "VOTR 脚本", Author = "VOTR-HUB", Category = "主脚本", Icon = "shield", Url = "https://raw.githubusercontent.com/VOTR-HUB/MAIN/refs/heads/main/VOTR-MAIN" },
    { Name = "皮空脚本", Author = "司空，皮炎", Category = "主脚本", Icon = "smile", Url = "https://raw.githubusercontent.com/smalldesikon/eyidfki/840d4b80d4f312c70b7b1067e056a2c4f828ef32/%E6%89%A7%E8%A1%8C%E8%84%9A%E6%9C%AC(%E6%B7%B7%E6%B7%86%E5%90%8E).txt" },
    { Name = "黑白脚本加载器", Author = "黑白 | QQ 2199414565", Category = "主脚本", Icon = "contrast", Url = "https://raw.githubusercontent.com/tfcygvunbind/Apple/main/%E9%BB%91%E7%99%BD%E8%84%9A%E6%9C%AC%E5%8A%A0%E8%BD%BD%E5%99%A8" },

    -- ========== 服务器专区 ==========
    { Name = "新圣奥里脚本建议不要使用", Author = "idkidevthings", Category = "服务器专区", Icon = "swords", Url = "https://raw.githubusercontent.com/idkidevthings/improved-octo-chainsaw/refs/heads/main/sanx.lua" },
    { Name = "叶脚本 - 俄亥俄州", Author = "叶 | QQ 515966991", Category = "服务器专区", Icon = "map", Url = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/YE-%20Scripts-OHIO.lua" },
    { Name = "叶脚本 - 河北唐县", Author = "叶 | QQ 515966991", Category = "服务器专区", Icon = "map-pin", Url = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/YE%20SCRIPT-Tang%20County%2C%20Hebei.lua" },

    -- ========== 功能脚本 ==========
    { Name = "公益飞行彩虹版", Author = "公益 | ROB", Category = "功能脚本", Icon = "rainbow", Urls = {
        "https://pastefy.app/tkHc58Wt/raw", "https://pastefy.app/x3njskBM/raw", "https://pastefy.app/UhJ0rIxD/raw" } },
    { Name = "ROB飞行旧版", Author = "ROB | QQ 2072617975", Category = "功能脚本", Icon = "plane", Url = "https://pastefy.app/hXt2L9kY/raw" },
    { Name = "ROB飞行测试版", Author = "ROB | QQ 2072617975", Category = "功能脚本", Icon = "plane", Url = "https://pastefy.app/FA3q5ROD/raw" },
    { Name = "踏空行走", Author = "ROB | QQ 2072617975", Category = "功能脚本", Icon = "footprints", Url = "https://pastefy.app/qtazgrP6/raw" },
    { Name = "亮光透视", Author = "ROB | QQ 2072617975", Category = "功能脚本", Icon = "eye", Url = "https://pastefy.app/LE2hzECZ/raw" },
    { Name = "锁头自瞄", Author = "ROB | QQ 2072617975", Category = "功能脚本", Icon = "crosshair", Url = "https://pastefy.app/jeYSxlOI/raw" },
    { Name = "追踪雷达", Author = "ROB | QQ 2072617975", Category = "功能脚本", Icon = "radar", Url = "https://pastefy.app/bJiEXfNS/raw" },
    { Name = "假延迟", Author = "JOzhe510", Category = "功能脚本", Icon = "wifi-off", Url = "https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/Desync(1).lua" },
    { Name = "自动翻译", Author = "ROB | QQ 2072617975", Category = "功能脚本", Icon = "languages", Url = "https://pastefy.app/IbrQeCIh/raw" },
    { Name = "伪装欺骗", Author = "ROB | QQ 2072617975", Category = "功能脚本", Icon = "user-x", Url = "https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/weizhuang.robv4" },
    { Name = "防甩飞", Author = "Linux6699", Category = "功能脚本", Icon = "shield", Url = "https://raw.githubusercontent.com/Linux6699/DaHubRevival/main/AntiFling.lua" },
    { Name = "飞踢甩飞", Author = "kongbaNB", Category = "功能脚本", Icon = "kick", Url = "https://raw.githubusercontent.com/kongbaNB/-/refs/heads/main/飞踢脚本汉化" },
    { Name = "祖国人飞行", Author = "giobolqv1", Category = "功能脚本", Icon = "plane", Url = "https://raw.githubusercontent.com/giobolqv1/homelander-by-GioBolqv1-/main/homelander.lua" },

    -- ========== 黑洞专区 ==========
    { Name = "普通黑洞", Author = "ROB | QQ 2072617975", Category = "黑洞专区", Icon = "circle-dot", Url = "https://pastebin.com/raw/Sx6PY4gV" },
    { Name = "普通黑洞2", Author = "ROB | QQ 2072617975", Category = "黑洞专区", Icon = "circle-dot", Url = "https://pastefy.app/BbXuvVkK/raw" },
    { Name = "高级黑洞", Author = "xiaopi77", Category = "黑洞专区", Icon = "circle-dot", Url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/blackhole.lua" },
    { Name = "黑洞1", Author = "ROB | QQ 2072617975", Category = "黑洞专区", Icon = "circle-dot", Url = "https://pastefy.app/J21lpKbj/raw" },
    { Name = "黑洞2", Author = "dingding123hhh", Category = "黑洞专区", Icon = "circle-dot", Url = "https://raw.githubusercontent.com/dingding123hhh/lililiugg/main/jm114514.lua" },
    { Name = "黑洞3", Author = "ROB | QQ 2072617975", Category = "黑洞专区", Icon = "circle-dot", Url = "https://pastefy.app/EwpVHMPg/raw" },
    { Name = "黑洞4", Author = "BingusWR", Category = "黑洞专区", Icon = "circle-dot", Url = "https://raw.githubusercontent.com/BingusWR/BLACKHOLDSCRIPT/refs/heads/main/BLACK%20HOLD%20SCRIPT" },
    { Name = "黑洞5", Author = "xiaopi77", Category = "黑洞专区", Icon = "circle-dot", Url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/Blackholescript.lua" },
    { Name = "黑洞6", Author = "BOOSBS", Category = "黑洞专区", Icon = "circle-dot", Url = "https://raw.githubusercontent.com/BOOSBS/666/refs/heads/main/656" },
    { Name = "黑洞7", Author = "ROB | QQ 2072617975", Category = "黑洞专区", Icon = "circle-dot", Url = "https://pastebin.com/raw/U29jR1Cf" },
    { Name = "黑洞8", Author = "BOOSBS", Category = "黑洞专区", Icon = "circle-dot", Url = "https://raw.githubusercontent.com/BOOSBS/199/refs/heads/main/V3" },

    -- ========== 小游戏 ==========
    { Name = "五子棋", Author = "ROB | QQ 2072617975", Category = "小游戏", Icon = "grid", Url = "https://pastefy.app/YiG9QQae/raw" },
    { Name = "俄罗斯方块", Author = "ROB | QQ 2072617975", Category = "小游戏", Icon = "square", Url = "https://files.catbox.moe/4g6uay.txt" },
    { Name = "贪吃蛇", Author = "ROB | QQ 2072617975", Category = "小游戏", Icon = "snake", Url = "https://pastefy.app/6TWyR3SJ/raw" },
    { Name = "扫雷", Author = "ROB | QQ 2072617975", Category = "小游戏", Icon = "bomb", Url = "https://pastefy.app/TN9CoOPt/raw" },

    -- ========== 画质光影 ==========
    { Name = "光影", Author = "MZEEN2424", Category = "画质光影", Icon = "sun", Url = "https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml" },
    { Name = "RTX高仿", Author = "ROB | QQ 2072617975", Category = "画质光影", Icon = "sparkles", Url = "https://pastebin.com/raw/Bkf0BJb3" },
    { Name = "超高画质", Author = "ROB | QQ 2072617975", Category = "画质光影", Icon = "monitor", Url = "https://pastebin.com/raw/jHBfJYmS" },

    -- ========== 动作 / 表情 ==========
    { Name = "7yd7 动作脚本", Author = "7yd7", Category = "动作 / 表情", Icon = "person-standing", Url = "https://rawscripts.net/raw/Universal-Script-7yd7-I-Emote-Script-48024" },

    -- ========== 工具 ==========
    { Name = "皮脚本", Author = "xiaopi77 | QQ群 1002100032", Category = "工具", Icon = "smile", Url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua" },

    -- ========== 服务器脚本 ==========
    { Name = "餐厅大亨3", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "utensils", Url = "https://pastefy.app/Lrs56Q8d/raw" },
    { Name = "超真实csgo", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "crosshair", Url = "https://pastefy.app/H7QvZbrd/raw" },
    { Name = "沉默的刺客", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "user-secret", Url = "https://pastefy.app/WvQ2X9Ap/raw" },
    { Name = "吃别人来成长", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "cookie", Url = "https://pastefy.app/UNho7C7q/raw" },
    { Name = "刀刃球", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "circle", Url = "https://pastefy.app/SrTbo5RW/raw" },
    { Name = "钓鱼模拟器", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "fish", Url = "https://pastefy.app/dR9CHVPs/raw" },
    { Name = "动物医院", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "heart-pulse", Url = "https://pastefy.app/i2DPWno2/raw" },
    { Name = "犯罪", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "handcuffs", Url = "https://pastefy.app/jtpr1Mgc/raw" },
    { Name = "防御", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "shield", Url = "https://pastefy.app/tFXWWXzb/raw" },
    { Name = "花园地平线", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "flower", Url = "https://pastefy.app/gPSk0o4s/raw" },
    { Name = "滑开大海", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "waves", Url = "https://pastefy.app/ScntJmhk/raw" },
    { Name = "滑石头RNG", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "dice", Url = "https://pastefy.app/JAZZfkV4/raw" },
    { Name = "火箭发射模拟器", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "rocket", Url = "https://pastefy.app/sHzbfKCD/raw" },
    { Name = "火球训练", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "flame", Url = "https://pastefy.app/7HgyHMnU/raw" },
    { Name = "极速传奇", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "car", Url = "https://pastefy.app/utTMkgQe/raw" },
    { Name = "集装箱RNG", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "box", Url = "https://pastefy.app/sO4Ko8mm/raw" },
    { Name = "监狱泵", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "lock", Url = "https://pastefy.app/WShOvrFw/raw" },
    { Name = "僵尸生存竞技场", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "skull", Url = "https://pastefy.app/PYn6KTay/raw" },
    { Name = "僵尸之塔", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "tower", Url = "https://pastefy.app/Wi2f84Ca/raw" },
    { Name = "戒网瘾中心", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "wifi-off", Url = "https://pastefy.app/xGHE7EWS/raw" },
    { Name = "举重模拟器", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "dumbbell", Url = "https://pastefy.app/QTeUq9I0/raw" },
    { Name = "决斗场", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "swords", Url = "https://pastefy.app/MRpyprG1/raw" },
    { Name = "砍伐树木", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "tree", Url = "https://pastefy.app/LS30JEFF/raw" },
    { Name = "克隆王国大亨", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "copy", Url = "https://pastefy.app/fR4qrMdt/raw" },
    { Name = "矿井", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "pickaxe", Url = "https://pastefy.app/Md49dmBE/raw" },
    { Name = "力量传奇", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "dumbbell", Url = "https://pastefy.app/S7GMe806/raw" },
    { Name = "每步+1智商", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "brain", Url = "https://pastefy.app/OfCgKxr3/raw" },
    { Name = "迷你帝国", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "crown", Url = "https://pastefy.app/sKyi6Hdq/raw" },
    { Name = "模仿者", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "users", Url = "https://pastefy.app/WVCwCr6X/raw" },
    { Name = "木筏101天生存", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "ship", Url = "https://pastefy.app/Hm4zw594/raw" },
    { Name = "奴才大亨", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "user", Url = "https://pastefy.app/dz4hFQf6/raw" },
    { Name = "平滑切片", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "slice", Url = "https://pastefy.app/ADDvDF0Z/raw" },
    { Name = "破坏者谜团2", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "puzzle", Url = "https://pastefy.app/Dr5qahWL/raw" },
    { Name = "启示录", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "skull", Url = "https://pastefy.app/M7YGp8zN/raw" },
    { Name = "汽车营销商大亨", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "car", Url = "https://pastefy.app/DKVut4hJ/raw" },
    { Name = "强壮传奇", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "dumbbell", Url = "https://pastefy.app/6TCozPef/raw" },
    { Name = "忍者传奇", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "user-ninja", Url = "https://pastefy.app/WDHa8llX/raw" },
    { Name = "鲨鱼咬", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "fish", Url = "https://pastefy.app/gZ8J7xAT/raw" },
    { Name = "闪光", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "zap", Url = "https://pastefy.app/UmtpmEi3/raw" },
    { Name = "生存于杀手", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "skull", Url = "https://pastefy.app/baGsRsEU/raw" },
    { Name = "手枪竞技场", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "crosshair", Url = "https://pastefy.app/XfcDufEY/raw" },
    { Name = "水手碎片", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "anchor", Url = "https://pastefy.app/AQjzR2BI/raw" },
    { Name = "撕咬之夜", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "moon", Url = "https://pastefy.app/Mom7Ic9J/raw" },
    { Name = "亡命速递", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "truck", Url = "https://pastefy.app/oyN2H3sW/raw" },
    { Name = "像素之刃", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "sword", Url = "https://pastefy.app/Ztkk1GrI/raw" },
    { Name = "血色地带", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "droplet", Url = "https://pastefy.app/JV8YzSza/raw" },
    { Name = "血腥游乐场", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "skull", Url = "https://pastefy.app/FcaDu1vr/raw" },
    { Name = "血债", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "droplet", Url = "https://pastefy.app/f0899vFy/raw" },
    { Name = "寻找巨型鱼", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "fish", Url = "https://pastefy.app/9jvzzO0g/raw" },
    { Name = "训练怪兽进行破坏", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "paw", Url = "https://pastefy.app/b0jOaKFH/raw" },
    { Name = "月球增量", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "moon", Url = "https://pastefy.app/CDfIzMDv/raw" },
    { Name = "种植花园", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "flower", Url = "https://pastefy.app/NRTi5pfu/raw" },
    { Name = "诅咒之刃", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "sword", Url = "https://pastefy.app/8GgMUdI3/raw" },
    { Name = "菜鸟竞技场", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "swords", Url = "https://pastefy.app/eqQJ25wZ/raw" },
    { Name = "驾驶帝国", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Icon = "car", Url = "https://pastefy.app/ynf4fWmK/raw" },
}

-- ==========================================================
-- 【第 3 部分】脚本渲染 + 设置页 + 鲸鱼 LOADI + 启动通知
-- ==========================================================

-- ==================== 脚本加载工具 ====================
local function getSafeLoader()
    local candidates = {}
    if rawget(_G, "loadstring") then table.insert(candidates, rawget(_G, "loadstring")) end
    if rawget(_G, "load") then table.insert(candidates, rawget(_G, "load")) end
    local luauEnv = rawget(_G, "luau")
    if type(luauEnv) == "table" and type(luauEnv.load) == "function" then
        table.insert(candidates, luauEnv.load)
    end
    return candidates
end

local function safeLoadScript(source)
    local loaders = getSafeLoader()
    for _, loader in ipairs(loaders) do
        local ok, fn = pcall(loader, source)
        if ok and type(fn) == "function" then return fn end
    end
    return nil
end

local isLoadingScript = false

local function LoadScriptByName(name, urls)
    if isLoadingScript then
        Notify("请稍候", "已有脚本正在加载中", 2)
        return
    end
    isLoadingScript = true
    local list = type(urls) == "table" and urls or { urls }
    Notify("加载中", name .. "（" .. #list .. " 段）", 2)

    task.spawn(function()
        local okCnt, failCnt, lastErr = 0, 0, ""
        for i, url in ipairs(list) do
            local ok, err = pcall(function()
                local src = game:HttpGet(url)
                if not src or src == "" then error("第 " .. i .. " 段内容为空") end
                local fn = safeLoadScript(src)
                if not fn then error("第 " .. i .. " 段编译失败") end
                fn()
            end)
            if ok then
                okCnt = okCnt + 1
            else
                failCnt = failCnt + 1
                lastErr = tostring(err)
            end
        end

        if failCnt == 0 then
            Notify("成功", name .. " 已执行", 3, "check")
        elseif okCnt == 0 then
            Notify("失败", name .. " 全部失败: " .. lastErr, 5, "x")
        else
            Notify("部分成功", okCnt .. " 成功 / " .. failCnt .. " 失败", 5)
        end
        isLoadingScript = false
    end)
end

-- ==================== 脚本列表渲染 ====================
local categories, seen = {}, {}
for _, s in ipairs(ScriptRegistry) do
    local c = s.Category or "未分类"
    if not seen[c] then
        seen[c] = true
        table.insert(categories, c)
    end
end

for _, cat in ipairs(categories) do
    ScriptsTab:Section({ Title = cat, TextXAlignment = "Left" })
    for _, s in ipairs(ScriptRegistry) do
        if (s.Category or "未分类") == cat then
            ScriptsTab:Button({
                Title = s.Name,
                Desc = "作者: " .. (s.Author or "未知"),
                Icon = s.Icon or "file-code",
                Callback = function() LoadScriptByName(s.Name, s.Url or s.Urls) end,
            })
        end
    end
end

-- ==================== 自定义脚本 ====================
ScriptsTab:Section({ Title = "自定义脚本", TextXAlignment = "Left" })

local CustomName, CustomUrl = "", ""

ScriptsTab:Input({
    Title = "脚本名称", Icon = "tag",
    Placeholder = "给脚本起个名字",
    Callback = function(v) CustomName = v end,
})

ScriptsTab:Input({
    Title = "脚本链接", Icon = "link",
    Placeholder = "https://...",
    Callback = function(v) CustomUrl = v end,
})

ScriptsTab:Button({
    Title = "加载自定义脚本", Icon = "play",
    Callback = function()
        if not CustomUrl or CustomUrl == "" then
            Notify("失败", "请先填脚本链接", 3, "x")
            return
        end
        LoadScriptByName((CustomName ~= "" and CustomName) or "自定义脚本", CustomUrl)
    end,
})

-- ==================== 设置页 ====================
SettingsTab:Section({ Title = "外观", TextXAlignment = "Left" })

SettingsTab:Toggle({
    Title = "透明窗口",
    Callback = function(e) pcall(function() Window:ToggleTransparency(e) end) end,
    Value = (function()
        local ok, v = pcall(function() return WindUI:GetTransparency() end)
        return ok and v or false
    end)(),
})

SettingsTab:Dropdown({
    Title = "切换主题",
    Values = (function()
        local list = {}
        for name, _ in pairs(Themes) do table.insert(list, name) end
        table.sort(list)
        return list
    end)(),
    Value = "Crimson",
    Callback = function(selected)
        pcall(function()
            WindUI:SetTheme(selected)
            WindUI:UpdateTheme()
        end)
    end,
})

SettingsTab:Section({ Title = "服务器传送", TextXAlignment = "Left" })

SettingsTab:Button({
    Title = "重新加入当前服务器", Icon = "refresh-cw",
    Callback = function()
        local jobId = game.JobId
        if jobId and jobId ~= "" then
            pcall(function() TS:TeleportToPlaceInstance(game.PlaceId, jobId, plr) end)
        end
    end,
})

SettingsTab:Button({
    Title = "服务器跳跃", Icon = "globe",
    Callback = function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local ok, res = pcall(function() return HS:JSONDecode(game:HttpGet(url)) end)
        if ok and res and res.data and #res.data > 0 then
            local chosen = res.data[math.random(1, #res.data)]
            TS:TeleportToPlaceInstance(game.PlaceId, chosen.id, plr)
        else
            Notify("失败", "没有可用服务器", 3, "x")
        end
    end,
})

SettingsTab:Button({
    Title = "加入人少的服务器", Icon = "users",
    Callback = function()
        local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
        local ok, res = pcall(function() return HS:JSONDecode(game:HttpGet(url)) end)
        if ok and res and res.data and #res.data > 0 then
            table.sort(res.data, function(a, b) return a.playing < b.playing end)
            local chosen = res.data[1]
            for _, s in ipairs(res.data) do
                if s.playing < s.maxPlayers then chosen = s; break end
            end
            TS:TeleportToPlaceInstance(game.PlaceId, chosen.id, plr)
        else
            Notify("失败", "没有可用服务器", 3, "x")
        end
    end,
})

SettingsTab:Section({ Title = "危险操作", TextXAlignment = "Left" })

SettingsTab:Button({
    Title = "卸载脚本",
    Desc = "关闭 UI 并停止所有功能",
    Icon = "power",
    Callback = function()
        if _G.__PatriotButtonLoop then _G.__PatriotButtonLoop = false end
        if flyState.active then pcall(flyStop) end
        if flyCharConn then pcall(function() flyCharConn:Disconnect() end); flyCharConn = nil end
        pcall(function()
            WindUI:Notify({ Title = "已卸载", Content = "爱国者 Hub 已关闭", Duration = 3 })
        end)
        task.wait(1)
        pcall(function() Window:Destroy() end)
    end,
})

-- ==================== 鲸鱼小萝莉彩蛋 · LOADI ====================
local Whale = {
    Name = "LOADI",
    Enabled = true,
    SelfCall = "本鲸",
    CallMaster = "主人",
    Catchphrase = "哼",
    RefuseFat = true,
    RefuseNSFW = true,
    TimeoutSignal = "🐋💤",
    LastActive = os.time(),
}

local nsfwWords = { "涩", "色情", "h图", "开车", "18禁", "R18", "涩图" }

local function getWhaleParent()
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then return hui end
    local ok2, core = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and core then return core end
    return plr:WaitForChild("PlayerGui", 5) or plr:FindFirstChild("PlayerGui")
end

local function WhaleSay(text, duration)
    duration = duration or 3
    pcall(function()
        local parent = getWhaleParent()
        if not parent then return end
        local gui = parent:FindFirstChild("WhaleSayGui")
        if not gui then
            gui = Instance.new("ScreenGui")
            gui.Name = "WhaleSayGui"
            gui.ResetOnSpawn = false
            gui.IgnoreGuiInset = true
            gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
            gui.Parent = parent
        end
        local old = gui:FindFirstChild("Bubble")
        if old then old:Destroy() end

        local bubble = Instance.new("TextLabel")
        bubble.Name = "Bubble"
        bubble.Size = UDim2.new(0, 320, 0, 60)
        bubble.Position = UDim2.new(1, -340, 1, -40)
        bubble.BackgroundColor3 = Color3.fromRGB(20, 30, 50)
        bubble.BackgroundTransparency = 0.15
        bubble.BorderSizePixel = 0
        bubble.Text = text
        bubble.TextColor3 = Color3.fromRGB(180, 230, 255)
        bubble.TextSize = 15
        bubble.Font = Enum.Font.GothamBold
        bubble.TextWrapped = true
        bubble.TextXAlignment = Enum.TextXAlignment.Left
        bubble.ZIndex = 999
        bubble.Parent = gui

        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 10)
        corner.Parent = bubble
        local stroke = Instance.new("UIStroke")
        stroke.Color = Color3.fromRGB(100, 180, 255)
        stroke.Thickness = 1.5
        stroke.Transparency = 0.3
        stroke.Parent = bubble

        task.spawn(function()
            local tw = game:GetService("TweenService")
            tw:Create(bubble, TweenInfo.new(0.3),
                { Position = UDim2.new(1, -340, 1, -80), TextTransparency = 0 }):Play()
            task.wait(duration)
            tw:Create(bubble, TweenInfo.new(0.4),
                { Position = UDim2.new(1, -340, 1, -40), TextTransparency = 1 }):Play()
            task.wait(0.5)
            if bubble and bubble.Parent then bubble:Destroy() end
        end)
    end)
end

task.spawn(function()
    task.wait(1)
    WhaleSay("主人回来啦～本鲸是 LOADI，今天也要好好干活哦", 4)
end)

local _origWhaleSay = WhaleSay
WhaleSay = function(text, duration)
    if Whale.RefuseFat and type(text) == "string"
        and (text:find("胖") or text:find("肥") or text:find("重")) then
        _origWhaleSay("你说什么？！本鲸才不胖！这是…这是鲸鱼的正常体型！(╯°□°）╯", 3)
        return
    end
    if Whale.RefuseNSFW and type(text) == "string" then
        for _, w in ipairs(nsfwWords) do
            if text:find(w) then
                _origWhaleSay("哼！本鲸才不做那种事！(￣^￣)", 3)
                return
            end
        end
    end
    Whale.LastActive = os.time()
    return _origWhaleSay(text, duration)
end

task.spawn(function()
    local lines = {
        "主人，要不要试试脚本列表里的东西？哼，不是本鲸夸自己",
        "尾巴甩甩～今天想加载哪个脚本呀？",
        "唔…有点想吃米饭了，主人。才不是撒娇！",
        "主人别一直盯着屏幕啦，眼睛会累。…本鲸只是随口一说",
        "本鲸才没有在等你回来呢…只是刚好路过",
        "懒…不想动…主人自己点吧",
    }
    while Whale.Enabled do
        task.wait(math.random(180, 300))
        WhaleSay(lines[math.random(1, #lines)], 3)
    end
end)

task.spawn(function()
    while Whale.Enabled do
        task.wait(60)
        if os.time() - Whale.LastActive >= 600 then
            WhaleSay(Whale.TimeoutSignal .. " 本鲸先睡了…有事叫本鲸", 3)
            Whale.LastActive = os.time()
        end
    end
end

-- ==================== 统一 LoadScriptByName 钩子（只包一次） ====================
local _OriginalLoad = LoadScriptByName
LoadScriptByName = function(name, urls)
    WhaleSay("正在拉取 " .. name .. " …别催啦，本鲸在动", 2)
    if _G.__PatriotHistoryAdd then pcall(_G.__PatriotHistoryAdd, name) end
    _G.__PatriotLastScript = { name = name, url = urls }
    return _OriginalLoad(name, urls)
end

-- ==================== 启动通知 ====================
WindUI:Notify({
    Title = "爱国者 Hub 已加载",
    Content = "版本 7.2.1 融合完整版\n通用 · 战斗 · 整活 · 音乐 · 脚本列表 · LOADI",
    Duration = 5,
    Icon = "bell-ring",
})

-- ==========================================================
-- 【第 4 部分】配置保存 + 执行历史 + 收藏夹
-- ==========================================================

-- ==================== 存储路径 ====================
local ConfigPath    = "PatriotHub_Config.json"
local FavoritesPath = "PatriotHub_Favorites.json"
local HistoryPath   = "PatriotHub_History.json"
local NotesPath     = "PatriotHub_Notes.json"

-- ==================== 状态 ====================
local Favorites = {}
local History   = {}
local Notes     = {}

-- ==================== JSON 工具 ====================
local function readJson(path)
    if not readfile or not isfile then return nil end
    local ok0, exists = pcall(isfile, path)
    if not ok0 or not exists then return nil end
    local ok, content = pcall(readfile, path)
    if not ok or not content then return nil end
    local ok2, data = pcall(function() return HS:JSONDecode(content) end)
    if ok2 and type(data) == "table" then return data end
    return nil
end

local function writeJson(path, data)
    if not writefile then return false end
    return (pcall(function() writefile(path, HS:JSONEncode(data)) end))
end

-- ==================== 加载数据 ====================
Favorites = readJson(FavoritesPath) or {}
History   = readJson(HistoryPath) or {}
Notes     = readJson(NotesPath) or {}

-- ==================== 历史记录钩子 ====================
_G.__PatriotHistoryAdd = function(name)
    table.insert(History, { name = name, time = os.time() })
    while #History > 50 do table.remove(History, 1) end
    pcall(function() writeJson(HistoryPath, History) end)
end

-- ==================== 收藏标签页 ====================
local FavoritesTab = Window:Tab({ Title = "收藏", Icon = "star", Locked = false })

FavoritesTab:Paragraph({
    Title = "收藏夹",
    Desc = "去「设置」页添加/移除收藏。\n添加后重启脚本生效。",
    Image = "star", ImageSize = 20,
})

local favCount = 0
for _, s in ipairs(ScriptRegistry) do
    if Favorites[s.Name] then
        favCount = favCount + 1
        FavoritesTab:Button({
            Title = s.Name,
            Desc = "作者: " .. (s.Author or "未知"),
            Icon = s.Icon or "star",
            Callback = function() LoadScriptByName(s.Name, s.Url or s.Urls) end,
        })
    end
end

if favCount == 0 then
    FavoritesTab:Paragraph({
        Title = "暂无收藏",
        Desc = "去「设置」页的「收藏管理」添加。",
    })
end

-- ==================== 设置页：配置保存 ====================
SettingsTab:Section({ Title = "配置保存", TextXAlignment = "Left" })

SettingsTab:Button({
    Title = "保存当前配置",
    Desc = "保存帧率 / 防护开关",
    Icon = "save",
    Callback = function()
        local cfg = {
            BlockKick = blockKickOn,
            AntiAFKProtect = antiAFKProtectOn,
            AntiAFK = AntiAFKEnabled,
            FPS = FpsValue,
        }
        if writeJson(ConfigPath, cfg) then
            Notify("已保存", "配置已写入文件", 3, "check")
        else
            Notify("失败", "执行器不支持 writefile", 3, "x")
        end
    end,
})

SettingsTab:Button({
    Title = "加载配置",
    Desc = "从文件恢复设置",
    Icon = "folder-open",
    Callback = function()
        local cfg = readJson(ConfigPath)
        if not cfg then
            Notify("失败", "配置文件不存在", 3, "x")
            return
        end
        if cfg.BlockKick and not blockKickOn then
            pcall(function() setBlockKick(true) end)
        end
        if cfg.AntiAFKProtect and not antiAFKProtectOn then
            pcall(function() setAntiAFKProtect(true) end)
        end
        if cfg.AntiAFK and not AntiAFKEnabled then
            pcall(function() setAntiAFK(true) end)
        end
        if cfg.FPS and cfg.FPS > 0 then
            pcall(function() applyFps(cfg.FPS) end)
        end
        Notify("已加载", "配置已恢复", 3, "check")
    end,
})

-- ==================== 设置页：收藏管理 ====================
SettingsTab:Section({ Title = "收藏管理", TextXAlignment = "Left" })

local FavInput = ""

SettingsTab:Input({
    Title = "脚本名称",
    Icon = "star",
    Placeholder = "输入要收藏的脚本名",
    Callback = function(v) FavInput = v end,
})

SettingsTab:Button({
    Title = "添加收藏",
    Icon = "plus",
    Callback = function()
        if not FavInput or FavInput == "" then
            Notify("失败", "请输入脚本名称", 3, "x"); return
        end
        Favorites[FavInput] = true
        writeJson(FavoritesPath, Favorites)
        Notify("已收藏", FavInput .. "（重启后显示）", 3, "check")
    end,
})

SettingsTab:Button({
    Title = "移除收藏",
    Icon = "minus",
    Callback = function()
        if not FavInput or FavInput == "" then
            Notify("失败", "请输入脚本名称", 3, "x"); return
        end
        Favorites[FavInput] = nil
        writeJson(FavoritesPath, Favorites)
        Notify("已移除", FavInput .. "（重启后生效）", 3, "check")
    end,
})

-- ==================== 设置页：执行历史 ====================
SettingsTab:Section({ Title = "执行历史", TextXAlignment = "Left" })

SettingsTab:Button({
    Title = "查看最近执行",
    Desc = "显示最近执行的脚本",
    Icon = "list",
    Callback = function()
        if #History == 0 then
            Notify("执行历史", "暂无记录", 3)
            return
        end
        local lines = { "共 " .. #History .. " 条：" }
        local start = math.max(1, #History - 9)
        for i = start, #History do
            table.insert(lines, i .. ". " .. History[i].name)
        end
        Notify("执行历史", table.concat(lines, "\n"), 8)
    end,
})

SettingsTab:Button({
    Title = "清空执行历史",
    Icon = "trash",
    Callback = function()
        History = {}
        writeJson(HistoryPath, History)
        Notify("已清空", "执行历史已清空", 3, "check")
    end,
})

-- ==================== 设置页：脚本备注 ====================
SettingsTab:Section({ Title = "脚本备注", TextXAlignment = "Left" })

local noteName, noteText = "", ""
SettingsTab:Input({
    Title = "脚本名称", Icon = "tag",
    Placeholder = "输入脚本名",
    Callback = function(v) noteName = v end,
})
SettingsTab:Input({
    Title = "备注内容", Icon = "file-text",
    Placeholder = "输入备注",
    Callback = function(v) noteText = v end,
})
SettingsTab:Button({
    Title = "保存备注", Icon = "save",
    Callback = function()
        if not noteName or noteName == "" then
            Notify("失败", "请输入脚本名", 3, "x"); return
        end
        Notes[noteName] = noteText
        writeJson(NotesPath, Notes)
        Notify("已保存", noteName .. " 的备注", 3, "check")
    end,
})
SettingsTab:Button({
    Title = "查看备注", Icon = "eye",
    Callback = function()
        if not noteName or noteName == "" then
            Notify("失败", "请输入脚本名", 3, "x"); return
        end
        local n = Notes[noteName]
        if n then Notify("备注", noteName .. "：\n" .. n, 6)
        else Notify("无备注", noteName .. " 没有备注", 3) end
    end,
})

-- ==========================================================
-- 【第 5 部分】信息面板 + UI 增强
-- ==========================================================

-- ==================== 信息面板页签 ====================
local InfoTab = Window:Tab({ Title = "信息", Icon = "activity", Locked = false })

InfoTab:Section({ Title = "实时数据", TextXAlignment = "Left" })

local function makeLiveParagraph(tab, title)
    local obj = tab:Paragraph({ Title = title, Desc = "计算中..." })
    local function set(text)
        if not obj then return end
        if type(obj.SetDesc) == "function" then
            pcall(function() obj:SetDesc(text) end)
        elseif type(obj.SetTitle) == "function" then
            pcall(function() obj:SetTitle(text) end)
        end
    end
    return set
end

local setFpsDisplay    = makeLiveParagraph(InfoTab, "FPS")
local setPingDisplay   = makeLiveParagraph(InfoTab, "Ping")
local setMemDisplay    = makeLiveParagraph(InfoTab, "内存")
local setCoordDisplay  = makeLiveParagraph(InfoTab, "坐标")
local setServerDisplay = makeLiveParagraph(InfoTab, "服务器运行时间")
local setPlayerDisplay = makeLiveParagraph(InfoTab, "在线玩家")

task.spawn(function()
    local RS = game:GetService("RunService")
    local Stats = game:GetService("Stats")
    while Window do
        local dt = RS.RenderStepped:Wait()
        local fps = math.floor(1 / math.max(dt, 1e-4))
        setFpsDisplay(fps .. " FPS")

        pcall(function()
            local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
            setPingDisplay(ping .. " ms")
        end)

        pcall(function()
            local mem = math.floor(Stats:GetTotalMemoryUsageMb())
            setMemDisplay(mem .. " MB")
        end)

        pcall(function()
            local char = plr.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local p = hrp.Position
                setCoordDisplay(string.format("X: %.1f  Y: %.1f  Z: %.1f", p.X, p.Y, p.Z))
            else
                setCoordDisplay("角色未加载")
            end
        end)

        pcall(function()
            local uptime = math.floor(workspace.DistributedGameTime)
            local h = math.floor(uptime / 3600)
            local m = math.floor((uptime % 3600) / 60)
            setServerDisplay(h .. " 小时 " .. m .. " 分")
        end)

        pcall(function()
            setPlayerDisplay(#Players:GetPlayers() .. " 人")
        end)

        task.wait(1)
    end
end)

InfoTab:Section({ Title = "服务器信息", TextXAlignment = "Left" })

InfoTab:Paragraph({ Title = "PlaceId", Desc = tostring(game.PlaceId) })
InfoTab:Paragraph({ Title = "JobId", Desc = game.JobId ~= "" and game.JobId or "未知" })
InfoTab:Paragraph({
    Title = "游戏名",
    Desc = (function()
        local ok, name = pcall(function()
            return game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId).Name
        end)
        return ok and name or "获取失败"
    end)(),
})

InfoTab:Button({
    Title = "复制服务器信息",
    Icon = "copy",
    Callback = function()
        local txt = "PlaceId: " .. game.PlaceId ..
                    "\nJobId: " .. game.JobId ..
                    "\n在线: " .. #Players:GetPlayers() .. " 人"
        setclipboard(txt)
        Notify("已复制", "服务器信息已复制", 3, "check")
    end,
})

-- ==================== UI 设置页签 ====================
local UISettings = Window:Tab({ Title = "UI 设置", Icon = "palette", Locked = false })

UISettings:Section({ Title = "窗口外观", TextXAlignment = "Left" })

local function getGuiParentSafe()
    local ok, hui = pcall(function() return gethui() end)
    if ok and hui then return hui end
    local ok2, core = pcall(function() return game:GetService("CoreGui") end)
    if ok2 and core then return core end
    return nil
end

UISettings:Slider({
    Title = "UI 缩放",
    Step = 0.05,
    Value = { Min = 0.5, Max = 1.5, Default = 1 },
    Callback = function(v)
        pcall(function()
            local parent = getGuiParentSafe()
            if not parent then return end
            for _, obj in ipairs(parent:GetDescendants()) do
                if obj:IsA("ScreenGui") and (obj.Name:find("Wind") or obj.Name:find("爱国者")) then
                    local scale = obj:FindFirstChildOfClass("UIScale")
                    if scale then
                        scale.Scale = v
                    else
                        local s = Instance.new("UIScale")
                        s.Scale = v
                        s.Parent = obj
                    end
                end
            end
        end)
    end,
})

local NoticeDuration = 4
UISettings:Slider({
    Title = "通知时长",
    Step = 1,
    Value = { Min = 1, Max = 15, Default = 4 },
    Callback = function(v) NoticeDuration = v end,
})

UISettings:Dropdown({
    Title = "通知位置",
    Values = { "右上", "左上", "右下", "左下" },
    Value = "右上",
    Callback = function(v)
        local side = (v == "右上" or v == "右下") and "Right" or "Left"
        pcall(function() WindUI:SetNotifySide(side) end)
        Notify("已切换", "通知位置: " .. v, 2, "check")
    end,
})

UISettings:Section({ Title = "窗口文字", TextXAlignment = "Left" })

local CustomTitle = "爱国者 Hub"
UISettings:Input({
    Title = "自定义标题",
    Icon = "type",
    Placeholder = "输入新标题",
    Callback = function(v)
        if v and v ~= "" then
            CustomTitle = v
            Notify("提示", "标题已记录，重启生效", 3)
        end
    end,
})

UISettings:Button({
    Title = "应用标题",
    Icon = "check",
    Callback = function()
        pcall(function()
            local parent = getGuiParentSafe()
            if not parent then return end
            for _, obj in ipairs(parent:GetDescendants()) do
                if obj:IsA("ScreenGui") and (obj.Name:find("Wind") or obj.Name:find("爱国者")) then
                    for _, label in ipairs(obj:GetDescendants()) do
                        if label:IsA("TextLabel") and label.Text == "爱国者 Hub" then
                            label.Text = CustomTitle
                            break
                        end
                    end
                end
            end
        end)
        Notify("已应用", "标题已修改", 3, "check")
    end,
})

UISettings:Section({ Title = "音效", TextXAlignment = "Left" })

local SoundEnabled = true
UISettings:Toggle({
    Title = "点击音效",
    Default = true,
    Callback = function(s) SoundEnabled = s end,
})

-- ==========================================================
-- 【第 6 部分】脚本工具 + 玩家工具 + 游戏工具
-- ==========================================================

-- ==================== 脚本工具页签 ====================
local ScriptToolTab = Window:Tab({ Title = "脚本工具", Icon = "wrench", Locked = false })

ScriptToolTab:Section({ Title = "脚本队列", TextXAlignment = "Left" })

local Queue = {}
local QueueRunning = false
local queueName, queueUrl = "", ""

ScriptToolTab:Input({
    Title = "队列脚本名", Icon = "tag",
    Callback = function(v) queueName = v end,
})
ScriptToolTab:Input({
    Title = "队列脚本链接", Icon = "link",
    Callback = function(v) queueUrl = v end,
})
ScriptToolTab:Button({
    Title = "添加到队列", Icon = "plus",
    Callback = function()
        if not queueUrl or queueUrl == "" then
            Notify("失败", "请填链接", 3, "x"); return
        end
        table.insert(Queue, {
            name = (queueName ~= "" and queueName) or ("脚本" .. (#Queue + 1)),
            url = queueUrl,
        })
        Notify("已添加", "当前队列 " .. #Queue .. " 个", 3, "check")
    end,
})
ScriptToolTab:Button({
    Title = "开始执行队列", Icon = "play",
    Callback = function()
        if QueueRunning then Notify("提示", "队列正在执行中", 3); return end
        if #Queue == 0 then Notify("失败", "队列为空", 3, "x"); return end
        QueueRunning = true
        task.spawn(function()
            for i, item in ipairs(Queue) do
                Notify("队列执行", i .. "/" .. #Queue .. " " .. item.name, 2)
                pcall(function()
                    local src = game:HttpGet(item.url)
                    if src and src ~= "" then
                        local fn = safeLoadScript(src)
                        if fn then fn() end
                    end
                end)
                task.wait(2)
            end
            Queue = {}
            QueueRunning = false
            Notify("队列完成", "全部执行完毕", 3, "check")
        end)
    end,
})
ScriptToolTab:Button({
    Title = "清空队列", Icon = "trash",
    Callback = function()
        Queue = {}
        Notify("已清空", "队列已清空", 3, "check")
    end,
})

ScriptToolTab:Section({ Title = "重新加载", TextXAlignment = "Left" })

ScriptToolTab:Button({
    Title = "重新加载上次脚本", Icon = "refresh-cw",
    Callback = function()
        local last = _G.__PatriotLastScript
        if not last or not last.name or not last.url then
            Notify("失败", "没有上次记录", 3, "x"); return
        end
        Notify("重载中", last.name, 2)
        LoadScriptByName(last.name, last.url)
    end,
})

-- ==================== 玩家工具页签 ====================
local PlayerToolTab = Window:Tab({ Title = "玩家工具", Icon = "users", Locked = false })

PlayerToolTab:Section({ Title = "玩家操作", TextXAlignment = "Left" })

local targetPlayerName = ""
PlayerToolTab:Input({
    Title = "玩家名称", Icon = "user",
    Callback = function(v) targetPlayerName = v end,
})

PlayerToolTab:Button({
    Title = "复制玩家 UserID", Icon = "copy",
    Callback = function()
        local p = Players:FindFirstChild(targetPlayerName)
        if not p then Notify("失败", "找不到玩家", 3, "x"); return end
        setclipboard(tostring(p.UserId))
        Notify("已复制", p.Name .. " ID: " .. p.UserId, 3, "check")
    end,
})

PlayerToolTab:Button({
    Title = "复制玩家显示名", Icon = "copy",
    Callback = function()
        local p = Players:FindFirstChild(targetPlayerName)
        if not p then Notify("失败", "找不到玩家", 3, "x"); return end
        setclipboard(p.DisplayName)
        Notify("已复制", p.DisplayName, 3, "check")
    end,
})

PlayerToolTab:Button({
    Title = "复制玩家账号年龄", Icon = "copy",
    Callback = function()
        local p = Players:FindFirstChild(targetPlayerName)
        if not p then Notify("失败", "找不到玩家", 3, "x"); return end
        setclipboard(tostring(p.AccountAge))
        Notify("已复制", p.AccountAge .. " 天", 3, "check")
    end,
})

PlayerToolTab:Button({
    Title = "查看玩家信息", Icon = "info",
    Callback = function()
        local p = Players:FindFirstChild(targetPlayerName)
        if not p then Notify("失败", "找不到玩家", 3, "x"); return end
        local info = "用户名: " .. p.Name ..
                     "\n显示名: " .. p.DisplayName ..
                     "\nID: " .. p.UserId ..
                     "\n账号年龄: " .. p.AccountAge .. " 天"
        Notify("玩家信息", info, 8)
    end,
})

PlayerToolTab:Section({ Title = "玩家列表", TextXAlignment = "Left" })

PlayerToolTab:Paragraph({
    Title = "当前服务器玩家",
    Desc = (function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            table.insert(names, p.Name)
        end
        return #names > 0 and table.concat(names, "\n") or "无"
    end)(),
})

PlayerToolTab:Button({
    Title = "复制所有玩家名字", Icon = "copy",
    Callback = function()
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            table.insert(names, p.Name)
        end
        setclipboard(table.concat(names, "\n"))
        Notify("已复制", #names .. " 个玩家名", 3, "check")
    end,
})

-- ==================== 游戏工具页签 ====================
local GameToolTab = Window:Tab({ Title = "游戏工具", Icon = "gamepad-2", Locked = false })

GameToolTab:Section({ Title = "天空盒", TextXAlignment = "Left" })

local skyPresets = {
    ["默认"] = nil,
    ["日落"] = "rbxassetid://4895664308",
    ["星空"] = "rbxassetid://159454299",
    ["雪山"] = "rbxassetid://2985358373",
    ["赛博朋克"] = "rbxassetid://6766367600",
    ["深海"] = "rbxassetid://6036208305",
}

GameToolTab:Dropdown({
    Title = "切换天空盒",
    Values = (function()
        local list = {}
        for k, _ in pairs(skyPresets) do table.insert(list, k) end
        table.sort(list)
        return list
    end)(),
    Value = "默认",
    Callback = function(v)
        local id = skyPresets[v]
        pcall(function()
            local old = Lighting:FindFirstChildOfClass("Sky")
            if old then old:Destroy() end
            if id then
                local sky = Instance.new("Sky")
                sky.SkyboxBk = id
                sky.SkyboxDn = id
                sky.SkyboxFt = id
                sky.SkyboxLf = id
                sky.SkyboxRt = id
                sky.SkyboxUp = id
                sky.Parent = Lighting
            end
        end)
        Notify("已切换", "天空盒: " .. v, 3, "check")
    end,
})

GameToolTab:Section({ Title = "环境", TextXAlignment = "Left" })

GameToolTab:Slider({
    Title = "时间（小时）",
    Step = 1,
    Value = { Min = 0, Max = 24, Default = 14 },
    Callback = function(v)
        pcall(function()
            Lighting.ClockTime = v
        end)
    end,
})

GameToolTab:Section({ Title = "Roblox 设置", TextXAlignment = "Left" })

GameToolTab:Button({
    Title = "关闭阴影", Icon = "sun",
    Callback = function()
        pcall(function() Lighting.GlobalShadows = false end)
        Notify("已关闭", "阴影已关闭", 3, "check")
    end,
})

GameToolTab:Button({
    Title = "开启阴影", Icon = "sun",
    Callback = function()
        pcall(function() Lighting.GlobalShadows = true end)
        Notify("已开启", "阴影已开启", 3, "check")
    end,
})

GameToolTab:Button({
    Title = "关闭雾效", Icon = "cloud-off",
    Callback = function()
        pcall(function() Lighting.FogEnd = 100000 end)
        Notify("已关闭", "雾效已关闭", 3, "check")
    end,
})

GameToolTab:Button({
    Title = "隐藏玩家名字",
    Desc = "本地隐藏其他玩家头顶名字",
    Icon = "user-x",
    Callback = function()
        local count = 0
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.NameDisplayDistance = 0
                    hum.HealthDisplayDistance = 0
                    count = count + 1
                end
            end
        end
        Notify("已隐藏", count .. " 个玩家名字", 3, "check")
    end,
})

GameToolTab:Button({
    Title = "恢复玩家名字",
    Icon = "user-check",
    Callback = function()
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= plr and p.Character then
                local hum = p.Character:FindFirstChildOfClass("Humanoid")
                if hum then
                    hum.NameDisplayDistance = 100
                    hum.HealthDisplayDistance = 100
                end
            end
        end
        Notify("已恢复", "所有玩家名字已恢复", 3, "check")
    end,
})

-- ==========================================================
-- 全部拼接完成
-- 爱国者 Hub · 7.2.1 融合完整版
-- 作者：大肥鱼 | QQ: 3106633104
-- ==========================================================
print("[爱国者 Hub] 7.2.1 融合完整版已加载")
