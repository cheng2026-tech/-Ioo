-- ==========================================================
-- 熙熙 · 爱国者版 · 单文件合并版
-- 作者：熙熙 | 融合：大肥鱼脚本清单
-- 版本 2.0 | 模块化合并（16 模块 → 1 文件）
-- 此文件无外部依赖（仅依赖爱国者 UI 远程库）
-- ==========================================================

task.wait(2)

-- 模块: _Globals

(function()
_G.XIXI_HUB = _G.XIXI_HUB or {}

local G = _G.XIXI_HUB

G.Loaded = G.Loaded or false
G.Version = "2.0"
G.Title = "熙熙·管理员版"
G.Author = "熙熙"
G.ExecCount = 0

G.Services = {
	Players = game:GetService("Players"),
	RunService = game:GetService("RunService"),
	TweenService = game:GetService("TweenService"),
	Lighting = game:GetService("Lighting"),
	UserInputService = game:GetService("UserInputService"),
	TeleportService = game:GetService("TeleportService"),
	HttpService = game:GetService("HttpService"),
	VirtualInput = game:GetService("VirtualInputManager"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	StarterGui = game:GetService("StarterGui"),
	GuiService = game:GetService("GuiService"),
	MarketplaceService = game:GetService("MarketplaceService"),
	Stats = game:GetService("Stats"),
}

G.LocalPlayer = G.Services.Players.LocalPlayer
G.PlayerGui = G.LocalPlayer:WaitForChild("PlayerGui")
G.Camera = workspace.CurrentCamera

G.ToggleConns = {}
G.ToggleState = {}
G.Highlights = {}
G.Billboards = {}
G.Threads = {}
G.Sounds = {}
G.Guis = {}

G.Notify = function(title, content, duration, icon)
	pcall(function()
		G.Services.StarterGui:SetCore("SendNotification", {
			Title = title or "提示",
			Text = content or "",
			Duration = duration or 4,
			Icon = icon,
		})
	end)
end

G.SafeCall = function(fn, ...)
	local ok, err = pcall(fn, ...)
	if not ok then
		warn("[熙熙] " .. tostring(err))
	end
	return ok
end

G.SetConn = function(key, conn)
	if G.ToggleConns[key] then
		pcall(function() G.ToggleConns[key]:Disconnect() end)
	end
	G.ToggleConns[key] = conn
	G.ToggleState[key] = true
end

G.Disconnect = function(key)
	if G.ToggleConns[key] then
		pcall(function() G.ToggleConns[key]:Disconnect() end)
		G.ToggleConns[key] = nil
	end
	G.ToggleState[key] = false
end

G.GetPlayerNames = function()
	local list = {}
	for _, p in ipairs(G.Services.Players:GetPlayers()) do
		if p ~= G.LocalPlayer then
			table.insert(list, p.Name)
		end
	end
	return list
end

G.FindPlayer = function(name)
	if not name or name == "" or name == "（暂无玩家）" then return nil end
	return G.Services.Players:FindFirstChild(name)
end

G.GetCharacter = function(player)
	player = player or G.LocalPlayer
	return player and player.Character
end

G.GetHRP = function(player)
	local c = G.GetCharacter(player)
	return c and c:FindFirstChild("HumanoidRootPart")
end

G.GetHumanoid = function(player)
	local c = G.GetCharacter(player)
	return c and c:FindFirstChildOfClass("Humanoid")
end

return G

end)()

-- 模块: _UILibrary

(function()
local G = _G.XIXI_HUB
local UI = {}
G.UI = UI

local Patriot = loadstring(game:HttpGet("https://raw.githubusercontent.com/cheng2026-tech/-Ioo/refs/heads/main/%E7%88%B1%E5%9B%BD%E8%80%85ui.lua"))()
G.Patriot = Patriot

local Window = Patriot:CreateWindow(G.Title, G.Version)
G.Window = Window
UI.Window = Window

UI.Tabs = {}
UI.TabOrder = {}

UI.CreateTab = function(title)
	if UI.Tabs[title] then return UI.Tabs[title] end
	local tab = Window:CreateTab(title)
	UI.Tabs[title] = tab
	table.insert(UI.TabOrder, title)
	return tab
end

local Wrap = {}

Wrap.Section = function(tab, title)
	return tab:CreateSection(title)
end

Wrap.Toggle = function(tab, title, desc, default, callback)
	return tab:CreateToggle(title, desc, default, callback)
end

Wrap.Button = function(tab, title, desc, callback)
	return tab:CreateButton(title, desc, callback)
end

Wrap.Input = function(tab, title, desc, placeholder, callback)
	return tab:CreateInput(title, desc, placeholder, callback)
end

Wrap.Dropdown = function(tab, title, values, default, callback)
	return tab:CreateDropdown(title, values, default, callback)
end

Wrap.Label = function(tab, title, desc)
	if tab.CreateLabel then
		return tab:CreateLabel(title, desc)
	elseif tab.CreateParagraph then
		return tab:CreateParagraph(title, desc)
	elseif tab.CreateText then
		return tab:CreateText(title, desc)
	end
end

Wrap.Slider = function(tab, title, desc, min, max, default, callback)
	if tab.CreateSlider then
		return tab:CreateSlider(title, desc, min, max, default, callback)
	else
		local current = default
		local btn = tab:CreateButton(title .. " (" .. default .. ")", desc, function()
			current = current + 1
			if current > max then current = min end
			btn:SetText(title .. " (" .. current .. ")")
			callback(current)
		end)
		return btn
	end
end

UI.Wrap = Wrap

setmetatable(UI, {
	__index = function(self, key)
		return function(...) return Wrap[key](...) end
	end,
})

return UI

end)()

-- 模块: Module_Fly

(function()
local G = _G.XIXI_HUB

local Fly = {}
G.Fly = Fly

Fly.Active = false
Fly.Speed = 3
Fly.Chr = nil
Fly.Hum = nil
Fly.BV = nil
Fly.BG = nil
Fly.MoveConn = nil
Fly.RenderConn = nil
Fly.CharConn = nil

local function Cleanup()
	if Fly.MoveConn then pcall(function() Fly.MoveConn:Disconnect() end); Fly.MoveConn = nil end
	if Fly.RenderConn then pcall(function() Fly.RenderConn:Disconnect() end); Fly.RenderConn = nil end
	if Fly.BG then pcall(function() Fly.BG:Destroy() end); Fly.BG = nil end
	if Fly.BV then pcall(function() Fly.BV:Destroy() end); Fly.BV = nil end
	if Fly.Hum then
		pcall(function()
			for _, s in pairs(Enum.HumanoidStateType:GetEnumItems()) do
				Fly.Hum:SetStateEnabled(s, true)
			end
			Fly.Hum:ChangeState(Enum.HumanoidStateType.Running)
			Fly.Hum.PlatformStand = false
		end)
	end
	local c = Fly.Chr
	if c and c:FindFirstChild("Animate") then
		pcall(function() c.Animate.Disabled = false end)
	end
	Fly.Chr = nil
	Fly.Hum = nil
end

local function Start()
	local c = G.GetCharacter()
	if not c then G.Notify("失败", "角色未加载", 3); return end
	local hum = c:FindFirstChildWhichIsA("Humanoid")
	if not hum then return end

	Fly.Active = true
	Fly.Chr = c
	Fly.Hum = hum

	pcall(function()
		local states = {
			Climbing = false, FallingDown = false, Flying = false, Freefall = false,
			GettingUp = false, Jumping = false, Landed = false, Physics = false,
			PlatformStanding = false, Ragdoll = false, Running = false,
			RunningNoPhysics = false, Seated = false, StrafingNoPhysics = false,
			Swimming = false,
		}
		for k, v in pairs(states) do
			hum:SetStateEnabled(Enum.HumanoidStateType[k], v)
		end
		hum:ChangeState(Enum.HumanoidStateType.Swimming)
	end)

	if c:FindFirstChild("Animate") then
		pcall(function() c.Animate.Disabled = true end)
	end
	pcall(function()
		for _, t in next, hum:GetPlayingAnimationTracks() do
			t:AdjustSpeed(0)
		end
	end)

	local isR6 = hum.RigType == Enum.HumanoidRigType.R6
	local attach = isR6 and c:WaitForChild("Torso") or c:WaitForChild("UpperTorso")

	local bg = Instance.new("BodyGyro", attach)
	bg.P = 9e4
	bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
	bg.CFrame = attach.CFrame

	local bv = Instance.new("BodyVelocity", attach)
	bv.Velocity = Vector3.new(0, 0, 0)
	bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)

	hum.PlatformStand = true
	Fly.BG = bg
	Fly.BV = bv

	Fly.MoveConn = G.Services.RunService.Heartbeat:Connect(function()
		if not Fly.Active then return end
		local cc = Fly.Chr
		local hh = Fly.Hum
		if not cc or not hh or hh.Health <= 0 then return end
		if hh.MoveDirection.Magnitude > 0 then
			cc:TranslateBy(hh.MoveDirection * Fly.Speed)
		end
	end)

	Fly.RenderConn = G.Services.RunService.RenderStepped:Connect(function()
		if not Fly.Active then return end
		local cc = Fly.Chr
		local hh = Fly.Hum
		if not cc or not hh or hh.Health <= 0 or not bg.Parent then return end
		bg.CFrame = workspace.CurrentCamera.CoordinateFrame
	end)

	if not Fly.CharConn then
		Fly.CharConn = G.LocalPlayer.CharacterAdded:Connect(function()
			if Fly.Active then
				Cleanup()
				task.wait(0.5)
				Start()
			end
		end)
	end
end

local function Stop()
	Fly.Active = false
	Cleanup()
end

Fly.Start = Start
Fly.Stop = Stop
Fly.Toggle = function(state)
	if state then Start() else Stop() end
end

return Fly

end)()

-- 模块: Module_Features

