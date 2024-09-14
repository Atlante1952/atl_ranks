function atl_ranks.get_exp_for_level(level)
    return math.ceil(160 * 1.5^level + 1)
end

function atl_ranks.get_player_rank(player_name)
    local rank = atl_ranks.storage:get_string(player_name)
    if minetest.check_player_privs(player_name, {server = true}) then
        rank = "admin"
    else
        rank = "beginner"
    end
    return rank
end

function atl_ranks.set_player_rank(player_name, rank)
    atl_ranks.storage:set_string(player_name, rank)
end

function atl_ranks.get_rank_by_level(level)
    for rank, info in pairs(atl_ranks.all_ranks) do
        if info.min_level and info.max_level and level >= info.min_level and level <= info.max_level then
            return rank
        end
    end
    return "beginner"
end

function atl_ranks.update_nametag(player)
    local player_name = player:get_player_name()
    local rank = atl_ranks.get_player_rank(player_name)
    local rank_info = atl_ranks.all_ranks[rank]
    if not rank_info then
        minetest.log("error", "Rank info not found for rank: " .. rank)
        return
    end
    local level = atl_ranks.get_player_level(player_name)
    local nametag = minetest.colorize(rank_info.color, rank_info.description .. " [Lv." .. level .. "]") .. " " .. player_name
    player:set_nametag_attributes({text = nametag})
end

function atl_ranks.get_player_exp(player_name)
    return tonumber(atl_ranks.storage:get_int(player_name .. "_exp")) or 0
end

function atl_ranks.set_player_exp(player_name, exp)
    atl_ranks.storage:set_int(player_name .. "_exp", exp)
end

function atl_ranks.get_player_level(player_name)
    return tonumber(atl_ranks.storage:get_int(player_name .. "_level")) or 0
end

function atl_ranks.set_player_level(player_name, level)
    atl_ranks.storage:set_int(player_name .. "_level", level)
end

function atl_ranks.check_level_up(player_name, new_exp)
    local current_level = atl_ranks.get_player_level(player_name)
    while true do
        local next_level_exp = atl_ranks.get_exp_for_level(current_level + 1)
        if new_exp < next_level_exp then
            break
        end
        new_exp = new_exp - next_level_exp
        current_level = current_level + 1
        --minetest.chat_send_player(player_name, "You leveled up to level " .. current_level .. "!")
        local player = minetest.get_player_by_name(player_name)
        local lootboxes = math.random(1, 3)
        local inv = player:get_inventory()
        if inv:room_for_item("main", {name = "atl_ranks:lootbox", count = lootboxes}) then
            inv:add_item("main", {name = "atl_ranks:lootbox", count = lootboxes})
            minetest.chat_send_player(player_name, "-!- Your level has increased, you have received a reward " .. lootboxes .. " lootbox!")
        else
            minetest.chat_send_player(player_name, "-!- Your level has increased, you have received a reward " .. lootboxes .. " lootbox! (Item dropped)")
            local pos = player:get_pos()
            minetest.add_item(pos, {name = "atl_ranks:lootbox", count = lootboxes})
        end
    end
    atl_ranks.set_player_exp(player_name, new_exp)
    atl_ranks.set_player_level(player_name, current_level)
    local player = minetest.get_player_by_name(player_name)
    atl_ranks.update_nametag(player)
    --minetest.chat_send_player(player_name, "You leveled up to level " .. current_level .. "!")
    local new_rank = atl_ranks.get_rank_by_level(current_level)
    atl_ranks.set_player_rank(player_name, new_rank)
    atl_ranks.update_nametag(player)
    atl_ranks.update_hud(player)
end

function atl_ranks.add_exp(player_name, exp)
    local current_exp = atl_ranks.get_player_exp(player_name)
    local new_exp = current_exp + exp
    atl_ranks.check_level_up(player_name, new_exp)
end

function atl_ranks.update_hud(player)
    local player_name = player:get_player_name()
    local rank = atl_ranks.get_player_rank(player_name)
    local rank_info = atl_ranks.all_ranks[rank]
    local level = atl_ranks.get_player_level(player_name)
    local exp = atl_ranks.get_player_exp(player_name)
    local exp_needed = atl_ranks.get_exp_for_level(level + 1)
    local exp_percentage = exp_needed > 0 and (exp / exp_needed * 100) or 0
    local old_hud_ids = atl_ranks.player_hud_ids[player_name] or {}
    for _, hud_id in ipairs(old_hud_ids) do
        player:hud_remove(hud_id)
    end
    local hud_id = player:hud_add({
        hud_elem_type = "text",
        position = {x = 0.85, y = 0.35},
        offset = {x = 0, y = 0},
        text = "Level: " .. level .. " | Rank " .. rank_info.description .. "\nExp: " .. exp .. "/" .. exp_needed .. " | Exp: " .. string.format("%.2f", exp_percentage) .. "%",
        number = 0xe7b40e,
        alignment = {x = 0.5, y = 1},
        scale = {x = 100, y = 100},
    })
    atl_ranks.player_hud_ids[player_name] = {hud_id}
end

function atl_ranks.initialize_player(player_name)
    if atl_ranks.storage:get_string(player_name) == "" then
        atl_ranks.set_player_rank(player_name, "beginner")
        atl_ranks.set_player_exp(player_name, 0)
        atl_ranks.set_player_level(player_name, 1)
    end
    if minetest.check_player_privs(player_name, {server = true}) then
        atl_ranks.set_player_rank(player_name, "admin")
    end
end
