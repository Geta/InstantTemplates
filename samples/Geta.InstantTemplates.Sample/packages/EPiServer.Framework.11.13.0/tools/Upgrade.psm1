#$installPath is the path to the folder where the package is installed
param([string]$installPath)

#	The Update-EPiDataBase and Update-EPiConfig uses by default EPiServerDB connection string name and $package\tools\epiupdates path 
#	to find sql files and transformations file but if it needed to customize the connectionStringname 
#	then a settings.config file can be created (e.g. "settings.config" file under the $package\tools\settings.config).
#	The format of the settings file is like 
#		<settings>
#			<connectionStringName/>
#		</settings>
$setting = "settings.config"
$exportRootPackageName = "EPiUpdatePackage"
$frameworkPackageId = "EPiServer.Framework"
$tools_id = "tools"
$runBatFile = "update.bat"
$updatesPattern = "epiupdates*"
$defaultCommandTimeout = "1800"
$nl = [Environment]::NewLine

#	This CommandLet update DB 
#	It collects all scripts by default under $packagepath\tools\epiupdates
#   By default uses EPiServerDB connection string name and if the connection string name is different from default (EPiServerDB)
#	then it needs a settings.config (See setting for more information)
Function Update-EPiDatabase
{
<#
	.Description
		Update database by deploying updated sql files that can be found under nuget packages. The pattern to find sql files is nugetpackage.id.version\tools\epiupdates*.sql.
		By default uses EPiServerDB connection string name and if the connection string name is different from default (EPiServerDB)
		then it needs a settings.config in the epiupdates folder as: 
		<settings>
			<connectionStringName>MyConnectionString</connectionStringName>
		</settings>
    .SYNOPSIS 
		Update all Epi database
    .EXAMPLE
		Update-EPiDatabase
		Update-EPiDatabase -commandTimeout 60

#>
	[CmdletBinding()]
    param ([string]$commandTimeout = $defaultCommandTimeout)
	Update "sql" -Verbose:(GetVerboseFlag($PSBoundParameters)) $commandTimeout
}

#	This CommandLet update web config 
#	It collects all transformation config by default under $packagepath\tools\epiupdates
Function Update-EPiConfig
{
<#
	.Description
		Update config file by finding transform config files that can be found under nuget packages. The pattern to find transform config files is nugetpackage.id.version\tools\epiupdates*.config.
    .SYNOPSIS 
		Update config file.
    .EXAMPLE
		Update-EPiConfig
#>
	[CmdletBinding()]
    param ( )

	Update "config" -Verbose:($PSBoundParameters["Verbose"].IsPresent -eq $true)
}

#	This command can be used in the visual studio environment
#	Try to find all packages that related to the project that needs to be updated  
#   Create export package that can be used to update to the site
Function Export-EPiUpdates 
{
 <#
	.Description
		Export updated sql and transform config files that can be found under nuget packages. The pattern to find sql and transform config files is nugetpackage.id.version\tools\epiupdates*.
		The transform config files and sql files are saved in the EPiUpdatePackage folder. In the EPiUpdatePackage folder is uppdate.bat file that can be run on the site.
    .SYNOPSIS 
		Export updated sql files into EPiUpdatePackage.
    .EXAMPLE
		Export-EPiUpdates
		Export-EPiUpdates commandTimeout:30
#>
	[CmdletBinding()]
    param ($action = "sql", [string]$commandTimeout =$defaultCommandTimeout)
	
	$params = Getparams $installPath
	$packages = $params["packages"]
	$sitePath = $params["sitePath"]
	ExportPackages  $action $params["sitePath"]  $params["packagePath"] $packages $commandTimeout -Verbose:(GetVerboseFlag($PSBoundParameters))
}


