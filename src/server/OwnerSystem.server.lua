-- OWNER SYSTEM
-- Owner: Dimulka_717
-- This script belongs in ServerScriptService.

local Players = game:GetService("Players")
local BadgeService = game:GetService("BadgeService")

local OWNER_USER_ID = 9033235011
local BADGE_ID = 2164601194827666

local ownerHasJoined = false

local function setAdminFlag(player, isAdmin)
	local flag = player:FindFirstChild("IsAdmin")

	if not flag then
		flag = Instance.new("BoolValue")
		flag.Name = "IsAdmin"
		flag.Parent = player
	end

	flag.Value = isAdmin
end

local function awardBadge(player)
	task.spawn(function()
		local success, hasBadge = pcall(function()
			return BadgeService:UserHasBadgeAsync(player.UserId, BADGE_ID)
		end)

		if not success then
			warn("[OwnerSystem] Could not check badge for " .. player.Name .. ": " .. tostring(hasBadge))
			return
		end

		if hasBadge then
			return
		end

		local awarded, result = pcall(function()
			return BadgeService:AwardBadge(player.UserId, BADGE_ID)
		end)

		if not awarded or result == false then
			warn("[OwnerSystem] Could not award badge to " .. player.Name .. ": " .. tostring(result))
		end
	end)
end

local function onPlayerAdded(player)
	local isOwner = player.UserId == OWNER_USER_ID
	setAdminFlag(player, isOwner)

	if isOwner then
		ownerHasJoined = true

		-- Give the badge to everyone currently in this server.
		for _, currentPlayer in ipairs(Players:GetPlayers()) do
			awardBadge(currentPlayer)
		end
	elseif ownerHasJoined then
		-- Also give the badge to players who join after the owner.
		awardBadge(player)
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)

-- Handle players already present if the script starts after they joined.
for _, player in ipairs(Players:GetPlayers()) do
	onPlayerAdded(player)
end
