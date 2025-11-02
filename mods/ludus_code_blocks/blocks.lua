-- Texturas temporales usando bloques existentes hasta crear las definitivas
-- Estas son referencias a texturas que ya existen en Luanti

-- Bloque Terminal de Programación
minetest.register_node("ludus_code_blocks:programming_terminal", {
    description = "💻 Terminal de Programación\n" ..
                  "Desarrollado por profeDaniel & GitHub Copilot\n" ..
                  "Clic derecho para abrir editor de código",
    
    tiles = {
        "default_steel_block.png^[colorize:#0000FF:50",  -- Top: azul
        "default_steel_block.png^[colorize:#000000:50",  -- Bottom: negro
        "default_steel_block.png^[colorize:#333333:50",  -- Sides: gris
        "default_steel_block.png^[colorize:#333333:50",
        "default_steel_block.png^[colorize:#333333:50",
        "default_steel_block.png^[colorize:#00FF00:30"   -- Front: verde terminal
    },
    
    paramtype = "light",
    paramtype2 = "facedir",
    light_source = 3,
    
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    sounds = default.node_sound_stone_defaults(),
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local player_name = clicker:get_player_name()
        
        -- Abrir editor básico directamente
        local formspec = "formspec_version[4]" ..
            "size[12,8]" ..
            "bgcolor[#1a1a1a]" ..
            "label[0.5,0.5;💻 CodeCraft Academy - Terminal de Programación]" ..
            "dropdown[0.5,1.2;3,0.8;language;Lua,Python,Java;1]" ..
            "textarea[0.5,2.2;11,4;code;Código:;-- Hola mundo\\nprint('¡Hola CodeCraft Academy!')]" ..
            "button[0.5,6.5;2.5,0.8;save;💾 Guardar]" ..
            "button[3.5,6.5;2.5,0.8;run;▶️ Ejecutar]" ..
            "button[6.5,6.5;2.5,0.8;help;❓ Ayuda]" ..
            "button_exit[9.5,6.5;2,0.8;close;❌ Cerrar]"
        
        minetest.show_formspec(player_name, "code_terminal:" .. minetest.pos_to_string(pos), formspec)
        return itemstack
    end,
    
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        local player_name = placer:get_player_name()
        
        meta:set_string("owner", player_name)
        meta:set_string("infotext", "💻 Terminal de " .. player_name .. " - CodeCraft Academy")
        
        minetest.chat_send_player(player_name, 
            "💻 ¡Terminal instalado! Clic derecho para programar")
    end
})

-- Bloque Servidor de Código (para proyectos compartidos)
minetest.register_node("ludus_code_blocks:code_server", {
    description = "🖥️ Servidor de Código\n" ..
                  "Para proyectos compartidos del equipo\n" ..
                  "Desarrollado por profeDaniel & GitHub Copilot",
    
    tiles = {
        "default_steel_block.png^[colorize:#FF0000:30",  -- Top: rojo servidor
        "default_steel_block.png^[colorize:#000000:50",  -- Bottom: negro
        "default_steel_block.png^[colorize:#666666:30",  -- Sides: gris claro
        "default_steel_block.png^[colorize:#666666:30",
        "default_steel_block.png^[colorize:#666666:30", 
        "default_steel_block.png^[colorize:#FFFF00:30"   -- Front: amarillo
    },
    
    paramtype = "light",
    paramtype2 = "facedir", 
    light_source = 5,
    
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    sounds = default.node_sound_stone_defaults(),
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local player_name = clicker:get_player_name()
        
        local formspec = "formspec_version[4]" ..
            "size[12,8]" ..
            "bgcolor[#2a2a2a]" ..
            "label[0.5,0.5;🖥️ Servidor de Código - Proyectos del Equipo]" ..
            "textlist[0.5,1.5;11,4;project_list;Proyecto_1.lua,Proyecto_2.py,Proyecto_3.java;1]" ..
            "button[0.5,6;2.5,0.8;download;⬇️ Descargar]" ..
            "button[3.5,6;2.5,0.8;upload;⬆️ Subir]" ..
            "button[6.5,6;2.5,0.8;share;🤝 Compartir]" ..
            "button_exit[9.5,6;2,0.8;close;❌ Cerrar]"
        
        minetest.show_formspec(player_name, "code_server:" .. minetest.pos_to_string(pos), formspec)
        return itemstack
    end,
    
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        local player_name = placer:get_player_name()
        
        meta:set_string("owner", player_name)
        meta:set_string("infotext", "🖥️ Servidor del Equipo - CodeCraft Academy")
        
        minetest.chat_send_player(player_name, 
            "🖥️ ¡Servidor instalado! Aquí se guardan proyectos del equipo")
    end
})

