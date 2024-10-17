
# Icons
$script:CursorIcon = [char]0x276F    # provided by ChatGPT
$script:BranchIcon = [char]0xe0a0    # nf-pl-branch 
$script:DotnetIcon = [char]0xe77f    # nf-dev-dotnet 
# $script:DotnetIcon = [char]0xDB82 + [char]0xDEAE    # nf-md-dot_net 󰪮
$script:RustIcon = [char]0xe7a8      # nf-dev-rust 
$script:CIcon = [char]0xe61e         # nf-custom-c 
$script:PythonIcon = [char]0xe73c    # nf-dev-python 
$script:MarkdownIcon = [char]0xe73e  # nf-dev-markdown 
$script:GitFolderIcon = [char]0xe5fb # nf-custom-folder_git 

# Powerline
$script:PowerlineRightRound = [char]0xE0B4
$script:PowerlineLeftRound = [char]0xE0B6
$script:PowerlineRightTriangle = [char]0xE0B0
$script:PowerlineLeftTriangle = [char]0xE0B2
$script:PowerlineSmallPixelRight = [char]0xE0C4
$script:PowerlineSmallPixelLeft = [char]0xE0C5

# Colors - Rose Pine
## Clear
$script:Clear = "`e[0m"
## Dawn
$script:DawnBaseBackground = "`e[48;2;250;244;237m"
$script:DawnBaseForeground = "`e[38;2;250;244;237m"
$script:DawnTextBackground = "`e[48;2;87;82;121m"
$script:DawnTextForeground = "`e[38;2;87;82;121m"
$script:DawnLoveBackground = "`e[48;2;180;99;122m"
$script:DawnLoveForeground = "`e[38;2;180;99;122m"
$script:DawnGoldBackground = "`e[48;2;234;157;52m"
$script:DawnGoldForeground = "`e[38;2;234;157;52m"
$script:DawnRoseBackground = "`e[48;2;215;130;126m"
$script:DawnRoseForeground = "`e[38;2;215;130;126m"
$script:DawnPineBackground = "`e[48;2;40;105;131m"
$script:DawnPineForeground = "`e[38;2;40;105;131m"
$script:DawnFoamBackground = "`e[48;2;86;148;159m"
$script:DawnFoamForeground = "`e[38;2;86;148;159m"
$script:DawnIrisBackground = "`e[48;2;144;122;169m"
$script:DawnIrisForeground = "`e[38;2;144;122;169m"
## Moon
$script:MoonBaseBackground = "`e[48;2;35;33;54m"
$script:MoonBaseForeground = "`e[38;2;35;33;54m"
$script:MoonTextForeground = "`e[48;2;224;222;244m"
$script:MoonTextForeground = "`e[38;2;224;222;244m"
$script:MoonLoveBackground = "`e[48;2;235;111;146m"
$script:MoonLoveForeground = "`e[38;2;235;111;146m"
$script:MoonGoldBackground = "`e[48;2;246;193;119m"
$script:MoonGoldForeground = "`e[38;2;246;193;119m"
$script:MoonRoseBackground = "`e[48;2;234;154;151m"
$script:MoonRoseForeground = "`e[38;2;234;154;151m"
$script:MoonPineBackground = "`e[48;2;62;143;176m"
$script:MoonPineForeground = "`e[38;2;62;143;176m"
$script:MoonFoamBackground = "`e[48;2;156;207;216m"
$script:MoonFoamForeground = "`e[38;2;156;207;216m"
$script:MoonIrisBackground = "`e[48;2;196;167;231m"
$script:MoonIrisForeground = "`e[38;2;196;167;231m"

#Buffers
$script:builder = [System.Text.StringBuilder]::new()

# Override default prompt
function prompt {
    $start = [System.TimeProvider]::System.GetTimestamp()

    $git = Get-GitStats

    if ($null -eq $git) {
        $programmingLanguage = Get-Language
        if ($null -eq $programmingLanguage) {
            Clear-PromptText
            Add-PromptText (Get-PathSegment)
        }
        else {
            Clear-PromptText
            Add-PromptText (Get-PathSegment)
            Add-PromptSeparator
            Add-PromptText $programmingLanguage
        }
    }
    else {
        $programmingLanguage = Get-Language
        $relativePath = $PWD.Path.Substring((Split-Path -Parent -Path $git.TopLevel).Length + 1)
        Clear-PromptText
        Add-PromptText $relativePath
        if ($null -ne $programmingLanguage) {
            Add-PromptSeparator
            Add-PromptText $programmingLanguage
        }
        Add-PromptSeparator
        if ($null -ne $git.Branch) {
            Add-PromptText "$($git.Branch) "
        }
        Add-PromptText "$($git.Commit) $($script:MoonPineForeground)+$($git.AddedFiles) $($script:MoonLoveForeground)-$($git.DeletedFiles) $($script:MoonRoseForeground)~$($git.ModifiedFiles) $($($script:MoonGoldForeground))"
    }

    $elapsed = [System.TimeProvider]::System.GetElapsedTime($start)

    Add-PromptSeparator
    Add-PromptText "$([System.String]::Format('{0:F0}', $elapsed.TotalMilliseconds)) ms"

    Get-PromptText
}

function Format-Measure {
    param ($MeasureResult)
    "$($MeasureResult.Milliseconds) ms $($MeasureResult.Microseconds) us $($MeasureResult.Nanoseconds) ns"
}

function Clear-PromptText {
    $script:builder.Clear() | Out-Null
}

function Get-PromptText {
    Add-PromptText $script:MoonGoldForeground
    Add-PromptText " $($script:CursorIcon) "
    Add-PromptText $script:Clear
    return $script:builder.ToString()
}

