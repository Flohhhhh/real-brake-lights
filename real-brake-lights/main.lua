-- brake lights will turn on below this speed in MPH
local threshold = 3
local vehicle

CreateThread(function()
	local sleep = 1000
    while true do Wait(sleep)
		if not IsPedInAnyVehicle(PlayerPedId()) then sleep = 1000 goto continue end
		sleep = 0
        vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
       

        local speed = GetEntitySpeed(vehicle) * 2.236936
        if speed <= threshold then
            SetVehicleBrakeLights(vehicle, true)
        end

        ::continue::
    end
end)
