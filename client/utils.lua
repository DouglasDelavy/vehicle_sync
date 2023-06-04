function AddVehicleStateBagChangeHandler(keyFilter, handler)
    local function handleStateBagChange(bagName, _key, value, _reserved, replicated)
        if replicated then return end

        local vehicle = GetEntityFromStateBagName(bagName)
        if vehicle == 0 or GetEntityType(vehicle) ~= 2 then return end

        handler(vehicle, value)
    end

    return AddStateBagChangeHandler(keyFilter, nil, handleStateBagChange)
end