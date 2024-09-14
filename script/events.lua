function atl_ranks.on_dignode(pos, oldnode, digger)
    if not digger or not digger:is_player() then
        return
    end
    local player_name = digger:get_player_name()
    for _, entry in ipairs(atl_ranks.exp_table) do
        if oldnode.name == entry.block then
            atl_ranks.add_exp(player_name, entry.exp)
            atl_ranks.update_hud(digger)
            break
        end
    end
end
minetest.register_on_dignode(atl_ranks.on_dignode)

minetest.register_on_joinplayer(function(player)
    local player_name = player:get_player_name()
    atl_ranks.initialize_player(player_name)
    atl_ranks.update_nametag(player)
    atl_ranks.update_hud(player)
end)
