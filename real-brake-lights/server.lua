-- client tells server if their vehicle should have brake lights
RegisterNetEvent("rbl:setBrakeLights")
AddEventHandler("rbl:setBrakeLights", function(netId, state)
    -- print("rbl:setBrakeLights")
    local vehicle = NetworkGetEntityFromNetworkId(netId)
    Entity(vehicle).state.rbl_brakelights = state
end)

RegisterNetEvent("rbl:setBlackout")
AddEventHandler('rbl:setBlackout', function(netid, state)
  -- print("Setting blackout")
  local vehicle = NetworkGetEntityFromNetworkId(netid)
  Entity(vehicle).state.rbl_blackout = state
end)