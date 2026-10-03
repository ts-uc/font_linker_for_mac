# macOS フォントリンク作成スクリプト

Morisawa および Adobe LiveType のフォントファイルを、ユーザーのフォントディレクトリ（`~/Library/Fonts`）にシンボリックリンクとして登録する zsh スクリプトです。フォントファイル自体はコピー・変更せず、元のファイルを参照するリンクを作成します。

## 対象のフォント

スクリプトは次の場所を検索し、`.otf`、`.ttf`、`.ttc`、`.dfont` ファイルを対象にします。

- Morisawa: `/Library/Application Support/Morisawa/.Cache`
- Adobe LiveType: `~/Library/Application Support/Adobe/CoreSync/plugins/livetype`

ソースディレクトリが見つからない場合は警告を表示し、そのディレクトリをスキップします。

## 実行方法

macOS のターミナルで、プロジェクトのディレクトリから実行します。

```sh
zsh ./font_linker_for_mac.sh
```

必要に応じて実行権限を付けて、直接実行することもできます。

```sh
chmod +x ./font_linker_for_mac.sh
./font_linker_for_mac.sh
```

## スクリプトの動作

1. `~/Library/Fonts` がなければ作成します。
2. このツールの接頭語 `FontLinker_` 付きのリンクを削除して作り直します。旧形式の `MorisawaCache_*` および `AdobeLiveType_*` のリンクも移行時に削除します。また、`Morisawa.Cache` と `Adobe.LiveType` がシンボリックリンクの場合も削除します。
3. 見つかったフォントごとに、たとえば `FontLinker_MorisawaCache_001.ttf` や `FontLinker_AdobeLiveType_001.otf` の名前でシンボリックリンクを作成します。
4. `fc-cache` が利用できる場合はフォントキャッシュの更新を試み、`fc-list` が利用できる場合は検出結果を表示します。

## 注意事項

- 作成されるリンクには、このツールのものと判別できる接頭語 `FontLinker_` が付きます。実行のたびに `FontLinker_MorisawaCache_*` と `FontLinker_AdobeLiveType_*` のリンクを削除して作り直します。旧形式のリンクも移行のため削除するので、これらの名前を別用途で使わないでください。
- 元のフォントファイルや、それ以外のファイルは削除しません。
- フォントを利用するアプリは、スクリプト実行後に完全に終了してから再起動してください。
- アプリ上ではリンク名ではなく、フォントファイルに設定されたフォント名で表示されます。表示名はフォントによって異なります。
- `fc-cache` と `fc-list` は任意です。インストールされていない場合でもリンク作成は行われます。
