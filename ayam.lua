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
local isAutoBestTowerActive = false 
local bestTowerDelay = 5

-- Setup GUI Panel
local gui = Instance.new("ScreenGui")
gui.Name = "AutoFarmPanel"
gui.ResetOnSpawn = false
gui.Parent = targetGuiParent

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 316)
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
title.Text = "     Auto Farm [Extended Panel]"
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = frame

local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 6)
titleCorner.Parent = title

-- LABEL MONITOR TOWER
local debugLabel = Instance.new("TextLabel")
debugLabel.Size = UDim2.new(1, -16, 0, 24)
debugLabel.Position = UDim2.new(0, 8, 0, 34)
debugLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
debugLabel.TextColor3 = Color3.fromRGB(180, 50, 50)
debugLabel.TextSize = 10
debugLabel.Font = Enum.Font.Code
debugLabel.Text = "Auto Surrender: OFF"
debugLabel.Parent = frame

local debugCorner = Instance.new("UICorner")
debugCorner.CornerRadius = UDim.new(0, 4)
debugCorner.Parent = debugLabel

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
    box.Text = "" 
    box.Parent = frame

    local boxCorner = Instance.new("UICorner")
    boxCorner.CornerRadius = UDim.new(0, 4)
    boxCorner.Parent = box

    return btn, box
end

local rebirthBtn = createButton("Auto Rebirth", 64, isAutoRebirthActive)
local towerBtn, towerDelayBox = createButtonWithRightInput("Auto Tower", isAutoTowerActive, "Delay", 100)
local surrenderBtn, surrenderInputBox = createButtonWithRightInput("Auto Surrender", isAutoSurrenderActive, "Target Floor", 136)
local upgradeFeederBtn = createButton("Auto Upgrade Feeder", 172, isAutoUpgradeFeederActive)
local upgradeRecyclerBtn = createButton("Auto Upgrade Recycler", 208, isAutoUpgradeRecyclerActive)
local bestTowerBtn, bestTowerDelayBox = createButtonWithRightInput("Auto Best Tower", isAutoBestTowerActive, "Delay", 244)

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
    if not isAutoSurrenderActive then
        debugLabel.Text = "Auto Surrender: OFF"
        debugLabel.TextColor3 = Color3.fromRGB(180, 50, 50)
    end
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

bestTowerBtn.MouseButton1Click:Connect(function()
    isAutoBestTowerActive = not isAutoBestTowerActive
    bestTowerBtn.BackgroundColor3 = isAutoBestTowerActive and Color3.fromRGB(0, 160, 90) or Color3.fromRGB(180, 50, 50)
    bestTowerBtn.Text = "Auto Best Tower: " .. (isAutoBestTowerActive and "ON" or "OFF")
end)

towerDelayBox.FocusLost:Connect(function()
    local val = tonumber(towerDelayBox.Text)
    if val and val > 0 then towerDelay = val else towerDelayBox.Text = "" end
end)

surrenderInputBox.FocusLost:Connect(function()
    local val = tonumber(surrenderInputBox.Text)
    if val and val > 0 then targetSurrenderFloor = val else surrenderInputBox.Text = "" end
end)

bestTowerDelayBox.FocusLost:Connect(function()
    local val = tonumber(bestTowerDelayBox.Text)
    if val and val > 0 then bestTowerDelay = val else bestTowerDelayBox.Text = "" end
end)

-- LOOP 1: Auto Rebirth
task.spawn(function()
    while true do
        if isAutoRebirthActive and RemotesModule then
            pcall(function() RemotesModule.invoke(RemotesModule.defs.Rebirth) end)
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

-- LOOP 3: Auto Surrender (Aman, mati jika tombol OFF)
task.spawn(function()
    while true do
        if isAutoSurrenderActive then
            local targetValObj = nil
            for _, obj in ipairs(player:GetDescendants()) do
                if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                    local name = obj.Name:lower()
                    if name:find("tower") or name:find("best") then
                        targetValObj = obj
                        break
                    end
                end
            end

            local customTarget = tonumber(surrenderInputBox.Text)
            local activeTarget = (customTarget and customTarget > 0) and customTarget or 60
            local currentFloorNum = nil
            
            if targetValObj then
                currentFloorNum = targetValObj.Value
                debugLabel.Text = targetValObj.Name .. ": " .. tostring(currentFloorNum)
                debugLabel.TextColor3 = Color3.fromRGB(0, 255, 120)
            else
                debugLabel.Text = "Tower Value: Mencari..."
                debugLabel.TextColor3 = Color3.fromRGB(255, 165, 0)
            end
            
            if RemotesModule and currentFloorNum and type(currentFloorNum) == "number" and currentFloorNum >= activeTarget then
                pcall(function()
                    if RemotesModule.defs and RemotesModule.defs.TowerSurrender then
                        RemotesModule.invoke(RemotesModule.defs.TowerSurrender)
                    end
                end)
                task.wait(5)
            end
        end
        task.wait(1)
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

-- LOOP 5: Auto Skip Continue
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

-- LOOP 7: Auto Best Tower (Aman dari fungsi surrender/leave)
task.spawn(function()
    while true do
        if isAutoBestTowerActive then 
            pcall(function()
                local detectedBestFloor = 1
                for _, obj in ipairs(player:GetDescendants()) do
                    if obj:IsA("IntValue") or obj:IsA("NumberValue") then
                        local nameLower = obj.Name:lower()
                        if nameLower:find("tower") or nameLower:find("best") then
                            if obj.Value > 1 then
                                detectedBestFloor = obj.Value
                                break
                            end
                        end
                    end
                end

                for _, obj in ipairs(ReplicatedStorage:GetDescendants()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("RemoteFunction") then
                        local nameLower = obj.Name:lower()
                        if (nameLower:find("tower") or nameLower:find("elevator") or nameLower:find("rung")) 
                           and not nameLower:find("surrender") 
                           and not nameLower:find("leave") 
                           and not nameLower:find("exit") 
                           and not nameLower:find("quit") then
                            
                            if obj:IsA("RemoteFunction") then
                                pcall(function() obj:InvokeServer(detectedBestFloor) end)
                            elseif obj:IsA("RemoteEvent") then
                                pcall(function() obj:FireServer(detectedBestFloor) end)
                            end
                        end
                    end
                end
            end)
        end
        
        local currentBestDelay = tonumber(bestTowerDelayBox.Text)
        if not currentBestDelay or currentBestDelay <= 0 then
            currentBestDelay = bestTowerDelay
        end
        
        task.wait(currentBestDelay)
    end
end)