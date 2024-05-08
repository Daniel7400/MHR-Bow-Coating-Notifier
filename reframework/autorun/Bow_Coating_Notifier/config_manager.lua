-- IMPORTS
local constants = require("Bow_Coating_Notifier.constants");
local green_comfy_tea_utils = require("Bow_Coating_Notifier.green_comfy_tea_utils");
-- END IMPORTS

--- The manager for all things related to the configuration file.
local config_manager = {
    -- The configs that are being managed.
    config = {
        -- The current config, which is what is saved/loaded and determines the state of the mod.
        current = nil,

        -- The default config, used is the basis of the config and used as the validation schema when loading config data.
        default = {
            -- The flag used to determine if the mod is enabled or not.
            enabled = true,

            -- The config options that control the display settings.
            display = {
                -- The option that controls the outline color of the notification box.
                box_outline_color = 0xFFFF0000,

                -- The option that controls the background color of the notification box.
                box_background_color = 0x77000000,

                -- The option that controls the color of the text within the notification box.
                text_color = 0xFFFFFFFF,

                -- The option that controls the font size of the text within the notification box.
                font_size = 35,

                -- The option that controls whether the notification should only appear while the player is aiming their bow.
                only_show_while_aiming = true,

                -- The option that controls the adjustment to the x position at which the notification box is drawn on the screen.
                x_position_adjust = 0,

                -- The option that controls the adjustment to the y position at which the notification box is drawn on the screen.
                y_position_adjust = 0
            },

            -- The selected language option.
            language = "default (en-us)",

            -- The config options that control the warning settings.
            warning = {
                -- The option that determines whether warnings are enabled or not.
                enabled = true,

                -- The option that controls which condition to check when trying to determine when a warning should display.
                mode = constants.warning_activation_option.number,

                -- The option that controls the value that is checked against the mode to determine when a warning should display.
                amount = 3,

                -- The option that controls the outline color of the warning notification box.
                box_outline_color = 0xFFFFCC00,

                -- The option that controls the background color of the warning notification box.
                box_background_color = 0x77000000,

                -- The option that controls the color of the text within the warning notification box.
                text_color = 0xFFFFFFFF
            }
        },
    }
};

-- The name and path of the config file that stores the settings of the user.
local file_name = constants.directory_path .. "/config.json";

---
--- Attempts to load the configuration data from the config file. If the file fails to load it will use the defaults instead.
---
function config_manager.load()
    -- Attempt to load the json config file.
    local loaded_config = json.load_file(file_name);

    -- Check if the config file failed to load.
    if not loaded_config then
        -- If yes, then log that the config file failed to load.
        log.error(string.format("[%s] - Failed to load config file, switching to default.", constants.mod_name));

        -- Set the current config as a deep copy of the default config.
        config_manager.config.current = green_comfy_tea_utils.table.deep_copy(config_manager.config.default);
    else -- Else, the config file was loaded without issue.
        -- Set the current config as the merge of the default config and loaded config (to verify the schema, and force
        -- it to match the default config structure, any other values will be ignored).
        config_manager.config.current = green_comfy_tea_utils.table.merge(config_manager.config.default, loaded_config);
    end
end

---
--- Attempts to save the configuration data from the config file to disk.
---
function config_manager.save()
    -- Attempt to save the json config file.
    local saved = json.dump_file(file_name, config_manager.config.current);

    -- Check if the saved flag is set as true.
    if saved then
        -- If yes, then the file was saved successfully and it will be logged as doing so.
        log.info(string.format("[%s] - Config file saved successfully.", constants.mod_name));
    else -- Else, the config file failed to be saved.
        -- Log that the config file failed to save.
        log.error(string.format("[%s] - Failed to save config file.", constants.mod_name));
    end
end

---
--- Reset the current config values back to the default values.
---
function config_manager.reset()
    config_manager.config.current = green_comfy_tea_utils.table.deep_copy(config_manager.config.default);
end

---
--- Initializes the config manager module.
---
function config_manager.init_module()
    -- Load the config.
    config_manager.load();
end

return config_manager;