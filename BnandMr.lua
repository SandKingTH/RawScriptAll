repeat task.wait() until game:IsLoaded()
repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui")

local player = game.Players.LocalPlayer
local LocalPlayer = game.Players.LocalPlayer
local playerGui = player:FindFirstChild("PlayerGui")
local mainGui = playerGui and playerGui:FindFirstChild("Main (minimal)")
local chooseTeamGui = mainGui and mainGui:FindFirstChild("ChooseTeam")
function RunScript(SC) 
    if SC == "banana" then
        task.spawn(function()
            repeat wait() until game:IsLoaded() and game.Players.LocalPlayer
            getgenv().SettingFarm ={
                ["Hide UI"] = false,
                ["Reset Teleport"] = {
                    ["Enabled"] = false,
                    ["Delay Reset"] = 3,
                    ["Item Dont Reset"] = {
                        ["Fruit"] = {
                            ["Enabled"] = true,
                            ["All Fruit"] = true, 
                            ["Select Fruit"] = {
                                ["Enabled"] = false,
                                ["Fruit"] = {},
                            },
                        },
                    },
                },
                ["White Screen"] = false,
                ["Lock Fps"] = {
                    ["Enabled"] = false,
                    ["FPS"] = 20,
                },
                ["Get Items"] = {
                    ["Saber"] = true,
                    ["Godhuman"] =  true,
                    ["Skull Guitar"] = true,
                    ["Mirror Fractal"] = true,
                    ["Cursed Dual Katana"] = true,
                    ["Upgrade Race V2-V3"] = true,
                    ["Auto Pull Lever"] = true,
                    ["Shark Anchor"] = true,
                },
                ["Get Rare Items"] = {
                    ["Rengoku"] = false,
                    ["Dragon Trident"] = false, 
                    ["Pole (1st Form)"] = false,
                    ["Gravity Blade"]  = false,
                },
                ["Farm Fragments"] = {
                    ["Enabled"]  = true,
                    ["Fragment"] = 100000,
                },
                ["Auto Chat"] = {
                    ["Enabled"] = false,
                    ["Text"] = "",
                },
                ["Auto Summon Rip Indra"] = true, --- auto buy haki and craft haki legendary 
                ["Select Hop"] = { -- 70% will have it
                    ["Hop Server If Have Player Near"] = false, 
                    ["Hop Find Rip Indra Get Valkyrie Helm or Get Tushita"] = true, 
                    ["Hop Find Dough King Get Mirror Fractal"] = false,
                    ["Hop Find Raids Castle [CDK]"] = true,
                    ["Hop Find Cake Queen [CDK]"] = true,
                    ["Hop Find Soul Reaper [CDK]"] = true,
                    ["Hop Find Darkbeard [SG]"] = true,
                    ["Hop Find Mirage [ Pull Lever ]"] = false,
                },
                ["Farm Mastery"] = {
                    ["Melee"] = false,
                    ["Sword"] = false,
                },
                ["Buy Haki"] = {
                    ["Enhancement"] = false,
                    ["Skyjump"] = true,
                    ["Flash Step"] = true,
                    ["Observation"] = true,
                },
                ["Sniper Fruit Shop"] = {
                    ["Enabled"] = true, -- Auto Buy Fruit in Shop Mirage and Normal
                    ["Fruit"] = {"Leopard-Leopard","Kitsune-Kitsune","Dragon-Dragon","Yeti-Yeti","Gas-Gas"},
                },
                ["Lock Fruit"] = {},
                ["Webhook"] = {
                    ["Enabled"] = false,
                    ["WebhookUrl"] = "",
                }
            }
            getgenv().Key = _G.KeyBanana
            loadstring(game:HttpGet("https://raw.githubusercontent.com/obiiyeuem/vthangsitink/main/BananaCat-kaitunBF.lua"))()
        end)
        repeat
            task.wait()
        until game:IsLoaded()
        task.wait(10)
        print("Start")

        while true do
            task.wait(5)
            setfpscap(10)
            -- if game:GetService("Stats"):GetTotalMemoryUsageMb() >= 3000 then
            --     game:Shutdown()
            -- end
        end
    elseif SC == "maru" then
        task.spawn(function()
            repeat task.wait() until game:IsLoaded()
            repeat task.wait() until game.Players
            repeat task.wait() until game.Players.LocalPlayer
            repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui")
            _G.Team = "Pirate" -- Marine / Pirate
            getgenv().Script_Mode = "Kaitun_Script"
            _G.MainSettings = {
                ["EnabledHOP"] = true,
                ['FPSBOOST'] = true,
                ["FPSLOCKAMOUNT"] = 60,
                ['WhiteScreen'] = true,
                ['CloseUI'] = false,
                ["NotifycationExPRemove"] = true,
                ['AFKCheck'] = 150,
                ["LockFragments"] = 20000,
                ["LockFruitsRaid"] = {
                        [1] = "Yeti-Yeti",
                        [2] = "Dragon-Dragon",
                        [3] = "Dough-Dough",
                        [4] = "Kitsune-Kitsune",
                        [5] = "Leopard-Leopard",
                        [6] = "Venom-Venom",
                        [7] = "Spirit-Spirit",
                        [8] = "Mammoth-Mammoth",
                        [9] = "Gas-Gas",
                        [10] = "Lightning-Lightning",
                        [11] = "T-Rex-T-Rex",
                }
            }
            _G.SharkAnchor_Settings = {
                ["Enabled_Farm"] = true,
                ['FarmAfterMoney'] = 2500000
            }
            _G.Quests_Settings = {
                ['Rainbow_Haki'] = true,
                ["MusketeerHat"] = true,
                ["PullLever"] = true,
                ['DoughQuests_Mirror'] = {
                    ['Enabled'] = true,
                    ['UseFruits'] = true
                }
            }
            _G.Races_Settings = {
                ['Race'] = {
                    ['EnabledEvo'] = true,
                    ["v2"] = true,
                    ["v3"] = true,
                    ["Races_Lock"] = {
                        ["Races"] = {
                            ["Mink"] = true,
                            ["Human"] = true,
                            ["Fishman"] = true
                        },
                        ["RerollsWhenFragments"] = 20000
                    }
                }
            }
            _G.Fruits_Settings = {
                ['Main_Fruits'] = {},
                ['Select_Fruits'] = {"Ice-Ice", "Light-Light", "Dark-Dark","Rumble-Rumble","Magma-Magma",}
            }
            _G.Settings_Melee = {
                ['Superhuman'] = true,
                ['DeathStep'] = true,
                ['SharkmanKarate'] = true,
                ['ElectricClaw'] = true,
                ['DragonTalon'] = true,
                ['Godhuman'] = true
            }
            _G.SwordSettings = {
                ['Saber'] = true,
                ["Pole"] = false,
                ['MidnightBlade'] = false,
                ['Shisui'] = true,
                ['Saddi'] = true,
                ['Wando'] = true,
                ['Yama'] = true,
                ['Rengoku'] = false,
                ['Canvander'] = false,
                ['BuddySword'] = false,
                ['TwinHooks'] = false,
                ['HallowScryte'] = false,
                ['TrueTripleKatana'] = true,
                ['CursedDualKatana'] = true
            }
            _G.GunSettings = {
                ['Kabucha'] = false,
                ['SerpentBow'] = false,
                ['SoulGuitar'] = false
            }
            _G.FarmMastery_Settings = {
                ['Melee'] = false,
                ['Sword'] = false,
                ['DevilFruits'] = true,
                ['Select_Swords'] = {
                    ["AutoSettings"] = true,
                    ["ManualSettings"] = {
                        "Saber",
                        "Buddy Sword"
                    }
                }
            }
            _G.Hop_Settings = {
                ["Find Tushita"] = false
            }
            getgenv().Key = "MARU-K13E1-9UIP-45J9-AJQ0Q-KVOK2"
            getgenv().id = "969581952531316827"
            getgenv().Script_Mode = "Kaitun_Script"
            loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/e1c3fb1e210e932600653f256d136b6e.lua"))()  
        end)
        repeat
            task.wait()
        until game:IsLoaded()
        task.wait(10)
        print("Start")

        while true do
            task.wait(5)
            setfpscap(10)
            -- if game:GetService("Stats"):GetTotalMemoryUsageMb() >= 3000 then
            --     game:Shutdown()
            -- end
        end
    else
        task.spawn(function()
            repeat task.wait() until game:IsLoaded()
            repeat task.wait() until game.Players
            repeat task.wait() until game.Players.LocalPlayer
            repeat task.wait() until game.Players.LocalPlayer:FindFirstChild("PlayerGui")
            _G.Team = "Pirate" -- Marine / Pirate
            getgenv().Script_Mode = "Kaitun_Script"
            _G.MainSettings = {
                ["EnabledHOP"] = true,
                ['FPSBOOST'] = true,
                ["FPSLOCKAMOUNT"] = 60,
                ['WhiteScreen'] = true,
                ['CloseUI'] = false,
                ["NotifycationExPRemove"] = true,
                ['AFKCheck'] = 150,
                ["LockFragments"] = 20000,
                ["LockFruitsRaid"] = {
                        [1] = "Yeti-Yeti",
                        [2] = "Dragon-Dragon",
                        [3] = "Dough-Dough",
                        [4] = "Kitsune-Kitsune",
                        [5] = "Leopard-Leopard",
                        [6] = "Venom-Venom",
                        [7] = "Spirit-Spirit",
                        [8] = "Mammoth-Mammoth",
                        [9] = "Gas-Gas",
                        [10] = "Lightning-Lightning",
                        [11] = "T-Rex-T-Rex",
                }
            }
            _G.SharkAnchor_Settings = {
                ["Enabled_Farm"] = true,
                ['FarmAfterMoney'] = 2500000
            }
            _G.Quests_Settings = {
                ['Rainbow_Haki'] = true,
                ["MusketeerHat"] = true,
                ["PullLever"] = true,
                ['DoughQuests_Mirror'] = {
                    ['Enabled'] = true,
                    ['UseFruits'] = true
                }
            }
            _G.Races_Settings = {
                ['Race'] = {
                    ['EnabledEvo'] = true,
                    ["v2"] = true,
                    ["v3"] = true,
                    ["Races_Lock"] = {
                        ["Races"] = {
                            ["Mink"] = true,
                            ["Human"] = true,
                            ["Fishman"] = true
                        },
                        ["RerollsWhenFragments"] = 20000
                    }
                }
            }
            _G.Fruits_Settings = {
                ['Main_Fruits'] = {},
                ['Select_Fruits'] = {"Ice-Ice", "Light-Light", "Dark-Dark","Rumble-Rumble","Magma-Magma",}
            }
            _G.Settings_Melee = {
                ['Superhuman'] = true,
                ['DeathStep'] = true,
                ['SharkmanKarate'] = true,
                ['ElectricClaw'] = true,
                ['DragonTalon'] = true,
                ['Godhuman'] = true
            }
            _G.SwordSettings = {
                ['Saber'] = true,
                ["Pole"] = false,
                ['MidnightBlade'] = false,
                ['Shisui'] = true,
                ['Saddi'] = true,
                ['Wando'] = true,
                ['Yama'] = true,
                ['Rengoku'] = false,
                ['Canvander'] = false,
                ['BuddySword'] = false,
                ['TwinHooks'] = false,
                ['HallowScryte'] = false,
                ['TrueTripleKatana'] = true,
                ['CursedDualKatana'] = true
            }
            _G.GunSettings = {
                ['Kabucha'] = false,
                ['SerpentBow'] = false,
                ['SoulGuitar'] = false
            }
            _G.FarmMastery_Settings = {
                ['Melee'] = false,
                ['Sword'] = false,
                ['DevilFruits'] = true,
                ['Select_Swords'] = {
                    ["AutoSettings"] = true,
                    ["ManualSettings"] = {
                        "Saber",
                        "Buddy Sword"
                    }
                }
            }
            _G.Hop_Settings = {
                ["Find Tushita"] = false
            }
            getgenv().Key = "MARU-K13E1-9UIP-45J9-AJQ0Q-KVOK2"
            getgenv().id = "969581952531316827"
            getgenv().Script_Mode = "Kaitun_Script"
            loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/e1c3fb1e210e932600653f256d136b6e.lua"))()  
        end)
        repeat
            task.wait()
        until game:IsLoaded()
        task.wait(10)
        print("Start")

        while true do
            task.wait(5)
            setfpscap(10)
            -- if game:GetService("Stats"):GetTotalMemoryUsageMb() >= 3000 then
            --     game:Shutdown()
            -- end
        end
    end
