--[[
Editors.lua - Interfaces gráficas para editar código
Maneja formspecs para diferentes lenguajes de programación
--]]

local editors = {}

-- Configuración de colores para syntax highlighting básico
local colors = {
    keyword = "#569CD6",    -- Azul para palabras clave
    string = "#D69E2E",     -- Amarillo para strings
    comment = "#6A9955",    -- Verde para comentarios
    number = "#B5CEA8",     -- Verde claro para números
    normal = "#D4D4D4"      -- Blanco para texto normal
}

-- Plantillas de código por lenguaje
local templates = {
    lua = [[-- Mi primer programa en Lua
print("¡Hola, CodeCraft Academy!")

-- Variables
local nombre = "Estudiante"
local edad = 15

-- Función simple
function saludar(persona)
    return "Hola " .. persona .. "!"
end

-- Llamar función
local mensaje = saludar(nombre)
print(mensaje)]],

    python = [[# Mi primer programa en Python
print("¡Hola, CodeCraft Academy!")

# Variables
nombre = "Estudiante"
edad = 15

# Función simple
def saludar(persona):
    return f"Hola {persona}!"

# Llamar función
mensaje = saludar(nombre)
print(mensaje)]]
}

-- Crear formspec del editor de código
function editors.create_editor_formspec(player_name, project_name)
    local project = code_blocks.storage.get_project(player_name, project_name)
    if not project then
        return "size[10,8]label[2,1;Proyecto no encontrado]"
    end
    
    local code = project.code
    if code == "" and templates[project.language] then
        code = templates[project.language]
    end
    
    -- Escapar el código para formspec
    code = minetest.formspec_escape(code)
    
    local formspec = "formspec_version[4]" ..
        "size[16,12]" ..
        "bgcolor[#1E1E1E]" ..  -- Fondo oscuro tipo IDE
        
        -- Título
        "label[0.5,0.5;💻 CodeCraft Academy - Editor de Código]" ..
        "label[0.5,1;" .. minetest.colorize("#4FC3F7", "Proyecto: " .. project.name .. " (" .. project.language .. ")") .. "]" ..
        
        -- Área de código principal
        "textarea[0.5,2;15,7;code_input;Código:;" .. code .. "]" ..
        
        -- Botones de acción
        "button[0.5,9.5;2.5,0.8;btn_run;▶ Ejecutar]" ..
        "button[3.2,9.5;2.5,0.8;btn_save;💾 Guardar]" ..
        "button[5.9,9.5;2.5,0.8;btn_share;🔗 Compartir]" ..
        "button[8.6,9.5;2.5,0.8;btn_help;❓ Ayuda]" ..
        "button_exit[13.5,9.5;2,0.8;btn_close;✖ Cerrar]" ..
        
        -- Área de salida/resultados
        "label[0.5,10.7;📤 Salida del programa:]" ..
        "textarea[0.5,11.2;15,2;output_area;;" .. minetest.formspec_escape(project.output or "") .. "]"
    
    return formspec
end

-- Manejar acciones del formspec
function editors.handle_editor_submit(player, formname, fields)
    local player_name = player:get_player_name()
    
    -- Extraer nombre del proyecto del formname
    local project_name = formname:match("^code_editor:(.+)$")
    if not project_name then
        return false
    end
    
    local project = code_blocks.storage.get_project(player_name, project_name)
    if not project then
        minetest.chat_send_player(player_name, "❌ Proyecto no encontrado")
        return true
    end
    
    -- Guardar código si se modificó
    if fields.code_input and fields.code_input ~= project.code then
        code_blocks.storage.update_project_code(player_name, project_name, fields.code_input)
    end
    
    -- Manejar botones
    if fields.btn_run then
        -- Ejecutar código
        local success, result = editors.execute_code(project.language, fields.code_input or project.code)
        project.output = result
        project.execution_count = (project.execution_count or 0) + 1
        code_blocks.storage.save_projects()
        
        -- Mostrar resultado en chat también
        if success then
            minetest.chat_send_player(player_name, "✅ Código ejecutado:")
            minetest.chat_send_player(player_name, result)
        else
            minetest.chat_send_player(player_name, "❌ Error de ejecución:")
            minetest.chat_send_player(player_name, result)
        end
        
        -- Reabrir editor con nueva salida
        minetest.show_formspec(player_name, "code_editor:" .. project_name,
            editors.create_editor_formspec(player_name, project_name))
        
    elseif fields.btn_save then
        minetest.chat_send_player(player_name, "💾 Proyecto guardado exitosamente")
        
    elseif fields.btn_share then
        minetest.show_formspec(player_name, "code_share:" .. project_name, 
            editors.create_share_formspec(project_name))
        
    elseif fields.btn_help then
        minetest.chat_send_player(player_name, editors.get_language_help(project.language))
        
    elseif fields.btn_close then
        minetest.close_formspec(player_name, formname)
    end
    
    return true
end

-- Ejecutar código según el lenguaje
function editors.execute_code(language, code)
    if language == "lua" then
        return editors.execute_lua(code)
    elseif language == "python" then
        return editors.execute_python_sim(code)
    else
        return false, "Lenguaje no soportado: " .. language
    end
