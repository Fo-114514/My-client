-- 后门脚本 - 老板定制版

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 创建主GUI
local main = Instance.new("ScreenGui")
main.Name = "main"
main.Parent = playerGui
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

-- 创建主框架
local Frame = Instance.new("Frame")
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Frame.Position = UDim2.new(0.3, 0, 0.3, 0)
Frame.Size = UDim2.new(0, 200, 0, 400)
Frame.Active = true
Frame.Draggable = true

-- 菜单背景图片
local menuImage = Instance.new("ImageLabel")
menuImage.Parent = Frame
menuImage.Size = UDim2.new(1, 0, 1, 0)
menuImage.Position = UDim2.new(0, 0, 0, 0)
menuImage.Image = "https://raw.githubusercontent.com/Fo-114514/My-client/refs/heads/main/%E8%8F%9C%E5%8D%95%E5%9B%BE%E7%89%87.png"
menuImage.BackgroundTransparency = 1

-- 关闭按钮
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

-- 音乐控制变量
local currentMusic = nil

-- 停止音乐函数
local function stopMusic()
    if currentMusic then
        currentMusic:Stop()
        currentMusic:Destroy()
        currentMusic = nil
    end
end

-- 播放音乐函数
local function playMusic(url, looped)
    stopMusic()
    local sound = Instance.new("Sound")
    sound.SoundId = url
    sound.Parent = game.Workspace
    sound.Volume = 1
    sound.Looped = looped or false
    sound:Play()
    currentMusic = sound
    return sound
end

-- 显示全屏图片函数
local function showFullscreenImage(imageUrl, duration)
    local imageGui = Instance.new("ScreenGui")
    imageGui.Parent = playerGui
    imageGui.Name = "FullscreenImage"
    
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Parent = imageGui
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Position = UDim2.new(0, 0, 0, 0)
    imageLabel.Image = imageUrl
    imageLabel.BackgroundTransparency = 1
    imageLabel.ZIndex = 10
    
    if duration then
        delay(duration, function()
            imageGui:Destroy()
        end)
    end
    
    return imageGui
end

-- 替换天空盒函数
local function replaceSkybox(imageUrl)
    local skybox = Instance.new("Sky")
    skybox.SkyboxBk = imageUrl
    skybox.SkyboxDn = imageUrl
    skybox.SkyboxFt = imageUrl
    skybox.SkyboxLf = imageUrl
    skybox.SkyboxRt = imageUrl
    skybox.SkyboxUp = imageUrl
    skybox.Parent = game.Lighting
    return skybox
end

-- 创建按钮函数
local function createButton(name, position, callback)
    local button = Instance.new("TextButton")
    button.Parent = Frame
    button.Name = name
    button.Position = position
    button.Size = UDim2.new(0, 160, 0, 35)
    button.BackgroundColor3 = Color3.fromRGB(200, 162, 200) -- 淡紫色
    button.Text = name
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    
    button.MouseButton1Click:Connect(callback)
    
    return button
end

-- 创建所有按钮
-- 吓唬按钮
createButton("吓唬", UDim2.new(0.5, -80, 0.1, 0), function()
    showFullscreenImage("https://raw.githubusercontent.com/Fo-114514/My-client/refs/heads/main/%E5%90%93%E5%94%AC.png", 9)
    local sound = playMusic("https://github.com/Fo-114514/My-client/raw/refs/heads/main/%E5%90%93%E5%94%AC1bgm.ogg", false)
    delay(9, function()
        if sound then
            sound:Stop()
        end
    end)
end)

-- 吓唬2按钮
createButton("吓唬2", UDim2.new(0.5, -80, 0.2, 0), function()
    showFullscreenImage("https://raw.githubusercontent.com/Fo-114514/My-client/refs/heads/main/%E5%90%93%E5%94%AC2.png", 18)
    local sound = playMusic("https://github.com/Fo-114514/My-client/raw/refs/heads/main/%E6%89%93%E6%AD%8C%E8%88%9E_%E5%90%93%E5%94%AC2,3bgm.mp3", false)
    delay(18, function()
        if sound then
            sound:Stop()
        end
    end)
end)

-- 吓唬3按钮
createButton("吓唬3", UDim2.new(0.5, -80, 0.3, 0), function()
    showFullscreenImage("https://raw.githubusercontent.com/Fo-114514/My-client/refs/heads/main/%E5%90%93%E5%94%AC2.png", 18)
    local sound = playMusic("https://github.com/Fo-114514/My-client/raw/refs/heads/main/%E6%89%93%E6%AD%8C%E8%88%9E_%E5%90%93%E5%94%AC2,3bgm.mp3", false)
    delay(18, function()
        if sound then
            sound:Stop()
        end
    end)
end)

-- sky按钮
createButton("sky", UDim2.new(0.5, -80, 0.4, 0), function()
    replaceSkybox("https://raw.githubusercontent.com/Fo-114514/My-client/refs/heads/main/%E5%A4%A9%E7%A9%BA.png")
end)

-- sky2按钮
createButton("sky2", UDim2.new(0.5, -80, 0.5, 0), function()
    replaceSkybox("https://raw.githubusercontent.com/Fo-114514/My-client/refs/heads/main/%E5%A4%A9%E7%A9%BA2.png")
end)

-- 播放音乐按钮
createButton("播放音乐", UDim2.new(0.5, -80, 0.6, 0), function()
    playMusic("https://github.com/Fo-114514/My-client/raw/refs/heads/main/Jumpstyle_bgm.ogg", true)
end)

-- 停止音乐按钮
createButton("停止音乐", UDim2.new(0.5, -80, 0.7, 0), function()
    stopMusic()
end)

-- 最小化功能（参考原始脚本）
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
        for _, button in pairs(allButtons) do
            button.Visible = false
        end
        Frame.Size = UDim2.new(0, 200, 0, 60)
        menuImage.Visible = false
    else
        for _, button in pairs(allButtons) do
            button.Visible = true
        end
        Frame.Size = UDim2.new(0, 200, 0, 400)
        menuImage.Visible = true
    end
end)

-- 防止角色死亡后脚本出错
player.CharacterAdded:Connect(function()
    stopMusic()
end)

