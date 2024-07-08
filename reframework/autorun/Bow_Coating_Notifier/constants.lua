--- Constants to be used throughout the application.
local constants <const> = {
    -- The name of the mod.
    mod_name = "Bow Coating Notifier",

    -- The directory path for the mod.
    directory_path = "Bow_Coating_Notifier",

    -- The default fonts directory path for REFramework
    fonts_path = "fonts",

    -- The standard options to use within a color picker without alpha.
    color_picker_options = 1 << 1 --[[ No Alpha ]]
        | 1 << 3 --[[ No Options ]]
        | 1 << 20 --[[ Display RGB Value Fields ]]
        | 1 << 22, --[[ Display Hex Value Field ]]

    -- The standard options to use within a color picker with alpha.
    color_picker_options_with_alpha = 1 << 3  --[[ No Options ]]
        | 1 << 16 --[[ Display Alpha Bar ]]
        | 1 << 18 --[[ Display Alpha Current Preview ]]
        | 1 << 20 --[[ Display RGB Value Fields ]]
        | 1 << 22, --[[ Display Hex Value Field ]]

    --[[ For reference: https://github.com/praydog/REFramework/blob/master/dependencies/imguizmo/example/imgui.h#L1536 ]]

    -- The dropdown options for the warning activation condition.
    warning_activation_option = {
        -- The number of shots remaining option.
        number = 1,

        -- The percentage of shots remaining option.
        percentage = 2
    },

    -- The names for types within the game.
    type_name = {
        -- The Player Manager type name.
        player_manager = "snow.player.PlayerManager"
    },

    -- The enum that defines the available player weapon types.
    player_weapon_type = sdk.enum_to_table("snow.player.PlayerWeaponType"),

    -- The enum that defines the available coating types.
    coating_type = sdk.enum_to_table("snow.data.weapon.BottleTypes")
}

-- The language directory path that contains all of the language files.
constants.language_directory_path = constants.directory_path .. "\\languages\\";

return constants;