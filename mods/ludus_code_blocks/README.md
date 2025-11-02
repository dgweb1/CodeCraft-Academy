# Code Blocks - Sistema de Programación para CodeCraft Academy

**Autores:** profeDaniel & GitHub Copilot  
**Versión:** 1.0.0  
**Licencia:** MIT

## Descripción

Code Blocks transforma CodeCraft Academy en una plataforma educativa completa para enseñar programación. Los estudiantes pueden escribir, ejecutar y colaborar en proyectos de código directamente dentro del mundo 3D de Luanti.

## Características Principales

### 🎯 Programación Integrada
- **Terminales 3D:** Coloca bloques de terminal que funcionan como computadoras
- **Editor Visual:** Interface gráfica moderna para escribir código
- **Multi-lenguaje:** Soporte para Python, Lua, Java (y Arduino próximamente)
- **Ejecución en Tiempo Real:** Ejecuta código y ve resultados instantáneos

### 👥 Colaboración Educativa
- **Chat de Equipos:** Comunicación entre miembros del mismo equipo
- **Revisión de Código:** Sistema peer-to-peer para revisar proyectos
- **Pantalla Compartida:** Comparte tu código con el equipo
- **Proyectos Colaborativos:** Trabaja en grupo en tiempo real

### 📚 Herramientas para Profesores
- **Dashboard de Estadísticas:** Monitorea el progreso de estudiantes
- **Gestión de Proyectos:** Ve y administra trabajos de estudiantes
- **Sistema de Backups:** Respalda automáticamente los proyectos
- **Privilegios Educativos:** Controles especiales para docentes

## Instalación

1. Copia la carpeta `code_blocks` a `mods/` en tu juego CodeCraft Academy
2. Asegúrate de tener las dependencias instaladas:
   - `default` (núcleo del juego)
   - `flow` (sistema de interfaces)
   - `formspec_ast` (formularios dinámicos) 
   - `equipos` (opcional - para equipos)
3. Reinicia el servidor/juego
4. ¡Los terminales aparecerán en el inventario creativo!

## Uso Básico

### Para Estudiantes

#### Comandos Esenciales
```
/code help                    # Ver ayuda completa
/code editor python          # Abrir editor de Python  
/code editor lua             # Abrir editor de Lua
/code projects               # Ver mis proyectos
/code run mi_proyecto        # Ejecutar proyecto
/code delete mi_proyecto     # Eliminar proyecto
```

#### Terminales Físicos
1. Coloca un **Terminal de Código** en el mundo
2. Click derecho para abrir el editor
3. Selecciona el lenguaje de programación
4. Escribe tu código
5. Guarda y ejecuta
6. ¡El terminal conserva tu trabajo!

### Para Profesores

#### Privilegios Especiales
Otorga privilegios de profesor:
```
/grant profeDaniel code_teacher
```

#### Comandos Administrativos
```
/code stats                      # Ver estadísticas generales
/code_admin help                 # Ayuda para profesores
/code_admin projects estudiante  # Ver proyectos de alumno
/code_admin backup               # Crear respaldo
/code_admin clear estudiante     # Limpiar proyectos
```

### Colaboración en Equipos

#### Chat de Equipo
```
/team_chat ¡Hola equipo!        # Enviar mensaje al equipo
/team_projects                   # Ver proyectos del equipo
/share_screen mi_proyecto        # Compartir código actual
```

#### Revisión de Código
```
/request_review compañero proyecto  # Solicitar revisión
/code_review estudiante proyecto   # Revisar código de otro
```

## Ejemplos de Código

### Python Básico
```python
# Hola mundo en Python
print("¡Hola CodeCraft Academy!")

# Matemáticas simples
resultado = 5 + 3 * 2
print(f"El resultado es: {resultado}")

# Lista de lenguajes
lenguajes = ["Python", "Lua", "Java"]
for lang in lenguajes:
    print(f"Aprendiendo {lang}")
```

### Lua para Luanti
```lua
-- Hola mundo en Lua
print("¡Hola desde Lua!")

-- Función simple
function saludar(nombre)
    return "Hola " .. nombre .. "!"
end

print(saludar("CodeCraft"))

-- Tabla de datos
estudiantes = {
    {nombre = "Ana", edad = 15},
    {nombre = "Luis", edad = 16}
}

for i, estudiante in ipairs(estudiantes) do
    print(estudiante.nombre .. " tiene " .. estudiante.edad .. " años")
end
```

