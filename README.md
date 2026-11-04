# llm 🦙

A terminal management script and orchestrator for `llama.cpp` and local AI interfaces.

## Features
- **Multi-Backend Engine**: Switch seamlessly between `mainline` and `ikllamacpp` (CPU/ik fork).
- **Frontend Hub**: Launch and manage multiple interfaces:
  - **CLI**: Interactive terminal (`llama-cli`)
  - **Server**: Local or public (`0.0.0.0`) `llama-server` with API keys (default port **9931**, same as upstream; override with `LLM_PORT=1234 llm`)
  - **MykyAgent**: Lightweight coding agent with subagent web distillation & guardrails
  - **Pi**: Coding agent with local models
  - **Hermes**: Autonomous reasoning agent
  - **OpenCode** / **Codehamr**: Terminal and GUI code assistants
  - **SillyTavern** / **Odysseus** / **DeepSeek Harness** / **Little-coder**
- **Dynamic Model Injection**: Automatically probes active `llama-server` models, context windows, and reasoning configs for connected agents.
- **Unified Updates**: Upgrades `llama.cpp`, submodules, recompiles kernels, and updates all installed frontends via `llm -u`.
  API/cloud users with no local engine can still run `llm -u` — it skips the missing engine and just updates the orchestrator and installed frontends.

## Backend tuning

Each backend emits only flags its build actually parses (checked against `llama-server --help` in `$BASE_DIR/llama.cpp-<backend>`):

| backend | extra flags | notes |
|---|---|---|
| `mainline` | `--load-mode mmap --lazy-mode on --poll 0 --prio -1 --cpu-strict`, `-nr`, `--sleep-idle-seconds` | full CPU pinning/polling control |
| `ikllamacpp` | `-rtr -mqkv -amb 512` | no `--load-mode`/`--poll`/`--prio`/`--cpu-strict`, no `-nr`, no idle unload |

- `ik`: `-rtr` run-time repack + `-mqkv` merge QKV + `-amb 512` attention max batch measured best of 64/128/512 on MiniCPM-35B-A3B and LFM3-1.7B. Override with `IK_TUNING="-rtr -amb 256"` in `llm_settings.conf`.
- `--cache-ram` and `--ctx-checkpoints` work on both; the idle-unload knob applies to `mainline` only.
- Speculative decoding names are translated for `ik` (`draft-mtp` → `mtp`, `draft-dspark` → `dspark`, `draft-simple` → `draft`, `--spec-draft-n-max N` → `--spec-type X:n_max=N`), so `llm_models.txt` stays in mainline spelling.

### GPU / limited VRAM

No auto-offload logic in the script: placement is upstream's job. Pass the flags yourself
in `llm_models.txt` field 3 (per model), `IK_TUNING`, or on the CLI:

- **mainline**: `-fitt <MiB>` (`--fit-target`, e.g. `-fitt 1024`) or `--fit off`, `-ngl N`.
- **ikllamacpp**: `--fit --fit-margin <MiB>` (per-tensor placement), `-ncmoe N` (first N layers' MoE experts stay on CPU), `-dexp` (defer expert mmap), `-nkvo` (KV in RAM), `-ot name=buf`, `-gfm layer,margin`.
- **Cache**: `--swa-compress` is in the ik default tuning (sliding-window layers get KV at window size, not `n_ctx`).

`LLM_CUDA=1 llm -i` (or `-c`) builds with `-DGGML_CUDA=ON`; plain builds stay CPU-only.

## Usage

Launch the interactive TUI:
```bash
llm
```
Select a model with `fzf`, auto-calculate VRAM offload, and select your target frontend mode.

### Standalone / Direct Launch
```bash
llm -ma             # Launch MykyAgent (connects to local or remote server)
llm -ma 192.168.1.50 # Connect MykyAgent to remote llama-server
llm -pi             # Launch Pi coding agent
llm -he             # Launch Hermes agent
llm -u              # Upgrade llama.cpp, engines, and installed frontends
llm -s              # Interactive sampling settings (temp, top-p, min-p, etc.)
llm -b              # Switch active llama.cpp backend
```
