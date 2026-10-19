#!/usr/bin/env bash
set -euo pipefail

nvidia-docker () {
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey |
sudo gpg --dearmor --yes \
  -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg

curl -fsSL \
https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list |
sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' |
sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null

echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/00-build-speed
sudo apt-get update
sudo apt-get install -y nvidia-container-toolkit-base
rm -f /etc/dpkg/dpkg.cfg.d/00-build-speed

sudo install -d -m 0755 /etc/systemd/system/nvidia-cdi-refresh.service.d
sudo tee /etc/systemd/system/nvidia-cdi-refresh.service.d/20-incus.conf >/dev/null <<'EOF'
[Unit]
ConditionPathExists=/dev/nvidiactl
Before=docker.service containerd.service
[Service]
ExecCondition=
ExecStart=
ExecStart=/usr/bin/nvidia-ctk cdi generate --output=/var/run/cdi/nvidia.yaml
EOF
sudo systemctl daemon-reload
sudo systemctl enable nvidia-cdi-refresh.service nvidia-cdi-refresh.path
sudo systemctl restart nvidia-cdi-refresh.service
}
nvidia-docker

chezmoi () {
echo 'force-unsafe-io' > /etc/dpkg/dpkg.cfg.d/00-build-speed
sudo apt-get update
sudo apt-get install -y zsh direnv
rm -f /etc/dpkg/dpkg.cfg.d/00-build-speed

sudo chsh -s "$(command -v zsh)" code

curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o /tmp/omz-install.sh
sudo -u code -H sh -c 'cd "$HOME" && exec sh /tmp/omz-install.sh --unattended --keep-zshrc'
rm -f /tmp/omz-install.sh

sudo -u code -H bash -c '
  set -euo pipefail
  cd "$HOME"
  installer="$(curl -fsLS https://get.chezmoi.io)"
  sh -c "$installer" -- init --apply https://github.com/dotverx/dotfiles.git
'

if ! sudo grep -qF '# coi: switch to zsh' /home/code/.bashrc 2>/dev/null; then
sudo tee -a /home/code/.bashrc >/dev/null <<'EOF'
# coi: switch to zsh
if [[ $- == *i* ]] && command -v zsh >/dev/null 2>&1; then
exec zsh
fi
EOF
fi
sudo chown code:code /home/code/.bashrc
}
chezmoi
