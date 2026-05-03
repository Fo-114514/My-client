-- 后门脚本 - 老板定制版（粒子永久+火焰加强+载体隐藏）

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 资源下载函数 - 使用game:HttpGet
local function downloadAsset(url, fileName)
    local success, result = pcall(function()
        local response = game:HttpGet(url)
        if response and #response > 0 then
            if writefile then
                writefile(fileName, response)
                print("下载成功: " .. fileName .. " (大小: " .. #response .. " 字节)")
                return true
            end
        else
            print("下载失败: 响应为空")
        end
        return false
    end)
    if not success then
        print("下载异常: " .. tostring(result))
    end
    return false
end

-- 获取本地资源的customasset路径
local function getAssetPath(fileName)
    if isfile and isfile(fileName) then
        local success, result = pcall(function()
            return getcustomasset(fileName)
        end)
        if success and result then
            return result
        end
    end
    return nil
end

-- 国内下载路径
local assetUrls = {
    ["menu_image.png"] = "http://38.58.180.135:3141/%E8%8F%9C%E5%8D%95%E5%9B%BE%E7%89%87.png",
    ["scare1.png"] = "http://38.58.180.135:3141/%E5%90%93%E5%94%AC.png",
    ["scare1_bgm.ogg"] = "http://38.58.180.135:3141/%E5%90%93%E5%94%AC1bgm.ogg",
    ["scare2.png"] = "http://38.58.180.135:3141/%E5%90%93%E5%94%AC2.png",
    ["scare23_bgm.mp3"] = "http://38.58.180.135:3141/%E6%89%93%E6%AD%8C%E8%88%9E_%E5%90%93%E5%94%AC2,3bgm.mp3",
    ["sky.png"] = "http://38.58.180.135:3141/%E5%A4%A9%E7%A9%BA.png",
    ["sky2.png"] = "http://38.58.180.135:3141/%E5%A4%A9%E7%A9%BA2.png",
    ["Jumpstyle_bgm.ogg"] = "http://38.58.180.135:3141/Jumpstyle_bgm.ogg",
    ["particle1.png"] = "http://38.58.180.135:3141/%E7%94%B7%E7%A5%9E.JPG",
    ["particle2.png"] = "http://38.58.180.135:3141/%E6%81%AD%E5%96%9C.png",
    ["wp.png"] = "http://38.58.180.135:3141/wp.png",
    ["wp2.png"] = "http://38.58.180.135:3141/wp2.png"
}

-- 获取资源（优先本地，没有就用URL或下载）
local function getFileAsset(fileName)
    local localPath = getAssetPath(fileName)
    if localPath then
        return localPath
    end
    
    local url = assetUrls[fileName]
    if url then
        downloadAsset(url, fileName)
        local localPath2 = getAssetPath(fileName)
        if localPath2 then
            return localPath2
        end
    end
    
    return assetUrls[fileName] or nil
end

-- 先下载所有资源
for fileName, url in pairs(assetUrls) do
    if not isfile or not isfile(fileName) then
        downloadAsset(url, fileName)
    end
end

-- 创建主GUI
local main = Instance.new("ScreenGui")
main.Name = "main"
main.Parent = playerGui
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

local Frame = Instance.new("Frame")
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Position = UDim2.new(0.2, 0, 0.35, 0)
Frame.Size = UDim2.new(0, 500, 0, 250)
Frame.Active = true
Frame.Draggable = true

local menuImage = Instance.new("ImageLabel")
menuImage.Parent = Frame
menuImage.Size = UDim2.new(1, 0, 1, 0)
menuImage.Position = UDim2.new(0, 0, 0, 0)
local menuAsset = getFileAsset("menu_image.png")
if menuAsset then
    menuImage.Image = menuAsset
end
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
    if currentMusic then
        pcall(function() currentMusic:Stop() currentMusic:Destroy() end)
    end
    if scareSound then
        pcall(function() scareSound:Stop() scareSound:Destroy() end)
    end
    main:Destroy()
end)

local currentMusic = nil
local scareSound = nil
local particleEmitters = {}  -- 存储所有粒子发射器，防止被垃圾回收

local function stopMusic()
    if currentMusic then pcall(function() currentMusic:Stop() end) end
    if scareSound then pcall(function() scareSound:Stop() end) end
end

local function createSound(fileName, looped)
    local assetPath = getFileAsset(fileName)
    if not assetPath then return nil end
    
    local sound = Instance.new("Sound")
    sound.SoundId = assetPath
    sound.Parent = workspace
    sound.Volume = 1
    sound.Looped = looped or false
    sound.PlayOnRemove = false
    return sound
