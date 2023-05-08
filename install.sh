# !/bin/bash

# Homebrew 설치 여부 확인
if ! which brew
then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# 스크립트 내에서 일부 sudo 권한이 필요한 명령을 수행하기 위해 root 패스워드를 입력
# sudo 권한이 필요한 이유 : cask로 설치한 애플리케이션을 바로 실행하기 위해 다운로드 된 파일에 대한 격리 속성 제거 작업
read -r -s -p "[sudo] sudo password for $(whoami):" pass

# BrewFile 실행 명령어
brew bundle --file=./Brewfile

# cask로 다운로드시 웹에서 다운로드한 것과 동일하기 때문에 실행을 하면 Security 문제로 실행되지 않음
# cask로 설치한 애플리케이션을 바로 실행하기 위해 다운로드 된 파일에 대한 격리 속성 제거 작업 명령어
sudo xattr -dr com.apple.quarantine /Applications/AppCleaner
sudo xattr -dr com.apple.quarantine /Applications/BetterTouchTool
sudo xattr -dr com.apple.quarantine /Applications/CheatSheet
sudo xattr -dr com.apple.quarantine /Applications/coconutBattery
sudo xattr -dr com.apple.quarantine /Applications/DBeaver
sudo xattr -dr com.apple.quarantine /Applications/DeepL
sudo xattr -dr com.apple.quarantine /Applications/Fig
sudo xattr -dr com.apple.quarantine /Applications/Gemini\ 2
sudo xattr -dr com.apple.quarantine /Applications/Google\ Chrome
sudo xattr -dr com.apple.quarantine /Applications/Google\ Drive
sudo xattr -dr com.apple.quarantine /Applications/IINA
sudo xattr -dr com.apple.quarantine /Applications/iTerm
sudo xattr -dr com.apple.quarantine /Applications/Itsycal
sudo xattr -dr com.apple.quarantine /Applications/JetBrains\ Toolbox
sudo xattr -dr com.apple.quarantine /Applications/Keka
sudo xattr -dr com.apple.quarantine /Applications/Keyboard\ Cleaner
sudo xattr -dr com.apple.quarantine /Applications/Microsoft\ Edge
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

#SDKMAN 설치
curl -s "https://get.sdkman.io" | bash

# install font
cp -a ./fonts/. ~/Library/Fonts

# configure zsh
chmod 755 ./zsh/install.sh
./zsh/install.sh

# copy iterm2 configuration
chmod 755 ./iterm2/install.sh
./iterm2/install.sh

# 설치 성공 완료 메세지 노출
printf '\n install success! \n'