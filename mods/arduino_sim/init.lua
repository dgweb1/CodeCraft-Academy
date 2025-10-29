--[[
Arduino Simulator 3D - Sistema de simulación de Arduino para CodeCraft Academy
Autores: profeDaniel & GitHub Copilot

Este mod permite a los estudiantes:
- Programar Arduino virtual con código real
- Conectar componentes virtuales (LEDs, sensores, motores)
- Ver resultados en tiempo real en el mundo 3D
- Aprender electrónica de forma visual e interactiva
--]]

arduino_sim = {
    version = "1.0.0",
    authors = {"profeDaniel", "GitHub Copilot"}
}

local modpath = minetest.get_modpath("arduino_sim")

-- Cargar módulos
dofile(modpath .. "/components.lua")  -- Componentes virtuales
dofile(modpath .. "/boards.lua")     -- Placas Arduino
dofile(modpath .. "/editor.lua")     -- Editor de código Arduino
dofile(modpath .. "/simulator.lua")  -- Motor de simulación

-- Registro de bloques Arduino
minetest.register_node("arduino_sim:arduino_uno", {
    description = "🤖 Arduino UNO Virtual\n" ..
                  "Placa de desarrollo para aprender programación\n" ..
                  "Desarrollado por profeDaniel & GitHub Copilot",
    
    tiles = {
        "default_steel_block.png^[colorize:#0080FF:50",  -- Top: azul Arduino
        "default_steel_block.png^[colorize:#000000:50",  -- Bottom: negro
        "default_steel_block.png^[colorize:#008000:30",  -- Sides: verde PCB
        "default_steel_block.png^[colorize:#008000:30",
        "default_steel_block.png^[colorize:#008000:30",
        "default_steel_block.png^[colorize:#FFFF00:20"   -- Front: amarillo USB
    },
    
    paramtype = "light",
    paramtype2 = "facedir",
    light_source = 4,
    
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    sounds = default.node_sound_glass_defaults(),
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        local player_name = clicker:get_player_name()
        arduino_sim.editor.show_arduino_ide(player_name, pos)
        return itemstack
    end,
    
    after_place_node = function(pos, placer, itemstack, pointed_thing)
        local meta = minetest.get_meta(pos)
        local player_name = placer:get_player_name()
        
        meta:set_string("owner", player_name)
        meta:set_string("program", arduino_sim.editor.get_default_sketch())
        meta:set_string("infotext", "🤖 Arduino UNO de " .. player_name)
        
        minetest.chat_send_player(player_name, 
            "🤖 ¡Arduino UNO listo! Clic derecho para programar")
    end
})

-- LED Virtual
minetest.register_node("arduino_sim:led_red", {
    description = "🔴 LED Rojo Virtual\n" ..
                  "Conectable al Arduino - Pin digital",
    
    tiles = {"default_steel_block.png^[colorize:#FF0000:80"},
    paramtype = "light",
    light_source = 0,  -- Se enciende dinámicamente
    
    groups = {cracky = 2, oddly_breakable_by_hand = 2},
    sounds = default.node_sound_glass_defaults(),
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        -- Conectar/desconectar del Arduino cercano
        arduino_sim.components.connect_led(pos, clicker:get_player_name())
        return itemstack
    end
})

-- Registro básico de comandos
minetest.register_chatcommand("arduino_help", {
    description = "Ayuda del simulador Arduino",
    func = function(name, param)
        return true, [[
🤖 Arduino Simulator - CodeCraft Academy

Componentes disponibles:
• Arduino UNO - Placa principal de desarrollo
• LED Rojo - Luz indicadora programable  
• Sensor de Temperatura - Mide ambiente virtual
• Servomotor - Motor controlable por código

Uso básico:
1. Coloca un Arduino UNO
2. Coloca LEDs o sensores cerca
3. Clic derecho en Arduino para programar
4. Escribe código y ejecuta
5. ¡Ve los resultados en tiempo real!

Ejemplo código:
void setup() {
  pinMode(13, OUTPUT);  // LED en pin 13
}

void loop() {
  digitalWrite(13, HIGH);  // Encender LED
  delay(1000);            // Esperar 1 segundo
  digitalWrite(13, LOW);   // Apagar LED  
  delay(1000);            // Esperar 1 segundo
}

¡Desarrollado por profeDaniel & GitHub Copilot! 🚀
]]
    end
})

-- Log de inicialización
minetest.log("action", "[Arduino Simulator] Cargado exitosamente")
minetest.log("action", "[Arduino Simulator] Autores: profeDaniel & GitHub Copilot")