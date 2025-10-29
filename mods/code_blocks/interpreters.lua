--[[
Interpreters.lua - Intérpretes y compiladores para diferentes lenguajes
--]]

local interpreters = {}

-- Configuración de timeouts y límites
local MAX_EXECUTION_TIME = 5  -- segundos
local MAX_OUTPUT_LENGTH = 1000  -- caracteres

-- Intérprete mejorado de Lua con más funciones
function interpreters.execute_lua_advanced(code, player_name)
    local output_lines = {}
    local error_occurred = false
    
    -- Entorno sandbox expandido pero seguro
    local env = {
        -- Funciones básicas
        print = function(...)
            local args = {...}
            local line = ""
            for i, v in ipairs(args) do
                if i > 1 then line = line .. "\t" end
                line = line .. tostring(v)
            end
            table.insert(output_lines, line)
        end,
        
        -- Matemáticas
        math = {
            abs = math.abs, acos = math.acos, asin = math.asin,
            atan = math.atan, ceil = math.ceil, cos = math.cos,
            deg = math.deg, exp = math.exp, floor = math.floor,
            log = math.log, max = math.max, min = math.min,
            pi = math.pi, pow = math.pow, rad = math.rad,
            random = math.random, sin = math.sin, sqrt = math.sqrt,
            tan = math.tan
        },
        
        -- Strings
        string = {
            byte = string.byte, char = string.char, find = string.find,
            format = string.format, gsub = string.gsub, len = string.len,
            lower = string.lower, rep = string.rep, reverse = string.reverse,
            sub = string.sub, upper = string.upper
        },
        
        -- Tables
        table = {
            concat = table.concat, insert = table.insert,
            remove = table.remove, sort = table.sort
        },
        
        -- Utilidades
        pairs = pairs, ipairs = ipairs, next = next,
        tonumber = tonumber, tostring = tostring, type = type,
        unpack = unpack or table.unpack,
        
        -- Funciones específicas para estudiantes
        usuario = player_name,
        tiempo = os.time,
        
        -- Mini-API para interactuar con el mundo (limitada)
        mundo = {
            obtener_pos = function()
                return {x = 0, y = 0, z = 0}  -- Posición simulada
            end,
            mensaje = function(texto)
                table.insert(output_lines, "🌍 Mundo dice: " .. tostring(texto))
            end
        }
    }
    
    -- Compilar código
    local chunk, compile_error = loadstring(code)
    if not chunk then
        return false, "❌ Error de sintaxis:\n" .. compile_error
    end
    
    -- Ejecutar con timeout simulado (básico)
    setfenv(chunk, env)
    local start_time = os.clock()
    
    local success, runtime_error = pcall(function()
        chunk()
        -- Verificar si se excedió el tiempo (aproximado)
        if os.clock() - start_time > MAX_EXECUTION_TIME then
            error("Tiempo de ejecución excedido")
        end
    end)
    
    if not success then
        return false, "❌ Error de ejecución:\n" .. tostring(runtime_error)
    end
    
    -- Preparar salida
    local output = table.concat(output_lines, "\n")
    if #output > MAX_OUTPUT_LENGTH then
        output = output:sub(1, MAX_OUTPUT_LENGTH) .. "\n... (salida truncada)"
    end
    
    if output == "" then
        output = "✅ Código ejecutado sin salida"
    else
        output = "✅ Resultado:\n" .. output
    end
    
    return true, output
end

