# KnowIT.Builder

Un módulo de PowerShell diseñado para estandarizar y simplificar el desarrollo de módulos PowerShell propios dentro de KnowIT.

## 📋 Objetivo

KnowIT.Builder proporciona los comandos y funciones necesarias para:

- **Crear nuevos módulos PowerShell** con estructura y configuración estandarizada
- **Generar funciones** siguiendo plantillas predefinidas
- **Gestionar versiones** y metadatos de módulos

El propósito es asegurar consistencia, calidad y mantenibilidad en todos los módulos desarrollados dentro de la organización, facilitando la colaboración y el control de cambios.

## 🚀 Funcionalidades Principales

### New-KnowITModule
Crea un nuevo módulo PowerShell con estructura base estandarizada.

```powershell
New-KnowITModule -Name "KnowIT.NuevoModulo" -Path "C:\repos\Modulos"
```

### New-KnowITModuleFunction
Genera una nueva función dentro de un módulo, aplicando plantillas predefinidas.

```powershell
New-KnowITModuleFunction -Name "Get-KnwoITData"
# Alias: nfunc
```

### Build-KnowITModule
Compila y empaqueta el módulo, validando estructura y versiones.

```powershell
Build-KnowITModule -Version "1.0.0"
# Alias: build
```

## 📦 Requisitos

- PowerShell 7.2 o superior
- Windows PowerShell 5.1+ (compatibilidad parcial)

## ⚙️ Desarrollo

### Estructura del Proyecto

```
src/
├── public/                    # Funciones públicas (exportadas)
├── private/                   # Funciones privadas (internas)
└── KnowIT.Builder.psm1        # Archivo principal del módulo

template/                      # Estructura base para nuevos módulos
├── src/
│   ├── public/
│   ├── private/
│   └── Module.psm1
└── module.psd1                # Manifiesto de ejemplo

module.psd1                    # Manifiesto del módulo KnowIT.Builder
build.ps1                      # Script de construcción para CI/CD
dev-build.ps1                  # Script de construcción para desarrollo
```

### Desarrollo con Sandbox

Ejecuta el sandbox para pruebas durante el desarrollo:

```powershell
.\run.ps1
```

### Construcción Local

Para construir el módulo en tu entorno de desarrollo:

```powershell
.\dev-build.ps1
```

Para construir con una versión específica:

```powershell
.\build.ps1 -Version "1.0.0"
.\build.ps1 -BuildNumber 5
```

## 🤝 Contribución futura

Este módulo se desarrolla con la visión de convertirse en un proyecto open source. La arquitectura modular y el uso de plantillas estandarizadas facilitan la colaboración externa y el mantenimiento comunitario.

## 🙌 Agradecimientos

Este proyecto fue inspirado y construido sobre la idea y conceptos de [ModuleTools](https://github.com/belibug/ModuleTools). Reconocemos el trabajo original y la base que proporcionó para el desarrollo de KnowIT.Builder.

## 📃 Licencia

© 2025 KnowIT Soluciones. Todos los derechos reservados.

## 👤 Autor

José Ramón Aguilar

## 🌐 Idiomas

- Español (LEEME.md)
- [English (README.md)](README.md)