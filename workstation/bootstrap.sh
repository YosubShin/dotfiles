#!/bin/bash

set -eu

export DEBIAN_FRONTEND=noninteractive

UPGRADE_PACKAGES=${1:-none}

if [ "${UPGRADE_PACKAGES}" != "none" ]; then
  echo "==> Updating and upgrading packages ..."

  # Add third party repositories
  sudo add-apt-repository ppa:keithw/mosh-dev -y

  CLOUD_SDK_SOURCE="/etc/apt/sources.list.d/google-cloud-sdk.list"
  CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"
  if [ ! -f "${CLOUD_SDK_SOURCE}" ]; then
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a ${CLOUD_SDK_SOURCE}
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  fi

  YARN_SOURCE="/etc/apt/sources.list.d/yarn.list"
  if [ ! -f "${YARN_SOURCE}" ]; then
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee -a ${YARN_SOURCE}
    curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
  fi

  sudo apt-get update
  sudo apt-get upgrade -y
fi

sudo apt-get install -qq \
  apache2-utils \
  apt-transport-https \
  build-essential \
  bzr \
  ca-certificates \
  clang \
  cmake \
  curl \
  direnv \
  dnsutils \
  docker.io \
  fakeroot-ng \
  gdb \
  git \
  git-crypt \
  gnupg \
  gnupg2 \
  htop \
  hugo \
  ipcalc \
  jq \
  less \
  libclang-dev \
  liblzma-dev \
  libpq-dev \
  libprotoc-dev \
  libsqlite3-dev \
  libssl-dev \
  libvirt-clients \
  libvirt-daemon-system \
  lldb \
  locales \
  man \
  mosh \
  mtr-tiny \
  musl-tools \
  ncdu \
  netcat-openbsd \
  openssh-server \
  pkg-config \
  protobuf-compiler \
  pwgen \
  python \
  python3 \
  python3-flake8 \
  python3-pip \
  python3-setuptools \
  python3-venv \
  python3-wheel \
  qrencode \
  quilt \
  ripgrep \
  shellcheck \
  socat \
  software-properties-common \
  sqlite3 \
  stow \
  sudo \
  tmate \
  tmux \
  tree \
  unzip \
  wget \
  zgen \
  zip \
  zlib1g-dev \
  zsh \
  emacs \
  yarn \
  --no-install-recommends \

