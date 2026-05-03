-- 后门脚本 - 老板定制版（修复吓唬功能）

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
    ["Jumpstyle_bgm.ogg"] = "http://38.58.180.135:3141/Jumpstyle_bgm.ogg"
}

-- 获取资源（优先本地，没有就用URL或下载）
local function getFileAsset(fileName)
    local localPath = getAssetPath(fileName)
    if localPath then
        print("使用本地资源: " .. fileName)
        return localPath
    end
    
    local url = assetUrls[fileName]
    if url then
        print("尝试下载: " .. fileName)
        downloadAsset(url, fileName)
        
        local localPath2 = getAssetPath(fileName)
        if localPath2 then
            print("下载后使用本地资源: " .. fileName)
            return localPath2
        end
    end
    
    if url then
        print("回退到URL: " .. fileName)
        return url
    end
    
    print("无法获取资源: " .. fileName)
    return nil
end

-- 先下载所有资源
print("开始下载资源...")
for fileName, url in pairs(assetUrls) do
    if not isfile or not isfile(fileName) then
        downloadAsset(url, fileName)
    else
        print("文件已存在: " .. fileName)
    end
end
print("资源下载完成")

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
local menuAsset = getFileAsset("menu_image.png")
if menuAsset then
    menuImage.Image = menuAsset
    print("菜单图片加载成功")
else
    print("警告: 菜单图片加载失败")
end
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

-- 停止音乐函数（仅停止，不销毁）
local function stopMusic()
    if currentMusic then
        pcall(function()
            currentMusic:Stop()
        end)
        currentMusic = nil
        print("音乐已停止")
    end
end

-- 创建音乐对象
local function createSound(fileName, looped)
    local assetPath = getFileAsset(fileName)
    if not assetPath then
        print("错误: 找不到音频文件 " .. fileName)
        return nil
    end
    
    local sound = Instance.new("Sound")
    
    if string.find(assetPath, "rbxasset://") or string.find(assetPath, "rbxassetid://") then
        sound.SoundId = assetPath
    else
        sound.SoundId = assetPath
    end
    
    sound.Parent = game:GetService("SoundService")
    sound.Volume = 1
    sound.Looped = looped or false
    
    return sound
end

-- 播放音乐函数（用于循环音乐）
local function playMusic(fileName, looped)
    stopMusic()
    
    local sound = createSound(fileName, looped)
    if not sound then
        return nil
    end
    
    sound.Loaded:Connect(function()
        print("音频加载成功: " .. fileName)
        sound:Play()
    end)
    
    sound:Load()
    currentMusic = sound
    print("开始播放: " .. fileName)
    return sound
end

-- 显示全屏图片函数
local function showFullscreenImage(fileName)
    local assetPath = getFileAsset(fileName)
    if not assetPath then
        print("错误: 找不到图片文件 " .. fileName)
        return nil
    end
    
    local imageGui = Instance.new("ScreenGui")
    imageGui.Parent = playerGui
    imageGui.Name = "FullscreenImage"
    
    local imageLabel = Instance.new("ImageLabel")
    imageLabel.Parent = imageGui
    imageLabel.Size = UDim2.new(1, 0, 1, 0)
    imageLabel.Position = UDim2.new(0, 0, 0, 0)
    imageLabel.Image = assetPath
    imageLabel.BackgroundTransparency = 1
    imageLabel.ZIndex = 10
    
    print("显示全屏图片: " .. fileName)
    
    return imageGui
end

-- 吓唬功能：播放音乐+显示图片，指定时间后同时停止
local function scareAction(imageFile, soundFile, duration)
    -- 停止之前的音乐
    stopMusic()
    
    -- 先显示图片
    local imageGui = showFullscreenImage(imageFile)
    if not imageGui then
        print("图片显示失败，取消吓唬")
        return
    end
    
    -- 再创建并播放音乐
    local sound = createSound(soundFile, false)
    if sound then
        sound.Loaded:Connect(function()
            sound:Play()
            print("吓唬音乐开始播放: " .. soundFile)
        end)
        sound:Load()
    end
    
    -- 定时器：时间到了同时移除图片和停止音乐
    delay(duration, function()
        if imageGui then
            imageGui:Destroy()
            print("吓唬图片已移除: " .. imageFile)
        end
        if sound then
            pcall(function()
                sound:Stop()
            end)
            print("吓唬音乐已停止: " .. soundFile)
        end
    end)
    
    print("吓唬开始，持续 " .. duration .. " 秒")
end

-- 替换天空盒函数
local function replaceSkybox(fileName)
    local assetPath = getFileAsset(fileName)
    if not assetPath then
        print("错误: 找不到天空盒文件 " .. fileName)
        return nil
    end
    
    local oldSky = game.Lighting:FindFirstChildOfClass("Sky")
    if oldSky then
        oldSky:Destroy()
    end
    
    local skybox = Instance.new("Sky")
    skybox.SkyboxBk = assetPath
    skybox.SkyboxDn = assetPath
    skybox.SkyboxFt = assetPath
    skybox.SkyboxLf = assetPath
    skybox.SkyboxRt = assetPath
    skybox.SkyboxUp = assetPath
    skybox.Parent = game.Lighting
    
    print("替换天空盒: " .. fileName)
    return skybox
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
    
    button.MouseButton1Click:Connect(function()
        print("点击按钮: " .. name)
        callback()
    end)
    
    return button
end

-- 创建所有功能按钮 - 横版布局
-- 第一排
createButton("吓唬", UDim2.new(0.02, 0, 0.15, 0), UDim2.new(0, 90, 0, 35), function()
    scareAction("scare1.png", "scare1_bgm.ogg", 8)
end)

createButton("吓唬2", UDim2.new(0.22, 0, 0.15, 0), UDim2.new(0, 90, 0, 35), function()
    scareAction("scare2.png", "scare23_bgm.mp3", 18)
end)

createButton("吓唬3", UDim2.new(0.42, 0, 0.15, 0), UDim2.new(0, 90, 0, 35), function()
    scareAction("scare2.png", "scare23_bgm.mp3", 18)
end)

createButton("sky", UDim2.new(0.62, 0, 0.15, 0), UDim2.new(0, 80, 0, 35), function()
    replaceSkybox("sky.png")
end)

createButton("sky2", UDim2.new(0.8, 0, 0.15, 0), UDim2.new(0, 80, 0, 35), function()
    replaceSkybox("sky2.png")
end)

-- 第二排
createButton("播放音乐", UDim2.new(0.02, 0, 0.5, 0), UDim2.new(0, 100, 0, 35), function()
    playMusic("Jumpstyle_bgm.ogg", true)
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
        print("")
    else
        for _, button in pairs(allButtons) do
            button.Visible = true
        end
        Frame.Size = UDim2.new(0, 500, 0, 250)
        menuImage.Visible = true
        print("")
    end
end)

-- 防止角色死亡后脚本出错
player.CharacterAdded:Connect(function()
    stopMusic()
end)

