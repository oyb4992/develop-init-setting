#!/bin/bash

# iTerm2 설정 디렉토리 생성
mkdir -p ~/Library/Application\ Support/iTerm2/DynamicProfiles/

# iTerm2 설정 파일 복사
cp ./config/terminals/iterm2/com.googlecode.iterm2.plist ~/Library/Application\ Support/iTerm2/DynamicProfiles/

# 기본 셸을 zsh로 변경
chsh -s /bin/zsh

echo "iTerm2 설정이 완료되었습니다."