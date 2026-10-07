-- =====================================================================
-- 熙熙 · 爱国者版 —— 模块化设计 · WindUI 单文件最终版
-- 作者：熙熙  |  版本：V2.1 WindUI Final
-- 说明：16 个模块全部内联进本文件，用 local Module = {} 隔离
--       外部脚本点击才加载，不预载，降低内存
--       彩蛋（520 爱心 / 鲸鱼 LOADI / 开场动画）全部保留
-- 用法：整文件粘贴进执行器运行；F 键开关 UI
-- =====================================================================

-- =====================================================================
-- MODULE 00 · 全局环境 / 服务 / 工具函数
-- =====================================================================
local cloneref = (cloneref or clonereference or function(i) return i end)
local Players   = cloneref(game:GetService("Players"))
local RunService = cloneref(game:GetService("RunService"))
local UIS       = cloneref(game:GetService("UserInputService"))
local HttpService = cloneref(game:GetService("HttpService"))
local Lighting  = cloneref(game:GetService("Lighting"))
local TeleportService = cloneref(game:GetService("TeleportService"))
local LP = Players.LocalPlayer
local CWD = "熙熙Patriot"

local function getChar()   return LP.Character or LP.CharacterAdded:Wait() end
local function getHum()    local c = getChar(); return c and c:FindFirstChildOfClass("Humanoid") end
local function getRoot()   local c = getChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function safeCall(fn, ...) local s,e = pcall(fn, ...) if not s then warn("[ERR]", e) end return s end
local function sNotify(t, c, d) if M01_UI and M01_UI.Ready and M01_UI.Notify then M01_UI.Notify(t, c, d) end end

-- =====================================================================
-- MODULE 01 · UI 库加载 + 封装层（隔离 WindUI，失败降级原生）
-- =====================================================================
local M01_UI = {}
M01_UI.Ready = false
M01_UI.Wind  = nil
M01_UI.FB    = nil
M01_UI.Tabs  = {}

local WindUI
local ok, err = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/Footagesus/WindUI/main/dist/main.lua"))()
end)
if not ok or not WindUI then
    ok, WindUI = pcall(function()
        return loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
    end)
end

if ok and WindUI then
    pcall(WindUI.SetNotificationLower, WindUI, true)
    M01_UI.Wind = WindUI:CreateWindow({
        Title = "熙熙 Patriot Hub",
        Icon = "star",
        Author = "V2.1 模块化 · WindUI",
        Theme = "Dark",
        Folder = "XixiPatriotWind",
        ToggleKey = Enum.KeyCode.F,
    })
    M01_UI.Ready = true
else
    warn("[UI] WindUI 加载失败，启用原生降级UI。错误：", err)
    local PG = LP:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui"); sg.Name = "XixiFallback"; sg.ResetOnSpawn = false; sg.Parent = PG
    local bf = Instance.new("Frame"); bf.Size = UDim2.new(0, 360, 0, 480); bf.Position = UDim2.new(0, 10, 0, 10)
    bf.BackgroundColor3 = Color3.fromRGB(22, 22, 26); bf.BorderSizePixel = 0; bf.Parent = sg
    Instance.new("UIListLayout", bf)
    M01_UI.FB = bf
end

function M01_UI:MakeTab(name, icon)
    if self.Ready then
        local t = self.Wind:Tab({ Title = name, Icon = icon or "circle" })
        self.Tabs[name] = t
        return t
    else
        local l = Instance.new("TextLabel", self.FB)
        l.Size = UDim2.new(1, -8, 0, 22); l.BackgroundTransparency = 1
        l.TextColor3 = Color3.fromRGB(255, 255, 255); l.Font = Enum.Font.Code
        l.TextSize = 13; l.Text = "TAB: " .. name
        local fake = {}
        fake.Button = function(_, x, cb)
            local b = Instance.new("TextButton", self.FB); b.Size = UDim2.new(1, -8, 0, 26)
            b.Text = x; b.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.MouseButton1Click:Connect(function() pcall(cb) end)
        end
        fake.Toggle = function(_, x, d, cb)
            local b = Instance.new("TextButton", self.FB); b.Size = UDim2.new(1, -8, 0, 26)
            b.Text = (d and "[x] " or "[ ] ") .. x; b.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            local s = d or false; pcall(cb, s)
            b.MouseButton1Click:Connect(function() s = not s; b.Text = (s and "[x] " or "[ ] ") .. x; pcall(cb, s) end)
        end
        fake.Slider = function(_, x, a, b2, d, cb)
            local b = Instance.new("TextButton", self.FB); b.Size = UDim2.new(1, -8, 0, 26)
            b.Text = x .. ": " .. d; b.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
            b.TextColor3 = Color3.fromRGB(255, 255, 255); pcall(cb, d)
            b.MouseButton1Click:Connect(function()
                local v = tonumber(d) or a; v = v + math.max(1, math.floor((b2 - a) / 10))
                if v > b2 then v = a end; b.Text = x .. ": " .. v; pcall(cb, v)
            end)
        end
        fake.Dropdown = function(_, x, vs, d, cb)
            for _, v in ipairs(vs) do
                local b = Instance.new("TextButton", self.FB); b.Size = UDim2.new(1, -8, 0, 22)
                b.Text = x .. "> " .. v; b.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
                b.TextColor3 = Color3.fromRGB(255, 255, 255)
                b.MouseButton1Click:Connect(function() pcall(cb, v) end)
            end
        end
        fake.Input = function(_, x, _, d, cb)
            local b = Instance.new("TextBox", self.FB); b.Size = UDim2.new(1, -8, 0, 26)
            b.PlaceholderText = x; b.Text = d or ""; b.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
            b.TextColor3 = Color3.fromRGB(255, 255, 255)
            b.FocusLost:Connect(function(e) if e then pcall(cb, b.Text) end end)
        end
        fake.Paragraph = function(_, x, d)
            local l2 = Instance.new("TextLabel", self.FB); l2.Size = UDim2.new(1, -8, 0, 40)
            l2.BackgroundTransparency = 1; l2.TextColor3 = Color3.fromRGB(200, 200, 200)
            l2.Font = Enum.Font.Code; l2.TextSize = 12; l2.TextWrapped = true
            l2.Text = x .. "\n" .. (d or "")
        end
        fake.Section = function() end
        self.Tabs[name] = fake
        return fake
    end
end

function M01_UI:Button(tab, text, cb, icon)
    if self.Ready then
        tab:Button({ Title = text, Icon = icon or "play", Callback = function() pcall(cb) end }); tab:Space()
    else tab:Button(text, cb) end
end

function M01_UI:Toggle(tab, text, def, cb, flag)
    if self.Ready then
        local c = { Title = text, Value = def or false, Callback = function(s) pcall(cb, s) end }
        if flag then c.Flag = flag end
        tab:Toggle(c); tab:Space()
    else tab:Toggle(text, def, cb) end
end

function M01_UI:Slider(tab, text, mn, mx, def, cb, flag)
    if self.Ready then
        local c = { Title = text, Step = 1, Value = { Min = mn, Max = mx, Default = def }, Callback = function(v) pcall(cb, v) end }
        if flag then c.Flag = flag end
        tab:Slider(c); tab:Space()
    else tab:Slider(text, mn, mx, def, cb) end
end

function M01_UI:Dropdown(tab, text, vals, def, cb, multi)
    if self.Ready then
        local c = { Title = text, Values = vals, Callback = function(v) pcall(cb, v) end }
        if multi then c.Multi = true; c.AllowNone = true; c.Value = type(def) == "table" and def or { def } else c.Value = def end
        tab:Dropdown(c); tab:Space()
    else tab:Dropdown(text, vals, def, cb) end
end

function M01_UI:Input(tab, text, ph, def, cb)
    if self.Ready then
        tab:Input({ Title = text, Placeholder = ph or "", Value = def or "", Callback = function(v) pcall(cb, v) end }); tab:Space()
    else tab:Input(text, ph, def, cb) end
end

function M01_UI:Paragraph(tab, t, d)
    if self.Ready then tab:Paragraph({ Title = t, Desc = d or "" }); tab:Space()
    else tab:Paragraph(t, d) end
end

function M01_UI:Section(tab, t)
    if self.Ready then tab:Section({ Title = t }); tab:Space() end
end

function M01_UI:Notify(title, content, dur)
    if self.Ready then
        pcall(WindUI.Notify, WindUI, { Title = title or "提示", Content = content or "", Icon = "solar:bell-bold", Duration = dur or 3 })
    else print("[NFY]", title, content) end
end

-- =====================================================================
-- MODULE 02 · 彩蛋（520 爱心 / 鲸鱼 LOADI / 开场动画 / 执行计数）
-- =====================================================================
local M02_Egg = {}

function M02_Egg:Heart()
    local PG = LP:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui"); sg.Name = "XixiHeart"; sg.ResetOnSpawn = false; sg.Parent = PG
    local fr = Instance.new("Frame"); fr.Size = UDim2.new(0, 220, 0, 220)
    fr.Position = UDim2.new(0.5, -110, 0.5, -110); fr.BackgroundTransparency = 1; fr.Parent = sg
    for i = 1, 520 do
        local a = i / 520 * math.pi * 2
        local x = 16 * math.pow(math.sin(a), 3)
        local y = 13 * math.cos(a) - 5 * math.cos(2 * a) - 2 * math.cos(3 * a) - math.cos(4 * a)
        local d = Instance.new("Frame"); d.Size = UDim2.new(0, 3, 0, 3)
        d.BackgroundColor3 = Color3.fromHSV(i / 520, 1, 1)
        d.Position = UDim2.new(0, 110 + x * 4, 0, 110 - y * 4); d.Parent = fr
    end
    task.delay(4, function() sg:Destroy() end)
