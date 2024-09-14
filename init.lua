atl_ranks = {}
atl_ranks.modpath = minetest.get_modpath("atl_ranks")
atl_ranks.storage = minetest.get_mod_storage()
atl_ranks.player_hud_ids = {}


function atl_ranks.load_file(path)
    local status, err = pcall(dofile, path)
    if not status then
        minetest.log("error", "-!- Failed to load file: " .. path .. " - Error: " .. err)
    else
        minetest.log("action", "-!- Successfully loaded file: " .. path)
    end
end

if atl_ranks.modpath then
    local files_to_load = {
        "script/api.lua",
        "script/events.lua",
        "script/commands.lua",
        "script/chat.lua",
        "script/tables.lua",
        "script/lootbox.lua",
    }
    for _, file in ipairs(files_to_load) do
        atl_ranks.load_file(atl_ranks.modpath .. "/" .. file)
    end
else
    minetest.log("error", "-!- Files in clan mod are not set or valid.")
end

