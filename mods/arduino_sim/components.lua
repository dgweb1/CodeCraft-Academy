--[[
Components.lua - Componentes virtuales para Arduino
--]]

local components = {}

-- Conectar LED al Arduino más cercano
function components.connect_led(led_pos, player_name)
    -- Buscar Arduino cerca (radio de 5 bloques)
    local arduino_pos = nil
    local min_dist = 6
    
    for dx = -5, 5 do
        for dy = -2, 2 do
            for dz = -5, 5 do
                local check_pos = {
                    x = led_pos.x + dx,
                    y = led_pos.y + dy,  
                    z = led_pos.z + dz
                }
                
                local node = minetest.get_node(check_pos)
                if node.name == "arduino_sim:arduino_uno" then
                    local dist = vector.distance(led_pos, check_pos)
                    if dist < min_dist then
                        arduino_pos = check_pos
                        min_dist = dist
                    end
                end
            end
        end
    end
    
    if arduino_pos then
        local meta = minetest.get_meta(led_pos)
        meta:set_string("connected_arduino", minetest.pos_to_string(arduino_pos))
        meta:set_string("infotext", "🔴 LED conectado al Arduino")
        
        minetest.chat_send_player(player_name, 
            "🔴 LED conectado al Arduino (distancia: " .. 
            string.format("%.1f", min_dist) .. " bloques)")
    else
        minetest.chat_send_player(player_name, 
            "❌ No hay Arduino cerca. Coloca uno a menos de 5 bloques")
    end
end

-- Controlar LED desde Arduino  
function components.control_led(arduino_pos, pin, state)
    -- Buscar LEDs conectados a este Arduino
    local led_positions = components.find_connected_leds(arduino_pos)
    
    for _, led_pos in ipairs(led_positions) do
        local node = minetest.get_node(led_pos)
        local new_light = (state == "HIGH") and 10 or 0
        
        -- Actualizar intensidad de luz
        minetest.swap_node(led_pos, {
            name = node.name,
            param1 = new_light,
            param2 = node.param2
        })
        
        -- Cambiar infotext
        local meta = minetest.get_meta(led_pos)
        local status = (state == "HIGH") and "ENCENDIDO" or "APAGADO" 
        meta:set_string("infotext", "🔴 LED " .. status .. " (Pin " .. pin .. ")")
    end
end

-- Encontrar LEDs conectados
function components.find_connected_leds(arduino_pos)
    local arduino_str = minetest.pos_to_string(arduino_pos)
    local connected_leds = {}
    
    -- Buscar en área cercana
    for dx = -5, 5 do
        for dy = -2, 2 do
            for dz = -5, 5 do
                local check_pos = {
                    x = arduino_pos.x + dx,
                    y = arduino_pos.y + dy,
                    z = arduino_pos.z + dz  
                }
                
                local node = minetest.get_node(check_pos)
                if node.name == "arduino_sim:led_red" then
                    local meta = minetest.get_meta(check_pos)
                    local connected_to = meta:get_string("connected_arduino")
                    
                    if connected_to == arduino_str then
                        table.insert(connected_leds, check_pos)
                    end
                end
            end
        end
    end
    
    return connected_leds
end

arduino_sim.components = components