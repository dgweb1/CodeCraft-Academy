--[[
Storage.lua - Sistema de Archivos Virtual
Maneja el almacenamiento persistente de proyectos de código
--]]

local storage = {}
local worldpath = minetest.get_worldpath()
local projects_file = worldpath .. "/code_blocks_projects.json"

-- Cargar proyectos desde archivo
function storage.load_projects()
    local file = io.open(projects_file, "r")
    if not file then
        code_blocks.projects = {}
        return
    end
    
    local content = file:read("*all")
    file:close()
    
    local success, data = pcall(minetest.parse_json, content)
    if success and type(data) == "table" then
        code_blocks.projects = data
    else
        code_blocks.projects = {}
        minetest.log("warning", "[CodeBlocks] Error cargando proyectos, iniciando limpio")
    end
end

-- Guardar proyectos a archivo
function storage.save_projects()
    local file = io.open(projects_file, "w")
    if not file then
        minetest.log("error", "[CodeBlocks] No se pudo guardar proyectos")
        return false
    end
    
    file:write(minetest.write_json(code_blocks.projects))
    file:close()
    return true
end

-- Crear nuevo proyecto
function storage.create_project(player_name, project_name, language)
    if not code_blocks.projects[player_name] then
        code_blocks.projects[player_name] = {}
    end
    
    -- Verificar límites
    if #code_blocks.projects[player_name] >= code_blocks.config.max_projects then
        return false, "Has alcanzado el límite de " .. code_blocks.config.max_projects .. " proyectos"
    end
    
    -- Verificar si ya existe
    for _, project in ipairs(code_blocks.projects[player_name]) do
        if project.name == project_name then
            return false, "Ya tienes un proyecto llamado '" .. project_name .. "'"
        end
    end
    
    -- Crear proyecto
    local new_project = {
        name = project_name,
        language = language,
        created = os.time(),
        modified = os.time(),
        code = "",
        output = "",
        shared_with = {},
        execution_count = 0
    }
    
    table.insert(code_blocks.projects[player_name], new_project)
    storage.save_projects()
    
    return true, "Proyecto '" .. project_name .. "' creado exitosamente"
end

-- Obtener proyecto específico
function storage.get_project(player_name, project_name)
    if not code_blocks.projects[player_name] then
        return nil
    end
    
    for _, project in ipairs(code_blocks.projects[player_name]) do
        if project.name == project_name then
            return project
        end
    end
    
    return nil
end

-- Actualizar código del proyecto
function storage.update_project_code(player_name, project_name, new_code)
    local project = storage.get_project(player_name, project_name)
    if not project then
        return false, "Proyecto no encontrado"
    end
    
    project.code = new_code
    project.modified = os.time()
    storage.save_projects()
    
    return true, "Código actualizado"
end

-- Listar proyectos del jugador
function storage.list_projects(player_name)
    if not code_blocks.projects[player_name] then
        return {}
    end
    
    return code_blocks.projects[player_name]
end

-- Compartir proyecto con otro jugador
function storage.share_project(owner, project_name, target_player)
    local project = storage.get_project(owner, project_name)
    if not project then
        return false, "Proyecto no encontrado"
    end
    
    -- Verificar que el jugador objetivo existe
    local target_exists = false
    for _, player in ipairs(minetest.get_connected_players()) do
        if player:get_player_name() == target_player then
            target_exists = true
            break
        end
    end
    
    if not target_exists then
        return false, "Jugador '" .. target_player .. "' no encontrado"
    end
    
    -- Agregar a la lista de compartidos
    if not project.shared_with then
        project.shared_with = {}
    end
    
    table.insert(project.shared_with, target_player)
    storage.save_projects()
    
    -- Notificar al jugador objetivo
    minetest.chat_send_player(target_player, 
        "📩 " .. owner .. " ha compartido el proyecto '" .. project_name .. "' contigo")
    
    return true, "Proyecto compartido con " .. target_player
end

-- API pública
code_blocks.storage = storage

-- Cargar datos al inicio
storage.load_projects()

-- Comandos para gestión de proyectos
minetest.register_chatcommand("code_new", {
    description = "Crear nuevo proyecto de código",
    params = "<nombre> <lenguaje>",
    func = function(name, param)
        local project_name, language = param:match("^(%S+)%s+(%S+)$")
        if not project_name or not language then
            return false, "Uso: /code_new <nombre> <lenguaje> (lua|python)"
        end
        
        if not code_blocks.config.languages[language] then
            return false, "Lenguaje '" .. language .. "' no soportado. Disponibles: lua, python"
        end
        
        return storage.create_project(name, project_name, language)
    end
})

minetest.register_chatcommand("code_list", {
    description = "Listar tus proyectos de código",
    func = function(name, param)
        local projects = storage.list_projects(name)
        if #projects == 0 then
            return true, "No tienes proyectos aún. Usa /code_new <nombre> <lenguaje> para crear uno"
        end
        
        local list = "📁 Tus proyectos:\n"
        for i, project in ipairs(projects) do
            local modified_date = os.date("%d/%m %H:%M", project.modified)
            list = list .. string.format("%d. %s (%s) - %s\n", 
                i, project.name, project.language, modified_date)
        end
        
        return true, list
    end
})

minetest.register_chatcommand("code_share", {
    description = "Compartir proyecto con otro jugador",
    params = "<proyecto> <jugador>",
    func = function(name, param)
        local project_name, target_player = param:match("^(%S+)%s+(%S+)$")
        if not project_name or not target_player then
            return false, "Uso: /code_share <proyecto> <jugador>"
        end
        
        return storage.share_project(name, project_name, target_player)
    end
})