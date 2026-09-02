-- Pastikan menghapus UI lama jika script dijalankan ulang
local CoreGui = game:GetService("CoreGui")
local success, protectedGui = pcall(function()
    return gethui()
end)

local targetGuiParent = (success and protectedGui) or CoreGui

if targetGuiParent:FindFirstChild("AutoFarmPanel") then
    targetGuiParent.AutoFarmPanel:Destroy()
end

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local RemotesModule = nil
pcall(function()
    RemotesModule = require(ReplicatedStorage:WaitForChild("Core"):WaitForChild("Remotes"))
end)

local player = Players.LocalPlayer
local playerScripts = player:WaitForChild("PlayerScripts")

-- Mengambil Controller yang dibutuhkan
local CampaignController, CoopController, DataController = nil, nil, nil
pcall(function()
    CampaignController = require(playerScripts:WaitForChild("Features"):WaitForChild("Battle"):WaitForChild("campaign"):WaitForChild("CampaignController"))
end)
pcall(function()
    CoopController = require(playerScripts:WaitForChild("Features"):WaitForChild("Coop"):WaitForChild("CoopController"))
end)
pcall(function()
    DataController = require(playerScripts:WaitForChild("Core"):WaitForChild("Data"):WaitForChild("DataController"))
end)

-- Status Fitur & Pengaturan
local isAutoRebirthActive = false
local rebirthDelay = 0.1

local isAutoTowerActive = false
local towerDelay = 4

local isAutoSurrenderActive = false
local targetSurrenderFloor = 60

local isAutoUpgradeFeederActive = false
local isAutoSkipContinueActive = true 
local isAutoUpgradeRecyclerActive = false

-- Setup GUI Panel (Tinggi diubah menjadi 216 agar pas)
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmPanel"
gui.ResetOnSpawn = false
gui.Parent = targetGuiParent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 216)
frame.Position = UDim2.new(0.02, 0, 0.48, 0)
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
title.Text = "     Auto Farm"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 6)
titleCorner.Parent = title

-- FITUR DRAGGABLE
local dragging, dragInput, dragStart, startPos
title.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = frame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

title.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Tombol Close [X]
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

-- Fungsi Pembuat Tombol Standar
local function createButton(text, yPos, defaultState)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 28)
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

-- Fungsi Pembuat Tombol dengan Input Kosong di Kanan
local function createButtonWithRightInput(text, defaultState, placeholderText, yPos)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.62, -10, 0, 28)
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

    local box = Instance.new("TextBox")
    box.Size = UDim2.new(0.38, -10, 0, 28)
    box.Position = UDim2.new(0.62, 2, 0, yPos)
    box.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.PlaceholderColor3 = Color3.fromRGB(140, 140, 140)
    box.TextSize = 10
    box.Font = Enum.Font.Gotham
    box.PlaceholderText = placeholderText
    box.Text = "" -- Memastikan teks di dalam box kosong
    box.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box

    return btn, box
end

-- Susunan Komponen UI
local rebirthBtn = createButton("Auto Rebirth", 36, isAutoRebirthActive)
local towerBtn, towerDelayBox = createButtonWithRightInput("Auto Tower", isAutoTowerActive, "Delay", 72)
local surrenderBtn, surrenderInputBox = createButtonWithRightInput("Auto Surrender", isAutoSurrenderActive, "Detik", 108)
local upgradeFeederBtn = createButton("Auto Upgrade Feeder", 144, isAutoUpgradeFeederActive)
local upgradeRecyclerBtn = createButton("Auto Upgrade Recycler", 180, isAutoUpgradeRecyclerActive)

-- Aksi Tombol On/Off
rebirthBtn.MouseButton1Click:Connect(function()
    isAutoRebirthActive = not isAutoRebirthActive
    rebirthBtn.BackgroundColor3 = isAutoRebirthActive and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(180, 50, 50)
    rebirthBtn.Text = "Auto Rebirth: " .. (isAutoRebirthActive and "ON" or "OFF")
end)

towerBtn.MouseButton1Click:Connect(function()
    isAutoTowerActive = not isAutoTowerActive
    towerBtn.BackgroundColor3 = isAutoTowerActive and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(180, 50, 50)
    towerBtn.Text = "Auto Tower: " .. (isAutoTowerActive and "ON" or "OFF")
end)

surrenderBtn.MouseButton1Click:Connect(function()
    isAutoSurrenderActive = not isAutoSurrenderActive
    surrenderBtn.BackgroundColor3 = isAutoSurrenderActive and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(180, 50, 50)
    surrenderBtn.Text = "Auto Surrender: " .. (isAutoSurrenderActive and "ON" or "OFF")
end)

upgradeFeederBtn.MouseButton1Click:Connect(function()
    isAutoUpgradeFeederActive = not isAutoUpgradeFeederActive
    upgradeFeederBtn.BackgroundColor3 = isAutoUpgradeFeederActive and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(180, 50, 50)
    upgradeFeederBtn.Text = "Auto Upgrade Feeder: " .. (isAutoUpgradeFeederActive and "ON" or "OFF")
end)

