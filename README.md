# 🚀 개발 환경 설정 도구

macOS와 Windows 시스템을 위한 포괄적인 개발 환경 구성 저장소입니다. 체계적으로 정리된 설정 파일, 자동화된 설치 스크립트, 생산성 도구를 통해 완전한 개발자 워크스테이션 구축을 위한 Infrastructure-as-Code를 제공합니다.

## 📋 목차

- [주요 특징](#-주요-특징)
- [빠른 시작](#-빠른-시작)
- [디렉토리 구조](#-디렉토리-구조)
- [설치 방법](#-설치-방법)
- [설정 가이드](#️-설정-가이드)
- [도구 개요](#️-도구-개요)
- [플랫폼 지원](#-플랫폼-지원)
- [유지보수](#-유지보수)
- [기여하기](#-기여하기)

## ✨ 주요 특징

- **🎯 원클릭 설치**: 하나의 스크립트로 완전한 개발 환경 구축
- **🔧 모듈식 구성**: OS 및 기능별로 분리된 설정 (`os/common`, `os/macos`)
- **💻 크로스 플랫폼**: macOS와 Windows 시스템 모두 지원
- **📦 패키지 관리**: Homebrew를 통한 자동화된 설치
- **⚡ 성능 최적화**: 빠른 터미널, 효율적인 에디터, 생산성 도구
- **🛡️ 보안 중심**: 적절한 권한 처리와 안전한 기본 설정

## 🚀 빠른 시작

```bash
# 저장소 클론
git clone <repository-url>
cd dev-init-setting

# 설치 스크립트 실행
chmod +x install.sh
./install.sh
```

**끝!** 개발 환경이 자동으로 구성됩니다.

## 📁 디렉토리 구조

```
dev-init-setting/
├── 📋 README.md                    # 프로젝트 문서
├── 📝 CLAUDE.md                    # Claude Code 사용 지침
├── 📝 GEMINI.md                    # Gemini AI 사용 지침
├── 📝 shrimp-rules.md              # Shrimp 작업 규칙
├── 📄 .gitignore                   # Git 무시 규칙
├── 
├── 📁 os/                          # OS별 및 공통 설정
│   ├── 📁 common/                  # 공통 설정
│   │   ├── 📁 config/              # 공통 도구 설정 (Kitty, iTerm2, Neovim, Zsh 등)
│   │   ├── 📁 assets/              # 정적 자산 (폰트 등)
│   │   └── 📜 install.sh           # 공통 설치 스크립트
│   │
│   ├── 📁 macos/                   # macOS 전용 설정
│   │   ├── 📁 config/              # macOS 전용 도구 설정 (AeroSpace, Hammerspoon, Raycast 등)
│   │   ├── 📁 packages/            # 패키지 관리 (Brewfile)
│   │   └── 📜 install.sh           # macOS 설치 스크립트
│   │
│   └── 📁 windows/                 # Windows 전용 설정
│       └── � install.sh           # Windows 설치 스크립트
├── 
├── � install.sh                   # 메인 설치 스크립트
├── 
├── 📁 services/                    # Docker 서비스
│   └── lobechat/                   # LobeChat 설정
│       └── docker-compose.yml      # Docker Compose 파일
└── 
```

## 🔧 설치 방법

### 사전 요구사항

- **macOS**: macOS 10.15+ (Catalina 이상)
- **Windows**: Windows 10/11 with WSL2 (Unix 도구 사용을 위해)
- **인터넷 연결**: 패키지 다운로드를 위해 필요

### 자동 설치

```bash
# 전체 설치 (권장)
./install.sh
```

### 수동 설치

```bash
# Homebrew 패키지만 설치
brew bundle --file=./os/macos/packages/Brewfile

# 개별 도구 설정
./os/common/config/zsh/install.sh
./os/macos/config/karabiner/install.sh
./os/common/config/kitty/install.sh
```

## ⚙️ 설정 가이드

### 설치 후 단계

1. **터미널 재시작**: 모든 쉘 설정 적용
2. **Raycast 설정**: 단축키 및 확장 기능 설정
3. **Karabiner 설정**: 키보드 수정 기능 활성화
4. **AeroSpace 설정**: 창 관리자 활성화 및 단축키 확인
5. **Kitty 확인**: 터미널 외관 및 기능 확인

### 커스터마이징

각 설정 디렉토리에는 다음이 포함됩니다:
- **설정 파일**: 메인 설정
- **설치 스크립트**: 자동화된 설정
- **문서**: 도구별 가이드

커스터마이징 예시:
```bash
# Kitty 터미널 설정 편집
vim os/common/config/kitty/kitty.conf

# Zsh 설정 수정
vim os/common/config/zsh/.zshrc

# 키보드 매핑 업데이트
vim os/macos/config/karabiner/karabiner.json
```

## 🛠️ 도구 개요

### 에디터 & IDE
- **Neovim**: LazyVim 배포판을 사용한 모던 Vim
- **VS Code**: Vim 키바인딩과 통합
- **IntelliJ IDEA**: Vim 플러그인 설정

### 터미널
- **Kitty**: 빠른 GPU 가속 터미널 (메인)
- **iTerm2**: macOS용 기능이 풍부한 터미널 (보조)
- **Zsh**: Oh-My-Zsh로 향상된 쉘

### 생산성 도구 (macOS)
- **Raycast**: 애플리케이션 런처 및 생산성 도구
- **Karabiner-Elements**: 고급 키 리매핑
- **PopClip**: 텍스트 조작 확장 기능
- **Hammerspoon**: 시스템 자동화 스크립팅

### 윈도우 관리
- **AeroSpace**: macOS용 타일링 윈도우 매니저 (주력)
- **GlazeWM**: Windows용 타일링 윈도우 매니저
- **SKHD**: 단순 핫키 데몬

### 개발 도구
- **Docker & Colima**: 컨테이너화 플랫폼
- **Git**: git-flow가 포함된 버전 관리
- **Node.js**: JavaScript 런타임
- **Python 3.13**: UV 패키지 매니저 사용
- **mise**: 다중 언어 버전 관리자

## 🌐 플랫폼 지원

### macOS 기능
- ✅ Homebrew를 통한 네이티브 패키지 관리
- ✅ Karabiner를 사용한 고급 키보드 리매핑
- ✅ Hammerspoon을 통한 시스템 자동화
- ✅ Raycast 생산성 도구 모음
- ✅ BetterTouchTool을 통한 제스처 커스터마이징
- ✅ AeroSpace를 사용한 강력한 타일링 윈도우 관리

### Windows 기능
- ✅ GlazeWM을 사용한 타일링 윈도우 관리
- ✅ Zebar와 상태바 통합
- ✅ Unix 도구를 위한 WSL2 통합
- ✅ 크로스 플랫폼 터미널 설정

## 🔄 유지보수

### 패키지 업데이트

```bash
# 모든 Homebrew 패키지 업데이트
brew upgrade && brew cleanup

# Neovim 플러그인 업데이트
nvim +PlugUpdate +qa

# Raycast 확장 기능 리빌드
find os/common/config/raycast/raycast_command -name package.json -execdir npm run build \;
```

### 새로운 도구 추가

```bash
# Brewfile에 추가
echo "brew 'new-tool'" >> os/macos/packages/Brewfile

# 즉시 설치
brew install new-tool

# 설정 디렉토리 생성
mkdir -p os/common/config/new-tool
```

### 시스템 상태 확인

```bash
# Homebrew 상태 확인
brew doctor

# 설정 확인
kitty --version
nvim --version
zsh --version
```

## 🤝 기여하기

1. **저장소 포크**
2. **기능 브랜치 생성** (`git checkout -b feature/amazing-feature`)
3. **변경사항 철저히 테스트**
4. **변경사항 커밋** (`git commit -m 'Add amazing feature'`)
5. **브랜치에 푸시** (`git push origin feature/amazing-feature`)
6. **Pull Request 생성**

### 가이드라인

- 기존 디렉토리 구조 따르기
- 깨끗한 시스템에서 설치 스크립트 테스트
- 새로운 기능에 대한 문서 업데이트
- 가능한 경우 크로스 플랫폼 호환성 유지

## 📄 라이센스

이 프로젝트는 MIT 라이센스 하에 배포됩니다 - 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

## 🙏 감사인사

- [Homebrew](https://brew.sh/) - macOS용 패키지 매니저
- [Oh My Zsh](https://ohmyz.sh/) - Zsh 프레임워크
- [LazyVim](https://lazyvim.org/) - Neovim 설정
- [Raycast](https://raycast.com/) - 생산성 플랫폼
- [Kitty](https://sw.kovidgoyal.net/kitty/) - 터미널 에뮬레이터
- [AeroSpace](https://nikitabobko.github.io/AeroSpace/guide) - 타일링 윈도우 매니저

## 📞 지원

- 📧 **이슈**: [GitHub Issues](https://github.com/username/dev-init-setting/issues)
- 📖 **문서**: AI 어시스턴트 사용 지침은 `CLAUDE.md` 확인
- 💬 **토론**: [GitHub Discussions](https://github.com/username/dev-init-setting/discussions)

---

**🎉 행복한 코딩!** 당신의 개발 환경이 생산성과 효율성을 위해 최적화되었습니다.