function Add-PromptText {
    param ([string]$Text)
    $script:builder.Append($Text) | Out-Null
}

function Add-PromptSeparator {
    Add-PromptText $script:MoonGoldForeground
    Add-PromptText " $($script:CursorIcon) "
    Add-PromptText $script:Clear
}

function Get-PathSegment {
    $currentDirectory = $PWD.Path
    $currentDirectoryPathing = $currentDirectory -split '\\'

    if ($currentDirectoryPathing.Length -gt 2) {
        return "$($currentDirectoryPathing[0])\...\$($currentDirectoryPathing[-1])"
    }
    else {
        return $currentDirectory
    }
}

function Get-Language {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]
        $SearchPath = '.'
    )

    $safeSearchPath = (Resolve-Path -Path $SearchPath).Path

    $files = @(Get-ChildItem -Path $safeSearchPath -File)

    foreach ($file in $files) {
        if ($file.Extension -eq '.cs' -or $file.Extension -eq ".csproj" -or $file.Extension -eq ".sln" -or $file.Extension -eq ".slnx") {
            # every .NET icon has a spacing issue. We'll add space as our best ability.
            return "$($script:DotnetIcon)  $(Get-CurrentDotnetVersion)"
        }
    }

    foreach ($file in $files) {
        if ($file.Extension -eq '.cpp' -or $file.Extension -eq ".hpp" -or $file.Extension -eq ".h" -or $file.Extension -eq ".c" -or $file.Extension -eq ".vcxproj") {
            return "$($script:CIcon)"
        }
    }

    foreach ($file in $files) {
        if ($file.Extension -eq ".rs" -or $file.Name -ieq "Cargo.toml") {
            return "$($script:RustIcon)"
        }
    }

    foreach ($file in $files) {
        if ($file.Extension -eq ".py") {
            return "$($script:PythonIcon)"
        }
    }

    foreach ($file in $files) {
        if ($file.Extension -eq ".md") {
            return "$($script:MarkdownIcon)"
        }
    }

    $gitTopLevel = Get-GitTopLevel

    if ($null -ne $gitTopLevel) {
        if ($safeSearchPath -gt $gitTopLevel.Length) {
            $upperLanguage = Get-Language -SearchPath (Split-path -Parent $safeSearchPath)
            if ($null -ne $upperLanguage) {
                return $upperLanguage
            }
        }
    }

    return $null
}

function Get-GitTopLevel {
    $topLevel = (git --no-optional-locks rev-parse --show-toplevel 2>$null)

    if ($null -ne $topLevel) {
        return $topLevel
    }

    return $null
}

function Get-GitStatus {
    $porcelain = (git --no-optional-locks status --porcelain=v2 --branch --untracked-files=no 2>$null)

    if ($null -ne $porcelain) {
        return $porcelain
    }

    return $null
}

function Get-GitStats {
    $gitStatus = Get-GitStatus

    if ($null -ne $gitStatus) {
        $branch = $null
        $commit = $null
        $untrackedFilesCount = 0
        $addedFilesCount = 0
        $modifiedFilesCount = 0
        $deletedFilesCount = 0
        $renamedFilesCount = 0
        $copiedFilesCount = 0
        $typeChangedFilesCount = 0
        $unmergedFilesCount = 0
        $ignoredFilesCount = 0

        foreach ($line in $gitStatus) {
            if ($line.StartsWith("# branch.oid")) {
                $commit = $line.Substring(13, 8)
            }
            elseif ($line.StartsWith("# branch.head")) {
                $branch = $line.Substring(14)
            }
            elseif ($line.StartsWith("?")) {
                $untrackedFilesCount++;
            }
            elseif ($line.StartsWith("A")) {
                $addedFilesCount++;
            }
            elseif ($line.StartsWith("M") -or $line.StartsWith("AM")) {
                $modifiedFilesCount++;
            }
            elseif ($line.StartsWith("D")) {
                $deletedFilesCount++;
            }
            elseif ($line.StartsWith("R")) {
                $renamedFilesCount++;
            }
            elseif ($line.StartsWith("C")) {
                $copiedFilesCount++;
            }
            elseif ($line.StartsWith("T")) {
                $typeChangedFilesCount++;
            }
            elseif ($line.StartsWith("U")) {
                $unmergedFilesCount++;
            }
            elseif ($line.StartsWith("!")) {
                $ignoredFilesCount++;
            }
        }

        $topLevel = Get-GitTopLevel

        [PSCustomObject]@{
            TopLevel         = $topLevel
            Branch           = $branch
            Commit           = $commit
            UntrackedFiles   = $untrackedFilesCount
            AddedFiles       = $addedFilesCount
            ModifiedFiles    = $modifiedFilesCount
            DeletedFiles     = $deletedFilesCount
            RenamedFiles     = $renamedFilesCount
            CopiedFiles      = $copiedFilesCount
            TypeChangedFiles = $typeChangedFilesCount
            UnmergedFiles    = $unmergedFilesCount
            IgnoredFiles     = $ignoredFilesCount
        }
    }

    return $null
}

function Get-CurrentDotnetVersion {
    return (dotnet --version)
}

# Import the Chocolatey Profile.
# See https://ch0.co/tab-completion for details.
$ChocolateyProfile = [System.IO.Path]::Combine($env:ChocolateyInstall, 'helpers', 'chocolateyProfile.psm1')
if ([System.IO.File]::Exists($ChocolateyProfile)) {
    Import-Module "$ChocolateyProfile"
}

# Disable highlighting of directories.
$PSStyle.FileInfo.Directory = ""

# Enable history picker by default.
Set-PSReadLineOption -HistoryNoDuplicates -PredictionViewStyle ListView

# Set to dev drive repos
Set-Location -Path 'D:\repos'
