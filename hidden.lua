print("Exec at: ", math.floor(tick()))

local longWaitingTime = .5
local shortWaitingTime = .1


local localPlayer =game.Players.LocalPlayer
local remotes = game:GetService("ReplicatedStorage"):WaitForChild("Comms")

local eventRemote = remotes.eEzMode
local salonRemote = remotes.eSalon

local staticRoundInfo = workspace.StaticMeshes.Round
local gears = workspace.Gear
local shoeColors = staticRoundInfo.ColourBlocks_Shoes
local accessoryColors = staticRoundInfo.ColourBlocks_Acc

local function getCustomColor(_type, color)
    for i, v in pairs (_type:GetChildren()) do 
        if i == color then 
            return v
        end 
    end 
end 
local function findGear(_gears, gId, _colors, cId)
    local gear = _gears:FindFirstChild(gId)
    if not gear then warn("No Gear.") return end

    local cb = gear:FindFirstChild("Cb")
    if not cb then warn("e1") return end 
                
    local button = cb:FindFirstChildOfClass("ClickDetector")
    if not localPlayer.Character or not button then warn("e2") return end 

    localPlayer.Character.HumanoidRootPart.CFrame = (cb.CFrame)
    task.wait(shortWaitingTime)
    fireclickdetector(button)
    if cId then 
        if not _colors then 
            local args = {
                ["Cat"] = "Hair",
                ["ID"] = cId or 0,
            }

            if cId then 
                task.wait(shortWaitingTime)
                salonRemote:FireServer(args)
            end 
        else 
            if not cId then return end 
            local _trueColor = getCustomColor(_colors, cId)
            if not _trueColor then return end 

            localPlayer.Character.HumanoidRootPart.CFrame = _trueColor.CFrame
            task.wait(shortWaitingTime)
            fireclickdetector(_trueColor.ClickDetector)
        end 
    end 
end 
local _funcTable = {
    ["Lip"] = function(lipType)
        local args = {
            ["Cat"] = "Lips",
            ["ID"] = lipType,
            }
        salonRemote:FireServer(args)
    end, 
    ["Skin"] = function(skinType)
        local args = {
            ["Cat"] = "Skin",
            ["ID"] = skinType,
            }
        salonRemote:FireServer(args)
    end,
    ["Eye"] = function(eyeType)
        local args = {
            ["Cat"] = "Eyes",
            ["ID"] = eyeType,
            }
        salonRemote:FireServer(args)
    end,
    ["Outfit"] = function(outfitNumber)
        findGear(gears.Outfit, outfitNumber)
    end,
    ["Hair"] = function(hairType, hairColor)
        findGear(gears.Hair, hairType, nil, hairColor)
    end,
    ["Shoes"] = function(shoeType, color)
        findGear(gears.Shoes, shoeType, shoeColors, color)
    end,
    ["A1"] = function(acc, color)
        findGear(gears.Acc, acc, accessoryColors, color)
    end,
    ["A2"] = function(acc, color)
        findGear(gears.Acc, acc, accessoryColors, color)
    end,
    ["A3"] = function(acc, color)
        findGear(gears.Acc, acc, accessoryColors, color)
    end,
}

local function doThing(values)
        for i, v in pairs (values.Card) do 
        local func = _funcTable[i]
        if not func then continue end 

        if type(v) == "table" then 
            local _type, color = v.I, v.C

            local s, r = pcall(function()
                return func(_type, color)
            end)

            if not s then 
                warn("ERROR: ", r)
            end

            task.wait(longWaitingTime)
            continue
        end 

        local s, r = pcall(function()
            return func(v)
        end)

        if not s then 
            print("ERROR:",r)
        end 

        task.wait(longWaitingTime)
    end 
end 
function serializeTable(val, name, skipnewlines, depth)
   skipnewlines = skipnewlines or false
   depth = depth or 0

   local tmp = string.rep(" ", depth)

   if name then tmp = tmp .. name .. " = " end

   if type(val) == "table" then
       tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

       for k, v in pairs(val) do
           tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
       end

       tmp = tmp .. string.rep(" ", depth) .. "}"
   elseif type(val) == "number" then
       tmp = tmp .. tostring(val)
   elseif type(val) == "string" then
       tmp = tmp .. string.format("%q", val)
   elseif type(val) == "boolean" then
       tmp = tmp .. (val and "true" or "false")
   elseif type(val) == "function" then
       tmp = tmp  .. "func: " .. debug.getinfo(val).name
   else
       tmp = tmp .. tostring(val)
   end

   return tmp
end

eventRemote.OnClientEvent:Connect(function(mode, values)
    if mode ~= "___EZM_SETUP___" then return end
    task.wait()

    print(serializeTable(values))
    doThing(values)
end)
_G.Disconnect = function()
    a:Disconnect()
    a = nil
    _G.Disconnect = nil 

    print("Successfully disconnected event!")
end
