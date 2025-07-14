local alert_processor = {}

local constants = require("constants")
local custom_alert_state = require("custom_alert_state")

function alert_processor.convert_raw_alerts_info_to_count_by_planet_info(alert_lists_by_type_by_surface)
    local last_scan_tick = custom_alert_state.get_last_scan_tick()
    result = {}
    for surface_index, alerts_by_type in pairs(alert_lists_by_type_by_surface) do
        local surface = game.get_surface(surface_index)
        if surface and surface.planet then
            -- count number of new alerts per planet per type
            local planet_name = surface.planet.name
            for alert_type, alert_list in pairs(alerts_by_type) do
                local count = 0
                for _, this_alert in pairs(alert_list) do
                    if this_alert.tick > last_scan_tick then
                        count = count + 1
                    end
                end
                if not result[alert_type] then
                    result[alert_type] = {}
                end
                if not result[alert_type][planet_name] then
                    result[alert_type][planet_name] = {}
                end
                result[alert_type][planet_name] = count
            end
        end
    end
    return result
end

--Return type:
--  map[
--    alert_type
--    :
--    map[planet_name : count]
--  ]
function alert_processor.read_alert_counts_by_planet_by_type(player --[[luaPlayer]])
    local destroyed_alerts = player.get_alerts{type=defines.alert_type.entity_destroyed}
    return alert_processor.convert_raw_alerts_info_to_count_by_planet_info(destroyed_alerts)
end

function alert_processor.scan_alerts()
    local connected_player_per_force = {}
    for _, this_player in pairs(game.players) do
        if this_player.connected then
            if not connected_player_per_force[this_player.force_index] then
                connected_player_per_force[this_player.force_index] = this_player
            end
        end
    end

    alert_counts_by_planet_by_force = {}
    for this_force_index, player_in_force in pairs(connected_player_per_force) do
        for alert_type, planet_counts in pairs(alert_processor.read_alert_counts_by_planet_by_type(player_in_force)) do
            for planet_name, alert_count in pairs(planet_counts) do
                local state_data = custom_alert_state.get_state_data_for_force_alerttype_planet(this_force_index, alert_type, planet_name)
                
            --alert_counts_by_planet_by_force[this_force_index] = 
            end
        end
    end

    custom_alert_state.set_last_scan_tick(game.tick)
end

function alert_processor.tick()
    local last_scan_tick = custom_alert_state.get_last_scan_tick()
    local elapsed_since_last_scan = game.tick - last_scan_tick
    
    if elapsed_since_last_scan >= constants.ALERT_SCAN_TICK_INTERVAL then
        alert_processor.scan_alerts()
    end

    for _, this_force in pairs(game.forces) do
        this_force.play_sound({
            path = "simcity2000-power-line",
            position = nil,
            volume_modifier = nil,
            override_sound_type = 'alert'
        })
    end

    custom_alert_state.set_last_tick(game.tick)
end

return alert_processor
