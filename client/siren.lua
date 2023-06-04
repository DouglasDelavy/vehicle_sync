VehicleSiren = {}

function VehicleSiren:On(vehicle)
    SetVehicleSiren(vehicle, true)
    SetVehicleHasMutedSirens(vehicle, true)
end

function VehicleSiren:Off(vehicle)
    SetVehicleSiren(vehicle, false)
    SetVehicleHasMutedSirens(vehicle, false)
end

function VehicleSiren:GetVehicleSirens(vehicle)
    local vehicleModel = GetEntityModel(vehicle)
    local vehicleSirens = VEHICLE_SIRENS[vehicleModel] or VEHICLE_SIRENS[`DEFAULT`]

    return vehicleSirens
end

function VehicleSiren:SetMode(vehicle, sirenMode)
    if sirenMode ~= 0 then
        local vehicleSirens = self:GetVehicleSirens(vehicle)

        local lastSirenModeIndex = sirenMode == 1 and #vehicleSirens or sirenMode - 1
        local lastSirenModeSoundName = vehicleSirens[lastSirenModeIndex]
        if lastSirenModeSoundName then
            Sound:StopVehicleSound(vehicle, lastSirenModeSoundName)
        end

        local newSirenModeSoundName = vehicleSirens[sirenMode]
        if newSirenModeSoundName then
            Sound:CreateVehicleSound(vehicle, newSirenModeSoundName)
        end
    else
        Sound:StopAllVehicleSounds(vehicle)
    end
end

function VehicleSiren:GetVehicleHornSoundName(vehicle)
    local vehicleModel = GetEntityModel(vehicle)

    return VEHICLE_HORNS[vehicleModel] or VEHICLE_HORNS[`DEFAULT`]
end

function VehicleSiren:StartHorn(vehicle)
    local hornSoundName = self:GetVehicleHornSoundName(vehicle)

    if hornSoundName then
        Sound:CreateVehicleSound(vehicle, hornSoundName)
    end
end

function VehicleSiren:StopHorn(vehicle)
    local hornSoundName = self:GetVehicleHornSoundName(vehicle)

    if hornSoundName then
        Sound:StopVehicleSound(vehicle, hornSoundName)
    end
end