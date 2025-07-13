local player_state = {}

function player_state.on_mod_init()
    if not storage.player_state then
        storage.player_state = {}
    end
    for _, this_player in pairs(game.players) do
        player_state.add_tracked_player(this_player)
    end
end

function player_state.add_tracked_player(player --[[luaPlayer]])
    if storage.player_state[player.index] == nil then
        storage.player_state[player.index] = {
            we_muted_entity_destroyed = false
        }
    end
end

function player_state.remove_tracked_player(player_index --[[uint]])
    storage.player_state[player_index] = nil
end

function player_state.update_state_version(current_file_mod_state_version --[[uint]])
    -- constants.TARGET_MOD_STATE_VERSION has "target" version we are upgrading to
end

function player_state.on_global_disable()
    storage.player_state = nil
end

function player_state.get_player_data(player --[[luaPlayer]])
    return storage.player_state[player.index]
end

return player_state
