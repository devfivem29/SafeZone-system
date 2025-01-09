ESX = exports["es_extended"]:getSharedObject()

-- Variables
local playerInSafeZone = false
local showText = false
local textToShow = ""
local textTimer = 0
local textColor = {0, 255, 0} -- Vert par défaut

-- Fonction pour afficher du texte à l'écran
function DrawTextBottom(text, color)
    SetTextFont(4)
    SetTextScale(Config.TextSettings.textScale, Config.TextSettings.textScale)
    SetTextColour(color[1], color[2], color[3], 255) -- Couleur dynamique
    SetTextOutline()
    SetTextCentre(true)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(Config.TextSettings.textPosition.x, Config.TextSettings.textPosition.y)
end

-- Gestion des blips des zones sécurisées
Citizen.CreateThread(function()
    for _, zone in ipairs(Config.SafeZones) do
        local blip = AddBlipForRadius(zone.coords, zone.radius)
        SetBlipHighDetail(blip, true)
        SetBlipColour(blip, 2) -- Couleur verte
        SetBlipAlpha(blip, 128) -- Transparence

        local marker = AddBlipForCoord(zone.coords)
        SetBlipSprite(marker, 161)
        SetBlipDisplay(marker, 4)
        SetBlipScale(marker, 1.0)
        SetBlipColour(marker, 2)
        SetBlipAsShortRange(marker, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.name)
        EndTextCommandSetBlipName(marker)
    end

    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local inSafeZone = false

        for _, zone in ipairs(Config.SafeZones) do
            local distance = #(playerCoords - zone.coords)
            if distance <= zone.radius then
                inSafeZone = true
                if not playerInSafeZone then
                    playerInSafeZone = true
                    showText = true
                    textTimer = GetGameTimer() + 10000 -- Affiche le texte pendant 10 secondes
                    textToShow = Config.SafeZoneNotification.enter
                    textColor = Config.TextSettings.enterColor -- Vert
                end

                -- Désarme automatiquement le joueur s'il entre dans la zone sécurisée
                if IsPedArmed(playerPed, 7) then
                    SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
                end

                break
            end
        end

        if not inSafeZone and playerInSafeZone then
            playerInSafeZone = false
            showText = true
            textTimer = GetGameTimer() + 10000 -- Affiche le texte pendant 10 secondes
            textToShow = Config.SafeZoneNotification.exit
            textColor = Config.TextSettings.exitColor -- Rouge
        end

        Citizen.Wait(500)
    end
end)

-- Affichage du texte informatif
Citizen.CreateThread(function()
    while true do
        if showText then
            if GetGameTimer() < textTimer then
                DrawTextBottom(textToShow, textColor)
            else
                showText = false
            end
        end
        Citizen.Wait(0)
    end
end)

-- Désactivation des attaques et de la touche R dans les zones sécurisées
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if playerInSafeZone then
            -- Désactiver la touche "R" (Coup de poing et rechargement)
            if Config.SafeZoneSettings.disableR then
                DisableControlAction(0, 45, true) 
            end

            -- Empêcher les attaques (coups de poing, coups de pied, crosse)
            if Config.SafeZoneSettings.disableAttack then
                DisableControlAction(0, 140, true) -- Coup de poing léger
                DisableControlAction(0, 141, true) -- Coup de poing fort
                DisableControlAction(0, 142, true) -- Coup de coudes
                DisableControlAction(0, 263, true) -- Coup de crosse d'arme
                DisableControlAction(0, 264, true) -- Coup de pied
            end

            -- Désactiver le tir
            if Config.SafeZoneSettings.disableShoot then
                DisableControlAction(0, 24, true) -- Tir (clic gauche)
                DisableControlAction(0, 257, true) -- Tir avec arme
            end

            -- Désactiver la visée
            if Config.SafeZoneSettings.disableAim then
                DisableControlAction(0, 25, true) -- Visée (clic droit)
            end

            -- Désarme automatiquement le joueur
            if Config.SafeZoneSettings.autoUnarm then
                local playerPed = PlayerPedId()
                if IsPedArmed(playerPed, 6) then
                    SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
                end
            end
        end
    end
end)

-- Empêche les attaques contre d'autres joueurs dans les zones sécurisées
AddEventHandler('gameEventTriggered', function(eventName, data)
    if eventName == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        local attacker = data[2]

        if attacker and victim and DoesEntityExist(victim) and DoesEntityExist(attacker) then
            local victimCoords = GetEntityCoords(victim)

            for _, zone in ipairs(Config.SafeZones) do
                local distance = #(victimCoords - zone.coords)
                if distance <= zone.radius then
                    CancelEvent()
                    break
                end
            end
        end
    end
end)

-- Anti-CarKill (Empêcher d'écraser des joueurs en zone sécurisée)
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if Config.SafeZoneSettings.antiCarKill then
            local playerPed = PlayerPedId()
            if playerInSafeZone and IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)
                SetEntityNoCollisionEntity(vehicle, playerPed, true)
                DisableControlAction(0, 59, true) -- Désactiver le contrôle du véhicule en marche
                DisableControlAction(0, 60, true) -- Désactiver le contrôle du véhicule en marche
            end
        end
    end
end)