end

local function playMusic(fileName, looped)
    stopMusic()
    local sound = createSound(fileName, looped)
    if sound then
        sound:Play()
        currentMusic = sound
    end
    return sound
end

local function showFullscreenImage(fileName)
    local assetPath = getFileAsset(fileName)
    if not assetPath then return nil end
    
    local imageGui = Instance.new("ScreenGui")
    imageGui.Parent = playerGui
    imageGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Parent = imageGui
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Image = assetPath
    imageLabel.BackgroundTransparency = 1
    imageLabel.ZIndex = 10
    return imageGui
end

local function scareAction(imageFile, soundFile, duration)
    stopMusic()
    local imageGui = showFullscreenImage(imageFile)
    local sound = createSound(soundFile, false)
    if sound then
        sound:Play()
        scareSound = sound
    end
    spawn(function()
        wait(duration)
        if imageGui then imageGui:Destroy() end
        if sound then pcall(function() sound:Stop() end) scareSound = nil end
    end)
end

local function replaceSkybox(fileName)
    local assetPath = getFileAsset(fileName)
    if not assetPath then return end
    local oldSky = game.Lighting:FindFirstChildOfClass("Sky")
    if oldSky then oldSky:Destroy() end
    local skybox = Instance.new("Sky")
    skybox.SkyboxBk = assetPath
    skybox.SkyboxDn = assetPath
    skybox.SkyboxFt = assetPath
    skybox.SkyboxLf = assetPath
    skybox.SkyboxRt = assetPath
    skybox.SkyboxUp = assetPath
    skybox.Parent = game.Lighting
end

-- 粒子功能 - 真正永久，角色重生也会重新添加
local function addParticlesToCharacter(char, textureFileName)
    local particleTexture = getFileAsset(textureFileName)
    if not particleTexture then return end
    
    for _, part in ipairs(char:GetChildren()) do
        if part:IsA("BasePart") then
            -- 检查是否已经有emitter了
            local existingAttach = part:FindFirstChild("ParticleAttachment")
            if existingAttach then
                existingAttach:Destroy()
            end
            
            local attach = Instance.new("Attachment", part)
            attach.Name = "ParticleAttachment"
            
            local emitter = Instance.new("ParticleEmitter")
            emitter.Parent = attach
            emitter.Texture = particleTexture
            emitter.Rate = 500  -- 疯狂发射
            emitter.Lifetime = NumberRange.new(5, 10)
            emitter.Speed = NumberRange.new(10, 30)
            emitter.SpreadAngle = Vector2.new(360, 360)
            emitter.Acceleration = Vector3.new(0, 5, 0)
            emitter.Drag = 0.3
            emitter.RotSpeed = NumberRange.new(-200, 200)
            emitter.Size = NumberSequence.new(NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0))
            
            table.insert(particleEmitters, emitter)
        end
    end
end

local particle1Active = false
local particle2Active = false

local function spawnParticles1()
    particle1Active = true
    local char = player.Character
    if char then
        addParticlesToCharacter(char, "particle1.png")
    end
end

local function spawnParticles2()
    particle2Active = true
    local char = player.Character
    if char then
        addParticlesToCharacter(char, "particle2.png")
    end
end

-- 角色重生时重新添加粒子
player.CharacterAdded:Connect(function(char)
    wait(0.5)  -- 等角色完全加载
    if particle1Active then
        addParticlesToCharacter(char, "particle1.png")
    end
    if particle2Active then
        addParticlesToCharacter(char, "particle2.png")
    end
    stopMusic()
end)

-- 创建火焰函数
local function createFireStorm()
    for i = 1, 500 do  -- 500个火焰
        spawn(function()
            local randomX = math.random(-800, 800)
            local randomZ = math.random(-800, 800)
            local randomY = math.random(-10, 80)
            
            local firePart = Instance.new("Part")
            firePart.Size = Vector3.new(math.random(5, 15), math.random(5, 15), math.random(5, 15))
            firePart.Position = Vector3.new(randomX, randomY, randomZ)
            firePart.Anchored = true
            firePart.CanCollide = false
            firePart.Transparency = 0.999  -- 几乎完全透明
            firePart.Material = Enum.Material.SmoothPlastic
            firePart.BrickColor = BrickColor.new("Bright red")
            firePart.Parent = workspace
            
            local fire = Instance.new("Fire")
            fire.Size = math.random(20, 50)  -- 大火
            fire.Heat = math.random(15, 30)
            fire.Parent = firePart
            
            -- 再加个火光
            local light = Instance.new("PointLight")
            light.Parent = firePart
            light.Brightness = math.random(2, 8)
            light.Range = math.random(10, 30)
            light.Color = Color3.fromRGB(255, math.random(100, 180), 0)
        end)
    end
