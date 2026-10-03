#!/bin/zsh
# Morisawa / Adobe LiveType のフォント実体に対するシンボリックリンクを
# macOS のユーザーフォントディレクトリ ~/Library/Fonts 直下に作成します。
#
# 使い方:
#   zsh ~/create_font_symlinks.sh
#
# 作成されるリンク例:
#   ~/Library/Fonts/MorisawaCache_001.ttf
#   ~/Library/Fonts/AdobeLiveType_001.otf

set -euo pipefail

FONT_DIR="$HOME/Library/Fonts"
MORISAWA_SRC="/Library/Application Support/Morisawa/.Cache"
ADOBE_SRC="$HOME/Library/Application Support/Adobe/CoreSync/plugins/livetype"

log() {
  printf '%s\n' "$*"
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
}

create_font_links() {
  local prefix="$1"
  local srcdir="$2"
  local count=0
  local src ext link

  if [[ ! -d "$srcdir" ]]; then
    warn "ソースディレクトリがありません: $srcdir"
    return 0
  fi

  while IFS= read -r -d '' src; do
    count=$((count + 1))
    ext="${src##*.}"
    link=$(printf '%s/%s_%03d.%s' "$FONT_DIR" "$prefix" "$count" "$ext")
    ln -s "$src" "$link"
  done < <(
    find "$srcdir" -type f \( \
      -iname '*.otf' -o \
      -iname '*.ttf' -o \
      -iname '*.ttc' -o \
      -iname '*.dfont' \
    \) -print0 | sort -z
  )

  log "$prefix: ${count} 個のリンクを作成"
}

refresh_font_cache() {
  if ! command -v fc-cache >/dev/null 2>&1; then
    warn "fc-cache が見つかりません。アプリ起動時の自動スキャンに任せます。"
    return 0
  fi

  log "fontconfig キャッシュを更新中..."

  fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || warn "通常の fontconfig キャッシュ更新に失敗しました"

  find /Applications -path '*/Contents/Resources/etc/fonts/fonts.conf' -type f -print0 2>/dev/null | while IFS= read -r -d '' conf; do
    local confdir
    confdir="${conf:h}"
    FONTCONFIG_FILE="$conf" FONTCONFIG_PATH="$confdir" fc-cache -f "$FONT_DIR" >/dev/null 2>&1 || true
  done
}

show_detected_fonts() {
  if ! command -v fc-list >/dev/null 2>&1; then
    return 0
  fi

  local detected
  detected=$(fc-list | grep -E 'MorisawaCache_|AdobeLiveType_' | wc -l | tr -d ' ')

  log ""
  log "通常fontconfigで検出されたフォントエントリ数: $detected"
  fc-list | grep -E 'MorisawaCache_|AdobeLiveType_' | sed -n '1,10p' || true
}

main() {
  log "フォントリンク作成を開始します。"
  mkdir -p "$FONT_DIR"

  if [[ -L "$FONT_DIR/Morisawa.Cache" ]]; then
    rm "$FONT_DIR/Morisawa.Cache"
    log "削除: $FONT_DIR/Morisawa.Cache"
  fi

  if [[ -L "$FONT_DIR/Adobe.LiveType" ]]; then
    rm "$FONT_DIR/Adobe.LiveType"
    log "削除: $FONT_DIR/Adobe.LiveType"
  fi

  find "$FONT_DIR" -maxdepth 1 -type l \( \
    -name 'MorisawaCache_*' -o \
    -name 'AdobeLiveType_*' \
  \) -delete

  create_font_links "MorisawaCache" "$MORISAWA_SRC"
  create_font_links "AdobeLiveType" "$ADOBE_SRC"

  local total
  total=$(find "$FONT_DIR" -maxdepth 1 -type l \( \
    -name 'MorisawaCache_*' -o \
    -name 'AdobeLiveType_*' \
  \) | wc -l | tr -d ' ')

  log "合計: ${total} 個のシンボリックリンクを作成"

  refresh_font_cache
  show_detected_fonts

  log ""
  log "完了しました。フォントを使うアプリを完全に終了してから再起動してください。"
  log "アプリ上では 'Morisawa' や 'Adobe' ではなく、例: 'BIZ UD', 'UD デジタル', 'Kiro', 'TK-takumi' などのフォント名で表示されます。"
}

main "$@"
