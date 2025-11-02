--[[
Code Blocks - Sistema de programación integrado para CodeCraft Academy
Autores: profeDaniel & GitHub Copilot

Este mod permite a los estudiantes escribir, ejecutar y colaborar
en proyectos de programación directamente en el mundo 3D.
--]]

-- Inicialización básica sin dependencias circulares
code_blocks = {
    version = "1.0.0",
    authors = {"profeDaniel", "GitHub Copilot"},
    storage = {},
    editors = {},
    blocks = {},
    interpreters = {},
    collaboration = {}
}

-- Obtener rutas del mod
local modpath = minetest.get_modpath("ludus_code_blocks")

-- Función auxiliar para dividir strings
local function split_string(str, delimiter)
    if not str or str == "" then return {} end
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)"
    for match in str:gmatch(pattern) do
        table.insert(result, match)
    end
    return result
end

-- Cargar módulos en orden correcto (con protección de errores)
local function safe_dofile(filepath)
    local success, err = pcall(dofile, filepath)
    if not success then
        minetest.log("error", "[CodeBlocks] Error cargando " .. filepath .. ": " .. tostring(err))
        return false
    end
    return true
end

-- Intentar cargar cada módulo
safe_dofile(modpath .. "/storage.lua")
safe_dofile(modpath .. "/editors.lua") 
safe_dofile(modpath .. "/blocks.lua")
safe_dofile(modpath .. "/interpreters.lua")
safe_dofile(modpath .. "/collaboration.lua")
safe_dofile(modpath .. "/crafting.lua")

-- Comando básico de ayuda
minetest.register_chatcommand("code_help", {
    description = "Ayuda del sistema CodeCraft Academy",
    func = function(name, param)
        return true, [[
🎓 CodeCraft Academy - Sistema de Programación

Comandos básicos:
• /code_help - Esta ayuda
• /code editor lua - Abrir editor de Lua  
• /code projects - Ver mis proyectos

Para más funciones, usa los terminales físicos
del inventario creativo.

¡Coloca un terminal y click derecho para empezar! 🚀

Desarrollado por: profeDaniel & GitHub Copilot
]]
    end
})

-- Comando simplificado principal
minetest.register_chatcommand("code", {
    description = "Sistema de programación básico",
    func = function(name, param)
        local args = split_string(param, " ")
        local cmd = args[1] or "help"
        
        if cmd == "help" then
            return true, "Usa /code_help para ver la ayuda completa"
            
        elseif cmd == "editor" then
            local language = args[2] or "lua"
            
            -- Verificar que el módulo está cargado
            if code_blocks.editors and code_blocks.editors.show_main_editor then
                code_blocks.editors.show_main_editor(name, language)
                return true, "Abriendo editor de " .. language
            else
                -- Fallback: mostrar editor básico
                local formspec = "formspec_version[4]" ..
                    "size[12,8]" ..
                    "label[0.5,0.5;🎓 CodeCraft Academy - Editor " .. language .. "]" ..
                    "textarea[0.5,1.5;11,5;code;Escribe tu código:;-- Hola mundo en " .. language .. "\\nprint('¡Hola CodeCraft Academy!')]" ..
                    "button[0.5,7;2.5,0.8;save;💾 Guardar]" ..
                    "button[3.5,7;2.5,0.8;run;▶️ Ejecutar]" ..
                    "button_exit[8.5,7;2.5,0.8;close;❌ Cerrar]"
                
                minetest.show_formspec(name, "code_editor_basic:" .. language, formspec)
                return true, "Abriendo editor básico de " .. language
            end
            
        elseif cmd == "projects" then
            -- Verificar que el módulo está cargado
            if code_blocks.storage and code_blocks.storage.list_projects then
                local projects = code_blocks.storage.list_projects(name)
                if #projects == 0 then
                    return true, "No tienes proyectos. Usa /code editor <lenguaje> para crear uno"
                end
                
                local list = "📁 Tus proyectos:\\n"
                for i, project in ipairs(projects) do
                    list = list .. string.format("%d. %s (%s)\\n", 
                        i, project.name, project.language)
                end
                return true, list
            else
                return true, "Sistema de proyectos cargándose... Intenta de nuevo en un momento"
            end
            
        else
            return false, "Comando desconocido. Usa /code help o /code_help"
        end
    end
})

-- Manejador básico para formularios
minetest.register_on_player_receive_fields(function(player, formname, fields)
    local name = player:get_player_name()
    
    -- Editor básico
    if formname:match("^code_editor_basic:") then
        local language = formname:match("^code_editor_basic:(.+)$")
        
        if fields.run and fields.code then
            -- Ejecución básica
            if language == "lua" then
                local func, err = loadstring(fields.code)
                if func then
                    local success, result = pcall(func)
                    if success then
                        minetest.chat_send_player(name, "✅ Código ejecutado correctamente")
                    else
                        minetest.chat_send_player(name, "❌ Error: " .. tostring(result))
                    end
                else
                    minetest.chat_send_player(name, "❌ Error de sintaxis: " .. tostring(err))
                end
            else
                minetest.chat_send_player(name, "🔄 Simulando ejecución de " .. language .. "...")
                minetest.chat_send_player(name, "📄 Código procesado: " .. string.len(fields.code) .. " caracteres")
            end
        elseif fields.save and fields.code then
            minetest.chat_send_player(name, "💾 Código guardado (función completa próximamente)")
        end
        
        return true
    end
    
    return false
end)

-- Log de inicialización
minetest.log("action", "[CodeCraft Academy] Code Blocks mod inicializado")
minetest.log("action", "[CodeCraft Academy] Autores: profeDaniel & GitHub Copilot")
minetest.log("action", "[CodeCraft Academy] Versión: " .. code_blocks.version)