#Cleanup synology cloud drive "conflict" files
#will fine all conflicted files, choose the bigger file, delete old one, and rename conflicted file to orig file
param (
  [Parameter(Mandatory = $true)]$directory, 
  $filefilter = "*_conflict*",
  $dryrun = 0,
  $doit="NO",
  $separator="_SPEEDY")

#validate with user that they want to continue
Write-Output("Reading directory $directory with a file filter of $filefilter")
$files = Get-ChildItem -Path $directory -Filter $filefilter -Recurse
Write-output("Found "+$files.Length+" files")
$doit = read-host -Prompt "Continue? type YES"
if($doit -ne "YES"){exit}

$nameArry={}
foreach($file in $files){
    
    $nameArry=$file -Split $separator
    $extension=[System.IO.Path]::GetExtension($file)
    
    $origFile=(Split-Path -Path $file.FullName)+"\"+$nameArry[0]+[string]$extension
    #Write-Output($origFile)

    #make sure orig file exists
    if([System.IO.File]::Exists($origFile)){
        #if conflicted file is bigger than orig file
        if(((Get-Item $file.FullName).length/1MB) -gt ((Get-Item $origFile).length/1MB)){
        
            if (!$dryrun) {
                Remove-Item -Path $origFile
                Rename-Item -Path $file.FullName -NewName $origFile
              }else{
                Write-Output("Dryrun, no action")
              }
            Write-Output("Renamed " + $file.FullName + " to " + $origFile)
            #exit

        }else{
            Write-Output("WARNING: Conflicted file " + $file.FullName + " not larger than " + $origFile)
        }
    }
}