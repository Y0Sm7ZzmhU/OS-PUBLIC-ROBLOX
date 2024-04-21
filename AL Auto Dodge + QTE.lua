--[[_G.Settings = {
    "QTE Timer" = 1
}]]

local settings = _G.Settings or {}
local _timer = if settings["QTE Timer"] then settings["QTE Timer"] else 1
local legitTimer = math.clamp(_timer,.2, 3)
local baseToString = {
    ["Wizard"] = "MagicQTE", 
    ["Thief"] = "DaggerQTE", 
    ["Slayer"] = "SpearQTE", 
    ["Matrial Artist"] = "FistQTE", 
    ["Warrior"] = "SwordQTE"
}
local replicatedStorage = game:GetService("ReplicatedStorage")
local players = game:GetService("Players")
local player = players.LocalPlayer 

local remotes = replicatedStorage:WaitForChild("Remotes")
local actionRemote = remotes:WaitForChild("Information"):WaitForChild("RemoteFunction")

local playerClass, breakTimer = nil, tick()

local function getClass()
    while task.wait() do 
        local result, class = pcall(function()
            return player.PlayerGui.StatMenu.Holder.ContentFrame.Stats.Body.RightColumn.Content.BaseClass.Type.Text
        end)
        if result then 
            return class
        end
    end
end 
local playerClass = getClass()

task.spawn(function()
    while task.wait() do 
        actionRemote:FireServer({[1] = true, [2] = true}, "DodgeMinigame")
    end
end)

if not playerClass or playerClass == "None" then 
    warn("Player has no class!")

    while task.wait(2) do 
        local class = getClass()
        
        if class ~= "None" then 
            print("Auto dodge setup")
            playerClass = class
            break
        end 
    end 
end 

local classTranslation = baseToString[playerClass]
local classUi = player.PlayerGui.Combat[classTranslation]

classUi:GetPropertyChangedSignal("Visible"):Connect(function()
    local newValue = classUi.Visible 
    if newValue then 
        classUi.Visible = false
        task.wait(math.clamp(legitTimer, 0.1, 2))
        actionRemote:FireServer(true, classTranslation)
    end 
end)
player.CharacterAdded:Connect(function()
    local newClassUi = player.PlayerGui:WaitForChild("Combat"):WaitForChild(classTranslation)
    newClassUi:GetPropertyChangedSignal("Visible"):Connect(function()
        local newValue = newClassUi.Visible 
        if newValue then 
            newClassUi.Visible = false
            task.wait(math.clamp(legitTimer, 0.1, 2))
            actionRemote:FireServer(true, classTranslation)
        end 
    end)
end)
