-- 后门脚本 - 老板定制版（粒子火焰终极修复版）

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 资源下载函数
local function downloadAsset(url, fileName)
    local success, result = pcall(function()
        local response = game:HttpGet(url)
        if response and #response > 0 then
            if writefile then
                writefile(fileName, response)
                return true
            end
        end
        return false
    end)
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

-- 获取资源
local function getFileAsset(fileName)
    local localPath = getAssetPath(fileName)
    if localPath then return localPath end
    
    local url = assetUrls[fileName]
    if url then
        downloadAsset(url, fileName)
        local localPath2 = getAssetPath(fileName)
        if localPath2 then return localPath2 end
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
if menuAsset then menuImage.Image = menuAsset end
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
    if currentMusic then pcall(function() currentMusic:Stop() currentMusic:Destroy() end) end
    if scareSound then pcall(function() scareSound:Stop() scareSound:Destroy() end) end
    main:Destroy()
end)

local currentMusic = nil
local scareSound = nil
local fireLoop = nil  -- 火焰循环协程

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
    if sound then sound:Play() scareSound = sound end
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

-- 粒子功能 - 参考k011lkidd的做法，直接放Head上，VelocitySpread设超大
local function spawnParticles1()
    local particleTexture = getFileAsset("particle1.png")
    if not particleTexture then return end
    
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    -- 参考：emit.VelocitySpread = 100000
    local emit = Instance.new("ParticleEmitter")
    emit.Parent = head
    emit.Texture = particleTexture
    emit.Rate = 500
    emit.Lifetime = NumberRange.new(5, 15)
    emit.Speed = NumberRange.new(20, 50)
    emit.SpreadAngle = Vector2.new(360, 360)
    emit.VelocitySpread = 100000  -- 超大扩散范围
    emit.Acceleration = Vector3.new(0, 10, 0)
    emit.Drag = 0.2
    emit.RotSpeed = NumberRange.new(-300, 300)
    
    print("粒子1已生成（参考k011lkidd方式）")
end

local function spawnParticles2()
    local particleTexture = getFileAsset("particle2.png")
    if not particleTexture then return end
    
    local char = player.Character
    if not char then return end
    local head = char:FindFirstChild("Head")
    if not head then return end
    
    local emit = Instance.new("ParticleEmitter")
    emit.Parent = head
    emit.Texture = particleTexture
    emit.Rate = 500
    emit.Lifetime = NumberRange.new(5, 15)
    emit.Speed = NumberRange.new(20, 50)
    emit.SpreadAngle = Vector2.new(360, 360)
    emit.VelocitySpread = 100000
    emit.Acceleration = Vector3.new(0, 10, 0)
    emit.Drag = 0.2
    emit.RotSpeed = NumberRange.new(-300, 300)
    
    print("粒子2已生成（参考k011lkidd方式）")
end

-- 角色重生时保留粒子（Head变了的话需要重新加）
player.CharacterAdded:Connect(function(char)
    wait(0.5)
    stopMusic()
    -- 粒子需要重新添加到新角色上
    -- 这里不做自动重加，因为用户可能不想一直有粒子
end)

-- 火焰功能 - 参考RainFire的做法，while true循环创建
local function startFireStorm()
    if fireLoop then return end  -- 已经在烧了
    
    fireLoop = coroutine.create(function()
        while true do
            -- 一波创建多个火焰
            for i = 1, 20 do
                local part = Instance.new("Part")
                part.Position = Vector3.new(math.random(-500, 500), math.random(1, 100), math.random(-500, 500))
                part.Size = Vector3.new(math.random(5, 20), math.random(5, 20), math.random(5, 20))
                part.Anchored = true
                part.CanCollide = false
                part.Transparency = 1  -- 参考：载体透明
                part.Parent = workspace
                
                local fire = Instance.new("Fire")
                fire.Size = math.random(30, 60)  -- 超级大
                fire.Heat = math.random(20, 40)
                fire.Parent = part
                
                -- 加光效
                local light = Instance.new("PointLight")
                light.Parent = part
                light.Brightness = math.random(3, 10)
                light.Range = math.random(20, 50)
                light.Color = Color3.fromRGB(255, math.random(80, 160), 0)
            end
            wait(0.3)  -- 每0.3秒一波，参考原版RainFire的wait(1)但这里更快更多
        end
    end)
    coroutine.resume(fireLoop)
    print("火焰风暴开始！")
end

-- WP1
local function wpAction()
    local texAsset = getFileAsset("wp.png")
    if not texAsset then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            pcall(function()
                obj.Material = Enum.Material.Plastic
                obj.Transparency = 0
                -- 参考DecalSpam做法，创建6个面的Decal
                local faces = {
                    {name = "Front", face = Enum.NormalId.Front},
                    {name = "Back", face = Enum.NormalId.Back},
                    {name = "Right", face = Enum.NormalId.Right},
                    {name = "Left", face = Enum.NormalId.Left},
                    {name = "Top", face = Enum.NormalId.Top},
                    {name = "Bottom", face = Enum.NormalId.Bottom}
                }
                for _, f in ipairs(faces) do
                    -- 先清除旧Decal
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("Decal") and child.Name == "WP_" .. f.name then
                            child:Destroy()
                        end
                    end
                    local decal = Instance.new("Decal", obj)
                    decal.Name = "WP_" .. f.name
                    decal.Texture = texAsset
                    decal.Face = f.face
                end
            end)
        end
    end
    
    startFireStorm()
    print("WP1完成：贴图替换 + 火焰风暴")
end

-- WP2
local function wp2Action()
    local texAsset = getFileAsset("wp2.png")
    if not texAsset then return end
    
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and not obj:IsA("Terrain") then
            pcall(function()
                obj.Material = Enum.Material.Plastic
                obj.Transparency = 0
                local faces = {
                    {name = "Front", face = Enum.NormalId.Front},
                    {name = "Back", face = Enum.NormalId.Back},
                    {name = "Right", face = Enum.NormalId.Right},
                    {name = "Left", face = Enum.NormalId.Left},
                    {name = "Top", face = Enum.NormalId.Top},
                    {name = "Bottom", face = Enum.NormalId.Bottom}
                }
                for _, f in ipairs(faces) do
                    for _, child in ipairs(obj:GetChildren()) do
                        if child:IsA("Decal") and child.Name == "WP_" .. f.name then
                            child:Destroy()
                        end
                    end
                    local decal = Instance.new("Decal", obj)
                    decal.Name = "WP_" .. f.name
                    decal.Texture = texAsset
                    decal.Face = f.face
                end
            end)
        end
    end
    
    startFireStorm()
    print("WP2完成：贴图替换 + 火焰风暴")
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

print("脚本加载完成 fuck you!")
