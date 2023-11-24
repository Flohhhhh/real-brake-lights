-- client tells server if their vehicle should have brake lights
RegisterNetEvent("rbl:setBrakeLights")
AddEventHandler("rbl:setBrakeLights", function(netId, state)
    -- print("[RBL] setBrakeLights")
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    Entity(vehicle).state.rbl_brakelights = state
end)

RegisterNetEvent("rbl:setBlackout")
AddEventHandler('rbl:setBlackout', function(netid, state)
  print("[RBL] Setting blackout " .. tostring(state))
  local vehicle = NetworkGetEntityFromNetworkId(netid)
  Entity(vehicle).state.rbl_blackout = state
end)

RegisterNetEvent("rbl:setParked")
AddEventHandler("rbl:setParked", function(netId, state)
  -- print("[RBL] setParked")
  local vehicle = NetworkGetEntityFromNetworkId(netId)
  Entity(vehicle).state.rbl_parked = state
end)

--[[

options
# option 1
- have another state on vehicle for whether it's in parked state
- set parked state after x time with randomness
- when in parked state, set brake lights to false
- getting out of vehicle sets parked state to true
  - this could possible ovverride the current system for disabling when there is no driver
  - or maybe old method can be adapted to trigger this?

# option 2
- 
]]