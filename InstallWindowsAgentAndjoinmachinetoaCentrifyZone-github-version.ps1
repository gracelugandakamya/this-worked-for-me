# This script will install the Centrify Agent and also run the dzjoin command on the remote Windows machines and join the machines to a Centrify Zone in access manager.

# This is Centrify agent package you want to copy to the servers in the $computer variable
$source = "C:\Windows\Temp\Centrify Agent for Windows64.exe"


<#This variable is the list of target machines where we want the agent installed and machines joined to the Centrify zone in active directory.
 This file contains the list of remote servers you want to copy the Centrify agent package to#>
$computers = Get-content '\\machine1.domain.net\C$\Windows\Temp\targetmachines2.txt'


# The destination location you want the Centrify agent package to be copied to
$destination = "C$\Windows\Temp\"

#This variable gets the credential from the user running the script
$credential = Get-Credential -Credential DOMAIN\DomainUserName

#This step enables the Enable-WSManCredSSP on the local machine.
Enable-WSManCredSSP -Role Client -DelegateComputer *.DOMAIN.NET -Force




#This next step enables use of the delgated credentials on the remote target servers where we want to install the Centrify agent.
Invoke-Command -ComputerName $computers -ScriptBlock {Enable-WSManCredSSP -role server -Force} -Credential $credential






#The command below pulls all the variables above and performs the file copy
foreach ($computer in $computers) 
{ if (Test-Path -Path \\$computer\$destination) 
{ Copy-Item $source -Destination "\\$computer\$destination" -Recurse -Verbose} 
}



#Once the installer executable is copied, proceed to install it silently
Invoke-Command -ComputerName $computers -ScriptBlock {Start-Process 'C:\Windows\Temp\Centrify Agent for Windows64.exe' -ArgumentList "q" -Wait} -Verbose


<#After the agent is installed clean up the agent package off of the machine
The command below pulls all the variables above and performs the file removal on the target machine#>
foreach ($computer in $computers) 
{ if (Test-Path -Path \\$computer\$destination) 
{ Remove-Item -Path "\\$computer\$destination\Centrify Agent for Windows64.exe" -Verbose} 
}



#This next variable sets a PowerShell session on those target remote machines
$session = New-PSSession -ComputerName $computers -Credential $credential -Authentication Credssp -Verbose

#This step closes the current PSSEssion.
Remove-PSSession -ComputerName $computers  -Verbose




#This tells the script to wait for 60 seconds as the Centrify agent finishes installing the AGent and laying down libraries.
Start-Sleep -seconds 600 -Verbose


#This variable gets the credential from the user running the script
$credential2 = Get-Credential -Credential DOMAIN\DomainUserName -verbose

#This step creates a new PSSEssion
$session2 = New-PSSession -ComputerName $computers -Credential $credential2 -Authentication Credssp -Verbose




#This is to run the dzjoin command on the target remote machines so the machines can join the Centrify zone in active directory.
Invoke-Command -Session $session2  -ScriptBlock {dzjoin /r yes /z ZoneName} -Verbose 







