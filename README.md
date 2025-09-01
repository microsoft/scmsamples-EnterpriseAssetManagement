# Asset Management Mobile App Onboarding Guide

This guide explains how to set up Microsoft Dynamics 365 Supply Chain Management and Dataverse for the Asset Management mobile app, install the app, and configure users for access.

---

## Prerequisites

### 1. System Requirements
- You must be using **Microsoft Dynamics 365 Supply Chain Management version 10.0.36 or later**.

### 2. Set Up a Dataverse Environment
The Asset Management mobile app relies on **Dataverse**. You must ensure your environment is properly configured.

#### Steps:
1. Sign in to the **Power Platform admin center**: [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)
2. Navigate to **Environments > New**.
3. Set up a new environment or choose an existing one.
4. Ensure **"Enable Dynamics 365 apps"** is enabled.
5. Ensure **Power Apps Component Framework (PCF)** is enabled.

---

## Licensing Requirements
Each user must have a **valid Microsoft Entra ID license** and the required **security roles**.

### Required Security Roles:
- **Asset Management Mobile Application User Role** (in Dataverse)
- **Finance and Operations Basic User** (for Supply Chain Management)

To review licensing details, please see the [Dynamics 365 Licensing Guide](https://go.microsoft.com/fwlink/?LinkId=866544).

---
# Build, install, and other development processes
## Prerequisites
### Microsoft Power Platform CLI
- Install [Microsoft Power Platform CLI](https://aka.ms/PowerAppsCLI).

## Generate a new Canvas App binary
- Run the script 
```powershell
.\scripts\MsAppPackTool\MsAppPackTool.ps1
```
- This generates **msdyn_assetmanagementv2_bbd03_DocumentUri.msapp** under **/Solution/Export/CanvasApps**, which is compiled based on the source code at /CanvasAppSource

---

## Generate a new solution
- Run the script 
```powershell
.\scripts\SolutionPackTool\SolutionPackTool.ps1
``` 
- This generates **msdyn_AssetManagementMobileSolution_managed.zip** and **msdyn_AssetManagementMobileSolution.zip** under **/bin**
---

## Installing the Mobile App in Dataverse

Follow these steps to install the **Dynamics 365 Asset Management Mobile Application** in Dataverse:

1. **Navigate to the PowerApps Portal**: [https://make.powerapps.com](https://make.powerapps.com)
2. **Navigate to the Solutions tab on the left side**
3. Select **Import Solution**
4. Optional: You might need to sign the solution file first, if your organization demands solutions to be signed - [Sign Tool](https://learn.microsoft.com/en-us/dotnet/framework/tools/signtool-exe)
5. **Import either the managed or unmanaged zip file from /bin**

---

## Applying changes
- Open the Asset Management App in edit mode from the PowerApps portal
- Make the required changes there
- Download a copy of the app
- Unpack the downloaded **.msapp** into this repository by running the script
```powershell
.\scripts\MsAppUnpackTool\MsAppUnpackTool.ps1 <msapp_file_path>
```
- Your changes are now reflected in /CanvasAppSource
- You can now generate a new app binary, followed by a new solution, using the steps described above.
---

### Localization (translation)
All translations are found in the [`/Translations`](/Translations/) directory. The baseline is [`en-US`](/Translations/Labels.en-US.resx).

#### Uptaking label changes

Once a new label is added, they should be injected into the Canvas app. Follow these steps:

1. Run the script:
   ```powershell
   .\scripts\LocalizerTool\LocalizerTool.ps1 -CopyToClipboard
   ```
   * You will now have the translations in your clipboard.
2. Edit the Canvas app in Power Apps studio.
3. Modify `App -> OnStart` and replace everything between the lines:
   ```csharp
   //localizer:gen-start
   ...
   //localizer:gen-end
   ```
   > To select the existing generated code, put your cursor right before the `With({`, then while holding `Shift`, press `End` twice and finally `Ctrl+V` to paste in the newly generated translation data.

---

## Additional Resources
For more details, including **security roles** and **Finance and Operations Asset Management setup** , refer to the official Microsoft documentation:  
[Onboarding the Asset Management Mobile App](https://learn.microsoft.com/en-us/dynamics365/supply-chain/asset-management/asset-management-mobile-app/onboard-app).

---

## Third-party code and tools

This repository does not vendor third-party source code. It relies on Microsoft tooling including Microsoft Power Platform CLI (PAC) and Power Apps packaging utilities as described above. Any third-party assets referenced at build or runtime are subject to their own licenses and are not included in this repository.

## Telemetry and diagnostics

This app may surface limited diagnostics and error tracing provided by the Power Apps platform.

- How to disable: set `appinsightserrortracing` to `false` in `CanvasAppSource/Properties.json`, then rebuild/pack the app. Disabling diagnostics may reduce troubleshooting capability.
- No personal data should be intentionally collected by this repository's code. Review your environment’s policies and telemetry configuration before deployment.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft’s Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party’s policies.

## Support

See [SUPPORT.md](./SUPPORT.md) for how to get help and our support policy.
