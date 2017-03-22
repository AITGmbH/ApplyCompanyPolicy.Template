// ----------------------------------------------------------------------------
// This file is subject to the terms and conditions defined in
// file 'LICENSE.txt', which is part of this source code package.
// ----------------------------------------------------------------------------
(**

# AIT.VisualStudioTextTransform buildConfig.fsx configuration
*)

#load "buildConfigDef.fsx"

#r "packages/FSharp.Data/lib/net40/FSharp.Data.dll"
#r "System.Xml"
#r "System.Xml.Linq"

(**
## Required config start

First We need to load some dependencies and open some namespaces.
*)
open BuildConfigDef
open System.Collections.Generic
open System.IO
open FSharp.Data


open Fake
open Fake.Git
open Fake.FSharpFormatting
open AssemblyInfoFile

(**
## Main project configuration
Then we need to set some general properties of the project.
*)
type NuSpecFile = FSharp.Data.XmlProvider<"src/ApplyCompanyPolicy/ApplyCompanyPolicy.nuspec">
let nuspecFile = NuSpecFile.GetSample()


let buildConfig =
 // Read release notes document
 let release = ReleaseNotesHelper.parseReleaseNotes (File.ReadLines "doc/ReleaseNotes.md")
 let nuspecVersion = SemVerHelper.parse nuspecFile.Metadata.Version
 let releaseNoteVersion = release.SemVer
 if nuspecVersion > releaseNoteVersion then
    failwithf "Please add documentation for version %s!" nuspecFile.Metadata.Version
 { BuildConfiguration.Defaults with
    ProjectName = nuspecFile.Metadata.Id
    CopyrightNotice = nuspecFile.Metadata.Copyright
    ProjectSummary = nuspecFile.Metadata.Summary
    ProjectDescription = nuspecFile.Metadata.Description
    ProjectAuthors =
        nuspecFile.Metadata.Authors.Split([|','|])
        |> Seq.map (fun l -> l.Trim())
        |> Seq.toList
    NugetTags = nuspecFile.Metadata.Tags
    PageAuthor = "AIT GmbH"
    BuildDocumentation = true
    GithubUser = "AITGmbH"
    // Defaults to ProjectName if unset
    GithubProject = "ApplyCompanyPolicy.Template"
    Version = release.NugetVersion
(**
Setup which nuget packages are created.
*)
    NugetPackages =
      [ "../src/ApplyCompanyPolicy/ApplyCompanyPolicy.nuspec", (fun config p ->
          { p with
              WorkingDir = "src/ApplyCompanyPolicy"
              Version = config.Version
              NoDefaultExcludes = true
              ReleaseNotes = toLines release.Notes } ) ]
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
## AIT.Build features
Setup the builds
*)
    BuildTargets =
     [ BuildParams.Empty ]

    EnableDebugSymbolConversion = false
    RestrictReleaseToWindows = false
  }

(**
## FAKE settings

You can setup FAKE variables as well.
*)

if isMono then
    monoArguments <- "--runtime=v4.0 --debug"