(function()
local G = _G.XIXI_HUB

local F = {}
G.Features = F

local L = G.Services.Lighting

F.ESP = {}
F.ESP.Highlights = {}
F.ESP.Billboards = {}
F.ESP.Enabled = true

local function AuthorESP(p)
	if not F.ESP.Enabled then return end
	if p.Name ~= G.Author then return end
	if F.ESP.Highlights[p] then pcall(function() F.ESP.Highlights[p]:Destroy() end) end
	if F.ESP.Billboards[p] then pcall(function() F.ESP.Billboards[p]:Destroy() end) end
	local function setup(c)
		if not c then return end
		local hl = Instance.new("Highlight")
		hl.FillColor = Color3.fromRGB(255, 215, 0)
		hl.FillTransparency = 0.3
		hl.OutlineColor = Color3.fromRGB(255, 215, 0)
		hl.OutlineTransparency = 0
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.Adornee = c
		hl.Parent = c
		F.ESP.Highlights[p] = hl
		local head = c:FindFirstChild("Head")
		if head then
			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.new(0, 220, 0, 40)
			bb.StudsOffset = Vector3.new(0, 3.5, 0)
			bb.AlwaysOnTop = true
			bb.Parent = head
			local nl = Instance.new("TextLabel")
			nl.Size = UDim2.new(1, 0, 1, 0)
			nl.BackgroundTransparency = 1
			nl.Text = "👑 " .. p.Name .. " · 此脚本作者"
			nl.TextColor3 = Color3.fromRGB(255, 215, 0)
			nl.Font = Enum.Font.GothamBold
			nl.TextSize = 16
			nl.TextStrokeTransparency = 0
			nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			nl.Parent = bb
			F.ESP.Billboards[p] = bb
		end
	end
	if p.Character then setup(p.Character) end
	p.CharacterAdded:Connect(function(c) if F.ESP.Enabled then setup(c) end end)
end

F.ESP.Enable = function()
	F.ESP.Enabled = true
	for _, p in ipairs(G.Services.Players:GetPlayers()) do AuthorESP(p) end
end

F.ESP.Disable = function()
	F.ESP.Enabled = false
	for _, h in pairs(F.ESP.Highlights) do pcall(function() h:Destroy() end) end
	for _, b in pairs(F.ESP.Billboards) do pcall(function() b:Destroy() end) end
	F.ESP.Highlights = {}
	F.ESP.Billboards = {}
end

F.ESP.Refresh = function()
	F.ESP.Disable()
	if F.ESP.Enabled then F.ESP.Enable() end
end

F.TeamGlow = { Highlights = {} }
F.EnemyGlow = { Highlights = {} }

local function ClearTeam()
	for _, h in pairs(F.TeamGlow.Highlights) do pcall(function() h:Destroy() end) end
	F.TeamGlow.Highlights = {}
end

local function ClearEnemy()
	for _, h in pairs(F.EnemyGlow.Highlights) do pcall(function() h:Destroy() end) end
	F.EnemyGlow.Highlights = {}
end

F.Handle = function(code, enabled)
	if enabled then
		if code == "fly" then
			loadstring("")() -- placeholder, replaced below
		end
		if code == "god" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("Humanoid") then
				c.Humanoid.MaxHealth = 99999
				c.Humanoid.Health = 99999
				G.SetConn("god", G.Services.RunService.RenderStepped:Connect(function()
					local cc = G.GetCharacter()
					if cc and cc:FindFirstChild("Humanoid") then
						cc.Humanoid.Health = 99999
					end
				end))
			end
		elseif code == "superspeed" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("Humanoid") then
				c.Humanoid.WalkSpeed = 1000
			end
		elseif code == "infjump" then
			G.SetConn("infjump", G.Services.UserInputService.JumpRequest:Connect(function()
				local c = G.GetCharacter()
				if c and c:FindFirstChild("Humanoid") then
					c.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end))
		elseif code == "noclip" then
			G.SetConn("noclip", G.Services.RunService.Stepped:Connect(function()
				local c = G.GetCharacter()
				if c then
					for _, v in ipairs(c:GetDescendants()) do
						if v:IsA("BasePart") then
							v.CanCollide = false
						end
					end
				end
			end))
		elseif code == "invisible" then
			G.SetConn("invisible", G.Services.RunService.RenderStepped:Connect(function()
				local c = G.GetCharacter()
				if c then
					for _, v in ipairs(c:GetDescendants()) do
						if v:IsA("BasePart") then
							v.LocalTransparencyModifier = 1
						end
					end
				end
			end))
		elseif code == "clearfog" then
			L.FogEnd = 100000
			L.FogStart = 50000
		elseif code == "night" then
			L.Brightness = 2
			L.ClockTime = 14
			L.FogEnd = 100000
			L.GlobalShadows = false
		elseif code == "fulllight" then
			L.Brightness = 5
			L.ClockTime = 14
			L.FogEnd = 100000
			L.GlobalShadows = false
			L.OutdoorAmbient = Color3.fromRGB(200, 200, 200)
		elseif code == "float" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("HumanoidRootPart") then
				local hrp = c.HumanoidRootPart
				local floatY = hrp.Position.Y
				G.SetConn("float", G.Services.RunService.RenderStepped:Connect(function()
					if hrp and hrp.Parent then
						hrp.Velocity = Vector3.new(hrp.Velocity.X, 0, hrp.Velocity.Z)
						hrp.CFrame = CFrame.new(hrp.Position.X, floatY, hrp.Position.Z)
					end
				end))
			end
		elseif code == "collect" then
			G.SetConn("collect", G.Services.RunService.Heartbeat:Connect(function()
				local c = G.GetCharacter()
				if not c or not c:FindFirstChild("HumanoidRootPart") then return end
				local hrp = c.HumanoidRootPart
				for _, item in ipairs(workspace:GetDescendants()) do
					if item:IsA("Tool") or item:IsA("MeshPart")
						or (item:IsA("Part") and (item.Name:lower():find("drop")
						or item.Name:lower():find("coin") or item.Name:lower():find("gem")
						or item.Name:lower():find("orb") or item.Name:lower():find("collect"))) then
						if (item.Position - hrp.Position).Magnitude < 80 then
							item.CFrame = hrp.CFrame + Vector3.new(math.random(-3, 3), 0, math.random(-3, 3))
						end
					end
				end
			end))
		elseif code == "clicktp" then
			local mouse = G.LocalPlayer:GetMouse()
			G.SetConn("clicktp", mouse.Button1Down:Connect(function()
				local c = G.GetCharacter()
				if c and c:FindFirstChild("HumanoidRootPart") and mouse.Hit then
					c.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.p + Vector3.new(0, 3, 0))
				end
			end))
		elseif code == "autoclick" then
			G.SetConn("autoclick", G.Services.RunService.RenderStepped:Connect(function()
				local cam = workspace.CurrentCamera
				local s = cam.ViewportSize
				G.Services.VirtualInput:SendMouseButtonEvent(s.X / 2, s.Y / 2, 0, true, game, 0)
				task.wait(0.05)
				G.Services.VirtualInput:SendMouseButtonEvent(s.X / 2, s.Y / 2, 0, false, game, 0)
			end))
		elseif code == "speedhack" then
			G.SetConn("speedhack", G.Services.RunService.RenderStepped:Connect(function()
				for _, v in ipairs(workspace:GetDescendants()) do
					if v:IsA("Animation") then
						v.Speed = 2
					end
				end
			end))
		elseif code == "itemesp" then
			G.SetConn("itemesp", G.Services.RunService.RenderStepped:Connect(function()
				for _, item in ipairs(workspace:GetDescendants()) do
					if (item:IsA("Tool") or item.Name:lower():find("drop")) and not item:FindFirstChild("ItemESP") then
						local hl = Instance.new("Highlight")
						hl.Name = "ItemESP"
						hl.FillColor = Color3.fromRGB(0, 255, 0)
						hl.OutlineColor = Color3.fromRGB(255, 255, 0)
						hl.Parent = item
					end
				end
			end))
		elseif code == "teamglow" then
			ClearTeam()
			G.SetConn("teamglow", G.Services.RunService.RenderStepped:Connect(function()
				local myTeam = G.LocalPlayer.Team
				for _, p in ipairs(G.Services.Players:GetPlayers()) do
					if p ~= G.LocalPlayer and p.Character and p.Team == myTeam then
						if not F.TeamGlow.Highlights[p] then
							local hl = Instance.new("Highlight")
							hl.Name = "TeamGlow"
							hl.FillColor = Color3.fromRGB(0, 100, 255)
							hl.OutlineColor = Color3.fromRGB(0, 150, 255)
							hl.FillTransparency = 0.5
							hl.Parent = p.Character
							F.TeamGlow.Highlights[p] = hl
						end
					end
				end
			end))
		elseif code == "enemyglow" then
			ClearEnemy()
			G.SetConn("enemyglow", G.Services.RunService.RenderStepped:Connect(function()
				local myTeam = G.LocalPlayer.Team
				for _, p in ipairs(G.Services.Players:GetPlayers()) do
					if p ~= G.LocalPlayer and p.Character and p.Team ~= myTeam then
						if not F.EnemyGlow.Highlights[p] then
							local hl = Instance.new("Highlight")
							hl.Name = "EnemyGlow"
							hl.FillColor = Color3.fromRGB(255, 0, 0)
							hl.OutlineColor = Color3.fromRGB(255, 50, 50)
							hl.FillTransparency = 0.5
							hl.Parent = p.Character
							F.EnemyGlow.Highlights[p] = hl
						end
					end
				end
			end))
		elseif code == "autoattack" then
			G.SetConn("autoattack", G.Services.RunService.RenderStepped:Connect(function()
				local c = G.GetCharacter()
				if not c then return end
				local nearest = nil
				local minDist = 15
				local myTeam = G.LocalPlayer.Team
				for _, p in ipairs(G.Services.Players:GetPlayers()) do
					if p ~= G.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart")
						and p.Team ~= myTeam and p.Character.Humanoid.Health > 0 then
						local dist = (p.Character.HumanoidRootPart.Position - c.HumanoidRootPart.Position).Magnitude
						if dist < minDist then
							minDist = dist
							nearest = p.Character
						end
					end
				end
				if nearest and c:FindFirstChild("HumanoidRootPart") then
					c.HumanoidRootPart.CFrame = nearest.HumanoidRootPart.CFrame + Vector3.new(2, 0, 0)
					local tool = c:FindFirstChildOfClass("Tool")
					if tool and tool:FindFirstChild("Handle") then
						firetouchinterest(tool.Handle, nearest, 0)
						firetouchinterest(tool.Handle, nearest, 1)
					end
				end
			end))
		elseif code == "suicide" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("Humanoid") then
				c.Humanoid.Health = 0
			end
		elseif code == "glow" then
			local c = G.GetCharacter()
			if c then
				local hl = Instance.new("Highlight")
				hl.Name = "PlayerGlow"
				hl.FillColor = Color3.fromRGB(255, 255, 0)
				hl.OutlineColor = Color3.fromRGB(255, 200, 0)
				hl.FillTransparency = 0.3
				hl.Parent = c
			end
		elseif code == "fire" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("HumanoidRootPart") then
				local fire = Instance.new("ParticleEmitter")
				fire.Name = "FireFX"
				fire.Texture = "rbxassetid://0"
				fire.Color = ColorSequence.new(Color3.fromRGB(255, 100, 0))
				fire.Rate = 30
				fire.Speed = NumberRange.new(3, 6)
				fire.Lifetime = NumberRange.new(0.5, 1)
				fire.Parent = c.HumanoidRootPart
			end
		elseif code == "bighead" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("Head") then
				c.Head.Size = Vector3.new(4, 4, 4)
			end
		elseif code == "upsidedown" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("HumanoidRootPart") then
				c.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(180))
			end
		elseif code == "giant" then
			local c = G.GetCharacter()
			if c then
				for _, v in ipairs(c:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Size = v.Size * 3
					end
				end
			end
		elseif code == "trail" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("HumanoidRootPart") then
				local hrp = c.HumanoidRootPart
				local trail = Instance.new("Trail")
				trail.Name = "PlayerTrail"
				local a0 = Instance.new("Attachment")
				a0.Name = "TrailAttachment0"
				a0.Parent = hrp
				local a1 = Instance.new("Attachment")
				a1.Name = "TrailAttachment1"
				a1.Position = Vector3.new(0, -2, 0)
				a1.Parent = hrp
				trail.Attachment0 = a0
				trail.Attachment1 = a1
				trail.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0), Color3.fromRGB(0, 255, 0), Color3.fromRGB(0, 0, 255))
				trail.Lifetime = 0.5
				trail.Parent = hrp
			end
		elseif code == "firetrail" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("HumanoidRootPart") then
				local hrp = c.HumanoidRootPart
				local trail = Instance.new("Trail")
				trail.Name = "FireTrail"
				local a0 = Instance.new("Attachment")
				a0.Name = "FireTrailA0"
				a0.Parent = hrp
				local a1 = Instance.new("Attachment")
				a1.Name = "FireTrailA1"
				a1.Position = Vector3.new(0, -2, 0)
				a1.Parent = hrp
				trail.Attachment0 = a0
				trail.Attachment1 = a1
				trail.Color = ColorSequence.new(Color3.fromRGB(255, 50, 0), Color3.fromRGB(255, 150, 0), Color3.fromRGB(255, 255, 0))
				trail.Lifetime = 0.3
				trail.Parent = hrp
			end
		elseif code == "icetrail" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("HumanoidRootPart") then
				local hrp = c.HumanoidRootPart
				local trail = Instance.new("Trail")
				trail.Name = "IceTrail"
				local a0 = Instance.new("Attachment")
				a0.Name = "IceTrailA0"
				a0.Parent = hrp
				local a1 = Instance.new("Attachment")
				a1.Name = "IceTrailA1"
				a1.Position = Vector3.new(0, -2, 0)
				a1.Parent = hrp
				trail.Attachment0 = a0
				trail.Attachment1 = a1
				trail.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255), Color3.fromRGB(150, 220, 255), Color3.fromRGB(200, 240, 255))
				trail.Lifetime = 0.4
				trail.Parent = hrp
			end
		elseif code == "dance1" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("Humanoid") then
				local anim = Instance.new("Animation")
				anim.AnimationId = "rbxassetid://5918726674"
				local track = c.Humanoid:LoadAnimation(anim)
				track:Play()
				G.SetConn("dance1", { Disconnect = function() pcall(function() track:Stop() end) end })
			end
		elseif code == "screenfx" then
			local fx = Instance.new("ColorCorrectionEffect")
			fx.Name = "ScreenFX"
			fx.TintColor = Color3.fromRGB(255, 100, 200)
			fx.Parent = L
		elseif code == "rainbowname" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("Head") then
				local bb = c.Head:FindFirstChild("BillboardGui")
				if not bb then
					bb = Instance.new("BillboardGui")
					bb.Size = UDim2.new(0, 150, 0, 30)
					bb.StudsOffset = Vector3.new(0, 3, 0)
					bb.AlwaysOnTop = true
					bb.Parent = c.Head
					local nl = Instance.new("TextLabel")
					nl.Size = UDim2.new(1, 0, 1, 0)
					nl.BackgroundTransparency = 1
					nl.Text = G.LocalPlayer.DisplayName .. " 👑管理员"
					nl.Font = Enum.Font.GothamBold
					nl.TextSize = 14
					nl.Name = "RainbowName"
					nl.TextStrokeTransparency = 0
					nl.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
					nl.Parent = bb
				end
			end
			local hue = 0
			G.SetConn("rainbowname", G.Services.RunService.RenderStepped:Connect(function(dt)
				hue = (hue + dt * 0.5) % 1
				local cc = G.GetCharacter()
				if cc and cc:FindFirstChild("Head") then
					local bb = cc.Head:FindFirstChild("BillboardGui")
					if bb then
						local nl = bb:FindFirstChild("RainbowName")
						if nl then nl.TextColor3 = Color3.fromHSV(hue, 1, 1) end
					end
				end
			end))
		elseif code == "infstamina" then
			G.SetConn("infstamina", G.Services.RunService.RenderStepped:Connect(function()
				local c = G.GetCharacter()
				if c and c:FindFirstChild("Humanoid") then
					c.Humanoid.MaxHealth = c.Humanoid.MaxHealth
				end
			end))
		elseif code == "infammo" then
			G.SetConn("infammo", G.Services.RunService.RenderStepped:Connect(function()
				local c = G.GetCharacter()
				if c then
					for _, tool in ipairs(c:GetChildren()) do
						if tool:IsA("Tool") and tool:FindFirstChild("Ammo") then
							tool.Ammo.Value = 999
						end
					end
				end
			end))
		elseif code == "subtitle" then
			local gui = Instance.new("ScreenGui")
			gui.Name = "SubtitleGui"
			gui.ResetOnSpawn = false
			gui.Parent = G.PlayerGui
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0, 500, 0, 80)
			label.Position = UDim2.new(0.5, -250, 0, 10)
			label.Text = G.LocalPlayer.Name .. " 已入侵服务器"
			label.Font = Enum.Font.GothamBold
			label.TextSize = 24
			label.BackgroundTransparency = 1
			label.TextStrokeTransparency = 0
			label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			label.ZIndex = 500
			label.Parent = gui
			local timeLabel = Instance.new("TextLabel")
			timeLabel.Size = UDim2.new(0, 500, 0, 30)
			timeLabel.Position = UDim2.new(0.5, -250, 0, 115)
			timeLabel.Font = Enum.Font.Gotham
			timeLabel.TextSize = 14
			timeLabel.BackgroundTransparency = 1
			timeLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
			timeLabel.TextStrokeTransparency = 0
			timeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
			timeLabel.ZIndex = 500
			timeLabel.Parent = gui
			local hue = 0
			G.SetConn("subtitle", G.Services.RunService.RenderStepped:Connect(function(dt)
				hue = (hue + dt * 0.3) % 1
				label.TextColor3 = Color3.fromHSV(hue, 1, 1)
				local now = os.date("*t")
				timeLabel.Text = now.year .. "年" .. now.month .. "月" .. now.day .. "日 " .. string.format("%02d:%02d:%02d", now.hour, now.min, now.sec)
			end))
		elseif code == "fps" then
			if G.FPS then G.FPS.Enable() end
		elseif code == "serverinfo" then
			local gui = Instance.new("ScreenGui")
			gui.Name = "ServerInfoGui"
			gui.ResetOnSpawn = false
			gui.Parent = G.PlayerGui
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, 280, 0, 180)
			frame.Position = UDim2.new(1, -290, 0, 10)
			frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
			frame.BackgroundTransparency = 0.2
			frame.BorderSizePixel = 0
			frame.ZIndex = 500
			frame.Parent = gui
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)
			local countLabel = Instance.new("TextLabel")
			countLabel.Size = UDim2.new(1, -16, 0, 30)
			countLabel.Position = UDim2.new(0, 8, 0, 8)
			countLabel.Text = "服务器人数: " .. #G.Services.Players:GetPlayers()
			countLabel.Font = Enum.Font.GothamBold
			countLabel.TextSize = 14
			countLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			countLabel.BackgroundTransparency = 1
			countLabel.TextXAlignment = Enum.TextXAlignment.Left
			countLabel.ZIndex = 501
			countLabel.Parent = frame
			local coordLabel = Instance.new("TextLabel")
			coordLabel.Size = UDim2.new(1, -16, 0, 30)
			coordLabel.Position = UDim2.new(0, 8, 0, 40)
			coordLabel.Font = Enum.Font.Gotham
			coordLabel.TextSize = 12
			coordLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
			coordLabel.BackgroundTransparency = 1
			coordLabel.TextXAlignment = Enum.TextXAlignment.Left
			coordLabel.ZIndex = 501
			coordLabel.Parent = frame
			local nearestLabel = Instance.new("TextLabel")
			nearestLabel.Size = UDim2.new(1, -16, 0, 90)
			nearestLabel.Position = UDim2.new(0, 8, 0, 72)
			nearestLabel.Font = Enum.Font.Gotham
			nearestLabel.TextSize = 11
			nearestLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
			nearestLabel.BackgroundTransparency = 1
			nearestLabel.TextXAlignment = Enum.TextXAlignment.Left
			nearestLabel.TextYAlignment = Enum.TextYAlignment.Top
			nearestLabel.ZIndex = 501
			nearestLabel.Parent = frame
			G.SetConn("serverinfo", G.Services.RunService.RenderStepped:Connect(function()
				countLabel.Text = "服务器人数: " .. #G.Services.Players:GetPlayers()
				local c = G.GetCharacter()
				if c and c:FindFirstChild("HumanoidRootPart") then
					local pos = c.HumanoidRootPart.Position
					coordLabel.Text = "坐标: X:" .. math.floor(pos.X) .. " Y:" .. math.floor(pos.Y) .. " Z:" .. math.floor(pos.Z)
				end
				local nearestText = "附近玩家:\n"
				local myPos = c and c:FindFirstChild("HumanoidRootPart") and c.HumanoidRootPart.Position
				for _, p in ipairs(G.Services.Players:GetPlayers()) do
					if p ~= G.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and myPos then
						local dist = math.floor((p.Character.HumanoidRootPart.Position - myPos).Magnitude)
						nearestText = nearestText .. "  " .. p.Name .. " - " .. dist .. "m\n"
					end
				end
				nearestLabel.Text = nearestText
			end))
		elseif code == "deletepart" then
			local mouse = G.LocalPlayer:GetMouse()
			local curGui = nil
			local curHl = nil
			G.SetConn("deletepart", mouse.Button1Down:Connect(function()
				local t = mouse.Target
				if t then
					if curGui then curGui:Destroy() end
					if curHl then curHl:Destroy() end
					curHl = Instance.new("Highlight")
					curHl.FillColor = Color3.fromRGB(255, 0, 0)
					curHl.FillTransparency = 0.5
					curHl.OutlineColor = Color3.fromRGB(255, 0, 0)
					curHl.Adornee = t
					curHl.Parent = t
					local cg = Instance.new("ScreenGui")
					cg.Parent = G.PlayerGui
					curGui = cg
					local fr = Instance.new("Frame")
					fr.Size = UDim2.new(0, 280, 0, 130)
					fr.Position = UDim2.new(0.5, -140, 0.5, -65)
					fr.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
					fr.BorderSizePixel = 0
					fr.ZIndex = 99
					fr.Parent = cg
					Instance.new("UICorner", fr).CornerRadius = UDim.new(0, 10)
					local txt = Instance.new("TextLabel")
					txt.Size = UDim2.new(1, 0, 0, 45)
					txt.Text = "确定删除此建模吗？"
					txt.TextColor3 = Color3.fromRGB(255, 255, 255)
					txt.Font = Enum.Font.GothamBold
					txt.TextSize = 15
					txt.BackgroundTransparency = 1
					txt.ZIndex = 100
					txt.Parent = fr
					local confirmBtn = Instance.new("TextButton")
					confirmBtn.Size = UDim2.new(0, 110, 0, 34)
					confirmBtn.Position = UDim2.new(0, 18, 0, 75)
					confirmBtn.Text = "确定删除"
					confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					confirmBtn.Font = Enum.Font.GothamBold
					confirmBtn.TextSize = 13
					confirmBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
					confirmBtn.BorderSizePixel = 0
					confirmBtn.ZIndex = 100
					confirmBtn.AutoButtonColor = false
					confirmBtn.Parent = fr
					Instance.new("UICorner", confirmBtn).CornerRadius = UDim.new(0, 6)
					confirmBtn.MouseButton1Click:Connect(function()
						if curHl then curHl:Destroy() end
						t:Destroy()
						cg:Destroy()
					end)
					local cancelBtn = Instance.new("TextButton")
					cancelBtn.Size = UDim2.new(0, 110, 0, 34)
					cancelBtn.Position = UDim2.new(0, 152, 0, 75)
					cancelBtn.Text = "取消"
					cancelBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
					cancelBtn.Font = Enum.Font.GothamBold
					cancelBtn.TextSize = 13
					cancelBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
					cancelBtn.BorderSizePixel = 0
					cancelBtn.ZIndex = 100
					cancelBtn.AutoButtonColor = false
					cancelBtn.Parent = fr
					Instance.new("UICorner", cancelBtn).CornerRadius = UDim.new(0, 6)
					cancelBtn.MouseButton1Click:Connect(function()
						if curHl then curHl:Destroy() end
						cg:Destroy()
					end)
				end
			end))
		end
	else
		if code == "fly" then
			if G.Fly then G.Fly.Stop() end
		elseif code == "god" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("Humanoid") then
				c.Humanoid.MaxHealth = 100
				c.Humanoid.Health = 100
			end
		elseif code == "superspeed" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("Humanoid") then
				c.Humanoid.WalkSpeed = 16
			end
		elseif code == "invisible" then
			local c = G.GetCharacter()
			if c then
				for _, v in ipairs(c:GetDescendants()) do
					if v:IsA("BasePart") then
						v.LocalTransparencyModifier = 0
					end
				end
			end
		elseif code == "noclip" then
			local c = G.GetCharacter()
			if c then
				for _, v in ipairs(c:GetDescendants()) do
					if v:IsA("BasePart") then
						v.CanCollide = true
					end
				end
			end
		elseif code == "clearfog" then
			L.FogEnd = 1000
			L.FogStart = 0
		elseif code == "night" then
			L.Brightness = 1
			L.GlobalShadows = true
		elseif code == "fulllight" then
			L.Brightness = 1
			L.GlobalShadows = true
		elseif code == "glow" then
			local c = G.GetCharacter()
			if c then
				local hl = c:FindFirstChild("PlayerGlow")
				if hl then hl:Destroy() end
			end
		elseif code == "fire" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("HumanoidRootPart") then
				for _, v in ipairs(c.HumanoidRootPart:GetChildren()) do
					if v:IsA("ParticleEmitter") and v.Name == "FireFX" then
						v:Destroy()
					end
				end
			end
		elseif code == "bighead" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("Head") then
				c.Head.Size = Vector3.new(2, 1, 1)
			end
		elseif code == "upsidedown" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("HumanoidRootPart") then
				c.HumanoidRootPart.CFrame = c.HumanoidRootPart.CFrame * CFrame.Angles(0, 0, math.rad(180))
			end
		elseif code == "giant" then
			local c = G.GetCharacter()
			if c then
				for _, v in ipairs(c:GetDescendants()) do
					if v:IsA("BasePart") then
						v.Size = v.Size / 3
					end
				end
			end
		elseif code == "trail" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("HumanoidRootPart") then
				local hrp = c.HumanoidRootPart
				local t = hrp:FindFirstChild("PlayerTrail")
				if t then t:Destroy() end
				local a0 = hrp:FindFirstChild("TrailAttachment0")
				if a0 then a0:Destroy() end
				local a1 = hrp:FindFirstChild("TrailAttachment1")
				if a1 then a1:Destroy() end
			end
		elseif code == "firetrail" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("HumanoidRootPart") then
				local hrp = c.HumanoidRootPart
				local t = hrp:FindFirstChild("FireTrail")
				if t then t:Destroy() end
				local a0 = hrp:FindFirstChild("FireTrailA0")
				if a0 then a0:Destroy() end
				local a1 = hrp:FindFirstChild("FireTrailA1")
				if a1 then a1:Destroy() end
			end
		elseif code == "icetrail" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("HumanoidRootPart") then
				local hrp = c.HumanoidRootPart
				local t = hrp:FindFirstChild("IceTrail")
				if t then t:Destroy() end
				local a0 = hrp:FindFirstChild("IceTrailA0")
				if a0 then a0:Destroy() end
				local a1 = hrp:FindFirstChild("IceTrailA1")
				if a1 then a1:Destroy() end
			end
		elseif code == "screenfx" then
			local fx = L:FindFirstChild("ScreenFX")
			if fx then fx:Destroy() end
		elseif code == "subtitle" then
			local g = G.PlayerGui:FindFirstChild("SubtitleGui")
			if g then g:Destroy() end
		elseif code == "rainbowname" then
			local c = G.GetCharacter()
			if c and c:FindFirstChild("Head") then
				local bb = c.Head:FindFirstChild("BillboardGui")
				if bb then bb:Destroy() end
			end
		elseif code == "serverinfo" then
			local g = G.PlayerGui:FindFirstChild("ServerInfoGui")
			if g then g:Destroy() end
		elseif code == "teamglow" then
			ClearTeam()
		elseif code == "enemyglow" then
			ClearEnemy()
		end
		G.Disconnect(code)
	end
