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

### set name and alias
in this repo `.coi/config.toml`

```toml
[container]
image = FixMeInConfigToml
alias = FixMeInConfigToml
```

change to custom names that dont collide with existing local ones

```toml
[container]
image = "custom-app-image"
alias = "app"
```

### build a container
```sh
coi build
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
