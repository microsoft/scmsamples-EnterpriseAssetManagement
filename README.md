# Asset Management Mobile App Onboarding Guide

This guide explains how to set up Microsoft Dynamics 365 Supply Chain Management and Dataverse for the Asset Management mobile app, install the app, and configure users for access.

---

## Prerequisites

### 1. System Requirements
- You must be using **Microsoft Dynamics 365 Supply Chain Management version 10.0.36 or later**.

### 2. Set Up a Dataverse Environment
The Asset Management mobile app relies on **Dataverse**. You must ensure your environment is properly configured.

#### Steps:
1. Sign in to the **Power Platform admin center**:  
   [https://admin.powerplatform.microsoft.com](https://admin.powerplatform.microsoft.com)
2. Go to **Environments > New**.
3. Set up a new environment or choose an existing one.
4. Make sure the **"Enable Dynamics 365 apps"** option is turned on.
5. Ensure **Power Apps Component Framework (PCF)** is enabled.

---

## Licensing Requirements
Each user must have a **valid Microsoft Entra ID license** and the required **security roles**.

### Required Roles:
- **Asset Management Mobile Application User Role** (in Dataverse)
- **Finance and Operations Basic User** (for Supply Chain Management)

To review licensing details, see the [Dynamics 365 Licensing Guide](https://go.microsoft.com/fwlink/?LinkId=866544).

---
## Prerequisites
### Pac CLI
-Install [Microsoft Power Apps CLI](https://aka.ms/PowerAppsCLI).
   (For VM users) If you don't have permissions to install the Power Apps CLI Standalone SDK, you can use [Power Apps CLI via its VS Code Extension](https://docs.microsoft.com/en-us/powerapps/developer/data-platform/powerapps-cli?WT.mc_id=BA-MVP-5004107#using-power-platform-vs-code-extension)
-[Power Platform Tool](https://dev.azure.com/dynamicscrm/_apis/resources/Containers/17976494/ArtifactsRelease?itemPath=ArtifactsRelease%2FRelease%2FCdsVSToolKit%2F2019%2FCRMDeveloperTools%2FRelease%2FPowerPlatformTools.vsix) for Visual Studio.
## Generate a new Canvas App binary
- Run the script 
```powershell
.\scripts\MsAppPackTool.ps1
```
- This generates **msdyn_assetmanagementv2_bbd03.msapp** under **/Solution/Export/CanvasApps**, which is compiled based on the source code at /CanvasAppSource

---

## Generate a new Solution
- Run the script 
```powershell
.\scripts\SolutionPackTool.ps1
``` 
- AssetManagementMobileSolution_managed.zip and AssetManagementMobileSolution.zip are now in /bin
---

## Installing the Mobile App in Dataverse

Follow these steps to install the **Dynamics 365 Asset Management Mobile Application** in Dataverse:

1. **Go to the PowerApps Portal**:  
   [https://make.powerapps.com](https://make.powerapps.com)
2. **Go to Solutions in the left pane tab**
3. **Import Solution**
4. Optional: You might need to sign the solution file first, if your org demands solutions to be signed
5. **Select either the managed or unmanaged zip file from /Solution/release**

---

## Applying changes
- Open the Asset Management App with edit mode in PowerApps
- Make necessary changes there
- Download a copy of an app
- Unpack the downloaded **.msapp** into this repository by running the script
```powershell
\scripts\MsAppUnpackTool.ps1 <msapp_file_path>
```
- Your changes are now reflected in /CanvasAppSource and /CanvasAppReviewSource
- You can now Generate a new app binary, followed by a new solution, using the steps above.
---

### Localization (translation)

All translations are found in the [`/Translations`](/Translations/) directory. The baseline is [`en-US`](/Translations/Labels.en-US.resx).

#### Adding a new label

To add a new label, use [ResX Resource Manager](https://github.com/dotnet/ResXResourceManager) and add it to the en-US column. Add a comment if appropriate.

The labels will be translated by the l11n team and they will detect when changes are made. There should be no need to reach out to anyone for translations.

#### Uptaking label changes

Once a new label is added or l11n team has translated new labels, they should be injected into the Canvas app. Follow these steps:

1. Run the script:
   ```powershell
   .\build\scripts\LocalizerTool.ps1 -CopyToClipboard
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

## Granting Access to Users

Once the app is installed, you must share it and assign security roles.

### 1. Share the App with Users
1. Open **Power Apps**.
2. Navigate to **Apps** and find **"Asset Management V2"**.
3. Click on the three dots **(...)** next to the app.
4. Select **Share**.
5. Enter the users’ email addresses and click **Share**.

### 2. Assign User Roles in Dataverse
Each user must be assigned the correct security roles.

#### Steps:
1. Open **Power Platform admin center**.
2. Go to **Environments > Select your environment**.
3. Click **Settings > Users + permissions > Users**.
4. Find the user and click their name.
5. Click **Manage roles** and assign:
   - **"Asset Management Mobile Application User Role"**.
   - **"Finance and Operations Basic User"**.
6. Click **Save**.

---

## Additional Resources
For more details, refer to the official Microsoft documentation:  
[Onboarding the Asset Management Mobile App](https://learn.microsoft.com/en-us/dynamics365/supply-chain/asset-management/asset-management-mobile-app/onboard-app).