end

repeat task.wait() 
    pcall(function() 
        if game:GetService("Players").LocalPlayer.PlayerGui["Main (minimal)"].ChooseTeam.Container.Pirates then 
            for i, v in pairs(getconnections(game:GetService("Players").LocalPlayer.PlayerGui["Main (minimal)"].ChooseTeam.Container.Pirates.Frame.TextButton.Activated)) do 
                v.Function()
            end
        end
    end)
until (game.Players.LocalPlayer.Neutral == false) == true

function getLevel()
    return player.Data.Level.Value
end

local function isFruitFullyAwakened()
    local fruitName = player.Data.DevilFruit.Value
    if fruitName == "" then return false end

    local fruitTool = player.Backpack:FindFirstChild(fruitName)
        or player.Character:FindFirstChild(fruitName)
    if not fruitTool or not fruitTool:IsA("Tool") then return false end

    local awakenedFolder = fruitTool:FindFirstChild("AwakenedMoves")
    if not awakenedFolder then return false end

    local requiredMoves = {"Z","X","C","V"} -- move พื้นฐาน
    if awakenedFolder:FindFirstChild("F") then table.insert(requiredMoves,"F") end
    if fruitTool.Name == "Dough-Dough" and awakenedFolder:FindFirstChild("TAP") then
        table.insert(requiredMoves,"TAP")
    end

    for _, move in ipairs(requiredMoves) do
        if not awakenedFolder:FindFirstChild(move) then
            return false
        end
    end
    return true
