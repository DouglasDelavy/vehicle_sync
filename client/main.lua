local gNextHeavySoundCleanup = 0
local gIsDrivingVehicle = false
local gCurrentDrivingVehicle = 0

local function isVehicleAllowedToPedUseSirens(ped, vehicle)
    if IsPedInAnyHeli(ped) or IsPedInAnyPlane(ped) then return false end

    local vehicleClass = GetVehicleClass(vehicle)
    if vehicleClass ~= EMERGENCY_VEHICLE_CLASS then return false end

    local vehicleDriverPed = GetPedInVehicleSeat(vehicle, -1)
    if vehicleDriverPed ~= ped then return false end

    return true
end

local function toggleVehicleSirenState()
    if not gIsDrivingVehicle or gCurrentDrivingVehicle == 0 then return end

    local currentVehicleState = Entity(gCurrentDrivingVehicle).state
    local isSirenOn = currentVehicleState.siren

    currentVehicleState:set('siren', not isSirenOn, true)
    currentVehicleState:set('sirenMode', isSirenOn and 0 or 1, true)
end

local function toggleVehicleHornState()
    if not gIsDrivingVehicle or gCurrentDrivingVehicle == 0 then return end

    local currentVehicleState = Entity(gCurrentDrivingVehicle).state
    local isHornOn = Entity(gCurrentDrivingVehicle).state.sirenHorn

    currentVehicleState:set('sirenHorn', not isHornOn, true)
end

local function cycleVehicleSirenMode()
    if not gIsDrivingVehicle or gCurrentDrivingVehicle == 0 then return end

    local currentVehicleState = Entity(gCurrentDrivingVehicle).state

    local currentSirenMode = currentVehicleState.sirenMode
    if currentSirenMode == 0 or currentSirenMode == nil then return end

    local currentVehicleModel = GetEntityModel(gCurrentDrivingVehicle)
    local vehicleSirens = VEHICLE_SIRENS[currentVehicleModel] or VEHICLE_SIRENS[`DEFAULT`]

    local newSirenMode = currentSirenMode + 1

    if newSirenMode > #vehicleSirens then
        newSirenMode = 1
    end

    currentVehicleState:set('sirenMode', newSirenMode, true)
end

local function toggleVehicleSirenSound()
    if not gIsDrivingVehicle or gCurrentDrivingVehicle == 0 then return end

    local currentVehicleState = Entity(gCurrentDrivingVehicle).state
    local isSirenOn = currentVehicleState.siren
    if not isSirenOn then return end

    local sirenMode = currentVehicleState.sirenMode

    currentVehicleState:set('sirenMode', sirenMode == 0 and 1 or 0, true)
end

local function startInsideVehicleThread()
    CreateThread(function()
        while gIsDrivingVehicle do
            local gameTimer = GetGameTimer()

            if gameTimer > gNextHeavySoundCleanup then
                gNextHeavySoundCleanup = gameTimer + HEAVY_CLEANUP_TIME_IN_MS

                Sound:Cleanup()
            end

            DisableControlAction(0, 80, true) -- INPUT_VEH_CIN_CAM
            DisableControlAction(0, 86, true) -- INPUT_VEH_HORN

            DisableControlAction(0, 81, true) -- INPUT_VEH_NEXT_RADIO
            DisableControlAction(0, 82, true) -- INPUT_VEH_PREV_RADIO

            DisableControlAction(0, 19, true) -- INPUT_CHARACTER_WHEEL
            DisableControlAction(0, 85, true) -- INPUT_VEH_RADIO_WHEEL

            Wait(0)
        end
    end)
end

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()

        if not gIsDrivingVehicle then
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)

                if (isVehicleAllowedToPedUseSirens(playerPed, vehicle)) then
                    gIsDrivingVehicle = true
                    gCurrentDrivingVehicle = vehicle

                    startInsideVehicleThread()
                end
            end
        elseif gIsDrivingVehicle then
            if not IsPedInAnyVehicle(playerPed, false) then
                gIsDrivingVehicle = false
                gCurrentDrivingVehicle = 0
            end
        end

        Wait(1000)
    end
end)

AddVehicleStateBagChangeHandler("siren", function(vehicle, isSirenOn)
    if isSirenOn then
        VehicleSiren:On(vehicle)
    else
        VehicleSiren:Off(vehicle)
    end
end)

AddVehicleStateBagChangeHandler("sirenHorn", function(vehicle, value)
    if value then
        VehicleSiren:StartHorn(vehicle)
    else
        VehicleSiren:StopHorn(vehicle)
    end
end)

AddVehicleStateBagChangeHandler("sirenMode", function(vehicle, sirenMode)
    VehicleSiren:SetMode(vehicle, sirenMode)
end)

RegisterKeyMapping("toggleVehicleSiren", "Siren Turn On/Off", "keyboard", "Q")
RegisterCommand('toggleVehicleSiren', toggleVehicleSirenState, false)

RegisterKeyMapping("toggleVehicleSirenSound", "Siren Turn On/Off Sound", "keyboard", "LMENU")
RegisterCommand('toggleVehicleSirenSound', toggleVehicleSirenSound, false)

RegisterKeyMapping("cycleVehicleSiren", "Siren Cycle", "keyboard", "R")
RegisterCommand('cycleVehicleSiren', cycleVehicleSirenMode, false)

RegisterKeyMapping('+toggleVehicleHorn', "Siren Horn On/Off", "keyboard", "E")
RegisterCommand('+toggleVehicleHorn', toggleVehicleHornState, false)
RegisterCommand('-toggleVehicleHorn', toggleVehicleHornState, false)