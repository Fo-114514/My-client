-- 后门脚本 - 老板定制版（直接URL加载版）

local player = game.Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- 国内资源URL
local assetUrls = {
    menu_image = "http://38.58.180.135:3141/%E8%8F%9C%E5%8D%95%E5%9B%BE%E7%89%87.png",
    scare1 = "http://38.58.180.135:3141/%E5%90%93%E5%94%AC.png",
    scare1_bgm = "http://38.58.180.135:3141/%E5%90%93%E5%94%AC1bgm.ogg",
    scare2 = "http://38.58.180.135:3141/%E5%90%93%E5%94%AC2.png",
    scare23_bgm = "http://38.58.180.135:3141/%E6%89%93%E6%AD%8C%E8%88%9E_%E5%90%93%E5%94%AC2,3bgm.mp3",
    sky = "http://38.58.180.135:3141/%E5%A4%A9%E7%A9%BA.png",
    sky2 = "http://38.58.180.135:3141/%E5%A4%A9%E7%A9%BA2.png",
    Jumpstyle_bgm = "http://38.58.180.135:3141/Jumpstyle_bgm.ogg"
}

-- 创建主GUI
local main = Instance.new("ScreenGui")
main.Name = "main"
main.Parent = playerGui
main.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
main.ResetOnSpawn = false

-- 创建主框架 - 横长方形
local Frame = Instance.new("Frame")
Frame.Parent = main
Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Frame.Position = UDim2.new(0.2, 0, 0.35, 0)
Frame.Size = UDim2.new(0, 500, 0, 250)
Frame.Active = true
Frame.Draggable = true

-- 菜单背景图片
local menuImage = Instance.new("ImageLabel")
menuImage.Parent = Frame
menuImage.Size = UDim2.new(1, 0, 1, 0)
menuImage.Position = UDim2.new(0, 0, 0, 0)
menuImage.Image = assetUrls.menu_image
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
    if currentMusic then
        pcall(function()
            currentMusic:Stop()
            currentMusic:Destroy()
        end)
    end
    if scareSound then
        pcall(function()
            scareSound:Stop()
            scareSound:Destroy()
        end)
    end
    main:Destroy()
end)

-- 音乐控制变量
local currentMusic = nil
local scareSound = nil

-- 停止音乐函数
local function stopMusic()
    if currentMusic then
        pcall(function()
            currentMusic:Stop()
        end)
    end
    if scareSound then
        pcall(function()
            scareSound:Stop()
        end)
    end
end

-- 播放音乐函数
local function playMusic(url, looped)
    stopMusic()
    
    local sound = Instance.new("Sound")
    sound.SoundId = url
    sound.Parent = workspace
    sound.Volume = 1
    sound.Looped = looped or false
    sound:Play()
    
    currentMusic = sound
    return sound
end

-- 显示全屏图片函数
local function showFullscreenImage(url)
    local imageGui = Instance.new("ScreenGui")
    imageGui.Parent = playerGui
    imageGui.Name = "FullscreenImage"
    imageGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Parent = imageGui
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Position = UDim2.new(0, 0, 0, 0)
    imageLabel.Image = url
    imageLabel.BackgroundTransparency = 1
    imageLabel.ZIndex = 10
    
    return imageGui
end

-- 吓唬功能
local function scareAction(imageUrl, soundUrl, duration)
    stopMusic()
    
    local imageGui = showFullscreenImage(imageUrl)
    
    local sound = Instance.new("Sound")
    sound.SoundId = soundUrl
    sound.Parent = workspace
    sound.Volume = 1
    sound.Looped = false
    sound:Play()
    scareSound = sound
    
    spawn(function()
        wait(duration)
        if imageGui then
            imageGui:Destroy()
        end
        if sound then
            pcall(function()
                sound:Stop()
            end)
            scareSound = nil
        end
    end)
end

-- 替换天空盒函数
local function replaceSkybox(url)
    local oldSky = game.Lighting:FindFirstChildOfClass("Sky")
    if oldSky then
        oldSky:Destroy()
    end
    
    local skybox = Instance.new("Sky")
    skybox.SkyboxBk = url
    skybox.SkyboxDn = url
    skybox.SkyboxFt = url
    skybox.SkyboxLf = url
    skybox.SkyboxRt = url
    skybox.SkyboxUp = url
    skybox.Parent = game.Lighting
end

-- 创建按钮函数
local function createButton(name, position, size, callback)
    local button = Instance.new("TextButton")
    button.Parent = Frame
    button.Name = name
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

-- 创建所有功能按钮
createButton("吓唬", UDim2.new(0.02, 0, 0.15, 0), UDim2.new(0, 90, 0, 35), function()
    scareAction(assetUrls.scare1, assetUrls.scare1_bgm, 8)
end)

createButton("吓唬2", UDim2.new(0.22, 0, 0.15, 0), UDim2.new(0, 90, 0, 35), function()
    scareAction(assetUrls.scare2, assetUrls.scare23_bgm, 18)
end)

createButton("吓唬3", UDim2.new(0.42, 0, 0.15, 0), UDim2.new(0, 90, 0, 35), function()
    scareAction(assetUrls.scare2, assetUrls.scare23_bgm, 18)
end)

createButton("sky", UDim2.new(0.62, 0, 0.15, 0), UDim2.new(0, 80, 0, 35), function()
    replaceSkybox(assetUrls.sky)
end)

createButton("sky2", UDim2.new(0.8, 0, 0.15, 0), UDim2.new(0, 80, 0, 35), function()
    replaceSkybox(assetUrls.sky2)
end)

createButton("播放音乐", UDim2.new(0.02, 0, 0.5, 0), UDim2.new(0, 100, 0, 35), function()
    playMusic(assetUrls.Jumpstyle_bgm, true)
end)

createButton("停止音乐", UDim2.new(0.24, 0, 0.5, 0), UDim2.new(0, 100, 0, 35), function()
    stopMusic()
end)

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
        for _, button in pairs(allButtons) do
            button.Visible = false
        end
        Frame.Size = UDim2.new(0, 500, 0, 40)
        menuImage.Visible = false
    else
        for _, button in pairs(allButtons) do
            button.Visible = true
        end
        Frame.Size = UDim2.new(0, 500, 0, 250)
        menuImage.Visible = true
    end
end)

-- 防止角色死亡后脚本出错
player.CharacterAdded:Connect(function()
    stopMusic()
end)
