ESX = exports["es_extended"]:getSharedObject()

RegisterNetEvent('playerEnteredSafeZone')
AddEventHandler('playerEnteredSafeZone', function(zoneName)
    print(('%s a entré la zone sécurisée: %s'):format(GetPlayerName(source), zoneName))
end)

RegisterNetEvent('playerExitedSafeZone')
AddEventHandler('playerExitedSafeZone', function(zoneName)
    print(('%s a quitté la zone sécurisée: %s'):format(GetPlayerName(source), zoneName))
end)