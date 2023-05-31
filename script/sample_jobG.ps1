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

echo "jobG.ps1"
sleep 5

#--------------------------------------------------
# 後続ジョブ無し
#--------------------------------------------------
