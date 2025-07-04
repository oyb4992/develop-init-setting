#!/bin/bash

set -e  # 에러 발생 시 스크립트 종료

# Homebrew 설치 여부 확인
if ! command -v brew &> /dev/null; then
    echo "Homebrew가 설치되어 있지 않습니다. 설치를 시작합니다..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # M1/M2 Mac의 경우 PATH에 Homebrew 추가
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# sudo 권한 갱신
sudo -v

# BrewFile 실행 명령어
echo "패키지 설치를 시작합니다..."
if [ -f "./NewBrewfile" ]; then
    brew bundle --file=./NewBrewfile
else
    echo "NewBrewfile을 찾을 수 없습니다."
    exit 1
fi

# 설정은 모든 앱 설치 후 별도로 적용
# configure zsh
echo "Zsh 설정을 적용합니다..."
if [ -f "./zsh/install.sh" ]; then
    chmod 755 ./zsh/install.sh
    ./zsh/install.sh
else
    echo "zsh/install.sh를 찾을 수 없습니다."
fi

# copy karabiner configuration
echo "Karabiner 설정을 적용합니다..."
if [ -f "./karabiner/install.sh" ]; then
    chmod 755 ./karabiner/install.sh
    ./karabiner/install.sh
else
    echo "karabiner/install.sh를 찾을 수 없습니다."
fi

# configure kitty
echo "Kitty 설정을 적용합니다..."
if [ -f "./kitty/install.sh" ]; then
    chmod 755 ./kitty/install.sh
    ./kitty/install.sh
else
    echo "kitty/install.sh를 찾을 수 없습니다."
fi

# install fonts
echo "폰트를 설치합니다..."
if [ -d "./fonts" ]; then
    cp -a ./fonts/. ~/Library/Fonts
    echo "폰트 설치가 완료되었습니다."
else
    echo "fonts 디렉토리를 찾을 수 없습니다."
fi

# cask로 다운로드시 웹에서 다운로드한 것과 동일하기 때문에 실행을 하면 Security 문제로 실행되지 않음
# cask로 설치한 애플리케이션을 바로 실행하기 위해 다운로드 된 파일에 대한 격리 속성 제거 작업 명령어
echo "애플리케이션 격리 속성을 제거합니다..."

# 설치된 애플리케이션들의 격리 속성 제거
APPS=(
    "AppCleaner.app"
    "BetterTouchTool.app"
    "Boop.app"
    "DeepL.app"
    "Google Chrome.app"
    "Google Drive.app"
    "Itsycal.app"
    "JetBrains Toolbox.app"
    "Karabiner-Elements.app"
    "Keka.app"
    "Latest.app"
    "Obsidian.app"
    "OneDrive.app"
    "OpenLens.app"
    "PopClip.app"
    "Postman.app"
    "Raycast.app"
    "Slack.app"
    "Visual Studio Code.app"
    "GitHub Desktop.app"
    "Claude.app"
    "AeroSpace.app"
    "Arc.app"
    "Battery Toolkit.app"
    "kitty.app"
    "MonitorControl.app"
    "Ollama.app"
    "Another Redis Desktop Manager.app"
    "HTTPie Desktop.app"
    "IINA.app"
    "Kodi.app"
    "Zen Browser.app"
)

for app in "${APPS[@]}"; do
    if [ -d "/Applications/${app}" ]; then
        sudo xattr -dr com.apple.quarantine "/Applications/${app}" 2>/dev/null && echo "${app} 격리 속성 제거 완료" || echo "${app} 격리 속성 제거 실패 (이미 제거되었을 수 있음)"
    else
        echo "${app}이 설치되어 있지 않습니다."
    fi
done


# 설치 성공 완료 메시지 노출
echo ""
echo "================================="
echo "    개발 환경 설정이 완료되었습니다!"
echo "================================="
echo "다음 단계:"
echo "1. 터미널을 재시작하여 모든 변경사항을 적용하세요."
echo "2. Raycast를 실행하여 초기 설정을 완료하세요."
echo "3. Karabiner-Elements를 실행하여 키보드 설정을 확인하세요."
echo "4. Kitty 터미널을 열어 설정을 확인하세요."
echo ""