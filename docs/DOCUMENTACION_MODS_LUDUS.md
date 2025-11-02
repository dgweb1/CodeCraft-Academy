# Documentación de Mods Ludus - LudusTechnical

## Índice
1. [Visión General](#visión-general)
2. [Ludus Essential](#ludus-essential)
3. [Ludus Hand](#ludus-hand)
4. [Integración con el Sistema](#integración-con-el-sistema)
5. [Guía de Desarrollo](#guía-de-desarrollo)

## Visión General

Los mods Ludus (ludus_essential y ludus_hand) constituyen el conjunto de herramientas educativas especializadas desarrolladas específicamente para LudusTechnical. Estos mods proporcionan elementos visuales distintivos y mecánicas de interacción personalizadas que apoyan los objetivos pedagógicos del sistema.

### Filosofía de Diseño

Los mods Ludus siguen el principio de "simplicidad educativa", proporcionando elementos esenciales con funcionalidades claras y diferenciadas que faciliten la comprensión de conceptos computacionales sin agregar complejidad innecesaria al entorno de aprendizaje.

### Nomenclatura

El término "Ludus" (del latín "juego/escuela") refleja la naturaleza lúdica-educativa de estos componentes, diseñados específicamente para facilitar el aprendizaje a través de la experiencia interactiva.

## Ludus Essential

### Propósito y Funcionalidad

Ludus Essential proporciona un conjunto curado de bloques básicos con características específicas para actividades educativas. Este mod reemplaza elementos estándar de Minetest con versiones optimizadas para el contexto pedagógico.

### Estructura del Mod

```
ludus_essential/
├── init.lua          # Lógica principal y definiciones de bloques
├── mod.conf          # Metadatos del mod
└── textures/         # Texturas personalizadas para bloques educativos
    ├── ludus_tech_stone.png
    ├── ludus_tech_water.png
    ├── ludus_red.png
    ├── ludus_blue.png
    ├── ludus_green.png
    └── ludus_yellow.png
```

### Análisis del Código

#### Definición de Bloques Básicos

**Bloques de Entorno**
```lua
register_node('ludus_essential:tech_stone', {
    description = 'LudusTechnical Stone',
    tiles = { 'ludus_tech_stone.png' },
    groups = { oddly_breakable_by_hand = 3 },
    is_ground_content = true
})

register_node('ludus_essential:tech_water', {
    description = 'LudusTechnical Water',
    tiles = { 'ludus_tech_water.png' },
    groups = { oddly_breakable_by_hand = 3 },
    is_ground_content = true
})
```

**Características Técnicas:**
- Bloques básicos de terreno con identidad visual propia
- Texturización personalizada para diferenciación del entorno estándar
- Propiedades de excavación adaptadas para facilidad de uso educativo

#### Sistema de Bloques de Colores

**Implementación de Control de Acceso**
```lua
local admins = {"creador", "profe_daniel", "admin3"}

register_node('ludus_essential:red_block', {
    description = 'Bloque Rojo',
    tiles = { 'ludus_red.png' },
    groups = { oddly_breakable_by_hand = 3 },
    is_ground_content = false,
    drop = "",
    on_dig = function(pos, node, digger)
        local name = digger:get_player_name()
        for _, adm in ipairs(admins) do
            if name == adm then
                minetest.node_dig(pos, node, digger)
                return
            end
        end
        minetest.chat_send_player(name, "¡No puedes romper este bloque!")
    end,
})
```

**Características Pedagógicas:**
- **Control de Acceso Diferenciado**: Solo administradores pueden remover bloques
- **Retroalimentación Inmediata**: Mensajes informativos para estudiantes
- **Persistencia de Estructuras**: Las construcciones estudiantiles permanecen intactas
- **Sin Drop**: Evita acumulación no deseada de recursos

#### Sistema de Aliases para Mapgen

**Reemplazo de Bloques de Generación**
```lua
register_alias('mapgen_stone', 'ludus_essential:tech_stone')
register_alias('mapgen_water_source', 'ludus_essential:tech_water')
register_alias('mapgen_dirt', 'ludus_essential:red_block')
register_alias('mapgen_sand', 'ludus_essential:blue_block')
register_alias('mapgen_gravel', 'ludus_essential:green_block')
register_alias('mapgen_clay', 'ludus_essential:yellow_block')
```

**Aliases de Conveniencia**
```lua
register_alias('rojo', 'ludus_essential:red_block')
register_alias('azul', 'ludus_essential:blue_block')
register_alias('verde', 'ludus_essential:green_block')
register_alias('amarillo', 'ludus_essential:yellow_block')
```

**Ventajas del Sistema de Aliases:**
- Simplifica el acceso a bloques educativos mediante nombres intuitivos
- Integra seamlessly con el sistema de generación de mundos
- Permite referenciado directo por colores en español
- Facilita la comunicación entre estudiantes y docentes

### Aplicaciones Educativas

#### Codificación por Colores
- **Rojo**: Elementos de inicio/fin en algoritmos
- **Azul**: Estructuras de datos o variables
- **Verde**: Procesos exitosos o caminos válidos
- **Amarillo**: Advertencias o elementos de decisión

#### Construcción de Diagramas
Los bloques de colores permiten la creación de:
- Diagramas de flujo físicos
- Representaciones de estructuras de datos
- Mapas conceptuales tridimensionales
- Modelos de arquitecturas de sistemas

### Configuración y Personalización

#### Modificación de Lista de Administradores
```lua
-- En init.lua, línea 18
local admins = {"tu_usuario", "otro_admin", "profesor_auxiliar"}
```

#### Expansión de Paleta de Colores
Para agregar nuevos colores, seguir el patrón:
```lua
register_node('ludus_essential:nuevo_color_block', {
    description = 'Bloque Nuevo Color',
    tiles = { 'ludus_nuevo_color.png' },
    groups = { oddly_breakable_by_hand = 3 },
    is_ground_content = false,
    drop = "",
    on_dig = function(pos, node, digger)
        -- Implementar lógica de control de acceso
    end,
})
```

## Ludus Hand

### Propósito y Funcionalidad

Ludus Hand proporciona una herramienta de mano personalizada que reemplaza la herramienta por defecto de Minetest, optimizada para las necesidades específicas del entorno educativo.

### Estructura del Mod

```
ludus_hand/
├── init.lua          # Definición de la herramienta personalizada
├── mod.conf          # Metadatos del mod
└── textures/         # Textura personalizada
    └── ludus_hand_hand.png
```

### Análisis del Código

#### Definición de Herramienta Personalizada

```lua
register_item('ludus_hand:hand', {
    type = 'none',
    wield_image = 'ludus_hand_hand.png',
    wield_scale = {x = 0.5, y = 1, z = 4},
    tool_capabilities = {
        full_punch_interval = 0.9,
        max_drop_level = 0,
        groupcaps = {
            crumbly = {
                times = {[2] = 3.00, [3] = 0.70},
                uses = 0,
                maxlevel = 1,
            },
            snappy = {
                times = {[3] = 0.40},
                uses = 0,
                maxlevel = 1,
            },
            oddly_breakable_by_hand = {
                times = {[1] = 3.50, [2] = 2.00, [3] = 0.70},
                uses = 0,
            },
        },
        damage_groups = {fleshy = 1},
    }
})
```

### Características Técnicas

#### Configuración de Escala Visual
```lua
wield_scale = {x = 0.5, y = 1, z = 4}
```
- **x = 0.5**: Reduce ancho para visualización menos intrusiva
- **y = 1**: Mantiene altura estándar
- **z = 4**: Aumenta profundidad para mejor visibilidad

#### Capacidades de Herramienta Optimizadas

**Grupos de Material Soportados:**
- **crumbly**: Materiales desmenuzables (tierra, arena)
- **snappy**: Materiales frágiles (plantas, elementos delicados)
- **oddly_breakable_by_hand**: Bloques especiales rompibles a mano

**Tiempos de Excavación Balanceados:**
- Suficientemente rápidos para mantener fluidez en actividades
- Suficientemente lentos para requerir planificación y consideración
- Sin degradación (uses = 0) para uso educativo continuo

### Integración Pedagógica

#### Ventajas del Diseño Personalizado

1. **Identidad Visual**: Refuerza la marca educativa del sistema
2. **Rendimiento Optimizado**: Velocidades calibradas para contexto educativo
3. **Durabilidad Infinita**: Elimina mantenimiento de herramientas
4. **Accesibilidad**: Compatible con todos los materiales educativos

#### Consideraciones de Usabilidad

- **Retroalimentación Táctil**: Intervalos de uso proporcionan ritmo de trabajo apropiado
- **Versatilidad**: Funciona efectivamente con todos los bloques del sistema
- **Consistencia**: Comportamiento predecible facilita focus en objetivos educativos

## Integración con el Sistema

### Dependencias y Compatibilidad

#### Orden de Carga
```
1. default (base de Minetest)
2. ludus_essential (reemplaza elementos básicos)
3. ludus_hand (herramienta por defecto)
4. equipos (sistema educativo principal)
```

#### Interoperabilidad con Equipos

**Registro en Sistema de Límites**
Los bloques ludus_essential están integrados en el sistema de límites de inventario del mod equipos:
```lua
-- En equipos/init.lua
local function verificar_limite_item(player, itemstack)
    local item_name = itemstack:get_name()
    -- Incluye bloques ludus en verificación
    if string.match(item_name, "ludus_essential:.*_block") then
        -- Aplicar límites educativos
    end
end
```

**Compatibilidad con Zonas**
Los bloques ludus respetan las restricciones zonales establecidas por el mod equipos, permitiendo construcción solo dentro de áreas asignadas.

### Configuración Conjunta

#### Variables Compartidas
```lua
-- Administradores compartidos entre mods
local admins_ludus = {"creador", "profe_daniel", "admin3"}
local admins_equipos = config.administradores

-- Sincronización recomendada
if equipos and equipos.administradores then
    admins_ludus = equipos.administradores
end
```

#### Aliases Integrados
El sistema de aliases de ludus_essential facilita la referencia desde el mod equipos:
```lua
-- En actividades específicas
config.materiales_algoritmo = {
    "rojo",      -- alias para ludus_essential:red_block
    "azul",      -- alias para ludus_essential:blue_block
    "verde"      -- alias para ludus_essential:green_block
}
```

## Guía de Desarrollo

### Extensión de Ludus Essential

#### Agregar Nuevos Bloques Educativos

**Patrón de Implementación:**
```lua
register_node('ludus_essential:nombre_block', {
    description = 'Descripción Educativa',
    tiles = { 'ludus_nombre.png' },
    groups = { oddly_breakable_by_hand = 3, ludus_educational = 1 },
    is_ground_content = false,
    drop = "",
    
    -- Control de acceso educativo
    on_dig = function(pos, node, digger)
        local name = digger:get_player_name()
        if not es_administrador(name) then
            minetest.chat_send_player(name, "Bloque protegido para actividad educativa")
            return
        end
        minetest.node_dig(pos, node, digger)
    end,
    
    -- Funcionalidad educativa específica
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        -- Implementar interacción educativa
    end,
})
```

#### Implementar Bloques Interactivos

**Bloque con Estado Educativo:**
```lua
register_node('ludus_essential:switch_block', {
    description = 'Bloque Interruptor',
    tiles = { 'ludus_switch_off.png' },
    groups = { oddly_breakable_by_hand = 3 },
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        -- Cambiar estado visual
        if node.name == 'ludus_essential:switch_block' then
            node.name = 'ludus_essential:switch_block_on'
            minetest.set_node(pos, node)
            minetest.chat_send_player(clicker:get_player_name(), "Interruptor activado")
        end
    end,
})

register_node('ludus_essential:switch_block_on', {
    description = 'Bloque Interruptor (Activado)',
    tiles = { 'ludus_switch_on.png' },
    groups = { oddly_breakable_by_hand = 3 },
    
    on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)
        node.name = 'ludus_essential:switch_block'
        minetest.set_node(pos, node)
        minetest.chat_send_player(clicker:get_player_name(), "Interruptor desactivado")
    end,
})
```

### Extensión de Ludus Hand

#### Herramientas Especializadas

**Herramienta de Medición:**
```lua
register_item('ludus_hand:measuring_tool', {
    description = 'Herramienta de Medición Educativa',
    inventory_image = 'ludus_measuring_tool.png',
    wield_image = 'ludus_measuring_tool.png',
    
    on_use = function(itemstack, user, pointed_thing)
        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            minetest.chat_send_player(user:get_player_name(), 
                "Posición: " .. minetest.pos_to_string(pos))
        end
        return itemstack
    end,
})
```

#### Herramientas con Funcionalidad Educativa

**Selector de Áreas:**
```lua
register_item('ludus_hand:area_selector', {
    description = 'Selector de Área Educativa',
    inventory_image = 'ludus_area_selector.png',
    
    on_use = function(itemstack, user, pointed_thing)
        local meta = itemstack:get_meta()
        local player_name = user:get_player_name()
        
        if pointed_thing.type == "node" then
            local pos = pointed_thing.under
            local stored_pos = meta:get_string("first_pos")
            
            if stored_pos == "" then
                meta:set_string("first_pos", minetest.pos_to_string(pos))
                minetest.chat_send_player(player_name, "Primera posición seleccionada")
            else
                local first_pos = minetest.string_to_pos(stored_pos)
                local volume = calcular_volumen(first_pos, pos)
                minetest.chat_send_player(player_name, 
                    "Área seleccionada: " .. volume .. " bloques cúbicos")
                meta:set_string("first_pos", "")
            end
        end
        return itemstack
    end,
})
```

### Mejores Prácticas de Desarrollo

#### Convenciones de Nomenclatura
- Prefijo `ludus_essential:` para todos los bloques educativos
- Prefijo `ludus_hand:` para todas las herramientas educativas
- Sufijo `_block` para bloques sólidos
- Sufijo `_tool` para herramientas interactivas

#### Gestión de Texturas
```
textures/
├── ludus_[color].png          # Bloques de colores básicos
├── ludus_[material].png       # Bloques de materiales especiales
├── ludus_[function]_tool.png  # Herramientas especializadas
└── ludus_icon_[type].png      # Iconos de inventario
```

#### Documentación de Funciones
```lua
-- Descripción: Función que valida permisos educativos
-- Parámetros: player_name (string) - nombre del jugador
-- Retorna: boolean - true si tiene permisos, false en caso contrario
local function validar_permisos_educativos(player_name)
    -- Implementación
end
```

### Integración con Futuras Funcionalidades

#### Preparación para Métricas
```lua
-- Registro de eventos para sistema de métricas futuro
local function registrar_evento_ludus(tipo_evento, jugador, datos)
    if equipos and equipos.registrar_metrica then
        equipos.registrar_metrica(tipo_evento, jugador, datos)
    end
end
```

#### Hooks para Extensiones
```lua
-- Sistema de callbacks para permitir extensiones
ludus_essential.callbacks = {}

function ludus_essential.register_callback(evento, funcion)
    if not ludus_essential.callbacks[evento] then
        ludus_essential.callbacks[evento] = {}
    end
    table.insert(ludus_essential.callbacks[evento], funcion)
end
```

---

**Autor**: prof_daniel  
**Versión**: 1.0  
**Fecha**: 1 de noviembre de 2025  
**Componentes Documentados**: ludus_essential v1.0, ludus_hand v1.0