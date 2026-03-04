#!/bin/bash
set -e # Detener el script si algo falla
export AWS_PAGER=""

# --- Configuración ---
ADMIN_PROFILE="admin-dcanosu"
TERRAFORM_PROFILE="terraform"
POLICY_NAME="iam_policy.json"
USER_TARGET="terraform"
LOG_FILE="ansible/deploy_log.txt"
INVENTORY_FILE="ansible/inventories/inventory_list.txt"

echo "🔐 [STEP 1] Configuring IAM Permissions for User: $USER_TARGET"

ACCOUNT_ID=$(aws sts get-caller-identity --profile $ADMIN_PROFILE --query "Account" --output text)
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME"

# 1. Verificar si existe, si no crearla. Si existe, actualizarla.
if ! aws iam get-policy --policy-arn "$POLICY_ARN" --profile "$ADMIN_PROFILE" > /dev/null 2>&1; then
    echo "📜 Creating custom policy..."
    aws iam create-policy --policy-name "$POLICY_NAME" --policy-document file://terraform-policy.json --profile "$ADMIN_PROFILE"
else
    echo "🔄 Policy exists. Uploading new version with IAM permissions..."
    # Creamos una nueva versión y la ponemos como predeterminada
    aws iam create-policy-version \
        --policy-arn "$POLICY_ARN" \
        --policy-document file://terraform-policy.json \
        --set-as-default \
        --profile "$ADMIN_PROFILE"
fi

# 2. Attach policy to the terraform user
echo "🔗 Attaching custom policy to user..."
aws iam attach-user-policy --user-name "$USER_TARGET" --policy-arn "$POLICY_ARN" --profile "$ADMIN_PROFILE"

# 3. Clean up old FullAccess policies
echo "🧹 Cleaning up legacy FullAccess policies..."
DEPRECATED_POLICIES=(
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
    "arn:aws:iam::aws:policy/IAMFullAccess"
)

for policy in "${DEPRECATED_POLICIES[@]}"; do
    aws iam detach-user-policy --user-name "$USER_TARGET" --policy-arn "$policy" --profile "$ADMIN_PROFILE" || echo "⚠️ Policy already detached: $policy"
done

echo "⏳ Waiting 10s for IAM propagation..."
sleep 10

# --- Terraform Execution ---
echo "🏗️ [STEP 2] Starting Terraform Deployment"

cd terraform
export AWS_PROFILE=$TERRAFORM_PROFILE

terraform init -reconfigure
terraform plan -out=tfplan
terraform show -no-color tfplan > tfplan.txt
terraform apply -auto-approve tfplan

echo "✅ Terraform infrastructure deployed successfully!"

echo "📦 Getting AutoScaling Group name from Terraform output..."
ASG_NAME=$(terraform output -raw asg_name)
echo "🔎 ASG_NAME detected: $ASG_NAME"

cd .. # Back to root directory


# --- Ansible Execution ---
echo "🚀 [STEP 3] Running Ansible Configuration"
export AWS_PROFILE=$TERRAFORM_PROFILE
export ANSIBLE_CONFIG="ansible/ansible.cfg"

# 1. Export the current inventory to a text file
echo "📋 Saving inventory list to $INVENTORY_FILE..."

ansible-inventory -i ansible/inventories/aws_ec2.yaml --graph > "$INVENTORY_FILE"

# 2. Run the Playbook and save logs
echo "🛠️ Configuring instances with Docker and Nginx..."
# ansible-playbook ansible/site.yaml | tee "$LOG_FILE"
ansible-playbook ansible/site.yaml -e "asg_name=$ASG_NAME" | tee "$LOG_FILE"

echo "----------------------------------------------------------"
echo "🎉 Deployment Complete!"
echo "Check $INVENTORY_FILE for the list of managed instances."
echo "Check $LOG_FILE for execution details."
echo "----------------------------------------------------------"