Function Initialize-EPiDatabase
{
<#
	.Description
		Deploy all sql schema that can be found under nuget package. The pattern to find sql files is nugetpackage.id.version\tools\nugetpackage.id.sql.
		By default uses EPiServerDB connection string name and if the connection string name is different from default (EPiServerDB)
		then it needs a settings.config as: 
		<settings>
			<connectionStringName>MyConnectionString</connectionStringName>
		</settings>
    .SYNOPSIS 
		Deploy epi database schema.
    .EXAMPLE
		Initialize-EPiDatabase
		This command deploy all epi database schema that can be found in the nuget packages. 
	.EXAMPLE
		Initialize-EPiDatabase -sqlFilePattern:c:\data\mysql.sql -connectionString:MyConnectionString -commandTimeout:30
		This command deploy mysql.sql into database by using MyConnectionString. The -connectionString can be both connection string name inthe application web config or connection string.
#>
	[CmdletBinding()]
    param ([string]$sqlFilePattern, [string]$connectionString,[bool]$validation = $false, [string]$commandTimeout = $defaultCommandTimeout)

	$params = Getparams $installPath
	$packages = $params["packages"]
	$packagePath = $params["packagePath"]
	$sitePath = $params["sitePath"]

	$epideploy = GetDeployExe $packagePath $packages  
	if (!$epideploy)
	{
		throw "There is no EPiServer.Framework nuget package installed"
	}

	if (!$connectionString -and !$sqlFilePattern) 
	{
		# deploy all products
		DeploySqlFiles $epideploy $packages $packagePath $sitePath $validation $commandTimeout
		return
	}

	if (!$connectionString)
	{
		$connectionString = "EPiServerDB"
	}

	if ($sqlFilePattern)
	{
		DeploySqlFile $epideploy $connectionString $sqlFilePattern $sitePath $validation $commandTimeout
		return;	
	}
}

#	This command can be used in the visual studio environment
#	Try to find all packages that related to the project that has update  
#	Find out setting for each package
#   Call epideploy with -a config for each package
Function Update 
{
 	[CmdletBinding()]
    param ($action, [string]$commandTimeout = $defaultCommandTimeout)

	$params = Getparams $installPath
	$packages = $params["packages"]
	$sitePath = $params["sitePath"]
 
	Update-Packages $action $params["sitePath"] $params["packagePath"] $packages $commandTimeout -Verbose:(GetVerboseFlag($PSBoundParameters))
}


#	This command can be used in the visual studio environment
#	Export all packages that have epiupdates folder under tools path and
#	Create a bat (update.bat) that can be used to call on site
Function ExportPackages
{
 	[CmdletBinding()]
    param ($action, $sitePath, $packagesPath, $packages, $commandTimeout = $defaultCommandTimeout)

	CreateRootPackage  $exportRootPackageName
	$batFile  = AddUsage 
	$packages |foreach-object -process {
			$packageName = $_.id + "." + $_.version
			$packagePath = join-path $packagesPath $packageName
			$packageToolsPath = join-Path $packagePath $tools_id
			if (test-Path $packageToolsPath){
				$updatePackages = Get-ChildItem -path $packageToolsPath -Filter $updatesPattern
				if($updatePackages -ne $null) {
					foreach($p in $updatePackages) {
						$packageSetting = Get-PackageSetting $p.FullName
						ExportPackage $packagePath $packageName $p $packageSetting
						$des = join-path $packageName $p
						AddDeployCommand $action $batFile  $des $packageSetting $commandTimeout
					}
				}
			}
		}
	Add-Content $batFile.FullName ") $($nl)"
	ExportFrameworkTools $packagesPath $packages
	Write-Verbose "A $($runBatFile) file has been created in the $($exportRootPackageName)"
}

Function AddDeployCommand($action, $batFile,  $des, $packageSetting, $commandTimeout = $defaultCommandTimeout)
{
	if ($action -match "config")
	{
		$command =  "epideploy.exe  -a config -s ""%~f1""  -p ""$($des)\*"" -c ""$($packageSetting["connectionStringName"])"""
		Add-Content $batFile.FullName $command
	}
	if ($action -match "sql")
	{
		$command =  "epideploy.exe  -a sql -s ""%~f1""  -p ""$($des)\*""  -m ""$($commandTimeout)""  -c ""$($packageSetting["connectionStringName"])"""
		Add-Content $batFile.FullName $command
	}
}

Function AddUsage ()
{
	$content = "@echo off  $($nl) if '%1' ==''  ($($nl) echo  USAGE: %0  web application path ""[..\episerversitepath or c:\episerversitepath]"" $($nl)	) else ($($nl)" 
	New-Item (join-path $exportRootPackageName $runBatFile) -type file -force -value $content
}

Function CreateRootPackage ($deployPackagePath)
{
	if (test-path $deployPackagePath)
	{
		remove-Item -path $deployPackagePath -Recurse
	}
	$directory = New-Item -ItemType directory -Path $deployPackagePath
	Write-Host "An Export package is created $($directory.Fullname)"
}

