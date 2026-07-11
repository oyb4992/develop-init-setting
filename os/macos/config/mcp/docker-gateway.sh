#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"
export DOCKER_MCP_USE_CE=true
export DOCKER_MCP_IN_CONTAINER=1
export DOCKER_CONTEXT=colima
export MCP_GATEWAY_DOCKER_BIND_ALLOWED_PATHS="/Users/oyunbog/IdeaProjects"

exec /opt/homebrew/bin/docker mcp gateway run \
  --servers github-official,filesystem \
  --config "$HOME/.docker/mcp/config.yaml" \
  --secrets "$HOME/.config/mcp/github.env" \
  --cpus 1 \
  --memory 1Gb \
  --log-calls \
  "$@"
