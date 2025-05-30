task.spawn(function() 
    repeat task.wait() until game:IsLoaded()

    local IP = "110.164.203.137"
    local PORT = "4135"
    local BaseURL = string.format("http://%s:%s", IP, PORT)
    local CacheInventory = {
        Data = {},
        Time = 0
    }
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local SkinController = require(game:GetService("ReplicatedStorage").Controllers.SkinController)
    function findAura(AuraList: {string}) 
        local Skin = SkinController:GetInventory()
        if not Skin then
            return false
        end
        local A = 0
        for i, v in pairs(Skin) do 
            if v["Type"] == "AuraSkin" and table.find(AuraList, v.DisplayName) and v.Count > 0 then 
                A += 1
            end
        end
        return A == #AuraList
    end

    function findItem(item: string)
        if (tick() - CacheInventory.Time) < 120 then
            for i , v in pairs(CacheInventory.Data) do 
                if v.Name == item then 
                    return true
                end
            end
            return false
        end
        local RequestGetInvertory = nil
        RequestGetInvertory = game:GetService("ReplicatedStorage").Remotes.CommF_:InvokeServer("getInventory")
        CacheInventory.Data = RequestGetInvertory
        CacheInventory.Time = tick()
        for i , v in pairs(RequestGetInvertory) do 
            if v.Name == item then 
                return true
            end
        end
        return false
    end 
    function allPressPlate()
        for i, v in pairs(workspace.Map["Boat Castle"].Summoner.Circle:GetChildren()) do 
            if v:IsA("Part") and v:FindFirstChild("Part") and v:FindFirstChild("TouchInterest") then 
                if v.Part.Color == Color3.fromRGB(99, 95, 98) then 
                    return false
                end
            end
        end
        return true
    end
    task.spawn(function() 
        while true do task.wait() 
            if not findItem("Tushita") and not findAura({"Pure Red", "Winter Sky", "Snow White"}) then 
                if LocalPlayer.Backpack:FindFirstChild("God's Chalice") or (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("God's Chalice")) then 
                    local Action = request({
                        Url = BaseURL .. string.format("/actions/%s", LocalPlayer.Name),
                        Method = "GET"
                    })
                    if Action.Body == "SEND_PACKET" and #Players:GetPlayers() < 12 then 
                        if not allPressPlate() then 
                            request({
                                Url = BaseURL .. "/actions/update/" .. game.JobId .. "/" .. game.Players.LocalPlayer.Name,
                                Method = "GET",
                            })
                            task.wait(5)
                        else 
                            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then 
                                local BP = LocalPlayer.Backpack:FindFirstChild("God's Chalice")
                                if BP then
                                    LocalPlayer.Character:FindFirstChild("Humanoid"):EquipTool(BP)
                                    task.wait(1)
                                end
                                if LocalPlayer.Character:FindFirstChild("God's Chalice") then 
                                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, workspace.Map["Boat Castle"].Summoner.Detection, 0)
                                    task.wait(1)
                                    firetouchinterest(game.Players.LocalPlayer.Character.HumanoidRootPart, workspace.Map["Boat Castle"].Summoner.Detection, 1)
                                end
                            end
                        end
                    end
                end
            else
                print("Has tushita stop")
                break 
            end
        end
    end)

end)
