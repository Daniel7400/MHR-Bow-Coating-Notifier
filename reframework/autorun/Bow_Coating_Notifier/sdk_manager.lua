--- The manager for all things related calling into the sdk.
local sdk_manager = {
    -- The player manager managed singleton from the sdk.
    player_manager = nil
};

---
--- Attempt to get the player object from the game.
--- @return any player The player object obtained from the player manager, otherwise nil.
---
function sdk_manager.get_player()
    -- Check if the player manager on the sdk manager is NOT already loaded/valid.
    if not sdk_manager.player_manager then
        -- If yes, then call into the sdk to get the player manager managed singleton.
        sdk_manager.player_manager = sdk.get_managed_singleton('snow.player.PlayerManager')
    end
	
    -- Check if the player manager is stil NOT valid.
	if not sdk_manager.player_manager then
        -- If yes, then return nil since no player can be found.
		return nil;
	end
	
    -- Return the player object as a result of the find master player call on the player manager.
	return sdk_manager.player_manager:call("findMasterPlayer")
end

---
--- Initializes the sdk manager module.
---
function sdk_manager.init_module()
    sdk_manager.player_manager = sdk.get_managed_singleton('snow.player.PlayerManager')
end

return sdk_manager;