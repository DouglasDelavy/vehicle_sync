Sound = {
    vehicleSounds = {}
}

function Sound:CreateVehicleSound(vehicle, soundName)
    if self.vehicleSounds[vehicle] == nil then self.vehicleSounds[vehicle] = {} end

    local vehicleSounds = self.vehicleSounds[vehicle]

    if vehicleSounds[soundName] ~= nil then return end

    local soundId = GetSoundId()

    vehicleSounds[soundName] = soundId

    PlaySoundFromEntity(soundId, soundName, vehicle, nil, false, 0)
end

function Sound:StopVehicleSound(vehicle, soundName)
    local vehicleSounds = self.vehicleSounds[vehicle]

    if vehicleSounds == nil then return end

    if vehicleSounds[soundName] == nil then return end

    local soundId = vehicleSounds[soundName]

    vehicleSounds[soundName] = nil

    StopSound(soundId)
    ReleaseSoundId(soundId)
end

function Sound:StopAllVehicleSounds(vehicle)
    local vehicleSounds = self.vehicleSounds[vehicle]

    if vehicleSounds == nil then return end

    for soundName in pairs(vehicleSounds) do
        self:StopVehicleSound(vehicle, soundName)
    end
end

function Sound:Cleanup()
    for vehicle in pairs(self.vehicleSounds) do
        if not DoesEntityExist(vehicle) then
            self:StopAllVehicleSounds(vehicle)

            self.vehicleSounds[vehicle] = nil
        end
    end
end


