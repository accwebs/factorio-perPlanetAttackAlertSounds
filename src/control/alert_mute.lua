local alert_mute = {}

local player_state = require("player_state")

function alert_mute.mute_alerts_specific_player(player --[[luaPlayer]])
    local player_state_data = player_state.get_player_data(player)
    player_state_data["we_muted_entity_destroyed"] = player.mute_alert(defines.alert_type.entity_destroyed)
end

function alert_mute.mute_alerts_all_players()
    for _, this_player in pairs(game.players) do
        alert_mute.mute_alerts_specific_player(this_player)
    end
end

function alert_mute.update_state_version(current_file_mod_state_version --[[uint]])
    -- constants.TARGET_MOD_STATE_VERSION has "target" version we are upgrading to
end

function alert_mute.on_global_disable()
    for _, this_player in pairs(game.players) do
        local player_state_data = player_state.get_player_data(this_player)
        if player_state_data["we_muted_entity_destroyed"] then
            this_player.unmute_alert(defines.alert_type.entity_destroyed)
            player_state_data["we_muted_entity_destroyed"] = false
        end
    end
end

return alert_mute
