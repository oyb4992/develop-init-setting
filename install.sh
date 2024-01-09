# !/bin/bash

# Homebrew 설치 여부 확인
if ! which brew
then
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 스크립트 내에서 일부 sudo 권한이 필요한 명령을 수행하기 위해 root 패스워드를 입력
# sudo 권한이 필요한 이유 : cask로 설치한 애플리케이션을 바로 실행하기 위해 다운로드 된 파일에 대한 격리 속성 제거 작업
read -r -s -p "[sudo] sudo password for $(whoami):" pass

# 설정은 모든 앱 설치 후 별도로 적용
# # configure zsh
# chmod 755 ./zsh/install.sh
# ./zsh/install.sh

# # copy iterm2 configuration
# chmod 755 ./iterm2/install.sh
# ./iterm2/install.sh

# # copy karabiner configuration
# chmod 755 ./karabiner/install.sh
# ./karabiner/install.sh

# # install font
# cp -a ./fonts/. ~/Library/Fonts

# # zshrc 설정 적용
# source ~/.zshrc

# BrewFile 실행 명령어
brew bundle --file=./Brewfile

# cask로 다운로드시 웹에서 다운로드한 것과 동일하기 때문에 실행을 하면 Security 문제로 실행되지 않음
# cask로 설치한 애플리케이션을 바로 실행하기 위해 다운로드 된 파일에 대한 격리 속성 제거 작업 명령어
sudo xattr -dr com.apple.quarantine /Applications/AppCleaner
sudo xattr -dr com.apple.quarantine /Applications/BetterTouchTool
sudo xattr -dr com.apple.quarantine /Applications/DBeaver
sudo xattr -dr com.apple.quarantine /Applications/DeepL
sudo xattr -dr com.apple.quarantine /Applications/Google\ Chrome
sudo xattr -dr com.apple.quarantine /Applications/Google\ Drive
sudo xattr -dr com.apple.quarantine /Applications/IINA
sudo xattr -dr com.apple.quarantine /Applications/iTerm
sudo xattr -dr com.apple.quarantine /Applications/Itsycal
sudo xattr -dr com.apple.quarantine /Applications/JetBrains\ Toolbox
sudo xattr -dr com.apple.quarantine /Applications/Karabiner-Elements
sudo xattr -dr com.apple.quarantine /Applications/Keka
sudo xattr -dr com.apple.quarantine /Applications/Latest
sudo xattr -dr com.apple.quarantine /Applications/OneDrive
sudo xattr -dr com.apple.quarantine /Applications/PopClip
sudo xattr -dr com.apple.quarantine /Applications/Postman
sudo xattr -dr com.apple.quarantine /Applications/Raycast
sudo xattr -dr com.apple.quarantine /Applications/Slack
# sudo xattr -dr com.apple.quarantine /Applications/Telegram #개인맥북엔 필요
sudo xattr -dr com.apple.quarantine /Applications/Visual\ Studio\ Code
sudo xattr -dr com.apple.quarantine /Applications/GitHub\ Desktop
sudo xattr -dr com.apple.quarantine /Applications/MonitorControl

# 설치 성공 완료 메세지 노출
printf '\n install success! \n'