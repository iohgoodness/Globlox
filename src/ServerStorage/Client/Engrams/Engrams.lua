
local gb, UI

local ReplicatedStorage = game:GetService('ReplicatedStorage')

local Levels = require(ReplicatedStorage:WaitForChild('Sandbox'):WaitForChild('Engrams')).Levels
local Data = require(ReplicatedStorage:WaitForChild('Sandbox'):WaitForChild('Engrams')).Data

local Engrams = {}

local function isUnlocked(itemName)
    return false
end

local engramSlot = ReplicatedStorage:WaitForChild('UI'):WaitForChild('EngramSlot')
local engramSlotItem = ReplicatedStorage:WaitForChild('UI'):WaitForChild('EngramItem')
function Engrams:Init()
    gb = require(game:GetService('ReplicatedStorage'):WaitForChild('Globlox'))
    UI = require(game:GetService('ReplicatedStorage'):WaitForChild('Client'):WaitForChild('UI'))

    UI.TabsFrameEngramsFrameTextButton.MouseButton1Click:Connect(function()
        UI.EngramsRight.Visible = not UI.EngramsRight.Visible
        
        if UI.ScreenGuiLeft.Visible then
            UI.ScreenGuiLeft.Visible = not UI.ScreenGuiLeft.Visible
            UI.ScreenGuiRight.Visible = not UI.ScreenGuiRight.Visible
            UI.ScreenGuiCenter.Visible = not UI.ScreenGuiCenter.Visible
        end
    end)

    UI.EngramsRightUnlockCancel.MouseButton1Click:Connect(function()
        UI.EngramsRightUnlock.Visible = false
    end)
    UI.EngramsRightUnlockConfirm.MouseButton1Click:Connect(function()
        UI.EngramsRightUnlock.Visible = false
    end)

    for index,engramTable in pairs(Levels) do
        local slot = engramSlot:Clone()
        slot.Crafting.Text = index
        for k, engramName in pairs(engramTable) do
            local slotItem = engramSlotItem:Clone()
            slotItem.ItemName.Text = engramName
            slotItem.Parent = slot.Frame
            slot.Parent = UI.EngramsRightInvFrame
            slotItem.MouseButton1Click:Connect(function()
                if not isUnlocked(engramName) and not UI.EngramsRightUnlock.Visible then
                    UI.EngramsRightUnlockItem.Text = engramName
                    UI.EngramsRightUnlock.Visible = true
                end
            end)
        end
    end
end

return Engrams