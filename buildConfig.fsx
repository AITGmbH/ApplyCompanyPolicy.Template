// ----------------------------------------------------------------------------
// This file is subject to the terms and conditions defined in
// file 'LICENSE.txt', which is part of this source code package.
// ----------------------------------------------------------------------------
(**

# AIT.VisualStudioTextTransform buildConfig.fsx configuration
*)

#if FAKE
#else
// Support when file is opened in Visual Studio
#load "packages/AIT.Build/content/buildConfigDef.fsx"
#endif

(**
## Required config start

First We need to load some dependencies and open some namespaces.
*)
open BuildConfigDef
open System.Collections.Generic
open System.IO

open Fake
open Fake.Git
open Fake.FSharpFormatting
open AssemblyInfoFile

(**
## Main project configuration

Then we need to set some general properties of the project.
*)
let buildConfig =
 // Read release notes document
 let release = ReleaseNotesHelper.parseReleaseNotes (File.ReadLines "doc/ReleaseNotes.md")
 { BuildConfiguration.Defaults with
    ProjectName = "AIT.CompanyPolicy"
    CopyrightNotice = "Copyright © 2015, AIT GmbH & Co. KG"
    ProjectSummary = "Applies the AIT Company Policy to the project."
    ProjectDescription =
      "The AIT Apply Company Policy lets you apply the AIT code policy for Visual Studio, just by adding a NuGet package. " +
      "For cleaner code and more efficient collaboration! " +
      "More documentation can be found here: http://aitgmbh.github.io/ApplyCompanyPolicy.Template/"
    ProjectAuthors = [ "Benjamin Fischer"; "Jan Mattner"; "Jakub Sabacinski"; "Boris Wehrle"; "Matthias Dittrich" ]
    NugetTags = "AIT Static Code Analysis Style Cop ReSharper Settings "
    PageAuthor = "AIT GmbH"
    GithubUser = "AITGmbH"
    // Defaults to ProjectName if unset
    GithubProject = "ApplyCompanyPolicy.Template"
    Version = release.NugetVersion
(**
Setup which nuget packages are created.
*)
    NugetPackages =
      [ "CompanyPolicy.nuspec", (fun config p ->
          { p with
              Version = config.Version
              NoDefaultExcludes = true
              ReleaseNotes = toLines release.Notes
              Dependencies =
                [ ]
                  |> List.map (fun name -> name, (GetPackageVersion "packages" name |> RequireExactly)) } ) ]
(**
With `UseNuget` you can specify if AIT.Build should restore nuget packages
before running the build (if you only use paket, you either leave it out or use the default setting = false).
*)
    UseNuget = true
(**
## The `GeneratedFileList` property

The `GeneratedFileList` list is used to specify which files are copied over to the release directory.
This list is also used for documentation generation.
Defaults to [ x.ProjectName + ".dll"; x.ProjectName + ".xml" ] which is only enough for very simple projects.
*)
    GeneratedFileList = [ ]

(**
You can change which AssemblyInfo files are generated for you.
On default "./src/SharedAssemblyInfo.fs" and "./src/SharedAssemblyInfo.cs" are created.
*)
    SetAssemblyFileVersions = (fun config ->
      let info =
        [ Attribute.Company "AIT GmbH & Co. KG"
          Attribute.Product config.ProjectName
          Attribute.Copyright config.CopyrightNotice
          Attribute.Version config.Version
          Attribute.FileVersion config.Version
          Attribute.InformationalVersion config.Version]
      ignore info)
(**
## Yaaf.AdvancedBuilding features
Setup the builds
*)
    BuildTargets =
     [ BuildParams.WithSolution ]

    EnableDebugSymbolConversion = false
    RestrictReleaseToWindows = false
  }

(**
## FAKE settings

You can setup FAKE variables as well.
*)

if isMono then
    monoArguments <- "--runtime=v4.0 --debug"

