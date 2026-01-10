# KnowIT.Builder

A PowerShell module designed to standardize and simplify the development of PowerShell modules within KnowIT.

> 🚧 This module is in **early stage** of development.

## 📋 Overview


KnowIT.Builder provides the commands and functions necessary to:

- **Create new PowerShell modules** with standardized structure and configuration
- **Generate functions** following predefined templates
- **Manage versions** and module metadata

The purpose is to ensure consistency, quality, and maintainability across all modules developed within the organization, facilitating collaboration and change control.

## 🚀 Main Features

### New-KnowITModule
Creates a new PowerShell module with standardized base structure.

```pwsh
PS> New-KnowITModule -Name KnowIT.NewModule -Path C:\repos\Modules
```

### New-KnowITModuleFunction
Generates a new function within a module, applying predefined templates.

```pwsh
PS> New-KnowITModuleFunction -Name Get-KnowITData

# or with alias:
PS> nfunc GetKnowITData
```

### Build-KnowITModule
Compiles and packages the module, using versioning configured in the manifest.

```pwsh
PS> Build-KnowITModule

# or with alias
PS> build
```

## 📦 Requirements

- PowerShell 7.2 or higher
- Windows PowerShell 5.1+ (partial compatibility)

## ⚙️ Development

### Project Structure

```text
src/
├── public/                    # Public functions (exported)
├── private/                   # Private functions (internal)
└── KnowIT.Builder.psm1        # Main module file

template/                      # Base structure for new modules
├── src/
│   ├── public/
│   ├── private/
│   └── Module.psm1
└── module.psd1                # Example manifest

module.psd1                    # KnowIT.Builder module manifest
build.ps1                      # Build script for CI/CD
dev-build.ps1                  # Build script for development
```

### Development Sandbox

Run the sandbox for testing during development:

```powershell
.\run.ps1
```

### Local Build

To build the module in your development environment:

```powershell
.\dev-build.ps1
```

To build with a specific version:

```powershell
.\build.ps1 -Version "1.0.0"
.\build.ps1 -BuildNumber 5
```

## 🤝 Contributing

This module is developed with the vision of becoming an open source project. The modular architecture and use of standardized templates facilitate external collaboration and community maintenance.

## 🙌 Acknowledgments

This project was inspired by and built upon the idea and concepts from [ModuleTools](https://github.com/belibug/ModuleTools). We acknowledge the original work and the foundation it provided for KnowIT.Builder's development.

## 📃 License

© 2025 KnowIT Soluciones. All rights reserved.

## 👤 Author

José Ramón Aguilar

## 🌐 Languages

- [Español (LEEME.md)](LEEME.md)
- English (README.md)
