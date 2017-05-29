local function CustomVehicleDommage()
  local myPed = GetPlayerPed(-1)
  local vehicle = GetVehiclePedIsIn(myPed, 0)
  if vehicle ~= 0 then
    local engineHealth = GetVehicleEngineHealth(vehicle)
    local vehicleHealth = GetEntityHealth(vehicle)
    local petrolTankeHealth = GetVehiclePetrolTankHealth(vehicle)
    local total = engineHealth + vehicleHealth + petrolTankeHealth
    local bodyHealth = GetVehicleBodyHealth(vehicle)
    if total < 2800 and engineHealth >= 1 then
      if vehicleHealth + petrolTankeHealth < 1800 or vehicleHealth < 750 then
        SetVehicleEngineHealth(vehicle, -1.0)
        SetVehicleEngineOn(vehicle, 0, 0, 0)
        SetVehicleBodyHealth(vehicle, vehicleHealth * 0.1 )
      else
        SetVehicleEngineHealth(vehicle, 0.0)
        SetVehicleEngineOn(vehicle, 0, 0, 0)
      end
    end
    -- ClearPrints()
    -- SetTextEntry_2("STRING")
    -- AddTextComponentString("~g~ total : ".. total .. "\n engine : " .. engineHealth .. '\n vehicle : ' .. vehicleHealth .. '\n reservoir : ' .. petrolTankeHealth .. '\n body :' .. bodyHealth)
    -- DrawSubtitleTimed(200, 1)
  end
end

function callRepairman(data)
  local myPed = GetPlayerPed(-1)
  local myCoord = GetEntityCoords(myPed)
  TriggerServerEvent('repairman:newMission', myCoord.x, myCoord.y, myCoord.z, 'vehicule en panne')
  DisplayNotification("Une dépaneuse vient d'être appelée.")
end

function removeVehicle(data)
  local myPed = GetPlayerPed(-1)
  local myCoord = GetEntityCoords(myPed)
  TriggerServerEvent('repairman:newMission', myCoord.x, myCoord.y, myCoord.z, 'enlèvement')
  DisplayNotification("Un plateau vient d'être appelée.")
end

RegisterNetEvent("repairman:callRepairman")
AddEventHandler("repairman:callRepairman", function(data)
  callRepairman(data)
end)

RegisterNetEvent("repairman:noRepairman")
AddEventHandler("repairman:noRepairman", function(data)
  notifIcon("CHAR_BLANK_ENTRY", 1, "Garagiste", false, "Le garage est actuellement fermé.\nMerci de rappeler plus tard.")
end)

RegisterNetEvent("repairman:noAvailableRM")
AddEventHandler("repairman:noAvailableRM", function(data)
  notifIcon("CHAR_BLANK_ENTRY", 1, "Garagiste", false, "Tous nos dépanneurs sont occupés.\nMerci de patienter.")
end)

RegisterNetEvent("repairman:missionAccepted")
AddEventHandler("repairman:missionAccepted", function()
  notifIcon("CHAR_BLANK_ENTRY", 1, "Garagiste", false, "Le dépanneur arrive !")
  -- DisplayNotification("Un dépanneur est en route.")
end)

RegisterNetEvent("repairman:missionFinish")
AddEventHandler("repairman:missionFinish", function()
  notifIcon("CHAR_BLANK_ENTRY", 1, "Garagiste", false, "Le dépanneur a terminé !")
  --DisplayNotification("Le dépanneur a terminé.")
end)

RegisterNetEvent("repairman:alreadyCalled")
AddEventHandler("repairman:alreadyCalled", function()
  notifIcon("CHAR_BLANK_ENTRY", 1, "Garagiste", false, "Vous avez déjà appelé une dépaneuse !")
  -- DisplayNotification("Vous avez déjà appelé une dépaneuse !")
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    CustomVehicleDommage()
  end
end)
