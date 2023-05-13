#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title 미리 알림 등록(todo)
# @raycast.mode compact

# Optional parameters:
# @raycast.icon ./reminder.png
# @raycast.argument1 { "type": "text", "placeholder": "일정 등록" }

# Documentation:
# @raycast.description 미리 알림 등록
# @raycast.author 마니의블로그
# @raycast.authorURL https://hjm79.top

shortcuts run "할일등록용" <<< "$1"

