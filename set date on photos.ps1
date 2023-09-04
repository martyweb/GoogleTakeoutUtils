#loop through folder and set the year on pictures to match folder

#Variables
param (
  [Parameter(Mandatory = $true)]$directory, 
  $dirfilter = "*",
  $dryrun = 0,
  $recurisve=0)

#validate with user that they want to continue
Write-Output("Reading directory $directory with a filter of $dirfilter")

#Main program function
Function Organize-Photos { 
  Param(
    [Parameter(Mandatory = $true)][string]$basedirectory, 
    [string]$dirfilter
  )
  
  if($recurisve){
    Write-Output "Recursive"
    $folders = Get-ChildItem -Path $basedirectory -Directory -Filter  "*"
  }else{
    Write-Output "Not recursive"
    $folders = Get-Item -Path $basedirectory
  }
  #Write-Output "Reading $folders"
  
  #loop through sub folders
  foreach ($sFolder in $folders) {

    $folderYear = ($sFolder.Name).substring(0,4)
    $folderDesc = $sFolder.Name
    #Write-Output($folderDesc)
    #exit
    
    #make dir path with filter
    $sFolderFullPath = $sFolder.FullName + "\"
    $dirWithFilter = $sFolderFullPath + $dirfilter
    Write-Output "Reading $dirWithFilter"
   
    #loop through files in folder
    foreach ($File in Get-ChildItem -Path $dirWithFilter -Exclude "*.json*" -File) { 
 
      Write-Output("Reading " + $File.FullName)

      #get metadata from file using exiftool
      $data = & ./exiftool.exe $File.FullName -j -q -q -overwrite_original
      $obj = $data | ConvertFrom-Json
      #Write-Output("Original datetime: " + $obj.DateTimeOriginal)
      #Write-Output($obj)

      #get pic year from metadata
      if ($obj.DateTimeOriginal){
        $picYear = $obj.DateTimeOriginal.substring(0,4)
      }else{
        $picYear=$folderYear
      }
      $dCreatedDateTime = $folderYear + "-01-01 00:00:00"
      $dCreatedDate = $folderYear + "-01-01"

      #set DateCreated
      if($obj.DateCreated){
        #get year
        #$DateCreatedobj = [DateTime]$obj.DateCreated
        $DateCreatedYear = $obj.DateCreated.substring(0,4)
        #Write-Output($DateCreatedYear + $folderYear + "-------")
        #does it match folder
        if($DateCreatedYear -ne $folderYear){
          #dry run test
          if (!$dryrun) {
            & ./exiftool "-overwrite_original" "-Description=`"$folderDesc`"" "-CreateDate=`"$dCreatedDateTime`"" "-DateCreated=`"$dCreatedDate`"" "-YearCreated=`"$folderYear`"" $File.FullName -q
            Write-Output($DateCreatedYear)
            Write-Output("Writing DateCreated " + $dCreatedDate + " to file " + $File.FullName)
          }else{
            Write-Output("DRYRUN: Would have Written DateCreated " + $dCreatedDate + " to file " + $File.FullName)
          }
        }
      }

      #set date if no in exif data or mismatch year
      $sDateTaken = ""
      if ((-not $obj.DateTimeOriginal) -or ($folderYear -ne $picYear)) { 

        if ($folderYear -ne $picYear -and $picYear -ne "") { 
          $dCreatedDateTime = $folderYear + $obj.DateTimeOriginal.substring(4, 6).replace(":","-")
          Write-Output("Year mismatch: " + $obj.DateTimeOriginal + " should be: " + $dCreatedDateTime)
          #Write-Output("-------------")
          
        }else{
          Write-Output("No datetime set")
        }

        #write metadata
        
        #Write-Output($dCreatedDate)
        #-overwrite_original
        #Write-Output("-Description=`"$folderDesc`" -DateTimeOriginal=`"$(Get-Date $dCreatedDate -format "yyyy:MM:dd") 00:00:00 `"")
        #exit
        if (!$dryrun) {
          & ./exiftool "-overwrite_original" "-Description=`"$folderDesc`"" "-DateTimeOriginal=$(Get-Date $dCreatedDateTime -format "yyyy:MM:dd") 00:00:00" $File.FullName -q
          Write-Output("Writing DateTimeOriginal " + $dCreatedDateTime + " to file " + $File.FullName)
        }else{
          Write-Output("DRYRUN: Would have Written DateTimeOriginal " + $dCreatedDateTime + " to file " + $File.FullName)
        }
        
        #exit
      }else{
        #Write-Output("Did not update date: " + $obj.DateTimeOriginal)
      }
             
    }
  }
}

#run the program
Organize-Photos $directory $dirfilter
