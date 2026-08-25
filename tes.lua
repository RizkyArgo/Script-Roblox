-- Pastikan menghapus UI lama jika script dijalankan ulang
local CoreGui = gethui() or game:GetService("CoreGui")
if CoreGui:FindFirstChild("AutoFarmPanel") then
    CoreGui.AutoFarmPanel:Destroy()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ambil modul Remotes dengan aman
local RemotesModule = nil
pcall(function()
    RemotesModule = require(ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes"))
end)

local player = Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")

-- Mengambil Controller dengan proteksi aman (tidak bakal error nil)
local CampaignController, CoopController = nil, nil
pcall(function()
    CampaignController = require(playerScripts:WaitForChild("Features"):WaitForChild("Battle"):WaitForChild("campaign"):WaitForChild("CampaignController"))
end)
pcall(function()
    CoopController = require(playerScripts:WaitForChild("Features"):WaitForChild("Coop"):WaitForChild("CoopController"))
end)

-- Status Fitur & Pengaturan Delay
local isAutoRebirthActive = false
local rebirthDelay = 2

local isAutoTowerActive = false
local towerDelay = 4

local isAutoUpgradeFeederActive = false
local isAutoSkipContinueActive = true

-- Setup GUI Panel
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmPanel"
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 280)
frame.Position = UDim2.new(0.02, 0, 0.60, 0)
frame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
frame.BorderSizePixel = 0
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 6)
corner.Parent = frame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.BackgroundColor3 = Color3.fromRGB(25, 25, 28)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 12
title.Font = Enum.Font.GothamBold
title.Text = "    Auto Farm Panel"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 6)
titleCorner.Parent = title

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 30, 0, 30)
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.BackgroundTransparency = 1
closeBtn.TextColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.TextSize = 13
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.Parent = frame

closeBtn.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local function createButton(text, yPos, defaultState)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 30)
    btn.Position = UDim2.new(0, 8, 0, yPos)
    btn.BackgroundColor3 = defaultState and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(180, 50, 50)
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.Font = Enum.Font.GothamBold
    btn.Text = text .. ": " .. (defaultState and "ON" or "OFF")
    btn.Parent = frame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 4)
    btnCorner.Parent = btn
    return btn
end

local function createDelayInput(placeholderText, defaultVal, yPos)
    local box = Instance.new("TextBox")
    box.Size = UDim2.new(1, -16, 0, 24)
    box.Position = UDim2.new(0, 8, 0, yPos)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    box.TextSize = 10
    box.Font = Enum.Font.Gotham
    box.PlaceholderText = placeholderText
    box.Text = tostring(defaultVal)
    box.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box
    return box
end

local rebirthBtn = createButton("Auto Rebirth", 36, isAutoRebirthActive)
local rebirthDelayBox = createDelayInput("Delay Rebirth (detik)", rebirthDelay, 70)

local towerBtn = createButton("Auto Start Tower", 100, isAutoTowerActive)
local towerDelayBox = createDelayInput("Delay Tower (detik)", towerDelay, 134)

local upgradeFeederBtn = createButton("Auto Upgrade Feeder", 164, isAutoUpgradeFeederActive)
local skipContinueBtn = createButton("Auto Skip Continue", 198, isAutoSkipContinueActive)

rebirthBtn.MouseButton1Click:Connect(function()
    isAutoRebirthActive = not isAutoRebirthActive
    rebirthBtn.BackgroundColor3 = isAutoRebirthActive and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(180, 50, 50)
    rebirthBtn.Text = "Auto Rebirth: " .. (isAutoRebirthActive and "ON" or "OFF")
end)

towerBtn.MouseButton1Click:Connect(function()
    isAutoTowerActive = not isAutoTowerActive
    towerBtn.BackgroundColor3 = isAutoTowerActive and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(180, 50, 50)
    towerBtn.Text = "Auto Start Tower: " .. (isAutoTowerActive and "ON" or "OFF")
end)

upgradeFeederBtn.MouseButton1Click:Connect(function()
    isAutoUpgradeFeederActive = not isAutoUpgradeFeederActive
    upgradeFeederBtn.BackgroundColor3 = isAutoUpgradeFeederActive and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(180, 50, 50)
    upgradeFeederBtn.Text = "Auto Upgrade Feeder: " .. (isAutoUpgradeFeederActive and "ON" or "OFF")
end)

skipContinueBtn.MouseButton1Click:Connect(function()
    isAutoSkipContinueActive = not isAutoSkipContinueActive
    skipContinueBtn.BackgroundColor3 = isAutoSkipContinueActive and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(180, 50, 50)
    skipContinueBtn.Text = "Auto Skip Continue: " .. (isAutoSkipContinueActive and "ON" or "OFF")
end)

rebirthDelayBox.FocusLost:Connect(function()
    local val = tonumber(rebirthDelayBox.Text)
    if val and val > 0 then rebirthDelay = val else rebirthDelayBox.Text = tostring(rebirthDelay) end
end)

towerDelayBox.FocusLost:Connect(function()
    local val = tonumber(towerDelayBox.Text)
    if val and val > 0 then towerDelay = val else towerDelayBox.Text = tostring(towerDelay) end
end)

-- LOOP 1: Auto Rebirth
task.spawn(function()
    while true do
        if isAutoRebirthActive and RemotesModule then
            pcall(function()
                if RemotesModule.defs and RemotesModule.defs.Rebirth then
                    RemotesModule.invoke(RemotesModule.defs.Rebirth)
                end
            end)
        end
        task.wait(rebirthDelay)
    end
end)

-- LOOP 2: Auto Start Tower
task.spawn(function()
    while true do
        if isAutoTowerActive then
            pcall(function()
                if CampaignController and type(CampaignController.startRun) == "function" then
                    CampaignController.startRun()
                elseif CampaignController and type(CampaignController.start) == "function" then
                    CampaignController.start()
                end

                if RemotesModule and RemotesModule.defs then
                    if RemotesModule.defs.CampaignStart then
                        RemotesModule.invoke(RemotesModule.defs.CampaignStart)
                    elseif RemotesModule.defs.TowerStart then
                        RemotesModule.invoke(RemotesModule.defs.TowerStart)
                    end
                end
            end)
        end
        task.wait(towerDelay)
    end
end)

-- LOOP 3: Auto Upgrade Feeder
task.spawn(function()
    while true do
        if isAutoUpgradeFeederActive and RemotesModule then
            pcall(function()
                if RemotesModule.defs then
                    if RemotesModule.defs.BuyGenerator then
                        for i = 1, 6 do
                            RemotesModule.invoke(RemotesModule.defs.BuyGenerator, i)
                            task.wait(0.1)
                        end
                    end
                    if RemotesModule.defs.UpgradeGenerator then
                        for i = 1, 6 do
                            RemotesModule.invoke(RemotesModule.defs.UpgradeGenerator, i)
                            task.wait(0.1)
                        end
                    end
                end
            end)
        end
        task.wait(1.5)
    end
end)

-- LOOP 4: Auto Skip Continue
task.spawn(function()
    pcall(function()
        if RemotesModule and RemotesModule.defs and RemotesModule.defs.TowerContinueOffer then
            RemotesModule.onClient(RemotesModule.defs.TowerContinueOffer, function(p1)
                if isAutoSkipContinueActive and type(p1) == "table" and p1.open == true then
                    task.wait(1)
                    pcall(function()
                        if RemotesModule.defs.TowerContinueDecline then
                            RemotesModule.fire(RemotesModule.defs.TowerContinueDecline)
                        end
                    end)
                end
            end)
        end
    end)
end)
