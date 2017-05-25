Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}

function getPlayers()
  local playerList = {}
  for i = 0, 32 do
    local player = GetPlayerFromServerId(i)
    if NetworkIsPlayerActive(player) then
      table.insert(playerList, player)
    end
  end
  return playerList
end

function getNearPlayer(checkZone)
  local players = getPlayers()
  local pos = GetEntityCoords(GetPlayerPed(-1))
  local pos2
  local distance
  local minDistance = checkZone
  local playerNear
  for _, player in pairs(players) do
    pos2 = GetEntityCoords(GetPlayerPed(player))
    distance = GetDistanceBetweenCoords(pos["x"], pos["y"], pos["z"], pos2["x"], pos2["y"], pos2["z"], true)
    if (pos ~= pos2 and distance < minDistance) then
      playerNear = player
      minDistance = distance
    end
  end
  if (minDistance < checkZone) then
    return playerNear
  end
end

function DisplayNotification(text)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(text)
	DrawNotification(false, false)
end

function notifIcon(icon, type, sender, title, text)
	Citizen.CreateThread(function()
    Wait(1)
    SetNotificationTextEntry("STRING");
    if TEXT[text] ~= nil then
      text = TEXT[text]
    end
    AddTextComponentString(text);
    SetNotificationMessage(icon, icon, true, type, sender, title, text);
    DrawNotification(false, true);
	end)
end

function DrawMissionText(m_text, showtime)
  ClearPrints()
	SetTextEntry_2("STRING")
	AddTextComponentString(m_text)
	DrawSubtitleTimed(showtime, 1)
end

function PrintChatMessage(text)
  TriggerEvent('chatMessage', "system", { 255, 0, 0 }, text)
end

function printConsole(data)
  TriggerServerEvent('medics:printConsole', data)
end

function drawTxt(text,font,centre,x,y,scale,r,g,b,a)
	SetTextFont(font)
	SetTextProportional(0)
	SetTextScale(scale, scale)
	SetTextColour(r, g, b, a)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextCentre(centre)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x , y)
end

List = {}
function List.new()
  return {first = 0, last = -1}
end
function List.pushleft(list, value)
  local first = list.first - 1
  list.first = first
  list[first] = value
end
function List.pushright(list, value)
  local last = list.last + 1
  list.last = last
  list[last] = value
end
function List.popleft(list)
  local first = list.first
  if first > list.last then
    local value = nil
  else
    local value = list[first]
  end
  list[first] = nil        -- to allow garbage collection
  list.first = first + 1
  return value
end
function List.getfirst(list)
  return list[list.first]
end
function List.popright(list)
  local last = list.last
  if list.first > last then
    local value = nil
  else
    local value = list[last]
  end
  list[last] = nil         -- to allow garbage collection
  list.last = last - 1
  return value
end
function List.getlast(list)
  local last = list.last
  if list.first > last then
    local value = nil
  else
    local value = list[last]
  end
  return value
end
