local threshold = Config.brakeLightThreshold
local vehicles = {}
local isLoopActive = false
local MPH_PER_MS = 2.236936

local function brakeLightLoop()
  CreateThread(function()
    isLoopActive = true
    while next(vehicles) do
      for vehicle, data in pairs(vehicles) do
        if DoesEntityExist(vehicle) then
          if data.blackout == 1 or (data.blackout == nil and not data.parked) then
            SetVehicleBrakeLights(vehicle, true)
          end
        else
          vehicles[vehicle] = nil
        end
      end
      Wait(0)
    end
    isLoopActive = false
  end)
end

AddStateBagChangeHandler('rbl_brakelights', nil, function(bagName, key, value)
  Wait(0)
  local vehicle = GetEntityFromStateBagName(bagName)
  if vehicle == 0 then return end
  if value then
    if not vehicles[vehicle] then
      local ent = Entity(vehicle)
      vehicles[vehicle] = {
        blackout = ent.state.rbl_blackout,
        parked = ent.state.rbl_parked,
        indicator = ent.state.rbl_indicator or 0
      }
    end
    if not isLoopActive then
     brakeLightLoop()
    end
  else
    vehicles[vehicle] = nil
  end
end)

local function parkTimer()
  local time = math.random((Config.parkTimerMin * 1000), Config.parkTimerMax * 1000)
  local expiration = GetGameTimer() + time
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  CreateThread(function()
    while true do
      if vehicle == 0 or not DoesEntityExist(vehicle) then return end
      local ped = PlayerPedId()
      if GetVehiclePedIsIn(ped, false) ~= vehicle then return end
      if GetPedInVehicleSeat(vehicle, -1) ~= ped then return end
      if (GetEntitySpeed(vehicle) * MPH_PER_MS) > 0 then return end
      if GetGameTimer() > expiration then
        TriggerServerEvent("rbl:setParked", VehToNet(vehicle), true)
        return
      end
      Wait(500)
    end
  end)
end

-- when i enter a vehicle, start a loop to check if i'm driving and if so, check speed and set brake lights
local function onEnteredVehicle(_vehicle)
  CreateThread(function()
    local vehicle = _vehicle
    local entity = Entity(vehicle)
    local vehicleNet = VehToNet(vehicle)
    local brakeLights = false

    while true do

      local ped = PlayerPedId()
      if GetVehiclePedIsIn(ped, false) ~= vehicle then
        if brakeLights then
          TriggerServerEvent('rbl:setBrakeLights', vehicleNet, false)
        end
        TriggerServerEvent("rbl:setParked", vehicleNet, true)
        return
      end
      if GetPedInVehicleSeat(vehicle, -1) ~= ped then
        if brakeLights then
          TriggerServerEvent('rbl:setBrakeLights', vehicleNet, false)
        end
        return
      end

      if vehicle == 0 or not DoesEntityExist(vehicle) then return end

      local speed = GetEntitySpeed(vehicle) * MPH_PER_MS
      if speed <= threshold and not IsControlPressed(0, 32) then
        if not brakeLights then
          brakeLights = true
          TriggerServerEvent('rbl:setBrakeLights', vehicleNet, true)
          if Config.enableParkEffect and (Config.parkTimerMax >= Config.parkTimerMin) then
            parkTimer()
          end
        end
      else
        if brakeLights then
          brakeLights = false
          TriggerServerEvent('rbl:setBrakeLights', vehicleNet, false)
        end
        if entity.state.rbl_blackout == 0 then
          TriggerServerEvent('rbl:setBlackout', vehicleNet, 1)
        end
        if entity.state.rbl_parked then
          TriggerServerEvent('rbl:setParked', vehicleNet, false)
        end
      end
      Wait(250)
    end
  end)
end

AddEventHandler('gameEventTriggered', function(event, args)
  if event == "CEventNetworkPlayerEnteredVehicle" then
    if args[1] ~= PlayerId() then return end
    if GetPedInVehicleSeat(args[2], -1) ~= PlayerPedId() then return end

    local vehicle = args[2]
    onEnteredVehicle(vehicle)
  end
end)

local function setBlackout(vehicle, newState)
  if vehicle == 0 or not DoesEntityExist(vehicle) then return end
  if newState == 0 then
    SetVehicleLights(vehicle, 1)
  elseif newState == 1 then
    SetVehicleLights(vehicle, 0)
  end
end

