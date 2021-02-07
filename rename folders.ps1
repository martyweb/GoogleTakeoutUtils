#rename folders that have a space to a dash
param (
  [Parameter(Mandatory = $true)]$directory, 
  $dryrun = 0)

Write-Output("Reading directory $directory")

$folders = Get-ChildItem -Path $directory -Directory -Recurse

foreach ($sFolder in $folders) {
    #Write-Output $sFolder.Name
    if([string]$sFolder.Name -like "* *"){
        $array = [string]$sFolder.Name.Trim() -split " "
        $newname=$sFolder -replace " ", "-"

        #make sure folder name looks like a date
        if($array.Length -eq 3){
            if($dryrun){
                Write-Output("Dryrun, no action on " + $newname)
            }else{
                Write-Output($sFolder.Name + " to " + $newname)
                Rename-Item -Path $sFolder.FullName $newname
                #exit
            }
        }
    }
}