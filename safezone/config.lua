-- config.lua
Config = {}

Config.SafeZoneSettings = {
    disableR = true,       -- Désactiver la touche R
    disableAttack = true,  -- Désactiver les attaques (poing, pied, crosse, arme)
    disableShoot = true,   -- Désactiver le tir
    disableAim = true,     -- Désactiver la visée
    autoUnarm = true,      -- Forcer le joueur à être désarmé
    antiCarKill = true     -- Empêcher les joueurs d'écraser d'autres joueurs en zone sécurisée
}

Config.SafeZones = {
    {
        name = "zone sécurisée",
        coords = vector3(449.89,-981.42,43.68), -- Coordonnées de la zone safe
        radius = 75.0 -- Rayon de la zone safe
    },
   --[[ {
        name = "exemple",
        coords = vector3(-56.95,-1094.84,26.41), -- Coordonnées de la zone safe
        radius = 75.0 -- Rayon de la zone safe
    },--]]
    {
        name = "zone sécurisée",
        coords = vector3(1000.0, 2000.0, 30.0),
        radius = 75.0
    }
}

-------------------Message affiché à l'écran--------------------------------------
Config.SafeZoneNotification = {
    enter = "Vous êtes entré dans une zone sécurisée.",
    exit = "Vous avez quitté une zone sécurisée."
}

------------------Paramètres d'affichage du texte----------------------
Config.TextSettings = {
    enterColor = {0, 255, 0}, -- Couleur verte
    exitColor = {255, 0, 0}, -- Couleur rouge
    textScale = 0.6, -- Taille du texte
    textPosition = {x = 0.5, y = 0.9} -- Position du texte (bas de l'écran, centré)
}