if Config.blackoutCommand ~= nil and Config.blackoutCommand ~= "" then
  RegisterCommand(Config.blackoutCommand, function()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    local entity = Entity(vehicle)
    local blackout = entity.state.rbl_blackout
    print("Blackout current: " .. tostring(blackout))
    local newState
      if blackout == 0 then
      newState = 1
    elseif blackout == 1 or blackout == nil then
      newState = 0
    end
    TriggerServerEvent("rbl:setBlackout", VehToNet(GetVehiclePedIsIn(PlayerPedId())), newState)
    TriggerServerEvent("ulc:setBlackout", VehToNet(GetVehiclePedIsIn(PlayerPedId())), newState)
  end)
end

AddStateBagChangeHandler('rbl_blackout', nil, function(bagName, key, value)
  Wait(0)
  local vehicle = GetEntityFromStateBagName(bagName)
  if vehicle == 0 then return end

  if vehicles[vehicle] then
    vehicles[vehicle].blackout = value
  end

  setBlackout(vehicle, value)
end)

AddStateBagChangeHandler('rbl_parked', nil, function(bagName, key, value)
  Wait(0)
  local vehicle = GetEntityFromStateBagName(bagName)
  if vehicle == 0 then return end

  if vehicles[vehicle] then
    vehicles[vehicle].parked = value
  end
end)

local function setIndicator(vehicle, state)
  if vehicle == 0 or not DoesEntityExist(vehicle) then return end
  if state == 2 then
    SetVehicleIndicatorLights(vehicle, 0, true)
    SetVehicleIndicatorLights(vehicle, 1, false)
  elseif state == 1 then  -- KEKW flipped
    SetVehicleIndicatorLights(vehicle, 0, false)
    SetVehicleIndicatorLights(vehicle, 1, true)
  elseif state == 3 then
    SetVehicleIndicatorLights(vehicle, 0, true)
    SetVehicleIndicatorLights(vehicle, 1, true)
  else
    SetVehicleIndicatorLights(vehicle, 0, false)
    SetVehicleIndicatorLights(vehicle, 1, false)
  end
end

AddStateBagChangeHandler('rbl_indicator', nil, function(bagName, key, value)
  Wait(0)
  local vehicle = GetEntityFromStateBagName(bagName)
  if vehicle == 0 then return end

  if vehicles[vehicle] then
    vehicles[vehicle].indicator = value or 0
  end

  setIndicator(vehicle, value or 0)
end)

if Config.enableSignals then
  local function toggleIndicator(type)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped then return end

    local entity = Entity(vehicle)
    local current = entity.state.rbl_indicator or 0
    local newState = 0

    if type == 'left' then
      newState = (current == 1) and 0 or 1
    elseif type == 'right' then
      newState = (current == 2) and 0 or 2
    elseif type == 'hazard' then
      newState = (current == 3) and 0 or 3
    end

    TriggerServerEvent('rbl:setIndicator', VehToNet(vehicle), newState)
  end

  RegisterCommand('rbl_left', function() toggleIndicator('left') end, false)
  RegisterKeyMapping('rbl_left', 'Vehicle Left Turn Signal', 'keyboard', Config.leftSignalKey)

  RegisterCommand('rbl_right', function() toggleIndicator('right') end, false)
  RegisterKeyMapping('rbl_right', 'Vehicle Right Turn Signal', 'keyboard', Config.rightSignalKey)

  RegisterCommand('rbl_hazard', function() toggleIndicator('hazard') end, false)
  RegisterKeyMapping('rbl_hazard', 'Vehicle Hazard Lights', 'keyboard', Config.hazardSignalKey)
end

local ped = PlayerPedId()
local vehicle = GetVehiclePedIsIn(ped, false)
if vehicle ~= 0 then
  TriggerServerEvent("rbl:setBrakeLights", VehToNet(vehicle), false)
  Wait(0)
  onEnteredVehicle(vehicle)
end


AddEventHandler('onResourceStop', function(resourceName)
  if resourceName ~= GetCurrentResourceName() then return end

  local pedNow = PlayerPedId()
  local vehNow = GetVehiclePedIsIn(pedNow, false)
  if vehNow == 0 or not DoesEntityExist(vehNow) then return end
  if GetPedInVehicleSeat(vehNow, -1) ~= pedNow then return end

  local netId = VehToNet(vehNow)
  if netId == 0 then return end

  TriggerServerEvent('rbl:setBrakeLights', netId, false)
  TriggerServerEvent('rbl:setParked', netId, true)
  TriggerServerEvent('rbl:setIndicator', netId, 0)
end)
