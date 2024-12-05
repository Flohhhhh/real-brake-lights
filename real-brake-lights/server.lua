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
