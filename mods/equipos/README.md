minetest.register_chatcommand("ayuda_zonas", {
    description = "Muestra los comandos disponibles para crear y limpiar zonas",
    privs = {server=true},
    func = function(name, param)
        local ayuda = [[
📦 Comandos de gestión de zonas:

/crear_zona <número> [material]
→ Crea una zona específica (1–15) con el material indicado (por defecto: default:stone)

/limpiar_zona <número>
→ Limpia una zona específica (1–15), reemplazando todo con aire

/crear_zonas [material]
→ Crea todas las zonas con el material indicado (por defecto: default:stone)

/limpiar_zonas
→ Limpia todas las zonas, reemplazando su contenido con aire

🧠 Consejo: usá estos comandos antes y después de cada sesión para preparar y reiniciar el entorno de trabajo.
]]
        return true, ayuda
    end
})