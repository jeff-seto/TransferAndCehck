# Transfer and Check

# Variables
$source = "C:\Folder1"
$destination = "C:\Folder2"
$log = "C:\Logs\archive.log"

# Edit for RegEx
$sourceRegEx = $source -replace "\\", "\\"
$destinationRegEx = $destination -replace "\\", "\\"

# Copy files to destination
robocopy /E /COPY:DAT /W:0 /R:1 $source $destination

# Check MD5 hash
$sourceHashTable = @{}
$destinationHashTable = @{}
$filesTable = @()

Get-ChildItem -File -Path $source -Recurse | foreach {
    $sourceFilePath = $_.FullName -replace $sourceRegEx, ""
    $sourceFileHash = Get-FileHash $_.FullName -Algorithm MD5
    $sourceHashTable[$sourceFilePath] = $sourceFileHash

    # Create file name Array
    $filesTable += $sourceFilePath
}

Get-ChildItem -File -Path $destination -Recurse | foreach {
    $destinationFilePath = $_.FullName -replace $destinationRegEx, ""
    $destinationFileHash = Get-FileHash $_.FullName -Algorithm MD5
    $destinationHashTable[$destinationFilePath] = $destinationFileHash
}

foreach ($file in $filesTable) {
    if (!$destinationHashTable[$file]) {
        Add-Content $log "$(Get-Date -f yyyy-dd-MM) $(Get-Date -f HH:mm:ss) - Missing file: $destination$file"
    } 
    elseif ($sourceHashTable[$file].Hash -ne $destinationHashTable[$file].Hash) {
        Add-Content $log "$(Get-Date -f yyyy-dd-MM) $(Get-Date -f HH:mm:ss) - Corrupt file: $destination$file"
    } 
    else {

        #Delete  Source and log
        Remove-Item $source$file
        Add-Content $log "$(Get-Date -f yyyy-dd-MM) $(Get-Date -f HH:mm:ss) - Deleted file: $source$file"
    }
}