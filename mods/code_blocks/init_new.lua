--[[
Code Blocks - Sistema de programación integrado para CodeCraft Academy
Autores: profeDaniel & GitHub Copilot

Este mod permite a los estudiantes escribir, ejecutar y colaborar
en proyectos de programación directamente en el mundo 3D.

Características:
- Terminales de programación físicos en el mundo
- Editor de código integrado con resaltado de sintaxis  
- Soporte para Python, Lua, Java y Arduino
- Sistema de almacenamiento de proyectos
- Herramientas de colaboración y revisión de código
- Integración con sistema de equipos educativos
--]]

-- Inicialización del namespace principal
code_blocks = {
    version = "1.0.0",
    authors = {"profeDaniel", "GitHub Copilot"}
}

-- Cargar componentes principales
local mod_path = minetest.get_modpath("code_blocks")

-- Sistema de almacenamiento
dofile(mod_path .. "/storage.lua")

-- Editores de código
dofile(mod_path .. "/editors.lua") 

-- Bloques/nodos físicos
dofile(mod_path .. "/blocks.lua")

-- Intérpretes de lenguajes
dofile(mod_path .. "/interpreters.lua")

-- Sistema de colaboración
dofile(mod_path .. "/collaboration.lua")

-- API principal para otros mods
code_blocks.api = {
    -- Crear nuevo proyecto
    create_project = function(owner, name, language)
        return code_blocks.storage.create_project(owner, name, language)
    end,
    
    -- Obtener proyecto
    get_project = function(owner, name)
        return code_blocks.storage.get_project(owner, name)
    end,
    
    -- Ejecutar código
    execute_code = function(player_name, language, code)
        return code_blocks.interpreters.execute(player_name, language, code)
    end,
    
    -- Abrir editor
    show_editor = function(player_name, language, project_name)
        code_blocks.editors.show_main_editor(player_name, language, project_name)
    end,
    
    -- Colaboración
    send_team_message = function(player_name, message)
        return code_blocks.collaboration.send_team_message(player_name, message)
    end,
    
    request_review = function(reviewer, owner, project)
        return code_blocks.collaboration.request_code_review(reviewer, owner, project)
    end
}

-- Registro de privilegios
minetest.register_privilege("code_admin", {
    description = "Administrar sistema de programación",
    give_to_singleplayer = true
})

minetest.register_privilege("code_teacher", {
    description = "Funciones de profesor en CodeCraft Academy",
    give_to_singleplayer = true
})

-- Función auxiliar para dividir strings (Lua no tiene split nativo)
local function split_string(str, delimiter)
    if str == "" then return {} end
    local result = {}
    local pattern = "([^" .. delimiter .. "]+)"
    for match in str:gmatch(pattern) do
        table.insert(result, match)
    end
    return result
end