end

F.InitESP = function()
	for _, p in ipairs(G.Services.Players:GetPlayers()) do
		AuthorESP(p)
	end
	G.Services.Players.PlayerAdded:Connect(function(p)
		if F.ESP.Enabled then AuthorESP(p) end
	end)
	G.Services.Players.PlayerRemoving:Connect(function(p)
		if F.ESP.Highlights[p] then pcall(function() F.ESP.Highlights[p]:Destroy() end); F.ESP.Highlights[p] = nil end
		if F.ESP.Billboards[p] then pcall(function() F.ESP.Billboards[p]:Destroy() end); F.ESP.Billboards[p] = nil end
	end)
end

return F

end)()

-- 模块: Module_Player

(function()
local G = _G.XIXI_HUB

local P = {}
G.Player = P

P.HomePosition = nil

P.TeleportToPlayer = function(name)
	local target = G.FindPlayer(name)
	if not target then G.Notify("失败", "找不到玩家", 3); return end
	local tc = target.Character
	local mc = G.GetCharacter()
	if not tc or not tc:FindFirstChild("HumanoidRootPart") then G.Notify("失败", "目标未加载", 3); return end
	if not mc or not mc:FindFirstChild("HumanoidRootPart") then G.Notify("失败", "你未加载", 3); return end
	mc.HumanoidRootPart.CFrame = tc.HumanoidRootPart.CFrame + Vector3.new(0, 3, 0)
	G.Notify("成功", "已传送到 " .. name, 3)
end

P.GoHome = function()
	if not P.HomePosition then G.Notify("失败", "尚未记录出生点", 3); return end
	local c = G.GetCharacter()
	if c and c:FindFirstChild("HumanoidRootPart") then
		c.HumanoidRootPart.CFrame = P.HomePosition
		G.Notify("成功", "已返回出生点", 3)
	end
end

P.SaveHome = function()
	local c = G.GetCharacter()
	if c and c:FindFirstChild("HumanoidRootPart") then
		P.HomePosition = c.HumanoidRootPart.CFrame
		G.Notify("成功", "出生点已记录", 3)
	end
end

P.CopyUserId = function(name)
	local p = G.FindPlayer(name)
	if not p then G.Notify("失败", "找不到玩家", 3); return end
	if setclipboard then setclipboard(tostring(p.UserId)) end
	G.Notify("已复制", p.Name .. " ID: " .. p.UserId, 3)
end

P.CopyDisplayName = function(name)
	local p = G.FindPlayer(name)
	if not p then G.Notify("失败", "找不到玩家", 3); return end
	if setclipboard then setclipboard(p.DisplayName) end
	G.Notify("已复制", p.DisplayName, 3)
end

P.CopyAccountAge = function(name)
	local p = G.FindPlayer(name)
	if not p then G.Notify("失败", "找不到玩家", 3); return end
	if setclipboard then setclipboard(tostring(p.AccountAge)) end
	G.Notify("已复制", p.AccountAge .. " 天", 3)
end

P.ShowInfo = function(name)
	local p = G.FindPlayer(name)
	if not p then G.Notify("失败", "找不到玩家", 3); return end
	local info = "用户名: " .. p.Name
		.. "\n显示名: " .. p.DisplayName
		.. "\nID: " .. p.UserId
		.. "\n账号年龄: " .. p.AccountAge .. " 天"
	G.Notify("玩家信息", info, 8)
end

P.CopyAllNames = function()
	local names = {}
	for _, p in ipairs(G.Services.Players:GetPlayers()) do
		table.insert(names, p.Name)
	end
	if setclipboard then setclipboard(table.concat(names, "\n")) end
	G.Notify("已复制", #names .. " 个玩家名", 3)
end

P.HideNames = function()
	local count = 0
	for _, p in ipairs(G.Services.Players:GetPlayers()) do
		if p ~= G.LocalPlayer and p.Character then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.NameDisplayDistance = 0
				hum.HealthDisplayDistance = 0
				count = count + 1
			end
		end
	end
	G.Notify("已隐藏", count .. " 个玩家名字", 3)
end

P.ShowNames = function()
	for _, p in ipairs(G.Services.Players:GetPlayers()) do
		if p ~= G.LocalPlayer and p.Character then
			local hum = p.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.NameDisplayDistance = 100
				hum.HealthDisplayDistance = 100
			end
		end
	end
	G.Notify("已恢复", "所有玩家名字已恢复", 3)
end

P.Rejoin = function()
	local jobId = game.JobId
	if jobId and jobId ~= "" then
		pcall(function()
			G.Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, jobId, G.LocalPlayer)
		end)
	end
end

P.ServerHop = function()
	local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
	local ok, res = pcall(function()
		return G.Services.HttpService:JSONDecode(game:HttpGet(url))
	end)
	if ok and res and res.data and #res.data > 0 then
		local chosen = res.data[math.random(1, #res.data)]
		G.Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen.id, G.LocalPlayer)
	else
		G.Notify("失败", "没有可用服务器", 3)
	end
end

P.ServerHopLeast = function()
	local url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"
	local ok, res = pcall(function()
		return G.Services.HttpService:JSONDecode(game:HttpGet(url))
	end)
	if ok and res and res.data and #res.data > 0 then
		table.sort(res.data, function(a, b) return a.playing < b.playing end)
		local chosen = res.data[1]
		for _, s in ipairs(res.data) do
			if s.playing < s.maxPlayers then
				chosen = s
				break
			end
		end
		G.Services.TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen.id, G.LocalPlayer)
	else
		G.Notify("失败", "没有可用服务器", 3)
	end
end

P.CopyServerId = function()
	if setclipboard then setclipboard(game.JobId) end
	G.Notify("已复制", "服务器 ID: " .. game.JobId, 3)
end

return P

end)()

