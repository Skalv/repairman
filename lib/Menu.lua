Menu = {}
Menu.__index = Menu

setmetatable(Menu, {
	__call = function(self, sample, openKey)
    Citizen.Trace("Cration du menu" .. sample.Title)
    local mn = {}

    mn.item = sample

    mn.backgroundColor = { 52, 73, 94, 196 }
    mn.backgroundColorActive = {192, 57, 43, 255}
    mn.tileTextColor = {192, 57, 43, 255}
    mn.tileBackgroundColor = { 255,255,255, 255 }
    mn.textColor = { 255,255,255,255 }
    mn.textColorActive = { 255,255,255, 255 }

    mn.keyOpenMenu = openKey -- F6
    mn.keyUp = 172 -- PhoneUp
    mn.keyDown = 173 -- PhoneDown
    mn.keyLeft = 174 -- PhoneLeft || Not use next release Maybe
    mn.keyRight =	175 -- PhoneRigth || Not use next release Maybe
    mn.keySelect = 176 -- PhoneSelect
    mn.KeyCancel = 177 -- PhoneCancel
    mn.IgnoreNextKey = false
    mn.posX = 0.05
    mn.posY = 0.05

    mn.ItemWidth = 0.20
    mn.ItemHeight = 0.03

    mn.isOpen = false   -- /!\ Ne pas toucher
    mn.currentPos = {1} -- /!\ Ne pas toucher

		return setmetatable(mn, Menu)
	end
})

function Menu:open()
  self:initMenu()
  self.isOpen = true
end

function Menu:close()
  self.isOpen = false
end

function drawRect(posX, posY, width, heigh, color)
  DrawRect(posX + width / 2, posY + heigh / 2, width, heigh, color[1], color[2], color[3], color[4])
end

function initText(textColor, font, scale)
  font = font or 0
  scale = scale or 0.35
  SetTextFont(font)
  SetTextScale(0.0,scale)
  SetTextCentre(true)
  SetTextDropShadow(0, 0, 0, 0, 0)
  SetTextEdge(0, 0, 0, 0, 0)
  SetTextColour(textColor[1], textColor[2], textColor[3], textColor[4])
  SetTextEntry("STRING")
end

function Menu:start()
  Citizen.Trace("Start")
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(1)
      if self.keyOpenMenu ~= nil then
        if IsControlJustPressed(1, self.keyOpenMenu) then
          self.isOpen = not self.isOpen
        end
      end
      if self.isOpen then
        self:keyControl()
        self:draw()
      end
    end
  end)
end

function Menu:draw()
  -- Draw Rect
  local pos = 0
  local menu = self:getCurrentMenu()
  local selectValue = self.currentPos[#self.currentPos]
  local nbItem = #menu.Items

  -- draw background title & title
  drawRect(self.posX, self.posY , self.ItemWidth, self.ItemHeight * 2, self.tileBackgroundColor)
  initText(self.tileTextColor, 4, 0.7)
  AddTextComponentString(menu.Title)
  DrawText(self.posX + self.ItemWidth/2, self.posY)

  -- draw bakcground items
  drawRect(self.posX, self.posY + self.ItemHeight * 2, self.ItemWidth, self.ItemHeight + (nbItem-1) * self.ItemHeight, self.backgroundColor)
  -- draw all items
  for pos, value in pairs(menu.Items) do
    if pos == selectValue then
      drawRect(self.posX, self.posY + self.ItemHeight * (1+pos), self.ItemWidth, self.ItemHeight, self.backgroundColorActive)
      initText(self.textColorActive)
    else
      initText(value.TextColor or self.textColor)
    end
    AddTextComponentString(value.Title)
    DrawText(self.posX + self.ItemWidth/2, self.posY + self.ItemHeight * (pos+1))
  end
end

function Menu:getCurrentMenu()
  local currentMenu = self.item
  for i=1, #self.currentPos - 1 do
    local val = self.currentPos[i]
    currentMenu = currentMenu.Items[val].SubMenu
  end
  return currentMenu
end

function Menu:initMenu()
  self.currentPos = {1}
  self.IgnoreNextKey = true
end

function Menu:keyControl()
  if self.IgnoreNextKey == true then
    self.IgnoreNextKey = false
    return
  end

  if IsControlJustPressed(1, self.keyDown) then
    local cMenu = self:getCurrentMenu()
    local size = #cMenu.Items
    local slcp = #self.currentPos
    self.currentPos[slcp] = (self.currentPos[slcp] % size) + 1

  elseif IsControlJustPressed(1, self.keyUp) then
    local cMenu = self:getCurrentMenu()
    local size = #cMenu.Items
    local slcp = #self.currentPos
    self.currentPos[slcp] = ((self.currentPos[slcp] - 2 + size) % size) + 1

  elseif IsControlJustPressed(1, self.KeyCancel) then
    table.remove(self.currentPos)
    if #self.currentPos == 0 then
      self.isOpen = false
    end

  elseif IsControlJustPressed(1, self.keySelect) then
    local cSelect = self.currentPos[#self.currentPos]
    local cMenu = self:getCurrentMenu()
    if cMenu.Items[cSelect].SubMenu ~= nil then
      self.currentPos[#self.currentPos + 1] = 1
    else
      if cMenu.Items[cSelect].ReturnBtn == true then
        table.remove(self.currentPos)
        if #self.currentPos == 0 then
          self.isOpen = false
        end
      else
        if cMenu.Items[cSelect].Function ~= nil then
          cMenu.Items[cSelect].Function(cMenu.Items[cSelect])
        end
        if cMenu.Items[cSelect].Event ~= nil then
          TriggerEvent(cMenu.Items[cSelect].Event, cMenu.Items[cSelect])
        end
        if cMenu.Items[cSelect].Close == nil or cMenu.Items[cSelect].Close == true then
          self.isOpen = false
        end
      end
    end
  end
end

function Menu:addItem(nItem)
  table.insert(self.item.Items, nItem)
end

function Menu:updateItem(uItem)
  for i=0, #self.item.Items do
    if self.item.Items[i].uid == iItem.uid then
      self.item.Items[i] = uItem
    end
  end
end

function Menu:removeItem(rItem)
  for i=0, #self.item.Items do
    table.remove(self.item.Items, i)
  end
end
