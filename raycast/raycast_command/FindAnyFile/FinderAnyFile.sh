#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title FinderAnyFile
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ./FinderAnyFile.png
# @raycast.argument1 { "type": "text", "placeholder": "파일", "percentEncoded": true }

# Documentation:
# @raycast.description 파일 찾기
# @raycast.author 마니의블로그
# @raycast.authorURL https://hjm79.top

open "fafapp://find?inp=$1"