end

function checkCDK()
    local Inventory = game.ReplicatedStorage.Remotes.CommF_:InvokeServer("getInventory")
    for _, v in pairs(Inventory) do
        if v.Name == "Cursed Dual Katana" then
            return true
        end
    end
    return false
end

getgenv().CheckMaxFruitsMastery = function(NameIT)
	if LocalPlayer.Character:FindFirstChild(tostring(NameIT)) and LocalPlayer.Character:FindFirstChild(tostring(NameIT)):IsA("Tool") then
		local ScriptSC = require(game:GetService("Players")["LocalPlayer"].Character[tostring(NameIT)].Data)
		return ScriptSC.Lvl.V
	elseif LocalPlayer.Backpack:FindFirstChild(tostring(NameIT)) and LocalPlayer.Backpack:FindFirstChild(tostring(NameIT)):IsA("Tool") then
		local ScriptSC = require(game:GetService("Players")["LocalPlayer"].Backpack[tostring(NameIT)].Data)
		return ScriptSC.Lvl.V
	end
end

getgenv().CheckCurrentMastery = function(NameIT)
	if LocalPlayer.Character:FindFirstChild(tostring(NameIT)) and LocalPlayer.Character:FindFirstChild(tostring(NameIT)):IsA("Tool") then
		return LocalPlayer.Character:FindFirstChild(tostring(NameIT)).Level.Value
	elseif LocalPlayer.Backpack:FindFirstChild(tostring(NameIT)) and LocalPlayer.Backpack:FindFirstChild(tostring(NameIT)):IsA("Tool") then
		return LocalPlayer.Backpack:FindFirstChild(tostring(NameIT)).Level.Value
	end
