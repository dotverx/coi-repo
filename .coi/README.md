### global coi config
in `"$HOME/.coi/config.toml"` something like this:
```toml
[container]
image = "coi-default"
storage_pool = "default"

[container.build]
agents = ["codex"]

[tool]
name = "codex"

[shell]
use_tmux = false
```

gpu access in default profile:
```sh
incus --project default \
  profile device add \
  default \
  local-gpu \
  gpu gputype=physical mode=0666

incus --project default \
  profile set \
  default \
  nvidia.runtime=true \
  nvidia.driver.capabilities=all
```

### run a container with bash
```sh
coi shell --debug --slot 1
```

### attach bash to a running container
```sh
coi attach --bash
coi attach ALIAS --bash
coi attach repo-app --bash
```
