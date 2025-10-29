--[[
Collaboration.lua - Herramientas de colaboración para equipos
--]]

local collab = {}

-- Sistema de chat por equipos
collab.team_chats = {}

-- Enviar mensaje al equipo
function collab.send_team_message(player_name, message)
    local team = code_blocks.blocks.get_player_team(player_name)
    if not team then
        return false, "No perteneces a un equipo"
    end
    
    -- Obtener miembros del equipo
    local team_members = collab.get_team_members(team)
    
    -- Enviar mensaje a todos los miembros conectados
    local formatted_message = "[" .. team .. "] " .. player_name .. ": " .. message
    
    for _, member in ipairs(team_members) do
        if minetest.get_player_by_name(member) then
            minetest.chat_send_player(member, minetest.colorize("#90EE90", formatted_message))
        end
    end
    
    return true, "Mensaje enviado al equipo"
end

-- Obtener miembros del equipo
function collab.get_team_members(team)
    -- Integración con sistema de equipos existente
    if _G.equipos_api and _G.equipos_api.get_team_members then
        return _G.equipos_api.get_team_members(team)
    end
    
    -- Fallback: simular miembros
    local all_players = {}
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local player_team = code_blocks.blocks.get_player_team(name)
        if player_team == team then
            table.insert(all_players, name)
        end
    end
    
    return all_players
end

-- Sistema de revisión de código
function collab.request_code_review(reviewer, project_owner, project_name)
    local project = code_blocks.storage.get_project(project_owner, project_name)
    if not project then
        return false, "Proyecto no encontrado"
    end
    
    -- Verificar que el revisor esté conectado
    local reviewer_player = minetest.get_player_by_name(reviewer)
    if not reviewer_player then
        return false, "Revisor no encontrado o desconectado"
    end
    
    -- Enviar solicitud de revisión
    local message = string.format(
        "🔍 %s solicita revisión de código para '%s'\nUsa /code_review %s %s para revisar",
        project_owner, project_name, project_owner, project_name
    )
    
    minetest.chat_send_player(reviewer, minetest.colorize("#FFD700", message))
    
    return true, "Solicitud de revisión enviada a " .. reviewer
end

-- Ver código para revisión
function collab.show_code_for_review(reviewer_name, project_owner, project_name)
    local project = code_blocks.storage.get_project(project_owner, project_name)
    if not project then
        return false, "Proyecto no encontrado"
    end
    
    -- Crear formspec de revisión
    local formspec = "formspec_version[4]" ..
        "size[16,12]" ..
        "bgcolor[#1E1E1E]" ..
        "label[1,0.5;🔍 Revisión de Código - " .. project.name .. " por " .. project_owner .. "]" ..
        "textarea[0.5,1.5;15,7;code_display;Código a revisar:;" .. 
        minetest.formspec_escape(project.code) .. "]" ..
        "textarea[0.5,9;15,2;review_comments;Comentarios de revisión:;]" ..
        "button[0.5,11.5;3,0.8;btn_approve;✅ Aprobar]" ..
        "button[4,11.5;3,0.8;btn_suggest;💡 Sugerir cambios]" ..
        "button[7.5,11.5;3,0.8;btn_reject;❌ Rechazar]" ..
        "button_exit[11,11.5;2.5,0.8;btn_close;Cerrar]"
    
    minetest.show_formspec(reviewer_name, "code_review:" .. project_owner .. ":" .. project_name, formspec)
    return true, "Mostrando código para revisión"
end

-- Comandos de colaboración
minetest.register_chatcommand("team_chat", {
    description = "Enviar mensaje al equipo",
    params = "<mensaje>",
    func = function(name, param)
        if param == "" then
            return false, "Uso: /team_chat <mensaje>"
        end
        
        return collab.send_team_message(name, param)
    end
})

minetest.register_chatcommand("code_review", {
    description = "Revisar código de un compañero",
    params = "<propietario> <proyecto>",
    func = function(name, param)
        local owner, project = param:match("^(%S+)%s+(.+)$")
        if not owner or not project then
            return false, "Uso: /code_review <propietario> <proyecto>"
        end
        
        return collab.show_code_for_review(name, owner, project)
    end
})

minetest.register_chatcommand("request_review", {
    description = "Solicitar revisión de código",
    params = "<revisor> <proyecto>",
    func = function(name, param)
        local reviewer, project = param:match("^(%S+)%s+(.+)$")
        if not reviewer or not project then
            return false, "Uso: /request_review <revisor> <proyecto>"
        end
        
        return collab.request_code_review(reviewer, name, project)
    end
})

