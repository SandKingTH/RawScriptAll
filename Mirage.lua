repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer.Character
repeat wait() until game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("ChooseTeam") == nil

local plr = game.Players.LocalPlayer

function is_land_hook(uRl)
    local Script_Teleport = 'game:GetService("ReplicatedStorage").__ServerBrowser:InvokeServer("teleport","'..game.JobId..'")'
    local playerval = #game.Players:GetPlayers()
    local time_of_server = tostring(game:GetService("Lighting").TimeOfDay)
    local Data_Payload = 
    {
        ["data"] = {
            ['jobId'] = game.JobId,
            ['players'] = playerval,  
            ['gametime'] = time_of_server,  
        }
    }

    local newdata = game:GetService("HttpService"):JSONEncode(Data_Payload)
    local headers = {
        ["content-type"] = "application/json"
    }
    local request = http_request or request or HttpPost or syn.request
    local callback = request({
        Url = tostring(uRl), 
        Body = newdata, 
        Method = "POST", 
        Headers = headers
    })
end

local found;
task.spawn(function()
    while true do
        pcall(function()
            if game.PlaceId == 7449423635 then 
                Mirage_Land = game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Mirage Island")
                if Mirage_Land ~= nil then
                    if not found then
                        print("Masterp Is Everything For you | Mirage IsLand [ Last update 18 April ]")
                        is_land_hook("http://110.164.203.137:5326/")
                        found = true
                    end
                else
                    found = false
                end
            end
        end)
        task.wait(1)
    end
end)
