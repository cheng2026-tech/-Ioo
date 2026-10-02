-- ============================================================
-- SANA HUB 完整功能版 v4.0
-- 适配 Delta 执行器，纯客户端功能
-- 第一部分：基础设置 + 穿墙 + 加速
-- ============================================================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Camera = workspace.CurrentCamera

-- 等角色
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Root = Character:WaitForChild("HumanoidRootPart")
local Humanoid = Character:WaitForChild("Humanoid")

-- 状态
local Toggles = {
    Noclip = false,
    Speed = false,
    Fly = false,
    AutoAttack = false,
    Teleport = false,
    ESP = false,
    AutoCollect = false,
    InfJump = false,
    NoFall = false,
}

local Settings = {
    WalkSpeed = 24,
    FlySpeed = 50,
    AutoAttackRange = 20,
    AutoAttackDistance = 8,
    ESPColor = Color3.fromRGB(255, 0, 0),
}

-- 穿墙
RunService.Stepped:Connect(function()
    if Toggles.Noclip and Character then
        for _, v in ipairs(Character:GetDescendants()) do
            if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
                v.CanCollide = false
            end
        end
    end
end)

-- 加速
RunService.RenderStepped:Connect(function()
    if Toggles.Speed and Character then
        local moveDir = Humanoid.MoveDirection
        if moveDir.Magnitude > 0 then
            Root.AssemblyLinearVelocity = Vector3.new(
                moveDir.X * Settings.WalkSpeed,
                Root.AssemblyLinearVelocity.Y,
                moveDir.Z * Settings.WalkSpeed
            )
        end
    end
end)-- ============================================================
-- SANA HUB 完整功能版 v4.0
-- 第二部分：飞行 + 无限跳跃 + 无摔落伤害
-- ============================================================

-- 飞行
local flyConnection = nil
local function toggleFly(enabled)
    Toggles.Fly = enabled
    if enabled then
        flyConnection = RunService.RenderStepped:Connect(function()
            if not Toggles.Fly then return end
            local moveDir = Humanoid.MoveDirection
            local velocity = Vector3.new(
                moveDir.X * Settings.FlySpeed,
                0,
                moveDir.Z * Settings.FlySpeed
            )
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, Settings.FlySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocity = velocity - Vector3.new(0, Settings.FlySpeed, 0)
            end
            Root.AssemblyLinearVelocity = velocity
        end)
    else
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    end
end-- ============================================================
-- SANA HUB 完整功能版 v4.0
-- 第二部分：飞行 + 无限跳跃 + 无摔落伤害
-- ============================================================

-- 飞行
local flyConnection = nil
local function toggleFly(enabled)
    Toggles.Fly = enabled
    if enabled then
        flyConnection = RunService.RenderStepped:Connect(function()
            if not Toggles.Fly then return end
            local moveDir = Humanoid.MoveDirection
            local velocity = Vector3.new(
                moveDir.X * Settings.FlySpeed,
                0,
                moveDir.Z * Settings.FlySpeed
            )
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                velocity = velocity + Vector3.new(0, Settings.FlySpeed, 0)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then
                velocity = velocity - Vector3.new(0, Settings.FlySpeed, 0)
            end
            Root.AssemblyLinearVelocity = velocity
        end)
    else
        if flyConnection then flyConnection:Disconnect() flyConnection = nil end
    end
end

