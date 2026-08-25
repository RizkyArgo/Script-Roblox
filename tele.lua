-- Pastikan menghapus UI lama jika script dijalankan ulang
local CoreGui = gethui() or game:GetService("CoreGui")
if CoreGui:FindFirstChild("UniversalEggFinder") then
    CoreGui.UniversalEggFinder:Destroy()
end

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

-- Setup GUI Panel utama
local gui = Instance.new("ScreenGui")
gui.Name = "UniversalEggFinder"
gui.Parent = CoreGui

local frame = Instance.new("ScrollingFrame")
frame.Size = UDim2.new(0, 400, 0, 420)
frame.Position = UDim2.new(0.02, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.ScrollBarThickness = 6
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 15
title.Font = Enum.Font.SourceSansBold
title.Text = "Universal Egg Finder & Safe Tween Tele"
title.Parent = frame

local layout = Instance.new("UIListLayout")
layout.Parent = frame
layout.SortOrder = Enum.SortOrder.LayoutOrder

-- Fungsi Tween Teleport (Aman dari anti-cheat & anti-mati)
local function safeTweenTeleport(targetObj)
    local character = player.Character
    if not character then return end
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return end

    local targetPos = nil
    
    -- Ambil posisi dari BasePart atau Model
    if targetObj:IsA("BasePart") then
        targetPos = targetObj.Position
    elseif targetObj:IsA("Model") then
        targetPos = (targetObj.PrimaryPart and targetObj.PrimaryPart.Position) or targetObj:GetPivot().Position
    end

    if targetPos then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then humanoid.PlatformStand = true end

        -- Hitung posisi tujuan (ditambah 3 studs ke atas biar tidak tembus lantai)
        local destination = CFrame.new(targetPos + Vector3.new(0, 3, 0))
        
        -- Durasi 0.5 detik (terasa seperti meluncur cepat, server menganggapnya gerakan lari)
        local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
        local tween = TweenService:Create(rootPart, tweenInfo, {CFrame = destination})
        
        tween:Play()
        
        tween.Completed:Connect(function()
            if humanoid then humanoid.PlatformStand = false end
        end)
    end
end

-- Fungsi untuk memindai dan menampilkan hasil secara live
task.spawn(function()
    while true do
        -- Hapus baris lama kecuali judul
        for _, child in ipairs(frame:GetChildren()) do
            if child:IsA("Frame") then
                child:Destroy()
            end
        end

        local foundEggs = {}
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name:lower():find("eggfitbounds") and (obj:IsA("BasePart") or obj:IsA("Model")) then
                table.insert(foundEggs, obj)
            end
        end

        -- Tampilkan hasil temuan ke panel UI
        for i, egg in ipairs(foundEggs) do
            local itemFrame = Instance.new("Frame")
            itemFrame.Size = UDim2.new(1, 0, 0, 35)
            itemFrame.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(40, 40, 40) or Color3.fromRGB(35, 35, 35)
            itemFrame.BorderSizePixel = 0
            itemFrame.Parent = frame

            local itemLayout = Instance.new("UIListLayout")
            itemLayout.FillDirection = Enum.FillDirection.Horizontal
            itemLayout.Parent = itemFrame

            -- Teks Label Nama
            local itemLabel = Instance.new("TextLabel")
            itemLabel.Size = UDim2.new(0.6, 0, 1, 0)
            itemLabel.BackgroundTransparency = 1
            itemLabel.TextColor3 = Color3.fromRGB(255, 200, 0)
            itemLabel.TextSize = 12
            itemLabel.Font = Enum.Font.Code
            itemLabel.Text = " [" .. i .. "] " .. egg.Name
            itemLabel.Parent = itemFrame

            -- Tombol TWEEN TELE
            local teleButton = Instance.new("TextButton")
            teleButton.Size = UDim2.new(0.4, 0, 1, 0)
            teleButton.BackgroundColor3 = Color3.fromRGB(0, 140, 100)
            teleButton.Text = "TWEEN TELE"
            teleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            teleButton.TextSize = 11
            teleButton.Font = Enum.Font.SourceSansBold
            teleButton.Parent = itemFrame

            -- Aksi Klik Tombol
            teleButton.MouseButton1Click:Connect(function()
                safeTweenTeleport(egg)
            end)
        end

        task.wait(2)
    end
end)