Function ExportPackage($packagpath, $packageName, $updatePackage, $setting)
{
	$packageRootPath = join-path (join-Path $exportRootPackageName  $packageName) $updatePackage.Name
	write-Host "Exporting  $($updatePackage.Name) into $($packageRootPath)"
	$destinationupdatePath  = join-Path $packageRootPath  $package.Name
	copy-Item $updatePackage.FullName  -Destination $destinationupdatePath  -Recurse
	if ($setting["settingPath"])
	{
		copy-Item $setting["settingPath"]  -Destination $packageRootPath 
	}
}

Function GetEpiFrameworkFromPackages($packages)
{
	return (GetPackage $packages $frameworkPackageId)
}

Function DeploySqlFiles()
{
 	[CmdletBinding()]
	 param ($epideploy, $packages, $packagesPath, $sitePath, [bool]$validation = $false, [string]$commandTimeout = $defaultCommandTimeout)

	 $packages | foreach-object -process {
			$packageName = $_.id + "." + $_.version
			$packagePath = join-path $packagesPath $packageName
			$sqldatabaseFile = join-Path (join-Path $packagePath $tools_id) ( $_.id + ".sql")
			if (test-Path $sqldatabaseFile){
				$packageSetting = Get-PackageSetting $packagePath
				DeploySqlFile $epideploy $packageSetting["connectionStringName"] $sqldatabaseFile  $sitePath  $validation $commandTimeout
			}
		}
}

Function DeploySqlFile()
{
	[CmdletBinding()]
	param ($epideploy, [string]$connectionString, [string]$sqlFilePattern, [string]$sitePath, [bool]$validation = $false, [string]$commandTimeout = $defaultCommandTimeout)

	if ((($connectionString -Match "Data Source=") -eq $true) -or (($connectionString -Match "AttachDbFilename=") -eq $true) -or (($connectionString -Match "Initial Catalog=") -eq $true)) 
	{
		&$epideploy  -a "sql" -s $sitePath  -p $sqlFilePattern -b  $connectionString  -v $validation -d (GetVerboseFlag($PSBoundParameters)) -m $commandTimeout
	}
	else
	{
		&$epideploy  -a "sql" -s $sitePath  -p $sqlFilePattern -c  $connectionString  -v $validation -d (GetVerboseFlag($PSBoundParameters))  -m $commandTimeout
	}
}

Function GetPackage($packages, $packageid)
{
	$package = $packages | where-object  {$_.id -eq $packageid} | Sort-Object -Property version -Descending
	if ($package -ne $null)
	{
		return $package.id + "." + $package.version 
	}
}

Function ExportFrameworkTools($packagePath, $packages)
{
	$epiDeployPath = GetDeployExe $packagesPath  $packages
	copy-Item $epiDeployPath  -Destination $exportRootPackageName
}
 
Function Update-Packages
{
	[CmdletBinding()]
	param($action, $sitePath, $packagesPath, $packages, [string]$commandTimeout = $defaultCommandTimeout)
	$epiDeployPath = GetDeployExe $packagesPath  $packages
	$packages | foreach-object -process {
				$packagePath = join-path $packagesPath ($_.id + "." + $_.version)
				$packageToolsPath = join-Path $packagePath $tools_id
				if (test-Path $packageToolsPath){
					$updatePackages = Get-ChildItem -path $packageToolsPath -Filter $updatesPattern
					if($updatePackages -ne $null) {
						foreach($p in $updatePackages) {
							$settings = Get-PackageSetting $p.FullName
							Update-Package $p.FullName $action $sitePath $epiDeployPath  $settings  -Verbose:(GetVerboseFlag($PSBoundParameters)) $commandTimeout
						}
					}
				}
			}
}
 
Function Update-Package  
  {
	[CmdletBinding()]
    Param ($updatePath, $action, $sitePath, $epiDeployPath, $settings, [string]$commandTimeout = $defaultCommandTimeout)
	
    if (test-Path $updatePath)
	{
        Write-Verbose "$epiDeployPath  -a $action -s $sitePath  -p $($updatePath)\* -c $($settings["connectionStringName"]) "
		&$epiDeployPath  -a $action -s $sitePath  -p $updatePath\* -c $settings["connectionStringName"]  -d (GetVerboseFlag($PSBoundParameters)) -m $commandTimeout
	}
}

