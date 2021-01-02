#Move files into a folder of when the photo was taken
Function Organize-Photos { 
  Param(
    [Parameter(Mandatory = $true)][string]$folder, 
    [string]$dirfilter
  )


  #loop through folders
  foreach ($sFolder in $folder) {

    #make dir path with filter
    $dirWithFilter = $sFolder + $dirfilter
    Write-Output "Reading $dirWithFilter"
   
    #loop through files in folder
    foreach ($File in Get-ChildItem -Path $dirWithFilter -Exclude "*.json*" -File) { 
 
      Write-Output($File.name)
      $data = & ./exiftool.exe $File.FullName -j -q -q
      #Write-Output($data)
      
      $obj = $data | ConvertFrom-Json
      #Write-Output($obj.DateTimeOriginal)
      #Write-Output($obj.CreateDate)
      
      $sDateTaken = ""
      if ($obj.CreateDate) { $sDateTaken = $obj.CreateDate }
      if ($obj.DateTimeOriginal) { $sDateTaken = $obj.DateTimeOriginal }
      
      if ($sDateTaken -ne "") {
        #figure out new folder name
        $aDateTaken = $sDateTaken.split(" ")
        $sNewFolderName = $aDateTaken[0] -replace ":","-"
        #Write-Output("From Metadata:" + $sNewFolderName)
      }

      #read google takeout json file
      if ($sDateTaken -eq "") {
        $jsonFile = $File.FullName + ".json"
        #Write-Output $jsonFile
        if (Test-Path $jsonFile) {
          $obj = (Get-Content $jsonFile | Out-String | ConvertFrom-Json)
          $dCreatedDate = (Get-Date 01.01.1970) + ([System.TimeSpan]::fromseconds($obj.photoTakenTime.timestamp))

          #write metadata
          & ./exiftool "-DateTimeOriginal=$(Get-Date $dCreatedDate -format "yyyy:MM:dd") 00:00:0" $File.FullName -q
          $sNewFolderName = (Get-Date $dCreatedDate -format "yyyy-MM-dd")
          #Write-Output("From JSON:" + $sNewFolderName)
        }
      }
      

      $des_path = $sFolder + $sNewFolderName
      #Write-Output($des_path)
      Move-File $File.FullName $des_path
            
    } #end foreach $file 
  } #end foreach $sfolder 
} #end Get-FileMetaData

#moves file into directory, creates if doesn't exist
Function Move-File {
  Param(
    [Parameter(Mandatory = $true)][string] $file,
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
  Write-Output("Moved " + $File)
}



$directory = "C:\pictures\Takeout\Google Photos\Photos from 2009\"
$dirfilter = "*"

#first pass, move everything that has tags
Organize-Photos $directory $dirfilter
