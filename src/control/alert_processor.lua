local alert_processor = {}

local constants = require("constants")
local custom_alert_state = require("custom_alert_state")

local function play_alert(force_index, --[[uint]]
                          sound_info --[[table]])
    game.forces[force_index].play_sound({
        path = sound_info.SOUND_PATH,
        position = nil,
        volume_modifier = nil,
        override_sound_type = 'alert'
    })
end

local function handle_new_destroyed_entity(force_index --[[uint]], planet_name --[[string]], died_tick --[[uint]])
    local current_tick = game.tick

    if died_tick > current_tick + constants.MAX_EVENT_CALLBACK_DELAY_BEFORE_IGNORE then
        return
    end
    
    local state_data = custom_alert_state.get_force_data(force_index, planet_name)
    local current_plays = state_data.current_plays
    local pending_plays = state_data.pending_plays
    custom_alert_state.age_out_old_current_plays(current_plays, current_tick)

    local sound_continuation_constants = constants.PLANET_CONTINUATION_ALERTS[planet_name]
    if not sound_continuation_constants then
        sound_continuation_constants = constants.DEFAULT_CONTINUATION_ALERT
    end

    if state_data.new_play_since_tick == true or #pending_plays > 0 then
        if (#current_plays + #pending_plays) < sound_continuation_constants.SOUND_MAX_CONCURRENT*2 then
            local to_insert = {
                tick = current_tick,
                sound_info = sound_continuation_constants
            }
            table.insert(pending_plays, to_insert)
        end
    else
        state_data.new_play_since_tick = true

        -- may be nil/undefined for planet
        local sound_initial_constants = constants.PLANET_INITIAL_ALERT[planet_name]
        if sound_initial_constants and #current_plays == 0 and #pending_plays == 0 then
            play_alert(force_index, sound_initial_constants)
            table.insert(current_plays, current_tick + sound_initial_constants.SOUND_TTL_TICKS)
        end

        if #current_plays < sound_continuation_constants.SOUND_MAX_CONCURRENT then
            play_alert(force_index, sound_continuation_constants)
            table.insert(current_plays, current_tick + sound_continuation_constants.SOUND_TTL_TICKS)
        end
    end
end

function alert_processor.tick()
    if storage.globally_disabled then
        return
    end

    local current_tick = game.tick
    local last_tick = custom_alert_state.get_last_tick()
    custom_alert_state.set_last_tick(game.tick)

    -- add a bit of randomness to 'gaps' between repeating sounds
    if math.random(0, constants.TICK_EVENT_CALLBACK_INTERVAL)*2 < (current_tick - last_tick) then
        return
    end
   
    local state_data_for_all_forces_planets = custom_alert_state.get_state_data_for_all_forces_planets()
    for force_index, state_by_planet in pairs(state_data_for_all_forces_planets) do
        for planet_name, state_data in pairs(state_by_planet) do
            state_data.new_play_since_tick = false
            local pending_plays = state_data.pending_plays
            local current_plays_list = nil
            while true do
                if #pending_plays == 0 then
                    break
                end
                local this_pending_play = pending_plays[1]
                table.remove(pending_plays, 1)

                local source_tick = this_pending_play.tick
                local sound_info = this_pending_play.sound_info
 
                if source_tick + constants.MAX_PENDING_PLAY_AGE > current_tick then
                    if not current_plays_list then
                        current_plays_list = state_data.current_plays
                        custom_alert_state.age_out_old_current_plays(current_plays_list, current_tick)
                    end
                    play_alert(force_index, sound_info)
                    table.insert(current_plays_list, current_tick + sound_info.SOUND_TTL_TICKS)
                    break
                end
            end
        end
    end
end

function alert_processor.on_entity_died(event --[[table]])
    local entity = event.entity
    local force_index = entity.force_index
    local planet = entity.surface.planet
    if #game.forces[force_index].players == 0 then
        return
    end
    if planet then
        handle_new_destroyed_entity(force_index, planet.name, event.tick)
    else
        handle_new_destroyed_entity(force_index, "not-a-planet", event.tick)
    end
end

return alert_processor
