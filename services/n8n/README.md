# n8n 로컬 개발 환경 설정

이 디렉터리는 Docker Compose를 사용하여 **n8n**을 로컬에서 실행하기 위한 최소 구성입니다. 아래 단계를 따라 진행합니다.

## 1. 준비 사항

- 시스템에 **Docker**와 **Docker Compose**가 설치되어 있어야 합니다.
- 이 저장소를 프로젝트(예: `/Users/oyunbog/IdeaProjects/dev-init-setting`)에 복제하거나 복사합니다.

## 2. 암호화 키 설정

1. `.env.example` 파일을 `.env`로 복사합니다.

   ```bash
   cp .env.example .env
   ```

2. 텍스트 편집기로 `.env` 파일을 열고 `N8N_ENCRYPTION_KEY` 값을 긴 무작위 문자열로 변경합니다. 대부분의 시스템에서 다음 명령어로 32바이트 길이의 16진수 문자열을 생성할 수 있습니다.

   ```bash
   openssl rand -hex 32
   ```

   생성된 문자열을 `.env` 파일의 `N8N_ENCRYPTION_KEY` 항목에 넣습니다.

## 3. n8n 시작하기

`docker-compose.yml` 파일이 있는 디렉터리에서 다음 명령을 실행합니다.

```bash
docker compose up -d
```

이 명령은 다음 작업을 수행합니다:

* `n8n` 도커 이미지를 없으면 가져옵니다.
* `n8n`이라는 이름의 단일 컨테이너를 포트 **5678**에서 실행합니다.
* 호스트의 `data/n8n` 디렉터리를 컨테이너에 마운트하여 워크플로우와 자격증명을 영구적으로 저장합니다.

컨테이너가 실행되면 브라우저에서 **http://localhost:5678** 주소로 접속하여 n8n UI에 접근할 수 있습니다. 여기서 워크플로우를 작성할 수 있습니다.

## 4. n8n 중지하기

컨테이너를 중지하려면 다음 명령을 실행합니다:

```bash
docker compose down
```

이 명령은 컨테이너를 종료하고 삭제하지만 `data/n8n` 디렉터리에 저장된 데이터는 유지됩니다.

런타임 데이터까지 초기화하려면 컨테이너를 중지한 뒤 `data/` 디렉터리를 삭제합니다. 이 디렉터리에는 SQLite DB, 실행 로그, 워크플로우, 자격증명 데이터가 들어 있으므로 필요한 백업이 있는지 먼저 확인합니다.

## 5. n8n 업데이트하기

n8n은 활발히 개발 중이며 업데이트가 자주 릴리스됩니다. 로컬 인스턴스를 업데이트하려면:

1. 실행 중인 컨테이너를 중지합니다.

   ```bash
   docker compose down
   ```

2. 최신 `n8n` 이미지를 가져오고 다시 실행합니다.

   ```bash
   docker compose pull
   docker compose up -d
   ```

데이터는 `data/n8n` 디렉터리에 저장되므로 기존 워크플로우와 자격증명은 유지됩니다.

## 6. (선택) OpenClaw와 연결

n8n에서 **OpenClaw**를 호출해야 하는 경우 워크플로우 내에서 **HTTP Request** 노드를 사용하면 됩니다. 예를 들어:

- **Method:** `POST`
- **URL:** `http://localhost:3000/hooks/agent` (또는 사용 중인 OpenClaw 서버 URL)
- **Headers:**
  - `Authorization: Bearer <HOOKS_TOKEN>`
  - `Content-Type: application/json`
- **Body:** 릴리즈 버전 정보, Gmail 알림 등 업무에 맞는 JSON 데이터를 입력합니다.

URL과 헤더는 OpenClaw 서버 설정에 맞게 수정합니다.

## 7. 추가 설정

이 구성은 SQLite 데이터베이스와 `regular` 모드로 실행하는 단일 컨테이너를 사용합니다. 개인용 자동화 작업에는 충분하지만 워크플로우가 늘어나거나 동시 실행이 많아지는 경우 PostgreSQL 데이터베이스와 queue 모드로 마이그레이션하는 것을 고려할 수 있습니다. 자세한 내용은 n8n 공식 문서를 참고합니다.

- [지원되는 데이터베이스 및 설정](https://docs.n8n.io/hosting/configuration/supported-databases-settings/)
- [queue 모드와 Redis를 이용한 확장](https://docs.n8n.io/hosting/scaling/queue-mode/)

## 8. Oracle Cloud VPS / Always Free 티어 주의사항

Oracle Cloud VPS(Always Free)와 같은 제한된 리소스 환경에서는 CPU, 메모리 및 저장 공간 사용을 주의 깊게 관리해야 합니다. 폴링 간격을 낮추고 실행 데이터를 정리하는 설정을 활용하여 자원 소비를 줄이세요.
