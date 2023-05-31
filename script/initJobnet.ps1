#
# Jobnet for Powershell
#
#--------------------------------------------------
#
# Usage psjn_initialize profilepath
#
function psjn_initialize($profilepath){
	if ($args[0] -eq "-h" -or $args[0] -eq "--help"){
		write-output "Usage: psjn_initialize profilepath"
		write-output "Initialize jobnet."
		write-output ""
		write-output "ex1 for script to start jobnet."
		write-output '  . ($PSScriptRoot + "\initJobnet.ps1")'
		write-output '  psjn_initialize $null'
		write-output ""
		write-output "ex2 for script of jobnet."
		write-output "  param ("
		write-output '      $profilepath,'
		write-output '      $currentdir'
		write-output "  )"
		write-output '  . $profilepath'
		write-output '  set-location $currentdir'
		write-output "  . .\initJobnet.ps1"
		write-output '  psjn_initialize $profilepath'
		write-output ""
		return
	}
	if ($profile -eq $null -or $profile -eq ""){
		$global:PSJN_PROFILE = $profilepath
	}else{
		$global:PSJN_PROFILE = $profile
	}

	if ($PSSCriptRoot -eq $null){
		$global:PSJN_SCRIPTDIR = $pwd
	}else{
		$global:PSJN_SCRIPTDIR = $PSSCriptRoot
	}
	$global:PSJN_HOLDCOUNT = (Split-Path $global:PSJN_SCRIPTDIR) + "\holdcount"
	$global:PSJN_LOGDIR = (Split-Path $global:PSJN_SCRIPTDIR) + "\log"
}

#--------------------------------------------------
#
# Usage: psjn_setholdcount scriptname holdcount
#
function psjn_setholdcount($scriptname, $xholdcount){
	if ($args[0] -eq "-h" -or $args[0] -eq "--help"){
		write-output "Usage: psjn_setholdcount scriptname holdcount"
		write-output "Set holdcount."
		write-output ""
		write-output "ex."
		write-output "  psjn_setholdcount sample_jobA.ps1 1"
		write-output ""
		return
	}
	echo $xholdcount | out-file -encoding UTF8 $global:PSJN_HOLDCOUNT\$scriptname
}

#--------------------------------------------------
#
# Usage: psjn_release scriptname
# Return: job object
#
function psjn_release($scriptname){
	if ($args[0] -eq "-h" -or $args[0] -eq "--help"){
		write-output "Usage: psjn_release scriptname"
		write-output "Release holed script(holdcount--)."
		write-output ""
		write-output "ex."
		write-output '  $j1 = psjn_release sample_jobA.ps1'
		write-output '  $j2 = psjn_release sample_jobB.ps1'
		write-output '  psjn_waitjob @($j1, $j2)'
		write-output ""
		return
	}
	$job = $null

	$mutex = New-Object System.Threading.Mutex($false, ("Global\" + $scriptname))
	$ret = $mutex.WaitOne()

	$holdcount = get-content $global:PSJN_HOLDCOUNT\$scriptname
	$holdcount = [int]$holdcount
	$holdcount--
	echo $holdcount | out-file -encoding UTF8 $global:PSJN_HOLDCOUNT\$scriptname
	if ($holdcount -eq 0){
		if ($profile -eq $null -or $profile -eq ""){
			$profile = $profilepath
		}
		$job = start-job -name $scriptname -filepath $global:PSJN_SCRIPTDIR\$scriptname -ArgumentList $global:PSJN_PROFILE,$global:PSJN_SCRIPTDIR
	}

	$mutex.ReleaseMutex()
	$mutex.Close()

	return $job
}

#--------------------------------------------------
#
# Usage: psjn_waitjob @(job-object, ... )
#
function psjn_waitjob($jobs){
	if ($args[0] -eq "-h" -or $args[0] -eq "--help"){
		write-output "Usage: psjn_waitjob @(job-object, ... )"
		write-output "Wait terminate of released job."
		write-output ""
		write-output "ex."
		write-output '  $j1 = psjn_release sample_jobA.ps1'
		write-output '  $j2 = psjn_release sample_jobB.ps1'
		write-output '  psjn_waitjob @($j1, $j2)'
		write-output ""
		return
	}
	foreach ($i in $jobs){
		if ($i -ne $null){
			$job = wait-job -id $i.id
			$datetime = get-date -uformat "%Y%m%d%H%M%S"
			$random = get-random
			receive-job -id $job.id -autoremove -wait | out-file -append -encoding UTF8 ($global:PSJN_LOGDIR + "\" + $job.name + "." + $datetime + "." + $random + ".log")
		}
	}
}

#--------------------------------------------------
#
# Usage: psjn_sweepholdcount
#
function psjn_sweepholdcount{
	if ($args[0] -eq "-h" -or $args[0] -eq "--help"){
		write-output "Usage: psjn_sweepholdcount"
		write-output "Sweep holdcount."
		write-output ""
		return
	}
	if ($global:PSJN_HOLDCOUNT -ne $null -and $global:PSJN_HOLDCOUNT -ne ""){
		rm $global:PSJN_HOLDCOUNT\*
	}
}