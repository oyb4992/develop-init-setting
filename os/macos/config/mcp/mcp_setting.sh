set -e

MCP_HOME="$HOME/.config/mcp"
PROJECT_PATH="$HOME/IdeaProjects"
GITHUB_PERSONAL_ACCESS_TOKEN="github_pat_여기에_토큰_입력"
#DATABASE_URI="postgresql://사용자:비밀번호@host.docker.internal:5432/데이터베이스명"

mkdir -p "$MCP_HOME"
chmod 700 "$MCP_HOME"

# GitHub MCP 설정
cat > "$MCP_HOME/github.env" <<EOF
GITHUB_PERSONAL_ACCESS_TOKEN=$GITHUB_PERSONAL_ACCESS_TOKEN
GITHUB_TOOLSETS=repos,issues,pull_requests,actions
GITHUB_READ_ONLY=1
EOF

# PostgreSQL MCP 설정
#cat > "$MCP_HOME/postgres.env" <<EOF
#DATABASE_URI=$DATABASE_URI
#EOF

chmod 600 \
  "$MCP_HOME/github.env" \
#  "$MCP_HOME/postgres.env"

# Filesystem MCP 실행 스크립트
cat > "$MCP_HOME/filesystem.sh" <<EOF
#!/usr/bin/env bash

# src="$PROJECT_PATH": macOS의 실제 접근 허용 디렉터리
# dst=/workspace: 컨테이너 내부에서 보이는 경로
# 마지막 /workspace: Filesystem MCP가 접근을 허용할 루트 디렉터리
exec docker run -i --rm \
  --mount type=bind,src="$PROJECT_PATH",dst=/workspace \
  mcp/filesystem \
  /workspace
EOF

# GitHub MCP 실행 스크립트
cat > "$MCP_HOME/github.sh" <<'EOF'
#!/usr/bin/env bash

exec docker run -i --rm \
  --env-file "$HOME/.config/mcp/github.env" \
  ghcr.io/github/github-mcp-server
EOF

# PostgreSQL MCP 실행 스크립트
#cat > "$MCP_HOME/postgres.sh" <<'EOF'
##!/usr/bin/env bash

#exec docker run -i --rm \
#  --env-file "$HOME/.config/mcp/postgres.env" \
#  crystaldba/postgres-mcp \
#  --access-mode=restricted
#EOF

chmod 700 \
  "$MCP_HOME/filesystem.sh" \
  "$MCP_HOME/github.sh"
#  "$MCP_HOME/postgres.sh"

# 이미지 미리 받기
docker pull mcp/filesystem
docker pull ghcr.io/github/github-mcp-server
#docker pull crystaldba/postgres-mcp

echo
echo "MCP 설정 생성 완료:"
echo "  $MCP_HOME/filesystem.sh"
echo "  $MCP_HOME/github.sh"
#echo "  $MCP_HOME/postgres.sh"