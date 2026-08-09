Configuration AppConfigs
{
    param ()

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    $Root = $PSScriptRoot

    Node 'localhost'
    {
        File GitConfig
        {
            DestinationPath = 'C:\Users\tema\.gitconfig'
            SourcePath      = "$Root\configs\git\.gitconfig"
            Type            = 'File'
            Ensure          = 'Present'
            Checksum        = 'SHA-256'
            MatchSource     = $true
        }

        File VsCodeSettings
        {
            DestinationPath = 'C:\Users\tema\AppData\Roaming\Code\User\settings.json'
            SourcePath      = "$Root\configs\vscode\settings.json"
            Type            = 'File'
            Ensure          = 'Present'
            Checksum        = 'SHA-256'
            MatchSource     = $true
        }

        File VsCodeKeybindings
        {
            DestinationPath = 'C:\Users\tema\AppData\Roaming\Code\User\keybindings.json'
            SourcePath      = "$Root\configs\vscode\keybindings.json"
            Type            = 'File'
            Ensure          = 'Present'
            Checksum        = 'SHA-256'
            MatchSource     = $true
        }

        File WindowsTerminalSettings
        {
            DestinationPath = 'C:\Users\tema\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
            SourcePath      = "$Root\configs\windowsterminal\settings.json"
            Type            = 'File'
            Ensure          = 'Present'
            Checksum        = 'SHA-256'
            MatchSource     = $true
        }

        File GhConfig
        {
            DestinationPath = 'C:\Users\tema\AppData\Roaming\GitHub CLI\config.yml'
            SourcePath      = "$Root\configs\gh\config.yml"
            Type            = 'File'
            Ensure          = 'Present'
            Checksum        = 'SHA-256'
            MatchSource     = $true
        }

        File KeePassXCConfig
        {
            DestinationPath = 'C:\Users\tema\AppData\Roaming\KeePassXC\keepassxc.ini'
            SourcePath      = "$Root\configs\keepassxc\keepassxc.ini"
            Type            = 'File'
            Ensure          = 'Present'
            Checksum        = 'SHA-256'
            MatchSource     = $true
        }

        File PowerShellProfile
        {
            DestinationPath = 'C:\Users\tema\Documents\PowerShell\Microsoft.PowerShell_profile.ps1'
            SourcePath      = "$Root\configs\powershell\Microsoft.PowerShell_profile.ps1"
            Type            = 'File'
            Ensure          = 'Present'
            Checksum        = 'SHA-256'
            MatchSource     = $true
        }
    }
}

AppConfigs -OutputPath '.\AppConfigs'
