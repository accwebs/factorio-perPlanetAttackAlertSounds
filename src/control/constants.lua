local constants = {}

-- constants.PROFILING_ENABLED = false
constants.TARGET_MOD_STATE_VERSION = 1
constants.TICK_EVENT_CALLBACK_INTERVAL = 15
constants.MAX_PENDING_PLAY_AGE = 60
constants.MAX_EVENT_CALLBACK_DELAY_BEFORE_IGNORE = 40

constants.PLANET_INITIAL_ALERT = {
    gleba = {
        SOUND_PATH='aoe2_under_attack',
        SOUND_TTL_TICKS=360,
        SOUND_MAX_CONCURRENT=1  -- ignored for "initial" sounds
    },
    vulcanus = {
        SOUND_PATH='ee_fanfare',
        SOUND_TTL_TICKS=360,
        SOUND_MAX_CONCURRENT=1  -- ignored for "initial" sounds
    }
}
constants.DEFAULT_CONTINUATION_ALERT = {
    SOUND_PATH='utility/alert_destroyed',
    SOUND_TTL_TICKS=120,
    SOUND_MAX_CONCURRENT=8
}
constants.PLANET_CONTINUATION_ALERTS = {
    fulgora = {
        SOUND_PATH='simcity2000_power_line',
        SOUND_TTL_TICKS=120,
        SOUND_MAX_CONCURRENT=8
    },
    gleba = {
        SOUND_PATH='ee_citizen_death',
        SOUND_TTL_TICKS=120,
        SOUND_MAX_CONCURRENT=8
    },
    vulcanus = {
        SOUND_PATH='dontstarve_deerclops_iceattack',
        SOUND_TTL_TICKS=120,
        SOUND_MAX_CONCURRENT=8
    }
}

return constants
