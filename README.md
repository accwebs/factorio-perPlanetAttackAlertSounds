# factorio-perPlanetAttackAlertSounds

Source repository for the Factorio mod "Per-Planet Attack Alert Sounds".

## Summary

Per-Planet Attack Alert Sounds is a mod for the video game [Factorio](https://factorio.com/). It is a silly, (largely) for-personal-use mod, that adds per-planet 'entity destroyed' alert sounds to reduce the constant toil of the player having to check the alert location each time the alert sound goes off.

Per-Planet Attack Alert Sounds on the Factorio mod portal: https://mods.factorio.com/mod/PerPlanetAttackAlertSounds

**WARNING: ALPHA status; crashes and bugs are likely!**

Nauvis continues to use the default alert sound; the mod tries to mimick default Nauvis sound behavior. Custom sounds are applied to Gleba, Vulcanus, and Fulgora. The custom sounds might be familiar to some gamers ;-)

**CAUTION: This mod makes some permanent force changes to games loaded with the mod active (to silence the default alert so that the custom logic can take over). Factorio does not auto-revert if you later disable the mod; you must first tell mod to undo the changes. Read the instructions below.**

## Usage Instructions

1. Install & enable the mod. It will automatically disable the default alert sounds and replace the alerts with the mod's custom behavior. 

## Considerations

1. Once you save your game with this mod active, it's not advisable to disable the mod on that save file moving forward because your file will have the default 'entity destroyed' sound effects permanently disabled.
2. There is a UI button that allows you to clean up alternative forces on an existing save file. The mod is then put into a zombie state.
    * Button is hidden by default.  Use Settings -> Mod Settings -> Map to display it.
    * If you regret your decision to permanently clean up the mod state on a file, you *CAN* re-enable the mod by globally disabling the mod, loading your file, saving your file (so that the saved game now has no record of the mod at all) and then re-enabling the mod.  Upon re-loading your file, the mod will re-initialize itself from scratch again.
