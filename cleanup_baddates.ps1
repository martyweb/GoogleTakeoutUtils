#Find pictures with bad dates ie. from the future and remove them

#Variables
param (
  [Parameter(Mandatory = $true)]$directory, 
  $dirfilter = "*",
  $dryrun = 1,
  $doit="NO",
  $recurisve=0)

#validate with user that they want to continue
Write-Output("Reading directory $directory with a filter of $dirfilter")
$doit = read-host -Prompt "Continue? type YES"
if($doit -ne "YES"){exit}


#Main program function
Function Organize-Photos { 
  Param(
    [Parameter(Mandatory = $true)][string]$basedirectory, 
    [string]$dirfilter
  )
  
  if($recurisve){
    Write-Output "Recursive"
    $folders = Get-ChildItem -Path $basedirectory -Directory
  }else{
    Write-Output "Not recursive"
    $folders = Get-Item -Path $basedirectory
  }
  Write-Output "Reading $folders"
  
  #loop through sub folders
  foreach ($sFolder in $folders) {

    #make dir path with filter
    $sFolderFullPath = $sFolder.FullName + "\"
    $dirWithFilter = $sFolderFullPath + $dirfilter
    Write-Output "Reading $dirWithFilter"
   
    #loop through files in folder
    foreach ($File in Get-ChildItem -Path $dirWithFilter -Exclude "*.json*" -File) { 
 
      Write-Output($File.FullName)

      #get metadata from file using exiftool
      $data = & ./exiftool.exe $File.FullName -j -q -q -overwrite_original
      $obj = $data | ConvertFrom-Json
      Write-Output($obj)

      #get date from exif output
      $sDateTaken = ""
      if ($obj.CreateDate) { 
        $sDateTaken = $obj.CreateDate
        $aDateTaken = $sDateTaken.split(" ")
        $sNewFolderNameCreateDate = $aDateTaken[0] -replace ":","-" 
      }
      if ($obj.DateTimeOriginal) { 
        $sDateTaken = $obj.DateTimeOriginal
        $aDateTaken = $sDateTaken.split(" ")
        $sNewFolderName = $aDateTaken[0] -replace ":","-"
      }
      if([string]$sNewFolderName -isnot [DateTime]){
        if([string]$sNewFolderNameCreateDate -as [DateTime]){
          $sNewFolderName=$sNewFolderNameCreateDate
        }else {
          $sNewFolderName=""
        }
      }
      
      #Write-Output($sNewFolderName)
      #exit
      

      if($sNewFolderName -eq ""){
        Write-Output("No new folder, not moved")
      }else{
        $des_path = $sFolderFullPath + $sNewFolderName
        #Write-Output($des_path)
        #exit
        if (!$dryrun) {
          Move-File $File.FullName $des_path
        }else{
          Write-Output("Dryrun, not moved to " + $des_path)
        }
        #exit
    
      }
      
            
    }
  }
}

#moves file into directory, creates if doesn't exist
Function Move-File {
  Param(
    [Parameter(Mandatory = $true)][string] $File,
    [Parameter(Mandatory = $true)][string] $des_path
  ) 
  #check if dest dir exists
  if (test-path $des_path) { 
    move-item $File $des_path 
  }
  else {
    new-item -ItemType directory -Path $des_path.Trim() #create directory
    move-item $File $des_path 
  }
  Write-Output("Moved " + $File + " to " + $des_path)
}


#run the program
Organize-Photos $directory $dirfilter
