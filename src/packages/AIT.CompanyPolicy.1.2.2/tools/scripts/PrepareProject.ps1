	# copies file to the solution directory
	# creates ".Settings" solution folder
	# adds shipped files to the solution
	function Init 
	{
		param($installPath, $toolsPath, $package, $project)
		# Checks if a partical file already added to a solution/project as project item 
		function CheckIfFileExistsInProject
		{
			param($projectItems, [string]$fileName)

			write-Host "Prepare the project and copy necessary files"
			for([int]$i = 1; $i -le $projectItems.Count; $i++)
			{
				$item = $projectItems.Item($i) 
				if($item.FileNames(1).Equals($fileName)){return $true;}
			}
			return $false
		}

		# Copies a file to solution dir, if not already there
		# Creates a solution folder, if not already there
		# Adds files to solution, if not already there
		function AddFileToSettings
		{
		    param([string]$filename, [string]$newFilename, [string]$installPath, [string]$policyFolderName, [string]$settingsFolderName, $solution)

			$solutionDir = [System.IO.Path]::GetDirectoryName($solution.FullName)

			$oldpath = [System.IO.Path]::Combine($installPath, $policyFolderName, $fileName)
			$newPath = [System.IO.Path]::Combine($solutionDir, $newFilename)
			
			# checks whether file exists in package
			if(Test-Path $oldpath) 
			{
				Copy-Item $oldpath $newPath
				
				# look up for solution folder
				$settingsFolder = $solution.Projects | Where-Object {$_.Name.Equals($settingsFolderName, [StringComparison]::OrdinalIgnoreCase)} | Select-Object -First 1

				# if not there, create new one
				if ($settingsFolder -eq $null) 
				{
					$settingsFolder = $solution.AddSolutionFolder($settingsFolderName) #solution change!!!!!!
				}
				
				# check if added already
				if(!(CheckIfFileExistsInProject $settingsFolder.ProjectItems $newPath))
				{
					$settingsFolder.ProjectItems.AddFromFile($newPath) 
				}
			}
		}


		
		$solution = Get-Interface $dte.Solution ([EnvDTE80.Solution2])
		$solutionFile = $solution.FullName

		$solutionDir = [System.IO.Path]::GetDirectoryName($solutionFile)

		$settingsFolder = $null
		$settingsFolderName = ".Settings"
		[string]$policyFilePath = [System.IO.Path]::Combine($installPath, "CompanyPolicy",  "CompanyPolicy.config")

		# no config file 
		if(!(Test-Path $policyFilePath)) 
		{ 

			write-Host $policyFilePath
			return; 
		}

		# while loop, read file names
		$fileNameList = New-Object 'System.Collections.Generic.List[string]'

		[xml]$xmlContent = [xml](Get-Content -Path $policyFilePath)
		
		[System.Xml.XmlElement] $root = $xmlContent.get_DocumentElement()

		[System.Xml.XmlElement] $staticCodeAnalysis = $root.StaticCodeAnalysis


		if($staticCodeAnalysis -ne $null)
		{
				[System.Xml.XmlElement] $configuration = $null

				foreach($configuration in $staticCodeAnalysis.ChildNodes)
				{
					if($configuration.Attributes["ruleSet"] -ne $null)
					{
						[string]$ruleSet = $configuration.Attributes["ruleSet"].Value
						# add file name to list, only if not added yet
						if($fileNameList.Contains($ruleSet) -eq $false)
						{
							$fileNameList.Add($ruleSet)
						}
					}
				}
		}

		# iterate file names collection and copy them to solution directory
		foreach($fileName in $fileNameList)
		{
				AddFileToSettings $filename $filename $installPath "CompanyPolicy\StaticCodeAnalysis"  $settingsFolderName $solution
		}
		 
		## Signing

		[System.Xml.XmlElement] $signing = $root.Signing

		if($signing -ne $null)
		{
				[System.Xml.XmlElement] $configuration = $signing.ChildNodes | Select-Object -First 1

				if(($configuration.Attributes["enabled"] -ne $null) -and ($configuration.Attributes["enabled"].Value -eq "true"))
				{
					if($configuration.Attributes["keyFile"] -ne $null)
					{
						[string]$keyFile = $configuration.Attributes["keyFile"].Value
						
						AddFileToSettings $keyFile $keyFile $installPath "CompanyPolicy\Signing"  $settingsFolderName $solution
					}
				}
			}

		[System.Xml.XmlElement] $codeAnalysisDictionary = $root.CodeAnalysisDictionary

		if($codeAnalysisDictionary -ne $null)
		{
				[System.Xml.XmlElement] $configuration = $codeAnalysisDictionary.ChildNodes | Select-Object -First 1

					if($configuration.Attributes["dictionary"] -ne $null)
					{
						[string]$dictionary = $configuration.Attributes["dictionary"].Value
						
						AddFileToSettings $dictionary $dictionary $installPath "CompanyPolicy\CodeAnalysisDictionary"  $settingsFolderName $solution
					}
				}

		[System.Xml.XmlElement] $styleCop = $root.StyleCop

		if($styleCop -ne $null)
		{
				[System.Xml.XmlElement] $configuration = $styleCop.ChildNodes | Select-Object -First 1

				if($configuration.Attributes["settings"] -ne $null)
				{
					[string]$styleCopFileName = $configuration.Attributes["settings"].Value

					AddFileToSettings $styleCopFileName $styleCopFileName $installPath "CompanyPolicy\StyleCop"  $settingsFolderName $solution
				}
			}

		## Resharper

		[System.Xml.XmlElement] $resharperSettings = $root.Resharper

		if($resharperSettings -ne $null)
		{
				[System.Xml.XmlElement] $configuration = $resharperSettings.ChildNodes | Select-Object -First 1

				if($configuration.Attributes["settings"] -ne $null)
				{

					[string]$resharperSettingsFile = $configuration.Attributes["settings"].Value

					if($resharperSettingsFile -ne $null)
					{

						$resharperSettingsFilePath = [System.IO.Path]::Combine($installPath, "CompanyPolicy\Resharper", $resharperSettingsFile)

						$solutionFileName = [System.IO.Path]::GetFileName($solutionFile)
						$resharperSettingsNewFile = $solutionFileName + '.DotSettings'

						AddFileToSettings $resharperSettingsFile $resharperSettingsNewFile $installPath "CompanyPolicy\Resharper"  $settingsFolderName $solution

					}
				}
			}

		if($solution.IsDirty)
		{
			$solution.SaveAs($solutionFile)
		}

		write-Host "Finished Copying"
	}

