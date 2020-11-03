
local gb

local Client = {}

function Client:Init()
    gb = require(game:GetService('ReplicatedStorage'):WaitForChild('Globlox'))

    game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

    require(gb.ReplicatedStorage:WaitForChild('Client'):WaitForChild('UI')):Init()
    require(gb.ReplicatedStorage:WaitForChild('Client'):WaitForChild('Data')):Init()

    require(gb.ReplicatedStorage:WaitForChild('Client'):WaitForChild('Engrams'):WaitForChild('Engrams')):Init()
    require(gb.ReplicatedStorage:WaitForChild('Client'):WaitForChild('Interact'):WaitForChild('Interact')):Init()
    require(gb.ReplicatedStorage:WaitForChild('Client'):WaitForChild('InventoryManage'):WaitForChild('InventoryManage')):Init()
end

return Client