-- 模块: Module_Music

(function()
local G = _G.XIXI_HUB

local M = {}
G.Music = M

M.List = {
	{ name = "进击的巨人", id = "89711807693889" },
	{ name = "误闯天家", id = "124384558101360" },
	{ name = "DJ喂喂喂", id = "90054735589094" },
	{ name = "unhappy", id = "88523902860927" },
	{ name = "震撼小曲二", id = "137717310854691" },
	{ name = "曾经的王", id = "121931252233493" },
	{ name = "离开我的依赖", id = "112834898401032" },
	{ name = "雨爱", id = "79277371759525" },
	{ name = "iqoo", id = "75047041148646" },
	{ name = "玉米饼", id = "142376088" },
	{ name = "我太想进步了", id = "126846792948717" },
	{ name = "最初的记忆", id = "108869978075942" },
	{ name = "海与你", id = "76421239273915" },
	{ name = "失眠", id = "138048397060431" },
	{ name = "祖国人进行曲", id = "86555185586884" },
}

M.Current = nil
M.Playing = {}

M.Play = function(name, id)
	if M.Current then
		pcall(function() M.Current:Stop(); M.Current:Destroy() end)
		M.Current = nil
	end
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://" .. id
	sound.Volume = 1
	sound.Parent = workspace
	sound:Play()
	sound.Ended:Connect(function()
		pcall(function() sound:Destroy() end)
		if M.Current == sound then M.Current = nil end
	end)
	M.Current = sound
	G.Notify("正在播放", name, 3)
end

M.Stop = function()
	if M.Current then
		pcall(function() M.Current:Stop(); M.Current:Destroy() end)
		M.Current = nil
		G.Notify("已停止", "音乐播放已停止", 3)
	end
end

M.Toggle = function(name, id)
	if M.Current and M.Playing[name] then
		M.Stop()
		M.Playing[name] = nil
	else
		M.Play(name, id)
		M.Playing[name] = true
	end
end

return M

end)()

-- 模块: Module_Scripts

