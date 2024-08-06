
## To fix "cannot be loaded because running scripts is disabled on this system" (run: 'get-executionpolicy' returns: Restricted) -->
## set-executionpolicy remotesigned

# Run following to bypass "not digitally signed" issue (fixes per session only)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

$dryRun = $false;
$packages = 'packages.txt' #'packages-test.txt'

write-host "`n---+++ START powershell script to install packages, using chocolately (`chocolatey.org`) +++---`n"

if($dryRun) {
  write-host "... DRY RUN ONLY ..."
}

$chocoIsInstalled = Test-Path -Path "$env:ProgramData\Chocolatey" # Get-Command choco.exe -ErrorAction SilentlyContinue

if ($chocoIsInstalled) {
  write-host "`n--> Chocolately is already installed ---`n"
}
else {
  write-host "`n--> Chocolately was not installed, let's install it! ---`n"

  if($dryRun) {
    write-host "This is a DRY RUN, we will not take this action"
  }
  else {
    Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
  }
}

$array = (gc $packages) -notmatch '^\s*$' -notmatch '^#' | ? {$_.trim() -ne "" }

foreach($item in $array)
{
  write-host "`n* --> Next package install: '${item}'`n"
  if($dryRun) {
    write-host "This is a DRY RUN, we will not take this action"
  }
  else {
    choco install $item -y
  }
} 

write-host "`n---+++ FINISH install script +++---`n"
