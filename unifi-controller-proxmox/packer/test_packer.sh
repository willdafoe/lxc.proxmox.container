#!/bin/bash

# Define variables
PKR_FILE="ubuntu2004.pkr.hcl"
PKR_VARS_FILE="ubuntu2004.pkrvars.hcl"

# Check if Packer is installed
if ! command -v packer &> /dev/null; then
    echo "Error: Packer is not installed. Please install Packer before proceeding."
    exit 1
fi

# Format the Packer HCL file
echo "Formatting Packer template..."
packer fmt "$PKR_FILE"

# Validate the Packer template
echo "Validating Packer template..."
packer validate -var-file="$PKR_VARS_FILE" "$PKR_FILE"
if [ $? -ne 0 ]; then
    echo "Validation failed. Please check your template."
    exit 1
fi

# Run Packer in debug mode (Dry-run)
echo "Running a Packer dry-run..."
packer build -var-file="$PKR_VARS_FILE" -on-error=ask -debug "$PKR_FILE"

echo "Packer test completed!"