end

-- Ejecutar código Lua (nativo)
function editors.execute_lua(code)
    local env = {
        -- Entorno sandboxed para seguridad
        print = function(...)
            local args = {...}
            local output = ""
            for i, v in ipairs(args) do
                if i > 1 then output = output .. "\t" end
                output = output .. tostring(v)
            end
            return output
        end,
        math = math,
        string = string,
        table = table,
        pairs = pairs,
        ipairs = ipairs,
        tonumber = tonumber,
        tostring = tostring,
        type = type
    }
    
    -- Capturar salida de print
    local output_lines = {}
    env.print = function(...)
        local args = {...}
        local line = ""
        for i, v in ipairs(args) do
            if i > 1 then line = line .. "\t" end
            line = line .. tostring(v)
        end
        table.insert(output_lines, line)
    end
    
    -- Compilar y ejecutar código
    local chunk, compile_error = loadstring(code)
    if not chunk then
        return false, "Error de sintaxis: " .. compile_error
    end
    
    -- Ejecutar en entorno controlado
    setfenv(chunk, env)
    local success, runtime_error = pcall(chunk)
    
    if not success then
        return false, "Error de ejecución: " .. tostring(runtime_error)
    end
    
    local output = table.concat(output_lines, "\n")
    if output == "" then
        output = "(No hay salida)"
    end
    
    return true, output
end

-- Simulador básico de Python (convertir a Lua)
function editors.execute_python_sim(python_code)
    -- Simulador muy básico que traduce Python simple a Lua
    local lua_code = python_code
    
    -- Convertir sintaxis básica de Python a Lua
    lua_code = lua_code:gsub("def ([%w_]+)%(([^)]*)%)", "function %1(%2)")
    lua_code = lua_code:gsub("if ([^:]+):", "if %1 then")
    lua_code = lua_code:gsub("elif ([^:]+):", "elseif %1 then")
    lua_code = lua_code:gsub("else:", "else")
    lua_code = lua_code:gsub("for ([%w_]+) in range%((%d+)%):", "for %1 = 0, %2-1 do")
    lua_code = lua_code:gsub("return ([^\n]*)", "return %1")
    
    -- Agregar ends necesarios (aproximación)
    local function_count = 0
    local if_count = 0
    for line in lua_code:gmatch("[^\n]+") do
        if line:match("^%s*function") then function_count = function_count + 1 end
        if line:match("^%s*if") then if_count = if_count + 1 end
    end
    
    for i = 1, function_count do
        lua_code = lua_code .. "\nend"
    end
    for i = 1, if_count do
        lua_code = lua_code .. "\nend"
    end
    
    -- Ejecutar como Lua
    return editors.execute_lua(lua_code)
end

-- Formspec para compartir proyectos
function editors.create_share_formspec(project_name)
    return "formspec_version[4]" ..
        "size[8,4]" ..
        "bgcolor[#1E1E1E]" ..
        "label[1,0.5;🔗 Compartir Proyecto: " .. project_name .. "]" ..
        "field[1,1.5;6,0.8;target_player;;Nombre del jugador]" ..
        "button[1,2.8;2.5,0.8;btn_share_confirm;Compartir]" ..
        "button[4.5,2.8;2.5,0.8;btn_cancel;Cancelar]"
end

-- Ayuda por lenguaje
function editors.get_language_help(language)
    if language == "lua" then
        return [[
🔵 Ayuda de Lua:

Sintaxis básica:
• Variables: local nombre = "valor"
• Funciones: function miFuncion() ... end  
• Condicionales: if condicion then ... end
• Bucles: for i = 1, 10 do ... end
• Imprimir: print("texto")

Ejemplo:
local x = 5
if x > 3 then
    print("x es mayor que 3")
end
]]
    elseif language == "python" then
        return [[
🐍 Ayuda de Python (Simulado):

Sintaxis básica:
• Variables: nombre = "valor"
• Funciones: def mi_funcion(): ...
• Condicionales: if condicion: ...
• Bucles: for i in range(10): ...
• Imprimir: print("texto")

Ejemplo:
x = 5
if x > 3:
    print("x es mayor que 3")

Nota: Esta es una simulación básica de Python
]]
    end
    
    return "Ayuda no disponible para " .. language
end

-- API pública
code_blocks.editors = editors

-- Registrar manejador de formspecs
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname:match("^code_editor:") then
        return editors.handle_editor_submit(player, formname, fields)
    elseif formname:match("^code_share:") then
        local project_name = formname:match("^code_share:(.+)$")
        local player_name = player:get_player_name()
        
        if fields.btn_share_confirm and fields.target_player then
            local success, message = code_blocks.storage.share_project(
                player_name, project_name, fields.target_player)
            minetest.chat_send_player(player_name, 
                success and ("✅ " .. message) or ("❌ " .. message))
        end
        
        if fields.btn_share_confirm or fields.btn_cancel then
            minetest.close_formspec(player_name, formname)
        end
        
        return true
    end
    
    return false
end)