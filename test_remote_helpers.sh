#!/usr/bin/env bash
# Sandbox test for the new remote-registry helpers in ~/bridge/skripty/llm/llm.
# Sources only the function definitions (everything before the final case
# dispatch), stubs what's not needed, then exercises the new helpers against
# the real 192.168.0.147 server.
set -e
python3 - <<'PYEOF'
src = open("/home/myky/bridge/skripty/llm/llm").read()
idx = src.rindex('case "$1" in')
open("/tmp/llm_funcs.sh", "w").write(src[:idx])
PYEOF
bash -n /tmp/llm_funcs.sh

CONFIG_DIR=$(mktemp -d)
export API_KEY="cannotguess"
export REMOTES_FILE="$CONFIG_DIR/remotes.json"
source /tmp/llm_funcs.sh

echo "=== 1. probe real models from 192.168.0.147 ==="
probe_remote_models "http://192.168.0.147:8080/v1" "$API_KEY"

echo "=== 2. remotes_upsert + remotes_get_models ==="
probe_out=$(probe_remote_models "http://192.168.0.147:8080/v1" "$API_KEY")
remotes_upsert "192.168.0.147" "http://192.168.0.147:8080/v1" "$API_KEY" $probe_out
cat "$REMOTES_FILE"
echo "remembered: $(remotes_get_models 192.168.0.147 | tr '\n' ' ')"

echo "=== 3. provider keys ==="
remote_provider_key "192.168.0.147"
remote_provider_key "192.168.0.147:8081"

echo "=== 4. unreachable host -> empty output, no crash ==="
n=$(probe_remote_models "http://127.0.0.1:59999/v1" "$API_KEY" | wc -l)
echo "lines: $n"

echo "ALL OK"