#	Find out EPiDeploy from frameworkpackage
Function GetDeployExe($packagesPath, $packages)
 {
	$frameWorkPackage = $packages |  where-object  {$_.id -eq $frameworkPackageId} | Sort-Object -Property version -Descending
	$frameWorkPackagePath = join-Path $packagesPath ($frameWorkPackage.id + "." + $frameWorkPackage.version)
	join-Path  $frameWorkPackagePath "tools\epideploy.exe"
 }

#	Find "settings.config" condig file under the package  
#	The format of the settings file is like 
#		<settings>
#			<connectionStringName/>
#		</settings>
Function Get-PackageSetting($packagePath)
{
	$packageSettings = Get-ChildItem -Recurse $packagePath -Include $setting | select -first 1
	if ($packageSettings -ne $null)
	{
		$xml = [xml](gc $packageSettings)
		if ($xml.settings.SelectSingleNode("connectionStringName") -eq $null)
		{
			$connectionStringName = $xml.CreateElement("connectionStringName")
			$xml.DocumentElement.AppendChild($connectionStringName)
		}
		if ([String]::IsNullOrEmpty($xml.settings.connectionStringName))
		{
			$xml.settings.connectionStringName  = "EPiServerDB"
		}
	}
	else
	{
		$xml = [xml] "<settings><connectionStringName>EPiServerDB</connectionStringName></settings>"
	}
	 @{"connectionStringName" = $($xml.settings.connectionStringName);"settingPath" = $packageSettings.FullName}
}

# Get base params
Function GetParams($installPath)
{
	#Get The current Project
	$project  = GetProject
	$projectPath = Get-ChildItem $project.Fullname
	#site path
	$sitePath = $projectPath.Directory.FullName
	#Get project packages 
	$packages = GetPackage($project.Name)
 
	if ($installPath)
	{
		#path to packages 
		$packagePath = (Get-Item -path $installPath -ErrorAction:SilentlyContinue).Parent.FullName
	}

	if (!$packagePath -or (test-path $packagePath) -eq $false)
	{
		throw "There is no 'nuget packages' directory"
	}

	@{"project" = $project; "packages" = $packages; "sitePath" = $sitePath; "packagePath" = $packagePath}
}

Function GetVerboseFlag ($parameters)
{
	($parameters["Verbose"].IsPresent -eq $true)
}

Function GetProject()
{
	Get-Project
}