-- 无限跳跃
local jumpConnection = nil
local function toggleInfJump(enabled)
    Toggles.InfJump = enabled
    if jumpConnection then jumpConnection:Disconnect() jumpConnection = nil end
    if enabled then
        jumpConnection = UserInputService.JumpRequest:Connect(function()
            if Toggles.InfJump then
                Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
    end
end

-- 无摔落伤害
RunService.Stepped:Connect(function()
    if Toggles.NoFall then
        Humanoid:ChangeState(Enum.HumanoidStateType.FallingDown)
        task.wait(0.1)
        Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
    end
end)-- ============================================================
-- SANA HUB 完整功能版 v4.0
-- 第三部分：自动攻击 + ESP透视
-- ============================================================

-- 自动攻击
local attackConnection = nil
local function startAutoAttack()
    attackConnection = RunService.Heartbeat:Connect(function()
        if not Toggles.AutoAttack then return end
        local nearest = nil
        local nearestDist = Settings.AutoAttackRange
        
        for _, npc in ipairs(Workspace:GetDescendants()) do
            if npc:IsA("Model") and npc ~= Character then
                local hum = npc:FindFirstChildOfClass("Humanoid")
                local hroot = npc:FindFirstChild("HumanoidRootPart")
                if hum and hroot and hum.Health > 0 then
                    local dist = (hroot.Position - Root.Position).Magnitude
                    if dist < nearestDist then
                        nearest = {char = npc, hum = hum, hroot = hroot, dist = dist}
                        nearestDist = dist
                    end
                end
            end
        end
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                local hroot = plr.Character:FindFirstChild("HumanoidRootPart")
                if hum and hroot and hum.Health > 0 then
                    local dist = (hroot.Position - Root.Position).Magnitude
                    if dist < nearestDist then
                        nearest = {char = plr.Character, hum = hum, hroot = hroot, dist = dist}
                        nearestDist = dist
                    end
                end
            end
        end
        
        if nearest then
            Root.CFrame = CFrame.lookAt(Root.Position, nearest.hroot.Position)
            if nearest.dist < Settings.AutoAttackDistance then
                local tool = Character:FindFirstChildOfClass("Tool")
                if tool then tool:Activate() end
                local mouse = LocalPlayer:GetMouse()
                if mouse then mouse1click() end
            else
                local moveDir = (nearest.hroot.Position - Root.Position).Unit
                Root.CFrame = Root.CFrame + moveDir * 20 * (1/60)
            end
        end
    end)
end

-- ESP透视
local espConnection = nil
local espObjects = {}
local function toggleESP(enabled)
    Toggles.ESP = enabled
    if espConnection then espConnection:Disconnect() espConnection = nil end
    
    if enabled then
        espConnection = RunService.RenderStepped:Connect(function()
            for _, v in pairs(espObjects) do
                if v and v.Parent then v:Destroy() end
            end
            table.clear(espObjects)
            
            if not Toggles.ESP then return end
            
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character then
                    local hum = plr.Character:FindFirstChildOfClass("Humanoid")
                    local hroot = plr.Character:FindFirstChild("HumanoidRootPart")
                    local head = plr.Character:FindFirstChild("Head")
                    if hum and hroot and head and hum.Health > 0 then
                        local screenPos, onScreen = Camera:WorldToScreenPoint(hroot.Position)
                        if onScreen then
                            local dist = (hroot.Position - Root.Position).Magnitude
                            local text = Instance.new("TextLabel")
                            text.Size = UDim2.new(0, 150, 0, 20)
                            text.Position = UDim2.new(0, screenPos.X - 75, 0, screenPos.Y - 50)
                            text.Text = plr.Name .. " [" .. math.floor(dist) .. "m]"
                            text.TextColor3 = Settings.ESPColor
                            text.TextSize = 14
                            text.BackgroundTransparency = 1
                            text.Parent = LocalPlayer:WaitForChild("PlayerGui")
                            table.insert(espObjects, text)
                        end
                    end
                end
            end
        end)
    else
        for _, v in pairs(espObjects) do
            if v and v.Parent then v:Destroy() end
        end
        table.clear(espObjects)
    end
end-- ============================================================
-- SANA HUB 完整功能版 v4.0
-- 第四部分：自动拾取 + 传送功能
-- ============================================================

-- 自动拾取
local collectConnection = nil
local function toggleAutoCollect()
    Toggles.AutoCollect = not Toggles.AutoCollect
    if collectConnection then collectConnection:Disconnect() collectConnection = nil end
    if Toggles.AutoCollect then
        collectConnection = RunService.Heartbeat:Connect(function()
            if not Toggles.AutoCollect then return end
            for _, part in ipairs(Workspace:GetDescendants()) do
                if part:IsA("BasePart") and (part.Name:lower():find("coin") or part.Name:lower():find("gem") or part.Name:lower():find("loot")) then
                    local dist = (part.Position - Root.Position).Magnitude
                    if dist < 15 then
                        Root.CFrame = CFrame.new(part.Position)
                        task.wait(0.05)
                    end
                end
            end
        end)
    end
end

-- 传送
local function teleportTo(pos)
    if not Toggles.Teleport then
        print("[SANA] 请先开启传送开关")
        return
    end
    Root.CFrame = CFrame.new(pos)
end

-- 传送点列表
local TeleportPoints = {
    {"黑色市场", Vector3.new(1038.969849, -22.73295, 895.430237)},
    {"鱼夫码头", Vector3.new(-50.147552, -24.555279, 1462.145996)},
    {"农场", Vector3.new(-1268.339233, 2.572412, 2560.060303)},
    {"监狱门口", Vector3.new(-1697.931885, 2.630666, 1284.567383)},
    {"监狱广场", Vector3.new(-1600.602417, 2.631028, 1268.060059)},
    {"代尔山", Vector3.new(847.062988, 194.115753, -326.212708)},
    {"水帘洞(消星点)", Vector3.new(3040.956055, 109.688538, 2711.069336)},
    {"大桥", Vector3.new(949.014954, 25.215754, 2897.654785)},
    {"地图右下(消星点)", Vector3.new(-1651.38501, 2.414712, 3225.27832)},
    {"下部加油站", Vector3.new(2270.378174, 2.630927, 154.161484)},
    {"游戏厅", Vector3.new(2934.893799, 2.956458, 1693.660034)},
    {"高尔夫", Vector3.new(2280.76709, 3.037836, 1982.3573)},
    {"修船厂", Vector3.new(4096.405273, -30.401447, 2865.045166)},
    {"车辆经销商", Vector3.new(3719.950195, 3.018573, -333.311859)},
    {"医院", Vector3.new(3980.091064, 2.876060, -138.794540)},
    {"警察局", Vector3.new(3364.273193, 3.918807, -394.723358)},
    {"圣奥里修车店", Vector3.new(2782.46875, 2.630995, -418.599304)},
    {"圣奥里银行", Vector3.new(3134.054199, 6.116048, -171.369766)},
    {"圣奥里服装店", Vector3.new(3617.912597, 3.107220, -452.820648)},
    {"圣奥里平民重生", Vector3.new(3741.114990, 3.720573, -438.105987)},
    {"圣奥里码头", Vector3.new(4527.65625, -23.968238, -280.593566)},
    {"圣奥里餐饮店", Vector3.new(3182.416748, 3.018591, 426.517913)},
    {"消防部门", Vector3.new(3578.676025, 8.408823, 579.656799)},
    {"宠物店", Vector3.new(3678.237305, 3.017920, 693.114624)},
    {"圣奥里大码头", Vector3.new(2736.307617, 2.630299, -1120.333008)},
    {"圣奥里海滩桥下(消星点)", Vector3.new(3964.504395, -25.068211, -854.057251)},
    {"大景超级超市", Vector3.new(3936.582764, 3.038293, 1136.326416)},
    {"转镜中心", Vector3.new(4152.919922, 2.631675, 941.446045)},
    {"道路服务", Vector3.new(4271.33252, 2.628108, 1200.086914)},
    {"大景餐饮店", Vector3.new(4476.997559, 3.037825, 906.802979)},
    {"送货中心(美团外卖)", Vector3.new(4399.419434, 3.038999, 1609.455933)},
    {"大景卖车店", Vector3.new(3434.377441, 42.931786, 2680.0)},
}-- ============================================================
-- SANA HUB 完整功能版 v4.0
-- 第五部分：GUI界面 + 完整整合
-- ============================================================

-- GUI界面
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "SanaHubGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 500)
MainFrame.Position = UDim2.new(0, 10, 0, 10)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BackgroundTransparency = 0.05
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "SANA HUB v4.0 (完整版)"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 18
Title.Font = Enum.Font.GothamBold
Title.Parent = MainFrame

-- 关闭按钮
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 30, 0, 30)
CloseButton.Position = UDim2.new(1, -35, 0, 2)
CloseButton.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.TextSize = 16
CloseButton.Parent = MainFrame
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- 创建开关函数
local yPos = 45
local function createToggle(text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -20, 0, 32)
    btn.Position = UDim2.new(0, 10, 0, yPos)
    btn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    btn.Text = text .. "  [关]"
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 16
    btn.Parent = MainFrame
    
    local enabled = false
    btn.MouseButton1Click:Connect(function()
        enabled = not enabled
        btn.Text = text .. (enabled and "  [开]" or "  [关]")
        btn.BackgroundColor3 = enabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(70, 70, 70)
        callback(enabled)
    end)
    
    yPos = yPos + 40
