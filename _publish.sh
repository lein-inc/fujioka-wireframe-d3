#!/bin/bash
# 藤岡 D-3 ワイヤー（複製版）の再公開
#   1) work/ の design-*-d3.html を staticrypt で暗号化
#   2) repo-d3 へ配置 → commit → push
# 使い方: ./_publish.sh <github_token> "コミットメッセージ"
set -e
BASE=/Users/apple/site/fujioka
SALT=9f3c1a7e5b2d4c6a8e0f1b3d5a7c9e21
PW=fujioka
TOKEN="$1"; MSG="${2:-ワイヤー更新}"
[ -z "$TOKEN" ] && { echo "usage: ./_publish.sh <token> \"msg\""; exit 1; }

# 最新のデザイン案をビルド
python3 "$BASE/work/_d3/build.py"

TMP=$(mktemp -d)
cp "$BASE"/work/design-*-d3.html "$TMP"/
# 一覧ページ（WFのTOP）。平文の原本は work/_d3/index.html
cp "$BASE/work/_d3/index.html" "$TMP"/index.html
"$BASE/_tools/node_modules/.bin/staticrypt" "$TMP"/*.html \
  -p "$PW" --salt "$SALT" --remember 30 -d "$TMP/enc" --short >/dev/null
cp "$TMP"/enc/*.html "$BASE/repo-d3/"
rm -rf "$TMP"

# 画像は暗号化対象外。work/img に増減があれば同期する（例: logo-alpha.png）
rsync -a --delete "$BASE/work/img/" "$BASE/repo-d3/img/"

cd "$BASE/repo-d3"
git add -A
git -c user.name=seki -c user.email=naofumi@le-in.net commit -m "$MSG" || { echo "変更なし"; exit 0; }
git push "https://${TOKEN}@github.com/lein-inc/fujioka-wireframe-d3.git" main
echo "公開: https://lein-inc.github.io/fujioka-wireframe-d3/"
