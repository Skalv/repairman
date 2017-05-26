local isRepairman = nil
local inJob = false
local VehicleTowTruck = GetHashKey('towtruck')
local VehicleFlatBed = GetHashKey('flatbed')
local missionsList = {}
local currentMission = nil
local currentBlip = nil
local showHelpLine = false

local GaragesCoords = {
  {
    ['PriseDeService'] = {x = -1148.4748, y = -2000.0338, z = 13.1803},
    ['RepairArea'] = {x = -1131.28,  y = -2001.58,  z = 13.58, r = 50.0},
    ['SpawnVehicle'] = {x = -1145.58, y = -1977.95, z = 13.1611},
    ['PoundArea'] = {x = -1138.07, y = -2034.9, z = 13.2015}
  },
}

local function isNearRepairGarage()
	for _, c in pairs(GaragesCoords) do
		local ply = GetPlayerPed(-1)
		local plyCoords = GetEntityCoords(ply, 0)
		local distance = GetDistanceBetweenCoords(c.PriseDeService.x, c.PriseDeService.y, c.PriseDeService.z, plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
		if(distance < 30) then
			DrawMarker(1, c.PriseDeService.x, c.PriseDeService.y, c.PriseDeService.z-1, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.5, 0, 0, 255, 155, 0, 0, 2, 0, 0, 0, 0)
		end
		if(distance < 2) then
			return true
		end
	end
end

local function isNearSpawnVehicle()
	for _, c in pairs(GaragesCoords) do
		local ply = GetPlayerPed(-1)
		local plyCoords = GetEntityCoords(ply, 0)
		local distance = GetDistanceBetweenCoords(c.SpawnVehicle.x, c.SpawnVehicle.y, c.SpawnVehicle.z, plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
		if(distance < 30) then
			DrawMarker(1, c.SpawnVehicle.x, c.SpawnVehicle.y, c.SpawnVehicle.z-1, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.5, 0, 0, 255, 155, 0, 0, 2, 0, 0, 0, 0)
		end
		if(distance < 2) then
			return true
		end
	end
end

local function isNearRepairArea()
  for _, c in pairs(GaragesCoords) do
		local ply = GetPlayerPed(-1)
		local plyCoords = GetEntityCoords(ply, 0)
		local distance = GetDistanceBetweenCoords(c.RepairArea.x, c.RepairArea.y, c.RepairArea.z, plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
		if(distance < 10) then
			return true
		end
	end
end

local function isNearPoundArea()
  for _, c in pairs(GaragesCoords) do
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)
		local distance = GetDistanceBetweenCoords(c.PoundArea.x, c.PoundArea.y, c.PoundArea.z, plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
    if(distance < 30) then
			DrawMarker(1, c.PoundArea.x, c.PoundArea.y, c.PoundArea.z-1, 0, 0, 0, 0, 0, 0, 2.0, 2.0, 1.5, 0, 0, 255, 155, 0, 0, 2, 0, 0, 0, 0)
		end
    if(distance < 3) then
			return true
		end
  end
end

local function spawnVehicle(vehicle)
  local car = vehicle
  local ply = GetPlayerPed(-1)

  RequestModel(car)
  while not HasModelLoaded(car) do
    Citizen.Wait(0)
  end

  existingVeh = CreateVehicle(car, -1145.58, -1977.95, 13.1611, -90.0, true, false)
  SetVehicleNumberPlateText(existingVeh, "Depa001")
  local id = NetworkGetNetworkIdFromEntity(existingVeh)
  SetNetworkIdCanMigrate(id, true)
  TaskWarpPedIntoVehicle(ply, existingVeh, -1)
end

local function GetVehicleInDirection( coordFrom, coordTo )
  local rayHandle = CastRayPointToPoint( coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z, 10, GetPlayerPed( -1 ), 0 )
  local _, _, _, _, vehicle = GetRaycastResult( rayHandle )
  return vehicle
end

local function GetVehicleLookByPlayer(ped, dist)
  local playerPos = GetEntityCoords(ped, 1)
  local inFrontOfPlayer = GetOffsetFromEntityInWorldCoords( ped, 0.0, dist, 0.0 )
  return GetVehicleInDirection( playerPos, inFrontOfPlayer )
end

-- Repairman functions --
function getStatusVehicle()
  local myPed = GetPlayerPed(-1)
  local vehicle = GetVehicleLookByPlayer(myPed, 3.0)
  local p = GetEntityCoords(vehicle, 0)
  local h = GetEntityHeading(vehicle)
  if vehicle ~= 0 then
    local scenario = 'PROP_HUMAN_BUM_SHOPPING_CART'
    local pos = GetOffsetFromEntityInWorldCoords(myPed, 0.0, 0.2, 0.0)
    TaskStartScenarioAtPosition(myPed, scenario, pos.x, pos.y, pos.z, 180.0, 8000, 1, 0)
    Citizen.Wait(8000)
    ClearPedTasks(myPed)
    local engineHealth = GetVehicleEngineHealth(vehicle)
    if engineHealth >= 950 then
      DrawMissionText('~g~Aucun probleme',8000)
    elseif engineHealth >= 0 then
      DrawMissionText('~o~Le véhicule est endommager, mais il est réparable sur place',8000)
    else
      DrawMissionText("~r~Véhicule HS, il doit etre rapatrié dans un garage pour réparation",8000)
    end
    -- end
  else
    DrawMissionText("~r~Placer vous devant un véhicule")
  end
end

function repairVehicle()
  local myPed = GetPlayerPed(-1)
  local vehicle = GetVehicleLookByPlayer(myPed, 3.0)
  if vehicle ~= 0 then
    local scenario = 'WORLD_HUMAN_VEHICLE_MECHANIC'
    local pos = GetOffsetFromEntityInWorldCoords(myPed, 0.0, 0.2, 0.0)
    TaskStartScenarioAtPosition(myPed, scenario, pos.x, pos.y, pos.z, 0.0, 8000, 1, 0)
    Citizen.Wait(8000)
    ClearPedTasks(myPed)
    local engineHealth = GetVehicleEngineHealth(vehicle)
    if engineHealth >= 0 then
      SetVehicleEngineHealth(vehicle, 1000.0)
      SetVehicleEngineOn(vehicle, 0, 0, 0)
      DrawMissionText("~g~Le véhicule a subit une réparation d'apoint", 5000)
    else
      DrawMissionText("~r~Le véhicule ne peut etre réparer sur place", 5000)
    end
  else
    DrawMissionText("~r~Placer vous devant un véhicule", 5000)
  end
end

function fullRepairVehicle()
  local myPed = GetPlayerPed(-1)
  local myPos = GetEntityCoords(myPed)
  if not isNearRepairArea() then
    DrawMissionText("~r~Ce type de reparation ne peut etre fait ici", 5000)
    return
  end
  local vehicle = GetVehicleLookByPlayer(myPed, 3.0)
  if vehicle ~= 0 then
    local scenario = 'WORLD_HUMAN_VEHICLE_MECHANIC'
    local pos = GetOffsetFromEntityInWorldCoords(myPed, 0.0, 0.2, 0.0)
    TaskStartScenarioAtPosition(myPed, scenario, pos.x, pos.y, pos.z, 0.0, 160000, 1, 0)
    local value = GetVehicleBodyHealth(vehicle)

    while( value < 999.9 ) do
      value = GetVehicleBodyHealth(vehicle)
      SetVehicleBodyHealth(vehicle, value + 1.0)
      DrawMissionText('Réparation en cours ~b~' .. math.floor(value) .. '/1000', 125)
      Citizen.Wait(125)
    end
    Citizen.Wait(250)
    ClearPedTasks(myPed)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehicleEngineHealth(vehicle, 1000.0)
    SetEntityHealth(vehicle,1000)
    SetVehiclePetrolTankHealth(vehicle,1000.0)
    SetVehicleEngineOn(vehicle, 0, 0, 0)
    SetVehicleBodyHealth(vehicle, 1000.0)
    SetVehicleFixed(vehicle)
    SetVehicleDeformationFixed(vehicle)
    SetVehicleUndriveable(vehicle, false)
    DrawMissionText('~g~Le véhicule est comme neuf', 5000)
  else
    DrawMissionText("~r~Placer vous devant un véhicule", 5000)
  end
end

function toggleCarHood()
  local myPed = GetPlayerPed(-1)
  local vehicle = GetVehicleLookByPlayer(myPed, 3.0)
  if vehicle ~= 0 then
    local CarHoodOpen = GetVehicleDoorAngleRatio(vehicle, 4) > 0.5
    if CarHoodOpen then
      SetVehicleDoorShut(vehicle, 4, 0, 0)
    else
      SetVehicleDoorOpen(vehicle, 4, 0, 0)
    end
  end
end

-- Pound manager
function addVehicleInPound()
  -- local carOnBlip = GetClosestVehicle(-1138.07, -2034.9, 13.2015, 3.000, 0, 70)
  -- SetEntityAsMissionEntity(carOnBlip, true, true)
  -- local carOnBlipsPlate = GetVehicleNumberPlateText(carOnBlip)
  -- TriggerServerEvent("repairman:addVehInPound", carOnBlipsPlate)
  -- Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(carOnBlip))
end

function rmVehicleInPound()

end

-- Mission manager
local function acceptMission(data)
  local mission = data.mission
  currentMission = mission
  TriggerServerEvent("repairman:acceptMission", mission.id)
  SetNewWaypoint(mission.posX, mission.posY)
  currentBlip = AddBlipForCoord(mission.posX, mission.posY, mission.posZ)
  SetBlipSprite(currentBlip, 446)
  SetBlipColour(currentBlip, 5)
  SetBlipAsShortRange(currentBlip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Mission en cours")
  EndTextCommandSetBlipName(currentBlip)
  SetBlipAsMissionCreatorBlip(currentBlip, true)
end

local function finishCurrentMission(data)
  Citizen.Trace("Mission terminé")
  TriggerServerEvent('repairman:endMission', currentMission.id)
  currentMission = nil
  if currentBlip ~= nil then
    RemoveBlip(currentBlip)
    currentBlip = nil
  end
end

local function updateMissionList(missions)
  local items = {{['Title'] = 'Retour', ['ReturnBtn'] = true }}
  for _,m in pairs(missions) do
    local item = {
      Title = 'Mission ' .. m.id .. ' [' .. m.type .. ']',
      mission = m,
      Function = acceptMission
    }
    local mySID = GetPlayerServerId(PlayerId())
    if m.acceptBy ~= nil then
      if (m.acceptBy == mySID) then
        item.Title = item.Title .. ' (En cours)'
        item.TextColor = {39, 174, 96, 255}
      else
        item.Title = item.Title .. ' (Déjà prise)'
        item.TextColor = {146, 149, 153, 255}
      end
    end
    table.insert(items, item)
  end
  if currentMission ~= nil then
    table.insert(items, {['Title'] = 'Terminer la mission', ['Function'] = finishCurrentMission})
  end
  table.insert(items, {['Title'] = 'Fermer'})

  menu = {
    ['Title'] = 'Mécanicien - liste des missions',
    ['SubMenu'] = {
      ['Title'] = 'Missions en cours',
      ['Items'] = items
    }
  }
  updateMenu(menu)
end

function toggleHelpLine()
  showHelpLine = not showHelpLine
end

local function trukHandler()
  local myPed = GetPlayerPed(-1)
  local myCoord = GetEntityCoords(myPed)
  local currentVehicle = GetVehiclePedIsIn(myPed, 0)

  if (currentVehicle == 0) then
    local towtruck = GetClosestVehicle(myCoord.x, myCoord.y, myCoord.z, 10.0, VehicleTowTruck, 70)
    if towtruck ~= 0 then
      local coords = GetOffsetFromEntityInWorldCoords(towtruck, -1.5, -3.2, 0)
      local dist = GetDistanceBetweenCoords(myCoord.x, myCoord.y, myCoord.z, coords.x, coords.y, coords.z, true)
      if dist < 10 then
        DrawMarker(1, coords.x, coords.y, coords.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 200, 0, 0, 0, 0)
      end
      if dist < 1.5 then
        -- showMessageInformation(TEXT.InfoGrue)
        SetTextComponentFormat("STRING")
        AddTextComponentString("~g~E~s~ attache/Detache le véhicule\n~g~PAGEUP~s~ monter la grue\n~g~PAGEDOWN~s~ pour baisser la grue")
        DisplayHelpTextFromStringLabel(0, 0, 1, -1)
        local c1 = GetOffsetFromEntityInWorldCoords(towtruck, 0.0, -4.3, 1.8)
        local c2 = GetOffsetFromEntityInWorldCoords(towtruck, 0.0, -4.3, -1.2)
        local vehicleAttach = GetEntityAttachedToTowTruck(towtruck)
        local vehicleGrap = GetVehicleInDirection(c1,c2)
        if ShowLineGrueHelp == true then
          if vehicleAttach ~= 0 then
            DrawLine(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 0, 255, 0, 255)
          elseif vehicleGrap ~= 0 then
            DrawLine(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 0, 0, 255, 255)
          else
            DrawLine(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 255, 0, 0, 255)
          end
        end
        if IsControlJustPressed(1, 10) then
          Citizen.InvokeNative(0xFE54B92A344583CA, towtruck, 1.0)
        elseif IsControlJustPressed(1, 11) then
          Citizen.InvokeNative(0xFE54B92A344583CA, towtruck, 0.0)
        elseif IsControlJustPressed(1, 38) then
          if vehicleAttach ~= 0 then
            DetachVehicleFromTowTruck(towtruck, vehicleAttach)
          elseif vehicleGrap ~= 0 then
            AttachVehicleToTowTruck(towtruck, vehicleGrap, true, 0.0,0.0,0.0)
          end
        end
      end
    else
      local flatbed = GetClosestVehicle(myCoord.x, myCoord.y, myCoord.z, 10.0, VehicleFlatBed, 70)
      if flatbed ~= 0 then
        local coords = GetOffsetFromEntityInWorldCoords(flatbed, -1.5, -5.2, 0)
        local dist = GetDistanceBetweenCoords(myCoord.x, myCoord.y, myCoord.z, coords.x, coords.y, coords.z, true)
        if dist < 10 then
          DrawMarker(1, coords.x, coords.y, coords.z, 0, 0, 0, 0, 0, 0, 1.0, 1.0, 1.0, 255, 0, 0, 200, 0, 0, 0, 0)
        end
        if dist < 1.5 then
          local c1 = GetOffsetFromEntityInWorldCoords(flatbed, 0.0, 0.0, 0.6)
          local c2 = GetOffsetFromEntityInWorldCoords(flatbed, 0.0, -5.0, 1.6)
          local cvg = GetVehicleInDirection(c1,c2)
          if cvg ~= 0 and GetEntityAttachedTo(cvg) == flatbed then
            SetTextComponentFormat("STRING")
            AddTextComponentString('~g~E~s~ Détacher le véhicule')
            DisplayHelpTextFromStringLabel(0, 0, 1, -1)
            if IsControlJustPressed(1, 38) then
              DetachEntity(cvg, true, true)
              local c = GetOffsetFromEntityInWorldCoords(flatbed, 0.0, -10.0, 0)
              SetEntityCoords(cvg,c.x, c.y, c.z)
              SetVehicleOnGroundProperly(cvg)
            end
          else
            local c1 = GetOffsetFromEntityInWorldCoords(flatbed, 0.0, -7.3, 1.8)
            local c2 = GetOffsetFromEntityInWorldCoords(flatbed, 0.0, -7.3, -1.2)
            local vehicleGrap = GetVehicleInDirection(c1,c2)
            if showHelpLine then
              if vehicleGrap ~= 0 then
                DrawLine(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 0, 255, 0, 255)
              else
                DrawLine(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 255, 0, 0, 255)
              end
            end
            if vehicleGrap ~= 0 then
              SetTextComponentFormat("STRING")
              AddTextComponentString('~g~E~s~ Attacher le véhicule')
              DisplayHelpTextFromStringLabel(0, 0, 1, -1)
              if IsControlJustPressed(1, 38) then
                AttachEntityToEntity(vehicleGrap, flatbed, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, true, false, 20, true)
              end
            else
              SetTextComponentFormat("STRING")
              AddTextComponentString('Aucun véhicule a porté')
              DisplayHelpTextFromStringLabel(0, 0, 1, -1)
              if IsControlJustPressed(1, 38) then
                DetachEntity(flatbed, true,true)
              end
            end
          end
        end
      end
    end
  else
    if showHelpLine then
      if (IsVehicleModel(currentVehicle, VehicleTowTruck)) then
        local c1 = GetOffsetFromEntityInWorldCoords(currentVehicle, 0.0, -4.3, 1.8)
        local c2 = GetOffsetFromEntityInWorldCoords(currentVehicle, 0.0, -4.3, -0.8)
        local vehicle = GetVehicleInDirection(c1,c2)
        if vehicle ~= 0 then
          DrawLine(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 0, 0, 255, 255)
        else
          DrawLine(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 255, 0, 0, 255)
        end
      elseif (IsVehicleModel(currentVehicle, VehicleFlatBed)) then
        local c1 = GetOffsetFromEntityInWorldCoords(currentVehicle, 0.0, -7.3, 1.8)
        local c2 = GetOffsetFromEntityInWorldCoords(currentVehicle, 0.0, -7.3, -1.2)
        local vehicleGrap = GetVehicleInDirection(c1,c2)
        if vehicleGrap ~= 0 then
          DrawLine(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 0, 255, 0, 255)
        else
          DrawLine(c1.x, c1.y, c1.z, c2.x, c2.y, c2.z, 255, 0, 0, 255)
        end
      else
        DrawMissionText("Ce véhicule n'est pas une dépaneuse.")
      end
    end
  end
end

RegisterNetEvent('repairman:updateMissionList')
AddEventHandler('repairman:updateMissionList', function (missions)
  updateMissionList(missions)
end)

RegisterNetEvent('repairman:missionAlreadyOccuped')
AddEventHandler('repairman:missionAlreadyOccuped', function ()
  -- notifIcon("CHAR_BLANK_ENTRY", 1, "Mecano Info", false, "La mission est déjà prise par quelqu'un d'autre")
  DisplayNotification("La mission est déjà prise par quelqu'un d'autre")
end)

RegisterNetEvent("repairman:addMeca")
AddEventHandler('repairman:addMeca', function (text, newRepairman)
  DisplayNotification(text)
  if (newRepairman ~= nil) then
    isRepairman = newRepairman
  end
end)

AddEventHandler('playerSpawned', function(spawn)
  TriggerServerEvent("repairman:isRepairman")

	Citizen.CreateThread(function()
		while isRepairman == nil do
			Citizen.Wait(1)
			RegisterNetEvent('repairman:setRepairman')
			AddEventHandler('repairman:setRepairman', function(repairman)
        isRepairman = repairman
			end)
		end

    Citizen.Wait(2500)

    for _, c in pairs(GaragesCoords) do
      local currentBlip = AddBlipForCoord(c.RepairArea.x, c.RepairArea.y, c.RepairArea.z)
      SetBlipSprite(currentBlip, 446)
      SetBlipAsShortRange(currentBlip, true)
      SetBlipColour(currentBlip, 1)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Mécanicien")
      EndTextCommandSetBlipName(currentBlip)
      SetBlipAsMissionCreatorBlip(currentBlip, true)
    end
  end)
end)

-- Main Thread
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
    if isRepairman and isNearRepairGarage() then
			if(inJob) then
				drawTxt("Appuyer sur ~g~E~s~ pour terminer votre service.",0,1,0.5,0.8,0.6,255,255,255,255)
			else
				drawTxt("Appuyer sur ~g~E~s~ pour prendre votre service.",0,1,0.5,0.8,0.6,255,255,255,255)
			end
			if IsControlJustPressed(1, 38)  then
				inJob = not inJob
				if(inJob) then
          local myPed = GetPlayerPed(-1)
          SetPedComponentVariation(myPed, 3, 11, 0, 2) -- TORSO
          SetPedComponentVariation(myPed, 11, 43, 0, 2) -- TORSO2
          SetPedComponentVariation(myPed, 4, 41, 0, 2) -- LEGS
          SetPedComponentVariation(myPed, 6, 25, 0, 2) -- FEET
          SetPedComponentVariation(myPed, 8, 15, 0, 2) -- ACCESSORIE

          TriggerServerEvent("repairman:inJob", 1)
				else

					TriggerServerEvent("skin_customization:SpawnPlayer")
          TriggerServerEvent("repairman:inJob", 0)
				end
			end
    end

    if isRepairman and inJob and isNearSpawnVehicle() then
      if(existingVeh ~= nil) then
        drawTxt("Appyyez sur ~g~E~s~ pour rentrer le vehicule.",0,1,0.5,0.8,0.6,255,255,255,255)
      else
        drawTxt("Appuyez sur ~g~E~s~ pour sortir la dépaneuse ou ~g~F~s~ pour sortir le plateau.",0,1,0.5,0.8,0.6,255,255,255,255)
      end

      if IsControlJustPressed(1, 38)  then
        if(existingVeh ~= nil) then
          SetEntityAsMissionEntity(existingVeh, true, true)
          Citizen.InvokeNative(0xEA386986E786A54F, Citizen.PointerValueIntInitialized(existingVeh))
          existingVeh = nil
        else
          spawnVehicle(VehicleTowTruck)
        end
      end
      if IsControlJustPressed(1, 23) then
        spawnVehicle(VehicleFlatBed)
      end
    end

    if isRepairman and inJob and (currentMission ~= nil) then
      trukHandler()
    end

    if IsControlJustPressed(1, 167) then
      openMenuGeneral()
    end
  end
end)
