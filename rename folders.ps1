#rename folders that have a space to a dash
param (
  [Parameter(Mandatory = $true)]$directory, 
  $dryrun = 1)

Write-Output("Reading directory $directory")

$folders = Get-ChildItem -Path $directory -Directory -Recurse

foreach ($sFolder in $folders) {
    #Write-Output $sFolder.Name.Length
    if(([string]$sFolder.Name -like "* *") -or ([string]$sFolder.Name.Length -ne 10)){
        #Write-Output $sFolder.Name
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

        $array = [string]$sFolder.Name.Trim() -split " "
        $bad=0
        $year=$array[0]
        $month=$array[1]
        $day=$array[2]
        if($year.Length -ne 4){
            Write-Output "bad year"
            $bad=1
        }
        if($month.Length -ne 2){
            Write-Output "bad month"
            $month=$month.PadLeft(2,"0")
            $bad=1
        }
        if($day.Length -ne 2){
            Write-Output "bad day"
            $day=$day.PadLeft(2,"0")
            $bad=1
        }
        if($bad -eq 1){
            $newname = "$year-$month-$day"
            Write-Output($sFolder.Name + " to " + $newname)
            #Rename-Item -Path $sFolder.FullName $newname
            #exit
        }
    }
}