end

-- 功能开关
createToggle("穿墙", function(v) Toggles.Noclip = v end)
createToggle("加速", function(v) Toggles.Speed = v end)
createToggle("飞行", function(v) toggleFly(v) end)
createToggle("无限跳跃", function(v) toggleInfJump(v) end)
createToggle("无摔落伤害", function(v) Toggles.NoFall = v end)
createToggle("自动攻击", function(v)
    Toggles.AutoAttack = v
    if v then startAutoAttack() end
end)
createToggle("ESP透视", function(v) toggleESP(v) end)
createToggle("自动拾取", function() toggleAutoCollect() end)
createToggle("传送开关", function(v) Toggles.Teleport = v end)

-- 传送点按钮
local tpYPos = yPos + 10
local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -20, 0, 120)
scrollFrame.Position = UDim2.new(0, 10, 0, tpYPos)
scrollFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scrollFrame.Parent = MainFrame

local layout = Instance.new("UIListLayout")
layout.Parent = scrollFrame

for _, point in ipairs(TeleportPoints) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 25)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = point[1]
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 14
    btn.Parent = scrollFrame
    btn.MouseButton1Click:Connect(function()
        teleportTo(point[2])
    end)
end

print("SANA HUB v4.0 完整版已加载")
print("功能：穿墙 / 加速 / 飞行 / 无限跳跃 / 无摔落 / 自动攻击 / ESP / 自动拾取 / 传送")




