[CmdletBinding()]
param ()

########################################################################
# Define your environment
########################################################################

# Grab the OS drive
$osDrive = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Windows).Substring(0, 3)

# Setup your Dev Drive if applicable.
# If you do not have a Dev Drive, just set this to the full directory
# path where you want all of your developer stuff to live.
$devDrive = 'D:\'

# This is for environments where the home for the user is a network drive.
#
# If you do not want your normal/default user profile to be used, set this to
# something under "devDrive" to keep all of your stuff in one place.
#
# IMPORTANT: This will affect the location of other tools sets and languages,
#            like dotnet tools, rust cargo, python pip, .gitconfig, etc.
#
# IMPORTANT: VS Code is defaulting to %USERPROFILE% and will no longer be able to find
#            the .gitconfig from %HOME%. We setup a symbolic link to handle this.
#
# $devHome = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile)
$devHome = [System.IO.Path]::Combine($devDrive, "dev-home")

########################################################################
# Read, Set, Go!!!
########################################################################
$myScriptPath = $MyInvocation.MyCommand.Path
$originalWorkingDirectory = Get-Location

Write-Verbose "OS Drive: '$($osDrive)'"
Write-Verbose "This Script Location: '$($myScriptPath)'"
Write-Verbose "Working Directory: '$($originalWorkingDirectory)'"

Write-Output  "Setting up your development environment."

$reposDirectroy = [System.IO.Path]::Combine($devDrive, "repos")
$nugetDirectory = [System.IO.Path]::Combine($devHome, ".nuget")
$defaultGitconfigFile = [System.IO.Path]::Combine($devHome, ".gitconfig")

try {
    ########################################################################
    # Dev Home Setup
    ########################################################################
    Write-Output "Setting up dev home."
    [System.IO.Directory]::CreateDirectory($devHome) | Out-Null
    [System.Environment]::SetEnvironmentVariable("HOME", $devHome, [System.EnvironmentVariableTarget]::User)

    ########################################################################
    # Repos Setup
    ########################################################################
    Write-Output "Setting up repos."
    [System.IO.Directory]::CreateDirectory($reposDirectroy) | Out-Null

    ########################################################################
    # Git
    ########################################################################
    Write-Output "Setting up git."

    $userprofileGitconfigFilePath = [System.IO.Path]::Combine([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::UserProfile), ".gitconfig")

    if (([System.IO.File]::Exists($defaultGitconfigFile) -eq $false)) {
        if ([System.IO.File]::Exists($userprofileGitconfigFilePath)) {
            Write-Output "Copying existing .gitconfig to dev home."
            [System.IO.File]::Copy($userprofileGitconfigFilePath, $defaultGitconfigFile)
        }
        else {
            $gitconfigBuilder = [System.Text.StringBuilder]::new(256)
            $gitconfigBuilder.AppendLine("[user]") | Out-Null
            $gitconfigBuilder.AppendLine("    name = ") | Out-Null
            $gitconfigBuilder.AppendLine("    email = ") | Out-Null
            $gitconfigBuilder.AppendLine("[init]") | Out-Null
            $gitconfigBuilder.AppendLine("    defaultBranch = main") | Out-Null
            $gitconfigContent = $gitconfigBuilder.ToString()
            [System.IO.File]::WriteAllText($defaultGitconfigFile, $gitconfigContent)
        }
    }

    # Create a symbolic link from $userprofileGitconfigFilePath to $defaultGitconfigFile
    if (([System.IO.File]::Exists($userprofileGitconfigFilePath)) -eq $true) {
        [System.IO.File]::Delete($userprofileGitconfigFilePath) | Out-Null
    }

    # Workaround for VS Code and other tools that expect .gitconfig to be in %USERPROFILE%
    New-Item -ItemType SymbolicLink -Path $userprofileGitconfigFilePath -Target $defaultGitconfigFile | Out-Null

    ########################################################################
    # NuGet Setup
    ########################################################################
    Write-Output "Setting up nuget."
    $globalPackagesNugetDirectory = [System.IO.Path]::Combine($nugetDirectory, "packages")
    $httpCacheNugetDirectory = [System.IO.Path]::Combine($nugetDirectory, "http-cache")
    $tempNugetDirectory = [System.IO.Path]::Combine($nugetDirectory, "scratch")
    $pluginsCacheNugetDirectory = [System.IO.Path]::Combine($nugetDirectory, "plugins-cache")

    [System.IO.Directory]::CreateDirectory($globalPackagesNugetDirectory) | Out-Null
    [System.IO.Directory]::CreateDirectory($httpCacheNugetDirectory) | Out-Null
    [System.IO.Directory]::CreateDirectory($tempNugetDirectory) | Out-Null
    [System.IO.Directory]::CreateDirectory($pluginsCacheNugetDirectory) | Out-Null

    [System.Environment]::SetEnvironmentVariable("NUGET_PACKAGES", $globalPackagesNugetDirectory, [System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable("NUGET_HTTP_CACHE_PATH", $httpCacheNugetDirectory, [System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable("NUGET_PLUGIN_PATH", $pluginsCacheNugetDirectory, [System.EnvironmentVariableTarget]::User)
    [System.Environment]::SetEnvironmentVariable("NUGET_TEMP_PATH", $tempNugetDirectory, [System.EnvironmentVariableTarget]::User)

    # At this point, everything else is going to route to %HOME% where applicable or is ready for your additional configurations.
    Write-Output "Complete!"
}
catch {
    Write-Error $PSItem.Exception.Message
}
finally {
    if ((Get-Location) -ne $originalWorkingDirectory) {
        Set-Location -Path $originalWorkingDirectory
    }
}