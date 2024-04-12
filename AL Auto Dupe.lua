--[[_G.Settings = {
	OwnerUserID = 1,
	ItemsToDupe = {
		"Radiant Elixir",
		"Chaos Orb"
	},
	MaxAmountToDrop = 10,
	DupeWait = 1.8,
	
	-- DO NOT TOUCH UNLESS TRYING TO HELP ME!
	Debug = {
		Notifications = true,
		Offset = CFrame.new(-2.5,0,0),
		LoopPlayerTP = false,
	}
}]]


local _settings = _G.Settings
local _debug = _settings.Debug
local players = game:GetService("Players")
local starterGui = game:GetService("StarterGui")
local replicatedStorage = game:GetService("ReplicatedStorage")
local teleportService = game:GetService("TeleportService")

local remotes = replicatedStorage:WaitForChild("Remotes")
local inventoryRemote = remotes:WaitForChild("Information"):WaitForChild("InventoryManage")
local updateHotbar = remotes:WaitForChild("Data"):WaitForChild("UpdateHotbar")

local player = players.LocalPlayer
local inventory = player.Backpack:WaitForChild("Tools")
local character = player.Character or player.CharacterAdded:Wait()
local root = character.HumanoidRootPart


local function assignSeparateThread(func)
	task.spawn(func)
end
local function getItemCount(itemName)
	local amount = 0
	for _, v in pairs(inventory:GetChildren()) do
		if v.Name == itemName then
			amount += 1
		end
	end
	
	return amount
end
local function checkValidItem(itemName)
	local itemExists = inventory:WaitForChild(itemName, 2)
	local count = getItemCount(itemName)
	
	return itemExists ~= nil, itemExists, count 
end
local function sendNotification(_table)
	local title = _table.title or "AL Auto Dupe"
	local text = _table.text or "No Message"
	local duration = _table.duration or .5
	
	if not _debug.Notifications then return end
	starterGui:SetCore("SendNotification",{
		Title = title;
		Text = text;
		Duration = duration;
	})
end
local function findPlayerFromID(id)
	local _player, _hasCharacter
	
	for _, v in pairs(players:GetPlayers()) do 
		 if v.UserId == id then
			_player = v 
			if v.Character then 
				_hasCharacter = v.Character
			end
		end
	end

	return _player, _hasCharacter
end

local ownerInGame, ownerCharacter = findPlayerFromID(_settings.OwnerUserID)
if not ownerInGame or not ownerCharacter then 
	local errorType = (not ownerInGame) and "Owner not in game" or "Owner has no character (get closer to them)"
	sendNotification({
		["title"] = "ERROR!",
		["text"] = errorType,
		["duration"] = 5,
	})
	
	return
end


sendNotification({
	["title"] = "AL - Dupe",
	["text"] = "Attempting to teleport to character...",
	["duration"] = .5,
})
while task.wait() do
	character:SetPrimaryPartCFrame((ownerCharacter.PrimaryPart.CFrame*_debug.Offset) * CFrame.Angles(0,math.rad(180),0))
	local distance = (ownerCharacter.PrimaryPart.Position-root.Position).Magnitude
	
	if distance <= 5 then
		if not _settings.Debug.LoopPlayerTP then
			break
		end
	end
end
sendNotification({
	["title"] = "AL - Dupe",
	["text"] = "Close enough to player! Beginning counting items...",
	["duration"] = .5,
})

local ownedItems = {}
for i, v in pairs(_settings.ItemsToDupe) do 
	local owned, itemPath, itemAmount = checkValidItem(v)
	if not owned then continue end 
	table.insert(ownedItems, {
		["Path"] = itemPath,
		["Amount"] = itemAmount,
		["Name"] = v
	})
end
task.wait(.5)
sendNotification({
	["title"] = "AL - Dupe",
	["text"] = "Got items! Check F9 to see content.",
	["duration"] = 1,
})
for i, v in pairs(ownedItems) do 
	print("-----\n"..i.. "\n"..table.concat(v, " "))	
end

task.wait(1)
assignSeparateThread(function()
	while task.wait() do 
		for i = 1,3 do 
			updateHotbar:FireServer({["1"] = "\255"})
			updateHotbar:FireServer({["\255"] = true})
		end 
	end 
end)

task.wait(_settings.DupeWait)

local storedCount = {}
for _, item in ownedItems do 
	local path = item.Path
	local amount = item.Amount
	local itemName = item.Name 
	storedCount[itemName] = math.clamp(amount, 0, _settings.MaxAmountToDrop)
	
	if path.Parent ~= nil and amount > 0 then 
		sendNotification({
			["title"] = "AL - Dupe",
			["text"] = ("Dropping: " .. itemName),
			["duration"] = 1,
		})
		while task.wait() do 
			local currentAmount = getItemCount(itemName)
			if currentAmount <= 0 then 
				break
			end
			inventoryRemote:FireServer("Drop", itemName)
		end
	end
end
task.wait(.2)
player:Kick("On Purpose :3")
teleportService:Teleport(game.PlaceId, player)
