local register_node = core.register_node
local register_alias = core.register_alias


register_node('ludus_essential:tech_stone', {
    description = 'LudusTechnical Stone',
    tiles = { 'ludus_tech_stone.png' },
    groups = { oddly_breakable_by_hand = 3 },
    is_ground_content = true
})

register_node('ludus_essential:tech_water', {
    description = 'LudusTechnical Water',
    tiles = { 'ludus_tech_water.png' },
    groups = { oddly_breakable_by_hand = 3 },
    is_ground_content = true
})


-- Bloques de colores
local admins = {"creador", "profe_daniel", "admin3"}

register_node('ludus_essential:red_block', {
    description = 'Bloque Rojo',
    tiles = { 'ludus_red.png' },
    groups = { oddly_breakable_by_hand = 3 },
    is_ground_content = false,
    drop = "",
    on_dig = function(pos, node, digger)
        local name = digger:get_player_name()
        for _, adm in ipairs(admins) do
            if name == adm then
                minetest.node_dig(pos, node, digger)
                return
            end
        end
        minetest.chat_send_player(name, "¡No puedes romper este bloque!")
    end,
})

register_node('ludus_essential:blue_block', {
    description = 'Bloque Azul',
    tiles = { 'ludus_blue.png' },
    groups = { oddly_breakable_by_hand = 3 },
    is_ground_content = false,
    drop = "",
    on_dig = function(pos, node, digger)
        local name = digger:get_player_name()
        for _, adm in ipairs(admins) do
            if name == adm then
                minetest.node_dig(pos, node, digger)
                return
            end
        end
        minetest.chat_send_player(name, "¡No puedes romper este bloque!")
    end,
})

register_node('ludus_essential:green_block', {
    description = 'Bloque Verde',
    tiles = { 'ludus_green.png' },
    groups = { oddly_breakable_by_hand = 3 },
    is_ground_content = false,
    drop = "",
    on_dig = function(pos, node, digger)
        local name = digger:get_player_name()
        for _, adm in ipairs(admins) do
            if name == adm then
                minetest.node_dig(pos, node, digger)
                return
            end
        end
        minetest.chat_send_player(name, "¡No puedes romper este bloque!")
    end,
})

register_node('ludus_essential:yellow_block', {
    description = 'Bloque Amarillo',
    tiles = { 'ludus_yellow.png' },
    groups = { oddly_breakable_by_hand = 3 },
    is_ground_content = false,
    drop = "",
    on_dig = function(pos, node, digger)
        local name = digger:get_player_name()
        for _, adm in ipairs(admins) do
            if name == adm then
                minetest.node_dig(pos, node, digger)
                return
            end
        end
        minetest.chat_send_player(name, "¡No puedes romper este bloque!")
    end,
})


register_alias('mapgen_stone', 'ludus_essential:tech_stone')
register_alias('mapgen_water_source', 'ludus_essential:tech_water')
register_alias('mapgen_dirt', 'ludus_essential:red_block')
register_alias('mapgen_sand', 'ludus_essential:blue_block')
register_alias('mapgen_gravel', 'ludus_essential:green_block')
register_alias('mapgen_clay', 'ludus_essential:yellow_block')
register_alias('rojo', 'ludus_essential:red_block')
register_alias('azul', 'ludus_essential:blue_block')
register_alias('verde', 'ludus_essential:green_block')
register_alias('amarillo', 'ludus_essential:yellow_block')
