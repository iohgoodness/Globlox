
local gb
local UI

local Data = {}

function Data:Init()
    gb = require(game:GetService('ReplicatedStorage'):WaitForChild('Globlox'))

    Data.DB = nil
    
    --# Grab the database for the player from the server
    local db = gb.ReplicatedStorage:WaitForChild('Remotes'):WaitForChild('DB')
    db.OnClientEvent:Connect(function(data)
        Data.DB = data
    end)
    db:FireServer()
    repeat wait() until Data.DB ~= nil

end

return Data