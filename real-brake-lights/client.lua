-- brake lights will turn on below this speed in MPH
local threshold = 3
local vehicle
local netVehicles = {}
local speed = 0
local stopped = false

CreateThread(function()
	local sleep = 1000
    while true do Wait(sleep)
		if not vehicle then sleep = 1000 goto continue end
        sleep = 0

        if stopped then
            SetVehicleBrakeLights(vehicle, true)
        end

        ::continue::
    end
end)

CreateThread(function()
    while true do
        vehicle = GetVehiclePedIsIn(PlayerPedId())
        if not vehicle then goto continue end

        speed = GetEntitySpeed(vehicle) * 2.236936
        if speed <= threshold then
            if not stopped then TriggerServerEvent("rbl:AddVehicle", {net = VehToNet(vehicle)}) end
            stopped = true
        else
            if stopped then TriggerServerEvent("rbl:RemoveVehicle", {net = VehToNet(vehicle)}) end
            stopped = false
        end

        ::continue::
        Wait(500)
    end
end)

RegisterNetEvent('rbl:Sync', function(_netVehicles)
    netVehicles = {}
    for _, v in pairs(_netVehicles) do
        table.insert(netVehicles, NetToVeh(v.net))
    end
end)

CreateThread(function()
    while true do Wait(0)
        for _, v in pairs(netVehicles) do
            local speed = GetEntitySpeed(v) * 2.236936
            if speed <= threshold then
                SetVehicleBrakeLights(v, true)
            end
        end
    end
end)