local vehicles = {}

RegisterNetEvent("rbl:AddVehicle", function(vehicle)
	--print("Adding vehicle: " .. json.encode(vehicle))
	local isAlready = false
	for _, v in pairs(vehicles) do
		if v.net == vehicle.net then
			isAlready = true
		end
	end
	if not isAlready then
		table.insert(vehicles, {net = vehicle.net, entity = NetworkGetEntityFromNetworkId(vehicle.net)})
	end
end)

RegisterNetEvent('rbl:RemoveVehicle', function(vehicle)
    for k, v in pairs(vehicles) do
        if v.net == vehicle.net then
            --print("Removing vehicle: " .. json.encode(v))
            table.remove(vehicles, k)
        end
    end
end)

CreateThread(function()
    while true do Wait(1000)
        TriggerClientEvent("rbl:Sync", -1, vehicles)
        --print(#vehicles)
    end
end)

CreateThread(function()
    while true do Wait(5000)
        for k, v in pairs(vehicles) do
            if not DoesEntityExist(v.entity) then
            --print("Removing: " .. json.encode(v))
                table.remove(vehicles, k)
            end
        end
    end
end)
