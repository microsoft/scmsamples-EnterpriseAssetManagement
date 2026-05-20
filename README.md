# Dynamics 365 Asset Management Mobile App

The Asset Management mobile app is a [Power Apps canvas app](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/getting-started) that provides Asset Management capabilities for **Microsoft Dynamics 365 Supply Chain Management**. Maintenance workers can use it to manage assigned work orders, create maintenance requests, and create new work orders. For product documentation and transition guidance from the existing Microsoft-distributed managed solution, see [Additional resources](#additional-resources).

Licensed under MIT. See [LICENSE](./LICENSE.txt).

## Prerequisites

- **Microsoft Dynamics 365 Supply Chain Management** version 10.0.36 or later.
- A **Power Platform environment** with:
  - Dynamics 365 apps enabled (set when creating the environment).
  - Power Apps Component Framework (PCF) enabled. To enable it on an existing environment, in the [Power Platform admin center](https://admin.powerplatform.microsoft.com) open **Environments → [your environment] → Settings → Product → Features**, then turn on the **Power Apps component framework for canvas apps** feature. See [Manage feature settings](https://learn.microsoft.com/en-us/power-platform/admin/settings-features) on Microsoft Learn for details.

## Quick install

The simplest way to install the app is to download the prebuilt managed solution from this repository's [latest Release](https://github.com/microsoft/scmsamples-EnterpriseAssetManagement/releases/latest) and import it in [Power Apps](https://make.powerapps.com).

1. From the [latest Release](https://github.com/microsoft/scmsamples-EnterpriseAssetManagement/releases/latest), download `AssetManagementMobileSample_managed.zip`.
2. Sign in to [Power Apps](https://make.powerapps.com).
3. Open the **Solutions** tab.
4. Select **Import solution** and choose the downloaded `.zip`.

After import, the **Asset Management V2** canvas app appears under the **Apps** tab in [Power Apps](https://make.powerapps.com).

If you need the unmanaged solution to modify the app's components directly, build from source (see [Building from source](#building-from-source)).

## Building from source

Build from source if you want to customize the canvas app at the source level or rebuild under your own publisher for redistribution.

### Repository layout

| Folder | What's there |
|---|---|
| [CanvasAppSource/](./CanvasAppSource/) | Source for the canvas app, as unpacked by the PAC CLI. |
| [Solution/](./Solution/) | Solution metadata, components, and the canvas app binary (`.msapp`) that gets bundled into the solution. |
| [Translations/](./Translations/) | RESX files — `Labels.en-US.resx` is the baseline; per-locale files hold translations. |
| [scripts/](./scripts/) | PowerShell scripts that pack and unpack the solution and canvas app, and generate the runtime translation table. |
| [bin/](./bin/) | Output directory for built solution archives. |

### Build tooling

To build the app from source, you need:

- **PowerShell** — Windows PowerShell 5.1 (preinstalled on Windows) or [PowerShell 7+](https://aka.ms/powershell) (cross-platform). Required by the scripts under [scripts/](./scripts/).
- **[Microsoft Power Platform CLI (PAC)](https://aka.ms/PowerAppsCLI)** — invoked by the pack and unpack scripts.

### Pack the canvas app

```powershell
./scripts/MsAppPackTool/MsAppPackTool.ps1
```

Packs the source in [CanvasAppSource/](./CanvasAppSource/) into an `.msapp` archive under [Solution/Export/CanvasApps/](./Solution/Export/CanvasApps/).

### Pack the solution

```powershell
./scripts/SolutionPackTool/SolutionPackTool.ps1
```

Packs the contents of [Solution/](./Solution/) into [bin/](./bin/), producing two archives — one unmanaged (`.zip`) and one managed (`_managed.zip`).

> **Publisher, solution, and customization prefix.** The defaults in [Solution/Export/Other/Solution.xml](./Solution/Export/Other/Solution.xml) are: publisher and solution unique name `AssetManagementMobileSample` (shared), customization prefix `eammob`, and Microsoft-branded display names ("Microsoft Asset Management Mobile Sample" for the publisher, "Asset Management Mobile App Sample" for the solution). These identify the solution as a Microsoft-distributed sample, which is appropriate for in-tenant use as-is.
>
> To redistribute under your own brand, make these source changes, then re-run the pack scripts:
> - Update the `<Publisher>`, solution `<LocalizedNames>`/`<Descriptions>`, and `<CustomizationPrefix>` blocks in `Solution.xml`.
> - Mirror the localized strings in the `resources.en-US.resx` files under [Solution/](./Solution/).
> - Search the source for `eammob_` and update component names that use the default prefix.

### Install the packed solution

To install a solution `.zip` produced under [bin/](./bin/), follow the same steps as [Quick install](#quick-install), but use your `.zip` from `bin/` instead of the prebuilt download. Choose the managed version (`_managed.zip`) to lock components against modification, or the unmanaged version (`.zip`) to keep them editable in the maker portal.

## Customizing the app

### Applying canvas app changes back to source

If you edit the canvas app in Power Apps Studio and want to sync those changes back to this repository:

1. In Power Apps Studio, choose **Download a copy** to save the canvas app as an `.msapp` file on your machine.
2. Run:
   ```powershell
   ./scripts/MsAppUnpackTool/MsAppUnpackTool.ps1 -MsAppPath <path-to-msapp>
   ```
   This unpacks the `.msapp` into [CanvasAppSource/](./CanvasAppSource/), overwriting the existing source.
3. Re-run the pack scripts in [Pack the canvas app](#pack-the-canvas-app) and [Pack the solution](#pack-the-solution) to produce updated archives.

This is the standard PAC CLI round-trip pattern for canvas apps. For broader CI/CD options, see [ALM for Power Platform](https://learn.microsoft.com/en-us/power-platform/alm/) on Microsoft Learn.

### Applying solution changes back to source

For changes outside the canvas app (for example, adding fields to a table or modifying the Asset Management Mobile Application User Role):

1. In [Power Apps](https://make.powerapps.com), open the **Solutions** tab and make your changes.
2. Select the unmanaged solution and choose **Export solution**. In the **Export this solution** panel, set **Export as** to **Unmanaged**, complete the export, and save the resulting `.zip` locally.
3. Unpack the `.zip` into [Solution/Export/](./Solution/Export/):
   ```powershell
   ./scripts/SolutionUnpackTool/SolutionUnpackTool.ps1 -SolutionZipPath <path-to-exported-zip>
   ```
4. Review the diff to confirm only your intended changes are present, then re-run the pack scripts in [Pack the canvas app](#pack-the-canvas-app) and [Pack the solution](#pack-the-solution) to produce updated archives.

### Localization

All translations live in [Translations/](./Translations/). The baseline is [Labels.en-US.resx](./Translations/Labels.en-US.resx).

After adding or changing labels in the `.resx` files, regenerate the canvas app's runtime translation table:

1. Generate the table and copy it to your clipboard:
   ```powershell
   ./scripts/LocalizerTool/LocalizerTool.ps1 -CopyToClipboard
   ```
2. In Power Apps Studio, open the canvas app, select the **App** control, and open its **OnStart** property.
3. Replace the contents between these markers with what's on your clipboard:
   ```text
   //localizer:gen-start
   ...
   //localizer:gen-end
   ```

## Additional resources

- [Asset Management mobile app overview](https://learn.microsoft.com/en-us/dynamics365/supply-chain/asset-management/asset-management-mobile-app/asset-management-mobile-app-overview): full feature description.
- [Onboard the Asset Management mobile app](https://learn.microsoft.com/en-us/dynamics365/supply-chain/asset-management/asset-management-mobile-app/onboard-app): security roles, licensing, and Finance & Operations Asset Management setup.
- [Asset Management mobile app open-source release](https://learn.microsoft.com/en-us/dynamics365/supply-chain/asset-management/asset-management-mobile-app/open-source-release): transition guidance from the Microsoft-distributed app.

## Third-party code and tools

This repository doesn't directly vendor third-party source code. Some Microsoft-provided components (such as the `MscrmControls.Common.A11yFocusTrap` PCF control) bundle MIT-licensed third-party code internally, with attribution alongside the bundle in `bundle.js.LICENSE.txt`. The repository otherwise relies on Microsoft tooling, primarily the Power Platform CLI (PAC). Any third-party assets referenced at build or runtime are subject to their own licenses.

## Telemetry and diagnostics

Application Insights for canvas apps is opt-in via a connection string in the app's settings (see [Application Insights for canvas apps](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/application-insights) on Microsoft Learn). The `ConnectionString` field in [CanvasAppSource/Properties.json](./CanvasAppSource/Properties.json) is empty, so this app sends no telemetry as shipped. If you fork and configure a connection string, telemetry flows to that resource. No personal data is intentionally collected by this repository's code.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft trademarks or logos is subject to and must follow Microsoft's Trademark & Brand Guidelines. Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship. Any use of third-party trademarks or logos are subject to those third-party's policies.

## Support

See [SUPPORT.md](./SUPPORT.md) for the support policy.