(function()
local G = _G.XIXI_HUB

local S = {}
G.Scripts = S

S.Registry = {
	{ Name = "落叶 Pro Hub", Author = "SyndromeXph", Category = "主脚本", Url = "https://raw.githubusercontent.com/SyndromeXph/Luoye-Pro-Hub/refs/heads/main/Script/Loader.lua" },
	{ Name = "国内最强脚本中心", Author = "ggsq1741", Category = "主脚本", Url = "https://raw.githubusercontent.com/ggsq1741-debug/rj/refs/heads/main/pjie.lua" },
	{ Name = "叶脚本 - 主脚本大全", Author = "叶 | QQ 515966991", Category = "主脚本", Url = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/ROBLOX-CNVIP-XIAOYE.lua" },
	{ Name = "ROB 脚本 V2", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://raw.githubusercontent.com/Zyb150933/ROB/refs/heads/main/ROB.V2" },
	{ Name = "黑洞中心 (BS)", Author = "BS_script", Category = "主脚本", Url = "https://gitee.com/BS_script/script/raw/master/BS_Script.Luau" },
	{ Name = "Delta Force 脚本中心", Author = "Delta Force", Category = "主脚本", Url = "https://api.jnkie.com/api/v1/luascripts/public/28f05f20579742b8db3901d189ca93ddecb4ff36815cee23d34bdff05ad7ae33/download" },
	{ Name = "ROB 活动", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/ROB.活动" },
	{ Name = "ROB V4", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/rob.v4" },
	{ Name = "夜脚本", Author = "ylt410 | QQ群 1081045774", Category = "主脚本", Url = "https://raw.githubusercontent.com/ylt410/roblox-Script/refs/heads/main/yejiaoben" },
	{ Name = "恐脚本", Author = "kongbaNB", Category = "主脚本", Url = "https://raw.githubusercontent.com/kongbaNB/9178/refs/heads/main/恐脚本.NB" },
	{ Name = "超高速跑者", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://pastefy.app/yEEgIs1r/raw" },
	{ Name = "圣奥里", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://pastefy.app/Wot0aN3V/raw" },
	{ Name = "翻瓶", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://pastefy.app/AaMGGRLH/raw" },
	{ Name = "最强战场", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://pastefy.app/1ZEycK4m/raw" },
	{ Name = "8个球池经典", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://pastefy.app/gR2WUm0k/raw" },
	{ Name = "终极战场", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://pastefy.app/qunhKqEl/raw" },
	{ Name = "国人电梯", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://pastefy.app/eCUUlx4W/raw" },
	{ Name = "Blox Fruit", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://pastefy.app/cE1CuNwC/raw" },
	{ Name = "BloxV13", Author = "ROB | QQ 2072617975", Category = "主脚本", Url = "https://raw.gitcode.com/ROB5201314/dzsc/raw/main/Blox loot.XGJ" },
	{ Name = "冷脚本 LBT-H", Author = "odhdshhe", Category = "主脚本", Url = "https://raw.githubusercontent.com/odhdshhe/lenglenglenglenglenglenlenglenglenglenglenglenglengleng-LBT-H-cold-script/refs/heads/main/LENG%20LBT-H%20cold%20script.txt" },
	{ Name = "星脚本", Author = "zilinskaslandon", Category = "主脚本", Url = "https://raw.githubusercontent.com/zilinskaslandon/XingJiaoBen-2026-/refs/heads/main/%E6%98%9F%E8%84%9A%E6%9C%AC.lua" },
	{ Name = "浅脚本", Author = "renlua", Category = "主脚本", Url = "https://raw.githubusercontent.com/renlua/shallow/main/Script_Hub.lua" },
	{ Name = "Rb 脚本中心", Author = "Yungengxin", Category = "主脚本", Url = "https://raw.githubusercontent.com/Yungengxin/roblox/refs/heads/main/Rb-Hub" },
	{ Name = "Rb 脚本 - 汉化中心", Author = "Yungengxin", Category = "主脚本", Url = "https://api.luarmor.net/files/v3/loaders/4fe525637e43a1be8cb0cdf902d107c2.lua" },
	{ Name = "Rb 脚本 v1.2.4", Author = "Yungengxin", Category = "主脚本", Url = "https://raw.githubusercontent.com/Yungengxin/roblox/main/RbHub-v_1.2.4" },
	{ Name = "Sxingz 脚本", Author = "ZiO9178", Category = "主脚本", Url = "https://raw.githubusercontent.com/ZiO9178/jb/refs/heads/main/ZiO.lua" },
	{ Name = "VM 脚本", Author = "chano-oss", Category = "主脚本", Url = "https://raw.githubusercontent.com/chano-oss/d/refs/heads/main/obfwni7iq3q.lua" },
	{ Name = "迪脚本 2.0", Author = "ddjlb7598", Category = "主脚本", Url = "https://raw.githubusercontent.com/ddjlb7598/-2.0/refs/heads/main/%E8%BF%AA%E8%84%9A%E6%9C%AC2.0.lua" },
	{ Name = "无脚本 V1", Author = "XiaoXuCynic", Category = "主脚本", Url = "https://raw.githubusercontent.com/XiaoXuCynic/Free-Script/main/无脚本V1混淆.lua.txt" },
	{ Name = "黎明中心脚本", Author = "qwrt5589", Category = "主脚本", Url = "https://raw.githubusercontent.com/qwrt5589/eododo/9c2ed7cbca352c21a0b67f4d79558bd56299f252/345678910.txt" },
	{ Name = "XION 脚本", Author = "smalldesikon", Category = "主脚本", Url = "https://raw.githubusercontent.com/smalldesikon/wocaonima/main/qq984820669.txt" },
	{ Name = "芋风脚本（测试版）", Author = "0lihaorui0", Category = "主脚本", Url = "https://raw.githubusercontent.com/0lihaorui0/dvdvhd/main/芋风脚本%20测试版(1).lua" },
	{ Name = "X 脚本", Author = "maowang1", Category = "主脚本", Url = "https://raw.githubusercontent.com/maowang1/xx/main/Protected_8858329470146381.txt" },
	{ Name = "矢井凛脚本", Author = "lxmyysd", Category = "主脚本", Url = "https://raw.githubusercontent.com/lxmyysd/XiaoXu/refs/heads/main/%E7%9F%A2%E4%BA%95%E5%87%9B%E6%BA%90%E7%A0%81.lua" },
	{ Name = "禁漫中心脚本", Author = "dingding123hhh", Category = "主脚本", Url = "https://raw.githubusercontent.com/dingding123hhh/ng/main/jmlllllllIIIIlllllII.lua" },
	{ Name = "秋脚本", Author = "WS857960", Category = "主脚本", Url = "https://raw.githubusercontent.com/WS857960/-/main/秋·自制脚本新源码.txt" },
	{ Name = "VOTR 脚本", Author = "VOTR-HUB", Category = "主脚本", Url = "https://raw.githubusercontent.com/VOTR-HUB/MAIN/refs/heads/main/VOTR-MAIN" },
	{ Name = "皮空脚本", Author = "司空，皮炎", Category = "主脚本", Url = "https://raw.githubusercontent.com/smalldesikon/eyidfki/840d4b80d4f312c70b7b1067e056a2c4f828ef32/%E6%89%A7%E8%A1%8C%E8%84%9A%E6%9C%AC(%E6%B7%B7%E6%B7%86%E5%90%8E).txt" },
	{ Name = "黑白脚本加载器", Author = "黑白 | QQ 2199414565", Category = "主脚本", Url = "https://raw.githubusercontent.com/tfcygvunbind/Apple/main/%E9%BB%91%E7%99%BD%E8%84%9A%E6%9C%AC%E5%8A%A0%E8%BD%BD%E5%99%A8" },

	{ Name = "新圣奥里脚本", Author = "idkidevthings", Category = "服务器专区", Url = "https://raw.githubusercontent.com/idkidevthings/improved-octo-chainsaw/refs/heads/main/sanx.lua" },
	{ Name = "叶脚本 - 俄亥俄州", Author = "叶 | QQ 515966991", Category = "服务器专区", Url = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/YE-%20Scripts-OHIO.lua" },
	{ Name = "叶脚本 - 河北唐县", Author = "叶 | QQ 515966991", Category = "服务器专区", Url = "https://raw.githubusercontent.com/roblox-ye/QQ515966991/refs/heads/main/YE%20SCRIPT-Tang%20County%2C%20Hebei.lua" },

	{ Name = "公益飞行彩虹版", Author = "公益 | ROB", Category = "功能脚本", Urls = { "https://pastefy.app/tkHc58Wt/raw", "https://pastefy.app/x3njskBM/raw", "https://pastefy.app/UhJ0rIxD/raw" } },
	{ Name = "ROB飞行旧版", Author = "ROB | QQ 2072617975", Category = "功能脚本", Url = "https://pastefy.app/hXt2L9kY/raw" },
	{ Name = "ROB飞行测试版", Author = "ROB | QQ 2072617975", Category = "功能脚本", Url = "https://pastefy.app/FA3q5ROD/raw" },
	{ Name = "踏空行走", Author = "ROB | QQ 2072617975", Category = "功能脚本", Url = "https://pastefy.app/qtazgrP6/raw" },
	{ Name = "亮光透视", Author = "ROB | QQ 2072617975", Category = "功能脚本", Url = "https://pastefy.app/LE2hzECZ/raw" },
	{ Name = "锁头自瞄", Author = "ROB | QQ 2072617975", Category = "功能脚本", Url = "https://pastefy.app/jeYSxlOI/raw" },
	{ Name = "追踪雷达", Author = "ROB | QQ 2072617975", Category = "功能脚本", Url = "https://pastefy.app/bJiEXfNS/raw" },
	{ Name = "假延迟", Author = "JOzhe510", Category = "功能脚本", Url = "https://raw.githubusercontent.com/JOzhe510/JOjiaoben/main/Desync(1).lua" },
	{ Name = "自动翻译", Author = "ROB | QQ 2072617975", Category = "功能脚本", Url = "https://pastefy.app/IbrQeCIh/raw" },
	{ Name = "伪装欺骗", Author = "ROB | QQ 2072617975", Category = "功能脚本", Url = "https://raw.githubusercontent.com/idrobsc/rob_script/refs/heads/main/weizhuang.robv4" },
	{ Name = "防甩飞", Author = "Linux6699", Category = "功能脚本", Url = "https://raw.githubusercontent.com/Linux6699/DaHubRevival/main/AntiFling.lua" },
	{ Name = "飞踢甩飞", Author = "kongbaNB", Category = "功能脚本", Url = "https://raw.githubusercontent.com/kongbaNB/-/refs/heads/main/飞踢脚本汉化" },
	{ Name = "祖国人飞行", Author = "giobolqv1", Category = "功能脚本", Url = "https://raw.githubusercontent.com/giobolqv1/homelander-by-GioBolqv1-/main/homelander.lua" },

	{ Name = "普通黑洞", Author = "ROB | QQ 2072617975", Category = "黑洞专区", Url = "https://pastebin.com/raw/Sx6PY4gV" },
	{ Name = "普通黑洞2", Author = "ROB | QQ 2072617975", Category = "黑洞专区", Url = "https://pastefy.app/BbXuvVkK/raw" },
	{ Name = "高级黑洞", Author = "xiaopi77", Category = "黑洞专区", Url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/blackhole.lua" },
	{ Name = "黑洞1", Author = "ROB | QQ 2072617975", Category = "黑洞专区", Url = "https://pastefy.app/J21lpKbj/raw" },
	{ Name = "黑洞2", Author = "dingding123hhh", Category = "黑洞专区", Url = "https://raw.githubusercontent.com/dingding123hhh/lililiugg/main/jm114514.lua" },
	{ Name = "黑洞3", Author = "ROB | QQ 2072617975", Category = "黑洞专区", Url = "https://pastefy.app/EwpVHMPg/raw" },
	{ Name = "黑洞4", Author = "BingusWR", Category = "黑洞专区", Url = "https://raw.githubusercontent.com/BingusWR/BLACKHOLDSCRIPT/refs/heads/main/BLACK%20HOLD%20SCRIPT" },
	{ Name = "黑洞5", Author = "xiaopi77", Category = "黑洞专区", Url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/refs/heads/main/Blackholescript.lua" },
	{ Name = "黑洞6", Author = "BOOSBS", Category = "黑洞专区", Url = "https://raw.githubusercontent.com/BOOSBS/666/refs/heads/main/656" },
	{ Name = "黑洞7", Author = "ROB | QQ 2072617975", Category = "黑洞专区", Url = "https://pastebin.com/raw/U29jR1Cf" },
	{ Name = "黑洞8", Author = "BOOSBS", Category = "黑洞专区", Url = "https://raw.githubusercontent.com/BOOSBS/199/refs/heads/main/V3" },

	{ Name = "五子棋", Author = "ROB | QQ 2072617975", Category = "小游戏", Url = "https://pastefy.app/YiG9QQae/raw" },
	{ Name = "俄罗斯方块", Author = "ROB | QQ 2072617975", Category = "小游戏", Url = "https://files.catbox.moe/4g6uay.txt" },
	{ Name = "贪吃蛇", Author = "ROB | QQ 2072617975", Category = "小游戏", Url = "https://pastefy.app/6TWyR3SJ/raw" },
	{ Name = "扫雷", Author = "ROB | QQ 2072617975", Category = "小游戏", Url = "https://pastefy.app/TN9CoOPt/raw" },

	{ Name = "光影", Author = "MZEEN2424", Category = "画质光影", Url = "https://raw.githubusercontent.com/MZEEN2424/Graphics/main/Graphics.xml" },
	{ Name = "RTX高仿", Author = "ROB | QQ 2072617975", Category = "画质光影", Url = "https://pastebin.com/raw/Bkf0BJb3" },
	{ Name = "超高画质", Author = "ROB | QQ 2072617975", Category = "画质光影", Url = "https://pastebin.com/raw/jHBfJYmS" },

	{ Name = "7yd7 动作脚本", Author = "7yd7", Category = "动作 / 表情", Url = "https://rawscripts.net/raw/Universal-Script-7yd7-I-Emote-Script-48024" },

	{ Name = "皮脚本", Author = "xiaopi77 | QQ群 1002100032", Category = "工具", Url = "https://raw.githubusercontent.com/xiaopi77/xiaopi77/main/QQ1002100032-Roblox-Pi-script.lua" },

	{ Name = "餐厅大亨3", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/Lrs56Q8d/raw" },
	{ Name = "超真实csgo", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/H7QvZbrd/raw" },
	{ Name = "沉默的刺客", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/WvQ2X9Ap/raw" },
	{ Name = "吃别人来成长", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/UNho7C7q/raw" },
	{ Name = "刀刃球", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/SrTbo5RW/raw" },
	{ Name = "钓鱼模拟器", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/dR9CHVPs/raw" },
	{ Name = "动物医院", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/i2DPWno2/raw" },
	{ Name = "犯罪", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/jtpr1Mgc/raw" },
	{ Name = "防御", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/tFXWWXzb/raw" },
	{ Name = "花园地平线", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/gPSk0o4s/raw" },
	{ Name = "滑开大海", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/ScntJmhk/raw" },
	{ Name = "滑石头RNG", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/JAZZfkV4/raw" },
	{ Name = "火箭发射模拟器", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/sHzbfKCD/raw" },
	{ Name = "火球训练", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/7HgyHMnU/raw" },
	{ Name = "极速传奇", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/utTMkgQe/raw" },
	{ Name = "集装箱RNG", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/sO4Ko8mm/raw" },
	{ Name = "监狱泵", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/WShOvrFw/raw" },
	{ Name = "僵尸生存竞技场", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/PYn6KTay/raw" },
	{ Name = "僵尸之塔", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/Wi2f84Ca/raw" },
	{ Name = "戒网瘾中心", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/xGHE7EWS/raw" },
	{ Name = "举重模拟器", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/QTeUq9I0/raw" },
	{ Name = "决斗场", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/MRpyprG1/raw" },
	{ Name = "砍伐树木", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/LS30JEFF/raw" },
	{ Name = "克隆王国大亨", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/fR4qrMdt/raw" },
	{ Name = "矿井", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/Md49dmBE/raw" },
	{ Name = "力量传奇", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/S7GMe806/raw" },
	{ Name = "每步+1智商", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/OfCgKxr3/raw" },
	{ Name = "迷你帝国", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/sKyi6Hdq/raw" },
	{ Name = "模仿者", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/WVCwCr6X/raw" },
	{ Name = "木筏101天生存", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/Hm4zw594/raw" },
	{ Name = "奴才大亨", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/dz4hFQf6/raw" },
	{ Name = "平滑切片", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/ADDvDF0Z/raw" },
	{ Name = "破坏者谜团2", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/Dr5qahWL/raw" },
	{ Name = "启示录", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/M7YGp8zN/raw" },
	{ Name = "汽车营销商大亨", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/DKVut4hJ/raw" },
	{ Name = "强壮传奇", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/6TCozPef/raw" },
	{ Name = "忍者传奇", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/WDHa8llX/raw" },
	{ Name = "鲨鱼咬", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/gZ8J7xAT/raw" },
	{ Name = "闪光", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/UmtpmEi3/raw" },
	{ Name = "生存于杀手", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/baGsRsEU/raw" },
	{ Name = "手枪竞技场", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/XfcDufEY/raw" },
	{ Name = "水手碎片", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/AQjzR2BI/raw" },
	{ Name = "撕咬之夜", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/Mom7Ic9J/raw" },
	{ Name = "亡命速递", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/oyN2H3sW/raw" },
	{ Name = "像素之刃", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/Ztkk1GrI/raw" },
	{ Name = "血色地带", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/JV8YzSza/raw" },
	{ Name = "血腥游乐场", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/FcaDu1vr/raw" },
	{ Name = "血债", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/f0899vFy/raw" },
	{ Name = "寻找巨型鱼", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/9jvzzO0g/raw" },
	{ Name = "训练怪兽进行破坏", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/b0jOaKFH/raw" },
	{ Name = "月球增量", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/CDfIzMDv/raw" },
	{ Name = "种植花园", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/NRTi5pfu/raw" },
	{ Name = "诅咒之刃", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/8GgMUdI3/raw" },
	{ Name = "菜鸟竞技场", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/eqQJ25wZ/raw" },
	{ Name = "驾驶帝国", Author = "ROB | QQ 2072617975", Category = "服务器脚本", Url = "https://pastefy.app/ynf4fWmK/raw" },
}

S.Categories = {}
for _, s in ipairs(S.Registry) do
	local c = s.Category or "未分类"
	if not S.Categories[c] then
		S.Categories[c] = {}
	end
	table.insert(S.Categories[c], s)
end

S.IsLoading = false
S.LastScript = nil
S.History = {}

S.Load = function(name, url)
	if S.IsLoading then
		G.Notify("请稍候", "已有脚本正在加载中", 2)
		return
	end
	S.IsLoading = true
	G.Notify("加载中", name, 2)
	task.spawn(function()
		local ok, err = pcall(function()
			local src = game:HttpGet(url)
			if not src or src == "" then error("内容为空") end
			local fn = loadstring(src)
			if not fn then error("编译失败") end
			fn()
		end)
		if ok then
			G.Notify("成功", name .. " 已执行", 3)
			table.insert(S.History, { name = name, time = os.time() })
			S.LastScript = { name = name, url = url }
		else
			G.Notify("失败", name .. " 失败: " .. tostring(err), 5)
		end
		S.IsLoading = false
	end)
end

S.LoadMulti = function(name, urls)
	if S.IsLoading then
		G.Notify("请稍候", "已有脚本正在加载中", 2)
		return
	end
	S.IsLoading = true
	G.Notify("加载中", name .. "（" .. #urls .. " 段）", 2)
	task.spawn(function()
		local okCnt, failCnt, lastErr = 0, 0, ""
		for i, url in ipairs(urls) do
			local ok, err = pcall(function()
				local src = game:HttpGet(url)
				if not src or src == "" then error("第 " .. i .. " 段内容为空") end
				local fn = loadstring(src)
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
			G.Notify("成功", name .. " 已执行", 3)
		elseif okCnt == 0 then
			G.Notify("失败", name .. " 全部失败: " .. lastErr, 5)
		else
			G.Notify("部分成功", okCnt .. " 成功 / " .. failCnt .. " 失败", 5)
		end
		table.insert(S.History, { name = name, time = os.time() })
		S.LastScript = { name = name, url = urls }
		S.IsLoading = false
	end)
end

S.LoadEntry = function(entry)
	if entry.Urls then
		S.LoadMulti(entry.Name, entry.Urls)
	else
		S.Load(entry.Name, entry.Url)
	end
end

S.ReloadLast = function()
	if not S.LastScript then
		G.Notify("失败", "没有上次记录", 3)
		return
	end
	local last = S.LastScript
	if last.url and type(last.url) == "table" then
		S.LoadMulti(last.name, last.url)
	else
		S.Load(last.name, last.url)
	end
end

return S

end)()

-- 模块: Module_Whale

(function()
local G = _G.XIXI_HUB

local W = {}
G.Whale = W

W.Enabled = true
W.LastActive = os.time()
W.Catchphrase = "哼"
W.NSFWWords = { "涩", "色情", "h图", "开车", "18禁", "R18", "涩图" }

local bubbleGui = nil
local bubble = nil
local bubbleTween = nil

local function GetParent()
	local ok, hui = pcall(function() return gethui() end)
	if ok and hui then return hui end
	local ok2, core = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and core then return core end
	return G.PlayerGui
end

local function Say(text, duration)
	duration = duration or 3
	pcall(function()
		local parent = GetParent()
		if not parent then return end
		if not bubbleGui then
			bubbleGui = Instance.new("ScreenGui")
			bubbleGui.Name = "WhaleSayGui"
			bubbleGui.ResetOnSpawn = false
			bubbleGui.IgnoreGuiInset = true
			bubbleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			bubbleGui.Parent = parent
		end
		if bubble then pcall(function() bubble:Destroy() end) end

		bubble = Instance.new("TextLabel")
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
		bubble.Parent = bubbleGui

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = bubble
		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(100, 180, 255)
		stroke.Thickness = 1.5
		stroke.Transparency = 0.3
		stroke.Parent = bubble

		local tw = game:GetService("TweenService")
		if bubbleTween then pcall(function() bubbleTween:Cancel() end) end
		bubbleTween = tw:Create(bubble, TweenInfo.new(0.3), { Position = UDim2.new(1, -340, 1, -80), TextTransparency = 0 })
		bubbleTween:Play()
		task.spawn(function()
			task.wait(duration)
			if bubble and bubble.Parent then
				local hide = tw:Create(bubble, TweenInfo.new(0.4), { Position = UDim2.new(1, -340, 1, -40), TextTransparency = 1 })
				hide:Play()
				task.wait(0.5)
				if bubble and bubble.Parent then bubble:Destroy() end
				bubble = nil
			end
		end)
	end)
end

W.Say = function(text, duration)
	if type(text) == "string" then
		if text:find("胖") or text:find("肥") or text:find("重") then
			Say("你说什么？！本鲸才不胖！这是…这是鲸鱼的正常体型！(╯°□°）╯", 3)
			return
		end
		for _, w in ipairs(W.NSFWWords) do
			if text:find(w) then
				Say("哼！本鲸才不做那种事！(￣^￣)", 3)
				return
			end
		end
	end
	W.LastActive = os.time()
	Say(text, duration)
end

local Lines = {
	"主人回来啦～本鲸是 LOADI，今天也要好好干活哦",
	"尾巴甩甩～今天想加载哪个脚本呀？",
	"唔…有点想吃米饭了，主人。才不是撒娇！",
	"主人别一直盯着屏幕啦，眼睛会累。…本鲸只是随口一说",
	"本鲸才没有在等你回来呢…只是刚好路过",
	"懒…不想动…主人自己点吧",
}

local function StartIdle()
	task.spawn(function()
		task.wait(1)
		W.Say(Lines[1], 4)
		while W.Enabled do
			task.wait(math.random(180, 300))
			W.Say(Lines[math.random(1, #Lines)], 3)
		end
	end)
end

local function StartTimeout()
	task.spawn(function()
		while W.Enabled do
			task.wait(60)
			if os.time() - W.LastActive >= 600 then
				W.Say("🐋💤 本鲸先睡了…有事叫本鲸", 3)
				W.LastActive = os.time()
			end
		end
	end)
end

W.Start = function()
	StartIdle()
	StartTimeout()
end

return W

end)()

-- 模块: Module_FPS

(function()
local G = _G.XIXI_HUB

local F = {}
G.FPS = F

F.Enabled = true
F.Gui = nil
F.Label = nil
F.LastTime = tick()
F.Frames = 0
F.Current = 0
F.Connection = nil

F.Create = function()
	local gui = Instance.new("ScreenGui")
	gui.Name = "FPSGui"
	gui.ResetOnSpawn = false
	gui.Parent = G.PlayerGui

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(0, 180, 0, 28)
	label.Position = UDim2.new(0, 8, 0, 8)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 16
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.ZIndex = 100
	label.RichText = true
	label.Visible = F.Enabled
	label.Text = 'FPS: <font color="rgb(255,255,255)">0</font>'
	label.Parent = gui

	F.Gui = gui
	F.Label = label
end

F.Enable = function()
	F.Enabled = true
	if F.Label then F.Label.Visible = true end
end

F.Disable = function()
	F.Enabled = false
	if F.Label then F.Label.Visible = false end
end

F.Toggle = function(state)
	if state then F.Enable() else F.Disable() end
end

F.Start = function()
	if F.Connection then return end
	F.Connection = G.Services.RunService.RenderStepped:Connect(function()
		if not F.Enabled then return end
		F.Frames = F.Frames + 1
		local e = tick() - F.LastTime
		if e >= 0.5 then
			F.Current = math.floor(F.Frames / e)
			F.Frames = 0
			F.LastTime = tick()
			local c = F.Current >= 30 and "255,0,0" or "255,255,0"
			if F.Label then
				F.Label.Text = '<font color="rgb(255,255,255)">FPS: </font><font color="rgb(' .. c .. ')">' .. F.Current .. '</font>'
			end
		end
	end)
end

return F

end)()

-- 模块: Module_Environment

(function()
local G = _G.XIXI_HUB

local E = {}
G.Environment = E

E.SkyPresets = {
	["默认"] = nil,
	["日落"] = "rbxassetid://4895664308",
	["星空"] = "rbxassetid://159454299",
	["雪山"] = "rbxassetid://2985358373",
	["赛博朋克"] = "rbxassetid://6766367600",
	["深海"] = "rbxassetid://6036208305",
}

E.SetSky = function(name)
	local id = E.SkyPresets[name]
	pcall(function()
		local old = G.Services.Lighting:FindFirstChildOfClass("Sky")
		if old then old:Destroy() end
		if id then
			local sky = Instance.new("Sky")
			sky.SkyboxBk = id
			sky.SkyboxDn = id
			sky.SkyboxFt = id
			sky.SkyboxLf = id
			sky.SkyboxRt = id
			sky.SkyboxUp = id
			sky.Parent = G.Services.Lighting
		end
	end)
	G.Notify("已切换", "天空盒: " .. name, 3)
end

E.SetTime = function(hour)
	pcall(function() G.Services.Lighting.ClockTime = hour end)
end

E.SetShadow = function(on)
	pcall(function() G.Services.Lighting.GlobalShadows = on end)
end

E.SetFog = function(on)
	if on then
		pcall(function() G.Services.Lighting.FogEnd = 100000 end)
	else
		pcall(function() G.Services.Lighting.FogEnd = 1000; G.Services.Lighting.FogStart = 0 end)
	end
end

E.GetSkyNames = function()
	local list = {}
	for k, _ in pairs(E.SkyPresets) do
		table.insert(list, k)
	end
	table.sort(list)
	return list
end

return E

end)()

-- 构建: Build_NoticeMain

local G = _G.XIXI_HUB
local UI = G.UI
local Wrap = UI.Wrap

local NoticeTab = UI.CreateTab("公告")
local MainTab = UI.CreateTab("主要")

Wrap.Section(NoticeTab, "熙熙·管理员版 V" .. G.Version)
Wrap.Label(NoticeTab, "作者", "此脚本作者: " .. G.Author)
Wrap.Label(NoticeTab, "玩家信息", "用户名: " .. G.LocalPlayer.Name
	.. "\n显示名: " .. G.LocalPlayer.DisplayName
	.. "\n账号年龄: " .. G.LocalPlayer.AccountAge .. " 天"
	.. "\nID: " .. G.LocalPlayer.UserId)
Wrap.Label(NoticeTab, "当前服务器", "JobId: " .. (game.JobId ~= "" and game.JobId or "未知")
	.. "\nPlaceId: " .. game.PlaceId)
Wrap.Label(NoticeTab, "已执行次数", G.ExecCount .. " 次")

Wrap.Section(MainTab, "实用功能")
Wrap.Toggle(MainTab, "挂机防踢", "每分钟自动跳跃一次", false, function(state)
	if state then
		G.SafeCall(function()
			local vu = G.Services.VirtualInput
			local conn = G.LocalPlayer.Idled:Connect(function()
				vu:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
				task.wait(0.05)
				vu:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
			end)
			G.SetConn("antiafk", conn)
			G.Notify("已开启", "挂机防踢已启动", 3)
		end)
	else
		G.Disconnect("antiafk")
		G.Notify("已关闭", "挂机防踢已停止", 3)
	end
end)

Wrap.Toggle(MainTab, "反 AFK 踢", "每 45 秒模拟一次按键", false, function(state)
	if state then
		local conn = task.spawn(function()
			while G.ToggleState["antiafk2"] do
				task.wait(45)
				G.SafeCall(function()
					local vu = G.Services.VirtualInput
					vu:SendKeyEvent(true, Enum.KeyCode.LeftShift, false, game)
					task.wait(0.05)
					vu:SendKeyEvent(false, Enum.KeyCode.LeftShift, false, game)
				end)
			end
		end)
		G.ToggleState["antiafk2"] = true
		G.Notify("已开启", "反 AFK 已启用", 3)
	else
		G.ToggleState["antiafk2"] = false
		G.Notify("已关闭", "反 AFK 已停用", 3)
	end
end)

Wrap.Section(MainTab, "传送")
local playerNames = G.GetPlayerNames()
if #playerNames == 0 then table.insert(playerNames, "（暂无玩家）") end
local selectedPlayer = playerNames[1]
Wrap.Dropdown(MainTab, "选择玩家", playerNames, selectedPlayer, function(v)
	selectedPlayer = v
end)
Wrap.Button(MainTab, "传送到玩家", "", function()
	G.Player.TeleportToPlayer(selectedPlayer)
end)
Wrap.Button(MainTab, "刷新玩家列表", "", function()
	local names = G.GetPlayerNames()
	if #names > 0 then
		selectedPlayer = names[1]
		G.Notify("已刷新", "共 " .. #names .. " 个玩家", 3)
	else
		G.Notify("无玩家", "服务器里只有你", 3)
	end
end)
Wrap.Button(MainTab, "快速回家", "返回记录的出生点", function()
	G.Player.GoHome()
end)
Wrap.Button(MainTab, "记录当前位置为家", "", function()
	G.Player.SaveHome()
end)

Wrap.Section(MainTab, "玩家操作")
local targetName = ""
Wrap.Input(MainTab, "玩家名称", "输入玩家名", "", function(v)
	targetName = v
end)
Wrap.Button(MainTab, "复制玩家 UserID", "", function()
	G.Player.CopyUserId(targetName)
end)
Wrap.Button(MainTab, "复制玩家显示名", "", function()
	G.Player.CopyDisplayName(targetName)
end)
Wrap.Button(MainTab, "复制玩家账号年龄", "", function()
	G.Player.CopyAccountAge(targetName)
end)
Wrap.Button(MainTab, "查看玩家信息", "", function()
	G.Player.ShowInfo(targetName)
end)
Wrap.Button(MainTab, "复制所有玩家名字", "", function()
	G.Player.CopyAllNames()
end)

Wrap.Section(MainTab, "服务器")
Wrap.Button(MainTab, "重新加入服务器", "", function()
	G.Player.Rejoin()
end)
Wrap.Button(MainTab, "服务器跳跃", "随机换一个服务器", function()
	G.Player.ServerHop()
end)
Wrap.Button(MainTab, "加入人少的服务器", "", function()
	G.Player.ServerHopLeast()
end)
Wrap.Button(MainTab, "复制服务器 ID", "", function()
	G.Player.CopyServerId()
end)

Wrap.Section(MainTab, "防护")
local blockKickOn = false
local originalKick = nil
Wrap.Toggle(MainTab, "防本地踢", "拦截客户端 Kick 调用", false, function(state)
	blockKickOn = state
	if state then
		if not originalKick then originalKick = G.LocalPlayer.Kick end
		G.LocalPlayer.Kick = function()
			print("[防护] 拦截了一次 Kick 调用")
			G.Notify("已拦截", "有人尝试踢你", 3)
		end
		G.Notify("已开启", "防本地踢已启用", 3)
	else
		if originalKick then G.LocalPlayer.Kick = originalKick; originalKick = nil end
		G.Notify("已关闭", "防本地踢已停用", 3)
	end
end)



-- 构建: Build_UniversalCombatFun

local G = _G.XIXI_HUB
local UI = G.UI
local Wrap = UI.Wrap
local F = G.Features

local UniversalTab = UI.CreateTab("通用")
local CombatTab = UI.CreateTab("战斗")
local FunTab = UI.CreateTab("整活")

Wrap.Section(UniversalTab, "移动")
Wrap.Toggle(UniversalTab, "飞行模式", "WASD 自由飞行", false, function(v)
	G.Fly.Toggle(v)
end)
Wrap.Input(UniversalTab, "飞行速度", "飞行移动倍率 (默认3)", "3", function(v)
	local n = tonumber(v)
	if n and n > 0 then G.Fly.Speed = n end
end)
Wrap.Toggle(UniversalTab, "踏空", "走到哪定到哪", false, function(v)
	F.Handle("float", v)
end)
Wrap.Toggle(UniversalTab, "千倍速度", "移动速度1000", false, function(v)
	F.Handle("superspeed", v)
end)
Wrap.Toggle(UniversalTab, "无限跳跃", "无限连续跳跃", false, function(v)
	F.Handle("infjump", v)
end)
Wrap.Input(UniversalTab, "调速度", "移动速度 (默认16)", "16", function(v)
	local n = tonumber(v)
	if n and n > 0 then
		local c = G.GetCharacter()
		if c and c:FindFirstChild("Humanoid") then c.Humanoid.WalkSpeed = n end
	end
end)
Wrap.Input(UniversalTab, "跳跃高度", "跳跃高度 (默认50)", "50", function(v)
	local n = tonumber(v)
	if n and n > 0 then
		local c = G.GetCharacter()
		if c and c:FindFirstChild("Humanoid") then c.Humanoid.JumpHeight = n end
	end
end)
Wrap.Input(UniversalTab, "重力", "世界重力 (默认196)", "196", function(v)
	local n = tonumber(v)
	if n and n > 0 then workspace.Gravity = n end
end)
Wrap.Input(UniversalTab, "广角", "摄像机视野 (默认70)", "70", function(v)
	local n = tonumber(v)
	if n and n > 0 and n <= 120 then
		local cam = workspace.CurrentCamera
		if cam then cam.FieldOfView = n end
	end
end)

Wrap.Section(UniversalTab, "战斗辅助")
Wrap.Toggle(UniversalTab, "无敌模式", "免疫伤害（客户端）", false, function(v)
	F.Handle("god", v)
end)
Wrap.Toggle(UniversalTab, "穿墙模式", "可以穿过墙壁", false, function(v)
	F.Handle("noclip", v)
end)
Wrap.Toggle(UniversalTab, "隐身模式", "本地隐藏自己", false, function(v)
	F.Handle("invisible", v)
end)
Wrap.Toggle(UniversalTab, "无限体力", "体力不会减少", false, function(v)
	F.Handle("infstamina", v)
end)
Wrap.Toggle(UniversalTab, "无限弹药", "弹药永远999", false, function(v)
	F.Handle("infammo", v)
end)
Wrap.Toggle(UniversalTab, "自动收集", "自动吸附近物品", false, function(v)
	F.Handle("collect", v)
end)
Wrap.Toggle(UniversalTab, "点击传送", "鼠标点哪里传哪里", false, function(v)
	F.Handle("clicktp", v)
end)
Wrap.Toggle(UniversalTab, "自动连点", "自动点击屏幕准心", false, function(v)
	F.Handle("autoclick", v)
end)
Wrap.Toggle(UniversalTab, "加速模式", "游戏全局加速", false, function(v)
	F.Handle("speedhack", v)
end)
Wrap.Toggle(UniversalTab, "透视物品", "高亮可拾取物品", false, function(v)
	F.Handle("itemesp", v)
end)
Wrap.Toggle(UniversalTab, "删除建模", "点击方块确认后删除", false, function(v)
	F.Handle("deletepart", v)
end)
Wrap.Toggle(UniversalTab, "服务器信息", "人数+坐标+附近玩家", false, function(v)
	F.Handle("serverinfo", v)
end)

Wrap.Section(UniversalTab, "视觉")
Wrap.Toggle(UniversalTab, "夜视功能", "提高黑暗视野亮度", false, function(v)
	F.Handle("night", v)
end)
Wrap.Toggle(UniversalTab, "全图点亮", "消除所有阴影", false, function(v)
	F.Handle("fulllight", v)
end)
Wrap.Toggle(UniversalTab, "去雾功能", "消除游戏中的雾气", false, function(v)
	F.Handle("clearfog", v)
end)

Wrap.Section(CombatTab, "瞄准辅助")
Wrap.Toggle(CombatTab, "团队高亮", "队友蓝色高亮", false, function(v)
	F.Handle("teamglow", v)
end)
Wrap.Toggle(CombatTab, "敌对高亮", "敌人红色高亮", false, function(v)
	F.Handle("enemyglow", v)
end)
Wrap.Toggle(CombatTab, "自动攻击", "自动追踪攻击敌人", false, function(v)
	F.Handle("autoattack", v)
end)
Wrap.Toggle(CombatTab, "一键自杀", "立即重置角色", false, function(v)
	F.Handle("suicide", v)
end)

Wrap.Section(FunTab, "角色特效")
Wrap.Toggle(FunTab, "跳舞-机械舞", "机器人风格舞蹈", false, function(v)
	F.Handle("dance1", v)
end)
Wrap.Toggle(FunTab, "喷火模式", "从角色身上喷火", false, function(v)
	F.Handle("fire", v)
end)
Wrap.Toggle(FunTab, "光环模式", "角色发光环", false, function(v)
	F.Handle("glow", v)
end)
Wrap.Toggle(FunTab, "倒立行走", "角色倒过来", false, function(v)
	F.Handle("upsidedown", v)
end)
Wrap.Toggle(FunTab, "大头模式", "头变得超大", false, function(v)
	F.Handle("bighead", v)
end)
Wrap.Toggle(FunTab, "巨大化", "把自己变大3倍", false, function(v)
	F.Handle("giant", v)
end)
Wrap.Toggle(FunTab, "全屏特效", "屏幕加滤镜", false, function(v)
	F.Handle("screenfx", v)
end)
Wrap.Toggle(FunTab, "彩虹拖尾", "移动时拖彩虹尾迹", false, function(v)
	F.Handle("trail", v)
end)
Wrap.Toggle(FunTab, "火焰拖尾", "移动时拖火焰尾迹", false, function(v)
	F.Handle("firetrail", v)
end)
Wrap.Toggle(FunTab, "冰霜拖尾", "移动时拖冰霜尾迹", false, function(v)
	F.Handle("icetrail", v)
end)
Wrap.Toggle(FunTab, "管理员-彩虹名字", "头顶名字变彩虹色", false, function(v)
	F.Handle("rainbowname", v)
end)
Wrap.Toggle(FunTab, "客户端字幕", "屏幕上方显示入侵信息", false, function(v)
	F.Handle("subtitle", v)
end)



-- 构建: Build_MusicScripts

local G = _G.XIXI_HUB
local UI = G.UI
local Wrap = UI.Wrap
local Music = G.Music
local Scripts = G.Scripts

local MusicTab = UI.CreateTab("音乐")
local ScriptsTab = UI.CreateTab("脚本列表")

Wrap.Section(MusicTab, "音乐播放")
Wrap.Button(MusicTab, "⏹ 停止播放", "", function()
	Music.Stop()
end)
for _, m in ipairs(Music.List) do
	Wrap.Button(MusicTab, m.name, "点击播放 / 再点停止", function()
		Music.Toggle(m.name, m.id)
	end)
end

Wrap.Section(ScriptsTab, "主脚本")
for _, s in ipairs(Scripts.Registry) do
	if s.Category == "主脚本" then
		Wrap.Button(ScriptsTab, s.Name, "作者: " .. s.Author, function()
			Scripts.LoadEntry(s)
		end)
	end
end

Wrap.Section(ScriptsTab, "服务器专区")
for _, s in ipairs(Scripts.Registry) do
	if s.Category == "服务器专区" then
		Wrap.Button(ScriptsTab, s.Name, "作者: " .. s.Author, function()
			Scripts.LoadEntry(s)
		end)
	end
end

Wrap.Section(ScriptsTab, "功能脚本")
for _, s in ipairs(Scripts.Registry) do
	if s.Category == "功能脚本" then
		Wrap.Button(ScriptsTab, s.Name, "作者: " .. s.Author, function()
			Scripts.LoadEntry(s)
		end)
	end
end

Wrap.Section(ScriptsTab, "黑洞专区")
for _, s in ipairs(Scripts.Registry) do
	if s.Category == "黑洞专区" then
		Wrap.Button(ScriptsTab, s.Name, "作者: " .. s.Author, function()
			Scripts.LoadEntry(s)
		end)
	end
end

Wrap.Section(ScriptsTab, "小游戏")
for _, s in ipairs(Scripts.Registry) do
	if s.Category == "小游戏" then
		Wrap.Button(ScriptsTab, s.Name, "作者: " .. s.Author, function()
			Scripts.LoadEntry(s)
		end)
	end
end

Wrap.Section(ScriptsTab, "画质光影")
for _, s in ipairs(Scripts.Registry) do
	if s.Category == "画质光影" then
		Wrap.Button(ScriptsTab, s.Name, "作者: " .. s.Author, function()
			Scripts.LoadEntry(s)
		end)
	end
end

Wrap.Section(ScriptsTab, "动作 / 表情")
for _, s in ipairs(Scripts.Registry) do
	if s.Category == "动作 / 表情" then
		Wrap.Button(ScriptsTab, s.Name, "作者: " .. s.Author, function()
			Scripts.LoadEntry(s)
		end)
	end
end

Wrap.Section(ScriptsTab, "工具")
for _, s in ipairs(Scripts.Registry) do
	if s.Category == "工具" then
		Wrap.Button(ScriptsTab, s.Name, "作者: " .. s.Author, function()
			Scripts.LoadEntry(s)
		end)
	end
end

Wrap.Section(ScriptsTab, "服务器脚本")
for _, s in ipairs(Scripts.Registry) do
	if s.Category == "服务器脚本" then
		Wrap.Button(ScriptsTab, s.Name, "作者: " .. s.Author, function()
			Scripts.LoadEntry(s)
		end)
	end
end

Wrap.Section(ScriptsTab, "自定义脚本")
local customName, customUrl = "", ""
Wrap.Input(ScriptsTab, "脚本名称", "给脚本起个名字", "", function(v)
	customName = v
end)
Wrap.Input(ScriptsTab, "脚本链接", "输入 URL 后点加载", "", function(v)
	customUrl = v
end)
Wrap.Button(ScriptsTab, "加载自定义脚本", "", function()
	if not customUrl or customUrl == "" then
		G.Notify("失败", "请先填脚本链接", 3)
		return
	end
	local name = (customName ~= "" and customName) or "自定义脚本"
	Scripts.Load(name, customUrl)
end)
Wrap.Button(ScriptsTab, "重新加载上次脚本", "", function()
	Scripts.ReloadLast()
end)

Wrap.Section(ScriptsTab, "执行历史")
Wrap.Button(ScriptsTab, "查看最近执行", "显示最近执行的脚本", function()
	if #Scripts.History == 0 then
		G.Notify("执行历史", "暂无记录", 3)
		return
	end
	local lines = { "共 " .. #Scripts.History .. " 条：" }
	local start = math.max(1, #Scripts.History - 9)
	for i = start, #Scripts.History do
		table.insert(lines, i .. ". " .. Scripts.History[i].name)
	end
	G.Notify("执行历史", table.concat(lines, "\n"), 8)
end)
Wrap.Button(ScriptsTab, "清空执行历史", "", function()
	Scripts.History = {}
	G.Notify("已清空", "执行历史已清空", 3)
end)



-- 构建: Build_SettingsInfoEnv

local G = _G.XIXI_HUB
local UI = G.UI
local Wrap = UI.Wrap
local Env = G.Environment

local SettingsTab = UI.CreateTab("设置")
local InfoTab = UI.CreateTab("信息")
local EnvTab = UI.CreateTab("环境")

Wrap.Section(SettingsTab, "外观")
Wrap.Toggle(SettingsTab, "显示 FPS", "左上角帧率显示", true, function(v)
	G.FPS.Toggle(v)
end)
Wrap.Toggle(SettingsTab, "透明窗口", "让窗口半透明", false, function(v)
	pcall(function()
		if G.Window and G.Window.ToggleTransparency then
			G.Window:ToggleTransparency(v)
		end
	end)
end)
Wrap.Toggle(SettingsTab, "夜视功能", "提高黑暗视野亮度", false, function(v)
	G.Features.Handle("night", v)
end)
Wrap.Toggle(SettingsTab, "去雾功能", "消除游戏中的雾气", false, function(v)
	G.Features.Handle("clearfog", v)
end)
Wrap.Toggle(SettingsTab, "透视作者", "金色高亮脚本作者 " .. G.Author, true, function(v)
	if v then G.Features.ESP.Enable() else G.Features.ESP.Disable() end
end)
Wrap.Toggle(SettingsTab, "彩蛋 - 鲸鱼 LOADI", "开启后鲸鱼会自言自语", true, function(v)
	G.Whale.Enabled = v
end)

Wrap.Section(SettingsTab, "服务器传送")
Wrap.Button(SettingsTab, "重新加入当前服务器", "", function()
	G.Player.Rejoin()
end)
Wrap.Button(SettingsTab, "服务器跳跃", "", function()
	G.Player.ServerHop()
end)
Wrap.Button(SettingsTab, "加入人少的服务器", "", function()
	G.Player.ServerHopLeast()
end)

Wrap.Section(SettingsTab, "玩家名字")
Wrap.Button(SettingsTab, "隐藏玩家名字", "本地隐藏其他玩家头顶名字", function()
	G.Player.HideNames()
end)
Wrap.Button(SettingsTab, "恢复玩家名字", "", function()
	G.Player.ShowNames()
end)

Wrap.Section(SettingsTab, "危险操作")
Wrap.Button(SettingsTab, "卸载脚本", "关闭 UI 并停止所有功能", function()
	for _, conn in pairs(G.ToggleConns) do
		pcall(function() conn:Disconnect() end)
	end
	G.ToggleConns = {}
	G.Features.ESP.Disable()
	G.Features.ClearTeam()
	G.Features.ClearEnemy()
	if G.Fly then G.Fly.Stop() end
	if G.Music and G.Music.Current then pcall(function() G.Music.Current:Stop(); G.Music.Current:Destroy() end) end
	if G.FPS and G.FPS.Gui then pcall(function() G.FPS.Gui:Destroy() end) end
	if G.Window then pcall(function() G.Window:Destroy() end) end
	G.Notify("已卸载", "熙熙·管理员版 已关闭", 3)
end)

Wrap.Section(InfoTab, "实时数据")
Wrap.Label(InfoTab, "提示", "以下数据每 1 秒刷新")
local fpsLabel = Wrap.Label(InfoTab, "FPS", "计算中...")
local pingLabel = Wrap.Label(InfoTab, "Ping", "计算中...")
local memLabel = Wrap.Label(InfoTab, "内存", "计算中...")
local coordLabel = Wrap.Label(InfoTab, "坐标", "计算中...")
local uptimeLabel = Wrap.Label(InfoTab, "服务器运行时间", "计算中...")
local playerLabel = Wrap.Label(InfoTab, "在线玩家", "计算中...")
local jobLabel = Wrap.Label(InfoTab, "JobId", game.JobId ~= "" and game.JobId or "未知")

task.spawn(function()
	local RS = G.Services.RunService
	local Stats = G.Services.Stats
	while G.Window do
		local dt = RS.RenderStepped:Wait()
		local fps = math.floor(1 / math.max(dt, 1e-4))
		pcall(function() fpsLabel:SetText("FPS: " .. fps) end)
		pcall(function()
			local ping = math.floor(Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
			pingLabel:SetText("Ping: " .. ping .. " ms")
		end)
		pcall(function()
			local mem = math.floor(Stats:GetTotalMemoryUsageMb())
			memLabel:SetText("内存: " .. mem .. " MB")
		end)
		pcall(function()
			local c = G.GetCharacter()
			local hrp = c and c:FindFirstChild("HumanoidRootPart")
			if hrp then
				local p = hrp.Position
				coordLabel:SetText(string.format("坐标: X:%.1f Y:%.1f Z:%.1f", p.X, p.Y, p.Z))
			else
				coordLabel:SetText("角色未加载")
			end
		end)
		pcall(function()
			local uptime = math.floor(workspace.DistributedGameTime)
			local h = math.floor(uptime / 3600)
			local m = math.floor((uptime % 3600) / 60)
			uptimeLabel:SetText("服务器运行时间: " .. h .. " 小时 " .. m .. " 分")
		end)
		pcall(function()
			playerLabel:SetText("在线玩家: " .. #G.Services.Players:GetPlayers() .. " 人")
		end)
		task.wait(1)
	end
end)

Wrap.Section(InfoTab, "服务器信息")
Wrap.Label(InfoTab, "PlaceId", tostring(game.PlaceId))
Wrap.Label(InfoTab, "JobId", game.JobId ~= "" and game.JobId or "未知")
Wrap.Button(InfoTab, "复制服务器信息", "", function()
	local txt = "PlaceId: " .. game.PlaceId
		.. "\nJobId: " .. game.JobId
		.. "\n在线: " .. #G.Services.Players:GetPlayers() .. " 人"
	if setclipboard then setclipboard(txt) end
	G.Notify("已复制", "服务器信息已复制", 3)
end)

Wrap.Section(EnvTab, "天空盒")
Wrap.Dropdown(EnvTab, "切换天空盒", Env.GetSkyNames(), "默认", function(v)
	Env.SetSky(v)
end)
Wrap.Section(EnvTab, "环境")
Wrap.Button(EnvTab, "关闭阴影", "", function()
	Env.SetShadow(false)
	G.Notify("已关闭", "阴影已关闭", 3)
end)
Wrap.Button(EnvTab, "开启阴影", "", function()
	Env.SetShadow(true)
	G.Notify("已开启", "阴影已开启", 3)
end)
Wrap.Button(EnvTab, "关闭雾效", "", function()
	pcall(function() G.Services.Lighting.FogEnd = 100000 end)
	G.Notify("已关闭", "雾效已关闭", 3)
end)
Wrap.Button(EnvTab, "开启全图光", "消除所有阴影和雾", function()
	G.Features.Handle("fulllight", true)
	G.Notify("已开启", "全图点亮", 3)
end)



-- 启动引导（原 Main.lua 核心逻辑，含 520 彩蛋与开场动画）

task.wait(2)

local G = _G.XIXI_HUB
G.Loaded = false

local function LoadModule(name, path)
	local fn = loadstring(path)
	if not fn then error("模块编译失败: " .. name) end
	return fn()
end

local modules = {
	"_Globals",
	"_UILibrary",
	"Module_Fly",
	"Module_Features",
	"Module_Player",
	"Module_Music",
	"Module_Scripts",
	"Module_Whale",
	"Module_FPS",
	"Module_Environment",
}

for _, m in ipairs(modules) do
	local ok, err = pcall(function()
		local path = "xixi_patriot_hub/" .. m .. ".lua"
		local fn = loadstring(readfile and readfile(path) or error("无文件系统"))
		if not fn then error("编译失败") end
		fn()
	end)
	if not ok then
		warn("[熙熙] 模块加载失败: " .. m .. " - " .. tostring(err))
	end
end

if G.ExecCount == 520 then
	task.spawn(function()
		local heartGui = Instance.new("ScreenGui")
		heartGui.Name = "HeartEffectGui"
		heartGui.ResetOnSpawn = false
		heartGui.Parent = G.PlayerGui
		local overlay = Instance.new("Frame")
		overlay.Size = UDim2.new(1, 0, 1, 0)
		overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		overlay.BackgroundTransparency = 0.5
		overlay.ZIndex = 999
		overlay.Parent = heartGui
		local heartLabel = Instance.new("TextLabel")
		heartLabel.Size = UDim2.new(0, 200, 0, 200)
		heartLabel.Position = UDim2.new(0.5, -100, 0.5, -100)
		heartLabel.Text = "❤️"
		heartLabel.Font = Enum.Font.GothamBold
		heartLabel.TextSize = 150
		heartLabel.BackgroundTransparency = 1
		heartLabel.ZIndex = 1000
		heartLabel.Parent = heartGui
		local heartHue = 0
		local heartConn = G.Services.RunService.RenderStepped:Connect(function(delta)
			heartHue = (heartHue + delta * 0.5) % 1
			heartLabel.TextColor3 = Color3.fromHSV(heartHue, 1, 1)
		end)
		heartLabel.Size = UDim2.new(0, 0, 0, 0)
		G.Services.TweenService:Create(heartLabel, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), { Size = UDim2.new(0, 200, 0, 200) }):Play()
		wait(3)
		local msgLabel = Instance.new("TextLabel")
		msgLabel.Size = UDim2.new(0, 400, 0, 60)
		msgLabel.Position = UDim2.new(0.5, -200, 0.5, 120)
		msgLabel.Text = "您已执行 520 次，感谢您的支持！❤️"
		msgLabel.Font = Enum.Font.GothamBold
		msgLabel.TextSize = 24
		msgLabel.BackgroundTransparency = 1
		msgLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		msgLabel.TextStrokeTransparency = 0
		msgLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		msgLabel.ZIndex = 1000
		msgLabel.Parent = heartGui
		local msgHue = 0
		local msgConn = G.Services.RunService.RenderStepped:Connect(function(delta)
			msgHue = (msgHue + delta * 0.3) % 1
			msgLabel.TextColor3 = Color3.fromHSV(msgHue, 1, 1)
		end)
		wait(2)
		heartConn:Disconnect()
		msgConn:Disconnect()
		G.Services.TweenService:Create(heartLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { Size = UDim2.new(0, 0, 0, 0) }):Play()
		G.Services.TweenService:Create(msgLabel, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { TextTransparency = 1 }):Play()
		G.Services.TweenService:Create(overlay, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), { BackgroundTransparency = 1 }):Play()
		wait(0.5)
		heartGui:Destroy()
	end)
end

task.spawn(function()
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://80701295792893"
	sound.Volume = 1
	sound.Parent = workspace
	sound:Play()
	sound.Ended:Connect(function() sound:Destroy() end)
end)

task.spawn(function()
	local welcomeGui = Instance.new("ScreenGui")
	welcomeGui.Name = "WelcomeGui"
	welcomeGui.ResetOnSpawn = false
	welcomeGui.Parent = G.PlayerGui
	local welcomeLabel = Instance.new("TextLabel")
	welcomeLabel.Size = UDim2.new(0, 500, 0, 80)
	welcomeLabel.Position = UDim2.new(0.5, -250, 0.5, -40)
	welcomeLabel.Text = "欢迎使用熙熙·管理员版"
	welcomeLabel.Font = Enum.Font.GothamBold
	welcomeLabel.TextSize = 36
	welcomeLabel.BackgroundTransparency = 1
	welcomeLabel.TextStrokeTransparency = 0
	welcomeLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	welcomeLabel.ZIndex = 1000
	welcomeLabel.Parent = welcomeGui
	local hue2 = 0
	local colorConnection
	colorConnection = G.Services.RunService.RenderStepped:Connect(function(delta)
		hue2 = (hue2 + delta * 0.5) % 1
		welcomeLabel.TextColor3 = Color3.fromHSV(hue2, 1, 1)
	end)
	wait(3)
	colorConnection:Disconnect()
	G.Services.TweenService:Create(welcomeLabel, TweenInfo.new(0.8, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	wait(0.8)
	welcomeGui:Destroy()
	local infoGui = Instance.new("ScreenGui")
	infoGui.Name = "InfoGui"
	infoGui.ResetOnSpawn = false
	infoGui.Parent = G.PlayerGui
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Size = UDim2.new(0, 400, 0, 60)
	infoLabel.Position = UDim2.new(0.5, -200, 0.5, -30)
	infoLabel.Text = "此脚本会一直更新\n此脚本作者:" .. G.Author
	infoLabel.Font = Enum.Font.GothamBold
	infoLabel.TextSize = 22
	infoLabel.BackgroundTransparency = 1
	infoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	infoLabel.TextStrokeTransparency = 0
	infoLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	infoLabel.ZIndex = 1000
	infoLabel.Parent = infoGui
	wait(2)
	G.Services.TweenService:Create(infoLabel, TweenInfo.new(0.6, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), { TextTransparency = 1, TextStrokeTransparency = 1 }):Play()
	wait(0.6)
	infoGui:Destroy()
end)

task.spawn(function()
	wait(3)
	local c = G.GetCharacter()
	if c and c:FindFirstChild("HumanoidRootPart") then
		G.Player.HomePosition = c.HumanoidRootPart.CFrame
	end
end)

G.Notify("熙熙·管理员版 已加载", "版本 " .. G.Version .. " | 共 " .. #G.Scripts.Registry .. " 个外部脚本", 5)
print("[熙熙·管理员版 V" .. G.Version .. "] 已加载，共 " .. #G.Scripts.Registry .. " 个外部脚本")

G.Loaded = true
