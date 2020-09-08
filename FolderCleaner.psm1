Function Remove-OldFiles {
    <#
    .SYNOPSIS
        Removes Files that have not been written to or has been created past the date limit or date specified

    .EXAMPLE
        PS C:\> Remove-OldFiles -FilePath 'C:\Users\User\Downloads', 'C:\Users\User\Desktop' -Days 30
        Remove files that are older than 30 days since files last write time in each directory

    .EXAMPLE
        PS C:> Get-ChildItem -Directory | Remove-OldFiles -Date $(Get-Date).AddDays(-30) -Type CreationTime
        Removes any files from each piped directory that creation time is older than 30 days

    .PARAMETER FilePath
        Location of the files

    .PARAMETER Daylimit
        Number of days from today before files are deleted (Default = 30)

    .PARAMETER Date
        Date limit that files path will be deleted

    .PARAMETER DryRun
        Performs Scan without deleting files

    .PARAMETER Type
        Specifies to check files CreationTime or LastWriteTime against Date Limit (Default = LastWriteTime)
    #>

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory, Position=0, ValueFromPipeline)]
        [ValidateScript({
            $_ | % {
                if(!(Test-Path $_ -Type Container -ErrorAction SilentlyContinue)) {
                    throw "Invalid FilePath: $_"
                } 
            };
            return $True
        })]
        [String[]] $FilePath,

        [Parameter(Position=1)]
        [ValidateScript({
            return $_ -gt 0
        })]
        [Int] $DayLimit = 30,

        [Parameter(Position=1)]
        [ValidateScript({
            return (Get-Date) -gt $_
        })]
        [Nullable[DateTime]] $Date = $null,
        
        [Parameter(Position=2)]
        [Validateset('CreationTime', 'LastWriteTime')]
        [String] $Type = 'LastWriteTime',

        [switch] $Confirm,

        [switch] $DryRun
    )

    Begin {
        # Variables
        $FilesFound = @()           # All files found past the date limit
        $DateLimit = if($Date){     # If files was created before the datelimit, an action will be performed
            $Date
        } else {
            (Get-Date).AddDays(-$DayLimit)
        } 
        Write-Verbose "Date Limit: $DateLimit"
    }
   
    Process {

        # Iterates through each filepath and find files that are past the date limit
        $FilePath | % {
            Push-Location $_
            Get-ChildItem $_ | %  {
                if($_.$Type -lt $DateLimit) {
                    
                    $FilesFound += $_       # Stores all the files that pass the date limit
    
                    # Determines if the action is to remove the file
                    if(!($DryRun)){
                        try {
                            Remove-Item $_ -Force -Confirm:$Confirm -Recurse
                        } catch {
                            Write-Error "Unable to remove: $_"
                        }
                    }
                }
            }
            Pop-Location
        }
    }

    End {
        return $FilesFound
    }
}
