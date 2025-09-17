local constants = {}

constants.PROFILING_ENABLED = false
constants.TARGET_MOD_STATE_VERSION = 1
constants.TICK_EVENT_CALLBACK_INTERVAL = 10
constants.ALERT_SCAN_TICK_INTERVAL = 50

constants.PLANET_INITIAL_ALERT = {
    gleba = {
        SOUND_PATH='aoe2_under_attack',
        SOUND_TTL_TICKS=300,
        SOUND_MAX_CONCURRENT=1
    },
    vulcanus = {
        SOUND_PATH='ee_fanfare',
        SOUND_TTL_TICKS=300,
        SOUND_MAX_CONCURRENT=1
    }
}
constants.DEFAULT_CONTINUATION_ALERT = {
    SOUND_PATH='utility/alert_destroyed',
    SOUND_TTL_TICKS=120,
    SOUND_MAX_CONCURRENT=4
}
constants.PLANET_CONTINUATION_ALERTS = {
    fulgora = {
        SOUND_PATH='simcity2000_power_line',
        SOUND_TTL_TICKS=60,
        SOUND_MAX_CONCURRENT=4
    },
    gleba = {
        SOUND_PATH='ee_citizen_death',
        SOUND_TTL_TICKS=120,
        SOUND_MAX_CONCURRENT=5
    },
    vulcanus = {
        SOUND_PATH='dontstarve_deerclops_iceattack',
        SOUND_TTL_TICKS=120,
        SOUND_MAX_CONCURRENT=5
    }
}

return constants
