--- IMPORTS
local config_manager = require("Bow_Coating_Notifier.config_manager");
local constants = require("Bow_Coating_Notifier.constants");
local draw_manager = require("Bow_Coating_Notifier.draw_manager");
local language_manager = require("Bow_Coating_Notifier.language_manager");
local green_comfy_tea_utils = require("Bow_Coating_Notifier.green_comfy_tea_utils");
--- END IMPORTS

--- The manager for the REFramework UI section of the mod.
local ui_manager = {
    -- The loaded fonts to hot swap between when certain languages require a new font to display properly.
    fonts = {},

    -- The language strings used in the the dropdown options for the warning activation condition.
    warning_activation_options = {}
};

-- The font size used in the REFramework UI.
local ui_font_size <const> = 18;

---
--- Checks whether the font on the current language is NOT already loaded in the fonts collection. If it is
--- not, then the font will be loaded via imgui and added into the fonts collection.
---
function ui_manager.load_font_if_missing()
    -- Check if the font assigned to the current language does NOT already have an entry in the fonts table.
    if not ui_manager.fonts[language_manager.language.current.font] then
        -- If yes, then load the font associated with the current language font name and store it in the fonts table.
        ui_manager.fonts[language_manager.language.current.font] =
            imgui.load_font(language_manager.language.current.font, ui_font_size, language_manager.unicode_glyph_ranges);
    end
end

