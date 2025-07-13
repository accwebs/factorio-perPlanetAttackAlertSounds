local gui = {}

local mod_gui = require("mod-gui")

gui.GLOBAL_DISABLE_BUTTON_NAME = "perPlanetAttackAlertSoundGlobalDisableButton"

function gui.on_global_disable_button_click(event)
    if storage.globally_disabled then
        return
    end
    if event.element.name == gui.GLOBAL_DISABLE_BUTTON_NAME then
        local player = game.get_player(event.player_index)
        gui.perform_global_disable(player)
    end
end

function gui.on_mod_setting_changed(event)
    if storage.globally_disabled then
        return
    end
    gui.update_all()
end

function gui.update_all()
    local show_global_disable_button = settings.global["per-planet-attack-alert-sounds-show-global-disable-button"].value

    for _, player in pairs(game.players) do
        local mod_gui_container = mod_gui.get_frame_flow(player)
        if show_global_disable_button then
            local exists = false
            for _, child in pairs(mod_gui_container.children) do
                if child.name == gui.GLOBAL_DISABLE_BUTTON_NAME then
                    exists = true
                end
            end
            if exists == false then
                mod_gui_container.add({
                    type = "button",
                    name = gui.GLOBAL_DISABLE_BUTTON_NAME,
                    caption={"disable.global-disable-button-text"},
                    tooltip={"disable.global-disable-button-tooltip"}
                })
            end
        else
            for _, child in pairs(mod_gui_container.children) do
                if child.name == gui.GLOBAL_DISABLE_BUTTON_NAME then
                    child.destroy()
                end
            end
        end
    end
end

function gui.register_events(perform_global_disable)
    script.on_event(defines.events.on_gui_click, gui.on_global_disable_button_click)  -- global 'clean up mod' button click
    script.on_event(defines.events.on_runtime_mod_setting_changed, gui.on_mod_setting_changed)  -- so we can show/hide the global 'clean up' button
    gui.perform_global_disable = perform_global_disable
end

return gui