end

function checkGod()
    return tonumber(game.ReplicatedStorage.Remotes.CommF_:InvokeServer("BuyGodhuman", true)) == 1
end

-- ===== Variables =====
local levelplayer = getLevel()
local GodHuman = checkGod()
local SwordCDK = checkCDK()
local fruitAwank = isFruitFullyAwakened()
local namefrutis = player.Data.DevilFruit.Value
_G.MaxF = 0
_G.CurrentF = 0

if namefrutis ~= '' then
    _G.MaxF = CheckMaxFruitsMastery(namefrutis)
    _G.CurrentF = CheckCurrentMastery(namefrutis)
end
print("level: "..levelplayer)
print("GodHuman: "..tostring(GodHuman))
print("SwordCDK: "..tostring(SwordCDK))
print("fruitAwank: "..tostring(fruitAwank))
print("namefrutis: "..namefrutis)
print("MaxMastery: ".._G.MaxF)
print("CurrenMastery: ".._G.CurrentF)

-- ===== Conditions =====
if levelplayer < 2800 then
    print("Script banana")
    RunScript("banana")
    task.spawn(function()
        while task.wait(5) do
            print("levelplayer < 2800")
            local levelplayer = getLevel()
            local SwordCDK = checkGod()
            if SwordCDK and levelplayer >= 2800 then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
            end
        end
    end)
elseif namefrutis == "" or fruitAwank == false or _G.CurrentF < _G.MaxF or _G.CurrentF == 0 then
    print("Maru")
    RunScript("maru")
    task.spawn(function()
        while task.wait(5) do
            print("Farm Frutis")
            local namefrutis = player.Data.DevilFruit.Value
            local fruitAwank = isFruitFullyAwakened()
            if namefrutis ~= '' then
                _G.MMaxF = CheckMaxFruitsMastery(namefrutis)
                _G.CurrentF = CheckCurrentMastery(namefrutis)
            end
            if namefrutis ~= "" and fruitAwank == true and _G.CurrentF >= _G.MaxF then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
                return
            end
        end
    end)
elseif SwordCDK == false then
    print("banana")
    RunScript("banana")

    task.spawn(function()
        while task.wait(5) do
            print("SwordCDK == false")
            local SwordCDK = checkCDK()
            if SwordCDK then
                game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, game.JobId, game.Players.LocalPlayer)
                return
            end
        end
    end)
elseif SwordCDK then
    print("Maru")
    RunScript("maru")
end
