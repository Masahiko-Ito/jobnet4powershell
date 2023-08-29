# Jobnet for Powershell

Jobnet for Powershell は、複数のPowershellスクリプトによるジョブネットを実現
します(メインフレームのバッチ処理の世界からPowershellの世界にやって来られた
方々のお役に立てれば幸いです)

## psjn_setholdcount - スクリプトのホールドカウント(保留数)を設定する
```
Usage: psjn_setholdcount script_name hold_count
ex.
  psjn_setholdcount sample_jobA.ps1 1
```

## psjn_release - スクリプトのホールドカウント(保留数)を1減算する
ホールドカウントが0になったタイミングで指定のスクリプトが実行され、その場合
はジョブオブジェクトが返される。実行されなかった場合は$nullが返される。
```
Usage: psjn_release script_name
ex.
  $jobobject = psjn_release sample_jobA.ps1
```

## psjn_waitjob - 指定したジョブオブジェクトの終了を待ち、実行ログを記録する
指定したジョブオブジェクトの内、$nullは無視する。
```
Usage: psjn_waitjob @(jobobject, ...)
ex.
  psjn_waitjob @($jobobject)
```

## psjn_sweepholdcount - 「holdcount」フォルダを掃除する
```
Usage: psjn_sweepholdcount
```

## 準備作業
ジョブネット用のフォルダを作成し、その下に「holdcount」「log」「script」の
3フォルダを作成する。

「script」の下に「initjobnet.ps1」をコピーする。

ジョブネットを構成するスクリプトを「script」の下に作成していく。

## ジョブネット開始スクリプト作成のルール
スクリプトの先頭は以下の行で始めること。
```
. ($PSScriptRoot + "\initJobnet.ps1")
psjn_initialize $null
```

ジョブネットを構成するスクリプトのホールドカウント(保留数)を設定する。
例えば以下のようなジョブネットの場合
```
jobA.ps1 -+->jobC.ps1
          |
jobB.ps1 -+
```

このようにホールドカウントを設定し
```
psjn_setholdcount jobA.ps1 1
psjn_setholdcount jobB.ps1 1
psjn_setholdcount jobC.ps1 2
```

最初に開始するスクリプトに対して、以下のようにリリースを行い
```
$j1 = psjn_release jobA.ps1
$j2 = psjn_release jobB.ps1
```

以下のように、リリースしたスクリプトの終了を待ち受けること。
```
psjn_waitjob @($j1, $j2)
```

## ジョブネットを構成するスクリプト作成のルール
スクリプトの先頭は以下の行で始めること。
```
param (
    $profilepath,
    $currentdir
)
. $profilepath
set-location $currentdir
. .\initJobnet.ps1
psjn_initialize $profilepath
```
以降のカレントディレクトリは「script」になる。

## スクリプトのリリース(保留解除)
例えば、「jobA.ps1」の後続として「jobB.ps1」「jobC.ps1」を並行して実行する
場合「jobA.ps1」の最後に
```
$j1 = psjn_release jobB.ps1
$j2 = psjn_release jobC.ps1
psjn_waitjob @($j1, $j2)
```
と記述する。

リリース時にホールドカウントが0になると実際に実行され、「psjn_waitjob」が終
了したタイミングで「log」配下に実行ログが「スクリプト名.yyyymmddhhmmss.乱数.log」
のファイル名で記録される。

## サンプルスクリプト
以下のジョブネットを構成する。
```
sample_startjobnet.ps1 -+-> sample_jobA.ps1 -+-> sample_jobE.ps1 -+-> sample_jobG.ps1
                        |                    |                    |
                        +-> sample_jobB.ps1 -+                    |
                        |                                         |
                        +-> sample_jobC.ps1 -+-> sample_jobF.ps1 -+
                        |                    |
                        +-> sample_jobD.ps1 -+
```
各々のスクリプト(A～G)は5秒程度実行にかかる(sleep 5)。直列に実行すれば35秒
(7*5秒)程度かかるが、上記のようなジョブネットが組めるとすると、(理想的には)
15秒程度で完了する。実際には多少のオーバヘッドがあるので、20秒程度で完了す
る。

## その他
JP1いらない
