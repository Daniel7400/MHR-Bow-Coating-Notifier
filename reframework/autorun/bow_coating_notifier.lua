log.info("[bow_coating_notifier.lua] loaded")

--- IMPORTS
require("Bow_Coating_Notifier.extensions.imgui_extensions");
require("Bow_Coating_Notifier.extensions.math_extensions");
require("Bow_Coating_Notifier.extensions.sdk_extensions");
require("Bow_Coating_Notifier.extensions.table_extensions");
local constants = require("Bow_Coating_Notifier.constants");
local config_manager = require("Bow_Coating_Notifier.config_manager");
local draw_manager = require("Bow_Coating_Notifier.draw_manager");
local language_manager = require("Bow_Coating_Notifier.language_manager");
local sdk_manager = require("Bow_Coating_Notifier.sdk_manager");
local ui_manager = require("Bow_Coating_Notifier.ui_manager");
--- END IMPORTS

--- MODULE INIT
config_manager.init_module();
draw_manager.init_module();
language_manager.init_module();
sdk_manager.init_module();
ui_manager.init_module();
--- END MODULE INIT

re.on_frame(function()
	-- Check if the enabled flag on the config is NOT true (meaning the user marked it as disabled).
	if not config_manager.config.current.enabled then
		-- Return to exit early.
		return;
	end

	-- Call the reset function on the draw manager to reset the values for the new frame.
	draw_manager.reset();

	-- Call the get player function on the sdk manager to get the player object.
	local player = sdk_manager.get_player();
	if not player then
		-- Return to exit early if the player object was NOT found.
		return;
	end

	-- Get the player weapon type field on the player and check if is of the bow type.
	local is_using_bow = player:get_field("_playerWeaponType") == constants.player_weapon_type.Bow
	if not is_using_bow then
		-- Return to exit early if the player is NOT using a bow.
		return;
	end

	-- Call the is weapon on function on the player to determine if the player has their weapon drawn (out).
	local is_weapon_drawn = player:call("isWeaponOn");
	if not is_weapon_drawn then
		-- Return to exit early if the player does NOT have their weapon drawn (out).
		return;
	end

	-- Call the get is aim mode on the player to determine if they are aiming their bow.
	local is_aiming = player:call("get_IsAimMode");

	-- Check if the only show while aiming flag on the config is true AND the player is NOT aiming.
	if config_manager.config.current.display.only_show_while_aiming and not is_aiming then
		-- If yes, then return to exit early since the player is NOT aiming and it is setup so that it will only
		-- show while they aiming.
		return;
	end

	-- Call the get using bottle function on the player to determine which coating they have applied.
	local equipped_coating = player:call("getUsingBottle");
	if not equipped_coating then
		-- Return to exit early if there is a nil coating applied for whatever reason.
		return;
	end

	-- Check if the coating that is applied is the close/short range coating.
	if equipped_coating == constants.coating_type.ShortRange then
		-- If yes, then return to exit early since the close/short range coating has unlimited shots.
		return;
	end

	-- Check if there is NO coating applied.
	if equipped_coating == constants.coating_type.None then
		-- If yes, then set the draw flag on the draw manager as true and return to exit early since the notification
		-- will be displayed under this condition.
		draw_manager.flags.draw = true;
		return;
	end

	-- Check if the warnings enabled flag is NOT true.
	if not config_manager.config.current.warning.enabled then
		-- If yes, then return to exit early since the rest of the code deals with the warnings and it is NOT enabled.
		return;
	end
	
	-- Call the get ref bottle slider data function on the player to get the bottle slider data.
	local bottle_slider_data = player:call("get_RefBottleSliderData");
	if not bottle_slider_data then
		-- Return to exit early if there is no bottle slider data for whatever reason.
		return
	end

	-- Call the get bottle slider func function on the bottle slider data to get the bottle slider func.
	local bottle_slider_func = bottle_slider_data:call("get_BottleSliderFunc");
	if not bottle_slider_func then
		-- Return to exit early if there is no bottle slider func for whatever reason.
		return
	end

	-- Call the get using bottle inventory on the bottle slider func to get the inventory data for the applied coating.
	local bottle_inventory_data = bottle_slider_func:call("getUsingBottleInventory");
	if not bottle_inventory_data then
		-- Return to exit early if there is no bottle inventory data for the applied coating for whatever reason.
		return
	end
	
	-- Call the get count function on the bottle inventory data and store it in the remaining shot count variable on
	-- the draw manager.
	draw_manager.values.remaining_shot_count = bottle_inventory_data:call("getCount");

	-- Check if the selected warning mode on the config is the number of shots remaining option AND
	-- the remaining shot count is less than or equal to the display activation amount.
	if config_manager.config.current.warning.mode == constants.warning_activation_option.number and
		draw_manager.values.remaining_shot_count <= config_manager.config.current.warning.amount then
		-- If yes, the set the draw and low shot count flags on the draw manager as true.
		draw_manager.flags.draw = true;
		draw_manager.flags.low_shot_count = true;
	-- Else if, check if the selected warning mode on the config is the percentage of shots remaining option.
	elseif config_manager.config.current.warning.mode == constants.warning_activation_option.percentage then
		-- Call the get item data function on the bottle inventory data to get the specific item data related
		-- to the applied coating.
		local item_data = bottle_inventory_data:call("getItemData");

		-- Call the get max count in pouch (the player's inventory pouch) on the item data to get the max count
		-- that can be held.
		local max_count = item_data:call("getMaxCountInPouch");

		-- Calculate the percentage of shots remaining.
		local percent_remaining = math.floor((draw_manager.values.remaining_shot_count / max_count) * 100);

		-- Check if the percentage remaining is less than or equal to the display activation amount from the config.
		if percent_remaining <= config_manager.config.current.warning.amount then
			-- If yes, then set the draw and low shot count flag on the draw manager as true.
			draw_manager.flags.draw = true;
			draw_manager.flags.low_shot_count = true;
		end
	end
	

end)