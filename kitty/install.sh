#!/bin/bash

# Kitty 설정 디렉토리 생성
mkdir -p ~/.config/kitty

# Kitty 설정 파일 복사
cp ./kitty/kitty.conf ~/.config/kitty/kitty.conf

echo "Kitty 설정이 완료되었습니다."