Function GetPackage($projectName)
{
	Get-Package -ProjectName  $projectName
}
#Exported functions are Update-EPiDataBase Update-EPiConfig
export-modulemember -function  Update-EPiDatabase, Update-EPiConfig, Export-EPiUpdates, Initialize-EPiDatabase
# SIG # Begin signature block
# MIIY1QYJKoZIhvcNAQcCoIIYxjCCGMICAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUDEWCEA304Ia8ttLRv1JxVmNT
# wiugghP9MIID7jCCA1egAwIBAgIQfpPr+3zGTlnqS5p31Ab8OzANBgkqhkiG9w0B
# AQUFADCBizELMAkGA1UEBhMCWkExFTATBgNVBAgTDFdlc3Rlcm4gQ2FwZTEUMBIG
# A1UEBxMLRHVyYmFudmlsbGUxDzANBgNVBAoTBlRoYXd0ZTEdMBsGA1UECxMUVGhh
# d3RlIENlcnRpZmljYXRpb24xHzAdBgNVBAMTFlRoYXd0ZSBUaW1lc3RhbXBpbmcg
# Q0EwHhcNMTIxMjIxMDAwMDAwWhcNMjAxMjMwMjM1OTU5WjBeMQswCQYDVQQGEwJV
# UzEdMBsGA1UEChMUU3ltYW50ZWMgQ29ycG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFu
# dGVjIFRpbWUgU3RhbXBpbmcgU2VydmljZXMgQ0EgLSBHMjCCASIwDQYJKoZIhvcN
# AQEBBQADggEPADCCAQoCggEBALGss0lUS5ccEgrYJXmRIlcqb9y4JsRDc2vCvy5Q
# WvsUwnaOQwElQ7Sh4kX06Ld7w3TMIte0lAAC903tv7S3RCRrzV9FO9FEzkMScxeC
# i2m0K8uZHqxyGyZNcR+xMd37UWECU6aq9UksBXhFpS+JzueZ5/6M4lc/PcaS3Er4
# ezPkeQr78HWIQZz/xQNRmarXbJ+TaYdlKYOFwmAUxMjJOxTawIHwHw103pIiq8r3
# +3R8J+b3Sht/p8OeLa6K6qbmqicWfWH3mHERvOJQoUvlXfrlDqcsn6plINPYlujI
# fKVOSET/GeJEB5IL12iEgF1qeGRFzWBGflTBE3zFefHJwXECAwEAAaOB+jCB9zAd
# BgNVHQ4EFgQUX5r1blzMzHSa1N197z/b7EyALt0wMgYIKwYBBQUHAQEEJjAkMCIG
# CCsGAQUFBzABhhZodHRwOi8vb2NzcC50aGF3dGUuY29tMBIGA1UdEwEB/wQIMAYB
# Af8CAQAwPwYDVR0fBDgwNjA0oDKgMIYuaHR0cDovL2NybC50aGF3dGUuY29tL1Ro
# YXd0ZVRpbWVzdGFtcGluZ0NBLmNybDATBgNVHSUEDDAKBggrBgEFBQcDCDAOBgNV
# HQ8BAf8EBAMCAQYwKAYDVR0RBCEwH6QdMBsxGTAXBgNVBAMTEFRpbWVTdGFtcC0y
# MDQ4LTEwDQYJKoZIhvcNAQEFBQADgYEAAwmbj3nvf1kwqu9otfrjCR27T4IGXTdf
# plKfFo3qHJIJRG71betYfDDo+WmNI3MLEm9Hqa45EfgqsZuwGsOO61mWAK3ODE2y
# 0DGmCFwqevzieh1XTKhlGOl5QGIllm7HxzdqgyEIjkHq3dlXPx13SYcqFgZepjhq
# IhKjURmDfrYwggSjMIIDi6ADAgECAhAOz/Q4yP6/NW4E2GqYGxpQMA0GCSqGSIb3
# DQEBBQUAMF4xCzAJBgNVBAYTAlVTMR0wGwYDVQQKExRTeW1hbnRlYyBDb3Jwb3Jh
# dGlvbjEwMC4GA1UEAxMnU3ltYW50ZWMgVGltZSBTdGFtcGluZyBTZXJ2aWNlcyBD
# QSAtIEcyMB4XDTEyMTAxODAwMDAwMFoXDTIwMTIyOTIzNTk1OVowYjELMAkGA1UE
# BhMCVVMxHTAbBgNVBAoTFFN5bWFudGVjIENvcnBvcmF0aW9uMTQwMgYDVQQDEytT
# eW1hbnRlYyBUaW1lIFN0YW1waW5nIFNlcnZpY2VzIFNpZ25lciAtIEc0MIIBIjAN
# BgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAomMLOUS4uyOnREm7Dv+h8GEKU5Ow
# mNutLA9KxW7/hjxTVQ8VzgQ/K/2plpbZvmF5C1vJTIZ25eBDSyKV7sIrQ8Gf2Gi0
# jkBP7oU4uRHFI/JkWPAVMm9OV6GuiKQC1yoezUvh3WPVF4kyW7BemVqonShQDhfu
# ltthO0VRHc8SVguSR/yrrvZmPUescHLnkudfzRC5xINklBm9JYDh6NIipdC6Anqh
# d5NbZcPuF3S8QYYq3AhMjJKMkS2ed0QfaNaodHfbDlsyi1aLM73ZY8hJnTrFxeoz
# C9Lxoxv0i77Zs1eLO94Ep3oisiSuLsdwxb5OgyYI+wu9qU+ZCOEQKHKqzQIDAQAB
# o4IBVzCCAVMwDAYDVR0TAQH/BAIwADAWBgNVHSUBAf8EDDAKBggrBgEFBQcDCDAO
# BgNVHQ8BAf8EBAMCB4AwcwYIKwYBBQUHAQEEZzBlMCoGCCsGAQUFBzABhh5odHRw
# Oi8vdHMtb2NzcC53cy5zeW1hbnRlYy5jb20wNwYIKwYBBQUHMAKGK2h0dHA6Ly90
# cy1haWEud3Muc3ltYW50ZWMuY29tL3Rzcy1jYS1nMi5jZXIwPAYDVR0fBDUwMzAx
# oC+gLYYraHR0cDovL3RzLWNybC53cy5zeW1hbnRlYy5jb20vdHNzLWNhLWcyLmNy
# bDAoBgNVHREEITAfpB0wGzEZMBcGA1UEAxMQVGltZVN0YW1wLTIwNDgtMjAdBgNV
# HQ4EFgQURsZpow5KFB7VTNpSYxc/Xja8DeYwHwYDVR0jBBgwFoAUX5r1blzMzHSa
# 1N197z/b7EyALt0wDQYJKoZIhvcNAQEFBQADggEBAHg7tJEqAEzwj2IwN3ijhCcH
# bxiy3iXcoNSUA6qGTiWfmkADHN3O43nLIWgG2rYytG2/9CwmYzPkSWRtDebDZw73
# BaQ1bHyJFsbpst+y6d0gxnEPzZV03LZc3r03H0N45ni1zSgEIKOq8UvEiCmRDoDR
# EfzdXHZuT14ORUZBbg2w6jiasTraCXEQ/Bx5tIB7rGn0/Zy2DBYr8X9bCT2bW+IW
# yhOBbQAuOA2oKY8s4bL0WqkBrxWcLC9JG9siu8P+eJRRw4axgohd8D20UaF5Mysu
# e7ncIAkTcetqGVvP6KUwVyyJST+5z3/Jvz4iaGNTmr1pdKzFHTx/kuDDvBzYBHUw
# ggVnMIIET6ADAgECAhEAmC+SaSXEmwKb5aP3fjOjVTANBgkqhkiG9w0BAQsFADB8
# MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYD
# VQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJDAiBgNVBAMT
# G1NlY3RpZ28gUlNBIENvZGUgU2lnbmluZyBDQTAeFw0xOTA1MjIwMDAwMDBaFw0y
# MjA1MjEyMzU5NTlaMIG1MQswCQYDVQQGEwJTRTEOMAwGA1UEEQwFMTExNTYxDzAN
# BgNVBAgMBlN3ZWRlbjESMBAGA1UEBwwJU3RvY2tob2xtMRowGAYDVQQJDBFSZWdl
# cmluZ3NnYXRhbiA2NzERMA8GA1UEEgwIQm94IDcwMDcxFTATBgNVBAoMDEVwaXNl
# cnZlciBBQjEUMBIGA1UECwwLRW5naW5lZXJpbmcxFTATBgNVBAMMDEVwaXNlcnZl
# ciBBQjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBALMg0HiSm99PJyVg
# buJFKNjRyi98VFKF4lTVA4GXfXgixyErz+ISaHcXrjxEW1CkH55+Vh+LDjBIMqJ2
# mOC+2d/Dh9OwZINayxOxV+gsqGH7F+7o//+EAWztkRH9Etw2IBedwlTeZvZitKew
# 6gYWZwMq7wM5Ndp7oaXw8E4MXviOY6Lof390xWWy3BhWRu9I37JhU4vkrnxg4cPZ
# 8sZYb0OEw/n0mvJ2Y2wjyRUQYZXtUHyAe2c5lfmDpdFkFf7QEPB9Erkm19MvF6Rv
# Av9hkaeQbNnFAKbJcp57ewpDdEMzR+CrLkwjSZhX5HM39/Aq/O58e4fCfSIotBYS
# nDZcjrcCAwEAAaOCAagwggGkMB8GA1UdIwQYMBaAFA7hOqhTOjHVir7Bu61nGgOF
# rTQOMB0GA1UdDgQWBBT8FQmibCssGc1dLqmLA0Jk40EuJDAOBgNVHQ8BAf8EBAMC
# B4AwDAYDVR0TAQH/BAIwADATBgNVHSUEDDAKBggrBgEFBQcDAzARBglghkgBhvhC
# AQEEBAMCBBAwQAYDVR0gBDkwNzA1BgwrBgEEAbIxAQIBAwIwJTAjBggrBgEFBQcC
# ARYXaHR0cHM6Ly9zZWN0aWdvLmNvbS9DUFMwQwYDVR0fBDwwOjA4oDagNIYyaHR0
# cDovL2NybC5zZWN0aWdvLmNvbS9TZWN0aWdvUlNBQ29kZVNpZ25pbmdDQS5jcmww
# cwYIKwYBBQUHAQEEZzBlMD4GCCsGAQUFBzAChjJodHRwOi8vY3J0LnNlY3RpZ28u
# Y29tL1NlY3RpZ29SU0FDb2RlU2lnbmluZ0NBLmNydDAjBggrBgEFBQcwAYYXaHR0
# cDovL29jc3Auc2VjdGlnby5jb20wIAYDVR0RBBkwF4EVc3VwcG9ydEBlcGlzZXJ2
# ZXIuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQCEvy8b9Y9uMcMSgC6H4qSrY0WetAMr
# QwTIea4KhaNDA/6C5hwfDv9HyOupMkBFgOUx2nxvH0MPy1yAC6EH2wtk+VCIbIYA
# hDPKLMdJ2s8UqCjbIAFKfCCh1im+VtUkQnFDWKNt+fLfKk9CfAd2lhS0NnUEmSzj
# 8/z4QwRO06asyL2i0VjdicUQTvRVEEoVqABvUisChgJMyp+yRHi5SbXDoSfiaIV/
# Hx+JILrr2nBAQ0Cj5KXHW0DnBAFyGqXTC62iFKz2ToNG250Dk+FWX1zBbQShc9ne
# muHX/HYmYWEg8M/9YorIYwDDEFNFjupbDPP67cA7vauuXqsuy2TcdXo9MIIF9TCC
# A92gAwIBAgIQHaJIMG+bJhjQguCWfTPTajANBgkqhkiG9w0BAQwFADCBiDELMAkG
# A1UEBhMCVVMxEzARBgNVBAgTCk5ldyBKZXJzZXkxFDASBgNVBAcTC0plcnNleSBD
# aXR5MR4wHAYDVQQKExVUaGUgVVNFUlRSVVNUIE5ldHdvcmsxLjAsBgNVBAMTJVVT
# RVJUcnVzdCBSU0EgQ2VydGlmaWNhdGlvbiBBdXRob3JpdHkwHhcNMTgxMTAyMDAw
# MDAwWhcNMzAxMjMxMjM1OTU5WjB8MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3Jl
# YXRlciBNYW5jaGVzdGVyMRAwDgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0
# aWdvIExpbWl0ZWQxJDAiBgNVBAMTG1NlY3RpZ28gUlNBIENvZGUgU2lnbmluZyBD
# QTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAIYijTKFehifSfCWL2MI
# Hi3cfJ8Uz+MmtiVmKUCGVEZ0MWLFEO2yhyemmcuVMMBW9aR1xqkOUGKlUZEQauBL
# Yq798PgYrKf/7i4zIPoMGYmobHutAMNhodxpZW0fbieW15dRhqb0J+V8aouVHltg
# 1X7XFpKcAC9o95ftanK+ODtj3o+/bkxBXRIgCFnoOc2P0tbPBrRXBbZOoT5Xax+Y
# vMRi1hsLjcdmG0qfnYHEckC14l/vC0X/o84Xpi1VsLewvFRqnbyNVlPG8Lp5UEks
# 9wO5/i9lNfIi6iwHr0bZ+UYc3Ix8cSjz/qfGFN1VkW6KEQ3fBiSVfQ+noXw62oY1
# YdMCAwEAAaOCAWQwggFgMB8GA1UdIwQYMBaAFFN5v1qqK0rPVIDh2JvAnfKyA2bL
# MB0GA1UdDgQWBBQO4TqoUzox1Yq+wbutZxoDha00DjAOBgNVHQ8BAf8EBAMCAYYw
# EgYDVR0TAQH/BAgwBgEB/wIBADAdBgNVHSUEFjAUBggrBgEFBQcDAwYIKwYBBQUH
# AwgwEQYDVR0gBAowCDAGBgRVHSAAMFAGA1UdHwRJMEcwRaBDoEGGP2h0dHA6Ly9j
# cmwudXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FDZXJ0aWZpY2F0aW9uQXV0aG9y
# aXR5LmNybDB2BggrBgEFBQcBAQRqMGgwPwYIKwYBBQUHMAKGM2h0dHA6Ly9jcnQu
# dXNlcnRydXN0LmNvbS9VU0VSVHJ1c3RSU0FBZGRUcnVzdENBLmNydDAlBggrBgEF
# BQcwAYYZaHR0cDovL29jc3AudXNlcnRydXN0LmNvbTANBgkqhkiG9w0BAQwFAAOC
# AgEATWNQ7Uc0SmGk295qKoyb8QAAHh1iezrXMsL2s+Bjs/thAIiaG20QBwRPvrjq
# iXgi6w9G7PNGXkBGiRL0C3danCpBOvzW9Ovn9xWVM8Ohgyi33i/klPeFM4MtSkBI
# v5rCT0qxjyT0s4E307dksKYjalloUkJf/wTr4XRleQj1qZPea3FAmZa6ePG5yOLD
# CBaxq2NayBWAbXReSnV+pbjDbLXP30p5h1zHQE1jNfYw08+1Cg4LBH+gS667o6XQ
# hACTPlNdNKUANWlsvp8gJRANGftQkGG+OY96jk32nw4e/gdREmaDJhlIlc5KycF/
# 8zoFm/lv34h/wCOe0h5DekUxwZxNqfBZslkZ6GqNKQQCd3xLS81wvjqyVVp4Pry7
# bwMQJXcVNIr5NsxDkuS6T/FikyglVyn7URnHoSVAaoRXxrKdsbwcCtp8Z359Luko
# TBh+xHsxQXGaSynsCz1XUNLK3f2eBVHlRHjdAd6xdZgNVCT98E7j4viDvXK6yz06
# 7vBeF5Jobchh+abxKgoLpbn0nu6YMgWFnuv5gynTxix9vTp3Los3QqBqgu07SqqU
# EKThDfgXxbZaeTMYkuO1dfih6Y4KJR7kHvGfWocj/5+kUZ77OYARzdu1xKeogG/l
# U9Tg46LC0lsa+jImLWpXcBw8pFguo/NbSwfcMlnzh6cabVgxggRCMIIEPgIBATCB
# kTB8MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAw
# DgYDVQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJDAiBgNV
# BAMTG1NlY3RpZ28gUlNBIENvZGUgU2lnbmluZyBDQQIRAJgvkmklxJsCm+Wj934z
# o1UwCQYFKw4DAhoFAKB4MBgGCisGAQQBgjcCAQwxCjAIoAKAAKECgAAwGQYJKoZI
# hvcNAQkDMQwGCisGAQQBgjcCAQQwHAYKKwYBBAGCNwIBCzEOMAwGCisGAQQBgjcC
# ARUwIwYJKoZIhvcNAQkEMRYEFHeqscy1UhIoNCS0u7isb5hImjDGMA0GCSqGSIb3
# DQEBAQUABIIBAIlyuKZOv5zpuN0rP6Dju/4RS3Tey1EQTiyhjKoM0+nhQuKutzmu
# rEbHt8tB0CvVgtPb2fzw85T0Q+e8AdU3nzJQZlNXPaoKoArL4PF7FUL8wNeL9ElC
# OOZc6jgN7hvkI3wfN7asqK5hURM6ckNTlvchkswr/tpGt1Efal49CDVa1WhZ37PR
# xbF0s9ClSGXOr/stHzRvFYaMepbKMfR0xlcqczUJA0g9414FDl123vldswbUZaHq
# O4nn/azbyXo/QnkZmpBdUL2LHnpN9LTVVjOnFZfBSaklp7Iatv/JlbONQ7eAqjXU
# qjtpIB3WNjpz3wrzH63O7AArgLhcGuwMFRKhggILMIICBwYJKoZIhvcNAQkGMYIB
# +DCCAfQCAQEwcjBeMQswCQYDVQQGEwJVUzEdMBsGA1UEChMUU3ltYW50ZWMgQ29y
# cG9yYXRpb24xMDAuBgNVBAMTJ1N5bWFudGVjIFRpbWUgU3RhbXBpbmcgU2Vydmlj
# ZXMgQ0EgLSBHMgIQDs/0OMj+vzVuBNhqmBsaUDAJBgUrDgMCGgUAoF0wGAYJKoZI
# hvcNAQkDMQsGCSqGSIb3DQEHATAcBgkqhkiG9w0BCQUxDxcNMTkwODE2MDczNzU5
# WjAjBgkqhkiG9w0BCQQxFgQUgNMVu3OMoA+35aOMZIj3IPM1ExAwDQYJKoZIhvcN
# AQEBBQAEggEAHsIaqBUraHs0Q0uoqdkjU3CZdCd6G5env3/5QxNOUkWncjcSr2zY
# Dx6h+I2+EmuYcZNU8NMueg01CFWLFnk0fqKyH615yLExwDHw/6tzzDGXfyVrdaY5
# TQfgsXr1uru8xpW59LzDZOWx8DJTxnaI6LjmWMZp3wlZYl32jMg1TneCsoPLiC7M
# pSUFMfvYh5eh92Rt+mFboBdxyFjyZHEwNwX27zpiiHHKZGTr8AfjGZh00A268v+g
# 0QXvFncWtTmOV2g8ov9FVyHofyMygt1sSbqE5hsGUAiGo+qbztVJBq4r9Zp6ph+F
# Y9H3GkmYRRQD/KkqAH6v99QPWAii+ZfO4w==
# SIG # End signature block