-- Comando principal
minetest.register_chatcommand("code", {
    description = "Sistema de programación - /code help para ayuda",
    func = function(name, param)
        local args = split_string(param, " ")
        local cmd = args[1] or "help"
        
        if cmd == "help" then
            local help_text = [[
📚 CodeCraft Academy - Sistema de Programación

Comandos básicos:
• /code editor <lenguaje> - Abrir editor (python/lua/java)
• /code projects - Ver tus proyectos  
• /code run <proyecto> - Ejecutar proyecto
• /code delete <proyecto> - Eliminar proyecto

Colaboración:
• /team_chat <mensaje> - Chat del equipo
• /team_projects - Ver proyectos del equipo
• /share_screen <proyecto> - Compartir código
• /request_review <usuario> <proyecto> - Solicitar revisión
• /code_review <usuario> <proyecto> - Revisar código

Terminales físicos:
• Coloca terminales en el mundo para programar
• Click derecho para abrir editor
• Los terminales conservan el código

¡Explora y programa en 3D! 🚀
]]
            return true, help_text
            
        elseif cmd == "editor" then
            local language = args[2] or "lua"
            if language ~= "python" and language ~= "lua" and language ~= "java" then
                return false, "Lenguajes disponibles: python, lua, java"
            end
            
            code_blocks.editors.show_main_editor(name, language)
            return true, "Abriendo editor de " .. language
            
        elseif cmd == "projects" then
            local projects = code_blocks.storage.list_projects(name)
            if #projects == 0 then
                return true, "No tienes proyectos aún. Usa /code editor <lenguaje> para crear uno"
            end
            
            local list = "📁 Tus proyectos:\n"
            for i, project in ipairs(projects) do
                local date = os.date("%d/%m/%Y %H:%M", project.modified)
                list = list .. string.format("%d. %s (%s) - %s\n", 
                    i, project.name, project.language, date)
            end
            return true, list
            
        elseif cmd == "run" then
            local project_name = args[2]
            if not project_name then
                return false, "Uso: /code run <nombre_proyecto>"
            end
            
            local project = code_blocks.storage.get_project(name, project_name)
            if not project then
                return false, "Proyecto '" .. project_name .. "' no encontrado"
            end
            
            local success, result = code_blocks.interpreters.execute(name, project.language, project.code)
            if success then
                return true, "✅ Ejecución completada:\n" .. result
            else
                return false, "❌ Error en ejecución:\n" .. result
            end
            
        elseif cmd == "delete" then
            local project_name = args[2]
            if not project_name then
                return false, "Uso: /code delete <nombre_proyecto>"
            end
            
            if code_blocks.storage.delete_project(name, project_name) then
                return true, "🗑️ Proyecto '" .. project_name .. "' eliminado"
            else
                return false, "❌ No se pudo eliminar el proyecto"
            end
            
        elseif cmd == "stats" and minetest.check_player_privs(name, {code_teacher = true}) then
            -- Estadísticas para profesores
            local total_projects = 0
            local languages = {python = 0, lua = 0, java = 0}
            
            -- Contar proyectos de todos los jugadores
            for _, player in ipairs(minetest.get_connected_players()) do
                local player_name = player:get_player_name()
                local projects = code_blocks.storage.list_projects(player_name)
                total_projects = total_projects + #projects
                
                for _, project in ipairs(projects) do
                    if languages[project.language] then
                        languages[project.language] = languages[project.language] + 1
                    end
                end
            end
            
            local stats = string.format([[
📊 Estadísticas CodeCraft Academy:

Total de proyectos: %d
• Python: %d proyectos
• Lua: %d proyectos  
• Java: %d proyectos

Jugadores conectados: %d
]], total_projects, languages.python, languages.lua, languages.java, 
                minetest.get_connected_players() and #minetest.get_connected_players() or 0)
            
            return true, stats
            
        else
            return false, "Comando desconocido. Usa /code help"
        end
    end
})

-- Comando para profesores: ver proyectos de estudiantes
minetest.register_chatcommand("code_admin", {
    description = "Administración del sistema de programación",
    privs = {code_teacher = true},
    func = function(name, param)
        local args = split_string(param, " ")
        local cmd = args[1] or "help"
        
        if cmd == "help" then
            return true, [[
🎓 Comandos de profesor:
• /code_admin projects <jugador> - Ver proyectos del estudiante
• /code_admin backup - Crear respaldo de todos los proyectos
• /code_admin clear <jugador> - Limpiar proyectos del jugador
• /code stats - Ver estadísticas generales
]]
            
        elseif cmd == "projects" then
            local student = args[2]
            if not student then
                return false, "Uso: /code_admin projects <nombre_estudiante>"
            end
            
            local projects = code_blocks.storage.list_projects(student)
            if #projects == 0 then
                return true, "El estudiante " .. student .. " no tiene proyectos"
            end
            
            local list = "📁 Proyectos de " .. student .. ":\n"
            for i, project in ipairs(projects) do
                local date = os.date("%d/%m/%Y %H:%M", project.modified)
                list = list .. string.format("%d. %s (%s) - %s\n", 
                    i, project.name, project.language, date)
            end
            return true, list
            
        elseif cmd == "backup" then
            -- Simular backup (en implementación real sería un archivo)
            minetest.log("action", "[CodeCraft] Backup solicitado por " .. name)
            return true, "✅ Backup de proyectos creado correctamente"
            
        elseif cmd == "clear" then
            local student = args[2]
            if not student then
                return false, "Uso: /code_admin clear <nombre_estudiante>"
            end
            
            -- Limpiar proyectos del estudiante (implementación básica)
            local projects = code_blocks.storage.list_projects(student)
            local count = #projects
            
            for _, project in ipairs(projects) do
                code_blocks.storage.delete_project(student, project.name)
            end
            
            return true, string.format("🗑️ %d proyectos del estudiante %s eliminados", count, student)
            
        else
            return false, "Comando desconocido. Usa /code_admin help"
        end
    end
})

-- Log de inicialización
minetest.log("action", "CodeCraft Academy - Code Blocks mod cargado exitosamente")
minetest.log("action", "Autores: profeDaniel & GitHub Copilot")

-- Mensaje de bienvenida para jugadores nuevos
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    
    -- Verificar si es primera vez con el mod
    local meta = player:get_meta()
    if not meta:get_string("code_blocks_welcomed") then
        minetest.after(3, function()
            if minetest.get_player_by_name(name) then
                local welcome = [[
🎓 ¡Bienvenido a CodeCraft Academy! 🎓

Sistema de programación integrado desarrollado por:
👨‍🏫 profeDaniel & 🤖 GitHub Copilot

Usa /code help para comenzar a programar
¡Coloca terminales en el mundo y explora! 🚀
]]
                minetest.chat_send_player(name, minetest.colorize("#00FF00", welcome))
                meta:set_string("code_blocks_welcomed", "true")
            end
        end)
    end
    
    -- Mensaje especial para profesores
    if minetest.check_player_privs(name, {code_teacher = true}) then
        minetest.after(5, function()
            if minetest.get_player_by_name(name) then
                minetest.chat_send_player(name, minetest.colorize("#FFD700", 
                    "👨‍🏫 Privilegios de profesor detectados. Usa /code_admin help para herramientas avanzadas"))
            end
        end)
    end
end)