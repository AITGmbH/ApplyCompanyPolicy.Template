AIT Apply Company Policy Template
========================

The AIT Apply Company Policy Template lets you create your own code policy for Visual Studio, which can be easily distributed as NuGet package. For cleaner code and more efficient collaboration!

## Features
- Easy installation as NuGet package.
- Central administration and distribution of all company-wide settings with the NuGet mechanism.
- Central changes of all company-wide settings with the NuGet-Update mechanism.
- Automatic Settings of Visual-Studio specific settings.
- Automatic setting of external tools (VS Code Analysis, Style Cop Code Analysis, ReSharper)
- Signing of projects with your key file
- Including and excluding specific projects
- Easy customization

## Documentation
See the [Documentation Pages](https://aitgmbh.github.io/ApplyCompanyPolicy.Template) for a detailed documentation.
And look [here](https://aitgmbh.github.io/ApplyCompanyPolicy.Template/CreatePackage.html) for steps to create a customized package (also take a note of the known issues down below).

### Requirements
- In order to open the projects, ensure that the [NuBuild Project System](https://visualstudiogallery.msdn.microsoft.com/3efbfdea-7d51-4d45-a954-74a2df51c5d0) is installed.
- PowerShell 3

## Get the AIT Defaults

The default AIT ACP package containing the recommended settings (AIT Company Policy) is available via NuGet at https://www.nuget.org/packages/AIT.CompanyPolicy/

To install AIT Company Policy, run the following command in the [Package Manager Console](http://docs.nuget.org/docs/start-here/using-the-package-manager-console):

    PM> Install-Package AIT.CompanyPolicy

## Known Issues
- There is a known bug concerning the update functionality of NuGet packages. This bug can appear when updating a single package under source control in Microsoft TFS using local Workspaces. For further information visit the discussion at [NuGet](https://github.com/NuGet/Home/issues/491) and the issue at [Microsoft](https://connect.microsoft.com/VisualStudio/feedback/details/1344773/tfs-local-workspace-marks-files-as-deleted). To prevent this bug from appearing, do not use the NuGet update-package functionality when there is only one NuGet package installed. Rather uninstall and install the package manually.

- Make sure that you only have the 'NuBuild Project System' for Visual Studio installed and not the 'NuGet Package Project'-Extension.
  Those two extensions are incompatible and having 'NuGet Package Project' installed will make it impossible to use this project.
  This limitation only hits you when you try to create your own 'CompanyPolicy' package, not when you are just using the final NuGet package.


This software is provided by [AIT GmbH & Co. KG](http://www.aitgmbh.de/en/).