RegisterNetEvent("rbl:setBrakeLights")
AddEventHandler("rbl:setBrakeLights", function(netId, state)
    local vehicle = NetworkGetEntityFromNetworkId(netId)
  if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    Entity(vehicle).state.rbl_brakelights = state
end)

RegisterNetEvent("rbl:setBlackout")
AddEventHandler('rbl:setBlackout', function(netid, state)
  print("[RBL] Setting blackout " .. tostring(state))
  local vehicle = NetworkGetEntityFromNetworkId(netid)
  if vehicle == 0 or not DoesEntityExist(vehicle) then return end
  Entity(vehicle).state.rbl_blackout = state
end)

RegisterNetEvent("rbl:setParked")
AddEventHandler("rbl:setParked", function(netId, state)
  local vehicle = NetworkGetEntityFromNetworkId(netId)
  if vehicle == 0 or not DoesEntityExist(vehicle) then return end
  Entity(vehicle).state.rbl_parked = state
end)
