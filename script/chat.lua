minetest.register_on_chat_message(function(player_name, message)
    local rank = atl_ranks.get_player_rank(player_name)
    local rank_info = atl_ranks.all_ranks[rank]
    if not rank_info then
        minetest.log("error", "Rank info not found for rank: " .. rank)
        return true
    end
    local level = atl_ranks.get_player_level(player_name)
    local prefix = minetest.colorize(rank_info.color, rank_info.description .. " [Lv." .. level .. "] ")
    minetest.chat_send_all(prefix .. "<" .. player_name .. "> " .. message)
    return true
end)