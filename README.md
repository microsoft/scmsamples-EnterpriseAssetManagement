# Dynamics 365 Asset Management Mobile App

The Asset Management mobile app is a [Power Apps canvas app](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/getting-started) that provides Asset Management capabilities for **Microsoft Dynamics 365 Supply Chain Management**. Maintenance workers can use it to manage assigned work orders, create maintenance requests, and create new work orders.

Licensed under MIT. See [LICENSE](./LICENSE.txt).

## Prerequisites

### Environment

- **Microsoft Dynamics 365 Supply Chain Management** version 10.0.36 or later.
- A **Dataverse environment** with:
  - Dynamics 365 apps enabled
  - Power Apps Component Framework (PCF) enabled

  To configure, sign in to the [Power Platform admin center](https://admin.powerplatform.microsoft.com), then navigate to **Environments** and either create a new environment or edit an existing one, ensuring both options are enabled.

### Licensing and security roles

Each user requires a valid **Microsoft Entra ID** license, plus the following security roles:

- **Asset Management Mobile Application User Role** (in Dataverse)
- **Finance and Operations Basic User** (for Supply Chain Management)

For full licensing details, see the [Dynamics 365 Licensing Guide](https://go.microsoft.com/fwlink/?LinkId=866544).

## Quick install

The simplest way to install the app is to download the prebuilt managed solution from this repository's [latest Release](https://github.com/microsoft/scmsamples-EnterpriseAssetManagement/releases/latest) and import it in [Power Apps](https://make.powerapps.com).

1. From the [latest Release](https://github.com/microsoft/scmsamples-EnterpriseAssetManagement/releases/latest), download `AssetManagementMobileSample_managed.zip`.
2. Sign in to [Power Apps](https://make.powerapps.com).
3. Open the **Solutions** tab.
4. Select **Import solution** and choose the downloaded `.zip`.
5. *(Optional)* If your organization requires signed solutions, sign the `.zip` with [SignTool](https://learn.microsoft.com/en-us/dotnet/framework/tools/signtool-exe) before importing.

If you need the unmanaged solution to modify the app's components directly, build from source (see [Building from source](#building-from-source)).

## Building from source

Build from source if you want to fork the app, customize the canvas app at the source level, or rebuild under your own publisher for redistribution.

### Build tooling

To build the app from source, install [Microsoft Power Platform CLI (PAC)](https://aka.ms/PowerAppsCLI).

### Generate the canvas app binary

```powershell
.\scripts\MsAppPackTool\MsAppPackTool.ps1
```

This produces `eammob_assetmanagementv2_bbd03_DocumentUri.msapp` in [Solution/Export/CanvasApps/](./Solution/Export/CanvasApps/) from the source in [CanvasAppSource/](./CanvasAppSource/).

### Generate the solution

```powershell
.\scripts\SolutionPackTool\SolutionPackTool.ps1
```

This produces both managed and unmanaged solution archives under [/bin](./bin/):

- `AssetManagementMobileSample.zip` (unmanaged)
- `AssetManagementMobileSample_managed.zip` (managed)

> **Publisher, solution, and customization prefix.** Configured in [Solution/Export/Other/Solution.xml](./Solution/Export/Other/Solution.xml) with publisher and solution unique name `AssetManagementMobileSample`, customization prefix `eammob`, and Microsoft-branded display names ("Microsoft Asset Management Mobile Sample" for the publisher, "Asset Management Mobile App Sample" for the solution). This identifies the solution as a Microsoft-distributed sample, which is appropriate for in-tenant use as-is. To redistribute under your own brand, update the `<Publisher>`, solution `<LocalizedNames>`/`<Descriptions>`, and `<CustomizationPrefix>` blocks in `Solution.xml`, mirror those localized strings in the `resources.en-US.resx` files under [Solution/](./Solution/), and update prefixed component references throughout the source before building.

### Install your build

To install a solution `.zip` produced from [/bin](./bin/), follow the same steps as [Quick install](#quick-install), substituting your `.zip` from `/bin/` for the Releases download. Choose the managed or unmanaged version depending on whether you want to lock components against modification (managed) or leave them open for editing in the maker portal (unmanaged).

## Customizing the app

### Applying canvas app changes back to source

This is the standard PAC CLI round-trip pattern for Power Apps canvas apps. See [ALM for Power Platform](https://learn.microsoft.com/en-us/power-platform/alm/) on Microsoft Learn for broader CI/CD options.

If you edit the canvas app in the maker portal and want those changes reflected in this repository:

1. Download a copy of the app from Power Apps Studio (this produces an `.msapp` file).
2. Run:
   ```powershell
   .\scripts\MsAppUnpackTool\MsAppUnpackTool.ps1 -MsAppPath <path-to-msapp>
   ```
   This unpacks the `.msapp` into [CanvasAppSource/](./CanvasAppSource/), overwriting the existing source.
3. Rebuild the app binary and solution using the steps in [Building from source](#building-from-source).

### Applying solution changes back to source

For changes outside the canvas app (for example, adding fields to an entity, or modifying the Asset Management Mobile Application User Role), edit the solution in the maker portal and unpack the exported solution back into [Solution/Export/](./Solution/Export/):

1. In [Power Apps](https://make.powerapps.com), open the **Solutions** tab and make your changes.
2. Select the solution and choose **Export**, then choose **Unmanaged**. Save the resulting `.zip` locally.
3. Unpack the `.zip` into the repository:
   ```powershell
   .\scripts\SolutionUnpackTool\SolutionUnpackTool.ps1 -SolutionZipPath <path-to-exported-zip>
   ```
4. Review the diff to confirm only your intended changes are present, then rebuild using the steps in [Building from source](#building-from-source).

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

- [Asset Management mobile app overview](https://learn.microsoft.com/en-us/dynamics365/supply-chain/asset-management/asset-management-mobile-app/asset-management-mobile-app-overview) covers the full feature description.
- [Onboarding the Asset Management Mobile App](https://learn.microsoft.com/en-us/dynamics365/supply-chain/asset-management/asset-management-mobile-app/onboard-app) covers security roles, licensing, and Finance & Operations Asset Management setup.

## Third-party code and tools

This repository does not directly vendor third-party source code authored by this project. Some Microsoft-provided components (such as the `MscrmControls.Common.A11yFocusTrap` PCF control) bundle MIT-licensed third-party code internally, with attribution alongside the bundle in `bundle.js.LICENSE.txt`. The repository otherwise relies on Microsoft tooling, including the Power Platform CLI (PAC) and Power Apps packaging utilities described above. Any third-party assets referenced at build or runtime are subject to their own licenses.

## Telemetry and diagnostics

Application Insights for canvas apps is opt-in via a connection string in the app's settings (see [Microsoft Learn](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/application-insights)). The `ConnectionString` field in [CanvasAppSource/Properties.json](./CanvasAppSource/Properties.json) is empty, so this app sends no telemetry as shipped. If you fork and configure one, telemetry flows to that resource. No personal data is intentionally collected by this repository's code.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft's Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.

## Support

See [SUPPORT.md](./SUPPORT.md) for the support policy.
