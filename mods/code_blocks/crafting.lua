--[[
Crafting.lua - Recetas de crafteo para CodeCraft Academy
Autores: profeDaniel & GitHub Copilot
--]]

-- Receta para Terminal de Programación
minetest.register_craft({
    output = "code_blocks:programming_terminal",
    recipe = {
        {"default:steel_ingot", "default:glass",        "default:steel_ingot"},
        {"default:copper_ingot", "default:mese_crystal", "default:copper_ingot"},
        {"default:steel_ingot", "default:steel_ingot",  "default:steel_ingot"}
    }
})

-- Receta para Servidor de Código
minetest.register_craft({
    output = "code_blocks:code_server", 
    recipe = {
        {"default:steel_ingot", "default:mese_block",   "default:steel_ingot"},
        {"default:steel_ingot", "default:diamond",      "default:steel_ingot"},
        {"default:steel_ingot", "default:steel_ingot",  "default:steel_ingot"}
    }
})

-- Receta para Monitor de Resultados
minetest.register_craft({
    output = "code_blocks:result_monitor",
    recipe = {
        {"default:obsidian_glass", "default:obsidian_glass", "default:obsidian_glass"},
        {"default:steel_ingot",    "default:mese_crystal",   "default:steel_ingot"},
        {"default:stone",          "default:stone",          "default:stone"}
    }
})

-- Recetas alternativas más accesibles para modo educativo

-- Terminal básico (más fácil de hacer)
minetest.register_craft({
    output = "code_blocks:programming_terminal",
    recipe = {
        {"default:stone", "default:glass", "default:stone"},
        {"default:stone", "default:torch", "default:stone"},
        {"default:stone", "default:stone", "default:stone"}
    }
})

-- Receta de reciclaje (convertir terminal en recursos)
minetest.register_craft({
    type = "shapeless",
    output = "default:steel_ingot 3",
    recipe = {"code_blocks:programming_terminal"}
})

-- Añadir a inventario creativo
minetest.register_craft({
    type = "shapeless",
    output = "code_blocks:programming_terminal 9",
    recipe = {"default:dirt"}  -- Solo para testing - eliminar en producción
})

minetest.register_craft({
    type = "shapeless", 
    output = "code_blocks:code_server 9",
    recipe = {"default:sand"}  -- Solo para testing - eliminar en producción
})

minetest.register_craft({
    type = "shapeless",
    output = "code_blocks:result_monitor 9", 
    recipe = {"default:gravel"}  -- Solo para testing - eliminar en producción
})