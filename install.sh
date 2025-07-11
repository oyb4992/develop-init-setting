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
function configure_tool() {
    local tool_name=$1
    local install_script_path=$2

    echo "${tool_name} 설정을 적용합니다..."
    if [ -f "${install_script_path}" ]; then
        chmod 755 "${install_script_path}"
        "${install_script_path}"
    else
        echo "${install_script_path}를 찾을 수 없습니다."
    fi
}

# configure zsh
configure_tool "Zsh" "./zsh/install.sh"

# copy karabiner configuration
configure_tool "Karabiner" "./karabiner/install.sh"

# configure kitty
configure_tool "Kitty" "./kitty/install.sh"

# install fonts
echo "폰트를 설치합니다..."
if [ -d "./fonts" ]; then
    cp -a ./fonts/. ~/Library/Fonts
    echo "폰트 설치가 완료되었습니다."
else
    echo "fonts 디렉토리를 찾을 수 없습니다."
fi

function remove_quarantine_attribute() {
    echo "애플리케이션 격리 속성을 제거합니다..."
    if [ -f "./apps.txt" ]; then
        while IFS= read -r app_name || [[ -n "$app_name" ]]; do
            if [ -d "/Applications/${app_name}" ]; then
                sudo xattr -dr com.apple.quarantine "/Applications/${app_name}" 2>/dev/null && echo "${app_name} 격리 속성 제거 완료" || echo "${app_name} 격리 속성 제거 실패 (이미 제거되었을 수 있음)"
            else
                echo "${app_name}이 설치되어 있지 않습니다."
            fi
        done < ./apps.txt
    else
        echo "apps.txt 파일을 찾을 수 없습니다. 애플리케이션 격리 속성을 제거할 수 없습니다."
    fi
}

remove_quarantine_attribute


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