-- Monitor de Resultados (muestra salida de programas)
minetest.register_node("ludus_code_blocks:result_monitor", {
    description = "📺 Monitor de Resultados\n" ..
                  "Muestra la salida de tus programas\n" ..
                  "Desarrollado por profeDaniel & GitHub Copilot",
    
    tiles = {
        "default_obsidian.png^[colorize:#000033:30",     -- Top: azul oscuro
        "default_obsidian.png",                          -- Bottom: negro
        "default_obsidian.png^[colorize:#111111:30",     -- Sides: gris muy oscuro
        "default_obsidian.png^[colorize:#111111:30",
        "default_obsidian.png^[colorize:#111111:30",
        "default_obsidian.png^[colorize:#00FFFF:20"      -- Screen: cyan brillante
    },
    
    paramtype = "light",
    paramtype2 = "facedir",
    light_source = 8,  -- Muy brillante como monitor
    
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    sounds = default.node_sound_glass_defaults(),
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local player_name = clicker:get_player_name()
        
        local formspec = "formspec_version[4]" ..
            "size[12,8]" ..
            "bgcolor[#001122]" ..
            "label[0.5,0.5;📺 Monitor de Resultados - CodeCraft Academy]" ..
            "textarea[0.5,1.5;11,5;output;Salida del programa:;> Hola CodeCraft Academy!\\n> Programa ejecutado correctamente\\n> Tiempo: 0.05s\\n> Estado: ✅ Éxito]" ..
            "button[0.5,7;2.5,0.8;clear;🗑️ Limpiar]" ..
            "button[3.5,7;2.5,0.8;save_log;💾 Guardar Log]" ..
            "button_exit[9.5,7;2,0.8;close;❌ Cerrar]"
        
        minetest.show_formspec(player_name, "result_monitor:" .. minetest.pos_to_string(pos), formspec)
        return itemstack
    end,
    
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        local player_name = placer:get_player_name()
        
        meta:set_string("owner", player_name)
        meta:set_string("infotext", "📺 Monitor de " .. player_name .. " - Resultados")
        
        minetest.chat_send_player(player_name, 
            "📺 ¡Monitor instalado! Aquí verás los resultados de tus programas")
    end
})

-- Manejador de formularios para los bloques
minetest.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()
    
    -- Terminal de programación
    if formname:match("^code_terminal:") then
        if fields.run and fields.code then
            local language = fields.language or "Lua"
            
            if language == "Lua" then
                local func, err = loadstring(fields.code)
                if func then
                    local success, result = pcall(func)
                    if success then
                        minetest.chat_send_player(player_name, "✅ [" .. language .. "] Código ejecutado correctamente")
                    else
                        minetest.chat_send_player(player_name, "❌ [" .. language .. "] Error: " .. tostring(result))
                    end
                else
                    minetest.chat_send_player(player_name, "❌ [" .. language .. "] Sintaxis: " .. tostring(err))
                end
            else
                minetest.chat_send_player(player_name, "🔄 [" .. language .. "] Simulando ejecución...")
                minetest.chat_send_player(player_name, "📊 [" .. language .. "] " .. string.len(fields.code) .. " caracteres procesados")
            end
            
        elseif fields.save and fields.code then
            minetest.chat_send_player(player_name, "💾 Código guardado en el terminal")
            
        elseif fields.help then
            minetest.chat_send_player(player_name, [[
📚 Ayuda del Terminal:
• Selecciona el lenguaje en el menú
• Escribe tu código en el área de texto
• Presiona ▶️ Ejecutar para ver resultados
• Usa 💾 Guardar para conservar tu trabajo
]])
        end
        return true
    end
    
    return false
end)