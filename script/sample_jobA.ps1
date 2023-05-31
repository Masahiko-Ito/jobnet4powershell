﻿#
# ジョブネットを構成するジョブスクリプト
#
#--------------------------------------------------
# 初期化処理
#
param (
	$profilepath,
	$currentdir
)
. $profilepath
set-location $currentdir
. .\initJobnet.ps1
psjn_initialize $profilepath
#--------------------------------------------------

echo "jobA.ps1"
sleep 5

#--------------------------------------------------
# 後続ジョブのリリース
#
$j1 = psjn_release sample_jobE.ps1
#--------------------------------------------------

#--------------------------------------------------
# リリースしたジョブの終了を待つ
#
psjn_waitjob @($j1)
#--------------------------------------------------
