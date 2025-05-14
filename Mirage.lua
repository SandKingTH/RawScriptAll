repeat wait() until game:IsLoaded()
repeat wait() until game.Players.LocalPlayer.Character
repeat wait() until game:GetService("Players").LocalPlayer.PlayerGui.Main:FindFirstChild("ChooseTeam") == nil

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")

local webhook_url = "http://110.164.203.137:5326/"

function send_mirage_data()
    local payload = {
        data = {
            jobId = game.JobId,
            players = #Players:GetPlayers(),
            gametime = Lighting.TimeOfDay
        }
    }

    local json = HttpService:JSONEncode(payload)
    local headers = {
        ["Content-Type"] = "application/json"
    }

    local request = http_request or request or HttpPost or syn and syn.request
    if request then
        local response = request({
            Url = webhook_url,
            Method = "POST",
            Headers = headers,
            Body = json
        })

        if response then
            print("📤 Mirage data sent:", response.StatusCode)
        else
            warn("❌ Failed to send Mirage data.")
        end
    else
        warn("❌ No HTTP request function available.")
    end
end

-- เริ่มทำงานเมื่ออยู่ในแมพที่ถูกต้อง
if game.PlaceId == 7449423635 then
    task.spawn(function()
        while true do
            task.wait(5)

            local mirage = workspace:FindFirstChild("_WorldOrigin")
                and workspace["_WorldOrigin"]:FindFirstChild("Locations")
                and workspace["_WorldOrigin"].Locations:FindFirstChild("Mirage Island")

            if mirage then
                print("🌌 Mirage Island detected, sending data...")
                send_mirage_data()
            else
                print("⏳ Waiting for Mirage Island...")
            end
        end
    end)
else
    warn("Not in the target PlaceId (7449423635). Script won't run.")
end
