-- brake lights will turn on below this speed in MPH
local threshold = 3

CreateThread(function()
    while true do Wait(0)
        local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        if not vehicle then goto continue end

        local speed = GetEntitySpeed(vehicle) * 2.236936
        if speed <= threshold then
            SetVehicleBrakeLights(vehicle, true)
        end

        ::continue::
    end
end)
