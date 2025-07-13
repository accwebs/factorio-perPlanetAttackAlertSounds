local main = {}

local alert_mute = require("alert_mute")
local alert_processor = require("alert_processor")
local constants = require("constants")
local custom_alert_state = require("custom_alert_state")
local gui = require("gui")
local player_state = require("player_state")

function main.on_mod_init()
    if storage.globally_disabled then
        return
    end
    if not storage.player_state then
        storage.player_state = {}
    end
    storage.globally_disabled = false
    storage.current_file_mod_state_version = constants.TARGET_MOD_STATE_VERSION
    custom_alert_state.on_mod_init()
    player_state.on_mod_init()
    gui.update_all()
    alert_mute.mute_alerts_all_players()
end

function main.on_player_created(event)
    if storage.globally_disabled then
        return
    end
    local player = game.get_player(event.player_index)
    player_state.add_tracked_player(player)
    gui.update_all()
    alert_mute.mute_alerts_specific_player(player)
end

function main.on_player_removed_from_save(event)
    player_state.remove_tracked_player(event.player_index)
end

function main.on_force_created(event)
    if storage.globally_disabled then
        return
    end
    custom_alert_state.add_tracked_force(event.force.index)
end

function main.on_force_merged(event)
    if storage.globally_disabled then
        return
    end
    custom_alert_state.remove_tracked_force(event.source_index)
end

function main.on_configuration_changed(configurationChangedData)
    if storage.globally_disabled then
        return
    end

    if storage.current_file_mod_state_version < constants.TARGET_MOD_STATE_VERSION then
        custom_alert_state.update_state_version(storage.current_file_mod_state_version)
        player_state.update_state_version(storage.current_file_mod_state_version)
        gui.update_all()
        alert_mute.update_state_version(storage.current_file_mod_state_version)
        storage.current_file_mod_state_version = constants.TARGET_MOD_STATE_VERSION
    end
end

function main.on_global_disable(originating_player --[[luaPlayer]])
    if storage.globally_disabled then
        return
    end

    if not originating_player.admin then
        originating_player.print({"disable.global-disable-you-not-admin"})
        return
    end
    originating_player.print({"disable.global-disable-starting"})

    alert_mute.on_global_disable()
    player_state.on_global_disable()
    custom_alert_state.on_global_disable()
    storage.globally_disabled = true

    for _, this_player in pairs(game.players) do
        if this_player.connected == true then
            this_player.print({"disable.global-disable-complete", this_player.name})
        end
    end
end

function main.register_events()
    script.on_init(main.on_mod_init)
    script.on_event(defines.events.on_player_created, main.on_player_created)
    script.on_event(defines.events.on_player_removed, main.on_player_removed_from_save)
    script.on_event(defines.events.on_force_created, main.on_force_created)
    script.on_event(defines.events.on_forces_merged, main.on_force_merged)
    script.on_configuration_changed(main.on_configuration_changed)
    script.on_nth_tick(constants.TICK_EVENT_CALLBACK_INTERVAL, alert_processor.tick)
    script.on_configuration_changed(main.on_configuration_changed)
    gui.register_events(main.on_global_disable)
end

return main