end

-- WP1
local function wpAction()
    local texAsset = getFileAsset("wp.png")
    if not texAsset then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            pcall(function()
                obj.Material = Enum.Material.SmoothPlastic
                for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right}) do
                    local existingTex = obj:FindFirstChild("WP_Tex_" .. face.Name)
                    if existingTex then existingTex:Destroy() end
                    local tex = Instance.new("Texture")
                    tex.Name = "WP_Tex_" .. face.Name
                    tex.Texture = texAsset
                    tex.Face = face
                    tex.Parent = obj
                end
            end)
        end
    end
    
    createFireStorm()
end

-- WP2
local function wp2Action()
    local texAsset = getFileAsset("wp2.png")
    if not texAsset then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            pcall(function()
                obj.Material = Enum.Material.SmoothPlastic
                for _, face in ipairs({Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Left, Enum.NormalId.Right}) do
                    local existingTex = obj:FindFirstChild("WP_Tex_" .. face.Name)
                    if existingTex then existingTex:Destroy() end
                    local tex = Instance.new("Texture")
                    tex.Name = "WP_Tex_" .. face.Name
                    tex.Texture = texAsset
                    tex.Face = face
                    tex.Parent = obj
                end
            end)
        end
    end
    
    createFireStorm()
end

-- 创建按钮
local function createButton(name, position, size, callback)
    local button = Instance.new("TextButton")
    button.Parent = Frame
    button.Position = position
    button.Size = size
    button.BackgroundColor3 = Color3.fromRGB(200, 162, 200)
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 14
    button.MouseButton1Click:Connect(callback)
    return button
end

-- 第一排
createButton("吓唬", UDim2.new(0.02, 0, 0.08, 0), UDim2.new(0, 80, 0, 30), function()
    scareAction("scare1.png", "scare1_bgm.ogg", 8)
end)
createButton("吓唬2", UDim2.new(0.20, 0, 0.08, 0), UDim2.new(0, 80, 0, 30), function()
    scareAction("scare2.png", "scare23_bgm.mp3", 18)
end)
createButton("吓唬3", UDim2.new(0.38, 0, 0.08, 0), UDim2.new(0, 80, 0, 30), function()
    scareAction("scare2.png", "scare23_bgm.mp3", 18)
end)
createButton("sky", UDim2.new(0.56, 0, 0.08, 0), UDim2.new(0, 70, 0, 30), function()
    replaceSkybox("sky.png")
end)
createButton("sky2", UDim2.new(0.72, 0, 0.08, 0), UDim2.new(0, 70, 0, 30), function()
    replaceSkybox("sky2.png")
end)

-- 第二排
createButton("粒子", UDim2.new(0.02, 0, 0.25, 0), UDim2.new(0, 80, 0, 30), function()
    spawnParticles1()
end)
createButton("粒子2", UDim2.new(0.20, 0, 0.25, 0), UDim2.new(0, 80, 0, 30), function()
    spawnParticles2()
end)
createButton("wp", UDim2.new(0.38, 0, 0.25, 0), UDim2.new(0, 80, 0, 30), function()
    wpAction()
end)
createButton("wp2", UDim2.new(0.56, 0, 0.25, 0), UDim2.new(0, 80, 0, 30), function()
    wp2Action()
end)

-- 第三排
createButton("播放音乐", UDim2.new(0.02, 0, 0.42, 0), UDim2.new(0, 90, 0, 30), function()
    playMusic("Jumpstyle_bgm.ogg", true)
end)
createButton("停止音乐", UDim2.new(0.22, 0, 0.42, 0), UDim2.new(0, 90, 0, 30), function()
    stopMusic()
end)

-- 最小化
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
        Frame.Size = UDim2.new(0, 500, 0, 40)
        menuImage.Visible = false
    else
        for _, button in pairs(allButtons) do button.Visible = true end
        Frame.Size = UDim2.new(0, 500, 0, 250)
        menuImage.Visible = true
    end
end)

print("后门脚本加载完成 - 粒子永久 + 500超级火焰 + 载体隐藏")
