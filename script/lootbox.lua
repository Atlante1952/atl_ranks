local function get_random_items(lootbox_items, count)
    local selected_items = {}
    for i = 1, count do
        local item = lootbox_items[math.random(1, #lootbox_items)]
        table.insert(selected_items, item)
    end
    return selected_items
end

local function drop_items(pos, items)
    local index = 1
    local timer = 0
    local drop_finished = false

    minetest.register_globalstep(function(dtime)
        timer = timer + dtime
        if timer >= 1 then
            timer = timer - 1
            if index <= #items then
                local item = items[index]
                local stack = ItemStack(item[1] .. " " .. item.quantity)
                local drop_pos = {x = pos.x, y = pos.y + 1.5, z = pos.z}
                minetest.add_item(drop_pos, stack)
                index = index + 1
                return true
            elseif not drop_finished then
                drop_finished = true
                minetest.after(1, function()
                    minetest.set_node(pos, {name = "air"})
                end)
                return false
            end
        end
        return true
    end)
end

minetest.register_node("atl_ranks:lootbox", {
    description = "Lootbox",
    tiles = {"atl_chest_chest_bottom.png", "atl_chest_chest_bottom.png", "atl_chest_chest_side.png",
        "atl_chest_chest_side.png", "atl_chest_chest_side.png", "atl_chest_chest_side.png"},
    groups = {},
    sounds = default.node_sound_wood_defaults(),
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "Unopened Lootbox")
    end,
    on_destruct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext", "")
    end,
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        if meta:get_string("infotext") == "Unopened Lootbox" then
            local items = get_random_items(atl_ranks.lootbox_items, 8)
            drop_items(pos, items)
            meta:set_string("infotext", "Opened Lootbox")
        end
    end,
})