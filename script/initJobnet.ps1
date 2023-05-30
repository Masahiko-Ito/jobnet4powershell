#
# Jobnet for Powershell
#
#--------------------------------------------------
#
# Global variable
#
if ($profile -eq $null -or $profile -eq ""){
	$global:PSJN_PROFILE = $args[0]
}else{
	$global:PSJN_PROFILE = $profile
}

if ($MyInvocation.MyCommand.path -eq $null){
	$global:PSJN_SCRIPTDIR = $pwd
}else{
	$global:PSJN_SCRIPTDIR = $PSSCriptRoot
}
$global:PSJN_HOLDCOUNT = (Split-Path $global:PSJN_SCRIPTDIR) + "\holdcount"
$global:PSJN_LOGDIR = (Split-Path $global:PSJN_SCRIPTDIR) + "\log"

#--------------------------------------------------
#
# Usage: psjn_setholdcount scriptname holdcount
#
function psjn_setholdcount {
	$scriptname = $args[0]
	$holdcount = $args[1]
	echo $holdcount | out-file -encoding UTF8 $global:PSJN_HOLDCOUNT\$scriptname
}

#--------------------------------------------------
#
# Usage: psjn_release scriptname
# Return: job object
#
function psjn_release {
	$scriptname = $args[0]
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
function psjn_waitjob {
	foreach ($i in $args[0]){
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
function psjn_sweepholdcount {
	if ($global:PSJN_HOLDCOUNT -ne $null -and $global:PSJN_HOLDCOUNT -ne ""){
		rm $global:PSJN_HOLDCOUNT\*
	}
}