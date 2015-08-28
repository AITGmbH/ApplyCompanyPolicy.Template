AIT Apply Company Policy SDK
========================

The AIT Apply Company Policy SDK lets you create your own code policy for Visual Studio, which can be easily distributed as NuGet package. For cleaner code and more efficient collaboration!

##Features
- Easy installation as NuGet package.
- Central administration and distribution of all company-wide settings with the NuGet mechanism.
- Central changes of all company-wide settings with the NuGet-Update mechanism.
- Automatic Settings of Visual-Studio specific settings.
- Automatic setting of external tools (VS Code Analysis, Style Cop Code Analysis, ReSharper)
- Signing of projects with your key file
- Including and excluding specific projects
- Easy customization

##Documentation
See the [Wiki](https://github.com/AITGmbH/Apply-Company-Policy-SDK/wiki) for a detailed documentation.

###Requirements
- In order to open the projects, ensure that the [NuBuild Project System](https://visualstudiogallery.msdn.microsoft.com/3efbfdea-7d51-4d45-a954-74a2df51c5d0) is installed.
- PowerShell 3

##Get the AIT Defaults

The default AIT ACP package containing the recommended settings (AIT Company Policy) is available via NuGet at https://www.nuget.org/packages/AIT.CompanyPolicy/

To install AIT Company Policy, run the following command in the [Package Manager Console](http://docs.nuget.org/docs/start-here/using-the-package-manager-console):

    PM> Install-Package AIT.CompanyPolicy

##Known Issues

- There is a known bug concerning the update functionality of NuGet packages. This bug can appear when updating a single package under source control in Microsoft TFS using local Workspaces. For further information visit the discussion at [NuGet](https://github.com/NuGet/Home/issues/491) and the issue at [Microsoft](https://connect.microsoft.com/VisualStudio/feedback/details/1344773/tfs-local-workspace-marks-files-as-deleted). To prevent this bug from appearing, do not use the NuGet update-package functionality when there is only one NuGet package installed. Rather uninstall and install the package manually.


This software is provided by [AIT GmbH & Co. KG](http://www.aitgmbh.de/en/).