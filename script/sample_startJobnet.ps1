#
# ジョブネット開始スクリプト
#
# sample_startjobnet.ps1 -+-> sample_jobA.ps1 -+-> sample_jobE.ps1 -+-> sample_jobG.ps1
#                         |                    |                    |
#                         +-> sample_jobB.ps1 -+                    |
#                         |                                         |
#                         +-> sample_jobC.ps1 -+-> sample_jobF.ps1 -+
#                         |                    |
#                         +-> sample_jobD.ps1 -+
#
#--------------------------------------------------
# 初期化処理
#
. ($PSScriptRoot + "\initJobnet.ps1") $null
#--------------------------------------------------

echo "startJobnet.ps1"

#--------------------------------------------------
# ホールドカウントの設定
#
psjn_setholdcount sample_jobA.ps1 1
psjn_setholdcount sample_jobB.ps1 1
psjn_setholdcount sample_jobC.ps1 1
psjn_setholdcount sample_jobD.ps1 1
psjn_setholdcount sample_jobE.ps1 2
psjn_setholdcount sample_jobF.ps1 2
psjn_setholdcount sample_jobG.ps1 2
#--------------------------------------------------

#--------------------------------------------------
# 最初に開始するジョブのリリース
#
$j1 = psjn_release sample_jobA.ps1
$j2 = psjn_release sample_jobB.ps1
$j3 = psjn_release sample_jobC.ps1
$j4 = psjn_release sample_jobD.ps1
#--------------------------------------------------

#--------------------------------------------------
# リリースしたジョブの終了を待つ
#
psjn_waitjob @($j1, $j2, $j3, $j4)
#--------------------------------------------------