minetest.register_chatcommand("team_projects", {
    description = "Ver proyectos del equipo",
    func = function(name, param)
        local team = code_blocks.blocks.get_player_team(name)
        if not team then
            return false, "No perteneces a un equipo"
        end
        
        local members = collab.get_team_members(team)
        local team_projects = {}
        
        -- Recopilar proyectos de todos los miembros
        for _, member in ipairs(members) do
            local projects = code_blocks.storage.list_projects(member)
            for _, project in ipairs(projects) do
                table.insert(team_projects, {
                    owner = member,
                    name = project.name,
                    language = project.language,
                    modified = project.modified
                })
            end
        end
        
        if #team_projects == 0 then
            return true, "El equipo " .. team .. " no tiene proyectos aún"
        end
        
        -- Ordenar por fecha de modificación
        table.sort(team_projects, function(a, b)
            return a.modified > b.modified
        end)
        
        local list = "📁 Proyectos del " .. team .. ":\n"
        for i, project in ipairs(team_projects) do
            local date = os.date("%d/%m %H:%M", project.modified)
            list = list .. string.format("%d. %s/%s (%s) - %s\n",
                i, project.owner, project.name, project.language, date)
        end
        
        return true, list
    end
})

-- Comando para compartir pantalla (simulado)
minetest.register_chatcommand("share_screen", {
    description = "Compartir tu código con el equipo",
    params = "<proyecto>",
    func = function(name, param)
        if param == "" then
            return false, "Uso: /share_screen <proyecto>"
        end
        
        local project = code_blocks.storage.get_project(name, param)
        if not project then
            return false, "Proyecto '" .. param .. "' no encontrado"
        end
        
        local team = code_blocks.blocks.get_player_team(name)
        if not team then
            return false, "No perteneces a un equipo"
        end
        
        local members = collab.get_team_members(team)
        local code_preview = project.code:sub(1, 200) -- Primeras 200 caracteres
        if #project.code > 200 then
            code_preview = code_preview .. "..."
        end
        
        local message = string.format(
            "💻 %s está compartiendo '%s' (%s):\n%s",
            name, project.name, project.language, code_preview
        )
        
        for _, member in ipairs(members) do
            if member ~= name and minetest.get_player_by_name(member) then
                minetest.chat_send_player(member, minetest.colorize("#87CEEB", message))
            end
        end
        
        return true, "Código compartido con tu equipo"
    end
})

-- Manejador para formspecs de revisión
minetest.register_on_player_receive_fields(function(player, formname, fields)
    local reviewer_name = player:get_player_name()
    
    local owner, project_name = formname:match("^code_review:([^:]+):(.+)$")
    if owner and project_name then
        if fields.btn_approve then
            local message = string.format("✅ %s aprobó tu código en '%s'", reviewer_name, project_name)
            if fields.review_comments and fields.review_comments ~= "" then
                message = message .. "\nComentarios: " .. fields.review_comments
            end
            
            if minetest.get_player_by_name(owner) then
                minetest.chat_send_player(owner, minetest.colorize("#90EE90", message))
            end
            
            minetest.chat_send_player(reviewer_name, "✅ Revisión enviada: Código aprobado")
            
        elseif fields.btn_suggest then
            local comments = fields.review_comments or ""
            if comments == "" then
                minetest.chat_send_player(reviewer_name, "❌ Debes escribir comentarios para sugerir cambios")
                return true
            end
            
            local message = string.format("💡 %s sugiere cambios en '%s':\n%s", 
                reviewer_name, project_name, comments)
            
            if minetest.get_player_by_name(owner) then
                minetest.chat_send_player(owner, minetest.colorize("#FFD700", message))
            end
            
            minetest.chat_send_player(reviewer_name, "💡 Sugerencias enviadas")
            
        elseif fields.btn_reject then
            local comments = fields.review_comments or "Sin comentarios específicos"
            local message = string.format("❌ %s rechazó tu código en '%s':\n%s",
                reviewer_name, project_name, comments)
            
            if minetest.get_player_by_name(owner) then
                minetest.chat_send_player(owner, minetest.colorize("#FF6B6B", message))
            end
            
            minetest.chat_send_player(reviewer_name, "❌ Código rechazado, feedback enviado")
        end
        
        if fields.btn_approve or fields.btn_suggest or fields.btn_reject or fields.btn_close then
            minetest.close_formspec(reviewer_name, formname)
        end
        
        return true
    end
    
    return false
end)

-- API pública
code_blocks.collaboration = collab