end

function M02_Egg:Whale()
    sNotify("鲸鱼彩蛋", "LOADI 鲸鱼启动~ 主人回来啦", 3)
end

function M02_Egg:Intro()
    local PG = LP:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui"); sg.Name = "XixiIntro"; sg.ResetOnSpawn = false; sg.Parent = PG
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0, 500, 0, 80)
    lbl.Position = UDim2.new(0.5, -250, 0.5, -40); lbl.Text = "欢迎使用 熙熙·爱国者版"
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 36; lbl.BackgroundTransparency = 1
    lbl.TextStrokeTransparency = 0; lbl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    lbl.TextColor3 = Color3.fromRGB(255, 255, 255); lbl.Parent = sg
    local hue = 0
    local c = RunService.RenderStepped:Connect(function(dt)
        hue = (hue + dt * 0.5) % 1; lbl.TextColor3 = Color3.fromHSV(hue, 1, 1)
    end)
    task.delay(3, function()
        c:Disconnect()
        if lbl then lbl:Destroy() end
        if sg then sg:Destroy() end
    end)
end

function M02_Egg:CountExec()
    local path = "XixiExecCount.txt"
    local n = 0
    local s, v = pcall(function()
        if readfile and isfile and isfile(path) then return tonumber(readfile(path)) or 0 end
        return 0
    end)
    n = (s and v) or 0
    n = n + 1
    pcall(function() if writefile then writefile(path, tostring(n)) end end)
    return n
end

-- =====================================================================
-- MODULE 03 · 飞行模块（WASD + 空格上 / Ctrl 下）
-- =====================================================================
local M03_Fly = { On = false, Speed = 50, Conn = nil }
local M03_FlyConn2 = nil

function M03_Fly:Start()
    self.On = true
    if self.Conn then self.Conn:Disconnect() end
    local h = getHum()
    if h then h.PlatformStand = true end
    self.Conn = RunService.Heartbeat:Connect(function()
        local r = getRoot()
        if not r then return end
        local v = Vector3.new()
        local cam = workspace.CurrentCamera
        if UIS:IsKeyDown(Enum.KeyCode.W) then v = v + cam.CFrame.LookVector * self.Speed end
        if UIS:IsKeyDown(Enum.KeyCode.S) then v = v - cam.CFrame.LookVector * self.Speed end
        if UIS:IsKeyDown(Enum.KeyCode.A) then v = v - cam.CFrame.RightVector * self.Speed end
        if UIS:IsKeyDown(Enum.KeyCode.D) then v = v + cam.CFrame.RightVector * self.Speed end
        if UIS:IsKeyDown(Enum.KeyCode.Space) then v = v + Vector3.new(0, self.Speed, 0) end
        if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then v = v - Vector3.new(0, self.Speed, 0) end
        r.Velocity = v
    end)
    sNotify("飞行", "已开启，速度 " .. self.Speed, 2)
end

function M03_Fly:Stop()
    self.On = false
    if self.Conn then self.Conn:Disconnect(); self.Conn = nil end
    local h = getHum()
    if h then h.PlatformStand = false end
    sNotify("飞行", "已关闭", 2)
end

function M03_Fly:Toggle()
    if self.On then self:Stop() else self:Start() end
end

-- =====================================================================
-- MODULE 04 · 通用功能开关处理器（无敌/穿墙/隐身/踏空/收集/点击传送/自动攻击/夜视等）
-- =====================================================================
local M04_Feat = { Conns = {}, OriginalKick = nil, BlockKick = false }
local _toggleConns = {}

local function featCleanup(code)
    if _toggleConns[code] then
        pcall(function() _toggleConns[code]:Disconnect() end)
        _toggleConns[code] = nil
    end
end

function M04_Feat:Set(code, enabled)
    if enabled then
        if code == "god" then
            local c = getChar(); local h = getHum()
            if h then
                h.MaxHealth = 99999; h.Health = 99999
                _toggleConns[code] = RunService.RenderStepped:Connect(function()
                    local h2 = getHum(); if h2 then h2.Health = 99999 end
                end)
            end
        elseif code == "noclip" then
            _toggleConns[code] = RunService.Stepped:Connect(function()
                local c = getChar()
                if c then for _, v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
            end)
        elseif code == "invisible" then
            _toggleConns[code] = RunService.RenderStepped:Connect(function()
                local c = getChar()
                if c then for _, v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then v.LocalTransparencyModifier = 1 end end end
            end)
        elseif code == "float" then
            local r = getRoot()
            if r then
                local fy = r.Position.Y
                _toggleConns[code] = RunService.RenderStepped:Connect(function()
                    local r2 = getRoot()
                    if r2 and r2.Parent then
                        r2.Velocity = Vector3.new(r2.Velocity.X, 0, r2.Velocity.Z)
                        r2.CFrame = CFrame.new(r2.Position.X, fy, r2.Position.Z)
                    end
                end)
            end
        elseif code == "collect" then
            local r = getRoot()
            if r then
                _toggleConns[code] = RunService.Heartbeat:Connect(function()
                    local r2 = getRoot()
                    if not r2 then return end
                    for _, item in ipairs(workspace:GetDescendants()) do
                        if item:IsA("Tool") or item:IsA("MeshPart") or (item:IsA("Part") and (item.Name:lower():find("drop") or item.Name:lower():find("coin") or item.Name:lower():find("gem") or item.Name:lower():find("collect") or item.Name:lower():find("orb"))) then
                            if (item.Position - r2.Position).Magnitude < 80 then
                                item.CFrame = r2.CFrame + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
                            end
                        end
                    end
                end)
            end
        elseif code == "clicktp" then
            local mouse = LP:GetMouse()
            _toggleConns[code] = mouse.Button1Down:Connect(function()
                local r = getRoot(); if r and mouse.Hit then r.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0)) end
            end)
        elseif code == "autoclick" then
            local vu = game:GetService("VirtualUser")
            _toggleConns[code] = RunService.RenderStepped:Connect(function()
                local s = workspace.CurrentCamera.ViewportSize
                vu:Button1Down(Vector2.new(s.X / 2, s.Y / 2))
                task.wait(0.05)
                vu:Button1Up(Vector2.new(s.X / 2, s.Y / 2))
            end)
        elseif code == "night" then
            Lighting.Brightness = 2; Lighting.ClockTime = 14; Lighting.FogEnd = 100000; Lighting.GlobalShadows = false
        elseif code == "fulllight" then
            Lighting.Brightness = 5; Lighting.ClockTime = 14; Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false; Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        elseif code == "clearfog" then
            Lighting.FogEnd = 100000; Lighting.FogStart = 50000
        elseif code == "superspeed" then
            local h = getHum(); if h then h.WalkSpeed = 1000 end
        elseif code == "infjump" then
            _toggleConns[code] = UIS.JumpRequest:Connect(function()
                local h = getHum(); if h then h:ChangeState(Enum.HumanoidStateType.Jumping) end
            end)
        elseif code == "teamglow" then
            local myTeam = LP.Team
            _toggleConns[code] = RunService.RenderStepped:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Team == myTeam and not p.Character:FindFirstChild("TeamGlow") then
                        local hl = Instance.new("Highlight"); hl.Name = "TeamGlow"
                        hl.FillColor = Color3.fromRGB(0, 100, 255); hl.OutlineColor = Color3.fromRGB(0, 150, 255)
                        hl.FillTransparency = 0.5; hl.Parent = p.Character
                    end
                end
            end)
        elseif code == "enemyglow" then
            local myTeam = LP.Team
            _toggleConns[code] = RunService.RenderStepped:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Team ~= myTeam and not p.Character:FindFirstChild("EnemyGlow") then
                        local hl = Instance.new("Highlight"); hl.Name = "EnemyGlow"
                        hl.FillColor = Color3.fromRGB(255, 0, 0); hl.OutlineColor = Color3.fromRGB(255, 50, 50)
                        hl.FillTransparency = 0.5; hl.Parent = p.Character
                    end
                end
            end)
        elseif code == "autoattack" then
            _toggleConns[code] = RunService.RenderStepped:Connect(function()
                local c = getChar(); if not c then return end
                local nearest, minDist, myTeam = nil, 15, LP.Team
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LP and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Team ~= myTeam and p.Character.Humanoid.Health > 0 then
                        local d = (p.Character.HumanoidRootPart.Position - c.HumanoidRootPart.Position).Magnitude
                        if d < minDist then minDist = d; nearest = p.Character end
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
        elseif code == "suicide" then
            local h = getHum(); if h then h.Health = 0 end
        elseif code == "blockkick" then
            if not self.OriginalKick then self.OriginalKick = LP.Kick end
            LP.Kick = function() sNotify("防护", "拦截了一次 Kick", 2) end
            self.BlockKick = true
        elseif code == "antiafk" then
            local vu = game:GetService("VirtualUser")
            _toggleConns[code] = LP.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
                task.wait(1)
                vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            end)
        end
    else
        if code == "god" then
            local h = getHum(); if h then h.MaxHealth = 100; h.Health = 100 end
        elseif code == "superspeed" then
            local h = getHum(); if h then h.WalkSpeed = 16 end
        elseif code == "noclip" or code == "invisible" then
            local c = getChar()
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true; v.LocalTransparencyModifier = 0 end
            end end
        elseif code == "night" then
            Lighting.Brightness = 1; Lighting.ClockTime = 14; Lighting.GlobalShadows = true
        elseif code == "fulllight" then
            Lighting.Brightness = 1; Lighting.GlobalShadows = true
        elseif code == "clearfog" then
            Lighting.FogEnd = 1000; Lighting.FogStart = 0
        elseif code == "teamglow" then
            for _, p in ipairs(Players:GetPlayers()) do
                local hl = p.Character and p.Character:FindFirstChild("TeamGlow"); if hl then hl:Destroy() end
            end
        elseif code == "enemyglow" then
            for _, p in ipairs(Players:GetPlayers()) do
                local hl = p.Character and p.Character:FindFirstChild("EnemyGlow"); if hl then hl:Destroy() end
            end
        elseif code == "blockkick" then
            if self.OriginalKick then pcall(function() LP.Kick = self.OriginalKick end) end
            self.BlockKick = false
        end
        featCleanup(code)
    end
