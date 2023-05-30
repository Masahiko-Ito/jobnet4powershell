#
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
. .\initJobnet.ps1 $profilepath
#--------------------------------------------------

echo "jobG.ps1"
sleep 5
psjn_sweepholdcount

#--------------------------------------------------
# 後続ジョブ無し
#--------------------------------------------------
