-- ============ 执行前等待 2 秒 ============
task.wait(2)

-- ============ 加载 LUMEN UI ============
loadstring(game:HttpGet("loadstring(game:HttpGet("https://raw.githubusercontent.com/cheng2026-tech/-Ioo/main/ui.lua"))()"))()
local ui = _G.ui
if type(ui) ~= "table" then warn("[大肥鱼脚本] LUMEN UI 加载失败") return end

-- ============ 服务 ============
local Players = game:GetService("Players")
local PlayerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")

-- ============ 全局执行计数 ============
local function getGlobalExecCount()
    if getgenv and getgenv().GlobalExecCount then return getgenv().GlobalExecCount end
    local success, result = pcall(function()
        if syn and syn.crypt and syn.crypt.custom then
            local data = syn.crypt.custom("read", "black_script_exec_count.txt")
            if data then return tonumber(data) or 0 end
        end
        return 0
    end)
    if success and result and result > 0 then return result end
    success, result = pcall(function()
        if readfile then
            local data = readfile("black_script_exec_count.txt")
            if data then return tonumber(data) or 0 end
        end
        return 0
    end)
    if success and result and result > 0 then return result end
    return 0
end
local function saveGlobalExecCount(count)
    if getgenv then getgenv().GlobalExecCount = count end
    pcall(function()
        if syn and syn.crypt and syn.crypt.custom then
            syn.crypt.custom("write", "black_script_exec_count.txt", tostring(count))
        end
    end)
    pcall(function()
        if writefile then writefile("black_script_exec_count.txt", tostring(count)) end
    end)
end
local globalExecCount = getGlobalExecCount()
if globalExecCount == 0 then globalExecCount = 1 else globalExecCount = globalExecCount + 1 end
saveGlobalExecCount(globalExecCount)

-- ============ 520 心形特效 ============
if globalExecCount == 520 then
    spawn(function()
        local heartGui = Instance.new("ScreenGui")
        heartGui.Name = "HeartEffectGui"; heartGui.ResetOnSpawn = false; heartGui.Parent = PlayerGui
        local overlay = Instance.new("Frame")
        overlay.Size = UDim2.new(1, 0, 1, 0); overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
        overlay.BackgroundTransparency = 0.5; overlay.ZIndex = 999; overlay.Parent = heartGui
        local heartLabel = Instance.new("TextLabel")
        heartLabel.Size = UDim2.new(0, 200, 0, 200); heartLabel.Position = UDim2.new(0.5, -100, 0.5, -100)
        heartLabel.Text = "❤️"; heartLabel.Font = Enum.Font.GothamBold
        heartLabel.TextSize = 150; heartLabel.BackgroundTransparency = 1
        heartLabel.ZIndex = 1000; heartLabel.Parent = heartGui
        local heartHue = 0
        local heartConn = RunService.RenderStepped:Connect(function(delta)
            heartHue = (heartHue + delta * 0.5) % 1
            heartLabel.TextColor3 = Color3.fromHSV(heartHue, 1, 1)
        end)
        heartLabel.Size = UDim2.new(0, 0, 0, 0)
        TweenService:Create(heartLabel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0, 200, 0, 200)}):Play()
        wait(3)
        local msgLabel = Instance.new("TextLabel")
        msgLabel.Size = UDim2.new(0, 400, 0, 60); msgLabel.Position = UDim2.new(0.5, -200, 0.5, 120)
        msgLabel.Text = "您已执行 520 次，感谢您的支持！❤️"
        msgLabel.Font = Enum.Font.GothamBold; msgLabel.TextSize = 24
        msgLabel.BackgroundTransparency = 1; msgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        msgLabel.TextStrokeTransparency = 0; msgLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
        msgLabel.ZIndex = 1000; msgLabel.Parent = heartGui
        local msgHue = 0
        local msgConn = RunService.RenderStepped:Connect(function(delta)
            msgHue = (msgHue + delta * 0.3) % 1
            msgLabel.TextColor3 = Color3.fromHSV(msgHue, 1, 1)
        end)
        wait(2)
        heartConn:Disconnect(); msgConn:Disconnect()
        TweenService:Create(heartLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0, 0, 0, 0)}):Play()
        TweenService:Create(msgLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1}):Play()
        TweenService:Create(overlay, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
        wait(0.5); heartGui:Destroy()
    end)
end

-- ============ 欢迎音效 ============
spawn(function()
    local sound = Instance.new("Sound")
    sound.SoundId = "rbxassetid://80701295792893"; sound.Volume = 1
    sound.Parent = workspace; sound:Play()
    sound.Ended:Connect(function() sound:Destroy() end)
end)

