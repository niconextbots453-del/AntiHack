local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- 自動建立兩端通訊用的 RemoteEvent
local weldRequest = ReplicatedStorage:FindFirstChild("WeldRequest")
if not weldRequest then
	weldRequest = Instance.new("RemoteEvent")
	weldRequest.Name = "WeldRequest"
	weldRequest.Parent = ReplicatedStorage
end

local function removePlayerWeld(character)
	local hrp = character:FindFirstChild("HumanoidRootPart")
	if hrp then
		local existingWeld = hrp:FindFirstChild("PlayerAttachWeld")
		if existingWeld then
			existingWeld:Destroy()
		end
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		humanoid.PlatformStand = false
	end
end

weldRequest.OnServerEvent:Connect(function(player, action, targetPlayer)
	local char = player.Character
	if not char or not char:FindFirstChild("HumanoidRootPart") then return end

	if action == "Weld" and targetPlayer and targetPlayer.Character then
		local targetHRP = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
		local myHRP = char.HumanoidRootPart
		local myHumanoid = char:FindFirstChildOfClass("Humanoid")

		if targetHRP and myHRP then
			removePlayerWeld(char)

			-- 先拉至目標下方 1.5 studs 再進行伺服器焊接
			myHRP.CFrame = targetHRP.CFrame * CFrame.new(0, -1.5, 0)

			local weld = Instance.new("Weld")
			weld.Name = "PlayerAttachWeld"
			weld.Part0 = targetHRP
			weld.Part1 = myHRP
			weld.C0 = CFrame.new(0, -1.5, 0)
			weld.Parent = myHRP

			if myHumanoid then
				myHumanoid.PlatformStand = true
			end
		end
	elseif action == "Unweld" then
		removePlayerWeld(char)
	end
end)
