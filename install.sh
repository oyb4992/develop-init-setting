# !/bin/bash

# Homebrew 설치 여부 확인
if ! which brew
then
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 스크립트 내에서 일부 sudo 권한이 필요한 명령을 수행하기 위해 root 패스워드를 입력
# sudo 권한이 필요한 이유 : cask로 설치한 애플리케이션을 바로 실행하기 위해 다운로드 된 파일에 대한 격리 속성 제거 작업
read -r -s -p "[sudo] sudo password for $(whoami):" pass

# configure zsh
chmod 755 ./zsh/install.sh
./zsh/install.sh

# copy iterm2 configuration
chmod 755 ./iterm2/install.sh
./iterm2/install.sh

# copy karabiner configuration
chmod 755 ./karabiner/install.sh
./karabiner/install.sh

# copy hoemrow.app
chmod 755 ./homerow/install.sh
./homerow/install.sh

# install font
cp -a ./fonts/. ~/Library/Fonts

# zshrc 설정 적용
source ~/.zshrc

# BrewFile 실행 명령어
brew bundle --file=./Brewfile

# cask로 다운로드시 웹에서 다운로드한 것과 동일하기 때문에 실행을 하면 Security 문제로 실행되지 않음
# cask로 설치한 애플리케이션을 바로 실행하기 위해 다운로드 된 파일에 대한 격리 속성 제거 작업 명령어
sudo xattr -dr com.apple.quarantine /Applications/AppCleaner
sudo xattr -dr com.apple.quarantine /Applications/BetterTouchTool
sudo xattr -dr com.apple.quarantine /Applications/CheatSheet
sudo xattr -dr com.apple.quarantine /Applications/coconutBattery
sudo xattr -dr com.apple.quarantine /Applications/Dash
sudo xattr -dr com.apple.quarantine /Applications/DBeaver
sudo xattr -dr com.apple.quarantine /Applications/DeepL
sudo xattr -dr com.apple.quarantine /Applications/Docker
sudo xattr -dr com.apple.quarantine /Applications/Fig
sudo xattr -dr com.apple.quarantine /Applications/Gemini\ 2
sudo xattr -dr com.apple.quarantine /Applications/Google\ Chrome
sudo xattr -dr com.apple.quarantine /Applications/Google\ Drive
sudo xattr -dr com.apple.quarantine /Applications/IINA
sudo xattr -dr com.apple.quarantine /Applications/iTerm
sudo xattr -dr com.apple.quarantine /Applications/Itsycal
sudo xattr -dr com.apple.quarantine /Applications/JetBrains\ Toolbox
sudo xattr -dr com.apple.quarantine /Applications/Karabiner-Elements
sudo xattr -dr com.apple.quarantine /Applications/Keka
sudo xattr -dr com.apple.quarantine /Applications/Keyboard\ Cleaner
sudo xattr -dr com.apple.quarantine /Applications/Latest
sudo xattr -dr com.apple.quarantine /Applications/Medis
sudo xattr -dr com.apple.quarantine /Applications/MonitorControl
sudo xattr -dr com.apple.quarantine /Applications/Notion
sudo xattr -dr com.apple.quarantine /Applications/OneDrive
sudo xattr -dr com.apple.quarantine /Applications/OnyX
sudo xattr -dr com.apple.quarantine /Applications/PopClip
sudo xattr -dr com.apple.quarantine /Applications/Postman
sudo xattr -dr com.apple.quarantine /Applications/Raycast
sudo xattr -dr com.apple.quarantine /Applications/Slack
sudo xattr -dr com.apple.quarantine /Applications/Sourcetree
sudo xattr -dr com.apple.quarantine /Applications/Telegram
sudo xattr -dr com.apple.quarantine /Applications/Visual\ Studio\ Code

# Karabiner Hyper키로 대체
# #우측 커맨드 한영키 전환 - 시작
# #참고1: https://www.youtube.com/watch?v=Z8tzpHW3ApA
# #참고2: https://www.notion.so/ee35e655235d41ecb259ff2f27ccb962
# #1
# printf '%s\n' '#!/bin/sh' \ 'hidutil property --set '"'"'{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x7000000E7,"HIDKeyboardModifierMappingDst":0x70000006C}]}'"'" \ >/Users/Shared/keymap
# chmod 755 /Users/Shared/keymap
# #2
# cat<<: >/Users/Shared/keymap.plist
# <?xml version="1.0" encoding="UT~-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "[http://www.apple.com/DTDs/PropertyList-1.0.dtd](http://www.apple.com/DTDs/PropertyList-1.0.dtd)"><plist version="1.0"><dict><key>Label</key><string>keymap</string><key>ProgramArguments</key><array><string>/Users/Shared/keymap</string></array><key>RunAtLoad</key><true/></dict></plist>
# :
# #3
# sudo mv /Users/Shared/keymap.plist /Library/LaunchAgents
# #4
# launchctl load /Library/LaunchAgents/keymap.plist
# #키보드-단축키-입력 소스-입력 메뉴에서 다음 소스 선택 단축키를 우측 커맨드로 변경
# #우측 커맨드 한영키 전환 - 끝

# #우측 커맨드 한영 원상복구
# # launchctl remove keymap
# # rm /Users/Shared/keymap
# # sudo rm /Library/LaunchAgents/keymap.plist

# 설치 성공 완료 메세지 노출
printf '\n install success! \n'