-- ============ 欢迎动画 ============
spawn(function()
    local welcomeGui = Instance.new("ScreenGui")
    welcomeGui.Name = "WelcomeGui"; welcomeGui.ResetOnSpawn = false; welcomeGui.Parent = PlayerGui
    local welcomeLabel = Instance.new("TextLabel")
    welcomeLabel.Size = UDim2.new(0, 500, 0, 80); welcomeLabel.Position = UDim2.new(0.5, -250, 0.5, -40)
    welcomeLabel.Text = "欢迎使用大肥鱼脚本·管理员版"
    welcomeLabel.Font = Enum.Font.GothamBold; welcomeLabel.TextSize = 36
    welcomeLabel.BackgroundTransparency = 1
    welcomeLabel.TextStrokeTransparency = 0; welcomeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    welcomeLabel.ZIndex = 1000; welcomeLabel.Parent = welcomeGui
    local hue2 = 0
    local colorConnection
    colorConnection = RunService.RenderStepped:Connect(function(delta)
        hue2 = (hue2 + delta * 0.5) % 1
        welcomeLabel.TextColor3 = Color3.fromHSV(hue2, 1, 1)
    end)
    wait(3)
    colorConnection:Disconnect()
    TweenService:Create(welcomeLabel, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
    wait(0.8); welcomeGui:Destroy()
    local infoGui = Instance.new("ScreenGui")
    infoGui.Name = "InfoGui"; infoGui.ResetOnSpawn = false; infoGui.Parent = PlayerGui
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Size = UDim2.new(0, 400, 0, 60); infoLabel.Position = UDim2.new(0.5, -200, 0.5, -30)
    infoLabel.Text = "此脚本会一直更新\n此脚本作者:大肥鱼"
    infoLabel.Font = Enum.Font.GothamBold; infoLabel.TextSize = 22
    infoLabel.BackgroundTransparency = 1; infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    infoLabel.TextStrokeTransparency = 0; infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    infoLabel.ZIndex = 1000; infoLabel.Parent = infoGui
    wait(2)
    TweenService:Create(infoLabel, TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
    wait(0.6); infoGui:Destroy()
end)

-- ============ FPS ============
local fpsGui = Instance.new("ScreenGui")
fpsGui.Name = "FPSGui"; fpsGui.ResetOnSpawn = false; fpsGui.Parent = PlayerGui
local FPSLabel = Instance.new("TextLabel")
FPSLabel.Size = UDim2.new(0, 180, 0, 28); FPSLabel.Position = UDim2.new(0, 8, 0, 8)
FPSLabel.BackgroundTransparency = 1; FPSLabel.Font = Enum.Font.GothamBold
FPSLabel.TextSize = 16; FPSLabel.TextXAlignment = Enum.TextXAlignment.Left
FPSLabel.ZIndex = 100; FPSLabel.Visible = true; FPSLabel.RichText = true
FPSLabel.Parent = fpsGui
local fpsEnabled = true
local lastFrameTime = tick()
local frameCount = 0
local currentFPS = 0
RunService.RenderStepped:Connect(function()
    if fpsEnabled then
        frameCount = frameCount + 1
        local e = tick() - lastFrameTime
        if e >= 0.5 then
            currentFPS = math.floor(frameCount / e)
            frameCount = 0; lastFrameTime = tick()
            local c = currentFPS >= 30 and "255,0,0" or "255,255,0"
            FPSLabel.Text = '<font color="rgb(255,255,255)">FPS: </font><font color="rgb(' .. c .. ')">' .. currentFPS .. '</font>'
        end
    end
end)

-- ============ 状态 ============
local espHighlights = {}
local espBillboards = {}
local teamGlowHighlights = {}
local enemyGlowHighlights = {}
local infJumpEnabled = false
local spinConnection = nil
local followConnection = nil
local followActive = false
local homePosition = nil
local authorEspEnabled = true
local _toggleConns = {}

-- ============ ESP ============
local function clearESP()
    for _, h in pairs(espHighlights) do pcall(function() h:Destroy() end) end
    for _, b in pairs(espBillboards) do pcall(function() b:Destroy() end) end
    espHighlights = {}; espBillboards = {}
end
local function clearTeamGlow()
    for _, h in pairs(teamGlowHighlights) do pcall(function() h:Destroy() end) end
    teamGlowHighlights = {}
end
local function clearEnemyGlow()
    for _, h in pairs(enemyGlowHighlights) do pcall(function() h:Destroy() end) end
    enemyGlowHighlights = {}
end
local function addAuthorESP(p)
    if not authorEspEnabled then return end
    if p.Name ~= "CHANGCHENG66" then return end
    if espHighlights[p] then pcall(function() espHighlights[p]:Destroy() end) end
    if espBillboards[p] then pcall(function() espBillboards[p]:Destroy() end) end
    local function s(c)
        if not c then return end
        local hl = Instance.new("Highlight")
        hl.FillColor = Color3.fromRGB(255, 215, 0); hl.FillTransparency = 0.3
        hl.OutlineColor = Color3.fromRGB(255, 215, 0); hl.OutlineTransparency = 0
        hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        hl.Adornee = c; hl.Parent = c
        espHighlights[p] = hl
        local h = c:FindFirstChild("Head")
        if h then
            local bb = Instance.new("BillboardGui")
            bb.Size = UDim2.new(0, 200, 0, 40); bb.StudsOffset = Vector3.new(0, 3.5, 0)
            bb.AlwaysOnTop = true; bb.Parent = h
            local nl = Instance.new("TextLabel")
            nl.Size = UDim2.new(1, 0, 1, 0); nl.BackgroundTransparency = 1
            nl.Text = "👑 " .. p.Name .. " · 此脚本作者"
            nl.TextColor3 = Color3.fromRGB(255, 215, 0); nl.Font = Enum.Font.GothamBold
            nl.TextSize = 16; nl.TextStrokeTransparency = 0
            nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); nl.Parent = bb
            espBillboards[p] = bb
        end
    end
    if p.Character then s(p.Character) end
    p.CharacterAdded:Connect(function(c) if authorEspEnabled then s(c) end end)
end
local function refreshAuthorESP()
    clearESP()
    if authorEspEnabled then
        for _, p in ipairs(Players:GetPlayers()) do addAuthorESP(p) end
    end
end
local function enableAuthorESP() authorEspEnabled = true; refreshAuthorESP() end
local function disableAuthorESP() authorEspEnabled = false; clearESP() end
for _, p in ipairs(Players:GetPlayers()) do addAuthorESP(p) end
Players.PlayerAdded:Connect(function(p) if authorEspEnabled then addAuthorESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if espHighlights[p] then pcall(function() espHighlights[p]:Destroy() end); espHighlights[p] = nil end
    if espBillboards[p] then pcall(function() espBillboards[p]:Destroy() end); espBillboards[p] = nil end
end)

spawn(function()
    wait(3)
    local c = Players.LocalPlayer.Character
    if c and c:FindFirstChild("HumanoidRootPart") then
        homePosition = c.HumanoidRootPart.CFrame
    end
end)

-- ============ toggle 处理 ============
local function handleFeatureToggle(runCode, enabled)
    if enabled then
        if runCode == "esp" then enableAuthorESP()
        elseif runCode == "night" then
            Lighting.Brightness = 2; Lighting.ClockTime = 14
            Lighting.FogEnd = 100000; Lighting.GlobalShadows = false
        elseif runCode == "fps" then fpsEnabled = true; FPSLabel.Visible = true
        elseif runCode == "float" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart; local floatY = hrp.Position.Y
                _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                    if hrp and hrp.Parent then
                        hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
                        hrp.CFrame = CFrame.new(hrp.Position.X, floatY, hrp.Position.Z)
                    end
                end)
            end
        elseif runCode == "antiafk" then
            local vu = game:GetService("VirtualUser")
            Players.LocalPlayer.Idled:Connect(function()
                vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                wait(1)
                vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
            end)
        elseif runCode == "collect" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                    for _, item in ipairs(workspace:GetDescendants()) do
                        if item:IsA("Tool") or item:IsA("MeshPart") or (item:IsA("Part") and (item.Name:lower():find("drop") or item.Name:lower():find("coin") or item.Name:lower():find("gem") or item.Name:lower():find("collect") or item.Name:lower():find("orb"))) then
                            if (item.Position - hrp.Position).Magnitude < 80 then
                                item.CFrame = hrp.CFrame + Vector3.new(math.random(-3,3), 0, math.random(-3,3))
                            end
                        end
                    end
                end)
            end
        elseif runCode == "clicktp" then
            local mouse = Players.LocalPlayer:GetMouse()
            _toggleConns[runCode] = mouse.Button1Down:Connect(function()
                local c = Players.LocalPlayer.Character
                if c and c:FindFirstChild("HumanoidRootPart") and mouse.Hit then
                    c.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
                end
            end)
        elseif runCode == "autoclick" then
            local vu = game:GetService("VirtualUser"); local camera = workspace.CurrentCamera
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                local s = camera.ViewportSize
                vu:Button1Down(Vector2.new(s.X/2, s.Y/2))
                wait(0.05)
                vu:Button1Up(Vector2.new(s.X/2, s.Y/2))
            end)
        elseif runCode == "speedhack" then
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                for _, v in ipairs(workspace:GetDescendants()) do
                    if v:IsA("Animation") then v.Speed = 2 end
                end
            end)
        elseif runCode == "itemesp" then
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                for _, item in ipairs(workspace:GetDescendants()) do
                    if (item:IsA("Tool") or item.Name:find("Drop")) and not item:FindFirstChild("ItemESP") then
                        local hl = Instance.new("Highlight"); hl.Name = "ItemESP"
                        hl.FillColor = Color3.fromRGB(0, 255, 0); hl.OutlineColor = Color3.fromRGB(255, 255, 0); hl.Parent = item
                    end
                end
            end)
        elseif runCode == "invisible" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0.8 end
            end end
        elseif runCode == "noclip" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end end
        elseif runCode == "god" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                c.Humanoid.MaxHealth = 99999; c.Humanoid.Health = 99999
                _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                    if c and c:FindFirstChild("Humanoid") then c.Humanoid.Health = 99999 end
                end)
            end
        elseif runCode == "teamglow" then
            local myTeam = Players.LocalPlayer.Team
            clearTeamGlow()
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Players.LocalPlayer and p.Character and p.Team == myTeam then
                        if not teamGlowHighlights[p] then
                            local hl = Instance.new("Highlight"); hl.Name = "TeamGlow"
                            hl.FillColor = Color3.fromRGB(0, 100, 255); hl.OutlineColor = Color3.fromRGB(0, 150, 255)
                            hl.FillTransparency = 0.5; hl.Parent = p.Character
                            teamGlowHighlights[p] = hl
                        end
                    end
                end
            end)
        elseif runCode == "enemyglow" then
            local myTeam = Players.LocalPlayer.Team
            clearEnemyGlow()
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Players.LocalPlayer and p.Character and p.Team ~= myTeam then
                        if not enemyGlowHighlights[p] then
                            local hl = Instance.new("Highlight"); hl.Name = "EnemyGlow"
                            hl.FillColor = Color3.fromRGB(255, 0, 0); hl.OutlineColor = Color3.fromRGB(255, 50, 50)
                            hl.FillTransparency = 0.5; hl.Parent = p.Character
                            enemyGlowHighlights[p] = hl
                        end
                    end
                end
            end)
        elseif runCode == "autoattack" then
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                local c = Players.LocalPlayer.Character; if not c then return end
                local nearest = nil; local minDist = 15; local myTeam = Players.LocalPlayer.Team
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Team ~= myTeam and p.Character.Humanoid.Health > 0 then
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
        elseif runCode == "fulllight" then
            Lighting.Brightness = 5; Lighting.ClockTime = 14; Lighting.FogEnd = 100000
            Lighting.GlobalShadows = false; Lighting.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
        elseif runCode == "suicide" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.Health = 0 end
        elseif runCode == "superspeed" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 1000 end
        elseif runCode == "infstamina" then
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                local c = Players.LocalPlayer.Character
                if c and c:FindFirstChild("Humanoid") then c.Humanoid.MaxHealth = c.Humanoid.MaxHealth end
            end)
        elseif runCode == "infammo" then
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function()
                local c = Players.LocalPlayer.Character
                if c then
                    for _, tool in ipairs(c:GetChildren()) do
                        if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then tool.Ammo.Value = 999 end
                    end
                end
            end)
        elseif runCode == "serverinfo" then
            local infoActive = true
            local infoGui = Instance.new("ScreenGui")
            infoGui.Name = "ServerInfoGui"; infoGui.ResetOnSpawn = false; infoGui.Parent = PlayerGui
            local infoFrame = Instance.new("Frame")
            infoFrame.Size = UDim2.new(0, 280, 0, 180); infoFrame.Position = UDim2.new(1, -290, 0, 10)
            infoFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30); infoFrame.BackgroundTransparency = 0.2
            infoFrame.BorderSizePixel = 0; infoFrame.ZIndex = 500; infoFrame.Parent = infoGui
            local infoCorner = Instance.new("UICorner"); infoCorner.CornerRadius = UDim.new(0, 8); infoCorner.Parent = infoFrame
            local playerCountLabel = Instance.new("TextLabel")
            playerCountLabel.Size = UDim2.new(1, -16, 0, 30); playerCountLabel.Position = UDim2.new(0, 8, 0, 8)
            playerCountLabel.Text = "服务器人数: " .. #Players:GetPlayers()
            playerCountLabel.Font = Enum.Font.GothamBold; playerCountLabel.TextSize = 14
            playerCountLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            playerCountLabel.BackgroundTransparency = 1
            playerCountLabel.TextXAlignment = Enum.TextXAlignment.Left
            playerCountLabel.ZIndex = 501; playerCountLabel.Parent = infoFrame
            local coordLabel = Instance.new("TextLabel")
            coordLabel.Size = UDim2.new(1, -16, 0, 30); coordLabel.Position = UDim2.new(0, 8, 0, 40)
            coordLabel.Font = Enum.Font.Gotham; coordLabel.TextSize = 12
            coordLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            coordLabel.BackgroundTransparency = 1
            coordLabel.TextXAlignment = Enum.TextXAlignment.Left
            coordLabel.ZIndex = 501; coordLabel.Parent = infoFrame
            local nearestLabel = Instance.new("TextLabel")
            nearestLabel.Size = UDim2.new(1, -16, 0, 90); nearestLabel.Position = UDim2.new(0, 8, 0, 72)
            nearestLabel.Font = Enum.Font.Gotham; nearestLabel.TextSize = 11
            nearestLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            nearestLabel.BackgroundTransparency = 1
            nearestLabel.TextXAlignment = Enum.TextXAlignment.Left
            nearestLabel.TextYAlignment = Enum.TextYAlignment.Top
            nearestLabel.ZIndex = 501; nearestLabel.Parent = infoFrame
            local renderConn = RunService.RenderStepped:Connect(function()
                if not infoActive then return end
                playerCountLabel.Text = "服务器人数: " .. #Players:GetPlayers()
                local c = Players.LocalPlayer.Character
                if c and c:FindFirstChild("HumanoidRootPart") then
                    local pos = c.HumanoidRootPart.Position
                    coordLabel.Text = "坐标: X:" .. math.floor(pos.X) .. " Y:" .. math.floor(pos.Y) .. " Z:" .. math.floor(pos.Z)
                end
                local nearestText = "附近玩家:\n"
                local myPos = c and c:FindFirstChild("HumanoidRootPart") and c.HumanoidRootPart.Position
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and myPos then
                        local dist = math.floor((p.Character.HumanoidRootPart.Position - myPos).Magnitude)
                        nearestText = nearestText .. "  " .. p.Name .. " - " .. dist .. "m\n"
                    end
                end
                nearestLabel.Text = nearestText
            end)
            _toggleConns[runCode] = {Disconnect = function()
                infoActive = false
                if infoGui then infoGui:Destroy() end
                if renderConn then renderConn:Disconnect() end
            end}
        elseif runCode == "dance1" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                local anim = Instance.new("Animation"); anim.AnimationId = "rbxassetid://5918726674"
                local track = c.Humanoid:LoadAnimation(anim); track:Play()
                _toggleConns[runCode] = {Disconnect = function() if track then track:Stop() end end}
            end
        elseif runCode == "fire" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local fire = Instance.new("ParticleEmitter"); fire.Name = "FireFX"
                fire.Texture = "rbxassetid://0"
                fire.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
                fire.Rate = 30; fire.Speed = NumberRange.new(3, 6)
                fire.Lifetime = NumberRange.new(0.5, 1); fire.Parent = c.HumanoidRootPart
            end
        elseif runCode == "glow" then
            local c = Players.LocalPlayer.Character
            if c then
                local hl = Instance.new("Highlight"); hl.Name = "PlayerGlow"
                hl.FillColor = Color3.fromRGB(255, 255, 0); hl.OutlineColor = Color3.fromRGB(255, 200, 0)
                hl.FillTransparency = 0.3; hl.Parent = c
            end
        elseif runCode == "upsidedown" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(180))
            end
        elseif runCode == "bighead" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Head") then c.Head.Size = Vector3.new(4, 4, 4) end
        elseif runCode == "screenfx" then
            local fx = Instance.new("ColorCorrectionEffect"); fx.Name = "ScreenFX"
            fx.TintColor = Color3.fromRGB(255, 100, 200); fx.Parent = Lighting
        elseif runCode == "trail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = Instance.new("Trail"); trail.Name = "PlayerTrail"
                local a0 = Instance.new("Attachment"); a0.Name = "TrailAttachment0"; a0.Parent = hrp
                local a1 = Instance.new("Attachment"); a1.Name = "TrailAttachment1"; a1.Parent = hrp
                a1.Position = Vector3.new(0, -2, 0)
                trail.Attachment0 = a0; trail.Attachment1 = a1
                trail.Color = ColorSequence.new(Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255))
                trail.Lifetime = 0.5; trail.MinLength = 0.1; trail.Parent = hrp
            end
        elseif runCode == "firetrail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = Instance.new("Trail"); trail.Name = "FireTrail"
                local a0 = Instance.new("Attachment"); a0.Name = "FireTrailA0"; a0.Parent = hrp
                local a1 = Instance.new("Attachment"); a1.Name = "FireTrailA1"; a1.Parent = hrp
                a1.Position = Vector3.new(0, -2, 0)
                trail.Attachment0 = a0; trail.Attachment1 = a1
                trail.Color = ColorSequence.new(Color3.fromRGB(255, 50, 0), Color3.fromRGB(255, 150, 0), Color3.fromRGB(255, 255, 0))
                trail.Lifetime = 0.3; trail.MinLength = 0.05; trail.Parent = hrp
            end
        elseif runCode == "iceTrail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = Instance.new("Trail"); trail.Name = "IceTrail"
                local a0 = Instance.new("Attachment"); a0.Name = "IceTrailA0"; a0.Parent = hrp
                local a1 = Instance.new("Attachment"); a1.Name = "IceTrailA1"; a1.Parent = hrp
                a1.Position = Vector3.new(0, -2, 0)
                trail.Attachment0 = a0; trail.Attachment1 = a1
                trail.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255), Color3.fromRGB(150, 220, 255), Color3.fromRGB(200, 240, 255))
                trail.Lifetime = 0.4; trail.MinLength = 0.08; trail.Parent = hrp
            end
        elseif runCode == "clearfog" then
            Lighting.FogEnd = 100000; Lighting.FogStart = 50000
        elseif runCode == "subtitle" then
            local subActive = true
            local subGui = Instance.new("ScreenGui")
            subGui.Name = "SubtitleGui"; subGui.ResetOnSpawn = false; subGui.Parent = PlayerGui
            local subLabel = Instance.new("TextLabel")
            subLabel.Size = UDim2.new(0, 500, 0, 80); subLabel.Position = UDim2.new(0.5, -250, 0, 10)
            subLabel.Text = Players.LocalPlayer.Name .. " 已入侵服务器"
            subLabel.Font = Enum.Font.GothamBold; subLabel.TextSize = 24
            subLabel.BackgroundTransparency = 1
            subLabel.TextStrokeTransparency = 0; subLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            subLabel.ZIndex = 500; subLabel.Parent = subGui
            local serverLabel = Instance.new("TextLabel")
            serverLabel.Size = UDim2.new(0, 500, 0, 40); serverLabel.Position = UDim2.new(0.5, -250, 0, 80)
            serverLabel.Text = "服务器ID: " .. game.JobId
            serverLabel.Font = Enum.Font.Gotham; serverLabel.TextSize = 16
            serverLabel.BackgroundTransparency = 1
            serverLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            serverLabel.TextStrokeTransparency = 0; serverLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            serverLabel.ZIndex = 500; serverLabel.Parent = subGui
            local timeLabel = Instance.new("TextLabel")
            timeLabel.Size = UDim2.new(0, 500, 0, 30); timeLabel.Position = UDim2.new(0.5, -250, 0, 115)
            timeLabel.Font = Enum.Font.Gotham; timeLabel.TextSize = 14
            timeLabel.BackgroundTransparency = 1
            timeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
            timeLabel.TextStrokeTransparency = 0; timeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
            timeLabel.ZIndex = 500; timeLabel.Parent = subGui
            local subHue = 0
            local renderConn = RunService.RenderStepped:Connect(function(delta)
                if not subActive then return end
                subHue = (subHue + delta * 0.3) % 1
                subLabel.TextColor3 = Color3.fromHSV(subHue, 1, 1)
                local now = os.date("*t")
                timeLabel.Text = now.year .. "年" .. now.month .. "月" .. now.day .. "日 " .. string.format("%02d:%02d:%02d", now.hour, now.min, now.sec)
            end)
            _toggleConns[runCode] = {Disconnect = function()
                subActive = false
                if subGui then subGui:Destroy() end
                if renderConn then renderConn:Disconnect() end
            end}
        elseif runCode == "rainbowname" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Head") then
                local bb = c.Head:FindFirstChild("BillboardGui")
                if not bb then
                    bb = Instance.new("BillboardGui"); bb.Size = UDim2.new(0, 150, 0, 30)
                    bb.StudsOffset = Vector3.new(0, 3, 0); bb.AlwaysOnTop = true; bb.Parent = c.Head
                    local nl = Instance.new("TextLabel"); nl.Size = UDim2.new(1, 0, 1, 0); nl.BackgroundTransparency = 1
                    nl.Text = Players.LocalPlayer.DisplayName .. " 👑管理员"
                    nl.Font = Enum.Font.GothamBold; nl.TextSize = 14; nl.Name = "RainbowName"
                    nl.TextStrokeTransparency = 0; nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0); nl.Parent = bb
                end
            end
            local hue2 = 0
            _toggleConns[runCode] = RunService.RenderStepped:Connect(function(delta)
                hue2 = (hue2 + delta * 0.5) % 1
                local c2 = Players.LocalPlayer.Character
                if c2 and c2:FindFirstChild("Head") then
                    local bb2 = c2.Head:FindFirstChild("BillboardGui")
                    if bb2 then
                        local nl2 = bb2:FindFirstChild("RainbowName")
                        if nl2 then nl2.TextColor3 = Color3.fromHSV(hue2, 1, 1) end
                    end
                end
            end)
        elseif runCode == "giant" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Size = v.Size * 3 end
            end end
        elseif runCode == "deletepart" then
            local mouse = Players.LocalPlayer:GetMouse(); local curGui = nil; local curHl = nil
            _toggleConns[runCode] = mouse.Button1Down:Connect(function()
                local t = mouse.Target
                if t then
                    if curGui then curGui:Destroy() end; if curHl then curHl:Destroy() end
                    curHl = Instance.new("Highlight"); curHl.FillColor = Color3.fromRGB(255, 0, 0)
                    curHl.FillTransparency = 0.5; curHl.OutlineColor = Color3.fromRGB(255, 0, 0)
                    curHl.Adornee = t; curHl.Parent = t
                    local cg = Instance.new("ScreenGui"); cg.Parent = PlayerGui; curGui = cg
                    local frame = Instance.new("Frame"); frame.Size = UDim2.new(0, 280, 0, 130)
                    frame.Position = UDim2.new(0.5, -140, 0.5, -65)
                    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40); frame.BorderSizePixel = 0
                    frame.ZIndex = 99; frame.Parent = cg
                    local frameCorner = Instance.new("UICorner"); frameCorner.CornerRadius = UDim.new(0, 10); frameCorner.Parent = frame
                    local text = Instance.new("TextLabel"); text.Size = UDim2.new(1, 0, 0, 45); text.Text = "确定删除此建模吗？"
                    text.TextColor3 = Color3.fromRGB(255, 255, 255); text.Font = Enum.Font.GothamBold
                    text.TextSize = 15; text.BackgroundTransparency = 1; text.ZIndex = 100; text.Parent = frame
                    local confirmBtn = Instance.new("TextButton"); confirmBtn.Size = UDim2.new(0, 110, 0, 34)
                    confirmBtn.Position = UDim2.new(0, 18, 0, 75); confirmBtn.Text = "确定删除"
                    confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255); confirmBtn.Font = Enum.Font.GothamBold
                    confirmBtn.TextSize = 13; confirmBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
                    confirmBtn.BorderSizePixel = 0; confirmBtn.ZIndex = 100
                    confirmBtn.AutoButtonColor = false; confirmBtn.Parent = frame
                    local cc = Instance.new("UICorner"); cc.CornerRadius = UDim.new(0, 6); cc.Parent = confirmBtn
                    confirmBtn.MouseButton1Click:Connect(function()
                        if curHl then curHl:Destroy() end; t:Destroy(); cg:Destroy()
                    end)
                    local cancelBtn = Instance.new("TextButton"); cancelBtn.Size = UDim2.new(0, 110, 0, 34)
                    cancelBtn.Position = UDim2.new(0, 152, 0, 75); cancelBtn.Text = "取消"
                    cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255); cancelBtn.Font = Enum.Font.GothamBold
                    cancelBtn.TextSize = 13; cancelBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
                    cancelBtn.BorderSizePixel = 0; cancelBtn.ZIndex = 100
                    cancelBtn.AutoButtonColor = false; cancelBtn.Parent = frame
                    local canc = Instance.new("UICorner"); canc.CornerRadius = UDim.new(0, 6); canc.Parent = cancelBtn
                    cancelBtn.MouseButton1Click:Connect(function()
                        if curHl then curHl:Destroy() end; cg:Destroy()
                    end)
                end
            end)
        elseif runCode == "infjump" then
            infJumpEnabled = true
            _toggleConns[runCode] = UserInputService.JumpRequest:Connect(function()
                if infJumpEnabled then
                    local c = Players.LocalPlayer.Character
                    if c and c:FindFirstChild("Humanoid") then
                        c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
                    end
                end
            end)
        end
    else
        if runCode == "esp" then disableAuthorESP()
        elseif runCode == "night" then Lighting.Brightness = 1; Lighting.GlobalShadows = true
        elseif runCode == "fps" then fpsEnabled = false; FPSLabel.Visible = false
        elseif runCode == "invisible" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Transparency = 0 end
            end end
        elseif runCode == "noclip" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.CanCollide = true end
            end end
        elseif runCode == "fulllight" then
            Lighting.Brightness = 1; Lighting.GlobalShadows = true
        elseif runCode == "superspeed" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = 16 end
        elseif runCode == "serverinfo" then
            local infoGui = PlayerGui:FindFirstChild("ServerInfoGui")
            if infoGui then infoGui:Destroy() end
        elseif runCode == "dance1" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Humanoid") then
                for _, t in ipairs(c.Humanoid:GetPlayingAnimationTracks()) do t:Stop() end
            end
        elseif runCode == "fire" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                for _, v in ipairs(c.HumanoidRootPart:GetChildren()) do
                    if v:IsA("ParticleEmitter") and v.Name == "FireFX" then v:Destroy() end
                end
            end
        elseif runCode == "glow" then
            local c = Players.LocalPlayer.Character
            if c then
                local hl = c:FindFirstChild("PlayerGlow"); if hl then hl:Destroy() end
            end
        elseif runCode == "upsidedown" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                c.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(180))
            end
        elseif runCode == "bighead" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Head") then c.Head.Size = Vector3.new(2, 1, 1) end
        elseif runCode == "screenfx" then
            local fx = Lighting:FindFirstChild("ScreenFX"); if fx then fx:Destroy() end
        elseif runCode == "trail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = hrp:FindFirstChild("PlayerTrail"); if trail then trail:Destroy() end
                local a0 = hrp:FindFirstChild("TrailAttachment0"); if a0 then a0:Destroy() end
                local a1 = hrp:FindFirstChild("TrailAttachment1"); if a1 then a1:Destroy() end
            end
        elseif runCode == "firetrail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = hrp:FindFirstChild("FireTrail"); if trail then trail:Destroy() end
                local a0 = hrp:FindFirstChild("FireTrailA0"); if a0 then a0:Destroy() end
                local a1 = hrp:FindFirstChild("FireTrailA1"); if a1 then a1:Destroy() end
            end
        elseif runCode == "iceTrail" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("HumanoidRootPart") then
                local hrp = c.HumanoidRootPart
                local trail = hrp:FindFirstChild("IceTrail"); if trail then trail:Destroy() end
                local a0 = hrp:FindFirstChild("IceTrailA0"); if a0 then a0:Destroy() end
                local a1 = hrp:FindFirstChild("IceTrailA1"); if a1 then a1:Destroy() end
            end
        elseif runCode == "clearfog" then
            Lighting.FogEnd = 1000; Lighting.FogStart = 0
        elseif runCode == "subtitle" then
            local subGui = PlayerGui:FindFirstChild("SubtitleGui")
            if subGui then subGui:Destroy() end
        elseif runCode == "rainbowname" then
            local c = Players.LocalPlayer.Character
            if c and c:FindFirstChild("Head") then
                local bb = c.Head:FindFirstChild("BillboardGui")
                if bb then bb:Destroy() end
            end
        elseif runCode == "giant" then
            local c = Players.LocalPlayer.Character
            if c then for _, v in ipairs(c:GetDescendants()) do
                if v:IsA("BasePart") then v.Size = v.Size / 3 end
            end end
        elseif runCode == "teamglow" then clearTeamGlow()
        elseif runCode == "enemyglow" then clearEnemyGlow()
        elseif runCode == "infjump" then infJumpEnabled = false
        end
        if _toggleConns[runCode] then
            pcall(function() _toggleConns[runCode]:Disconnect() end)
            _toggleConns[runCode] = nil
        end
    end
