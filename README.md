# llm 🦙

A terminal management script and orchestrator for `llama.cpp` and local AI interfaces.

## Features
- **Multi-Backend Engine**: Switch seamlessly between `mainline`, `ikllamacpp` (CUDA optimized), and `beellamacpp`.
- **Auto-NGL VRAM Calculation**: Automatically reads GGUF block structures and computes optimal GPU layer offload (`-ngl`) to fit your available VRAM.
- **Frontend Hub**: Launch and manage multiple interfaces:
  - **CLI**: Interactive terminal (`llama-cli`)
  - **Server**: Local or public (`0.0.0.0`) `llama-server` with API keys
  - **MykyAgent**: Lightweight coding agent with subagent web distillation & guardrails
  - **Pi**: Coding agent with local models
  - **Hermes**: Autonomous reasoning agent
  - **OpenCode** / **Codehamr**: Terminal and GUI code assistants
  - **SillyTavern** / **Odysseus** / **DeepSeek Harness** / **Little-coder**
- **Dynamic Model Injection**: Automatically probes active `llama-server` models, context windows, and reasoning configs for connected agents.
- **Unified Updates**: Upgrades `llama.cpp`, submodules, recompiles kernels, and updates all installed frontends via `llm -u`.
  API/cloud users with no local engine can still run `llm -u` — it skips the missing engine and just updates the orchestrator and installed frontends.

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
