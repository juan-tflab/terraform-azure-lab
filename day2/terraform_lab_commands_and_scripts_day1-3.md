# Terraform Azure Lab – Días 1 a 3 – Comandos y Scripts Técnicos

**Generado:** 2025-11-09

Contenido: comandos agrupados por tipo de tarea; scripts completos al final.

---

## 1. Configuración de entorno y variables

```bash
# Exportar variables necesarias para Azure/Terraform
export ARM_SUBSCRIPTION_ID="<tu_subscription_id>"  # ID de la suscripción Azure
export ARM_TENANT_ID="<tu_tenant_id>"              # ID del tenant Azure AD
export ARM_CLIENT_ID="<tu_client_id>"              # AppId del Service Principal
export ARM_CLIENT_SECRET="<tu_client_secret>"      # Secret del SP
export TF_VAR_location="eastus"                    # Variable TF para la ubicación por defecto
```

## 2. Gestión de Git y repositorios

```bash
# Inicializar repo (si es necesario)
git init                                        # Inicializa repositorio local
git remote add origin https://github.com/juan-tflab/terraform-azure-lab.git  # Añadir remoto

# Obtener ramas remotas y crear/usar main
git fetch origin                                # Descarga refs y objetos del remoto
git checkout -b main origin/main                # Crea y posiciona la rama main local

# Flujo básico de commit/push
git add .                                       # Añade cambios al índice (staging)
git commit -m "Mensaje descriptivo"             # Crea commit
git push --set-upstream origin main             # Sube y establece upstream (si es la primera vez)

# Inspección del índice y archivos rastreados
git diff --cached --name-only                   # Lista archivos staged
git ls-files                                    # Lista todos los archivos tracked
git status --ignored                             # Muestra also ignored files
```

## 3. Terraform: inicialización, plan, apply, destroy

```bash
# Inicializar y descargar providers
terraform init                                  # Inicializa el directorio Terraform

# Validación y formateo
terraform fmt -recursive                        # Formatea código en todos los módulos
terraform validate                               # Valida la configuración

# Plan y aplicar
terraform plan -out=tfplan                       # Genera plan almacenado
terraform apply tfplan                           # Aplica el plan

# Destruir (limpieza)
terraform destroy -auto-approve                  # Elimina todos los recursos creados por TF
```

## 4. Backend y manejo de estado

```bash
# Reconfigurar backend (útil después de mover carpetas)
terraform init -reconfigure                      # Reconfigura backend sin modificar recursos

# Revisar estado y listas
terraform state list                             # Lista recursos en el state
terraform state pull > current_state.tfstate     # Extrae el state remoto a un archivo local
terraform refresh                                # Actualiza el state local con la infra real
```

## 5. Automatización y documentación (terraform-docs)

```bash
# Generar documentación para el módulo actual
# Nota: ejecutar desde la carpeta que contiene main.tf del módulo
terraform-docs markdown table . > docs.md        # Crea docs.md con inputs/outputs/providers

# Si terraform-docs no está en PATH, ajustar ruta: e.g. $HOME/bin/terraform-docs
$HOME/bin/terraform-docs markdown table ./day2 > day2/docs.md
```

## 6. Hooks y scripts de pre-commit (automatizar docs)

```bash
# Ejemplo de hook .git/hooks/pre-commit (guardar como .git/hooks/pre-commit y dar execute)
#!/bin/bash
# Genera docs.md para cada subdirectorio day* que tenga main.tf y los añade al commit
for dir in $(find . -type d -maxdepth 2 -name "day*" -o -name "warmup"); do
  if [ -f "$dir/main.tf" ]; then
    echo "Generando documentación para $dir"
    terraform-docs markdown table "$dir" > "$dir/docs.md"  # Genera docs
    git add "$dir/docs.md"                                # Añade al commit
  fi
done
echo "Documentación actualizada automáticamente antes del commit"
```

## 7. Limpieza de caché Git y archivos grandes

```bash
# Quitar archivos previamente trackeados que ahora están en .gitignore
git rm -r --cached .terraform                       # Elimina .terraform del índice sin borrar localmente
git rm --cached path/to/large_file                  # Elimina archivo grande del índice
git commit -m "Remove large files from index per .gitignore"
git push --force                                   # Forzar push si reescribiste el historial (usar con precaución)
```

## 8. Comandos de Azure útiles (inspección y costos)

```bash
# Inspección VM y estado
az vm list -d -o table                              # Lista VMs y PowerState
az resource list --resource-group rg-tflab-day2 -o table  # Lista recursos de un RG

# Costos (via Cost Management)
az costmanagement query --type Usage --timeframe MonthToDate --dataset-aggregation cost=sum --output table
# o
az consumption usage list --start-date 2025-11-01 --end-date 2025-11-07 -o table

# Ver la cuenta activa
az account show --output table
```

---

## Scripts completos

### precheck.sh

```bash
#!/usr/bin/env bash
# precheck.sh — Validación básica del entorno Terraform y Azure
echo "🔎 Verificando entorno Terraform y Azure..."
echo "==> Terraform version:"
terraform -version || { echo "Terraform no encontrado"; exit 1; }
echo "==> Azure CLI version:"
az version | grep '"azure-cli"' || echo "Azure CLI no encontrada"
echo "==> Azure account check:"
az account show --output table || echo "No se encontró sesión activa de Azure"
echo "==> Variables ARM configuradas:"
env | grep ARM_ || echo "Variables ARM no configuradas"
echo "==> Terraform working directory:"
pwd
ls -la

```

### generate-docs.sh

```bash
#!/usr/bin/env bash
# generate-docs.sh — Genera docs.md para todos los módulos y entornos day*
set -e
if ! command -v terraform-docs &> /dev/null; then
  echo "terraform-docs no está en PATH. Instalalo o poné la ruta completa."
  exit 1
fi
BASE_DIR=$(pwd)
for module in "$BASE_DIR"/modules/*/; do
  [ -d "$module" ] || continue
  echo "Documentando módulo: $module"
  (cd "$module" && terraform-docs markdown table . > DOCS.md)
done
for envdir in "$BASE_DIR"/day*/; do
  [ -d "$envdir" ] || continue
  echo "Documentando entorno: $envdir"
  (cd "$envdir" && terraform-docs markdown table . > DOCS.md)
done
echo "Documentación actualizada."

```

### cleanup_terraform.sh

```bash
#!/usr/bin/env bash
# cleanup_terraform.sh — Destruye la infraestructura y borra artefactos locales
terraform destroy -auto-approve
rm -rf .terraform
rm -f terraform.tfstate terraform.tfstate.backup
echo "Limpieza completa."

```

### .gitignore

```bash
.terraform/
*.tfstate
*.tfstate.backup
*.tfvars
.terraform.lock.hcl
crash.log
docs.md

```

