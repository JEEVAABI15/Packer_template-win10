# Packer Template for Azure ARM

## Overview
This repository contains a **Packer template** for building a **Windows 10 image** on **Azure** using environment variables for authentication and configuration. The process involves:

- Using **Azure Service Principal** for authentication
- Defining **variables** in a `.env` file
- Running **Packer** to build and deploy the image
- Installing updates and applications using PowerShell scripts

## Prerequisites

Ensure you have the following installed:
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- [Packer](https://www.packer.io/downloads)
- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell)

## Step 1: Configure Azure Service Principal

To authenticate, create a **Service Principal** and assign it the necessary roles:

```sh
az login
az account show --query id --output tsv
az ad sp create-for-rbac --name "PackerSP" --role "Contributor" --scopes "/subscriptions/YOUR_SUBSCRIPTION_ID"
```

Replace `YOUR_SUBSCRIPTION_ID` with your actual subscription ID. This will return values such as `client_id`, `client_secret`, `tenant_id`, and `subscription_id`, which you will use in the next step.

## Step 2: Set Up Environment Variables

Create a `.env` file and add the following values:

```sh
CLIENT_ID=<APPID>
CLIENT_SECRET=<PASSWORD>
TENANT_ID=<TENANT>
SUBSCRIPTION_ID=<SUBID>
RESOURCE_GROUP=<YourResourceGroup>
```

## Step 3: Packer Template Configuration

The `packer-template.json` file uses environment variables for authentication:

```json
{
  "variables": {
    "client_id": "{{env `CLIENT_ID`}}",
    "client_secret": "{{env `CLIENT_SECRET`}}",
    "tenant_id": "{{env `TENANT_ID`}}",
    "subscription_id": "{{env `SUBSCRIPTION_ID`}}",
    "resource_group": "{{env `RESOURCE_GROUP`}}"
  },
  "builders": [
    {
      "type": "azure-arm",
      "client_id": "{{user `client_id`}}",
      "client_secret": "{{user `client_secret`}}",
      "tenant_id": "{{user `tenant_id`}}",
      "subscription_id": "{{user `subscription_id`}}",
      "managed_image_resource_group_name": "{{user `resource_group`}}",
      "managed_image_name": "Win10",
      "os_type": "Windows",
      "image_publisher": "MicrosoftWindowsDesktop",
      "image_offer": "Windows-10",
      "image_sku": "win10-22h2-pro",
      "communicator": "winrm",
      "winrm_use_ssl": true,
      "winrm_insecure": true,
      "winrm_timeout": "10m",
      "winrm_username": "packer",
      "azure_tags": {
        "dept": "Engineering",
        "task": "Image deployment"
      },
      "build_resource_group_name": "{{user `resource_group`}}",
      "vm_size": "Standard_B1s"
    }
  ],
  "provisioners": [
    {
      "type": "powershell",
      "scripts": [
        "scripts/windows-updates.ps1",
        "scripts/install-apps.ps1"
      ]
    }
  ]
}
```

## Step 4: PowerShell Scripts

**`scripts/windows-updates.ps1`** - Installs Windows updates
```powershell
Install-Module PSWindowsUpdate -Force -Scope CurrentUser
Get-WindowsUpdate -AcceptAll -Install -AutoReboot
```

**`scripts/install-apps.ps1`** - Install required applications (Modify as needed)
```powershell
Write-Host "Installing applications..."
```

## Step 5: Run Packer Build

### Load Environment Variables
First, export the `.env` variables:

```sh
export $(grep -v '^#' .env | xargs)
```

### Validate Packer Template
```sh
packer validate packer-template.json
```

### Build the Image
```sh
packer build packer-template.json
```

## Step 6: Verify Image in Azure
After successful completion, verify the image in Azure:

```sh
az image list --resource-group <yourResourceGroup> --output table
```

This should display the newly created `Win10` image.

## Conclusion
This **Packer template** allows you to automate the creation of **Windows 10 VM images** on **Azure**, using secure environment variables for authentication. You can customize the scripts to include additional software and configurations as needed.

