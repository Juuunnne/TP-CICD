#!/usr/bin/env bash
# restore_snapshot.sh
# Restore latest snapshot for VM protected by Azure Backup
# Usage: ./restore_snapshot.sh <resource_group> <vault_name> <backup_instance_name>
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <resource_group> <vault_name> <backup_instance_name>" >&2
  exit 1
fi

RG=$1
VAULT=$2
BI_NAME=$3

echo "Retrieving latest recovery point..."
RECOVERY_POINT=$(az dataprotection backup-instance list-recovery-points \
  --resource-group "$RG" \
  --vault-name "$VAULT" \
  --backup-instance-name "$BI_NAME" \
  --query "[-1].name" -o tsv)

if [[ -z "$RECOVERY_POINT" ]]; then
  echo "No recovery point found for $BI_NAME" >&2
  exit 1
fi

echo "Initiating restore using recovery point $RECOVERY_POINT..."
az dataprotection backup-instance restore initialize-for-item-level-recovery \
  --resource-group "$RG" \
  --vault-name "$VAULT" \
  --backup-instance-name "$BI_NAME" \
  --recovery-point-id "$RECOVERY_POINT" \
  --target-resource-id "$BI_NAME" \
  --no-wait

echo "Restore triggered. Monitor progress in Azure Portal." 