end

-- ============ 页面数据 ============
local pageContents = {
    ["公告"] = {type = "text"},
    ["通用"] = {
        type = "toggles",
        items = {
            {type = "button", name = "飞行模式", desc = "远程加载飞行脚本", icon = "🕊️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/refs/heads/main/%E9%A3%9E%E9%A5%BC"},
            {type = "button", name = "Remote", desc = "抓包", icon = "😈", url = "https://raw.githubusercontent.com/Klinac/scripts/main/utopia_spy.lua"},
            {type = "button", name = "碰撞甩飞", desc = "帅飞plud", icon = "😎", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/帅飞"},
            {type = "button", name = "fps通用", desc = "自动瞄准脚本", icon = "😎", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/%E8%87%AA%E7%9E%84"},
            {type = "button", name = "传送玩家", desc = "选择玩家传送到旁边", icon = "🫡", url = "teleport"},
            {type = "button", name = "跟随玩家", desc = "按跳跃键取消跟随", icon = "🚶", url = "follow"},
            {type = "button", name = "NTv3.3", desc = "多功能工具", icon = "😈", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/nt"},
            {type = "button", name = "无限罗宝", desc = "亲测可用", icon = "🤫", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/锁机"},
            {type = "button", name = "Tx翻译", desc = "点击执行", icon = "🧐", url = "https://raw.githubusercontent.com/JsYb666/Item/refs/heads/main/Auto-language"},
            {type = "button", name = "快速回家", desc = "传送到执行脚本时的位置", icon = "😁", url = "home"},
            {type = "toggle", name = "无敌模式", desc = "免疫伤害（客户端）", icon = "🛡️", code = "god"},
            {type = "toggle", name = "千倍速度", desc = "移动速度1000", icon = "⚡", code = "superspeed"},
            {type = "toggle", name = "无限体力", desc = "体力不会减少", icon = "💪", code = "infstamina"},
            {type = "toggle", name = "无限弹药", desc = "弹药永远999", icon = "🔫", code = "infammo"},
            {type = "toggle", name = "服务器信息", desc = "人数+坐标+附近玩家", icon = "📊", code = "serverinfo"},
            {type = "toggle", name = "自动收集", desc = "自动吸附近物品", icon = "📦", code = "collect"},
            {type = "toggle", name = "点击传送", desc = "鼠标点哪里传哪里", icon = "📍", code = "clicktp"},
            {type = "toggle", name = "自动连点", desc = "自动点击屏幕准心", icon = "🖱️", code = "autoclick"},
            {type = "toggle", name = "踏空", desc = "走到哪定到哪不往下掉", icon = "🦶", code = "float"},
            {type = "toggle", name = "防挂机", desc = "自动防止被踢出游戏", icon = "⏰", code = "antiafk"},
            {type = "toggle", name = "加速模式", desc = "游戏全局加速", icon = "⏩", code = "speedhack"},
            {type = "toggle", name = "穿墙模式", desc = "可以穿过墙壁", icon = "👻", code = "noclip"},
            {type = "toggle", name = "透视物品", desc = "高亮可拾取物品", icon = "✨", code = "itemesp"},
            {type = "toggle", name = "隐身模式", desc = "别人看不到你", icon = "👻", code = "invisible"},
            {type = "toggle", name = "删除建模", desc = "点击方块确认后删除", icon = "🗑️", code = "deletepart"},
            {type = "toggle", name = "去雾功能", desc = "消除游戏中的雾气", icon = "🌫️", code = "clearfog"},
            {type = "input", name = "旋转速度", desc = "角色自动旋转", icon = "🔄", default = "0", execute = function(v)
                if spinConnection then spinConnection:Disconnect(); spinConnection = nil end
                if v > 0 then
                    local c = Players.LocalPlayer.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        local hrp = c.HumanoidRootPart
                        spinConnection = RunService.RenderStepped:Connect(function()
                            if hrp and hrp.Parent then hrp.CFrame = hrp.CFrame * CFrame.Angles(0, math.rad(v) / 60, 0) end
                        end)
                    end
                end
                return true
            end},
            {type = "input", name = "广角", desc = "摄像机视野", icon = "🔭", default = "70", execute = function(v)
                if v > 0 and v <= 120 then
                    local cam = workspace.CurrentCamera
                    if cam then cam.FieldOfView = v; return true end
                end
                return false
            end},
            {type = "input", name = "调速度", desc = "移动速度", icon = "⚡", default = "16", execute = function(v)
                if v > 0 then
                    local c = Players.LocalPlayer.Character
                    if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = v; return true end
                end
                return false
            end},
            {type = "input", name = "跳跃高度", desc = "跳跃高度", icon = "🦘", default = "50", execute = function(v)
                if v > 0 then
                    local c = Players.LocalPlayer.Character
                    if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpHeight = v; return true end
                end
                return false
            end},
            {type = "input", name = "重力", desc = "世界重力", icon = "🌙", default = "196", execute = function(v)
                if v > 0 then workspace.Gravity = v; return true end
                return false
            end},
            {type = "toggle", name = "无限跳跃", desc = "无限连续跳跃", icon = "⬆️", code = "infjump"},
            {type = "toggle", name = "夜视功能", desc = "提高黑暗视野亮度", icon = "🔦", code = "night"},
            {type = "toggle", name = "显示FPS", desc = "左上角帧率显示", icon = "📊", code = "fps"},
            {type = "toggle", name = "ESP透视", desc = "红色描边+名字可穿墙", icon = "👁️", code = "esp"},
        }
    },
    ["战斗功能"] = {
        type = "toggles",
        items = {
            {type = "toggle", name = "团队高亮", desc = "队友蓝色高亮", icon = "🔵", code = "teamglow"},
            {type = "toggle", name = "敌对高亮", desc = "敌人红色高亮", icon = "🔴", code = "enemyglow"},
            {type = "toggle", name = "自动攻击", desc = "自动追踪攻击敌人", icon = "⚔️", code = "autoattack"},
            {type = "toggle", name = "全图点亮", desc = "消除所有阴影", icon = "💡", code = "fulllight"},
            {type = "toggle", name = "一键自杀", desc = "立即重置角色", icon = "💀", code = "suicide"},
        }
    },
    ["整活功能"] = {
        type = "toggles",
        items = {
            {type = "toggle", name = "跳舞-机械舞", desc = "机器人风格舞蹈", icon = "🤖", code = "dance1"},
            {type = "toggle", name = "喷火模式", desc = "从角色身上喷火", icon = "🔥", code = "fire"},
            {type = "toggle", name = "光环模式", desc = "角色发光环", icon = "✨", code = "glow"},
            {type = "toggle", name = "倒立行走", desc = "角色倒过来", icon = "🙃", code = "upsidedown"},
            {type = "toggle", name = "大头模式", desc = "头变得超大", icon = "🗿", code = "bighead"},
            {type = "toggle", name = "全屏特效", desc = "屏幕加滤镜", icon = "🎨", code = "screenfx"},
            {type = "toggle", name = "彩虹拖尾", desc = "移动时拖彩虹尾迹", icon = "🌈", code = "trail"},
            {type = "toggle", name = "火焰拖尾", desc = "移动时拖火焰尾迹", icon = "🔥", code = "firetrail"},
            {type = "toggle", name = "冰霜拖尾", desc = "移动时拖冰霜尾迹", icon = "❄️", code = "iceTrail"},
            {type = "toggle", name = "管理员-彩虹名字", desc = "头顶名字变彩虹色", icon = "👑", code = "rainbowname"},
            {type = "toggle", name = "巨大化", desc = "把自己变大3倍", icon = "🦖", code = "giant"},
            {type = "toggle", name = "客户端字幕", desc = "屏幕上方显示入侵信息", icon = "📺", code = "subtitle"},
            {type = "button", name = "祖国人", desc = "祖国人脚本", icon = "🦸", url = "https://raw.githubusercontent.com/giobolqv1/homelander-by-GioBolqv1-/refs/heads/main/homelander.lua"},
            {type = "button", name = "动作动画包", desc = "很多动作", icon = "🤖", url = "https://rawscripts.net/raw/Universal-Script-7yd7-I-Emote-Script-48024"},
            {type = "button", name = "播放器", desc = "自定义", icon = "🎉", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/播放"},
        }
    },
    ["音乐区"] = {
        type = "music",
        items = {
            {name = "进击的巨人", desc = "点击播放", icon = "🎵", soundId = "89711807693889"},
            {name = "误闯天家", desc = "点击播放", icon = "🎶", soundId = "124384558101360"},
            {name = "DJ喂喂喂", desc = "点击播放", icon = "🎧", soundId = "90054735589094"},
            {name = "unhappy", desc = "点击播放", icon = "🔊", soundId = "88523902860927"},
            {name = "震撼小曲二", desc = "点击播放", icon = "🎼", soundId = "137717310854691"},
            {name = "曾经的王", desc = "点击播放", icon = "🕺", soundId = "121931252233493"},
            {name = "离开我的依赖", desc = "点击播放", icon = "🌻", soundId = "112834898401032"},
            {name = "雨爱", desc = "点击播放", icon = "🌸", soundId = "79277371759525"},
            {name = "iqoo", desc = "点击播放", icon = "🎁", soundId = "75047041148646"},
            {name = "玉米饼", desc = "点击播放", icon = "🌽", soundId = "142376088"},
            {name = "我太想进步了", desc = "点击播放", icon = "🍺", soundId = "126846792948717"},
            {name = "最初的记忆", desc = "点击播放", icon = "💜", soundId = "108869978075942"},
            {name = "海与你", desc = "完整版", icon = "🥶", soundId = "76421239273915"},
            {name = "失眠", desc = "完整版", icon = "😴", soundId = "138048397060431"},
            {name = "传说之下", desc = "完整版", icon = "🍁", soundId = "138048397060431"},
            {name = "祖国人进行曲", desc = "点击播放", icon = "🎃", soundId = "86555185586884"},
        }
    },
    ["甩飞"] = {
        type = "buttons",
        items = {{name = "多人甩飞", desc = "选择玩家然后甩飞", icon = "💨", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/%E7%94%A9%E9%A3%9E"}}
    },
}

-- ============ 服务器页 ============
pageContents["服务器"] = {
    type = "buttons",
    items = {
        {name = "灾难之岛", desc = "点击执行", icon = "🎍", url = "https://raw.githubusercontent.com/hgvuyguyg/new/main/灾难之岛"},
        {name = "找出谁打了一巴掌", desc = "点击执行", icon = "🤲", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/巴掌"},
        {name = "汉堡包", desc = "点击执行", icon = "🍔", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/汉堡"},
        {name = "机器人滑膛枪", desc = "点击执行", icon = "🤖", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/机器人"},
        {name = "住宅大逃杀", desc = "点击执行", icon = "🚪", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/住宅屠杀"},
        {name = "降落或死亡", desc = "点击执行", icon = "🛩️", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/死亡"},
        {name = "砧板鲶鱼", desc = "点击执行", icon = "🐟", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/钓鱼"},
        {name = "死铁轨(黑脚本)", desc = "点击执行", icon = "🚂", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/铁轨"},
        {name = "柠檬大亨", desc = "点击执行", icon = "🍋", url = "https://rawscripts.net/raw/Sell-Lemons-Fluid-Orchard-Update-Read-Description-241132"},
        {name = "键盘逃脱", desc = "点击执行", icon = "⌨️", url = "https://raw.githubusercontent.com/ccdushii/zzzzzzzzz/refs/heads/main/ssssssssss"},
        {name = "驾驶帝国", desc = "皮脚本版", icon = "🚗", url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/Roblox-Pi-Drivingempire-Script.lua"},
        {name = "排干湖水", desc = "点击执行", icon = "💧", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/%E6%8E%92%E5%B9%B2%E6%B9%96%E6%B0%B4"},
        {name = "Doors", desc = "点击执行", icon = "🚪", url = "https://raw.githubusercontent.com/XxwanhexxX/doors-zh/refs/heads/main/Abysall.Hub"},
        {name = "后巷", desc = "点击执行", icon = "🏚️", url = "https://github.com/mryitang-sys/Ting-script/releases/download/nsjxjxhs/GE.2.6.lua"},
        {name = "点击一次加一弹药", desc = "点击执行", icon = "🔫", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/%E5%BC%B9%E8%8D%AF"},
        {name = "森林中的九十九夜", desc = "点击执行", icon = "🌲", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/99"},
        {name = "踢一个幸运方块", desc = "点击执行", icon = "🎲", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/%E5%B9%B8%E8%BF%90%E6%96%B9%E5%9D%97"},
        {name = "重型钓鱼", desc = "点击执行", icon = "🐬", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/重型钓鱼"},
        {name = "每次点击加1脂肪", desc = "点击执行", icon = "🍔", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/脂肪"},
        {name = "动物医院", desc = "点击执行", icon = "🚑", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/福瑞医院"},
        {name = "每次点击加1关注者", desc = "点击执行", icon = "❤️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/关注"},
        {name = "吃吃世界", desc = "点击执行", icon = "🍱", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/吃吃世界"},
        {name = "为你的城市供电", desc = "点击执行", icon = "🚦", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/为你的城市供电"},
        {name = "抛一枚硬币", desc = "点击执行", icon = "🎃", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/抛一枚硬币"},
        {name = "po大po", desc = "点击执行", icon = "🌰", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/拉大便"},
        {name = "blox Fruit", desc = "点击执行", icon = "🍎", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/blox"},
        {name = "悬崖豪宅大亨", desc = "点击执行", icon = "🥂", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/豪宅悬崖"},
        {name = "草地增量模拟器", desc = "点击执行", icon = "🌿", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/草地增亮"},
        {name = "餐厅大亨3", desc = "点击执行", icon = "☕", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/餐厅大亨"},
        {name = "破坏者谜团二", desc = "点击执行", icon = "☠️", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/mm2"},
        {name = "画一个滑雪板", desc = "点击执行", icon = "🛴", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/画画"},
        {name = "拥有一家咖啡馆", desc = "点击执行", icon = "🍵", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/拥有咖啡馆"},
        {name = "快躲起来吧！", desc = "点击执行", icon = "🐾", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/躲起来"},
        {name = "钓鱼吧", desc = "点击执行", icon = "🦈", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/调"},
        {name = "清洗键盘", desc = "点击执行", icon = "⌨️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/清洗键盘"},
        {name = "装载卡车", desc = "点击执行", icon = "🚛", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/装载卡车"},
        {name = "fisch", desc = "点击执行", icon = "🐠", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/船鱼"},
        {name = "种植花园2", desc = "点击执行", icon = "☘️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/种植菜园二"},
        {name = "活了7天", desc = "点击执行", icon = "🐻", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/活了7天"},
        {name = "被遗弃", desc = "点击执行", icon = "👻", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/被遗弃"},
        {name = "河北唐县", desc = "点击执行", icon = "🚙", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/河北"},
        {name = "在末日中活下来", desc = "点击执行", icon = "🤢", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/末日"},
        {name = "零售大亨2", desc = "点击执行", icon = "🛷", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/零售大亨"},
        {name = "采矿大亨", desc = "点击执行", icon = "🦇", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/采矿"},
        {name = "启示录", desc = "点击执行", icon = "⚠️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/启示录"},
        {name = "战争大亨", desc = "点击执行", icon = "🦚", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/战争"},
        {name = "海上生存100天", desc = "点击执行", icon = "💧", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/海上100天"},
        {name = "俄亥俄州", desc = "点击执行", icon = "🦉", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/ohio"},
        {name = "加1割草冒险", desc = "点击执行", icon = "🌱", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/割草冒险"},
        {name = "贪婪的种植者", desc = "点击执行", icon = "🤑", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/种植者"},
        {name = "加1剑点击", desc = "点击执行", icon = "🖕🏻", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/剑1"},
        {name = "在超级商店生存", desc = "点击执行", icon = "🥓", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/在超级商店生存"},
        {name = "在寒冷中生存", desc = "点击执行", icon = "🥶", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/在寒冷生存"},
        {name = "训练一只鸡", desc = "点击执行", icon = "🐓", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/训练鸡肉"},
        {name = "尘土飞扬的旅行", desc = "点击执行", icon = "🚘", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/长途旅行"},
        {name = "最强战场", desc = "点击执行", icon = "👾", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/最强"},
        {name = "跳跃获得足球球员", desc = "点击执行", icon = "🎈", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/获得球员"},
        {name = "伐木大亨2", desc = "点击执行", icon = "🌳", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/伐木大亨"},
        {name = "偷一个蛋", desc = "点击执行", icon = "🥚", url = "https://pastefy.app/4lHhgnhn/raw"},
        {name = "变身升级", desc = "点击执行", icon = "🐛", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/变身升级"},
        {name = "加1肌肉破坏墙壁", desc = "点击执行", icon = "💪🏼", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/肌肉墙壁"},
        {name = "加1翅膀偷走脑残", desc = "点击执行", icon = "🍪", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/翅膀脑残"},
        {name = "踢球进太空", desc = "点击执行", icon = "🐃", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/踢球太空"},
        {name = "魔法战利品", desc = "点击执行", icon = "✨", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/魔法战利品"},
        {name = "夜幕降临", desc = "点击执行", icon = "🐼", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/夜幕降临"},
        {name = "我的恐龙生活", desc = "点击执行", icon = "🦖", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/恐龙生活"},
        {name = "加一双跳自行车", desc = "点击执行", icon = "🚲", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/双跳车"},
        {name = "谋杀之岛2", desc = "点击执行", icon = "🌶️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/谋杀之岛"},
        {name = "声名远播", desc = "点击执行", icon = "🍃", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/抢劫"},
        {name = "加1速度僵尸键盘逃脱", desc = "点击执行", icon = "🐊", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/僵尸键盘"},
        {name = "清理所有树叶", desc = "点击执行", icon = "🍁", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/清理树叶"},
        {name = "开箱asmr", desc = "点击执行", icon = "🍰", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/开箱脆皮"},
        {name = "因为脑残退化而倒下", desc = "点击执行", icon = "🐊", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/脑残倒下"},
        {name = "我的木材农场", desc = "点击执行", icon = "🌲", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/我的木材农场"},
        {name = "加一个后空翻键盘逃脱", desc = "点击执行", icon = "💀", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/后空翻键盘"},
        {name = "每次点击加一排水速度", desc = "点击执行", icon = "💧", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/点击加排水"},
        {name = "加一肌肉进化", desc = "点击执行", icon = "💪🏼", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一肌肉精华"},
        {name = "抽取一只军队", desc = "点击执行", icon = "🍼", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/抽军队"},
        {name = "合拼一个核弹", desc = "点击执行", icon = "😺", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/合并核弹"},
        {name = "加一速度进化", desc = "点击执行", icon = "🐒", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加速度进化"},
        {name = "逃跑者", desc = "点击执行", icon = "👻", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/淘宝"},
        {name = "击杀头目", desc = "点击执行", icon = "🎅🏿", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/击杀头目"},
        {name = "加一速度沙滩逃脱", desc = "点击执行", icon = "🏖️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一沙滩"},
        {name = "dit", desc = "点击执行", icon = "🦰", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/dit"},
        {name = "正在探矿", desc = "点击执行", icon = "👀", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/正在挖矿"},
        {name = "蝗虫之屋", desc = "点击执行", icon = "🦗", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/蝗虫之王"},
        {name = "加一超级英雄进化", desc = "点击执行", icon = "🐲", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加油英雄"},
        {name = "拯救猫咪", desc = "点击执行", icon = "🐱", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/拯救猫"},
        {name = "恐怖寿司[第一章]", desc = "点击执行", icon = "😱", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/寿司"},
        {name = "加一蛛丝逃脱", desc = "点击执行", icon = "🕸️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一蜘蛛"},
        {name = "加一跳墙奥比逃脱", desc = "点击执行", icon = "🛫", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一跳墙"},
        {name = "按一个键帽", desc = "点击执行", icon = "🍅", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/按键帽"},
        {name = "在51区生存真相", desc = "点击执行", icon = "🤫", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/51真相"},
        {name = "每步减重", desc = "点击执行", icon = "🦵", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/走路减重"},
        {name = "矿井", desc = "点击执行", icon = "🛶", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/矿井"},
        {name = "神秘的杀手", desc = "点击执行", icon = "👹", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/神秘的杀手"},
        {name = "寻找菜鸟并变身", desc = "点击执行", icon = "🍸", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/寻找菜鸟"},
        {name = "加一技能点传奇", desc = "点击执行", icon = "⚔️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一技能点"},
        {name = "加一忍者键盘逃脱", desc = "点击执行", icon = "🌑", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一忍者"},
        {name = "破碎之梦", desc = "点击执行", icon = "❤️", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/破碎"},
        {name = "钓鱼换取垃圾", desc = "点击执行", icon = "🐡", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/钓鱼垃圾"},
        {name = "新手间接式", desc = "点击执行", icon = "🤨", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/新手间接式"},
        {name = "烤或死", desc = "点击执行", icon = "🍖", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/烤活死"},
        {name = "加一跳跃", desc = "点击执行", icon = "🦘", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/加一跳跃逃脱"},
        {name = "挖掘以逃脱", desc = "点击执行", icon = "🎃", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/挖掘逃出监狱"},
        {name = "飞行世界", desc = "点击执行", icon = "✈️", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/飞行世界"},
        {name = "空乘模拟器", desc = "点击执行", icon = "🛫", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/空乘模拟机"},
        {name = "埃尔帕索边境角色扮演", desc = "点击执行", icon = "🤑", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/帕索角色扮演"},
        {name = "加一玩具长臂逃脱", desc = "点击执行", icon = "🤳", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/玩具长臂"},
        {name = "墨水(别催了)", desc = "点击执行", icon = "😢", url = "https://raw.githubusercontent.com/hgvuyguyg/inkgames.github.io/refs/heads/main/ringta.lua"},
        {name = "无尽旅馆", desc = "点击执行", icon = "😎", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/k"},
        {name = "力量传奇", desc = "点击执行", icon = "💪🏼", url = "https://raw.githubusercontent.com/hgvuyguyg/jjjjjjjjj/main/力量"},
        {name = "路线06", desc = "点击执行", icon = "🐍", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/路线"},
        {name = "军事军队大亨", desc = "点击执行", icon = "🤠", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/战斗大亨"},
        {name = "偷走巴掌", desc = "点击执行", icon = "🖐🏻️", url = "https://raw.githubusercontent.com/hgvuyguyg/sbqr/main/1巴掌"},
    }
}

-- ============ 国内脚本页 ============
pageContents["国内脚本"] = {
    type = "buttons",
    items = {
        {name = "小皮脚本", desc = "拉完了", icon = "😔", url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ3106633104-Roblox-Pi-script.lua"},
        {name = "黑洞脚本", desc = "BS脚本", icon = "🤩", url = "https://gitee.com/BS_script/script/raw/master/BS_Script.Luau"},
        {name = "ROB脚本", desc = "ROB.V4", icon = "😍", url = "https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/rob.v4"},
        {name = "黄某脚本", desc = "拉完了缝合", icon = "😞", url = "https://rawscripts.net/raw/Universal-Script-HMscript-50384"},
        {name = "Loarder脚本", desc = "拉完了", icon = "🤔", url = "https://raw.githubusercontent.com/Jilxi/123/refs/heads/main/Loader.lua"},
    }
}

-- ============ 收集所有功能 ============
local allSearchItems = {}
for pageName, contentData in pairs(pageContents) do
    if contentData.items then
        for _, itm in ipairs(contentData.items) do
            table.insert(allSearchItems, {page = pageName, item = itm})
        end
    end
end

-- ============ 主窗口 ============
local TAB_NAMES = {"公告", "通用", "战斗功能", "整活功能", "音乐区", "甩飞", "服务器", "国内脚本", "设置"}
local findTabIndex
do
    local m = {}
    for i, n in ipairs(TAB_NAMES) do m[n] = i end
    findTabIndex = function(n) return m[n] end
end

local mainWin
local function closeAll()
    if mainWin then pcall(function() mainWin:destroy() end) end
    if fpsGui then pcall(function() fpsGui:Destroy() end) end
end

mainWin = ui.createPanel({
    w = 500, h = 340,
    title = "肥鱼脚本·黑客版",
    tabs = TAB_NAMES,
    sidebarWidth = 100,
    showPlayer = true,
    center = true,
    onClose = function()
        local verify
        verify = ui.createPanel({
            w = 320, h = 180, title = "确认关闭", center = true,
            minimizable = false, showPlayer = false,
        })
        ui.createLabel({
            parent = verify.body, x = 0, y = 10, w = 320, h = 40,
            text = "请输入数字 1 或 2 进行二次验证",
            align = Enum.TextXAlignment.Center, textSize = 12,
        })
        ui.createButton({
            parent = verify.body, x = 60, y = 80, w = 90, h = 40,
            text = "1", textSize = 18,
            onClick = function()
                ui.createLabel({
                    parent = verify.body, x = 0, y = 130, w = 320, h = 24,
                    text = "验证失败", color = Color3.fromRGB(255, 100, 100),
                    align = Enum.TextXAlignment.Center, textSize = 11,
                })
                task.wait(0.8)
                if verify then verify:destroy() end
            end,
        })
        ui.createButton({
            parent = verify.body, x = 170, y = 80, w = 90, h = 40,
            text = "2", textSize = 18,
            onClick = function()
                if verify then verify:destroy() end
                closeAll()
            end,
        })
    end,
})

-- ============ 顶部信息框 ============
do
    local tb = mainWin.titleBar
    if tb then
        local infoBox = Instance.new("Frame")
        infoBox.BackgroundColor3 = Color3.fromRGB(76, 175, 80)
        infoBox.BorderSizePixel = 0
        infoBox.Position = UDim2.new(0, 140, 0, 4)
        infoBox.Size = UDim2.new(0, 180, 0, 26)
        infoBox.ZIndex = 30
        infoBox.Parent = tb
        Instance.new("UICorner", infoBox).CornerRadius = UDim.new(0, 6)
        local infoLabel = Instance.new("TextLabel")
        infoLabel.BackgroundTransparency = 1
        infoLabel.Size = UDim2.new(1, 0, 1, 0)
        infoLabel.Text = "大肥鱼脚本 V2.0"
        infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        infoLabel.Font = Enum.Font.GothamBold
        infoLabel.TextSize = 10
        infoLabel.ZIndex = 31
        infoLabel.Parent = infoBox
        task.spawn(function()
            while infoBox.Parent do
                local now = os.date("*t")
                infoLabel.Text = "大肥鱼脚本 V2.0 | " .. now.month .. "月" .. now.day .. "日 " .. string.format("%02d:%02d:%02d", now.hour, now.min, now.sec)
                task.wait(1)
            end
        end)

        local adminBox = Instance.new("Frame")
        adminBox.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
        adminBox.BorderSizePixel = 0
        adminBox.Position = UDim2.new(0, 326, 0, 4)
        adminBox.Size = UDim2.new(0, 90, 0, 26)
        adminBox.ZIndex = 30
        adminBox.Parent = tb
        Instance.new("UICorner", adminBox).CornerRadius = UDim.new(0, 6)
        local adminLabel = Instance.new("TextLabel")
        adminLabel.BackgroundTransparency = 1
        adminLabel.Size = UDim2.new(1, 0, 1, 0)
        adminLabel.Text = "👑 管理员"
        adminLabel.TextColor3 = Color3.fromRGB(0, 0, 0)
        adminLabel.Font = Enum.Font.GothamBold
        adminLabel.TextSize = 10
        adminLabel.ZIndex = 31
        adminLabel.Parent = adminBox
    end
end

-- ============ 页面构建器 ============
local CW = 380
local PAD = 8
local CARD_H = 42
local CARD_GAP = 6

local function makeScrollFrame(parent)
    local scroll = Instance.new("ScrollingFrame")
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Color3.fromRGB(180, 180, 180)
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = parent
    return scroll
end

-- ★ 通用 tooltip 挂载
local function attachTooltip(frame, text)
    if not text then return end
    frame.MouseEnter:Connect(function()
        local mp = UserInputService:GetMouseLocation()
        ui.showTooltip(frame, text, mp.X + 12, mp.Y + 12)
    end)
    frame.MouseLeave:Connect(function()
        ui.hideTooltip()
    end)
end

local function makeButtonCard(scroll, item, yPos)
    local tooltipText = (item.name or "") .. "\n" .. (item.desc or "")
    ui.createButton({
        parent = scroll, x = PAD, y = yPos, w = CW, h = CARD_H,
        layout = "card",
        text = (item.icon or "") .. "  " .. (item.name or ""),
        icon = ">", textSize = 11,
        tooltip = tooltipText,
        onClick = function()
            if item.url == "teleport" or item.url == "follow" then
                local selectWin = ui.createPanel({
                    w = 220, h = 300,
                    title = item.url == "follow" and "选择跟随" or "选择玩家",
                    center = true, minimizable = false, showPlayer = false,
                })
                local pY = 8
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr ~= Players.LocalPlayer then
                        local target = plr
                        ui.createButton({
                            parent = selectWin.body, x = 8, y = pY, w = 204, h = 30,
                            layout = "card", text = target.Name, icon = ">", textSize = 11,
                            tooltip = "点击传送到 " .. target.Name .. " 旁边",
                            onClick = function()
                                if item.url == "follow" then
                                    followActive = true
                                    if followConnection then followConnection:Disconnect() end
                                    followConnection = RunService.RenderStepped:Connect(function()
                                        if not followActive then
                                            if followConnection then followConnection:Disconnect(); followConnection = nil end
                                            return
                                        end
                                        local c = Players.LocalPlayer.Character
                                        local tc = target.Character
                                        if c and c:FindFirstChild("HumanoidRootPart") and tc and tc:FindFirstChild("HumanoidRootPart") then
                                            c.HumanoidRootPart.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
                                        end
                                    end)
                                    UserInputService.JumpRequest:Connect(function()
                                        if followActive then
                                            followActive = false
                                            if followConnection then followConnection:Disconnect(); followConnection = nil end
                                        end
                                    end)
                                else
                                    local c = Players.LocalPlayer.Character
                                    local tc = target.Character
                                    if c and c:FindFirstChild("HumanoidRootPart") and tc and tc:FindFirstChild("HumanoidRootPart") then
                                        c.HumanoidRootPart.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(3, 0, 0)
                                    end
                                end
                                selectWin:destroy()
                            end,
                        })
                        pY = pY + 34
                    end
                end
            elseif item.url == "home" then
                if homePosition then
                    local c = Players.LocalPlayer.Character
                    if c and c:FindFirstChild("HumanoidRootPart") then
                        c.HumanoidRootPart.CFrame = homePosition
                    end
                end
            elseif item.url then
                if item.name == "驾驶帝国" then
                    pcall(function() getgenv().XiaoPi = "皮脚本-驾驶帝国" end)
                end
                task.spawn(function()
                    pcall(function()
                        loadstring(game:HttpGet(item.url))()
                    end)
                end)
            end
        end,
    })
    return yPos + CARD_H + CARD_GAP
end

local function makeToggleCard(scroll, item, yPos)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, CW, 0, CARD_H)
    card.Position = UDim2.new(0, PAD, 0, yPos)
    card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
    card.BorderSizePixel = 0
    card.Parent = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", card); st.Color = Color3.fromRGB(230, 230, 230)
    ui.createLabel({
        parent = card, x = 10, y = 5, w = CW - 60, h = 16,
        text = (item.icon or "") .. "  " .. (item.name or ""),
        textSize = 11, font = Enum.Font.GothamMedium,
    })
    ui.createLabel({
        parent = card, x = 30, y = 22, w = CW - 80, h = 14,
        text = item.desc or "", textSize = 9,
        color = Color3.fromRGB(130, 130, 130),
    })
    ui.createToggle({
        parent = card, x = CW - 46, y = 11, w = 36, h = 20,
        value = false,
        onChange = function(v)
            pcall(handleFeatureToggle, item.code, v)
        end,
    })
    attachTooltip(card, (item.name or "") .. "\n" .. (item.desc or ""))
    return yPos + CARD_H + CARD_GAP
end

local function makeInputCard(scroll, item, yPos)
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, CW, 0, CARD_H)
    card.Position = UDim2.new(0, PAD, 0, yPos)
    card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
    card.BorderSizePixel = 0
    card.Parent = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", card); st.Color = Color3.fromRGB(230, 230, 230)
    ui.createLabel({
        parent = card, x = 10, y = 5, w = CW - 140, h = 16,
        text = (item.icon or "") .. "  " .. (item.name or ""),
        textSize = 11, font = Enum.Font.GothamMedium,
    })
    ui.createLabel({
        parent = card, x = 30, y = 22, w = CW - 160, h = 14,
        text = (item.desc or "") .. " (默认" .. tostring(item.default or "") .. ")",
        textSize = 9, color = Color3.fromRGB(130, 130, 130),
    })
    local tb = ui.createTextBox({
        parent = card, x = CW - 130, y = 10, w = 60, h = 22,
        text = item.default or "", textSize = 11,
        align = Enum.TextXAlignment.Center,
    })
    ui.createButton({
        parent = card, x = CW - 62, y = 10, w = 50, h = 22,
        text = "设置", textSize = 10,
        tooltip = "点击应用输入框中的数值",
        onClick = function()
            local v = tonumber(tb.Text)
            if v and item.execute then
                pcall(item.execute, v)
            end
        end,
    })
    attachTooltip(card, (item.name or "") .. "\n" .. (item.desc or "") .. "，当前默认值 " .. tostring(item.default or ""))
    return yPos + CARD_H + CARD_GAP
end

local function makeMusicCard(scroll, item, yPos)
    local sound = nil
    local isPlaying = false
    local card = Instance.new("Frame")
    card.Size = UDim2.new(0, CW, 0, CARD_H)
    card.Position = UDim2.new(0, PAD, 0, yPos)
    card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
    card.BorderSizePixel = 0
    card.Parent = scroll
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
    local st = Instance.new("UIStroke", card); st.Color = Color3.fromRGB(230, 230, 230)
    ui.createLabel({
        parent = card, x = 10, y = 5, w = CW - 80, h = 16,
        text = (item.icon or "") .. "  " .. (item.name or ""),
        textSize = 11, font = Enum.Font.GothamMedium,
    })
    ui.createLabel({
        parent = card, x = 30, y = 22, w = CW - 100, h = 14,
        text = item.desc or "", textSize = 9,
        color = Color3.fromRGB(130, 130, 130),
    })
    local btn
    btn = ui.createButton({
        parent = card, x = CW - 62, y = 10, w = 50, h = 22,
        text = "播放", textSize = 10,
        tooltip = "点击播放 / 再点一次停止",
        onClick = function()
            if isPlaying then
                if sound then sound:Stop(); sound:Destroy(); sound = nil end
                isPlaying = false
                if btn then btn.Text = "播放" end
            else
                sound = Instance.new("Sound")
                sound.SoundId = "rbxassetid://" .. tostring(item.soundId)
                sound.Volume = 1
                sound.Parent = workspace
                sound:Play()
                sound.Ended:Connect(function()
                    if sound then sound:Destroy() end
                    sound = nil; isPlaying = false
                    if btn then btn.Text = "播放" end
                end)
                isPlaying = true
                if btn then btn.Text = "停止" end
            end
        end,
    })
    attachTooltip(card, (item.name or "") .. "\n" .. (item.desc or ""))
    return yPos + CARD_H + CARD_GAP
end

local function renderItem(scroll, item, pageType, yPos)
    local t = item.type or pageType
    if t == "button" or t == "buttons" then
        return makeButtonCard(scroll, item, yPos)
    elseif t == "toggle" or t == "toggles" then
        return makeToggleCard(scroll, item, yPos)
    elseif t == "input" then
        return makeInputCard(scroll, item, yPos)
    elseif t == "music" then
        return makeMusicCard(scroll, item, yPos)
    end
    return yPos
end

-- ============ 公告页 ============
local function buildAnnouncementPage(page)
    local searchTb = ui.createTextBox({
        parent = page, x = PAD, y = 8, w = CW, h = 32,
        placeholder = "🔍 搜索功能 (按回车搜索)",
        textSize = 12,
    })
    local timeLabel = ui.createLabel({
        parent = page, x = PAD, y = 50, w = CW, h = 280,
        text = "", textSize = 11,
        color = Color3.fromRGB(70, 70, 70),
        vAlign = Enum.TextYAlignment.Top, wrapped = true,
    })
    local resultScroll = makeScrollFrame(page)
    resultScroll.Position = UDim2.new(0, 0, 0, 48)
    resultScroll.Visible = false

    local function getTime()
        local n = os.date("*t")
        return n.year .. "年" .. n.month .. "月" .. n.day .. "日 " .. string.format("%02d:%02d:%02d", n.hour, n.min, n.sec)
    end
    task.spawn(function()
        while mainWin and mainWin.frame and mainWin.frame.Parent do
            pcall(function()
                timeLabel.Text =
                    "⏰ " .. getTime() .. "\n\n" ..
                    "👤 制作者：C 大肥鱼\n" ..
                    "📅 创建日期：2026年7月10日\n" ..
                    "🔄 此脚本一直更新\n\n" ..
                    "📊 您目前已经执行了 " .. globalExecCount .. " 次，感谢您的支持！\n" ..
                    "\n🇨🇳金秋十月，喜迎国庆！山河锦绣，国泰民安。\n\n✨感谢各位一直以来支持黑脚本。\n\n🎉愿大家假期愉快，万事顺遂！"
            end)
            task.wait(1)
        end
    end)

    searchTb.FocusLost:Connect(function(enterPressed)
        if not enterPressed then return end
        local q = string.lower(searchTb.Text or "")
        for _, c in ipairs(resultScroll:GetChildren()) do c:Destroy() end
        if q == "" then
            resultScroll.Visible = false
            timeLabel.Visible = true
            return
        end
        timeLabel.Visible = false
        resultScroll.Visible = true
        local yPos = 4
        for _, entry in ipairs(allSearchItems) do
            local itm = entry.item
            local nameMatch = itm.name and string.lower(itm.name):find(q, 1, true)
            local descMatch = itm.desc and string.lower(itm.desc):find(q, 1, true)
            if nameMatch or descMatch then
                ui.createButton({
                    parent = resultScroll, x = PAD, y = yPos, w = CW, h = CARD_H,
                    layout = "card",
                    text = (itm.icon or "") .. "  " .. (itm.name or "") .. "   (" .. entry.page .. ")",
                    icon = ">", textSize = 11,
                    tooltip = (itm.name or "") .. "\n" .. (itm.desc or "") .. "\n所在分类：" .. entry.page,
                    onClick = function()
                        local idx = findTabIndex(entry.page)
                        if idx then mainWin:selectTab(idx) end
                    end,
                })
                yPos = yPos + CARD_H + CARD_GAP
            end
        end
    end)
end

-- ============ 遍历页面构建 ============
for pageName, contentData in pairs(pageContents) do
    local idx = findTabIndex(pageName)
    if idx and mainWin.tabs[idx] then
        local page = mainWin.tabs[idx]
        if pageName == "公告" then
            buildAnnouncementPage(page)
        else
            local scroll = makeScrollFrame(page)
            local yPos = 8
            local items = contentData.items or {}
            for _, item in ipairs(items) do
                yPos = renderItem(scroll, item, contentData.type, yPos)
            end
        end
    end
end

-- ============ 设置页 ============
do
    local settingsIdx = findTabIndex("设置")
    if settingsIdx and mainWin.tabs[settingsIdx] then
        local page = mainWin.tabs[settingsIdx]
        local scroll = makeScrollFrame(page)
        local yPos = 8

        -- 边框颜色
        do
            local colorNames = {"金色", "红色", "蓝色", "绿色", "紫色", "粉色", "青色", "白色"}
            local colorValues = {
                Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 0, 0),
                Color3.fromRGB(0, 150, 255), Color3.fromRGB(0, 255, 100),
                Color3.fromRGB(200, 0, 255), Color3.fromRGB(255, 100, 200),
                Color3.fromRGB(0, 255, 255), Color3.fromRGB(255, 255, 255),
            }
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, CW, 0, 100)
            card.Position = UDim2.new(0, PAD, 0, yPos)
            card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
            local cst = Instance.new("UIStroke", card); cst.Color = Color3.fromRGB(230, 230, 230)
            ui.createLabel({
                parent = card, x = 10, y = 6, w = CW - 20, h = 16,
                text = "🎨  边框颜色", textSize = 11, font = Enum.Font.GothamMedium,
            })
            ui.createLabel({
                parent = card, x = 30, y = 24, w = CW - 40, h = 14,
                text = "点击色块切换面板边框颜色", textSize = 9,
                color = Color3.fromRGB(130, 130, 130),
            })
            ui.createColorPicker({
                parent = card, x = 15, y = 44,
                size = 22, gap = 6, cols = 8, value = 1,
                palette = colorValues, names = colorNames,
                onChange = function(col, idx, name)
                    if mainWin.panelStroke then
                        mainWin.panelStroke.Color = col
                    end
                end,
            })
            yPos = yPos + 100 + CARD_GAP
        end

        -- 面板比例
        do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, CW, 0, 60)
            card.Position = UDim2.new(0, PAD, 0, yPos)
            card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
            local sst = Instance.new("UIStroke", card); sst.Color = Color3.fromRGB(230, 230, 230)
            ui.createLabel({
                parent = card, x = 10, y = 6, w = CW - 20, h = 16,
                text = "📱  面板比例", textSize = 11, font = Enum.Font.GothamMedium,
            })
            ui.createLabel({
                parent = card, x = 30, y = 24, w = CW - 40, h = 14,
                text = "切换平板 / 手机尺寸", textSize = 9,
                color = Color3.fromRGB(130, 130, 130),
            })
            ui.createButton({
                parent = card, x = CW - 150, y = 16, w = 66, h = 28,
                text = "平板", textSize = 10,
                tooltip = "切换到平板尺寸 580 × 440",
                onClick = function() mainWin:setSize(580, 440) end,
            })
            ui.createButton({
                parent = card, x = CW - 78, y = 16, w = 66, h = 28,
                text = "手机", textSize = 10,
                tooltip = "切换到手机尺寸 500 × 340",
                onClick = function() mainWin:setSize(500, 340) end,
            })
            yPos = yPos + 60 + CARD_GAP
        end

        -- 透视作者
        do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, CW, 0, CARD_H)
            card.Position = UDim2.new(0, PAD, 0, yPos)
            card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
            local ast = Instance.new("UIStroke", card); ast.Color = Color3.fromRGB(230, 230, 230)
            ui.createLabel({
                parent = card, x = 10, y = 5, w = CW - 60, h = 16,
                text = "🤓  透视作者", textSize = 11, font = Enum.Font.GothamMedium,
            })
            ui.createLabel({
                parent = card, x = 30, y = 22, w = CW - 80, h = 14,
                text = "开启或关闭作者 ESP 高亮", textSize = 9,
                color = Color3.fromRGB(130, 130, 130),
            })
            ui.createToggle({
                parent = card, x = CW - 46, y = 11, w = 36, h = 20,
                value = authorEspEnabled,
                onChange = function(v)
                    if v then enableAuthorESP() else disableAuthorESP() end
                end,
            })
            attachTooltip(card, "透视作者\n开启后金色高亮脚本作者 CHANGCHENG66")
            yPos = yPos + CARD_H + CARD_GAP
        end

        -- 收藏模式
        do
            local card = Instance.new("Frame")
            card.Size = UDim2.new(0, CW, 0, CARD_H)
            card.Position = UDim2.new(0, PAD, 0, yPos)
            card.BackgroundColor3 = Color3.fromRGB(252, 252, 252)
            card.BorderSizePixel = 0
            card.Parent = scroll
            Instance.new("UICorner", card).CornerRadius = UDim.new(0, 10)
            local fst = Instance.new("UIStroke", card); fst.Color = Color3.fromRGB(230, 230, 230)
            ui.createLabel({
                parent = card, x = 10, y = 5, w = CW - 60, h = 16,
                text = "⭐  收藏模式", textSize = 11, font = Enum.Font.GothamMedium,
            })
            ui.createLabel({
                parent = card, x = 30, y = 22, w = CW - 80, h = 14,
                text = "开启后卡片右上角显示收藏星标", textSize = 9,
                color = Color3.fromRGB(130, 130, 130),
            })
            ui.createToggle({
                parent = card, x = CW - 46, y = 11, w = 36, h = 20,
                value = false,
                onChange = function(v)
                    ui.setFavoriteMode(v)
                end,
            })
            attachTooltip(card, "收藏模式\n开启后在每个功能卡片右上角显示星标，点击即可收藏")
            yPos = yPos + CARD_H + CARD_GAP
        end
    end
end

-- ============ 启动提示（仅此一次） ============
task.delay(0.5, function()
    ui.notify({
        type = "success",
        title = "大肥鱼脚本·黑客版",
        message = "脚本执行成功",
        duration = 4,
    })
end)

print("[大肥鱼脚本·黑客版 V2.0] 已加载")