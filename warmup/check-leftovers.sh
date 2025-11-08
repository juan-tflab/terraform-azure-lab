#!/bin/bash
# =========================================================
# 🔍 Azure Cleanup Checker - by Nova
# Versión: 1.0
# No destruye nada, solo informa y sugiere cómo limpiar.
# =========================================================

echo "------------------------------------------"
echo "🔎 Iniciando auditoría de recursos en Azure..."
echo "------------------------------------------"

found_anything=false

# 1️⃣ Grupos de recursos vacíos
echo ""
echo "🗂️  Verificando grupos de recursos vacíos..."
for rg in $(az group list --query "[].name" -o tsv); do
  count=$(az resource list --resource-group "$rg" --query "length([])" -o tsv)
  if [ "$count" -eq 0 ]; then
    found_anything=true
    echo "⚠️  Grupo vacío encontrado: $rg"
    echo "👉 Podés borrarlo con:"
    echo "   az group delete --name $rg --yes --no-wait"
    echo ""
  fi
done

# 2️⃣ NICs sin VM asociada
echo ""
echo "🔌 Revisando NICs huérfanas..."
for nic in $(az network nic list --query "[?virtualMachine==null].name" -o tsv); do
  rg=$(az network nic show --name "$nic" --query "resourceGroup" -o tsv)
  found_anything=true
  echo "⚠️  NIC sin VM: $nic  (RG: $rg)"
  echo "👉 Podés borrarla con:"
  echo "   az network nic delete --name $nic --resource-group $rg"
  echo ""
done

# 3️⃣ IPs públicas no asociadas
echo ""
echo "🌐 Revisando IPs públicas no asociadas..."
for pip in $(az network public-ip list --query "[?ipConfiguration==null].name" -o tsv); do
  rg=$(az network public-ip show --name "$pip" --query "resourceGroup" -o tsv)
  found_anything=true
  echo "⚠️  IP pública huérfana: $pip  (RG: $rg)"
  echo "👉 Podés borrarla con:"
  echo "   az network public-ip delete --name $pip --resource-group $rg"
  echo ""
done

# 4️⃣ VNETs sin subnets (versión compatible)
echo ""
echo "🌐 Revisando VNETs sin subnets..."
for vnet in $(az network vnet list --query "[].name" -o tsv); do
  rg=$(az network vnet show --name "$vnet" --query "resourceGroup" -o tsv)
  subnet_count=$(az network vnet show --name "$vnet" --resource-group "$rg" --query "length(subnets)" -o tsv)
  if [ "$subnet_count" -eq 0 ]; then
    found_anything=true
    echo "⚠️  VNET sin subnets: $vnet  (RG: $rg)"
    echo "👉 Podés borrarla con:"
    echo "   az network vnet delete --name $vnet --resource-group $rg"
    echo ""
  fi
done

# 5️⃣ Storage Accounts de estado Terraform (opcional)
echo ""
echo "🪣 Revisando Storage Accounts con nombres tipo 'statetflabjuan'..."
for sa in $(az storage account list --query "[?contains(name, 'statetflabjuan')].name" -o tsv); do
  rg=$(az storage account show --name "$sa" --query "resourceGroup" -o tsv)
  found_anything=true
  echo "ℹ️  Storage Account detectado: $sa  (RG: $rg)"
  echo "👉 Si ya no necesitás el backend remoto, podés borrarlo con:"
  echo "   az storage account delete --name $sa --resource-group $rg --yes"
  echo ""
done

# Resultado final
if [ "$found_anything" = false ]; then
  echo ""
  echo "✅ No se encontraron recursos residuales. ¡Tu entorno está limpio!"
else
  echo "------------------------------------------"
  echo "🔔 Revisión finalizada. Se detectaron recursos pendientes."
  echo "   Revisá los comandos sugeridos arriba para limpiarlos."
  echo "------------------------------------------"
fi

