--[[
Boards.lua - Diferentes tipos de placas Arduino
--]]

local boards = {}

-- Información de placas disponibles
boards.types = {
    uno = {
        name = "Arduino UNO",
        digital_pins = 14,
        analog_pins = 6,
        pwm_pins = {3, 5, 6, 9, 10, 11},
        memory = "32KB Flash, 2KB RAM"
    },
    
    nano = {
        name = "Arduino Nano", 
        digital_pins = 14,
        analog_pins = 8,
        pwm_pins = {3, 5, 6, 9, 10, 11},
        memory = "32KB Flash, 2KB RAM"
    },
    
    mega = {
        name = "Arduino Mega",
        digital_pins = 54,
        analog_pins = 16, 
        pwm_pins = {2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13},
        memory = "256KB Flash, 8KB RAM"
    }
}

arduino_sim.boards = boards