### Java Básico
```java
// Hola mundo en Java
public class HolaMundo {
    public static void main(String[] args) {
        System.out.println("¡Hola CodeCraft Academy!");
        
        // Variables y operaciones
        int a = 10;
        int b = 20;
        int suma = a + b;
        
        System.out.println("La suma es: " + suma);
    }
}
```

## Arquitectura Técnica

### Estructura de Archivos
```
code_blocks/
├── init.lua              # Punto de entrada principal
├── mod.conf              # Configuración del mod
├── README.md             # Esta documentación
├── storage.lua           # Sistema de almacenamiento
├── editors.lua           # Interfaces de editor
├── blocks.lua            # Bloques físicos del mundo
├── interpreters.lua      # Motores de ejecución
├── collaboration.lua     # Herramientas colaborativas
├── TEXTURAS.md          # Guía de texturas
└── textures/            # Gráficos del mod
    ├── code_blocks_terminal.png
    ├── code_blocks_python.png
    ├── code_blocks_lua.png
    └── code_blocks_java.png
```

### API para Desarrolladores
```lua
-- Crear proyecto programáticamente
code_blocks.api.create_project("estudiante", "mi_app", "python")

-- Obtener proyecto
local proyecto = code_blocks.api.get_project("estudiante", "mi_app")

-- Ejecutar código
local exito, resultado = code_blocks.api.execute_code("estudiante", "lua", "print('test')")

-- Abrir editor
code_blocks.api.show_editor("estudiante", "python", "mi_app")
```

## Configuración Avanzada

### Límites y Seguridad
El sistema incluye protecciones automáticas:
- **Timeout de ejecución:** 5 segundos máximo
- **Límite de líneas:** 50 líneas por archivo  
- **Proyectos máximos:** 10 por estudiante
- **Sandbox:** Código ejecuta en entorno controlado

### Personalización
Modifica los límites en `storage.lua`:
```lua
local config = {
    max_lines = 100,        -- Más líneas permitidas
    max_projects = 20,      # Más proyectos por estudiante  
    timeout = 10,           -- Más tiempo de ejecución
}
```

## Dependencias

### Requeridas
- **Luanti 5.14.0+** (Motor base)
- **default** (Bloques básicos)
- **flow** (Sistema de interfaces)
- **formspec_ast** (Formularios dinámicos)

### Opcionales
- **equipos** (Sistema de equipos educativos)
- **worldedit** (Herramientas de construcción)
- **simple_skins** (Personalización de avatares)

## Solución de Problemas

### Problemas Comunes

**P: No puedo ver los terminales en el inventario**
R: Verifica que tienes modo creativo activo o privilegios de `give`

**P: El código Python no ejecuta**  
R: Python se simula - usa funciones básicas como `print()`, `len()`, operaciones matemáticas

**P: Error "code_blocks no encontrado"**
R: Asegúrate que el mod está en la carpeta `mods/` y reinicia el servidor

**P: Los equipos no funcionan**
R: Instala el mod `equipos` o usa el sistema de equipos básico incluido

### Logs y Debug
Revisa los logs del servidor para errores:
```
[CodeCraft] Code Blocks mod cargado exitosamente
[CodeCraft] Autores: profeDaniel & GitHub Copilot
```

## Desarrollo y Contribuciones

### Añadir Nuevos Lenguajes
1. Edita `interpreters.lua`
2. Añade el ejecutor en la tabla `executors`
3. Crea plantillas en `get_code_template()`
4. Actualiza la documentación

### Crear Nuevas Características
El mod está diseñado modularmente:
- `storage.lua` - Persistencia de datos
- `editors.lua` - Interfaces de usuario  
- `blocks.lua` - Elementos del mundo 3D
- `interpreters.lua` - Ejecución de código
- `collaboration.lua` - Herramientas sociales

## Licencia y Créditos

**Desarrollado por:** profeDaniel & GitHub Copilot

**Licencia:** MIT License - Libre uso para educación

**Agradecimientos:**
- Comunidad Luanti/Minetest por el motor base
- Proyecto Flow por el sistema de interfaces  
- Todos los educadores que inspiran la programación

## Contacto y Soporte

Para reportar bugs, solicitar características o obtener ayuda:
- Crea un issue en el repositorio del proyecto
- Contacta a profeDaniel para soporte educativo
- Únete a la comunidad CodeCraft Academy

---

**¡Transforma la educación con CodeCraft Academy!** 🎓🚀

*"Aprender programación debería ser tan divertido como jugar"* - profeDaniel & GitHub Copilot