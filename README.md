# Dynamics 365 Asset Management Mobile App

The Asset Management mobile app is a [Power Apps canvas app](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/getting-started) that provides Asset Management capabilities for **Microsoft Dynamics 365 Supply Chain Management**. Maintenance workers can use it to manage assigned work orders, create maintenance requests, and create new work orders.

See the [Asset Management mobile app overview](https://learn.microsoft.com/en-us/dynamics365/supply-chain/asset-management/asset-management-mobile-app/asset-management-mobile-app-overview) on Microsoft Learn for the full feature description.

Licensed under MIT. See [LICENSE](./LICENSE).

## Prerequisites

### Environment

- **Microsoft Dynamics 365 Supply Chain Management** version 10.0.36 or later.
- A **Dataverse environment** with:
  - Dynamics 365 apps enabled
  - Power Apps Component Framework (PCF) enabled

  To configure, sign in to the [Power Platform admin center](https://admin.powerplatform.microsoft.com), then navigate to **Environments → New** and create or update an environment with both options enabled.

### Licensing and security roles

Each user requires a valid **Microsoft Entra ID** license, plus the following security roles:

- **Asset Management Mobile Application User Role** (in Dataverse)
- **Finance and Operations Basic User** (for Supply Chain Management)

For full licensing details, see the [Dynamics 365 Licensing Guide](https://go.microsoft.com/fwlink/?LinkId=866544).

### Build tooling

To build the app from source, install [Microsoft Power Platform CLI (PAC)](https://aka.ms/PowerAppsCLI).

## Building the app

### Generate the canvas app binary

```powershell
.\scripts\MsAppPackTool\MsAppPackTool.ps1
```

This compiles [CanvasAppSource/](./CanvasAppSource/) into `msdyn_assetmanagementv2_bbd03_DocumentUri.msapp` under [Solution/Export/CanvasApps/](./Solution/Export/CanvasApps/).

### Generate the solution

```powershell
.\scripts\SolutionPackTool\SolutionPackTool.ps1
```

This produces both managed and unmanaged solution archives under [/bin](./bin/):

- `msdyn_AssetManagementMobileSolution.zip` (unmanaged)
- `msdyn_AssetManagementMobileSolution_managed.zip` (managed)

> **Publisher and customization prefix.** This solution is configured with Microsoft (`microsoftdynamics`, prefix `msdyn`) as the publisher in [Solution/Export/Other/Solution.xml](./Solution/Export/Other/Solution.xml). Builds produced from this source as-is will be Microsoft-published, which is fine for in-tenant use and testing but not appropriate for redistribution under another brand. To redistribute or republish under your own brand, change the `<Publisher>` block and update the customization prefix throughout the source before building.

## Installing the app

Once you have a solution `.zip` from the previous step:

1. Sign in to [Power Apps Studio](https://make.powerapps.com).
2. Open the **Solutions** tab.
3. Select **Import solution** and choose either the **managed** or **unmanaged** zip from [/bin](./bin/):
   - **Managed** locks the components against direct modification. Appropriate for end-user installs that you don't intend to deeply customize.
   - **Unmanaged** leaves components open for editing in the maker portal. Appropriate if you intend to study or modify the app's internals.
4. *(Optional)* If your organization requires signed solutions, sign the `.zip` with [SignTool](https://learn.microsoft.com/en-us/dotnet/framework/tools/signtool-exe) before importing.

## Customizing the app

### Applying canvas app changes back to source

This is the standard PAC CLI round-trip pattern for Power Apps canvas apps. See [ALM for Power Platform](https://learn.microsoft.com/en-us/power-platform/alm/) on Microsoft Learn for broader CI/CD options.

If you edit the canvas app in the maker portal and want those changes reflected in this repository:

1. Download a copy of the app from Power Apps Studio (this produces an `.msapp` file).
2. Run:
   ```powershell
   .\scripts\MsAppUnpackTool\MsAppUnpackTool.ps1 <path-to-msapp>
   ```
   This unpacks the `.msapp` into [CanvasAppSource/](./CanvasAppSource/), overwriting the existing source.
3. Rebuild the app binary and solution using the steps in [Building the app](#building-the-app).

### Applying solution changes back to source

For changes outside the canvas app (for example, adding fields to an entity, or modifying the Asset Management Mobile Application User Role), edit the solution in the maker portal and unpack the exported solution back into [Solution/Export/](./Solution/Export/):

1. In [Power Apps Studio](https://make.powerapps.com), open the **Solutions** tab and make your changes.
2. Select the solution and choose **Export**, then choose **Unmanaged**. Save the resulting `.zip` locally.
3. Unpack the `.zip` into the repository:
   ```powershell
   .\scripts\SolutionUnpackTool\SolutionUnpackTool.ps1 -SolutionZipPath <path-to-exported-zip>
   ```
4. Review the diff to confirm only your intended changes are present, then rebuild using the steps in [Building the app](#building-the-app).

### Localization

All translations live in [Translations/](./Translations/). The baseline is [Labels.en-US.resx](./Translations/Labels.en-US.resx).

Once a new label is added, inject it into the canvas app's runtime translation table:

1. Generate the table from the `.resx` files:
   ```powershell
   .\scripts\LocalizerTool\LocalizerTool.ps1 -CopyToClipboard
   ```
   The translations are now in your clipboard.
2. In Power Apps Studio, open the canvas app and go to `App → OnStart`.
3. Replace the section between these markers:
   ```text
   //localizer:gen-start
   ...
   //localizer:gen-end
   ```
   with the clipboard contents.

## Additional resources

For more on the deployed product (including security roles, licensing, and Finance & Operations Asset Management setup), see [Onboarding the Asset Management Mobile App](https://learn.microsoft.com/en-us/dynamics365/supply-chain/asset-management/asset-management-mobile-app/onboard-app) on Microsoft Learn.

## Third-party code and tools

This repository does not vendor third-party source code. It relies on Microsoft tooling including Microsoft Power Platform CLI (PAC) and Power Apps packaging utilities as described above. Any third-party assets referenced at build or runtime are subject to their own licenses and are not included in this repository.

## Telemetry and diagnostics

This app may surface limited diagnostics and error tracing provided by the Power Apps platform.

- To disable, set `appinsightserrortracing` to `false` in [CanvasAppSource/Properties.json](./CanvasAppSource/Properties.json), then rebuild and pack the app. Disabling diagnostics may reduce troubleshooting capability.
- No personal data should be intentionally collected by this repository's code. Review your environment's policies and telemetry configuration before deployment.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft's Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.

## Support

See [SUPPORT.md](./SUPPORT.md) for the support policy.
