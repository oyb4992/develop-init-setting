#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title 애플스토어 앱 검색
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ./appstore.png
# @raycast.argument1 { "type": "text", "placeholder": "어플명", "percentEncoded": true }

# Documentation:
# @raycast.description 앱스토어 앱 찾기
# @raycast.author 마니의블로그
# @raycast.authorURL https://hjm79.top

open "macappstore://ax.search.itunes.apple.com/WebObjects/MZSearch.woa/wa/search?q=$1"



