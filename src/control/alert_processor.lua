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

function alert_processor.scan_alerts_and_play_sounds()
    local game_tick = game.tick

    local connected_player_per_force = {}
    for _, this_player in pairs(game.players) do
        if this_player.connected then
            if not connected_player_per_force[this_player.force_index] then
                connected_player_per_force[this_player.force_index] = this_player
            end
        end
    end

    for this_force_index, player_in_force in pairs(connected_player_per_force) do
        for alert_type, planet_counts in pairs(alert_processor.read_alert_counts_by_planet_by_type(player_in_force)) do
            for planet_name, alert_count in pairs(planet_counts) do
                if alert_count > 0 then
                    local sound_continuation_constants = constants.PLANET_CONTINUATION_ALERTS[planet_name]
                    if not sound_continuation_constants then
                        sound_continuation_constants = constants.DEFAULT_CONTINUATION_ALERT
                    end

                    -- may be nil/undefined for planet
                    local sound_initial_constants = constants.PLANET_INITIAL_ALERT[planet_name]
                    
                    local current_plays_list = custom_alert_state.get_current_plays_for_force_alerttype_planet(this_force_index, alert_type, planet_name)
                    custom_alert_state.age_out_old_plays(current_plays_list, game_tick)

                    local sound_constants_to_use = sound_initial_constants
                    if not sound_initial_constants or #current_plays_list > 0 then
                        sound_constants_to_use = sound_continuation_constants
                    end

                    if #current_plays_list < sound_constants_to_use.SOUND_MAX_CONCURRENT then
                        game.forces[this_force_index].play_sound({
                            path = sound_constants_to_use.SOUND_PATH,
                            position = nil,
                            volume_modifier = nil,
                            override_sound_type = 'alert'
                        })
                        table.insert(current_plays_list, game_tick + sound_constants_to_use.SOUND_TTL_TICKS)
                    end
                    custom_alert_state.clear_pending_plays(this_force_index, alert_type, planet_name)

                    if alert_count > 1 then
                        local remaining_alerts = alert_count - 1
                        if remaining_alerts > sound_continuation_constants.SOUND_MAX_CONCURRENT then
                            remaining_alerts = sound_continuation_constants.SOUND_MAX_CONCURRENT
                        end
                        local counter = 0
                        while counter < remaining_alerts do
                            custom_alert_state.add_pending_play(this_force_index, alert_type, planet_name, sound_continuation_constants)
                            counter = counter + 1
                        end
                    end
                end
            end
        end
    end

    custom_alert_state.set_last_scan_tick(game_tick)
end

function alert_processor.tick()
    local game_tick = game.tick
    local last_scan_tick = custom_alert_state.get_last_scan_tick()
    local elapsed_since_last_scan = game_tick - last_scan_tick
    
    if elapsed_since_last_scan >= constants.ALERT_SCAN_TICK_INTERVAL then
        custom_alert_state.set_last_tick(game.tick)
        alert_processor.scan_alerts_and_play_sounds()
    else
        local last_tick = custom_alert_state.get_last_tick()
        if math.random(0, constants.ALERT_SCAN_TICK_INTERVAL) < (game_tick - last_tick) then
            return
        end
        custom_alert_state.set_last_tick(game.tick)

        local pending_plays_by_alert_type_planet = custom_alert_state.get_pending_plays_per_alerttype_planet()
        for alert_type, pending_plays_by_planet in pairs(pending_plays_by_alert_type_planet) do
            for planet_name, cached_sound_list in pairs(pending_plays_by_planet) do
                if #cached_sound_list > 0 then
                    local cached_sound = cached_sound_list[1]
                    local force_index = cached_sound.force_index
                    local sound_info = cached_sound.sound_info
                    game.forces[force_index].play_sound({
                        path = sound_info.SOUND_PATH,
                        position = nil,
                        volume_modifier = nil,
                        override_sound_type = 'alert'
                    })
                    table.remove(cached_sound_list, 1)
                    
                    local current_plays_list = custom_alert_state.get_current_plays_for_force_alerttype_planet(force_index, alert_type, planet_name)
                    table.insert(current_plays_list, game_tick + sound_info.SOUND_TTL_TICKS)
                end
            end
        end
    end
end

return alert_processor
