# Hitchhiker's Guide to Multitenant environments

This folder contains the presentation and scripts, themes presented during PSConfEU session.

> All of this will make a lot more sense when the session recordings are released.

##  Prerequisites

### Dedicated Microsoft Edge or Google Chrome profiles

> Highly recommended to use a different browser release for this other than your default browser.

To support the easies sign-in flow into the appropriate tenants use dedicated browser profiles for every tenant you need to manage.

### Windows Terminal profiles

Make sure you have dedicated Windows Terminal profiles set up for every Tenant you manage, and that you updated the Profiles ID which is the `guid` property to match your Tenant ID

![image](https://github.com/sassdawe/2024/assets/10754765/004a1cd5-4bfa-495e-95ab-db0486e958a9)

The Tenant ID stored in the `guid` field will be used by the PowerShell $PROFILE customizations.

### PowerShell Profile

The PowerShell profile needs to contain or load & execute the code found inside the `sample-profile.ps1` file. 

This code will ensure that every dedicated Windows Terminal tab will automatically connect to the specified tenant and only that tenant using the device code flow without ever needing to specify any required paramater for login.

For this purpose the default paramaters are set inside the profile:

```PowerShell
        $PSDefaultParameterValues["Connect-AzAccount:UseDeviceAuthentication"] = $true
        $PSDefaultParameterValues["Connect-AzAccount:Scope"] = "Process"
        $PSDefaultParameterValues["Connect-AzAccount:Tenant"] = $tenantId.trim('{}')
```

### Oh-my-posh

Install oh-my-posh with the appropriate nerdfonts (I use `LiterationMono Nerd Font Mono`) so you can also use the custom oh-my-posh theme `cloud-native-azure-plus.omp.json` found here

> this `cloud-native-azure-plus.omp.json` theme will later be submitted to be included as an official themse.

This themse will show you when you connected or not to Azure, and also going to tell you when you are only connected with one technology or when you are connected to different tenants with them:

![image](https://github.com/sassdawe/2024/assets/10754765/64a5db56-f68b-4756-b41a-605c50a3469a)

## Extra

### Colorize the Azure Portal

You can no only use Themes for Edge / Chrome, but you can also use some colors for the Azure Portal using the [AzColorizer browser extension](https://github.com/sassdawe/AzColorizerPreview) to match the color of your tab in Windows Terminal 🌈

![image](https://github.com/sassdawe/2024/assets/10754765/12c32823-d92b-44ba-99ef-ad91da3c19e9)
