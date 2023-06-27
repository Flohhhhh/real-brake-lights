local threshold = 4 -- brake lights will turn on below this speed in MPH
local vehicles = {}
local isLoopActive = false

local function IsTableEmpty(table)
  for _ in pairs(table) do return false end
  return true
end

-- loop through list of vehicles and set brake lights
local function brakeLightLoop()
  CreateThread(function()
    -- print("Loop")
    isLoopActive = true
    while not IsTableEmpty(vehicles) do
      for vehicle, _data in pairs(vehicles) do
        local entity = Entity(vehicle)
        -- if vehicle exists, driver seat is occupied and vehicle isn't set to blackout, set brake lights
        if DoesEntityExist(vehicle) then -- if vehicle exists
          if not entity.state.rbl_blackout and not entity.state.rbl_parked then -- if not blackout or parked
            SetVehicleBrakeLights(vehicle, true)
          end
        else -- if vehicle doesn't exist, remove it from list
          vehicles[vehicle] = nil
        end
      end
      Wait(0)
    end
    isLoopActive = false
  end)
end

---------------------------
-- HANDLE OTHER VEHICLES --
---------------------------

-- whenever rbl_brakelights value changes on an entity, add or remove it from the list
AddStateBagChangeHandler('rbl_brakelights', null, function(bagName, key, value)
  Wait(0) -- Nedded as GetEntityFromStateBagName sometimes returns 0 on first frame
  local vehicle = GetEntityFromStateBagName(bagName)
  -- print("state changed for vehicle")
  if vehicle == 0 then return end
  local brakeLights = value
  if brakeLights then
    vehicles[vehicle] = true
    -- start loop if not already running
    if not isLoopActive then
     brakeLightLoop()
    end
  else
    vehicles[vehicle] = nil
  end
end)

-----------------
-- PARK EFFECT --
-----------------

local function parkTimer()
  local time = math.random(20000, 60000)
  local expiration = GetGameTimer() + time
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  -- local entity = Entity(vehicle)

  CreateThread(function()
    while true do
      if GetGameTimer() > expiration then
        local speed = GetEntitySpeed(vehicle) * 2.236936 -- get speed in MPH
        if speed < 1 then
          -- print("Setting park state to true")
          TriggerServerEvent("rbl:setParkState", VehToNet(vehicle), true)
          return
        else
          return
        end
      end
      Wait(500)
    end
  end)
end

-----------------------
-- HANDLE MY VEHICLE --
-----------------------

-- when i enter a vehicle, start a loop to check if i'm driving and if so, check speed and set brake lights
local function onEnteredVehicle(_vehicle)
  -- print("onEnteredVehicle")
  CreateThread(function()
    local ped = PlayerPedId()
    local vehicle = _vehicle
    local entity = Entity(vehicle)
    local brakeLights = false

    while true do
      -- if i'm not in the vehicle turn off its brake lights and return
      if GetVehiclePedIsIn(ped, false) ~= vehicle then
        TriggerServerEvent("rbl:setParked", VehToNet(vehicle), true)
        return
      end

      local speed = GetEntitySpeed(vehicle) * 2.236936 -- get speed in MPH
      if speed <= threshold then -- if stopped
        if not brakeLights then -- if brake lights are not already on, turn them on and start a timer for park state
          -- print("Enabling for my vehicle")
          brakeLights = true
          TriggerServerEvent('rbl:setBrakeLights', VehToNet(vehicle), true)
          parkTimer()
        end
      else -- if moving
        if brakeLights then
          -- print("Disabling for my vehicle")
          brakeLights = false
          TriggerServerEvent('rbl:setBrakeLights', VehToNet(vehicle), false)
        end
        if entity.state.rbl_blackout then
          TriggerServerEvent('rbl:setBlackout', VehToNet(vehicle), false)
        end
        if entity.state.rbl_parked then
          TriggerServerEvent('rbl:setParked', VehToNet(vehicle), false)
        end
      end

      Wait(250)
    end
  end)
end

AddEventHandler('gameEventTriggered', function(event, args)
  if event == "CEventNetworkPlayerEnteredVehicle" then
    if args[1] ~= PlayerId() then return end -- if it was not me return
    if GetPedInVehicleSeat(args[2], -1) ~= PlayerPedId() then return end -- if i'm not driver return

    local vehicle = args[2]
    onEnteredVehicle(vehicle)
  end
end)

----------------------
-- BLACKOUT COMMAND --
----------------------

RegisterCommand("blackout", function()
  local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
  local entity = Entity(vehicle)
  local blackout = entity.state.rbl_blackout
  -- print("Setting blackout to: " .. tostring(not blackout))
  TriggerServerEvent("rbl:setBlackout", VehToNet(GetVehiclePedIsIn(PlayerPedId())), not blackout)
end)



------------
-- EXTRAS --
------------

-- check my vehicle if i'm already in one when script starts
local ped = PlayerPedId()
local vehicle = GetVehiclePedIsIn(ped, false)
if vehicle then
  TriggerServerEvent("rbl:setBrakeLights", VehToNet(vehicle), false)
  Wait(0)
  onEnteredVehicle(vehicle)
end

