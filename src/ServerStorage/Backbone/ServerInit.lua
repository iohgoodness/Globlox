
local ServerStorage = game:GetService('ServerStorage')
local ReplicatedStorage = game:GetService('ReplicatedStorage')

local SyncScripts = ServerStorage:WaitForChild('SyncScripts')
local Backbone = SyncScripts:WaitForChild('Backbone')
local DBManage = require(Backbone:WaitForChild('DBManage'))
local gb

local ServerInit = {}

ServerInit.DatabaseID  = 'MyData00003'
ServerInit.LoadFromDB  = false
ServerInit.SaveOnClose = false
ServerInit.SaveOnLeave = false

ServerInit.Players = {}

function ServerInit:GetData(playerUserId)
    return ServerInit.Players[playerUserId]
end

function ServerInit:SetData(playerUserId, data)
    ServerInit.Players[playerUserId] = data
end

function ServerInit:HandlePlayers()
    gb.Players.PlayerAdded:Connect(function(player)
        gb.cr(function()
            local playerDB = DBManage:Load(player.UserId)
            ServerInit:SetData(player.UserId, playerDB)
        end)()
    end)
    gb.Players.PlayerRemoving:Connect(function(player)
        gb.cr(function()
            if ServerInit.SaveOnLeave then
                DBManage:Save(player.UserId, ServerInit:GetData(player.UserId))
            end
            ServerInit.Players[player.UserId] = nil
        end)()
    end)
end

function ServerInit:MovingClientScripts()
    SyncScripts:WaitForChild('Client').Parent = ReplicatedStorage
end

function ServerInit:SetGloblox()
    SyncScripts:WaitForChild('Globlox').Parent = ReplicatedStorage
    gb = require(ReplicatedStorage:WaitForChild('Globlox'))
end

function ServerInit:SetDataTransfer()
    local remotesDir = Instance.new('Folder')
    remotesDir.Name = 'Remotes'
    remotesDir.Parent = ReplicatedStorage
    local db = Instance.new('RemoteEvent')
    db.Name = 'DB'
    db.Parent = remotesDir
    db.OnServerEvent:Connect(function(player)
        gb.cr(function()
            db:FireClient(player, ServerInit.Players[player.UserId])
        end)()
    end)
end

function ServerInit:Init()
    ServerInit:SetGloblox()
    ServerInit:SetDataTransfer()
    DBManage:Establish(ServerInit.DatabaseID)
    ServerInit:HandlePlayers()
    ServerInit:MovingClientScripts()

    gb.cr(function()
        local dayCounter = Instance.new('IntValue', game.Lighting)
        dayCounter.Name  = 'DayCount'
        dayCounter.Value = 0
        local minutesAfterMidnight = 0
        while true do
            minutesAfterMidnight = minutesAfterMidnight + 1
            game.Lighting:SetMinutesAfterMidnight(minutesAfterMidnight)
            wait(0.01)
        end
    end)()
end

return ServerInit