--[[
Simulator.lua - Motor de simulación Arduino
--]]

local simulator = {}

-- Manejador para formularios del IDE Arduino
minetest.register_on_player_receive_fields(function(player, formname, fields)
    local player_name = player:get_player_name()
    
    -- IDE Arduino
    local arduino_pos_str = formname:match("^arduino_ide:(.+)$")
    if arduino_pos_str then
        local arduino_pos = minetest.string_to_pos(arduino_pos_str)
        if not arduino_pos then return false end
        
        local meta = minetest.get_meta(arduino_pos)
        
        if fields.btn_verify and fields.arduino_code then
            -- Verificar código (análisis básico de sintaxis)
            local errors = simulator.verify_code(fields.arduino_code)
            if #errors == 0 then
                minetest.chat_send_player(player_name, "✅ Código verificado - Sin errores")
            else  
                minetest.chat_send_player(player_name, "❌ Errores encontrados:")
                for _, error in ipairs(errors) do
                    minetest.chat_send_player(player_name, "  • " .. error)
                end
            end
            
        elseif fields.btn_upload and fields.arduino_code then
            -- Subir código al Arduino
            meta:set_string("program", fields.arduino_code)
            minetest.chat_send_player(player_name, "⬆️ Código subido al Arduino correctamente")
            
        elseif fields.btn_simulate and fields.arduino_code then
            -- Ejecutar simulación
            local success, result = arduino_sim.editor.simulate_arduino(
                fields.arduino_code, player_name, arduino_pos)
            
            if success then
                minetest.chat_send_player(player_name, "▶️ Simulación iniciada")
            else
                minetest.chat_send_player(player_name, "❌ Error en simulación: " .. result)
            end
            
        elseif fields.btn_stop then
            -- Parar simulación
            simulator.stop_simulation(arduino_pos)
            minetest.chat_send_player(player_name, "⏹️ Simulación detenida")
            
        elseif fields.btn_examples then
            -- Mostrar menú de ejemplos
            simulator.show_examples_menu(player_name, arduino_pos)
        end
        
        return true
    end
    
    -- Menú de ejemplos
    local examples_pos_str = formname:match("^arduino_examples:(.+)$")
    if examples_pos_str then
        local arduino_pos = minetest.string_to_pos(examples_pos_str)
        if not arduino_pos then return false end
        
        -- Cargar ejemplo seleccionado
        for example_key, example in pairs(arduino_sim.editor.examples) do
            if fields["example_" .. example_key] then
                local meta = minetest.get_meta(arduino_pos)
                meta:set_string("program", example.code)
                
                minetest.chat_send_player(player_name, 
                    "📚 Ejemplo '" .. example.name .. "' cargado")
                
                -- Volver al IDE con el ejemplo cargado
                arduino_sim.editor.show_arduino_ide(player_name, arduino_pos)
                break
            end
        end
        
        return true
    end
    
    return false
end)

-- Verificar código Arduino (básico)
function simulator.verify_code(code)
    local errors = {}
    
    -- Verificar que tenga setup() y loop()
    if not code:match("void%s+setup%s*%(") then
        table.insert(errors, "Falta función setup()")
    end
    
    if not code:match("void%s+loop%s*%(") then
        table.insert(errors, "Falta función loop()")  
    end
    
    -- Verificar llaves balanceadas
    local open_braces = 0
    for char in code:gmatch(".") do
        if char == "{" then
            open_braces = open_braces + 1
        elseif char == "}" then
            open_braces = open_braces - 1
        end
    end
    
    if open_braces ~= 0 then
        table.insert(errors, "Llaves {} desbalanceadas")
    end
    
    -- Verificar paréntesis balanceados
    local open_parens = 0
    for char in code:gmatch(".") do
        if char == "(" then
            open_parens = open_parens + 1
        elseif char == ")" then
            open_parens = open_parens - 1
        end
    end
    
    if open_parens ~= 0 then
        table.insert(errors, "Paréntesis () desbalanceados")
    end
    
    return errors
end

-- Mostrar menú de ejemplos
function simulator.show_examples_menu(player_name, arduino_pos)
    local pos_str = minetest.pos_to_string(arduino_pos)
    
    local formspec = "formspec_version[4]" ..
        "size[10,8]" ..
        "bgcolor[#2a2a2a]" ..
        "label[0.5,0.5;📚 Ejemplos de Arduino - CodeCraft Academy]" ..
        
        "button[0.5,2;9,0.8;example_blink;💡 LED Parpadeante - Básico]" ..
        "button[0.5,3;9,0.8;example_fade;🌟 LED con Fade - Intermedio]" ..
        "button[0.5,4;9,0.8;example_button;🔘 Botón y LED - Interactivo]" ..
        
        "label[0.5,5.2;Próximamente:]" ..
        "label[0.5,5.8;• Sensor de temperatura]" ..
        "label[0.5,6.3;• Servomotor controlado]" ..
        "label[0.5,6.8;• Comunicación serie]" ..
        
        "button_exit[7,7.2;2.5,0.8;btn_back;⬅️ Volver]"
    
    minetest.show_formspec(player_name, "arduino_examples:" .. pos_str, formspec)
end

-- Detener simulación
function simulator.stop_simulation(arduino_pos)
    -- Apagar todos los LEDs conectados
    arduino_sim.components.control_led(arduino_pos, "all", "LOW")
    
    -- Reset del Arduino visual
    local node = minetest.get_node(arduino_pos)
    minetest.swap_node(arduino_pos, {
        name = node.name,
        param1 = 4,  -- Luz base
        param2 = node.param2
    })
end

arduino_sim.simulator = simulator