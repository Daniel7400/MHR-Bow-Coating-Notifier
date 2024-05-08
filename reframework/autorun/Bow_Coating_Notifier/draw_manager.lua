-- IMPORTS
local config_manager = require("Bow_Coating_Notifier.config_manager");
local language_manager = require("Bow_Coating_Notifier.language_manager");
-- END IMPORTS

--- The manager for all things related to drawing on the screen.
local draw_manager = {
    -- The font used by d2d to display the text.
    font = nil,

    -- The flags that influence what (if anything) gets drawn on the screen.
    flags = {
        -- The flag that determines whether anything should be drawn on the screen or not.
        draw = false,

        -- The flag used to determine if the warning (low shot count remaining) message should be displayed.
        low_shot_count = false
    },

    -- The values used in the drawing process.
    values = {
        -- The value used to store the remaining amount of shots.
        remaining_shot_count = 0
    }
};

-- Define a buffer size that will be used to add spacing between the edge of the display notification and the text within.
local box_buffer_size <const> = 30;
local box_buffer_size_half <const> = box_buffer_size / 2;

---
--- Initializes the draw manager module.
---
function draw_manager.init_module()
    d2d.register(function()
        -- Set the font to use as Consolas with the size defined by the font size set in the config.
        draw_manager.font = d2d.Font.new("Consolas", config_manager.config.current.display.font_size);
    end,
    function()
        -- Check if the draw flag is set as true, otherwise do NOT draw anything on the screen.
        if draw_manager.flags.draw then
            -- If yes, initalize the notification variables, defaulting to the normal/alert values.
            local header_text = string.format("<-%s->", language_manager.language.current.notification.header.alert);
            local message_text = string.format("\n%s", language_manager.language.current.notification.message.no_coating);
            local text_color = config_manager.config.current.display.text_color;
            local outline_color = config_manager.config.current.display.box_outline_color;
            local background_color = config_manager.config.current.display.box_background_color;
    
            -- Check if the low shot count flag is set as true.
            if draw_manager.flags.low_shot_count then
                -- If yes, then update the notification header to that of the warning text.
                header_text = string.format("<-%s->", language_manager.language.current.notification.header.warning);

                -- Build out the remaining shot(s) string since it varies depending if the number of remaining shots
                -- is singular or plural.
                local remaining_shots_language_string = string.format(language_manager.language.current.notification.message.remaining_shots,
                    draw_manager.values.remaining_shot_count);

                -- Check if the remaining shot count is equal to 1.
                if draw_manager.values.remaining_shot_count == 1 then
                    -- If yes, then update the remaining shots string to the single shot remaining version.
                    remaining_shots_language_string = string.format(
                        language_manager.language.current.notification.message.single_remaining_shot,
                        draw_manager.values.remaining_shot_count);
                end

                -- Update the message text for the warning text.
                message_text = string.format("\n%s", remaining_shots_language_string);
                
                -- Update the colors to use the warning color values set on the config.
                text_color = config_manager.config.current.warning.text_color;
                outline_color = config_manager.config.current.warning.box_outline_color;
                background_color = config_manager.config.current.warning.box_background_color;
            end
    
            -- Measure the width and heights of the header and message text strings.
            local header_width, header_height = draw_manager.font:measure(header_text);
            local message_width, message_height = draw_manager.font:measure(message_text);

            -- Calculate the x offset for the header text to ensure it sits in the middle of the message box.
            local header_x_offset = (message_width - header_width) / 2;

            -- Calculate the dimensions of the message box using the width and height of the message
            -- and accounting for the buffer zone between the box edge and text.
            local box_width = message_width + box_buffer_size;
            local box_height = message_height + box_buffer_size;

            -- Get the width and height of the screen.
            local screen_w, screen_h = d2d.surface_size();
    
            -- Calculate the x and y coordinate such that the box and text will render in the center of the screen.
            local box_x = (screen_w / 2) - (box_width / 2);
            local box_y = (screen_h / 2) - (box_height / 2);
            local text_x = box_x;
            local text_y = box_y;

            -- Check if the width of the header is larger than the width of the message.
            if header_width > message_width then
                -- If yes, then recalculate the box width and box x position using the header width instead.
                box_width = header_width + box_buffer_size;
                box_x = (screen_w / 2) - (box_width / 2);
            end

            -- Apply x and y adjustments from the config.
            box_x = box_x + config_manager.config.current.display.x_position_adjust;
            box_y = box_y + config_manager.config.current.display.y_position_adjust;
            text_x = text_x + config_manager.config.current.display.x_position_adjust;
            text_y = text_y + config_manager.config.current.display.y_position_adjust;

            -- Draw the box with outline to the screen.
            d2d.fill_rect(box_x, box_y, box_width, box_height, background_color);
            d2d.outline_rect(box_x, box_y, box_width, box_height, 5, outline_color);

            -- Draw the header text into the message box.
            d2d.text(draw_manager.font, header_text, text_x + header_x_offset + box_buffer_size_half,
                text_y + box_buffer_size_half, text_color);

            -- Draw the message text into the message box.
            d2d.text(draw_manager.font, message_text, text_x + box_buffer_size_half,
                text_y + box_buffer_size_half, text_color);
        end
    end)
end

---
--- Updates the font set on the draw manager.
---
function draw_manager.update_font()
    -- Update the font being used by the draw manager to be one using the font size defined in the config.
    draw_manager.font = d2d.Font.new("Consolas", config_manager.config.current.display.font_size);
end

---
--- Reset the draw manager flags and values back to the default values.
---
function draw_manager.reset()
    -- Reset all of the draw manager flags and values to their default values.
    draw_manager.flags.draw = false;
    draw_manager.flags.low_shot_count = false;
    draw_manager.values.remaining_shot_count = 0;
end

return draw_manager;