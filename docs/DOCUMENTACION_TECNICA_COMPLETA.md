# Documentación Técnica - LudusTechnical

## Índice
1. [Descripción General](#descripción-general)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Análisis del Mod Equipos](#análisis-del-mod-equipos)
4. [Manual Técnico Completo](#manual-técnico-completo)
5. [Guía de Desarrollo](#guía-de-desarrollo)
6. [Ejemplos de Uso](#ejemplos-de-uso)

## Descripción General

LudusTechnical es un entorno educativo basado en Luanti/Minetest diseñado específicamente para la evaluación de competencias en ciencias de la computación a nivel secundario. El sistema implementa mecánicas de trabajo colaborativo en equipos, gestión de recursos limitados y evaluación de habilidades de pensamiento crítico.

### Características Principales

- Sistema de equipos automático con asignación aleatoria de estudiantes
- Zonas de trabajo delimitadas con 15 áreas independientes para equipos
- Gestión de recursos con límites de inventario y materiales
- Control administrativo con herramientas especializadas para docentes
- Evaluación integrada con métricas de colaboración y rendimiento

### Objetivos Pedagógicos

El sistema está diseñado para evaluar:
- Trabajo colaborativo y comunicación en equipos
- Resolución de problemas computacionales
- Pensamiento crítico y toma de decisiones
- Gestión eficiente de recursos limitados
- Aplicación práctica de conceptos teóricos

## Arquitectura del Sistema

### Visión General

LudusTechnical está construido como una extensión educativa de Luanti/Minetest, utilizando una arquitectura modular que separa las responsabilidades en diferentes componentes especializados.

### Diagrama de Componentes

```
LudusTechnical
├── Mods Educativos Propios
│   ├── equipos (núcleo del sistema)
│   ├── ludus_essential (bloques temáticos)
│   └── ludus_hand (herramientas personalizadas)
├── Mods Administrativos
│   ├── worldedit (edición de mundos)
│   ├── k_worldedit_gui (interfaz gráfica)
│   └── flow (framework UI)
├── Mods de Presentación
│   ├── simple_skins (avatares por equipo)
│   ├── creative (modo creativo)
│   └── sfinv (inventario mejorado)
└── Mods de Funcionalidad Base
    ├── default (nodos básicos de Minetest)
    ├── player_api (gestión de jugadores)
    └── formspec_ast (procesamiento de formularios)
```

### Flujo de Datos Principal

1. **Configuración**: Los parámetros se cargan desde config.lua
2. **Inicialización**: El sistema crea zonas y prepara el entorno
3. **Asignación**: Los estudiantes se distribuyen aleatoriamente en equipos
4. **Ejecución**: Los equipos trabajan en sus zonas asignadas
5. **Monitoreo**: El sistema registra actividades y métricas
6. **Evaluación**: Los docentes pueden acceder a reportes y estadísticas

## Análisis del Mod Equipos

### Estructura de Archivos

El mod equipos es el componente central del sistema educativo y está organizado en tres archivos principales:

```
equipos/
├── mod.conf (metadatos del mod)
├── init.lua (lógica principal y comandos)
├── config.lua (configuración del sistema)
└── zonas.lua (gestión de áreas de trabajo)
```

### config.lua - Sistema de Configuración

Este archivo centraliza todos los parámetros configurables del sistema:

#### Configuración de Apariencia
```lua
config.skin_default_entrada = "character_33"
config.skin_default_partida = "character_33"
```

#### Configuración Espacial
```lua
config.spawn_global_default = {x = 0, y = 50, z = 0}
config.zona_base_default = 10     -- dimensiones de zona
config.zona_altura_default = 5
config.zona_separacion_default = 20
```

#### Configuración Pedagógica
```lua
config.max_bloques = 13           -- límite de recursos por estudiante
```

#### Configuración de Usuarios
```lua
config.administradores = {"creador", "profe_daniel", "admin"}
-- Sistema automático para 50 estudiantes
for i = 1, 50 do
    table.insert(config.usuarios_permitidos, "estudiante"..i)
end
```

#### Definición de Equipos
El sistema define 15 equipos con características únicas:
```lua
config.zonas_equipo = {
    {nombre = "Equipo Alfa", color = "#FF0000", material = "default:stone", skin = "character_1"},
    {nombre = "Equipo Beta", color = "#00FF00", material = "default:wood", skin = "character_2"},
    -- ... hasta 15 equipos con materiales y colores distintivos
}
```

### zonas.lua - Gestión de Espacios

Este módulo maneja la creación y administración de las áreas de trabajo:

#### Funciones Principales

**Generación de Posiciones**
```lua
function M.generar_posiciones_zonas()
    -- Calcula posiciones en grilla 3x5
    -- Centra las zonas respecto al spawn actual
    -- Asigna coordenadas p1 y p2 para cada área
end
```

**Gestión de Spawns**
```lua
function M.crear_plataforma_spawn()
    -- Crea plataforma 3x3x1 en el spawn actual
    -- Utiliza material configurable
end
```

#### Algoritmo de Distribución Espacial

El sistema organiza las 15 zonas en una grilla de 3 filas por 5 columnas:
- Separación configurable entre zonas
- Centrado automático respecto al spawn
- Cálculo preciso de límites (p1, p2) para cada área

### init.lua - Lógica Principal

Este archivo contiene la implementación central del sistema educativo:

#### Sistema de Permisos

**Funciones de Autorización**
```lua
local function es_administrador(name)
    -- Verifica si el usuario tiene privilegios administrativos
end

local function permitido(name)
    -- Comprueba si el usuario está en la lista de permitidos
end
```

#### Gestión de Inventario con Límites Pedagógicos

**Control de Recursos**
```lua
-- Limite máximo de bloques iguales por estudiante
local max_items_per_type = config.max_bloques

-- Implementación de verificación periódica
minetest.register_globalstep(function(dtime)
    -- Verifica inventarios cada 2 segundos
    -- Elimina excesos automáticamente
    -- Notifica al estudiante sobre limitaciones
end)
```

#### Sistema de Asignación de Equipos

**Algoritmo de Distribución**
```lua
local function asignar_equipos_aleatorios(jugadores_conectados, tam_equipo)
    -- Mezcla aleatoria de jugadores
    math.randomseed(os.time())
    for i = #jugadores_conectados, 2, -1 do
        local j = math.random(i)
        jugadores_conectados[i], jugadores_conectados[j] = 
            jugadores_conectados[j], jugadores_conectados[i]
    end
    
    -- Asignación por grupos del tamaño especificado
    -- Manejo de jugadores sobrantes
end
```

#### Comandos Administrativos

El sistema implementa una interfaz completa de comandos para docentes:

**Comando Principal: /ayuda**
```lua
minetest.register_chatcommand("ayuda", {
    description = "Muestra todos los comandos disponibles",
    func = function(name)
        -- Lista completa de comandos con descripción
        -- Diferencia comandos de estudiante vs administrador
    end,
})
```

**Gestión de Partidas: /iniciar_partida**
```lua
minetest.register_chatcommand("iniciar_partida", {
    params = "<tamaño_equipo>",
    description = "Inicia una nueva partida con equipos de N jugadores",
    privs = {server = true},
    func = function(name, param)
        -- Validación de parámetros
        -- Creación automática de equipos
        -- Asignación de skins y teletransporte
        -- Aplicación de límites de inventario
    end,
})
```

**Control del Entorno: /crear_zonas**
```lua
minetest.register_chatcommand("crear_zonas", {
    description = "Crea las 15 zonas de equipos",
    privs = {server = true},
    func = function(name, param)
        -- Generación de plataformas de trabajo
        -- Aplicación de materiales distintivos
        -- Confirmación de creación exitosa
    end,
})
```

## Manual Técnico Completo

### Configuración del Sistema

#### Instalación

1. Copiar el directorio completo a la carpeta de juegos de Luanti
2. Configurar administradores en mods/equipos/config.lua
3. Ajustar parámetros pedagógicos según necesidades

#### Configuración de Usuarios

**Administradores**
```lua
config.administradores = {"nombre_docente1", "nombre_docente2"}
```

**Estudiantes**
El sistema genera automáticamente usuarios estudiante1 a estudiante50. Para personalizar:
```lua
config.usuarios_permitidos = {"alumno1", "alumno2", "alumno3"}
```

#### Parámetros Pedagógicos

**Límite de Recursos**
```lua
config.max_bloques = 13  -- máximo de bloques iguales por estudiante
```

**Dimensiones de Zona**
```lua
config.zona_base_default = 10    -- ancho y largo en bloques
config.zona_altura_default = 5   -- altura en bloques
```

### Flujo de Trabajo para Docentes

#### Preparación de Clase

1. **Configuración inicial**
   ```
   /crear_plataforma_spawn  -- crear área de reunión
   /crear_zonas            -- preparar áreas de trabajo
   ```

2. **Verificación del entorno**
   ```
   /listar_spawns          -- revisar puntos de aparición
   /estado_zonas           -- verificar áreas de equipo
   ```

#### Durante la Clase

1. **Inicio de actividad**
   ```
   /iniciar_partida 3      -- equipos de 3 estudiantes
   /iniciar_partida 5      -- equipos de 5 estudiantes
   ```

2. **Monitoreo**
   ```
   /ver_equipos            -- estado actual de equipos
   /tp_zona 5              -- visitar zona del equipo 5
   ```

3. **Gestión de incidencias**
   ```
   /reset_inventario nombreEstudiante  -- limpiar inventario
   /tp nombreEstudiante                -- teletransportar estudiante
   ```

#### Finalización de Clase

```
/reset_partida              -- reiniciar sistema completo
/guardar_estado             -- preservar configuración actual
```

### API para Desarrolladores

#### Funciones Públicas del Mod Equipos

**Verificación de Permisos**
```lua
equipos.es_administrador(player_name)  -- retorna boolean
equipos.permitido(player_name)         -- retorna boolean
```

**Gestión de Equipos**
```lua
equipos.obtener_equipo(player_name)    -- retorna nombre_equipo o nil
equipos.listar_equipos()               -- retorna tabla con todos los equipos
```

**Manipulación de Zonas**
```lua
equipos.obtener_zona(numero_equipo)    -- retorna datos de zona
equipos.posicion_en_zona(pos, numero_equipo)  -- verifica si posición está en zona
```

#### Eventos y Callbacks

**Registro de Eventos Educativos**
```lua
-- Callback cuando se forma un equipo
equipos.register_on_team_formed(function(team_name, players)
    -- Lógica personalizada para formación de equipos
end)

-- Callback cuando un jugador excede límites
equipos.register_on_limit_exceeded(function(player_name, item_name, count)
    -- Manejo personalizado de violaciones de límites
end)
```

### Integración con Otros Mods

#### simple_skins - Gestión de Avatares

```lua
-- Actualización segura de skin por equipo
local function safe_update_skin(player_name, skin_id)
    if rawget(_G, "skins") and type(skins.update_player_skin) == "function" then
        skins.skins[player_name] = skin_id
        local p = minetest.get_player_by_name(player_name)
        if p then
            p:get_meta():set_string("simple_skins:skin", skin_id)
            skins.update_player_skin(p)
        end
    end
end
```

#### worldedit - Construcción de Entornos

```lua
-- Creación de zona usando WorldEdit
local function crear_zona_worldedit(p1, p2, material)
    worldedit.set(p1, p2, material)
end
```

## Guía de Desarrollo

### Convenciones de Código

#### Nomenclatura
- Variables locales: snake_case
- Funciones públicas: camelCase
- Constantes: MAYUSCULAS_CON_GUION
- Archivos: minusculas.lua

#### Estructura de Funciones
```lua
-- Comentario descriptivo de la función
local function nombre_funcion(parametros)
    -- Validación de parámetros
    if not parametros then
        return false, "Error: parámetros requeridos"
    end
    
    -- Lógica principal
    local resultado = procesar(parametros)
    
    -- Retorno consistente
    return true, resultado
end
```

#### Manejo de Errores
```lua
-- Siempre retornar estado y mensaje
local success, message = operacion_riesgosa()
if not success then
    minetest.log("error", "Falló operación: " .. message)
    return false, message
end
```

### Patrones de Diseño Utilizados

#### Módulo de Configuración
```lua
-- config.lua - Patrón Singleton para configuración
local config = {}
-- ... definiciones ...
return config
```

#### Sistema de Callbacks
```lua
-- Patrón Observer para eventos del sistema
local callbacks = {}

function equipos.register_callback(event, func)
    if not callbacks[event] then
        callbacks[event] = {}
    end
    table.insert(callbacks[event], func)
end
```

#### Gestión de Estado
```lua
-- Estado global del sistema mantenido en tablas locales
local asignaciones = {}    -- jugador -> equipo
local estado_partida = "inactiva"
local inventarios_limitados = {}
```

### Extensibilidad del Sistema

#### Agregar Nuevos Comandos
```lua
minetest.register_chatcommand("nuevo_comando", {
    description = "Descripción del comando",
    params = "<parametros>",
    privs = {server = true},  -- solo administradores
    func = function(name, param)
        -- Validar permisos
        if not es_administrador(name) then
            return false, "Sin permisos"
        end
        
        -- Lógica del comando
        return true, "Comando ejecutado"
    end,
})
```

#### Crear Nuevos Tipos de Zonas
```lua
-- Extender config.lua con nuevas definiciones
config.zonas_especiales = {
    {nombre = "Zona Libre", tipo = "sandbox", restricciones = false},
    {nombre = "Zona Desafío", tipo = "challenge", tiempo_limite = 1800},
}
```

#### Integrar Métricas Personalizadas
```lua
-- Sistema de métricas extensible
local metricas = {}

function equipos.register_metric(name, calculator_func)
    metricas[name] = calculator_func
end

function equipos.calculate_all_metrics(team_name)
    local resultados = {}
    for metric_name, calc_func in pairs(metricas) do
        resultados[metric_name] = calc_func(team_name)
    end
    return resultados
end
```

## Ejemplos de Uso

### Caso de Uso 1: Actividad de Algoritmos

**Objetivo**: Evaluar comprensión de algoritmos de ordenamiento

**Configuración**:
```lua
-- Configurar equipos de 3 estudiantes
/iniciar_partida 3

-- Preparar materiales específicos
config.materiales_algoritmo = {
    "default:stone",      -- elementos a ordenar
    "default:glass",      -- separadores
    "default:wood"        -- estructura base
}
```

**Desarrollo**:
1. Cada equipo recibe bloques desordenados
2. Deben construir una estructura que represente ordenamiento
3. El sistema limita recursos para fomentar eficiencia

### Caso de Uso 2: Estructuras de Datos

**Objetivo**: Construir representaciones físicas de listas y árboles

**Configuración**:
```lua
-- Equipos más grandes para proyectos complejos
/iniciar_partida 5

-- Zona ampliada para estructuras grandes
config.zona_base_default = 15
config.zona_altura_default = 8
```

**Evaluación**:
- Corrección de la estructura implementada
- Eficiencia en el uso de materiales
- Calidad de la colaboración del equipo

### Caso de Uso 3: Simulación de Redes

**Objetivo**: Crear redes de comunicación entre zonas

**Implementación**:
```lua
-- Permitir construcción entre zonas para ciertos equipos
function equipos.habilitar_conexion_zonas(equipo1, equipo2)
    -- Lógica para permitir construcción compartida
end
```

**Métricas**:
- Tiempo de establecimiento de conexión
- Eficiencia de la ruta creada
- Coordinación entre equipos

## Conclusiones y Próximos Pasos

### Estado Actual del Sistema

LudusTechnical representa una implementación sólida y funcional de un entorno de evaluación educativa. El sistema actual proporciona:

- Base técnica robusta y extensible
- Interfaz administrativa completa para docentes
- Mecánicas educativas bien definidas
- Integración exitosa con el ecosistema Minetest

### Áreas de Mejora Identificadas

1. **Sistema de Métricas**: Implementar recolección automática de datos de rendimiento
2. **Interfaz Gráfica**: Desarrollar panel web para análisis de resultados
3. **Actividades Predefinidas**: Crear biblioteca de desafíos listos para usar
4. **Exportación de Datos**: Sistema para generar reportes académicos

### Recomendaciones para Desarrollo Futuro

La arquitectura modular actual facilita la implementación de estas mejoras sin afectar la funcionalidad existente. Se recomienda mantener la separación de responsabilidades y continuar con las convenciones de código establecidas.

---

**Autor**: prof_daniel  
**Versión**: 1.0  
**Fecha**: 1 de noviembre de 2025  
**Licencia**: Pendiente de definición