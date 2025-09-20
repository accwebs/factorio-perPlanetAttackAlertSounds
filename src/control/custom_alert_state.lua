local custom_alert_state = {}

function custom_alert_state.on_mod_init()
    if not storage.last_tick then
        storage.last_tick = 0
    end
    if not storage.force_info then
        storage.force_info = {}
    end
    for _, this_force in pairs(game.forces) do
        custom_alert_state.add_tracked_force(this_force.index)
    end
end

function custom_alert_state.add_tracked_force(force_index --[[uint]])
    if not storage.force_info[force_index] then
        storage.force_info[force_index] = {}
    end
end

function custom_alert_state.remove_tracked_force(force_index --[[uint]])
    storage.force_info[force_index] = nil
end

function custom_alert_state.update_state_version(current_file_mod_state_version --[[uint]])
    -- constants.TARGET_MOD_STATE_VERSION has "target" version we are upgrading to
end

function custom_alert_state.on_global_disable()
    storage.last_tick = nil
    storage.force_info = nil
end

function custom_alert_state.get_last_tick()
    return storage.last_tick
end

function custom_alert_state.set_last_tick(new_value --[[uint]])
    storage.last_tick = new_value
end

function custom_alert_state.get_state_data_for_all_forces_planets()
    return storage.force_info
end

function custom_alert_state.get_force_data(force_index --[[uint]], planet_name --[[string]])
    local record = storage.force_info[force_index]
    if not record[planet_name] then
        record[planet_name] = {
            current_plays = {},
            new_play_since_tick = false,
            pending_plays = {}
        }
    end
    return record[planet_name]
end

function custom_alert_state.age_out_old_current_plays(current_plays_list --[[table]], current_tick --[[uint]])
    for i = #current_plays_list, 1, -1 do
        if current_plays_list[i] < current_tick then
            table.remove(current_plays_list, i)
        end
    end
end

return custom_alert_state
