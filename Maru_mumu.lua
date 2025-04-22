getgenv().Mode = "OneClick"
getgenv().Setting = {
    ["Team"] = "Pirates",
    ["FucusOnLevel"] = true,
    ["Fruits"] = {
        ["Primary"] = {
            "Dough-Dough",
            "Dragon-Dragon",
            "Leopard-Leopard"
        },
        ["Normal"] = {
            "Flame-Flame",
            "Light-Light",
            "Magma-Magma",
            "Dark-Dark",
            "Buddha-Buddha"
        }
    },
    ["Lock Fruits"] = {
        "Yeti-Yeti",
        "T-Rex-T-Rex",
        "Dough-Dough",
        "Dragon-Dragon",
        "Kitsune-Kitsune",
        "Leopard-Leopard",
        "Venom-Venom",
        "Spirit-Spirit",
        "Mammoth-Mammoth",
        "Gas-Gas"

    },
    ["IdleCheck"] = 300,
};
script_key = "bsfQcIWjLYnYZreRCHHmVbgcyoOhPJhB"
loadstring(game:HttpGet("https://api.luarmor.net/files/v3/loaders/7249ea0a31d1ad6a0b78ae62d3357e73.lua"))()
