local missions = {}
local repairMens = {}
local missionId = 0

RegisterServerEvent("repairman:isRepairman")
AddEventHandler("repairman:isRepairman", function()
  TriggerEvent('es:getPlayerFromId', source, function(user)
    local isRepairman = false
    local executed_query = MySQL:executeQuery("SELECT * FROM users LEFT JOIN jobs ON jobs.job_id = users.job WHERE identifier = '@identifier' AND jobs.job_name = 'Mécanicien'", {['@identifier'] = user.identifier})
    local result = MySQL:getResults(executed_query, {'job'}, "identifier")
    if (result[1] ~= nil) then
      isRepairman = true
    end
    TriggerClientEvent('repairman:setRepairman', source, isRepairman)
  end)
end)

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

TriggerEvent('es:addAdminCommand', 'addMeca', 5, function(source, args, user)
  local newMecaId = args[2]
  if (newMecaId ~= nil) then
    TriggerEvent('es:getPlayerFromId', tonumber(newMecaId), function(newMeca)
      local query = MySQL:executeQuery("SELECT * FROM jobs WHERE job_name = 'Mécanicien'")
      local result = MySQL:getResults(query, {"job_id"}, "job_id")
      print("ici", result)
      if result and result[1] then
        local jobId = result[1].job_id
        print("jobid ", jobId)
        local query2 = MySQL:executeQuery("UPDATE users SET job = '@job_id' WHERE identifier = '@identifier'",
        {["@identifier"] = newMeca.identifier, ["@job_id"] = jobId})

        TriggerClientEvent('repairman:addMeca', source, "Nouveau mécanicien ajouté")
        TriggerClientEvent('repairman:addMeca', newMecaId, "Vous êtes maintenant mécanicien", true)
      end
    end)
  end
end, function(source, args, user)
  TriggerClientEvent('repairman:addMeca', source, "Vous n'avez pas le droit de faire cela")
end)
