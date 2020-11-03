
local gb, UI

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Items = require(ReplicatedStorage:WaitForChild('Sandbox'):WaitForChild('Items'))

local InventoryManage = {}

local function copyCharacter(model)
    model.Archivable = true
    return model:Clone()
end

local function fixWelds(character)
    for k,part in pairs(character:GetChildren()) do
        if part:IsA('Accessory') then
            local handle = part.Handle:Clone()
            part:Destroy()
            handle:ClearAllChildren()
            handle.Parent = character
            handle.CFrame = character.Head.CFrame
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = character.Head
            weld.Part1 = handle
            weld.Parent = handle
        end
    end
end

local function showPlayer(viewportFrame)
    local viewportCamera = Instance.new("Camera")
    viewportFrame.CurrentCamera = viewportCamera
    viewportCamera.Parent = viewportFrame
    
    local cln = copyCharacter(gb.Character)
    cln.Parent = viewportFrame
    cln.PrimaryPart = cln.HumanoidRootPart
    --fixWelds(cln)
    cln:SetPrimaryPartCFrame(gb.cfn(0, 0, 0))
    

    gb.RunService.RenderStepped:Connect(function()
        viewportCamera.CFrame = gb.cfn((cln:GetPrimaryPartCFrame() * gb.cfn(0, 2, -8)).p, cln:GetPrimaryPartCFrame().p)
        for k,part in pairs(gb.Character:GetChildren()) do
            for k,dummy in pairs(cln:GetChildren()) do
                if part:IsA('UnionOperation') or part:IsA('Part') or part:IsA('MeshPart') then
                    if part.Name == dummy.Name then
                        dummy.CFrame = part.CFrame
                    end
                end
            end
        end
    end)
end

function InventoryManage:ToggleInventory()
    UI.ScreenGuiLeft.Visible = not UI.ScreenGuiLeft.Visible
    UI.ScreenGuiRight.Visible = not UI.ScreenGuiRight.Visible
    UI.ScreenGuiCenter.Visible = not UI.ScreenGuiCenter.Visible
end

local function setupCenterUI()
    UI.ScreenGuiCenterYourName.Text = gb.Player.Name
    gb.cr(function()
        while true do
            local minutesNormalised = game.Lighting:GetMinutesAfterMidnight() % (60 * 24)
            local seconds = minutesNormalised * 60
            local hours = string.format("%02.f", math.floor(seconds/3600))
            local mins = string.format("%02.f", math.floor(seconds/60 - (hours*60)))
            UI.ScreenGuiCenterTime.Text = 'Time:     ' .. hours .. ':' .. mins
            UI.ScreenGuiCenterDay.Text = 'DAY:     ' .. game.Lighting:WaitForChild('DayCount').Value
            wait(0.01)
        end
    end)()
end

local function clearHotbar()
    for k,label in pairs(UI.ScreenGuiHotbar:GetChildren()) do
        if label:IsA('ImageButton') then
            label.ImageColor3 = Color3.fromRGB(8, 27, 29)
        end
    end
end

local selected = nil
local function hotbar(key)
    clearHotbar()
    if selected == key then
        UI['ScreenGuiHotbar' .. tostring(key)].ImageColor3 = Color3.fromRGB(8, 27, 29)
        selected = nil
    else
        UI['ScreenGuiHotbar' .. tostring(key)].ImageColor3 = Color3.fromRGB(30, 105, 112)
        selected = key
    end
end

local addedText = ReplicatedStorage:WaitForChild('UI'):WaitForChild('InventoryChange'):WaitForChild('Added')
local removedText = ReplicatedStorage:WaitForChild('UI'):WaitForChild('InventoryChange'):WaitForChild('Removed')
local spoiledText = ReplicatedStorage:WaitForChild('UI'):WaitForChild('InventoryChange'):WaitForChild('Spoiled')
function InventoryManage:PushChangeMessage(todo, objectName, objectAmount)
    UI.ChangeInventoryFrame.Visible = not UI.ChangeInventoryFrame.Visible
    UI.ChangeInventoryFrame.Visible = not UI.ChangeInventoryFrame.Visible
    if todo == 'added' then
        local addedFrame = addedText:Clone()
        addedFrame.Item.Text = objectAmount .. 'x ' .. objectName
        addedFrame.Parent = UI.ChangeInventoryFrame
        for k, item in pairs(addedFrame:GetChildren()) do
            gb.cr(function()
                if item:IsA('TextLabel') then
                    for i=1, 0, -0.1 do
                        item.TextTransparency = i
                        item.TextStrokeTransparency = i
                        wait()
                    end
                end
                if item:IsA('ImageLabel') then
                    for i=1, 0, -0.1 do
                        item.ImageTransparency = i
                        wait()
                    end
                end
                wait(2)
                if item:IsA('TextLabel') then
                    for i=0, 1, 0.1 do
                        item.TextTransparency = i
                        item.TextStrokeTransparency = i
                        wait()
                    end
                end
                if item:IsA('ImageLabel') then
                    for i=0, 1, 0.1 do
                        item.ImageTransparency = i
                        wait()
                    end
                end
                addedFrame:Destroy()
            end)()
        end
    elseif todo == 'removed' then

    elseif todo == 'spoiled' then

    end
end

local function invChange()
    UI.ScreenGuiLeftInvFrame.ChildAdded:Connect(function(child)
        InventoryManage:PushChangeMessage('added', child.Name, tonumber(child.Amount.Text:sub(2, #child.Amount.Text)))
    end)
    UI.ScreenGuiLeftInvFrame.ChildRemoved:Connect(function(child)

    end)
end

function InventoryManage:Init()

    gb = require(game:GetService('ReplicatedStorage'):WaitForChild('Globlox'))
    UI = require(game:GetService('ReplicatedStorage'):WaitForChild('Client'):WaitForChild('UI'))
    Interact = require(game:GetService('ReplicatedStorage'):WaitForChild('Client'):WaitForChild('Interact'):WaitForChild('Interact'))
    setupCenterUI()
    showPlayer(UI.ScreenGuiRightViewportFrame)

    invChange()

    gb.UIS.InputBegan:connect(function(inputObject, gameProcessedEvent)
        if inputObject.KeyCode == Enum.KeyCode.E then
            UI.EngramsRight.Visible = false
            InventoryManage:ToggleInventory()
        elseif inputObject.KeyCode == Enum.KeyCode.One then
            hotbar(1)
        elseif inputObject.KeyCode == Enum.KeyCode.Two then
            hotbar(2)
        elseif inputObject.KeyCode == Enum.KeyCode.Three then
            hotbar(3)
        elseif inputObject.KeyCode == Enum.KeyCode.Four then
            hotbar(4)
        elseif inputObject.KeyCode == Enum.KeyCode.Five then
            hotbar(5)
        elseif inputObject.KeyCode == Enum.KeyCode.Six then
            hotbar(6)
        elseif inputObject.KeyCode == Enum.KeyCode.Seven then
            hotbar(7)
        elseif inputObject.KeyCode == Enum.KeyCode.Eight then
            hotbar(8)
        elseif inputObject.KeyCode == Enum.KeyCode.Nine then
            hotbar(9)
        elseif inputObject.KeyCode == Enum.KeyCode.Zero then
            hotbar(0)
        elseif inputObject.KeyCode == Enum.KeyCode.F then
            Interact:Use()
            InventoryManage:ToggleInventory();InventoryManage:ToggleInventory()
        end
    end)

    for i=0, 9 do
        UI['ScreenGuiHotbar' .. tostring(i)].MouseButton1Click:Connect(function()
            hotbar(i)
        end)
    end
end

return InventoryManage