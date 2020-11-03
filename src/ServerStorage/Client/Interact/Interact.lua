
local gb, UI
local btnItem, engramItem

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Items = require(ReplicatedStorage:WaitForChild('Sandbox'):WaitForChild('Items'))

local ToggleInventory = require(ReplicatedStorage.Client.InventoryManage.InventoryManage).ToggleInventory
local PushChangeMessage = require(ReplicatedStorage.Client.InventoryManage.InventoryManage).PushChangeMessage

local Interact = {}

Interact.PossibleObjects = {}
Interact.InventoryObjects = {}
Interact.ClosestObject = nil
Interact.FurthestAway = 8

local gRightFrame = nil

local throwOutBox = ReplicatedStorage:WaitForChild('Objects'):WaitForChild('ThrowOutBox')
function Interact:RemoveItemFromInventory(button)
    local b = throwOutBox:Clone()
    b.Name = button.Name
    b.Amount.Value = tonumber(button.Amount.Text:sub(2, #button.Amount.Text))
    b.Position = (gb.Character:GetPrimaryPartCFrame() * CFrame.new(0, 0, -3)).p
    button:Destroy()
    local lookVector = gb.Character:GetPrimaryPartCFrame().LookVector
    local bf = Instance.new('BodyForce')
    bf.Parent = b
    local multi = 1.8
    bf.Force = Vector3.new(math.clamp(lookVector.X, -1, 1) * (100*multi), (200/5)*multi, math.clamp(lookVector.Z, -1, 1) * (100*multi))
    b.Parent = workspace.Objects.InteractF.Boxes
    Interact.PossibleObjects[#Interact.PossibleObjects+1] = b
    bf:Destroy()
    ToggleInventory();ToggleInventory()
end

local rightClickConnections = {}

local function configureRightClick(rightClickFrame)
    gb.addconn('rightclick', rightClickFrame.Drop.Drop.MouseButton1Click:Connect(function()
        Interact:RemoveItemFromInventory(rightClickFrame.Parent)
    end))
    gb.addconn('rightclick', rightClickFrame.Consume.Consume.MouseButton1Click:Connect(function()

    end))
    gb.addconn('rightclick', rightClickFrame.Transfer.Transfer.MouseButton1Click:Connect(function()
        
    end))
    gb.addconn('rightclick', rightClickFrame.RemoveItem.RemoveItem.MouseButton1Click:Connect(function()
        
    end))
    gb.addconn('rightclick', rightClickFrame.Repair.Repair.MouseButton1Click:Connect(function()
        
    end))
    gb.addconn('rightclick', rightClickFrame.SplitStack.SplitStack.MouseButton1Click:Connect(function()

    end))
    --[[
    gb.UIS.InputBegan:connect(function(inputObject, gameProcessedEvent)
        if inputObject.KeyCode == Enum.KeyCode.E then

        elseif inputObject.KeyCode == Enum.KeyCode.O then

        elseif inputObject.KeyCode == Enum.KeyCode.T then

        end
    end)
    ]]
end



local rightclick = ReplicatedStorage:WaitForChild('UI'):WaitForChild('RightClick')
local function newBtnItem(objectName, amount)
    local btnItemClone = btnItem:Clone()
    btnItemClone.Name = objectName
    btnItemClone.ItemName.Text = objectName
    btnItemClone.Amount.Text = 'x' .. amount
    btnItemClone.Weight.Text = string.format('%.1f', amount * Items[objectName]['Weight'])
    btnItemClone.Parent = UI.ScreenGuiLeftInvFrame
    btnItemClone.MouseButton2Click:Connect(function()
        if btnItemClone:FindFirstChild('RightClickFrame') then
            btnItemClone:FindFirstChild('RightClickFrame'):Destroy()
            gb.remconn('rightclick')
        else
            if gRightFrame then gRightFrame:Destroy() end
            local rightClickFrame = rightclick:Clone()
            gRightFrame = rightClickFrame
            rightClickFrame.Name = 'RightClickFrame'
            rightClickFrame.Parent = btnItemClone
            ToggleInventory();ToggleInventory()
            configureRightClick(rightClickFrame)
        end
    end)
end

function Interact:AddItemToInventory(object, objectName, amount)
    local maxAmount = Items[objectName].MaxStack
    local amountToAdd = amount
    for k,btn in pairs(UI.ScreenGuiLeftInvFrame:GetChildren()) do
        if btn:IsA('ImageButton') then
            if btn.Name == objectName then
                local btnAmount = tonumber(btn.Amount.Text:sub(2, #btn.Amount.Text))
                if btnAmount < maxAmount then
                    local available = maxAmount - btnAmount
                    if available >= amountToAdd then
                        btn.Amount.Text = 'x' .. (btnAmount + amountToAdd)
                        btn.Weight.Text = string.format('%.1f', (btnAmount + amountToAdd) * Items[objectName]['Weight'])
                        amountToAdd = 0
                        break
                    else
                        btn.Amount.Text = 'x' .. maxAmount
                        btn.Weight.Text = string.format('%.1f', maxAmount * Items[objectName]['Weight'])
                        amountToAdd = amountToAdd - available
                    end
                end
            end
        end
    end
    if amountToAdd > 0 then
        newBtnItem(objectName, amountToAdd)
    else
        PushChangeMessage(self, 'added', objectName, amount)
    end
end

local function facing(pos)
    local lv = gb.Character:GetPrimaryPartCFrame().LookVector
    local dir = (pos - gb.Character:GetPrimaryPartCFrame().p).unit
    local angle = math.acos(lv:Dot(dir))
    if angle < 1.8 then return true end
    return false
end

local function handleObject(part)
    if part:IsA('Model') then
        if part.PrimaryPart == nil then part.PrimaryPart = part:GetChildren()[1] end
        if Items[part.Name]['From'] then
            Interact.PossibleObjects[#Interact.PossibleObjects+1] = {
                part,
                math.random(Items[part.Name]['Uses'][1], Items[part.Name]['Uses'][2])
            }
        else
            Interact.PossibleObjects[#Interact.PossibleObjects+1] = part
        end
    elseif part:IsA('BasePart') then
        if Items[part.Name]['From'] then
            Interact.PossibleObjects[#Interact.PossibleObjects+1] = {
                part,
                math.random(Items[part.Name]['Uses'][1], Items[part.Name]['Uses'][2])
            }
        else
            Interact.PossibleObjects[#Interact.PossibleObjects+1] = part
        end
    end
end

function Interact:Use()
    local closepart, dist = nil, math.huge
    local part, foundindex
    for index,obj in pairs(Interact.PossibleObjects) do
        local obj = obj
        if type(obj) == 'table' then obj = obj[1] end
        if obj:IsA('Model') then
            if obj.PrimaryPart == nil then obj.PrimaryPart = obj:GetChildren()[1] end
            part = obj.PrimaryPart
        else
            part = obj
        end
        local away = (part.Position - gb.Character:GetPrimaryPartCFrame().p).magnitude
        if away < dist and away < Interact.FurthestAway and facing(part.Position) then dist = away closepart = part foundindex = index end
    end
    if closepart ~= nil then
        local zeroUses = false
        if closepart.Parent:IsA('Model') then
            closepart = closepart.Parent
        end
        if closepart.Parent.Name == 'Boxes' then
            Interact:AddItemToInventory(closepart, closepart.Name, closepart.Amount.Value)
            zeroUses = true
        else
            local from = Items[closepart.Name]['From']
            if from then
                local randomFrom = from[math.random(1, #from)]
                
                local random = math.random(randomFrom[2]['Amount'][1], randomFrom[2]['Amount'][2])
                Interact:AddItemToInventory(closepart, randomFrom[1], random)
                
                Interact.PossibleObjects[foundindex][2] = Interact.PossibleObjects[foundindex][2] - 1
                if Interact.PossibleObjects[foundindex][2] == 0 then zeroUses = true end
            else
                local random = math.random(Items[closepart.Name]['Amount'][1], Items[closepart.Name]['Amount'][2])
                Interact:AddItemToInventory(closepart, closepart.Name, random)
                zeroUses = true
            end
        end
        if zeroUses then
            table.remove(Interact.PossibleObjects, foundindex)
            local cloneClosePart = closepart:Clone()
            local parentDir = closepart.Parent
            local closepartParentName = closepart.Parent.Name
            closepart:Destroy()
            if closepartParentName ~= 'Boxes' then
                gb.cr(function()
                    wait(1)
                    cloneClosePart.Parent = parentDir
                    handleObject(cloneClosePart)
                end)()
            else cloneClosePart:Destroy() end
        end
    end
end

function Interact:Init()
    gb = require(game:GetService('ReplicatedStorage'):WaitForChild('Globlox'))
    UI = require(game:GetService('ReplicatedStorage'):WaitForChild('Client'):WaitForChild('UI'))
    btnItem = gb.ReplicatedStorage:WaitForChild('UI'):WaitForChild('Item')
    engramItem = gb.ReplicatedStorage:WaitForChild('UI'):WaitForChild('EngramItem')
    local interactF = workspace:WaitForChild('Objects'):WaitForChild('InteractF')
    for k,obj in pairs(interactF:GetDescendants()) do
        if obj:IsA('Folder') then
            for k,part in pairs(obj:GetChildren()) do
                handleObject(part)
            end
        end
    end
end

return Interact