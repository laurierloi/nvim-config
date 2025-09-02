#!/usr/bin/env bash
#!/usr/bin/env bash
set -e

# Configurable Python version (default 3.10)
PYTHON_VERSION="${PYTHON_VERSION:-3.10}"

echo ">>> Updating system packages..."
sudo apt update -y

echo ">>> Installing base dependencies..."
sudo apt install -y \
  curl git unzip build-essential pkg-config \
  ninja-build gettext cmake \
  ripgrep fd-find tig \
  luarocks \
  composer \
  python${PYTHON_VERSION} python${PYTHON_VERSION}-venv python${PYTHON_VERSION}-dev \
  python3-pip


echo ">>> Installing latest neo vim"
git clone https://github.com/neovim/neovim /tmp/neovim
cd /tmp/neovim
git checkout stable
make CMAKE_BUILD_TYPE=RelWithDebInfo
sudo make install
echo 'export PATH="/usr/local/bin:$PATH"' >> ~/.bashrc
export PATH="/usr/local/bin:$PATH"
cd -

echo ">>> Installing NVM (Node Version Manager)..."
if [ ! -d "$HOME/.nvm" ]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
fi
export NVM_DIR="$HOME/.nvm"
# shellcheck disable=SC1090
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

echo ">>> Installing latest Node.js with nvm..."
nvm install node
nvm use node
nvm alias default node

echo ">>> Installing Rust via rustup..."
if ! command -v rustup &> /dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
fi
rustup install stable
rustup default stable

echo ">>> Setting up Neovim config..."
mkdir -p ~/.config/nvim
ln -sf "$PWD/init.lua" ~/.config/nvim/init.lua

echo ">>> Installing LSP servers..."

# Python LSP
pip3 install --user 'python-lsp-server[all]'
pip3 install --user ruff
pip3 install --user yamllint

# TypeScript / JavaScript / Vue (Volar)
npm install -g typescript typescript-language-server @vue/language-server

# Rust Analyzer (ensure latest from rustup component)
rustup component add rust-analyzer || cargo install rust-analyzer

# Various npm dependencies
npm install -g \
    bash-language-server \
    lua-fmt \
    stylua \
    eslint \
    jsregexp \
    neovim \
    Copilot-cli \
    markdownlint-cli2 \
    vscode-langservers-extracted

echo ">>> Installing Terraform tools..."
if ! command -v terraform &> /dev/null; then
  sudo snap install terraform --classic
fi

if ! command -v tflint &> /dev/null; then
  sudo snap install tflint --classic
fi
pip3 install --user checkov

echo ">>> Installing tree-sitter CLI..."
cargo install tree-sitter-cli
cargo install selene

echo ">>> Installing latest GHDL..."
if ! command -v ghdl &> /dev/null; then
  sudo apt install -y gnat llvm clang make zlib1g-dev
  git clone https://github.com/ghdl/ghdl.git /tmp/ghdl
  cd /tmp/ghdl
  ./configure --prefix=$HOME/.local --with-llvm-config
  make -j$(nproc)
  make install
  cd -
  rm -rf /tmp/ghdl
fi

echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
echo 'alias vim="nvim"' >> ~/.bashrc

echo ">>> Done!"
echo "Next steps:"
echo "  1. Restart your shell so nvm and rustup are loaded everywhere"
echo "  2. Open nvim and run :Mason to verify LSP servers"
echo "  3. Enjoy 🚀"
