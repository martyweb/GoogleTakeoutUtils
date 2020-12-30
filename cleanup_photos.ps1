#Move files into a folder of when the photo was taken
Function Organize-Photos 
{ 
 Param([string[]]$folder) 
 foreach($sFolder in $folder) 
  { 
   $a = 0 
   $objShell = New-Object -ComObject Shell.Application 
   $objFolder = $objShell.namespace($sFolder) 
 
   foreach ($File in $objFolder.items()) 
    {  
     $FileMetaData = New-Object PSOBJECT 
      for ($a ; $a  -le 266; $a++) 
       {  
         if($objFolder.getDetailsOf($File, $a)) 
           { 
             $hash += @{$($objFolder.getDetailsOf($objFolder.items, $a))  = 
                  $($objFolder.getDetailsOf($File, $a)) 
                  } 
            $FileMetaData | Add-Member $hash 
            
            if(($objFolder.getDetailsOf($objFolder.items, $a).ToString() -eq "Date taken") -or ($objFolder.getDetailsOf($objFolder.items, $a).ToString() -eq "Media created")){
                
                #figure out new folder name
                $sDateTaken = $objFolder.getDetailsOf($File, $a).ToString()
                $aDateTaken = $sDateTaken.split(" ")
                $aMonthDayYear = $aDateTaken[0].split(‘/’)
                $sNewFolderName = $aMonthDayYear[2] + "-" + ($aMonthDayYear[0].Trim() -replace '[^a-zA-Z0-9]', '').PadLeft(2,'0') + "-" + ($aMonthDayYear[1].Trim() -replace '[^a-zA-Z0-9]', '').PadLeft(2,'0')
                $des_path = $sFolder + $sNewFolderName
                

                Move-File( $File, $des_path)
                
            }
            $hash.clear()
            
           } #end if            
       } #end for  
     $a=0 
     #$FileMetaData 
    } #end foreach $file 
  } #end foreach $sfolder 
} #end Get-FileMetaData

Function Move-File
{
  Param([string[]]$file) 
  Param([string[]]$des_path) 
  #check if dest dir exists
  if (test-path $des_path){ 
    move-item $File.Path $des_path 
    } else {
    new-item -ItemType directory -Path $des_path #create directory
    move-item $File.Path $des_path 
    }
    Write-Output("Moved " + $File.Path)
}

#read google takeout json files to figure out created date
Function Cleanup-Photos
{
    Param([string[]]$folder) 
    foreach($sFolder in $folder) 
  {
    #$objShell = New-Object -ComObject Shell.Application 
    #$objFolder = $objShell.namespace($sFolder) 

    #-Recurse

  #find files in directory
   foreach ($File in Get-ChildItem -Path $sFolder -Exclude "*.json*" -File) 
    {
      Write-Output($File.Name)
      
      #check if json file exists
      if([System.IO.File]::Exists($File.Path + $File.FullName+".json")){
        $obj = Get-Content ($File.Path + $File.FullName+".json") | ConvertFrom-Json
        
        if($obj.creationTime){
          
          $dCreatedDate = (Get-Date 01.01.1970)+([System.TimeSpan]::fromseconds($obj.creationTime.timestamp))
          #Write-Output(Get-Date $dCreatedDate -format "yyyy-MM-dd")
          $des_path = $sFolder + (Get-Date $dCreatedDate -format "yyyy-MM-dd")
          Move-File( $File, $des_path)
          
          #TODO: set date time in file

        }
      }
    }
  }


}


$directory = "C:\Users\marty\OneDrive\Downloads\Takeout\Google Photos\Photos from 2009\*"
$filter = "*"

#first pass, move everything that has tags
#Organize-Photos($directory)

#cleanup
Cleanup-Photos($directory)

