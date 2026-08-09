Configuration DevWorkstation
{
    param ()

    Import-DscResource -ModuleName 'PSDesiredStateConfiguration'

    Node 'localhost'
    {
        Environment DscProfileHome
        {
            Name   = 'DSC_PROFILE_HOME'
            Value  = 'C:\code\DSC-profile'
            Ensure = 'Present'
            Path   = $false
        }

        File CodeWorkspaceRoot
        {
            DestinationPath = 'C:\code'
            Type            = 'Directory'
            Ensure          = 'Present'
        }

        Registry ShowKnownFileExtensions
        {
            Key       = 'HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced'
            ValueName = 'HideFileExt'
            ValueData = '0'
            ValueType = 'Dword'
            Ensure    = 'Present'
        }

        Registry EnableLongPaths
        {
            Key       = 'HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem'
            ValueName = 'LongPathsEnabled'
            ValueData = '1'
            ValueType = 'Dword'
            Ensure    = 'Present'
        }

        Service DefenderRunning
        {
            Name        = 'WinDefend'
            State       = 'Running'
            StartupType = 'Automatic'
        }

        Service WindowsUpdateRunning
        {
            Name        = 'wuauserv'
            State       = 'Running'
            StartupType = 'Automatic'
        }
    }
}

DevWorkstation -OutputPath '.\DevWorkstation'
