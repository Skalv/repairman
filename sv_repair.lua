local missions = {}
local repairMens = {}
local missionId = 0

RegisterServerEvent("repairman:inJob")
AddEventHandler("repairman:inJob", function(inJob)
  if (inJob == 1) then
    local repairman = {
      ["sid"] = source,
      ["inMission"] = false
    }
    table.insert(repairMens, repairman)
    TriggerClientEvent("repairman:updateMissionList", source, missions)
  else
    for i = 1, #repairMens do
      if (repairMens[i].sid == source) then
        table.remove(repairMens, i)
      end
    end
  end
end)

RegisterServerEvent("repairman:newMission")
AddEventHandler("repairman:newMission", function(posX, posY, posZ, type)
  missionId = missionId + 1
  local newMission = {
    ["id"] = missionId,
    ["playerId"] = source,
    ["posX"] = posX,
    ["posY"] = posY,
    ["posZ"] = posZ,
    ["type"] = type,
    ["acceptBy"] = nil
  }
  table.insert(missions, newMission)
  for _, v in pairs(repairMens) do
    TriggerClientEvent("repairman:updateMissionList", v.sid, missions)
  end
end)

RegisterServerEvent("repairman:acceptMission")
AddEventHandler("repairman:acceptMission", function(missionId)
  for i = 1, #missions do
    if (missions[i].id == missionId) then
      if (missions[i].acceptBy ~= nil) then
        TriggerClientEvent("repairman:missionAlreadyOccuped", source)
      end
      missions[i].acceptBy = source
      TriggerClientEvent("repairman:missionAccepted", missions[i].playerId)
    end
  end

  for _, v in pairs(repairMens) do
    TriggerClientEvent("repairman:updateMissionList", v.sid, missions)
  end
end)

RegisterServerEvent("repairman:endMission")
AddEventHandler("repairman:endMission", function(missionId)
  for i = 1, #missions do
    if (missions[i].id == missionId) then
      TriggerClientEvent("repairman:missionFinish", missions[i].playerId)
      table.remove(missions, i)
    end
  end
  print("missions" .. missionId .. " removed")

  for _, v in pairs(repairMens) do
    TriggerClientEvent("repairman:updateMissionList", v.sid, missions)
  end
end)

-- DEBUG
TriggerEvent('es:addCommand', 'showMeca', function(source, args, user)
  for i = 1, #repairMens do
    print(repairMens[i].sid .. " : " .. repairMens[i].inMission)
  end
end)
