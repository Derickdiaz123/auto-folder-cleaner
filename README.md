# Auto-Folder-Cleaner
Powershell Module that contains functions to remove files before a specific day or specific number of days 

Examples:

```powershell
# Removes files that were not modified within the last 30 days
Remove-OldFiles -FilePath "C:\Users\User\Downloads" -Days 30 
```

```powershell
# Pipes Folders to check on files based on date created
Get-ChildItem -Directory | Remove-OldFiles -Date (Get-Date).AddDays(-30) -Type CreationTime
```

## Parameters
| Name | Description |
-------|--------------
|FilePath | List of valid filepaths|
|Day | Number of days before the current day (Default = 30)|
|Date | Date Time of the limit before deletion |
|Type | Specified to check either CreationTime or LastWriteTime (Default = LastWriteTime) |
|DryRun | Runs Command without deleting the files | 
|Confirm | Prompts User for confirmation before removing directories recursively |