upgradeRecyclerBtn.MouseButton1Click:Connect(function()
    isAutoUpgradeRecyclerActive = not isAutoUpgradeRecyclerActive
    upgradeRecyclerBtn.BackgroundColor3 = isAutoUpgradeRecyclerActive and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(180, 50, 50)
    upgradeRecyclerBtn.Text = "Auto Upgrade Recycler: " .. (isAutoUpgradeRecyclerActive and "ON" or "OFF")
end)

-- Simpan Nilai Kotak Input (Jika diisi user, ubah variabel. Jika kosong, pakai default)
towerDelayBox.FocusLost:Connect(function()
    local val = tonumber(towerDelayBox.Text)
    if val and val > 0 then 
        towerDelay = val 
    else 
        towerDelayBox.Text = "" 
    end
end)

surrenderInputBox.FocusLost:Connect(function()
    local val = tonumber(surrenderInputBox.Text)
    if val and val > 0 then 
        targetSurrenderFloor = val 
    else 
        surrenderInputBox.Text = "" 
    end
end)

-- LOOP 1: Auto Rebirth (Fix 0.1)
task.spawn(function()
    while true do
        if isAutoRebirthActive and RemotesModule then
            pcall(function()
                RemotesModule.invoke(RemotesModule.defs.Rebirth)
            end)
        end
        task.wait(rebirthDelay)
    end
end)

-- LOOP 2: Auto Start Tower
task.spawn(function()
    while true do
        if isAutoTowerActive and RemotesModule then
            pcall(function()
                if CampaignController and type(CampaignController.startRun) == "function" then
                    CampaignController.startRun()
                elseif CampaignController and type(CampaignController.start) == "function" then
                    CampaignController.start()
                end

                if RemotesModule.defs.CampaignStart then
                    RemotesModule.invoke(RemotesModule.defs.CampaignStart)
                elseif RemotesModule.defs.TowerStart then
                    RemotesModule.invoke(RemotesModule.defs.TowerStart)
                elseif RemotesModule.defs.StartGame then
                    RemotesModule.invoke(RemotesModule.defs.StartGame)
                elseif RemotesModule.defs.StartRun then
                    RemotesModule.invoke(RemotesModule.defs.StartRun)
                end
            end)
        end
        task.wait(towerDelay)
    end
end)

-- LOOP 3: Auto Surrender
task.spawn(function()
    while true do
        if isAutoSurrenderActive and RemotesModule then
            local waitTime = tonumber(surrenderInputBox.Text) or targetSurrenderFloor
            task.wait(waitTime)
            
            pcall(function()
                if isAutoSurrenderActive and RemotesModule.defs.TowerSurrender then
                    RemotesModule.invoke(RemotesModule.defs.TowerSurrender)
                end
            end)
        else
            task.wait(2)
        end
    end
end)

-- LOOP 4: Auto Buy & Auto Upgrade Feeder
task.spawn(function()
    while true do
        if isAutoUpgradeFeederActive and RemotesModule then
            pcall(function()
                pcall(function()
                    if RemotesModule.defs.BuyGenerator then
                        for i = 1, 6 do
                            RemotesModule.invoke(RemotesModule.defs.BuyGenerator, i)
                            task.wait(0.05)
                        end
                    elseif RemotesModule.defs.PurchaseGenerator then
                        for i = 1, 6 do
                            RemotesModule.invoke(RemotesModule.defs.PurchaseGenerator, i)
                            task.wait(0.05)
                        end
                    end
                end)

                pcall(function()
                    if RemotesModule.defs.UpgradeGenerator then
                        for i = 1, 6 do
                            RemotesModule.invoke(RemotesModule.defs.UpgradeGenerator, i)
                            task.wait(0.05)
                        end
                    elseif CoopController and type(CoopController.coopView) == "function" then
                        local data = CoopController.coopView()
                        if data and data.gens then
                            for slotNum, _ in pairs(data.gens) do
                                CoopController.upgradeGenerator(slotNum)
                                task.wait(0.1)
                            end
                        end
                    end
                end)
            end)
        end
        task.wait(1.5)
    end
end)

-- LOOP 5: Auto Skip Continue (Otomatis ON Permanen di Background)
task.spawn(function()
    pcall(function()
        if RemotesModule and RemotesModule.onClient and RemotesModule.defs and RemotesModule.defs.TowerContinueOffer then
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

-- LOOP 6: Auto Upgrade Recycler
task.spawn(function()
    while true do
        if isAutoUpgradeRecyclerActive and RemotesModule then
            pcall(function()
                if RemotesModule.defs.UpgradeRecycler then
                    RemotesModule.invoke(RemotesModule.defs.UpgradeRecycler)
                end
            end)
        end
        task.wait(1)
    end
end)