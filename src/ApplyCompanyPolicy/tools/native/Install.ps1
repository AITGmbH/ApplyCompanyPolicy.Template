param($installPath, $toolsPath, $package, $project)

	# Need to load MSBuild assembly if it's not loaded yet.
    Add-Type -AssemblyName 'Microsoft.Build, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a'

	## Function definitions

	# Computes the relative part of a path from given solution and project directory.
	function ComputeRelativePath
	{
		param([string]$solutionDir, [string]$projectDir)

		$projectWithoutSolution = $projectDir.Substring($solutionDir.Length)

		$projectWithoutSolutionSplit = $projectWithoutSolution -split '\\'
		$subfolderCount = $projectWithoutSolutionSplit.Length

		$relPath = ""

		while(--$subfolderCount -ne 0)
		{
			$relPath = "..\" + $relPath
		}
		
		return $relPath
	}

	# Main function
	# iterates the CompanyPolicy.config file
	# and calls a function corresponding to particular settings (e.g. Documentation, Signing etc.)
	# Params:
	# $policyFilePath - config file path
	# $projectFullName - project file path
	# $assemblyName - assembly name
    # $projectName - project name as displayed in Visual Studio
	function ApplyCompanyPolicy
    {
        param([string]$policyFilePath, [string]$projectFullName, [string]$assemblyName, [string]$projectName)
			

		# Grab the loaded MSBuild project for the project
		$msbuild = [Microsoft.Build.Evaluation.ProjectCollection]::GlobalProjectCollection.GetLoadedProjects($projectFullName) | Select-Object -First 1
		#Visual studio 2013 does not load c++ projects into the project collection. Workaround to load it directly
		if($msbuild -eq $null) {
			Write-Host "Project not found, trying to load it directly"
			$msbuild =[Microsoft.Build.Evaluation.ProjectCollection]::GlobalProjectCollection.LoadProject($projectFullName) 
	    } 

		#If msbuild is still null, throw an error
		if($msbuild -eq $null) {
			Write-Error "MsBuild for Project not Found"
		return; 
		} 

		#Testing if it is now in the list
		$msbuildTest = [Microsoft.Build.Evaluation.ProjectCollection]::GlobalProjectCollection.GetLoadedProjects($projectFullName) | Select-Object -First 1
		if($msbuildTest -eq $null) {
			Write-Error "Project is still not in the list"
		} else{
			Write-Host "Project has been loaded sucessfully"
		}

		# open xml file
		[xml]$xmlContent = [xml](Get-Content -Path $policyFilePath)

		# get the document element
		[System.Xml.XmlElement] $root = $xmlContent.get_DocumentElement()

		# Documentation settings Adjusted for c++
		[System.Xml.XmlElement] $documentation = $root.Documentation

		if(($documentation -ne $null) -and (CheckIfProjectIsIncluded $projectName $documentation))
		{
			[System.Xml.XmlElement] $configuration = $null

			foreach($configuration in $documentation.ChildNodes)
			{
				[string]$name = $configuration.Attributes["Name"].Value

				[string]$enabled = $configuration.Attributes["enabled"].Value
				
				SetConfigurationDocumentationCpp $msbuild $assemblyName $name $enabled
			}
		}

		$toolsVersion =	$msbuild.Xml.ToolsVersion

		# Static Code Analysis settings

		[System.Xml.XmlElement] $staticCodeAnalysis = $root.StaticCodeAnalysis
		if(($staticCodeAnalysis -ne $null) -and (CheckIfProjectIsIncluded $projectName $staticCodeAnalysis))
		{
			Write-Host("Set the Configuration Code Analysis")
			[System.Xml.XmlElement] $configuration = $null

			foreach($configuration in $staticCodeAnalysis.ChildNodes)
			{
				[string]$name = $configuration.Attributes["Name"].Value

				[string]$enabled = $configuration.Attributes["enabled"].Value

				[string]$ruleSet = $configuration.Attributes["ruleSet"].Value

				SetConfigurationStaticCodeAnalysis $msbuild $projectFullName $name $enabled $ruleSet
			}
		}

		# Signing settings

		[System.Xml.XmlElement] $signing = $root.Signing

		if(($signing -ne $null) -and (CheckIfProjectIsIncluded $projectName $signing))
		{
			[System.Xml.XmlElement] $configuration = $signing.ChildNodes | Select-Object -First 1

			[string]$keyFile = $configuration.Attributes["keyFile"].Value

			[string]$enabled = $configuration.Attributes["enabled"].Value

			SetConfigurationSigning $msbuild $projectFullName $keyFile $enabled
		}

		# Code Analysis Dictionary settings

		[System.Xml.XmlElement] $codeAnalysisDictionary = $root.CodeAnalysisDictionary

		if(($codeAnalysisDictionary -ne $null) -and (CheckIfProjectIsIncluded $projectName $codeAnalysisDictionary))
		{
			[System.Xml.XmlElement] $configuration = $codeAnalysisDictionary.ChildNodes | Select-Object -First 1

			[string]$dictionary = $configuration.Attributes["dictionary"].Value

			[string]$enabled = $configuration.Attributes["enabled"].Value
			
			SetConfigurationCodeAnalysisDictionary $msbuild $projectFullName $dictionary $enabled
		}

		# StyleCop settings

		[System.Xml.XmlElement] $styleCop = $root.StyleCop

		if($styleCop -ne $null)
		{
			[System.Xml.XmlElement] $configuration = $styleCop.ChildNodes | Select-Object -First 1

			[string]$enableBuildIntegration = $configuration.Attributes["enableBuildIntegration"].Value
			SetConfigurationStyleCop $msbuild $enableBuildIntegration
		}
		#Save it
		$msbuild.Save()


    }
	
	# Params:
	# $msbuild  - MSBuild project
	# $projectFullName - proje
	# $assemblyName 
	# $name - Configurations 
	# $enabled - indicates if documentation enabled
	# Properties to enable generation of XML Documentation files
	#  <GenerateXMLDocumentationFiles>false</GenerateXMLDocumentationFiles>
    #  <XMLDocumentationFileName>$(IntDir)doc\</XMLDocumentationFileName>

	function SetConfigurationDocumentationCpp
    {
        param([Microsoft.Build.Evaluation.Project]$msbuild, [string]$assemblyName, [string]$name, [string]$enabled)
		#Get the ItemDefintionGroup
		$itemDefinitionGroup = $msbuild.Xml.ItemDefinitionGroups | Where-Object {$_.Condition.Contains($name)} | Select-Object -First 1
		$compileSettings = $itemDefinitionGroup.FirstChild

		if($compileSettings -ne $null)
		{
			if($enabled -eq 'true')
			{

				$docFile = "`$(IntDir)\" + $assemblyName + '.XML'

				$generateXMLValue = "true"


			}
			if($enabled -eq 'false')
			{
				$docFile = ""
				$generateXMLValue = "false"
			}

			$generateXMLDocumentationFilesMetaDataElement = $compileSettings.Metadata | Where-Object {$_.Name.Contains("GenerateXMLDocumentationFiles")} | Select-Object -First 1
			if($generateXMLDocumentationFilesMetaDataElement -eq $null)
			{
				$compileSettings.AddMetaData("GenerateXMLDocumentationFiles", $generateXMLValue)
			}else{
				$generateXMLDocumentationFilesMetaDataElement.Value = $generateXMLValue
			}

			$XMLDocumentationFileNameMetaDataElement = $compileSettings.Metadata | Where-Object {$_.Name.Contains("XMLDocumentationFileName")} | Select-Object -First 1
			if($XMLDocumentationFileNameMetaDataElement -eq $null)
			{
				$compileSettings.AddMetaData("XMLDocumentationFileName", $docFile)
			}else{
				$XMLDocumentationFileNameMetaDataElement.Value = $docFile
			}
			#$compileSettings.AppendChild($generateXMLDocumentationFiles)
			#$compileSettings.AppendChild($XMLDocumentationFileName)	
		}
    }

	# Params:
	# $name - configuration name
	# $enabled - indicates if Static Code Analysis enabled
	# $ruleSet - rule set file name
	function SetConfigurationStaticCodeAnalysis
    {
        param([Microsoft.Build.Evaluation.Project]$msbuild, [string]$projectFullName, [string]$name, [string]$enabled, [string]$ruleSet)
		#Set the property for the static code analysis only if the platform tool set is v110 or v120
		$propertyGroup = $msbuild.Xml.PropertyGroups | Where-Object {$_.Condition.Contains($name)} | Select-Object -First 1
	
		if($propertyGroup -ne $null)
		{
			if($enabled -eq 'true')
			{
				$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
				$solutionFile = $solution.FullName
				$solutionDir = [System.IO.Path]::GetDirectoryName($solutionFile)
				$projectDir = [System.IO.Path]::GetDirectoryName($projectFullName)
				
				$relPath = ComputeRelativePath $solutionDir $projectDir

				# Indicate that ACP enabled Code Analysis
				$propertyGroup.SetProperty("ACPRunCodeAnalysis", "true" )
				
				$runCodeAnalysisPropertyTrue = $propertyGroup.SetProperty("RunCodeAnalysis", "true" )
				$runCodeAnalysisPropertyTrue.Condition = "'`$(PlatformToolset)' == 'v120' Or '`$(PlatformToolset)' == 'v110'"
				$runCodeAnalysisPropertyFalse = $propertyGroup.SetProperty("RunCodeAnalysis", "false" )
				$runCodeAnalysisPropertyFalse.Condition = "'`$(PlatformToolset)' != 'v120' And '`$(PlatformToolset)' != 'v110'"
								
				$propertyGroup.SetProperty("CodeAnalysisRuleSet", $relPath + $ruleSet )
			}
			if($enabled -eq 'false')
			{
				# Indicate that ACP enabled Code Analysis
				$propertyGroup.SetProperty("ACPRunCodeAnalysis", "false" )
				
				$propertyGroup.SetProperty("RunCodeAnalysis", "false" )

				$propertyGroup.SetProperty("CodeAnalysisRuleSet", " " )
				$propertyGroup.SetProperty("CodeAnalysisRuleSet", "" )
			}	
		}
    }

	# Params:
	# $enabled - indicates if signing enabled 
	# $keyFile - signing file name
	function SetConfigurationSigning
    {
        param([Microsoft.Build.Evaluation.Project]$msbuild, [string]$projectFullName, [string]$keyFile, [string]$enabled)
	
		$lastPropertyGroup = $msbuild.Xml.PropertyGroupsReversed  |Select-Object -First 1
		
		$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
		$solutionFile = $solution.FullName
		$solutionDir = [System.IO.Path]::GetDirectoryName($solutionFile)
		$projectDir = [System.IO.Path]::GetDirectoryName($projectFullName)
		
		$keyFilePath = [System.IO.Path]::Combine($solutionDir, $keyFile)
		
		$relPath = ComputeRelativePath $solutionDir $projectDir

		$assemblyOriginatorKeyFileProperty = $msbuild.Xml.Properties | Where-Object {$_.Name.Equals("AssemblyOriginatorKeyFile")} | Select-Object -First 1
		$signAssemblyProperty = $msbuild.Xml.Properties | Where-Object {$_.Name.Equals("SignAssembly")} | Select-Object -First 1

		if($assemblyOriginatorKeyFileProperty -eq $null)
		{
			if($enabled -eq "true") 
			{
				$msbuild.Xml.AddPropertyGroup().SetProperty("AssemblyOriginatorKeyFile", $relPath + $keyFile)
			}
		}
		else
		{
			if($enabled -eq "true") 
			{
				$assemblyOriginatorKeyFileProperty.Value = $relPath + $keyFile
			}
		}

		if($signAssemblyProperty -eq $null)
		{
			if($enabled -eq "true") 
			{
				$msbuild.Xml.AddPropertyGroup().SetProperty("SignAssembly", "true")
			}
		}
		else
		{
			if($enabled -eq "true") 
			{
				$signAssemblyProperty.Value = "true"
			}
			else
			{
				$signAssemblyProperty.Value = "false"
			}
		}
		
        
    }

	# Params:
	# $enabled - indicates if Code Analysis Dictionary enabled
	# $dictionary - Code Analysis Dictionary file
	function SetConfigurationCodeAnalysisDictionary
    {
		param([Microsoft.Build.Evaluation.Project]$msbuild, [string]$projectFullName, [string]$dictionary, [string]$enabled)
		
		$lastPropertyGroup = $msbuild.Xml.PropertyGroupsReversed  |Select-Object -First 1
		
		$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
		$solutionFile = $solution.FullName
		$solutionDir = [System.IO.Path]::GetDirectoryName($solutionFile)
		$projectDir = [System.IO.Path]::GetDirectoryName($projectFullName)
		
		$dictionaryFilePath = [System.IO.Path]::Combine($solutionDir, $dictionary)

		$relPath = ComputeRelativePath $solutionDir $projectDir

		$codeAnalysisDictionary = $msbuild.Xml.Items | Where-Object {$_.ItemType.Equals("CodeAnalysisDictionary")} | Select-Object -First 1

		if($codeAnalysisDictionary -eq $null)
		{
			$itemGroup = $msbuild.Xml.AddItemGroup().AddItem("CodeAnalysisDictionary",$relPath + $dictionary )
			$itemGroup.AddMetadata("Link", "Properties\" + $dictionary)
		}
		else
		{
			$parent = $codeAnalysisDictionary.Parent
			$parent.RemoveChild($codeAnalysisDictionary)
			$parent.AddItem("CodeAnalysisDictionary",$relPath + $dictionary ).AddMetadata("Link", "Properties\" + $dictionary)
		}
    }

	# Params:
	# $enableBuildIntegration - indicates automatic StyleCop execution on build
	function SetConfigurationStyleCop
    {
        param([Microsoft.Build.Evaluation.Project]$msbuild, [string]$enableBuildIntegration)
	
		if($enableBuildIntegration -eq "true") 
		{

			# check if imports exists
			$x = "$"
			$x= $x + "(MSBuildExtensionsPath)\StyleCop\v4.7\StyleCop.targets"
			$y = "Exists('$"
			$y= $y+ "(MSBuildExtensionsPath)\StyleCop\v4.7\StyleCop.targets')"

			$styleCopImports = $msbuild.Xml.Imports | Where-Object {$_.Project.Equals($x)} | Where-Object {$_.Condition.Equals($y)} | Select-Object -First 1

			if($styleCopImports.Count -eq 0)
			{
				$importElement = $msbuild.Xml.AddImport($x)
				$importElement.Condition = $y
			}
		}
		
    }

    # Checks whether the project name matches any pattern.
    #
    # Params:
    # $projectName - the project name to test
    # $patterns - patterns (wildcards as asterisk allowed) in an array
    function NameMatchesPatterns
    {
        param([string]$projectName, [string[]]$patterns)
        
        foreach ($pattern in $patterns)
        {
            if($projectName -like $pattern)
            {
                return $true
            }
        }

        return $false
    }

    # Extracts non empty patterns from a string and returns them in an array.
    #
    # Params:
    # $patterns - The patterns are expected to be separated by semicolons.
    function GetNonEmptyPatterns
    {
        param([string]$patterns)
        
        $patternArray = $patterns.Split(";").Trim()
        $retVal = @()
        foreach ($pattern in $patternArray)
        {
            if ($pattern)
            {
                $retVal += $pattern
            }
        }

        return $retVal
    }

    # Checks whether the project should be included or excluded.
    #
    # Params:
    # $projectName - the project name to test
    # $configSection - the XML element of the config section (such as Documentation or StaticCodeAnalysis)
    function CheckIfProjectIsIncluded
    {
        param([string]$projectName, [System.Xml.XmlElement]$configSection)

        $excludePatterns = $configSection.Attributes["exclude"].Value
        $includePatterns = $configSection.Attributes["includeOnly"].Value

        if ($excludePatterns -ne $null)
        {
            $patterns = GetNonEmptyPatterns $excludePatterns
            if(($patterns.Length -gt 0) -and (NameMatchesPatterns $projectName $patterns))
            {
                return $false
            }
        }

        if ($includePatterns -ne $null)
        {
            $patterns = GetNonEmptyPatterns $includePatterns
            if(($patterns.Length -gt 0) -and -not (NameMatchesPatterns $projectName $patterns))
            {
                return $false
            }
        }

        return $true
    }
	
	# proper script part
	write-host "This is the Install Script for c++"
	# prepare necessary variables
	$extScript = [System.IO.Path]::Combine($installPath, 'tools\scripts\PrepareProject.ps1')
	#Load External Script
	. "$extScript"

	#Call the Init Function of the external script
	Init $installPath $toolsPath $package $project

	[string]$policyFilePath = [System.IO.Path]::Combine($installPath, "CompanyPolicy", "CompanyPolicy.config")
	
	# check if CompanyPolicy.config exists, if not break the script 
	if(!(Test-Path $policyFilePath)) { return; }
	[string]$projectFullName = $project.FullName

	#Use RootNamespace instead of AssemblyName in a c++ project
	[string]$assemblyName =  $project.Properties.Item("RootNamespace").Value

    [string]$projectName = $project.Name

	# Function call
	try{
  		ApplyCompanyPolicy $policyFilePath $projectFullName $assemblyName $projectName
	}
	catch [Exception] {
		write-host $_.Exception.Message;
	return
	}
		write-host "ACP successfully applied";
	
	
	# Saves the project
	$project.Save()
	
	# Loads and saves the project as an Xml file, 
	# without committing any changes,
	# in order to force the "Reload" window in Visual Studio.	
	$object = New-Object System.Xml.XmlDocument 
	$object.Load($projectFullName)
	$object.Save($projectFullName)

