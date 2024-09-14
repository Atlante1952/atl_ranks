minetest.register_chatcommand("exp", {
    description = "Show the experience of the target player or the player who executed the command",
    privs = {shout = true},
    func = function(player_name, param)
        local target_player_name = param
        if target_player_name == "" then
            target_player_name = player_name
        end
        local exp = atl_ranks.get_player_exp(target_player_name)
        minetest.chat_send_player(player_name, target_player_name .. " has " .. exp .. " experience.")
    end,
})

minetest.register_chatcommand("set_exp", {
    params = "<player_name> <level> <exp>",
    description = "Set the level and experience of a player",
    privs = {server = true},
    func = function(player_name, param)
        local params = param:split(" ")
        if #params ~= 3 then
            return false, "-!- Usage: /set_exp <player_name> <level> <exp>"
        end
        local target_player_name = params[1]
        local level = tonumber(params[2])
        local exp = tonumber(params[3])
        if not level or not exp then
            return false, "-!- Level and experience must be numbers"
        end
        atl_ranks.set_player_level(target_player_name, level)
        atl_ranks.set_player_exp(target_player_name, exp)
        local new_rank = atl_ranks.get_rank_by_level(level)
        atl_ranks.set_player_rank(target_player_name, new_rank)
        local player = minetest.get_player_by_name(target_player_name)
        if player then
            atl_ranks.update_nametag(player)
            atl_ranks.update_hud(player)
        end
        return true, "-!- Set " .. target_player_name .. " to level " .. level .. " with " .. exp .. " experience"
    end,
})

