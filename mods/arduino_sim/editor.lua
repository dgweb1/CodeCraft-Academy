--[[
Editor Arduino - IDE virtual para programar Arduino
--]]

local editor = {}

-- Sketch por defecto
function editor.get_default_sketch()
    return [[// Sketch básico de Arduino - CodeCraft Academy
// Desarrollado por profeDaniel & GitHub Copilot

void setup() {
  // Configuración inicial - se ejecuta una vez
  pinMode(13, OUTPUT);  // Pin 13 como salida (LED incorporado)
  Serial.begin(9600);   // Iniciar comunicación serie
}

void loop() {
  // Código principal - se ejecuta continuamente
  digitalWrite(13, HIGH);  // Encender LED
  Serial.println("LED Encendido");
  delay(1000);            // Esperar 1 segundo
  
  digitalWrite(13, LOW);   // Apagar LED
  Serial.println("LED Apagado");  
  delay(1000);            // Esperar 1 segundo
}

/* 
 * ¡Bienvenido a Arduino con CodeCraft Academy!
 * 
 * Funciones principales:
 * - pinMode(pin, MODE): configura pin como INPUT/OUTPUT
 * - digitalWrite(pin, HIGH/LOW): escribe valor digital
 * - digitalRead(pin): lee valor digital
 * - analogRead(pin): lee valor analógico
 * - delay(ms): pausa en milisegundos
 * 
 * ¡Experimenta y aprende! 🚀
 */]]
end

-- Mostrar IDE de Arduino
function editor.show_arduino_ide(player_name, arduino_pos)
    local pos_str = minetest.pos_to_string(arduino_pos)
    local meta = minetest.get_meta(arduino_pos)
    local current_program = meta:get_string("program") or editor.get_default_sketch()
    
    local formspec = "formspec_version[4]" ..
        "size[16,12]" ..
        "bgcolor[#1a1a2e]" ..
        "label[0.5,0.5;🤖 Arduino IDE - CodeCraft Academy]" ..
        "label[11,0.5;Desarrollado por profeDaniel & GitHub Copilot]" ..
        
        -- Área de código principal
        "textarea[0.5,1.5;15,7;arduino_code;Código Arduino (C++):;" .. 
        minetest.formspec_escape(current_program) .. "]" ..
        
        -- Botones de acción
        "button[0.5,9;2.5,0.8;btn_verify;✓ Verificar]" ..
        "button[3.5,9;2.5,0.8;btn_upload;⬆️ Subir]" ..
        "button[6.5,9;2.5,0.8;btn_simulate;▶️ Simular]" ..
        "button[9.5,9;2.5,0.8;btn_stop;⏹️ Parar]" ..
        "button[12.5,9;2.5,0.8;btn_examples;📚 Ejemplos]" ..
        
        -- Monitor serie (simulado)
        "textarea[0.5,10.2;15,1.5;serial_monitor;Monitor Serie:;> Arduino UNO listo\\n> Esperando código...]" ..
        
        "button_exit[13,0.2;2.5,0.8;btn_close;❌ Cerrar]"
    
    minetest.show_formspec(player_name, "arduino_ide:" .. pos_str, formspec)
end

-- Ejemplos predefinidos
editor.examples = {
    blink = {
        name = "LED Parpadeante",
        code = [[void setup() {
  pinMode(13, OUTPUT);
}

void loop() {
  digitalWrite(13, HIGH);
  delay(1000);
  digitalWrite(13, LOW);
  delay(1000);
}]]
    },
    
    fade = {
        name = "LED con Fade",
        code = [[int brightness = 0;
int fadeAmount = 5;

void setup() {
  pinMode(9, OUTPUT);
}

void loop() {
  analogWrite(9, brightness);
  brightness = brightness + fadeAmount;
  
  if (brightness <= 0 || brightness >= 255) {
    fadeAmount = -fadeAmount;
  }
  delay(30);
}]]
    },
    
    button = {
        name = "Botón y LED",  
        code = [[const int buttonPin = 2;
const int ledPin = 13;

int buttonState = 0;

void setup() {
  pinMode(ledPin, OUTPUT);
  pinMode(buttonPin, INPUT);
}

void loop() {
  buttonState = digitalRead(buttonPin);
  
  if (buttonState == HIGH) {
    digitalWrite(ledPin, HIGH);
  } else {
    digitalWrite(ledPin, LOW);
  }
}]]
    }
}

-- Simulador básico de Arduino
function editor.simulate_arduino(code, player_name, arduino_pos)
    -- Análisis básico del código para simular comportamiento
    local results = {"🤖 Simulación Arduino iniciada..."}
    
    -- Detectar pinMode
    for pin, mode in code:gmatch("pinMode%((%d+),%s*(%w+)%)") do
        table.insert(results, "📌 Pin " .. pin .. " configurado como " .. mode)
    end
    
    -- Detectar digitalWrite
    for pin, state in code:gmatch("digitalWrite%((%d+),%s*(%w+)%)") do
        table.insert(results, "⚡ Pin " .. pin .. " = " .. state)
        
        -- Si es pin 13 (LED incorporado), cambiar luz del bloque
        if pin == "13" then
            editor.update_arduino_led(arduino_pos, state == "HIGH")
        end
    end
    
    -- Detectar delay
    for delay_ms in code:gmatch("delay%((%d+)%)") do
        table.insert(results, "⏰ Pausa: " .. delay_ms .. "ms")
    end
    
    -- Detectar Serial.println
    for message in code:gmatch("Serial%.println%(\"([^\"]+)\"%)") do
        table.insert(results, "📺 Serie: " .. message)
    end
    
    table.insert(results, "✅ Simulación completada")
    
    -- Mostrar resultados al jugador
    local result_text = table.concat(results, "\\n")
    minetest.chat_send_player(player_name, "🤖 Resultados de simulación:")
    for _, line in ipairs(results) do
        minetest.chat_send_player(player_name, line)
    end
    
    return true, result_text
end

-- Actualizar LED del Arduino (efecto visual)
function editor.update_arduino_led(pos, is_on)
    local node = minetest.get_node(pos)
    if node.name == "arduino_sim:arduino_uno" then
        -- Cambiar intensidad de luz según estado LED
        local new_light = is_on and 8 or 4
        minetest.swap_node(pos, {
            name = node.name,
            param1 = new_light,
            param2 = node.param2
        })
    end
end

arduino_sim.editor = editor