---
--- Initializes the ui manager module.
---
function ui_manager.init_module()
    -- Load the font associated with default language and store it in the fonts table.
    ui_manager.fonts[language_manager.language.default.font] =
        imgui.load_font(language_manager.language.default.font, ui_font_size, language_manager.unicode_glyph_ranges);

    -- Load the font on the current language if its not already loaded.
    ui_manager.load_font_if_missing();

    -- Set the warning activation dropdown options text with the associated keys from the current language.
    ui_manager.warning_activation_options = {
        language_manager.language.current.ui.dropdown.warning_activation.number,
        language_manager.language.current.ui.dropdown.warning_activation.percent
    };

    re.on_draw_ui(function()
        --[[ For reference: https://cursey.github.io/reframework-book/api/imgui.html ]]
    
        -- Define the flags that will track when values in the UI are changed.
        local config_changed,
            language_changed,
            font_size_changed,
            changed = false, false, false, false;

        -- Set the language index to default to 1 (default).
        local language_index = 1;

        -- Create a new tree node using the mod name from constants.
        if imgui.tree_node(constants.mod_name) then

            -- Push the font to ImGUI associated with the font name associated with the current language.
            imgui.push_font(ui_manager.fonts[language_manager.language.current.font]);

            -- Create a button that can be used to reset the config.
            if imgui.button(language_manager.language.current.ui.button.reset_config) then
                -- If pressed, then reset the config to the default values.
                config_manager.reset();

                -- Mark the config, language, and font size changed flags as true.
                config_changed = true;
                language_changed = true;
                font_size_changed = true;
            end
    
            -- Create a checkbox that a user can use to enable/disable the functionality of the mod.
            changed, config_manager.config.current.enabled = imgui.checkbox(language_manager.language.current.ui.checkbox.enabled,
                config_manager.config.current.enabled);
            config_changed = config_changed or changed;
    
            -- Create a new tree node for all of the mod settings.
            if imgui.tree_node(language_manager.language.current.ui.header.settings) then

                -- Create a new tree node for all settings relating to the notification display.
                if imgui.tree_node(language_manager.language.current.ui.header.notification_display) then
    
                    -- Create a checkbox that a user can use to configure the notification to only show while aiming.
                    -- Otherwise it will always show while the bow is drawn.
                    changed, config_manager.config.current.display.only_show_while_aiming =
                        imgui.checkbox(language_manager.language.current.ui.checkbox.only_show_while_aiming,
                        config_manager.config.current.display.only_show_while_aiming);
                    config_changed = config_changed or changed;
                    imgui.new_line();

                    -- Get the screen size to calculate the maximum and minumum values for the X and Y position adjustments.
                    local display_size = imgui.get_display_size();
                    local max_x_adjust = math.floor(display_size.x / 2);
                    local min_x_adjust = max_x_adjust * -1;
                    local max_y_adjust = math.floor(display_size.y / 2);
                    local min_y_adjust = max_y_adjust * -1;

                    -- Create a slider that the user can use to adjust the X position of the notification.
                    imgui.text(language_manager.language.current.ui.slider.adjust_position);
                    imgui.text("X");
                    imgui.same_line();
                    changed, config_manager.config.current.display.x_position_adjust = imgui.slider_int(" ",
                        config_manager.config.current.display.x_position_adjust, min_x_adjust, max_x_adjust);
                    config_changed = config_changed or changed;

                    -- Check if the user is hovering over the X position slider and is NOT interacting with it.
                    if imgui.is_item_hovered() and not imgui.is_item_active() then
                        -- If yes, then create a tooltip that will display to inform the user of a way to input
                        -- a value manually (with a keyboard).
                        imgui.set_tooltip(language_manager.language.current.ui.tooltip.manual_input);
                        imgui.begin_tooltip();
                        imgui.end_tooltip();
                    end
                    
                    -- Create a slider that the user can use to adjust the Y position of the notification.
                    imgui.text("Y")
                    imgui.same_line();
                    changed, config_manager.config.current.display.y_position_adjust = imgui.slider_int("  ",
                        config_manager.config.current.display.y_position_adjust, min_y_adjust, max_y_adjust);
                    config_changed = config_changed or changed;

                    -- Check if the user is hovering over the Y position slider and is NOT interacting with it.
                    if imgui.is_item_hovered() and not imgui.is_item_active() then
                        -- If yes, then create a tooltip that will display to inform the user of a way to input
                        -- a value manually (with a keyboard).
                        imgui.set_tooltip(language_manager.language.current.ui.tooltip.manual_input);
                        imgui.begin_tooltip();
                        imgui.end_tooltip();
                    end
                    imgui.new_line();

                    -- Create a slider that the user can use to adjust the font size of the notification text.
                    imgui.text(language_manager.language.current.ui.slider.font_size);
                    changed, config_manager.config.current.display.font_size = imgui.slider_int("   ",
                        config_manager.config.current.display.font_size, 1, 100);
                    config_changed = config_changed or changed;
                    font_size_changed = font_size_changed or changed;

                    -- Check if the user is hovering over the font size slider and is NOT interacting with it.
                    if imgui.is_item_hovered() and not imgui.is_item_active() then
                        -- If yes, then create a tooltip that will display to inform the user of a way to input
                        -- a value manually (with a keyboard).
                        imgui.set_tooltip(language_manager.language.current.ui.tooltip.manual_input);
                        imgui.begin_tooltip();
                        imgui.end_tooltip();
                    end
                    imgui.new_line();

                    -- Create a color picker that the user can use to change the color of the message text within the notification.
                    imgui.text(language_manager.language.current.ui.color_picker.message_text);
                    changed, config_manager.config.current.display.text_color =
                        imgui.color_picker_argb(language_manager.language.current.ui.misc.current,
                        config_manager.config.current.display.text_color, constants.color_picker_options);
                    config_changed = config_changed or changed;
                    imgui.new_line();
    
                    -- Create a color picker that the user can use to change the color of the notification box outline.
                    imgui.text(language_manager.language.current.ui.color_picker.box_outline);
                    changed, config_manager.config.current.display.box_outline_color =
                        imgui.color_picker_argb(language_manager.language.current.ui.misc.current .. " ",
                        config_manager.config.current.display.box_outline_color, constants.color_picker_options);
                    config_changed = config_changed or changed;
                    imgui.new_line();

                    -- Create a color picker that the user can use to change the color of the background of the notification box.
                    imgui.text(language_manager.language.current.ui.color_picker.box_background);
                    changed, config_manager.config.current.display.box_background_color =
                        imgui.color_picker_argb(language_manager.language.current.ui.misc.current .. "  ",
                        config_manager.config.current.display.box_background_color, constants.color_picker_options_with_alpha);
                    config_changed = config_changed or changed;

                    -- Close the Notification Display tree node.
                    imgui.tree_pop();
                end
    
                -- Create a new tree node for all settings relating to warnings.
                if imgui.tree_node(language_manager.language.current.ui.header.warnings) then

                    -- Create a checkbox that a user can use to enable/disable the warning notification.
                    changed, config_manager.config.current.warning.enabled =
                        imgui.checkbox(language_manager.language.current.ui.checkbox.enable_warnings,
                        config_manager.config.current.warning.enabled);
                    config_changed = config_changed or changed;
                    imgui.new_line();

                    -- Create a combo box that allows the user to switch between the different options that are
                    -- used to determine when the warning notification should appear.
                    imgui.text(language_manager.language.current.ui.combo_box.display_when);
                    changed, config_manager.config.current.warning.mode =
                        imgui.combo(" ", config_manager.config.current.warning.mode, ui_manager.warning_activation_options);
                    config_changed = config_changed or changed;
    
                    -- Create a new table to store the activation amount values that will be used within the UI as the
                    -- combo box options change. Default to the percent remaining values.
                    local activation_amount_settings = {
                        label = "%",
                        max_value = 100
                    };

                    -- Check if the warning mode saved on the config is for the amount of shots remaining option.
                    if config_manager.config.current.warning.mode == constants.warning_activation_option.number then
                        -- If yes, then update the activation amount values for the shots remaining option.
                        activation_amount_settings.label = language_manager.language.current.ui.misc.shots;
                        activation_amount_settings.max_value = 50;

                        -- Check if the amount value is larger than 50 (since the percentage option goes up to 100).
                        if config_manager.config.current.warning.amount > 50 then
                            -- If yes, then set the value as 50 and mark the config as being changed.
                            config_manager.config.current.warning.amount = 50;
                            config_changed = true;
                        end
                    end

                    -- Create a slider that the user can use to adjust the value that determines when the warning notification
                    -- should display (based on the selected option in the display when combo box).
                    imgui.text(language_manager.language.current.ui.slider.is_equal_or_less);
                    changed, config_manager.config.current.warning.amount = imgui.slider_int(activation_amount_settings.label,
                        config_manager.config.current.warning.amount, 1, activation_amount_settings.max_value);
                    config_changed = config_changed or changed;
                    imgui.new_line();

                    -- Create a color picker that the user can use to change the color of the message text within the
                    -- warning notification.
                    imgui.text(language_manager.language.current.ui.color_picker.message_text);
                    changed, config_manager.config.current.warning.text_color =
                        imgui.color_picker_argb(language_manager.language.current.ui.misc.current,
                        config_manager.config.current.warning.text_color, constants.color_picker_options);
                    config_changed = config_changed or changed;
                    imgui.new_line();

                    -- Create a color picker that the user can use to change the color of the warning notification box outline.
                    imgui.text(language_manager.language.current.ui.color_picker.box_outline);
                    changed, config_manager.config.current.warning.box_outline_color =
                        imgui.color_picker_argb(language_manager.language.current.ui.misc.current .. " ",
                        config_manager.config.current.warning.box_outline_color, constants.color_picker_options);
                    config_changed = config_changed or changed;
                    imgui.new_line();

                    -- Create a color picker that the user can use to change the color of the background of the warning
                    -- notification box.
                    imgui.text(language_manager.language.current.ui.color_picker.box_background);
                    changed, config_manager.config.current.warning.box_background_color =
                        imgui.color_picker_argb(language_manager.language.current.ui.misc.current .. "  ",
                        config_manager.config.current.warning.box_background_color, constants.color_picker_options_with_alpha);
                    config_changed = config_changed or changed;
                    
                    -- Close the Warnings tree node.
                    imgui.tree_pop();
                end

                -- Create a new tree node for the language settings.
                if imgui.tree_node(language_manager.language.current.ui.header.language) then

                    -- Create a combo box that allows the user to switch between different language options.
                    changed, language_index = imgui.combo(" ", green_comfy_tea_utils.table.find_index(language_manager.language.names,
                        config_manager.config.current.language, false), language_manager.language.names);
                    config_changed = config_changed or changed;
                    language_changed = language_changed or changed;
                    
                    -- Close the Language tree node.
                    imgui.tree_pop();
                end
    
                -- Close the Settings tree node.
                imgui.tree_pop();
            end

            -- Pop the font that was pushed earlier to return to the last used (default) REFramework font.
            imgui.pop_font();

            -- Close the tree node for the mod.
            imgui.tree_pop();
        end

        -- Check if the language option was changed.
        if language_changed then
            -- If yes, then update the selected language using the selected language.
            language_manager.update(language_index, true);

            -- Mark the config as being changed since the language was updated.
            config_changed = true;

            -- Load the font on the current language if its not already loaded.
            ui_manager.load_font_if_missing();

            -- Set the warning activation dropdown options text with the associated keys from the new current language.
            ui_manager.warning_activation_options[constants.warning_activation_option.number] =
                language_manager.language.current.ui.dropdown.warning_activation.number;
            ui_manager.warning_activation_options[constants.warning_activation_option.percentage] =
                language_manager.language.current.ui.dropdown.warning_activation.percent;
        end

        -- Check if the font size was changed.
        if font_size_changed then
            -- If yes, then call the update font function on the draw manager.
            draw_manager.update_font();
        end
    
        -- Check if the config was changed.
        if config_changed then
            -- If yes, then save the current config into the config file.
            config_manager.save();
    
            -- Check if the mod enabled option was turned off (disabled).
            if not config_manager.config.current.enabled then
                -- If yes, then reset the values on the draw manager since it will not be drawing anything anymore.
                draw_manager.reset();
            end
        end
    end)
end

return ui_manager;