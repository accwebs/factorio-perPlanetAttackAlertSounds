local custom_alert_state = {}

function custom_alert_state.on_mod_init()
    if not storage.last_scan_tick then
        storage.last_scan_tick = 0
    end
    if not storage.last_tick then
        storage.last_tick = 0
    end
    if not storage.force_info then
        storage.force_info = {}
    end
    if not storage.pending_plays then
        storage.pending_plays = {}
    end
    for _, this_force in pairs(game.forces) do
        custom_alert_state.add_tracked_force(this_force.index)
    end
end

function custom_alert_state.add_tracked_force(force_index --[[uint]])
    if not storage.force_info[force_index] then
        storage.force_info[force_index] = {
            custom_alert_status_by_type = { }
        }
        storage.force_info[force_index][defines.alert_type.entity_destroyed] = {}
    end
end

function custom_alert_state.remove_tracked_force(force_index --[[uint]])
    storage.force_info[force_index] = nil
end

function custom_alert_state.update_state_version(current_file_mod_state_version --[[uint]])
    -- constants.TARGET_MOD_STATE_VERSION has "target" version we are upgrading to
end

function custom_alert_state.on_global_disable()
    storage.last_scan_tick = nil
    storage.last_tick = nil
    storage.force_info = nil
end

function custom_alert_state.get_last_scan_tick()
    return storage.last_scan_tick
end

function custom_alert_state.set_last_scan_tick(new_value)
    storage.last_scan_tick = new_value
end

function custom_alert_state.get_last_tick()
    return storage.last_tick
end

function custom_alert_state.set_last_tick(new_value)
    storage.last_tick = new_value
end

function custom_alert_state.get_pending_plays_per_alerttype_planet()
    return storage.pending_plays
end

function custom_alert_state.clear_pending_plays(force_index,  --[[uint]]
                                                alert_type,
                                                planet_name)
    if not storage.pending_plays[alert_type] then
        storage.pending_plays[alert_type] = {}
    end
    local alert_type_record = storage.pending_plays[alert_type]
    if not alert_type_record[planet_name] then
        alert_type_record[planet_name] = {}
    end
    alert_type_record[planet_name] = {}
end

function custom_alert_state.add_pending_play(force_index,  --[[uint]]
                                             alert_type,
                                             planet_name,  --[[string]]
                                             sound_info)
    if not storage.pending_plays[alert_type] then
        storage.pending_plays[alert_type] = {}
    end
    local alert_type_record = storage.pending_plays[alert_type]
    if not alert_type_record[planet_name] then
        alert_type_record[planet_name] = {}
    end
    local planet_record = alert_type_record[planet_name]
    local to_insert = {
        force_index = force_index,
        sound_info = sound_info
    }
    table.insert(planet_record, to_insert)
end

function custom_alert_state.age_out_old_plays(current_plays_list, current_tick  --[[uint]])
    for i = #current_plays_list, 1, -1 do
        if current_plays_list[i] < current_tick then
            table.remove(current_plays_list, i)
        end
    end
end

function custom_alert_state.get_current_plays_for_force_alerttype_planet(
    force_index, --[uint]
    alert_type,
    planet_name)
    local record = storage.force_info[force_index][alert_type]
    if not record[planet_name] then
        record[planet_name] = {}
    end
    return record[planet_name]
end

return custom_alert_state
