param (
  [Parameter(Mandatory = $true)]$directory, 
  $filefilter = "*_conflict*",
  $dryrun = 0)

$directory="\\data.martyweb.com\onedrive_karen\Pictures"

Write-Output("Reading directory $directory")

#$folders = Get-ChildItem -Path $directory -Directory
$folders = Get-ChildItem -Directory -Recurse $directory | Where-Object { $_.GetFileSystemInfos().Count -eq 0 }
#$folders = (gci $directory -recurse -Directory | ?{(gci $_.Fullname -force).count -eq 0} | select -expand FullName)

foreach ($sFolder in $folders) {
    if($dryrun){
      Write-output("Dryrun, no action on " + $sFolder.FullName)
    }else{
      Write-Output("Removing " + $sFolder.FullName)
      Remove-Item -Path $sFolder.FullName
    }

}