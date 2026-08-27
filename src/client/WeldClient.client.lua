local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer
local weldRequest = ReplicatedStorage:WaitForChild("WeldRequest")

-- 建立 UI 介面
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "PlayerWeldUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 260)
frame.Position = UDim2.new(0.05, 0, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Select Player"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.BorderSizePixel = 0
title.Parent = frame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, -10, 1, -75)
scrollFrame.Position = UDim2.new(0, 5, 0, 35)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
scrollFrame.Parent = frame

local uiListLayout = Instance.new("UIListLayout")
uiListLayout.Padding = UDim.new(0, 3)
uiListLayout.Parent = scrollFrame

local detachBtn = Instance.new("TextButton")
detachBtn.Size = UDim2.new(1, -10, 0, 30)
detachBtn.Position = UDim2.new(0, 5, 1, -35)
detachBtn.Text = "Unweld / Detach"
detachBtn.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
detachBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
detachBtn.BorderSizePixel = 0
detachBtn.Parent = frame

detachBtn.MouseButton1Click:Connect(function()
	weldRequest:FireServer("Unweld")
end)

-- 動態更新玩家列表
local function refreshPlayerList()
	for _, child in pairs(scrollFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 25)
			btn.Text = player.DisplayName
			btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
			btn.TextColor3 = Color3.fromRGB(255, 255, 255)
			btn.BorderSizePixel = 0
			btn.Parent = scrollFrame

			btn.MouseButton1Click:Connect(function()
				weldRequest:FireServer("Weld", player)
			end)
		end
	end
end

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)
refreshPlayerList()

-- 虛空死亡偵測
RunService.Heartbeat:Connect(function()
	local char = LocalPlayer.Character
	if not char then return end

	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChildOfClass("Humanoid")

	if hrp and humanoid and humanoid.Health > 0 then
		if hrp.Position.Y <= workspace.FallenPartsDestroyHeight then
			weldRequest:FireServer("Unweld")
			humanoid.Health = 0
		end
	end
end)