end

-- =====================================================================
-- MODULE 05 · 玩家工具（传送/信息/名字列表）
-- =====================================================================
local M05_Player = {}

function M05_Player:GetNames()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP then table.insert(list, p.Name) end
    end
    return list
end

function M05_Player:TPTo(name)
    local t = Players:FindFirstChild(name)
    if not t then sNotify("失败", "找不到玩家", 3); return end
    local tc = t.Character; local mc = getChar()
    if not tc or not tc:FindFirstChild("HumanoidRootPart") then sNotify("失败", "目标未加载", 3); return end
    if not mc or not mc:FindFirstChild("HumanoidRootPart") then sNotify("失败", "你未加载", 3); return end
    mc.HumanoidRootPart.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
    sNotify("传送", "已传送到 " .. name, 3)
end

function M05_Player:Home()
    local c = getChar(); local r = getRoot()
    if r and M05_Player.HomePos then r.CFrame = M05_Player.HomePos; sNotify("回家", "已回到出生点", 3) end
end

function M05_Player:SetHome()
    local r = getRoot()
    if r then M05_Player.HomePos = r.CFrame; sNotify("标记", "已记录当前位置为家", 3) end
end

function M05_Player:CopyID(name)
    local p = Players:FindFirstChild(name)
    if not p then sNotify("失败", "找不到玩家", 3); return end
    pcall(setclipboard, tostring(p.UserId)); sNotify("已复制", p.Name .. " ID: " .. p.UserId, 3)
end

-- =====================================================================
-- MODULE 06 · 音乐模块
-- =====================================================================
local M06_Music = { Sound = nil }

local MusicList = {
    { name = "进击的巨人",       id = "89711807693889" },
    { name = "误闯天家",         id = "124384558101360" },
    { name = "DJ喂喂喂",         id = "90054735589094" },
    { name = "unhappy",          id = "88523902860927" },
    { name = "震撼小曲二",       id = "137717310854691" },
    { name = "曾经的王",         id = "121931252233493" },
    { name = "离开我的依赖",     id = "112834898401032" },
    { name = "雨爱",             id = "79277371759525" },
    { name = "iqoo",             id = "75047041148646" },
    { name = "玉米饼",           id = "142376088" },
    { name = "我太想进步了",     id = "126846792948717" },
    { name = "最初的记忆",       id = "108869975942" },
    { name = "海与你",           id = "76421239273915" },
    { name = "失眠",             id = "138048397060431" },
    { name = "祖国人进行曲",     id = "86555185586884" },
}

function M06_Music:PlayByName(idx)
    local m = MusicList[idx]
    if not m then return end
    self:Stop()
    local s = Instance.new("Sound"); s.SoundId = "rbxassetid://" .. m.id
    s.Volume = 1; s.Looped = false; s.Parent = workspace; s:Play()
    s.Ended:Connect(function() s:Destroy() end)
    self.Sound = s
    sNotify("音乐", "正在播放：" .. m.name, 3)
end

function M06_Music:Stop()
    if self.Sound then pcall(function() self.Sound:Stop(); self.Sound:Destroy() end); self.Sound = nil end
    sNotify("音乐", "已停止", 2)
end

function M06_Music:PlayFromText(txt)
    if not txt or txt == "" then return end
    local id = txt:match("rbxassetid://(%d+)") or txt:match("(%d+)")
    if not id then sNotify("音乐", "未识别音频ID", 3); return end
    self:Stop()
    local s = Instance.new("Sound"); s.SoundId = "rbxassetid://" .. id
    s.Volume = 1; s.Parent = workspace; s:Play()
    s.Ended:Connect(function() s:Destroy() end)
    self.Sound = s; sNotify("音乐", "播放 " .. id, 3)
end

-- =====================================================================
-- MODULE 07 · 脚本注册表 + 安全加载器（100+ 外部脚本）
-- =====================================================================
local M07_Scripts = { IsLoading = false, History = {}, Favorites = {}, Notes = {} }

local Whitelist = {
    ["https://raw.githubusercontent.com/"] = true,
    ["https://github.com/"] = true,
    ["https://pastebin.com/raw/"] = true,
    ["https://pastefy.app/"] = true,
    ["https://raw.gitcode.com/"] = true,
    ["https://gitee.com/"] = true,
}