-- Simulador Python mejorado
function interpreters.execute_python_advanced(python_code, player_name)
    -- Preprocesador más sofisticado para Python -> Lua
    local lua_code = python_code
    
    -- Mantener comentarios de Python
    lua_code = lua_code:gsub("#([^\n]*)", "-- %1")
    
    -- Convertir definiciones de función
    lua_code = lua_code:gsub("def%s+([%w_]+)%s*%(([^)]*)%)%s*:", "function %1(%2)")
    
    -- Convertir estructuras de control
    lua_code = lua_code:gsub("if%s+([^:]+)%s*:", "if %1 then")
    lua_code = lua_code:gsub("elif%s+([^:]+)%s*:", "elseif %1 then") 
    lua_code = lua_code:gsub("else%s*:", "else")
    lua_code = lua_code:gsub("while%s+([^:]+)%s*:", "while %1 do")
    
    -- Convertir bucles for básicos
    lua_code = lua_code:gsub("for%s+([%w_]+)%s+in%s+range%((%d+)%)%s*:", "for %1 = 0, %2-1 do")
    lua_code = lua_code:gsub("for%s+([%w_]+)%s+in%s+range%((%d+),%s*(%d+)%)%s*:", "for %1 = %2, %3-1 do")
    
    -- Convertir operadores de comparación
    lua_code = lua_code:gsub("==", "==")  -- Ya es igual
    lua_code = lua_code:gsub("!=", "~=")
    lua_code = lua_code:gsub(" and ", " and ")  -- Ya es igual
    lua_code = lua_code:gsub(" or ", " or ")    -- Ya es igual
    lua_code = lua_code:gsub(" not ", " not ")  -- Ya es igual
    
    -- Variables booleanas
    lua_code = lua_code:gsub("%bTrue%b", "true")
    lua_code = lua_code:gsub("%bFalse%b", "false")
    lua_code = lua_code:gsub("%bNone%b", "nil")
    
    -- Agregar ends automáticamente (heurística mejorada)
    local lines = {}
    local indent_stack = {}
    local current_indent = 0
    
    for line in lua_code:gmatch("[^\n]*") do
        -- Calcular indentación
        local spaces = line:match("^%s*")
        local new_indent = spaces and #spaces or 0
        
        -- Si la indentación disminuyó, cerrar bloques
        while #indent_stack > 0 and new_indent <= indent_stack[#indent_stack] do
            table.insert(lines, string.rep(" ", indent_stack[#indent_stack]) .. "end")
            table.remove(indent_stack)
        end
        
        table.insert(lines, line)
        
        -- Si es una línea que abre bloque, agregar a stack
        if line:match("%s*function") or line:match("%s*if") or line:match("%s*while") or 
           line:match("%s*for") or line:match("%s*else") or line:match("%s*elseif") then
            table.insert(indent_stack, new_indent)
        end
    end
    
    -- Cerrar bloques restantes
    while #indent_stack > 0 do
        table.insert(lines, "end")
        table.remove(indent_stack)
    end
    
    lua_code = table.concat(lines, "\n")
    
    -- Ejecutar como Lua avanzado
    return interpreters.execute_lua_advanced(lua_code, player_name)
end

-- Simulador básico de Java (conceptos de POO)
function interpreters.execute_java_basic(java_code, player_name)
    -- Simulador muy básico para conceptos de Java
    local lua_code = java_code
    
    -- Remover imports y package declarations
    lua_code = lua_code:gsub("import%s+[^;]+;", "")
    lua_code = lua_code:gsub("package%s+[^;]+;", "") 
    
    -- Convertir class a tabla
    lua_code = lua_code:gsub("public%s+class%s+([%w_]+)%s*{", "%1 = {}")
    
    -- Convertir métodos básicos
    lua_code = lua_code:gsub("public%s+static%s+void%s+main%s*%(String%[%]%s+args%)%s*{", 
        "function main()")
    lua_code = lua_code:gsub("public%s+([%w_]+)%s+([%w_]+)%s*%(([^)]*)%)%s*{", 
        "function %2(%3)")
    
    -- System.out.println -> print
    lua_code = lua_code:gsub("System%.out%.println%s*%(([^)]+)%)", "print(%1)")
    
    -- Tipos básicos
    lua_code = lua_code:gsub("int%s+([%w_]+)%s*=%s*", "local %1 = ")
    lua_code = lua_code:gsub("String%s+([%w_]+)%s*=%s*", "local %1 = ")
    
    -- Agregar ends
    lua_code = lua_code .. "\nend\nmain()"  -- Ejecutar main automáticamente
    
    return interpreters.execute_lua_advanced(lua_code, player_name)
end

-- Función principal de ejecución
function interpreters.execute_code(language, code, player_name)
    if language == "lua" then
        return interpreters.execute_lua_advanced(code, player_name)
    elseif language == "python" then
        return interpreters.execute_python_advanced(code, player_name)
    elseif language == "java" then
        return interpreters.execute_java_basic(code, player_name)
    else
        return false, "❌ Lenguaje no soportado: " .. language
    end
end

-- Ejemplos y plantillas mejoradas
interpreters.templates = {
    lua = {
        hello = [[-- Hola Mundo en Lua
print("¡Hola desde CodeCraft Academy!")
print("Tu usuario es:", usuario)
print("Hora actual:", tiempo())]],
        
        calculator = [[-- Calculadora Básica
function sumar(a, b)
    return a + b
end

function multiplicar(a, b)
    return a * b
end

-- Pruebas
local x, y = 10, 5
print("Suma:", sumar(x, y))
print("Multiplicación:", multiplicar(x, y))
print("Raíz cuadrada de", x, "es", math.sqrt(x))]],
        
        loops = [[-- Bucles y Tablas
local numeros = {1, 2, 3, 4, 5}
local suma = 0

print("Números originales:")
for i, num in ipairs(numeros) do
    print(i .. ": " .. num)
    suma = suma + num
end

print("Suma total:", suma)
print("Promedio:", suma / #numeros)]]
    },
    
    python = {
        hello = [[# Hola Mundo en Python
print("¡Hola desde CodeCraft Academy!")
print("Aprendiendo Python en 3D")

# Variables
nombre = "Estudiante"
edad = 16
print(f"Nombre: {nombre}, Edad: {edad}")]], -- Nota: f-strings no funcionarán en simulación
        
        calculator = [[# Calculadora en Python
def sumar(a, b):
    return a + b

def multiplicar(a, b):
    return a * b

# Pruebas
x = 10
y = 5
print("Suma:", sumar(x, y))
print("Multiplicación:", multiplicar(x, y))

# Bucle simple
for i in range(5):
    print("Contador:", i)]],
        
        conditions = [[# Condicionales en Python
edad = 16

if edad >= 18:
    print("Eres mayor de edad")
elif edad >= 13:
    print("Eres adolescente")
else:
    print("Eres menor de edad")

# Lista y bucle
frutas = ["manzana", "banana", "naranja"]
for fruta in frutas:
    print("Me gusta la", fruta)]]  -- Nota: esto no funcionará perfectamente en simulación
    }
}

-- API pública
code_blocks.interpreters = interpreters