rm -rf /var/lib/apt/lists/*

# install Go
if ! [ -x "$(command -v go)" ]; then
  export GO_VERSION="1.12.6"
  wget "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" 
  tar -C /usr/local -xzf "go${GO_VERSION}.linux-amd64.tar.gz" 
  rm -f "go${GO_VERSION}.linux-amd64.tar.gz"
  export PATH="/usr/local/go/bin:$PATH"
fi

# install doctl
if ! [ -x "$(command -v doctl)" ]; then
  export DOCTL_VERSION="1.20.1"
  wget https://github.com/digitalocean/doctl/releases/download/v${DOCTL_VERSION}/doctl-${DOCTL_VERSION}-linux-amd64.tar.gz
  tar xf doctl-${DOCTL_VERSION}-linux-amd64.tar.gz 
  chmod +x doctl 
  mv doctl /usr/local/bin 
  rm -f doctl-${DOCTL_VERSION}-linux-amd64.tar.gz
fi

# install terraform
if ! [ -x "$(command -v terraform)" ]; then
  export TERRAFORM_VERSION="0.12.2"
  wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
  unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip 
  chmod +x terraform
  mv terraform /usr/local/bin
  rm -f terraform_${TERRAFORM_VERSION}_linux_amd64.zip
fi

# install protobuf
if ! [ -x "$(command -v protoc)" ]; then
  export PROTOBUF_VERSION="3.8.0"
  mkdir -p protobuf_install 
  pushd protobuf_install
  wget https://github.com/protocolbuffers/protobuf/releases/download/v${PROTOBUF_VERSION}/protoc-${PROTOBUF_VERSION}-linux-x86_64.zip
  unzip protoc-${PROTOBUF_VERSION}-linux-x86_64.zip
  mv bin/protoc /usr/local/bin
  mv include/* /usr/local/include/
  popd
  rm -rf protobuf_install
fi

# install tools
if ! [ -x "$(command -v jump)" ]; then
  echo " ==> Installing jump .."
  export JUMP_VERSION="0.23.0"
  wget https://github.com/gsamokovarov/jump/releases/download/v${JUMP_VERSION}/jump_${JUMP_VERSION}_amd64.deb
  sudo dpkg -i jump_${JUMP_VERSION}_amd64.deb
  rm -f jump_${JUMP_VERSION}_amd64.deb
fi

if ! [ -x "$(command -v hub)" ]; then
  echo " ==> Installing hub .."
  export HUB_VERSION="2.12.0"
  wget https://github.com/github/hub/releases/download/v${HUB_VERSION}/hub-linux-amd64-${HUB_VERSION}.tgz
  tar xf hub-linux-amd64-${HUB_VERSION}.tgz
  chmod +x hub-linux-amd64-${HUB_VERSION}/bin/hub
  cp hub-linux-amd64-${HUB_VERSION}/bin/hub /usr/local/bin
  rm -rf hub-linux-amd64-${HUB_VERSION}
  rm -f hub-linux-amd64-${HUB_VERSION}.tgz*
fi

if [ ! -d "$(go env GOPATH)" ]; then
  echo " ==> Installing Go tools"
  # vim-go tooling
  go get -u -v github.com/davidrjenni/reftools/cmd/fillstruct
  go get -u -v github.com/mdempsky/gocode
  go get -u -v github.com/rogpeppe/godef
  go get -u -v github.com/zmb3/gogetdoc
  go get -u -v golang.org/x/tools/cmd/goimports
  go get -u -v golang.org/x/tools/cmd/gorename
  go get -u -v golang.org/x/tools/cmd/guru
  go get -u -v golang.org/x/tools/cmd/gopls
  go get -u -v golang.org/x/lint/golint
  go get -u -v github.com/josharian/impl
  go get -u -v honnef.co/go/tools/cmd/keyify
  go get -u -v github.com/fatih/gomodifytags
  go get -u -v github.com/fatih/motion
  go get -u -v github.com/koron/iferr

  # generic
  go get -u -v github.com/aybabtme/humanlog/cmd/...
  go get -u -v github.com/fatih/hclfmt

  export GIT_TAG="v1.2.0" 
  go get -d -u github.com/golang/protobuf/protoc-gen-go 
  git -C "$(go env GOPATH)"/src/github.com/golang/protobuf checkout $GIT_TAG 
  go install github.com/golang/protobuf/protoc-gen-go

  cp -r $(go env GOPATH)/bin/* /usr/local/bin/
fi

if [ ! -d "${HOME}/.fzf" ]; then
  echo " ==> Installing fzf"
  git clone https://github.com/junegunn/fzf "${HOME}/.fzf"
  pushd "${HOME}/.fzf"
  git remote set-url origin git@github.com:junegunn/fzf.git 
  ${HOME}/.fzf/install --bin --64 --no-bash --no-zsh --no-fish
  popd
fi

if [ ! -d "${HOME}/.zsh" ]; then
  echo " ==> Installing zsh plugins"
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${HOME}/.zsh/zsh-syntax-highlighting"
  git clone https://github.com/zsh-users/zsh-autosuggestions "${HOME}/.zsh/zsh-autosuggestions"
fi

if [ ! -d "${HOME}/.tmux/plugins" ]; then
  echo " ==> Installing tmux plugins"
  git clone https://github.com/tmux-plugins/tpm "${HOME}/.tmux/plugins/tpm"
  git clone https://github.com/tmux-plugins/tmux-open.git "${HOME}/.tmux/plugins/tmux-open"
  git clone https://github.com/tmux-plugins/tmux-yank.git "${HOME}/.tmux/plugins/tmux-yank"
  git clone https://github.com/tmux-plugins/tmux-prefix-highlight.git "${HOME}/.tmux/plugins/tmux-prefix-highlight"
fi

echo "==> Setting shell to zsh..."
chsh -s /usr/bin/zsh

echo "==> Setting up mount"
VOLUME_NAME=$(find /dev/disk/by-id/ -path "*/scsi-0DO_Volume_dev*" -fstype devtmpfs)
if [ -z "${VOLUME_NAME}" ]; then
  echo "==> Missing dev disk. Disks present:"
  ls -l /dev/disk/by-id/
  exit 1
fi

blkid "$VOLUME_NAME" || mkfs.ext4 "$VOLUME_NAME"

DEV_DATA_DIR="/mnt/dev"
if ! mountpoint -q "$DEV_DATA_DIR"; then
  echo "==> Mounting volume $VOLUME_NAME to dev data dir $DEV_DATA_DIR"
  # mount dev data
  mkdir -p "$DEV_DATA_DIR"
  mount -o discard,defaults,noatime "$VOLUME_NAME" "$DEV_DATA_DIR"
fi

# make it mountable in case the droplet is rebooted
if ! grep -qF "$DEV_DATA_DIR" /etc/fstab; then
  echo "$VOLUME_NAME $DEV_DATA_DIR ext4 defaults,nofail,noatime,discard 0 0" | sudo tee -a /etc/fstab
fi

echo "==> Creating dev directories"
mkdir -p /mnt/dev/code

if [ ! -d /mnt/dev/code/dotfiles ]; then
  echo "==> Setting up dotfiles"
  # the reason we dont't copy the files individually is, to easily push changes
  # if needed
  cd "/mnt/dev/code"
  git clone --recursive https://github.com/YosubShin/dotfiles.git

  cd "/mnt/dev/code/dotfiles"
  git remote set-url origin git@github.com:YosubShin/dotfiles.git

  ln -sfn $(pwd)/zshrc "${HOME}/.zshrc"
  ln -sfn $(pwd)/gitconfig "${HOME}/.gitconfig"
  ln -sfn $(pwd)/sshconfig "${HOME}/.ssh/config"
fi

# Set correct timezone
timedatectl set-timezone America/Los_Angeles

echo ""
echo "==> Done!"
