repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer.Character
repeat wait() until game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("ChooseTeam") == nil

local plr = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local found = false

function is_land_hook(uRl)
    local playerval = #game.Players:GetPlayers()
    local time_of_server = tostring(game:GetService("Lighting").TimeOfDay)

    local Data_Payload = {
        ["data"] = {
            ['jobId'] = game.JobId,
            ['players'] = playerval,
            ['gametime'] = time_of_server,
        }
    }

    local newdata = HttpService:JSONEncode(Data_Payload)
    local headers = {
        ["Content-Type"] = "application/json"
    }

    local request = http_request or request or HttpPost or syn.request
    local callback = request({
        Url = tostring(uRl),
        Body = newdata,
        Method = "POST",
        Headers = headers
    })
end

task.spawn(function()
    while true do
        pcall(function()
            if game.PlaceId == 7449423635 then
                local Mirage_Land = game:GetService("Workspace")["_WorldOrigin"].Locations:FindFirstChild("Mirage Island")
                if Mirage_Land and not found then
                    print("Mirage Island detected, sending to server...")
                    is_land_hook("http://110.164.203.137:5326/")
                    found = true
                elseif not Mirage_Land then
                    found = false
                end
            end
        end)
        task.wait(1)
    end
end)
