#!/bin/bash
set -e
export AWS_PAGER=""

POLICY_NAME="terraform-policy"
POLICY_FILE="terraform-policy.json"
USER_TARGET="terraform"

echo "[PRE-FLIGHT] Updating IAM Permissions for $USER_TARGET"

ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
POLICY_ARN="arn:aws:iam::$ACCOUNT_ID:policy/$POLICY_NAME"

if ! aws iam get-policy --policy-arn "$POLICY_ARN" > /dev/null 2>&1; then
    echo "Creating new policy..."
    aws iam create-policy --policy-name "$POLICY_NAME" --policy-document file://"$POLICY_FILE"
else
    echo "Updating policy version..."
    aws iam create-policy-version \
        --policy-arn "$POLICY_ARN" \
        --policy-document file://"$POLICY_FILE" \
        --set-as-default
fi

echo "Attaching policy to user..."
aws iam attach-user-policy --user-name "$USER_TARGET" --policy-arn "$POLICY_ARN"

echo "IAM setup complete. Waiting for propagation..."
sleep 10