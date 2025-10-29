# 🎓 CodeCraft Academy
### *Entorno Educativo de Programación Colaborativa en 3D*

<div align="center">

![CodeCraft Academy](https://img.shields.io/badge/Version-2.0-blue)
![Luanti](https://img.shields.io/badge/Luanti-5.14.0-green)
![License](https://img.shields.io/badge/License-MIT-orange)
![Educational](https://img.shields.io/badge/Purpose-Educational-purple)

**Desarrollado por**: profeDaniel & GitHub Copilot

</div>

## 📋 Índice
- [Descripción](#-descripción)
- [Características Principales](#-características-principales)
- [Instalación](#-instalación)
- [Configuración](#-configuración)
- [Uso para Docentes](#-uso-para-docentes)
- [Mods Incluidos](#-mods-incluidos)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)

## 🌟 Descripción

CodeCraft Academy es una plataforma educativa revolucionaria que combina la inmersión del mundo 3D con herramientas de programación reales. Permite a estudiantes aprender programación colaborativamente en un entorno gamificado basado en Luanti.

### 🎯 Objetivos Pedagógicos
- **Programación Colaborativa**: Trabajo en equipos con skins compartidos
- **Múltiples Lenguajes**: Python, Lua, Java, Arduino C++
- **Simulación Hardware**: Componentes Arduino virtuales
- **Gestión de Equipos**: Zonas restringidas y recursos limitados
- **Evaluación Integrada**: Sistema de seguimiento pedagógico

## ✨ Características Principales

### 🔧 Editor de Código Integrado (`code_blocks`)
- **Múltiples Lenguajes**: Python, Lua, Java
- **Sintaxis Highlighting**: Resaltado de código en tiempo real
- **Ejecución Inmediata**: Ejecuta código directamente en el mundo 3D
- **Colaboración**: Comparte código entre miembros del equipo
- **Terminales Virtuales**: Entrada/salida visual en el mundo

### 🤖 Simulador Arduino (`arduino_sim`)
- **Arduino UNO Virtual**: Simulación completa de la placa
- **Componentes Electrónicos**: LEDs, botones, sensores
- **IDE Integrado**: Editor de código Arduino en 3D
- **Visualización Real**: LEDs que se encienden/apagan realmente
- **Código C++ Real**: Sintaxis genuina de Arduino

### 👥 Sistema de Equipos (`equipos`)
- **Equipos Aleatorios**: 3 o 5 integrantes automáticamente
- **Skins Compartidos**: Identidad visual de equipo
- **Zonas Restringidas**: 15 áreas de trabajo delimitadas
- **Gestión de Recursos**: Inventario limitado por tipo de bloque
- **Panel de Administración**: Libro azul para docentes

### 📚 Material Pedagógico
- **Guía Completa**: 68 páginas de metodología educativa
- **Planes de Clase**: Actividades estructuradas
- **Evaluación**: Rúbricas y métodos de seguimiento
- **Resolución de Problemas**: Troubleshooting técnico

## 🛠 Instalación

### Requisitos Previos
- **Luanti**: Versión 5.14.0 o superior
- **Sistema Operativo**: Windows, Linux, macOS
- **RAM**: Mínimo 4GB (recomendado 8GB)
- **Conexión**: Para trabajo colaborativo

### Pasos de Instalación

1. **Clonar el Repositorio**
   ```bash
   git clone https://github.com/TU_USUARIO/CodeCraft-Academy.git
   cd CodeCraft-Academy
   ```

2. **Ubicar en Directorio de Juegos de Luanti**
   ```bash
   # Windows
   cp -r LudusTechnical "%APPDATA%\Luanti\games\"
   
   # Linux
   cp -r LudusTechnical ~/.luanti/games/
   
   # macOS
   cp -r LudusTechnical ~/Library/Application\ Support/luanti/games/
   ```

3. **Iniciar Luanti**
   - Abrir Luanti
   - Seleccionar "LudusTechnical" en la lista de juegos
   - Crear nuevo mundo o usar existente

## ⚙️ Configuración

### Configuración de Administradores

Editar `mods/equipos/config.lua`:
```lua
config.administradores = {
    "nombreDocente1",
    "nombreDocente2",
    -- Agregar más docentes según necesidad
}
```

### Configuración de Red (Multijugador)

Para trabajar desde múltiples equipos:

1. **Servidor Dedicado** (Recomendado)
   ```bash
   luanti --server --world /path/to/world --port 30000
   ```

2. **Host Local**
   - Crear mundo en modo "Host game"
   - Configurar puerto (30000 por defecto)
   - Compartir IP con estudiantes

## 👨‍🏫 Uso para Docentes

### Flujo Básico de Clase

1. **Preparación**
   ```
   /crear_zonas          # Crear 15 plataformas de trabajo
   ```

2. **Inicio de Partida**
   ```
   /iniciar_partida 3    # Equipos de 3 estudiantes
   /iniciar_partida 5    # Equipos de 5 estudiantes
   ```

3. **Comandos de Administración**
   ```
   /ayuda               # Ver todos los comandos
   /tp_zona 1           # Teletransporte a zona específica
   /reset_equipos       # Reiniciar configuración de equipos
   ```

### Panel de Administración
- **Libro Azul**: Acceso rápido a funciones administrativas
- **Interfaz Visual**: Botones para acciones comunes
- **Monitoreo**: Seguimiento de actividades por equipo

## 📦 Mods Incluidos

| Mod | Función | Estado |
|-----|---------|--------|
| `code_blocks` | Editor de código integrado | ✅ Completo |
| `arduino_sim` | Simulador Arduino | ✅ Completo |
| `equipos` | Gestión de equipos y zonas | ✅ Completo |
| `worldedit` | Herramientas de edición | ✅ Incluido |
| `default` | Nodos básicos | ✅ Incluido |
| `flow` | Interfaz de usuario | ✅ Incluido |

## 🔄 Sincronización Entre Equipos

### Configuración para Trabajo Multi-Equipo

1. **Repositorio GitHub**
   ```bash
   git add .
   git commit -m "Configuración inicial"
   git push origin main
   ```

2. **En el Segundo Equipo**
   ```bash
   git clone https://github.com/TU_USUARIO/CodeCraft-Academy.git
   ```

3. **Sincronización Regular**
   ```bash
   # Antes de trabajar
   git pull origin main
   
   # Después de trabajar
   git add .
   git commit -m "Descripción de cambios"
   git push origin main
   ```

### ⚠️ Consideraciones Importantes

- **NO subir archivos de mundo**: `.gitignore` los excluye automáticamente
- **Configuración local**: Mantener archivos de configuración específicos localmente
- **Backup regular**: Respaldar mundos importantes antes de cambios grandes

## 📖 Documentación Adicional

- **[Guía Pedagógica Completa](GUIA_PEDAGOGICA_CODECRAFT.md)**: 68 páginas de metodología
- **[Manual de Instalación](docs/installation.md)**: Guía detallada paso a paso
- **[API de Desarrollo](docs/api.md)**: Para desarrolladores de mods
- **[Troubleshooting](docs/troubleshooting.md)**: Solución de problemas comunes

## 🤝 Contribuir

¡Las contribuciones son bienvenidas! Por favor:

1. Fork el repositorio
2. Crear rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Crear Pull Request

### Áreas de Contribución Prioritarias
- 🎮 Sistema de gamificación y logros
- 📊 Analytics y evaluación automática
- 🌐 Localización a otros idiomas
- 🔧 Nuevos simuladores (Raspberry Pi, microcontroladores)
- 📱 Interfaz móvil/tablet

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo [LICENSE.txt](LICENSE.txt) para más detalles.

## 👏 Reconocimientos

- **Luanti Community**: Por la plataforma base
- **Minetest Developers**: Por el motor original
- **WorldEdit Team**: Por las herramientas de edición
- **Estudiantes y Docentes**: Por feedback y testing

---

<div align="center">

**CodeCraft Academy** - Donde la programación cobra vida en 3D

[🌟 Star este proyecto](https://github.com/TU_USUARIO/CodeCraft-Academy) | [🐛 Reportar Bug](https://github.com/TU_USUARIO/CodeCraft-Academy/issues) | [💡 Sugerir Feature](https://github.com/TU_USUARIO/CodeCraft-Academy/issues)

</div>