local ScriptRegistry = {
    { Name = "落叶 Pro Hub",                  Cat = "主脚本",       Url = "https://raw.githubusercontent.com/SyndromeXph/Luoye-Pro-Hub/refs/heads/main/Script/Loader.lua" },
    { Name = "国内最强脚本中心",              Cat = "主脚本",       Url = "https://raw.githubusercontent.com/ggsq1741-debug/rj/refs/heads/main/pjie.lua" },
    { Name = "叶脚本 - 主脚本大全",          Cat = "主脚本",       Url = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua" },
    { Name = "ROB 脚本 V2",                  Cat = "主脚本",       Url = "https://raw.githubusercontent.com/Zyb150933/ROB/refs/heads/main/ROB.V2" },
    { Name = "黑洞中心 (BS)",                Cat = "主脚本",       Url = "https://gitee.com/BS_script/script/raw/master/BS_Script.Luau" },
    { Name = "Delta Force 脚本中心",         Cat = "主脚本",       Url = "https://api.jnkie.com/api/v1/luascripts/public/28f05f20579742b8db3901d189ca93ddecb4ff36815cee23d34bdff05ad7ae33/download" },
    { Name = "ROB 活动",                     Cat = "主脚本",       Url = "https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/ROB.活动" },
    { Name = "ROB V4",                       Cat = "主脚本",       Url = "https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/rob.v4" },
    { Name = "夜脚本",                       Cat = "主脚本",       Url = "https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/yejiaoben" },
    { Name = "恐脚本",                       Cat = "主脚本",       Url = "https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/恐脚本.NB" },
    { Name = "超高速跑者",                   Cat = "主脚本",       Url = "https://pastefy.app/yEEgIs1r/raw" },
    { Name = "圣奥里",                       Cat = "主脚本",       Url = "https://pastefy.app/Wot0aN3V/raw" },
    { Name = "翻瓶",                         Cat = "主脚本",       Url = "https://pastefy.app/AaMGGRLH/raw" },
    { Name = "最强战场",                     Cat = "主脚本",       Url = "https://pastefy.app/1ZEycK4m/raw" },
    { Name = "8个球池经典",                  Cat = "主脚本",       Url = "https://pastefy.app/gR2WUm0k/raw" },
    { Name = "终极战场",                     Cat = "主脚本",       Url = "https://pastefy.app/qunhKqEl/raw" },
    { Name = "国人电梯",                     Cat = "主脚本",       Url = "https://pastefy.app/eCUUlx4W/raw" },
    { Name = "Blox Fruit",                   Cat = "主脚本",       Url = "https://pastefy.app/cE1CuNwC/raw" },
    { Name = "BloxV13",                      Cat = "主脚本",       Url = "https://raw.gitcode.com/ROB5201314/dzsc/raw/main/Blox loot.XGJ" },
    { Name = "冷脚本 LBT-H",                 Cat = "主脚本",       Url = "https://raw.githubusercontent.com/odhdshhe/lenglenglenglenglenglenlenglenglenglenglenglenglengleng-LBT-H-cold-script/refs/heads/main/LENG%20LBT-H%20cold%20script.txt" },
    { Name = "星脚本",                       Cat = "主脚本",       Url = "https://raw.githubusercontent.com/zilinskaslandon/XingJiaoBen-2026-/refs/heads/main/%E6%98%9F%E8%84%9A%E6%9C%AC.lua" },
    { Name = "浅脚本",                       Cat = "主脚本",       Url = "https://raw.githubusercontent.com/renlua/shallow/main/Script_Hub.lua" },
    { Name = "Rb 脚本中心",                  Cat = "主脚本",       Url = "https://raw.githubusercontent.com/Yungengxin/roblox/refs/heads/main/Rb-Hub" },
    { Name = "Rb 脚本 - 汉化中心",           Cat = "主脚本",       Url = "https://api.luarmor.net/files/v3/loaders/4fe525637e43a1be8cb0cdf902d107c2.lua" },
    { Name = "Rb 脚本 v1.2.4",               Cat = "主脚本",       Url = "https://raw.githubusercontent.com/Yungengxin/roblox/main/RbHub-v_1.2.4" },
    { Name = "Sxingz 脚本",                  Cat = "主脚本",       Url = "https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/ZiO.lua" },
    { Name = "VM 脚本",                      Cat = "主脚本",       Url = "https://raw.githubusercontent.com/chano-oss/d/refs/heads/main/obfwni7iq3q.lua" },
    { Name = "迪脚本 2.0",                   Cat = "主脚本",       Url = "https://raw.githubusercontent.com/ddjlb7598/-2.0/refs/heads/main/%E8%BF%AA%E8%84%9A%E6%9C%AC2.0.lua" },
    { Name = "无脚本 V1",                    Cat = "主脚本",       Url = "https://raw.githubusercontent.com/XiaoXuCynic/Free-Script/main/无脚本V1混淆.lua.txt" },
    { Name = "黎明中心脚本",                 Cat = "主脚本",       Url = "https://raw.githubusercontent.com/qwrt5589/eododo/9c2ed7cbca352c21a0b67f4d79558bd56299f252/345678910.txt" },
    { Name = "XION 脚本",                    Cat = "主脚本",       Url = "https://raw.githubusercontent.com/smalldesikon/wocaonima/main/qq984820669.txt" },
    { Name = "芋风脚本（测试版）",           Cat = "主脚本",       Url = "https://raw.githubusercontent.com/0lihaorui0/dvdvhd/main/芋风脚本%20测试版(1).lua" },
    { Name = "X 脚本",                       Cat = "主脚本",       Url = "https://raw.githubusercontent.com/maowang1/xx/main/Protected_8858329470146381.txt" },
    { Name = "矢井凛脚本",                   Cat = "主脚本",       Url = "https://raw.githubusercontent.com/lxmyysd/XiaoXu/refs/heads/main/%E7%9F%A2%E4%BA%95%E5%87%9B%E6%BA%90%E7%A0%81.lua" },
    { Name = "禁漫中心脚本",                 Cat = "主脚本",       Url = "https://raw.githubusercontent.com/dingding123hhh/ng/main/jmlllllllIIIIlllllII.lua" },
    { Name = "秋脚本",                       Cat = "主脚本",       Url = "https://raw.githubusercontent.com/WS857960/-/main/秋·自制脚本新源码.txt" },
    { Name = "VOTR 脚本",                    Cat = "主脚本",       Url = "https://raw.githubusercontent.com/VOTR-HUB/MAIN/refs/heads/main/VOTR-MAIN" },
    { Name = "皮空脚本",                     Cat = "主脚本",       Url = "https://raw.githubusercontent.com/smalldesikon/eyidfki/840d4b80d4f312c70b7b1067e056a2c4f828ef32/%E6%89%A7%E8%A1%8C%E8%84%9A%E6%9C%AC(%E6%B7%B7%E6%B7%86%E5%90%8E).txt" },
    { Name = "黑白脚本加载器",               Cat = "主脚本",       Url = "https://raw.githubusercontent.com/tfcygvunbind/Apple/main/%E9%BB%91%E7%99%BD%E8%84%9A%E6%9C%AC%E5%8A%A0%E8%BD%BD%E5%99%A8" },

    { Name = "新圣奥里脚本",                 Cat = "服务器专区",   Url = "https://raw.githubusercontent.com/idkidevthings/improved-octo-chainsaw/refs/heads/main/sanx.lua" },
    { Name = "叶脚本 - 俄亥俄州",            Cat = "服务器专区",   Url = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/YE-%20Scripts-OHIO.lua" },
    { Name = "叶脚本 - 河北唐县",            Cat = "服务器专区",   Url = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/YE%20SCRIPT-Tang%20County%2C%20Hebei.lua" },

    { Name = "公益飞行彩虹版",               Cat = "功能脚本",     Url = "https://pastefy.app/tkHc58Wt/raw" },
    { Name = "ROB飞行旧版",                  Cat = "功能脚本",     Url = "https://pastefy.app/hXt2L9kY/raw" },
    { Name = "ROB飞行测试版",                Cat = "功能脚本",     Url = "https://pastefy.app/FA3q5ROD/raw" },
    { Name = "踏空行走",                     Cat = "功能脚本",     Url = "https://pastefy.app/qtazgrP6/raw" },
    { Name = "亮光透视",                     Cat = "功能脚本",     Url = "https://pastefy.app/LE2hzECZ/raw" },
    { Name = "锁头自瞄",                     Cat = "功能脚本",     Url = "https://pastefy.app/jeYSxlOI/raw" },
    { Name = "追踪雷达",                     Cat = "功能脚本",     Url = "https://pastefy.app/bJiEXfNS/raw" },
    { Name = "假延迟",                       Cat = "功能脚本",     Url = "https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/Desync(1).lua" },
    { Name = "自动翻译",                     Cat = "功能脚本",     Url = "https://pastefy.app/IbrQeCIh/raw" },
    { Name = "伪装欺骗",                     Cat = "功能脚本",     Url = "https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/weizhuang.robv4" },
    { Name = "防甩飞",                       Cat = "功能脚本",     Url = "https://raw.githubusercontent.com/Linux6699/DaHubRevival/main/AntiFling.lua" },
    { Name = "飞踢甩飞",                     Cat = "功能脚本",     Url = "https://raw.githubusercontent.com/kongbaNB/-/refs/heads/main/飞踢脚本汉化" },
    { Name = "祖国人飞行",                   Cat = "功能脚本",     Url = "https://raw.githubusercontent.com/giobolqv1/homelander-by-GioBolqv1-/main/homelander.lua" },

    { Name = "普通黑洞",                     Cat = "黑洞专区",     Url = "https://pastebin.com/raw/Sx6PY4gV" },
    { Name = "普通黑洞2",                    Cat = "黑洞专区",     Url = "https://pastefy.app/BbXuvVkK/raw" },
    { Name = "高级黑洞",                     Cat = "黑洞专区",     Url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/blackhole.lua" },
    { Name = "黑洞1",                        Cat = "黑洞专区",     Url = "https://pastefy.app/J21lpKbj/raw" },
    { Name = "黑洞2",                        Cat = "黑洞专区",     Url = "https://raw.githubusercontent.com/dingding123hhh/lililiugg/main/jm114514.lua" },
    { Name = "黑洞3",                        Cat = "黑洞专区",     Url = "https://pastefy.app/EwpVHMPg/raw" },
    { Name = "黑洞4",                        Cat = "黑洞专区",     Url = "https://raw.githubusercontent.com/BingusWR/BLACKHOLDSCRIPT/refs/heads/main/BLACK%20HOLD%20SCRIPT" },
    { Name = "黑洞5",                        Cat = "黑洞专区",     Url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/Blackholescript.lua" },
    { Name = "黑洞6",                        Cat = "黑洞专区",     Url = "https://raw.githubusercontent.com/BOOSBS/666/refs/heads/main/656" },
    { Name = "黑洞7",                        Cat = "黑洞专区",     Url = "https://pastebin.com/raw/U29jR1Cf" },
    { Name = "黑洞8",                        Cat = "黑洞专区",     Url = "https://raw.githubusercontent.com/BOOSBS/199/refs/heads/main/V3" },

    { Name = "五子棋",                       Cat = "小游戏",       Url = "https://pastefy.app/YiG9QQae/raw" },
    { Name = "俄罗斯方块",                   Cat = "小游戏",       Url = "https://files.catbox.moe/4g6uay.txt" },
    { Name = "贪吃蛇",                       Cat = "小游戏",       Url = "https://pastefy.app/6TWyR3SJ/raw" },
    { Name = "扫雷",                         Cat = "小游戏",       Url = "https://pastefy.app/TN9CoOPt/raw" },

    { Name = "光影",                         Cat = "画质光影",     Url = "https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml" },
    { Name = "RTX高仿",                      Cat = "画质光影",     Url = "https://pastebin.com/raw/Bkf0BJb3" },
    { Name = "超高画质",                     Cat = "画质光影",     Url = "https://pastebin.com/raw/jHBfJYmS" },

    { Name = "7yd7 动作脚本",                Cat = "动作/表情",    Url = "https://rawscripts.net/raw/Universal-Script-7yd7-I-Emote-Script-48024" },

    { Name = "皮脚本",                       Cat = "工具",         Url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua" },

    { Name = "餐厅大亨3",                    Cat = "服务器脚本",   Url = "https://pastefy.app/Lrs56Q8d/raw" },
    { Name = "超真实csgo",                   Cat = "服务器脚本",   Url = "https://pastefy.app/H7QvZbrd/raw" },
    { Name = "沉默的刺客",                   Cat = "服务器脚本",   Url = "https://pastefy.app/WvQ2X9Ap/raw" },
    { Name = "吃别人来成长",                 Cat = "服务器脚本",   Url = "https://pastefy.app/UNho7C7Q/raw" },
    { Name = "刀刃球",                       Cat = "服务器脚本",   Url = "https://pastefy.app/SrTbo5RW/raw" },
    { Name = "钓鱼模拟器",                   Cat = "服务器脚本",   Url = "https://pastefy.app/dR9CHVPs/raw" },
    { Name = "动物医院",                     Cat = "服务器脚本",   Url = "https://pastefy.app/i2DPWno2/raw" },
    { Name = "犯罪",                         Cat = "服务器脚本",   Url = "https://pastefy.app/jtpr1Mgc/raw" },
    { Name = "防御",                         Cat = "服务器脚本",   Url = "https://pastefy.app/tFXWWXzb/raw" },
    { Name = "花园地平线",                   Cat = "服务器脚本",   Url = "https://pastefy.app/gPSk0o4s/raw" },
    { Name = "滑开大海",                     Cat = "服务器脚本",   Url = "https://pastefy.app/ScntJmhk/raw" },
    { Name = "滑石头RNG",                    Cat = "服务器脚本",   Url = "https://pastefy.app/JAZZfkV4/raw" },
    { Name = "火箭发射模拟器",               Cat = "服务器脚本",   Url = "https://pastefy.app/sHzbfKCD/raw" },
    { Name = "火球训练",                     Cat = "服务器脚本",   Url = "https://pastefy.app/7HgyHMnU/raw" },
    { Name = "极速传奇",                     Cat = "服务器脚本",   Url = "https://pastefy.app/utTMkgQe/raw" },
    { Name = "集装箱RNG",                    Cat = "服务器脚本",   Url = "https://pastefy.app/sO4Ko8mm/raw" },
    { Name = "监狱泵",                       Cat = "服务器脚本",   Url = "https://pastefy.app/WShOvrFw/raw" },
    { Name = "僵尸生存竞技场",               Cat = "服务器脚本",   Url = "https://pastefy.app/PYn6KTay/raw" },
    { Name = "僵尸之塔",                     Cat = "服务器脚本",   Url = "https://pastefy.app/Wi2f84Ca/raw" },
    { Name = "戒网瘾中心",                   Cat = "服务器脚本",   Url = "https://pastefy.app/xGHE7EWS/raw" },
    { Name = "举重模拟器",                  Cat = "服务器脚本",   Url = "https://pastefy.app/QTeUq9I0/raw" },
    { Name = "决斗场",                       Cat = "服务器脚本",   Url = "https://pastefy.app/MRpyprG1/raw" },
    { Name = "砍伐树木",                     Cat = "服务器脚本",   Url = "https://pastefy.app/LS30JEFF/raw" },
    { Name = "克隆王国大亨",                 Cat = "服务器脚本",   Url = "https://pastefy.app/fR4qrMdt/raw" },
    { Name = "矿井",                         Cat = "服务器脚本",   Url = "https://pastefy.app/Md49dmBE/raw" },
    { Name = "力量传奇",                     Cat = "服务器脚本",   Url = "https://pastefy.app/S7GMe806/raw" },
    { Name = "每步+1智商",                   Cat = "服务器脚本",   Url = "https://pastefy.app/OfCgKxr3/raw" },
    { Name = "迷你帝国",                     Cat = "服务器脚本",   Url = "https://pastefy.app/sKyi6Hdq/raw" },
    { Name = "模仿者",                       Cat = "服务器脚本",   Url = "https://pastefy.app/WVCwCr6X/raw" },
    { Name = "木筏101天生存",                Cat = "服务器脚本",   Url = "https://pastefy.app/Hm4zw594/raw" },
    { Name = "奴才大亨",                     Cat = "服务器脚本",   Url = "https://pastefy.app/dz4hFQf6/raw" },
    { Name = "平滑切片",                     Cat = "服务器脚本",   Url = "https://pastefy.app/ADDvDF0Z/raw" },
    { Name = "破坏者谜团2",                  Cat = "服务器脚本",   Url = "https://pastefy.app/Dr5qahWL/raw" },
    { Name = "启示录",                       Cat = "服务器脚本",   Url = "https://pastefy.app/M7YGp8zN/raw" },
    { Name = "汽车营销商大亨",               Cat = "服务器脚本",   Url = "https://pastefy.app/DKVut4hJ/raw" },
    { Name = "强壮传奇",                     Cat = "服务器脚本",   Url = "https://pastefy.app/6TCozPef/raw" },
    { Name = "忍者传奇",                     Cat = "服务器脚本",   Url = "https://pastefy.app/WDHa8llX/raw" },
    { Name = "鲨鱼咬",                       Cat = "服务器脚本",   Url = "https://pastefy.app/gZ8J7xAT/raw" },
    { Name = "闪光",                         Cat = "服务器脚本",   Url = "https://pastefy.app/UmtpmEi3/raw" },
    { Name = "生存于杀手",                   Cat = "服务器脚本",   Url = "https://pastefy.app/baGsRsEU/raw" },
    { Name = "手枪竞技场",                   Cat = "服务器脚本",   Url = "https://pastefy.app/XfcDufEY/raw" },
    { Name = "水手碎片",                     Cat = "服务器脚本",   Url = "https://pastefy.app/AQjzR2BI/raw" },
    { Name = "撕咬之夜",                     Cat = "服务器脚本",   Url = "https://pastefy.app/Mom7Ic9J/raw" },
    { Name = "亡命速递",                     Cat = "服务器脚本",   Url = "https://pastefy.app/oyN2H3sW/raw" },
    { Name = "像素之刃",                     Cat = "服务器脚本",   Url = "https://pastefy.app/Ztkk1GrI/raw" },
    { Name = "血色地带",                     Cat = "服务器脚本",   Url = "https://pastefy.app/JV8YzSza/raw" },
    { Name = "血腥游乐场",                   Cat = "服务器脚本",   Url = "https://pastefy.app/FcaDu1vr/raw" },
    { Name = "血债",                         Cat = "服务器脚本",   Url = "https://pastefy.app/f0899vFy/raw" },
    { Name = "寻找巨型鱼",                   Cat = "服务器脚本",   Url = "https://pastefy.app/9jvzzO0g/raw" },
    { Name = "训练怪兽进行破坏",             Cat = "服务器脚本",   Url = "https://pastefy.app/b0jOaKFH/raw" },
    { Name = "月球增量",                     Cat = "服务器脚本",   Url = "https://pastefy.app/CDfIzMDv/raw" },
    { Name = "种植花园",                     Cat = "服务器脚本",   Url = "https://pastefy.app/NRTi5pfu/raw" },
    { Name = "诅咒之刃",                     Cat = "服务器脚本",   Url = "https://pastefy.app/8GgMUdI3/raw" },
    { Name = "菜鸟竞技场",                   Cat = "服务器脚本",   Url = "https://pastefy.app/eqQJ25wZ/raw" },
    { Name = "驾驶帝国",                     Cat = "服务器脚本",   Url = "https://pastefy.app/ynf4fWmK/raw" },
}

function M07_Scripts:IsWhitelisted(url)
    for prefix, _ in pairs(Whitelist) do
        if url:sub(1, #prefix) == prefix then return true end
    end
    return false
end

function M07_Scripts:LoadByName(name, url)
    if self.IsLoading then sNotify("请稍候", "已有脚本在加载", 2); return end
    if type(url) == "table" then url = url[1] end
    if not url or url == "" then sNotify("失败", "链接为空", 3); return end
    if not self:IsWhitelisted(url) then sNotify("拒绝", name .. " 不在白名单", 4); return end

    self.IsLoading = true
    sNotify("加载中", name, 2)
    task.spawn(function()
        local ok, err = pcall(function()
            local src = game:HttpGet(url)
            if not src or src == "" then error("内容为空") end
            local fn = loadstring(src)
            if not fn then error("编译失败") end
            fn()
        end)
        if ok then
            table.insert(self.History, { name = name, time = os.time() })
            while #self.History > 50 do table.remove(self.History, 1) end
            sNotify("成功", name .. " 已执行", 3)
        else
            sNotify("失败", name .. " 错误: " .. tostring(err), 5)
        end
        self.IsLoading = false
    end)
end

function M07_Scripts:LoadFromText(txt)
    if not txt or txt == "" then sNotify("失败", "空链接", 3); return end
    local id = txt:match("rbxassetid://(%d+)") or txt:match("(%d+)")
    if id and not txt:match("https?://") then
        self:LoadByName("Sound:" .. id, nil)
        M06_Music:PlayFromText(id)
        return
    end
    if not txt:match("https?://") then sNotify("失败", "不是有效链接", 3); return end
    self:LoadByName("手动链接", txt)
end

-- =====================================================================
-- MODULE 08 · ESP / 高亮管理
-- =====================================================================
local M08_ESP = { On = false, Color = Color3.fromRGB(255, 0, 0), List = {} }

function M08_ESP:Refresh()
    for _, v in pairs(self.List) do pcall(function() v:Destroy() end) end
    self.List = {}
    if not self.On then return end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LP and p.Character and not p.Character:FindFirstChild("XixiESP") then
            local hl = Instance.new("Highlight"); hl.Name = "XixiESP"
            hl.FillColor = self.Color; hl.OutlineColor = Color3.fromRGB(255, 255, 255)
            hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
            hl.Adornee = p.Character; hl.Parent = p.Character
            table.insert(self.List, hl)
        end
    end
end

function M08_ESP:SetColor(name)
    if name == "绿" then self.Color = Color3.fromRGB(0, 255, 0)
    elseif name == "蓝" then self.Color = Color3.fromRGB(0, 100, 255)
    else self.Color = Color3.fromRGB(255, 0, 0) end
    self:Refresh()
end

function M08_ESP:Toggle(v)
    self.On = v
    if not v then
        for _, hl in pairs(self.List) do pcall(function() hl:Destroy() end) end
        self.List = {}
    else self:Refresh() end
end

Players.PlayerAdded:Connect(function() if M08_ESP.On then M08_ESP:Refresh() end end)
Players.PlayerRemoving:Connect(function() if M08_ESP.On then M08_ESP:Refresh() end end)

-- =====================================================================
-- MODULE 09 · 环境 / 光影 / 天空盒
-- =====================================================================
local M09_Env = {}
local SkyPresets = {
    ["默认"] = nil,
    ["日落"] = "rbxassetid://4895664308",
    ["星空"] = "rbxassetid://159454299",
    ["雪山"] = "rbxassetid://2985358373",
    ["赛博朋克"] = "rbxassetid://6766367600",
    ["深海"] = "rbxassetid://6036208305",
}

function M09_Env:SetSky(name)
    local id = SkyPresets[name]
    pcall(function()
        local old = Lighting:FindFirstChildOfClass("Sky")
        if old then old:Destroy() end
        if id then
            local sky = Instance.new("Sky")
            sky.SkyboxBk = id; sky.SkyboxDn = id; sky.SkyboxFt = id
            sky.SkyboxLf = id; sky.SkyboxRt = id; sky.SkyboxUp = id
            sky.Parent = Lighting
        end
    end)
    sNotify("天空盒", "已切换：" .. name, 3)
end

function M09_Env:SetTime(h)
    pcall(function() Lighting.ClockTime = h end)
    sNotify("时间", "已设为 " .. h .. " 点", 2)
end

function M09_Env:ToggleShadow(v)
    pcall(function() Lighting.GlobalShadows = not v end)
    sNotify("阴影", v and "已关闭" or "已开启", 2)
end

function M09_Env:ToggleFog(v)
    pcall(function()
        if v then Lighting.FogEnd = 100000 else Lighting.FogEnd = 1000 end
    end)
    sNotify("雾效", v and "已关闭" or "已开启", 2)
end

-- =====================================================================
-- MODULE 10 · 信息面板（FPS / Ping / 坐标 / 内存 / 玩家数）
-- =====================================================================
local M10_Info = {}

function M10_Info:Start(tab)
    local lines = {
        FPS = "FPS: --",
        Ping = "Ping: --",
        Mem = "内存: --",
        Coord = "坐标: --",
        Uptime = "运行: --",
        Players = "在线: --",
    }
    local els = {}
    for k, v in pairs(lines) do
        els[k] = tab:Paragraph({ Title = v }); tab:Space()
    end
    local last, fc, cfps = tick(), 0, 0
    RunService.RenderStepped:Connect(function(dt)
        fc = fc + 1
        local e = tick() - last
        if e >= 0.5 then
            cfps = math.floor(fc / e); fc = 0; last = tick()
            local c = cfps >= 30 and "255,0,0" or "255,255,0"
            els.FPS:SetDesc('FPS: <font color="rgb(255,255,255)"></font><font color="rgb(' .. c .. ')">' .. cfps .. '</font>')
        end
        pcall(function()
            els.Ping:SetDesc("Ping: " .. math.floor(game:GetService("Stats").Network.ServerStatsItem["Data Ping"]:GetValue()) .. "ms")
            els.Mem:SetDesc("内存: " .. math.floor(game:GetService("Stats"):GetTotalMemoryUsageMb()) .. "MB")
        end)
        local r = getRoot()
        if r then
            local p = r.Position
            els.Coord:SetDesc(string.format("坐标: X:%.0f Y:%.0f Z:%.0f", p.X, p.Y, p.Z))
        end
        local up = math.floor(workspace.DistributedGameTime)
        els.Uptime:SetDesc(string.format("运行: %d时%d分", math.floor(up / 3600), math.floor((up % 3600) / 60)))
        els.Players:SetDesc("在线: " .. #Players:GetPlayers() .. "人")
    end)
end

-- =====================================================================
-- MODULE 11 · 服务器工具（重进/跳服/复制ID）
-- =====================================================================
local M11_Server = {}

function M11_Server:CopyID()
    pcall(setclipboard, tostring(game.JobId))
    sNotify("已复制", "JobId: " .. game.JobId, 4)
end

function M11_Server:Rejoin()
    pcall(function() TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
    sNotify("重进", "正在重新加入...", 3)
end

function M11_Server:JumpServer()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if ok and res and res.data and #res.data > 0 then
        local c = res.data[math.random(1, #res.data)]
        TeleportService:TeleportToPlaceInstance(game.PlaceId, c.id, LP)
        sNotify("跳服", "正在跳转...", 3)
    else
        sNotify("失败", "没有可用服务器", 3)
    end
end

function M11_Server:LeastPop()
    local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
    local ok, res = pcall(function() return HttpService:JSONDecode(game:HttpGet(url)) end)
    if ok and res and res.data and #res.data > 0 then
        table.sort(res.data, function(a, b) return a.playing < b.playing end)
        local c = res.data[1]
        for _, s in ipairs(res.data) do if s.playing < s.maxPlayers then c = s; break end end
        TeleportService:TeleportToPlaceInstance(game.PlaceId, c.id, LP)
        sNotify("跳服", "前往 " .. c.playing .. " 人服务器", 3)
    else
        sNotify("失败", "没有可用服务器", 3)
    end
end

-- =====================================================================
-- MODULE 12 · 配置保存 / 历史 / 收藏 / 备注（持久化）
-- =====================================================================
local M12_Store = { Cfg = {}, Fav = {}, Hist = {}, Note = {} }
local CfgPath = "XixiCfg.json"; FavPath = "XixiFav.json"; HistPath = "XixiHist.json"; NotePath = "XixiNote.json"

local function jread(p)
    local s, v = pcall(function() if isfile and isfile(p) then return HttpService:JSONDecode(readfile(p)) end end)
    return (s and v) or nil
end
local function jwrite(p, d)
    pcall(function() if writefile then writefile(p, HttpService:JSONEncode(d)) end end)
end

M12_Store.Cfg = jread(CfgPath) or {}
M12_Store.Fav = jread(FavPath) or {}
M12_Store.Hist = jread(HistPath) or {}
M12_Store.Note = jread(NotePath) or {}

function M12_Store:SaveCfg(t)
    self.Cfg = t; jwrite(CfgPath, t); sNotify("配置", "已保存", 2)
end
function M12_Store:AddFav(name)
    self.Fav[name] = true; jwrite(FavPath, self.Fav); sNotify("收藏", name .. " 已收藏（重启生效）", 3)
end
function M12_Store:DelFav(name)
    self.Fav[name] = nil; jwrite(FavPath, self.Fav); sNotify("收藏", name .. " 已移除", 3)
end
function M12_Store:SetNote(name, text)
    self.Note[name] = text; jwrite(NotePath, self.Note); sNotify("备注", name .. " 已保存", 3)
end
function M12_Store:GetNote(name)
    local n = self.Note[name]
    sNotify("备注", n and (name .. ":\n" .. n) or (name .. " 没有备注"), 6)
end
function M12_Store:ShowHist()
    local h = M07_Scripts.History
    if #h == 0 then sNotify("历史", "暂无记录", 3); return end
    local s = "最近执行："
    local st = math.max(1, #h - 9)
    for i = st, #h do s = s .. "\n" .. i .. ". " .. h[i].name end
    sNotify("历史", s, 8)
end
function M12_Store:ClearHist()
    M07_Scripts.History = {}; jwrite(HistPath, {}); sNotify("历史", "已清空", 3)
end

-- =====================================================================
-- MODULE 13 · FPS 浮窗
-- =====================================================================
local M13_FPS = { On = true, Label = nil }
local function makeFPS()
    local PG = LP:WaitForChild("PlayerGui")
    local sg = Instance.new("ScreenGui"); sg.Name = "XixiFPS"; sg.ResetOnSpawn = false; sg.Parent = PG
    local lbl = Instance.new("TextLabel"); lbl.Size = UDim2.new(0, 180, 0, 28)
    lbl.Position = UDim2.new(0, 8, 0, 8); lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.GothamBold; lbl.TextSize = 16; lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 100; lbl.RichText = true; lbl.Parent = sg
    M13_FPS.Label = lbl
    local last, fc = tick(), 0
    RunService.RenderStepped:Connect(function()
        if not M13_FPS.On then lbl.Visible = false; return end
        lbl.Visible = true; fc = fc + 1
        local e = tick() - last
        if e >= 0.5 then
            local fps = math.floor(fc / e); fc = 0; last = tick()
            local c = fps >= 30 and "255,0,0" or "255,255,0"
            lbl.Text = '<font color="rgb(255,255,255)">FPS: </font><font color="rgb(' .. c .. ')">' .. fps .. '</font>'
        end
    end)
end

function M13_FPS:Toggle(v) self.On = v end

-- =====================================================================
-- MODULE 14 · 整活特效集合
-- =====================================================================
local M14_Fun = {}

function M14_Fun:Fire()
    local r = getRoot()
    if not r then return end
    local p = Instance.new("ParticleEmitter"); p.Name = "XixiFire"
    p.Texture = "rbxassetid://0"; p.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
    p.Rate = 30; p.Speed = NumberRange.new(3, 6); p.Lifetime = NumberRange.new(0.5, 1); p.Parent = r
    sNotify("整活", "喷火已开启", 2)
end

function M14_Fun:Glow()
    local c = getChar()
    if not c then return end
    local hl = Instance.new("Highlight"); hl.Name = "XixiGlow"
    hl.FillColor = Color3.fromRGB(255, 255, 0); hl.OutlineColor = Color3.fromRGB(255, 200, 0)
    hl.FillTransparency = 0.3; hl.Parent = c
    sNotify("整活", "光环已开启", 2)
end

function M14_Fun:BigHead()
    local c = getChar()
    if c and c:FindFirstChild("Head") then c.Head.Size = Vector3.new(4, 4, 4) end
end

function M14_Fun:UpsideDown()
    local r = getRoot()
    if r then r.CFrame = r.CFrame * CFrame.Angles(0, 0, math.rad(180)) end
end

function M14_Fun:Trail(kind)
    local r = getRoot(); if not r then return end
    local trail = Instance.new("Trail"); trail.Name = "XixiTrail"
    local a0 = Instance.new("Attachment"); a0.Name = "XixiTrailA0"; a0.Parent = r
    local a1 = Instance.new("Attachment"); a1.Name = "XixiTrailA1"; a1.Position = Vector3.new(0, -2, 0); a1.Parent = r
    trail.Attachment0 = a0; trail.Attachment1 = a1
    if kind == "fire" then
        trail.Color = ColorSequence.new(Color3.fromRGB(255, 50, 0), Color3.fromRGB(255, 150, 0), Color3.fromRGB(255, 255, 0))
    elseif kind == "ice" then
        trail.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255), Color3.fromRGB(150, 220, 255), Color3.fromRGB(200, 240, 255))
    else
        trail.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255))
    end
    trail.Lifetime = 0.5; trail.Parent = r
    sNotify("整活", kind .. "拖尾已开启", 2)
end

function M14_Fun:RainbowName()
    local c = getChar(); if not c or not c:FindFirstChild("Head") then return end
    local bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0, 150, 0, 30)
    bb.StudsOffset = Vector3.new(0, 3, 0); bb.AlwaysOnTop = true; bb.Parent = c.Head
    local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1, 0, 1, 0)
    nl.BackgroundTransparency = 1; nl.Text = LP.DisplayName .. " 👑管理员"
    nl.Font = Enum.Font.GothamBold; nl.TextSize = 14; nl.Name = "XixiRBName"
    nl.TextStrokeTransparency = 0; nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); nl.Parent = bb
    local hue = 0
    RunService.RenderStepped:Connect(function(dt)
        hue = (hue + dt * 0.5) % 1
        local c2 = getChar()
        if c2 and c2:FindFirstChild("Head") then
            local bb2 = c2.Head:FindFirstChildOfClass("BillboardGui")
            if bb2 then
                local nl2 = bb2:FindFirstChild("XixiRBName")
                if nl2 then nl2.TextColor3 = Color3.fromHSV(hue, 1, 1) end
            end
        end
    end)
end

function M14_Fun:Giant()
    local c = getChar()
    if c then for _, v in ipairs(c:GetDescendants()) do if v:IsA("BasePart") then v.Size = v.Size * 3 end end end
end

function M14_Fun:Subtitle(v)
    local PG = LP:WaitForChild("PlayerGui")
    if v then
        local sg = Instance.new("ScreenGui"); sg.Name = "XixiSub"; sg.ResetOnSpawn = false; sg.Parent = PG
        local l = Instance.new("TextLabel"); l.Size = UDim2.new(0, 500, 0, 80)
        l.Position = UDim2.new(0.5, -250, 0, 10); l.Text = LP.Name .. " 已入侵服务器"
        l.Font = Enum.Font.GothamBold; l.TextSize = 24; l.BackgroundTransparency = 1
        l.TextStrokeTransparency = 0; l.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); l.Parent = sg
        local l2 = Instance.new("TextLabel"); l2.Size = UDim2.new(0, 500, 0, 30)
        l2.Position = UDim2.new(0.5, -250, 0, 50); l2.Text = "服务器ID: " .. game.JobId
        l2.Font = Enum.Font.Gotham; l2.TextSize = 14; l2.BackgroundTransparency = 1
        l2.TextColor3 = Color3.fromRGB(200, 200, 200); l2.Parent = sg
        local hue = 0
        RunService.RenderStepped:Connect(function(dt)
            hue = (hue + dt * 0.3) % 1; l.TextColor3 = Color3.fromHSV(hue, 1, 1)
        end)
    else
        local sg = PG:FindFirstChild("XixiSub")
        if sg then sg:Destroy() end
    end
end

function M14_Fun:Fling(name)
    local t = Players:FindFirstChild(name)
    local target = (t and t.Character and t.Character:FindFirstChild("HumanoidRootPart")) or getRoot()
    if target then target.Velocity = Vector3.new(0, 500, 0); sNotify("甩飞", name or "自己", 2) end
end

-- =====================================================================
-- MODULE 15 · 启动 / 卸载
-- =====================================================================
local M15_Boot = {}

function M15_Boot:Unload()
    M03_Fly:Stop()
    for k, _ in pairs(_toggleConns) do featCleanup(k) end
    M08_ESP:Toggle(false)
    M06_Music:Stop()
    pcall(function() LP.PlayerGui:FindFirstChild("XixiFPS"):Destroy() end)
    pcall(function() LP.PlayerGui:FindFirstChild("XixiSub"):Destroy() end)
    pcall(function() LP.PlayerGui:FindFirstChild("XixiHeart"):Destroy() end)
    pcall(function() LP.PlayerGui:FindFirstChild("XixiFallback"):Destroy() end)
    if M01_UI.Wind and M01_UI.Wind.Destroy then pcall(function() M01_UI.Wind:Destroy() end) end
    sNotify("卸载", "熙熙 Patriot 已关闭", 3)
end

function M15_Boot:Init()
    makeFPS()
    local exec = M02_Egg:CountExec()
    local count = #ScriptRegistry

    local Notice  = M01_UI:MakeTab("公告", "megaphone")
    local Main    = M01_UI:MakeTab("主要", "house")
    local Universal= M01_UI:MakeTab("通用", "wrench")
    local Combat  = M01_UI:MakeTab("战斗", "swords")
    local Fun     = M01_UI:MakeTab("整活", "party-popper")
    local Music   = M01_UI:MakeTab("音乐", "music")
    local Scripts = M01_UI:MakeTab("脚本列表", "file-code")
    local FavTab  = M01_UI:MakeTab("收藏", "star")
    local Env     = M01_UI:MakeTab("环境", "palette")
    local Info    = M01_UI:MakeTab("信息", "activity")
    local Server  = M01_UI:MakeTab("服务器", "server")
    local Settings= M01_UI:MakeTab("设置", "settings")

    M01_UI:Paragraph(Notice, "熙熙 · 爱国者版", "V2.1 模块化 · WindUI 单文件\n共 " .. count .. " 个外部脚本 | 已执行 " .. exec .. " 次")
    M01_UI:Paragraph(Notice, "玩家信息", "用户名: " .. LP.Name .. "\n显示名: " .. LP.DisplayName .. "\nID: " .. LP.UserId)
    M01_UI:Paragraph(Notice, "当前服务器", "JobId: " .. (game.JobId ~= "" and game.JobId or "未知") .. "\nPlaceId: " .. game.PlaceId)
    M01_UI:Button(Notice, "520爱心彩蛋", function() M02_Egg:Heart() end, "heart")
    M01_UI:Button(Notice, "鲸鱼彩蛋", function() M02_Egg:Whale() end, "fish")

    M01_UI:Section(Main, "实用功能")
    M01_UI:Toggle(Main, "防挂机(AntiAFK)", false, function(v) M04_Feat:Set("antiafk", v) end, "AntiAFK")
    M01_UI:Toggle(Main, "防本地踢", false, function(v) M04_Feat:Set("blockkick", v) end, "BlockKick")

    M01_UI:Section(Main, "传送")
    local names = M05_Player:GetNames()
    if #names == 0 then names = { "（暂无玩家）" } end
    M01_UI:Dropdown(Main, "选择玩家", names, names[1], function(v)
        if v and v ~= "（暂无玩家）" then M05_Player.selected = v end
    end)
    M01_UI:Button(Main, "传送到玩家", function()
        if M05_Player.selected and M05_Player.selected ~= "（暂无玩家）" then
            M05_Player:TPTo(M05_Player.selected)
        else sNotify("失败", "请先选择玩家", 3) end
    end, "navigation")
    M01_UI:Button(Main, "标记当前位置为家", function() M05_Player:SetHome() end, "map-pin")
    M01_UI:Button(Main, "回到家的位置", function() M05_Player:Home() end, "home")
    M01_UI:Button(Main, "复制选中玩家ID", function()
        if M05_Player.selected then M05_Player:CopyID(M05_Player.selected) else sNotify("失败", "未选择玩家", 3) end
    end, "copy")

    M01_UI:Section(Main, "服务器")
    M01_UI:Button(Main, "重进本服", function() M11_Server:Rejoin() end, "refresh-cw")
    M01_UI:Button(Main, "服务器跳跃", function() M11_Server:JumpServer() end, "globe")
    M01_UI:Button(Main, "去人少服", function() M11_Server:LeastPop() end, "users")
    M01_UI:Button(Main, "复制JobId", function() M11_Server:CopyID() end, "copy")

    M01_UI:Section(Universal, "移动")
    M01_UI:Slider(Universal, "飞行速度", 10, 300, 50, function(v) M03_Fly.Speed = v end, "FlySpeed")
    M01_UI:Slider(Universal, "移动速度", 16, 500, 16, function(v) local h = getHum(); if h then h.WalkSpeed = v end end, "WalkSpeed")
    M01_UI:Slider(Universal, "跳跃力", 50, 500, 50, function(v) local h = getHum(); if h then h.JumpPower = v end end, "JumpPower")
    M01_UI:Slider(Universal, "重力", 50, 500, 196, function(v) if v > 0 then workspace.Gravity = v end end, "Gravity")
    M01_UI:Slider(Universal, "广角FOV", 50, 120, 70, function(v) local cam = workspace.CurrentCamera; if cam then cam.FieldOfView = v end end, "FOV")
    M01_UI:Button(Universal, "飞行开关 (F)", function() M03_Fly:Toggle() end, "plane")
    M01_UI:Toggle(Universal, "无限跳跃", false, function(v) M04_Feat:Set("infjump", v) end, "InfJump")
    M01_UI:Toggle(Universal, "千倍速度", false, function(v) M04_Feat:Set("superspeed", v) end, "SuperSpeed")
    M01_UI:Toggle(Universal, "踏空", false, function(v) M04_Feat:Set("float", v) end, "Float")
    M01_UI:Toggle(Universal, "无敌模式", false, function(v) M04_Feat:Set("god", v) end, "God")
    M01_UI:Toggle(Universal, "穿墙模式", false, function(v) M04_Feat:Set("noclip", v) end, "Noclip")
    M01_UI:Toggle(Universal, "隐身模式", false, function(v) M04_Feat:Set("invisible", v) end, "Invisible")
    M01_UI:Toggle(Universal, "自动收集", false, function(v) M04_Feat:Set("collect", v) end, "Collect")
    M01_UI:Toggle(Universal, "点击传送", false, function(v) M04_Feat:Set("clicktp", v) end, "ClickTP")
    M01_UI:Toggle(Universal, "自动连点", false, function(v) M04_Feat:Set("autoclick", v) end, "AutoClick")
    M01_UI:Toggle(Universal, "全图点亮", false, function(v) M04_Feat:Set("fulllight", v) end, "FullLight")
    M01_UI:Toggle(Universal, "夜视功能", false, function(v) M04_Feat:Set("night", v) end, "Night")
    M01_UI:Toggle(Universal, "去雾功能", false, function(v) M04_Feat:Set("clearfog", v) end, "ClearFog")

    M01_UI:Section(Combat, "战斗辅助")
    M01_UI:Toggle(Combat, "玩家ESP", false, function(v) M08_ESP:Toggle(v) end, "ESP")
    M01_UI:Dropdown(Combat, "ESP颜色", { "红", "绿", "蓝" }, "红", function(v) M08_ESP:SetColor(v) end)
    M01_UI:Toggle(Combat, "团队高亮", false, function(v) M04_Feat:Set("teamglow", v) end, "TeamGlow")
    M01_UI:Toggle(Combat, "敌对高亮", false, function(v) M04_Feat:Set("enemyglow", v) end, "EnemyGlow")
    M01_UI:Toggle(Combat, "自动攻击", false, function(v) M04_Feat:Set("autoattack", v) end, "AutoAttack")
    M01_UI:Toggle(Combat, "一键自杀", false, function(v) M04_Feat:Set("suicide", v) end, "Suicide")

    M01_UI:Section(Fun, "角色特效")
    M01_UI:Button(Fun, "喷火模式", function() M14_Fun:Fire() end, "flame")
    M01_UI:Button(Fun, "光环模式", function() M14_Fun:Glow() end, "sparkles")
    M01_UI:Button(Fun, "大头模式", function() M14_Fun:BigHead() end, "circle")
    M01_UI:Button(Fun, "倒立行走", function() M14_Fun:UpsideDown() end, "rotate-cw")
    M01_UI:Button(Fun, "巨大化", function() M14_Fun:Giant() end, "maximize")
    M01_UI:Button(Fun, "彩虹拖尾", function() M14_Fun:Trail("rainbow") end, "rainbow")
    M01_UI:Button(Fun, "火焰拖尾", function() M14_Fun:Trail("fire") end, "flame")
    M01_UI:Button(Fun, "冰霜拖尾", function() M14_Fun:Trail("ice") end, "snowflake")
    M01_UI:Button(Fun, "彩虹名字", function() M14_Fun:RainbowName() end, "type")
    M01_UI:Toggle(Fun, "客户端字幕", false, function(v) M14_Fun:Subtitle(v) end, "subtitles")
    M01_UI:Input(Fun, "甩飞目标名", "玩家名", "", function(nm) M14_Fun:Fling(nm) end)

    M01_UI:Section(Music, "音乐播放")
    M01_UI:Button(Music, "⏹ 停止播放", function() M06_Music:Stop() end, "square")
    for i, m in ipairs(MusicList) do
        M01_UI:Button(Music, m.name, function() M06_Music:PlayByName(i) end, "music")
    end
    M01_UI:Input(Music, "自定义音频ID", "rbxassetid或数字", "", function(t) M06_Music:PlayFromText(t) end)

    M01_UI:Section(Scripts, "外部脚本加载")
    M01_UI:Paragraph(Scripts, "说明", "以下脚本点击才加载，不预载，降低内存。仅允许白名单域名。")
    local cats = {}
    for _, s in ipairs(ScriptRegistry) do
        if not cats[s.Cat] then cats[s.Cat] = true; M01_UI:Section(Scripts, s.Cat) end
        M01_UI:Button(Scripts, s.Name, function() M07_Scripts:LoadByName(s.Name, s.Url) end, "download")
    end
    M01_UI:Input(Scripts, "手动贴链接加载", "https://...", "", function(t) M07_Scripts:LoadFromText(t) end)

    M01_UI:Section(FavTab, "收藏夹")
    local favCount = 0
    for _, s in ipairs(ScriptRegistry) do
        if M12_Store.Fav[s.Name] then
            favCount = favCount + 1
            M01_UI:Button(FavTab, s.Name, function() M07_Scripts:LoadByName(s.Name, s.Url) end, "star")
        end
    end
    if favCount == 0 then M01_UI:Paragraph(FavTab, "暂无收藏", "去「设置」页添加") end

    M01_UI:Section(Env, "环境")
    M01_UI:Dropdown(Env, "切换天空盒", { "默认", "日落", "星空", "雪山", "赛博朋克", "深海" }, "默认", function(v) M09_Env:SetSky(v) end)
    M01_UI:Slider(Env, "时间(小时)", 0, 24, 14, function(v) M09_Env:SetTime(v) end, "Time")
    M01_UI:Toggle(Env, "关闭阴影", false, function(v) M09_Env:ToggleShadow(v) end, "Shadow")
    M01_UI:Toggle(Env, "关闭雾效", false, function(v) M09_Env:ToggleFog(v) end, "Fog")

    M10_Info:Start(Info)

    M01_UI:Section(Server, "服务器信息")
    M01_UI:Paragraph(Server, "PlaceId", tostring(game.PlaceId))
    M01_UI:Paragraph(Server, "JobId", game.JobId ~= "" and game.JobId or "未知")
    M01_UI:Paragraph(Server, "在线玩家", tostring(#Players:GetPlayers()) .. " 人")

    M01_UI:Section(Settings, "外观")
    M01_UI:Toggle(Settings, "显示FPS", true, function(v) M13_FPS:Toggle(v) end, "ShowFPS")
    M01_UI:Dropdown(Settings, "主题", { "Dark", "Light", "Rose", "Indigo", "Sky", "Violet", "Amber" }, "Dark", function(th)
        if M01_UI.Ready and WindUI.SetTheme then pcall(WindUI.SetTheme, WindUI, th) end
    end)
    M01_UI:Section(Settings, "配置保存")
    M01_UI:Button(Settings, "保存当前配置", function()
        M12_Store:SaveCfg({
            BlockKick = M04_Feat.BlockKick,
            AntiAFK = _toggleConns["antiafk"] ~= nil,
            WalkSpeed = (getHum() and getHum().WalkSpeed) or 16,
        })
    end, "save")
    M01_UI:Button(Settings, "重新加载上次脚本", function()
        local last = M07_Scripts.History[#M07_Scripts.History]
        if last then sNotify("重载", last.name, 2) else sNotify("失败", "无历史记录", 3) end
    end, "refresh-cw")
    M01_UI:Section(Settings, "收藏管理")
    M01_UI:Input(Settings, "脚本名称", "输入要收藏的脚本名", "", function(v) M12_Store._favInput = v end)
    M01_UI:Button(Settings, "添加收藏", function()
        if M12_Store._favInput then M12_Store:AddFav(M12_Store._favInput) end
    end, "plus")
    M01_UI:Button(Settings, "移除收藏", function()
        if M12_Store._favInput then M12_Store:DelFav(M12_Store._favInput) end
    end, "minus")
    M01_UI:Section(Settings, "执行历史")
    M01_UI:Button(Settings, "查看最近执行", function() M12_Store:ShowHist() end, "list")
    M01_UI:Button(Settings, "清空历史", function() M12_Store:ClearHist() end, "trash")
    M01_UI:Section(Settings, "脚本备注")
    M01_UI:Input(Settings, "脚本名", "", "", function(v) M12_Store._noteName = v end)
    M01_UI:Input(Settings, "备注内容", "", "", function(v) M12_Store._noteText = v end)
    M01_UI:Button(Settings, "保存备注", function()
        if M12_Store._noteName then M12_Store:SetNote(M12_Store._noteName, M12_Store._noteText or "") end
    end, "save")
    M01_UI:Button(Settings, "查看备注", function()
        if M12_Store._noteName then M12_Store:GetNote(M12_Store._noteName) end
    end, "eye")
    M01_UI:Section(Settings, "危险操作")
    M01_UI:Button(Settings, "卸载脚本", function() M15_Boot:Unload() end, "power")

    UIS.InputBegan:Connect(function(i, g)
        if g then return end
        if i.KeyCode == Enum.KeyCode.F then M03_Fly:Toggle() end
    end)

    task.spawn(function()
        M02_Egg:Intro()
        task.wait(1)
        M02_Egg:Heart()
        task.wait(0.5)
        M02_Egg:Whale()
    end)

    if M01_UI.Ready then
        pcall(function() M01_UI.Wind.ConfigManager:Config("default"):Load() end)
        WindUI:Notify({ Title = "熙熙 Patriot", Content = "V2.1 模块化 WindUI 加载完成\nF键开关飞行 / 开关UI\n共 " .. count .. " 个外部脚本", Icon = "star", Duration = 6 })
    else
        sNotify("降级模式", "WindUI 未加载，已用原生按钮保底", 5)
    end
end

M15_Boot:Init()

-- =====================================================================
-- 全部拼接完成
-- 熙熙 · 爱国者版 V2.1 模块化 · WindUI 单文件
-- 16 模块：全局/UI/彩蛋/飞行/功能/玩家/音乐/脚本/ESP/环境/信息/服务器/存储/FPS/整活/启动
-- =====================================================================
print("[熙熙 Patriot] V2.1 模块化 WindUI 已加载")
