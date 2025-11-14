#!/bin/bash
set -euo pipefail
USAGE=$(cat <<-END
    Usage: ./deploy.sh [OPTIONS] [--aliases <alias1,alias2,...>], eg. ./deploy.sh --vim --aliases=speechmatics,custom
    Creates XDG-compliant symlinks for dotfiles to persistent directory (default: /scratch/chloeloughridge):
    - PERSIST_DIR/.zshenv (XDG bootstrap)
    - PERSIST_DIR/.config/zsh/.zshrc (main zsh config)
    - PERSIST_DIR/.config/zsh/.p10k.zsh (powerlevel10k theme)
    - PERSIST_DIR/.tmux.conf (tmux config)

    If PERSIST_DIR != HOME, also creates symlinks from HOME to PERSIST_DIR locations.

    OPTIONS:
        --vim                   deploy vimrc config symlink
        --aliases               specify additional alias scripts to source in .zshrc, separated by commas

    ENVIRONMENT:
        PERSIST_DIR             override persistent directory (default: /scratch/chloeloughridge)
END
)

export DOT_DIR=$(dirname $(realpath $0))

# Set persistent directory (default to HOME, can be overridden)
PERSIST_DIR="${PERSIST_DIR:-/scratch/chloeloughridge}"

VIM="false"
ALIASES=()
while (( "$#" )); do
    case "$1" in
        -h|--help)
            echo "$USAGE" && exit 1 ;;
        --vim)
            VIM="true" && shift ;;
        --aliases=*)
            IFS=',' read -r -a ALIASES <<< "${1#*=}" && shift ;;
        --) # end argument parsing
            shift && break ;;
        -*|--*=) # unsupported flags
            echo "Error: Unsupported flag $1" >&2 && exit 1 ;;
    esac
done

echo "deploying XDG-compliant dotfiles..."
echo "using extra aliases: ${ALIASES[@]}"
echo "using persistent directory: $PERSIST_DIR"

# Create XDG directories in persistent location
mkdir -p $PERSIST_DIR/.config/zsh

# XDG Bootstrap - symlink to persistent directory
echo "Creating symlink: $PERSIST_DIR/.zshenv -> $DOT_DIR/config/zshenv"
ln -sf $DOT_DIR/config/zshenv $PERSIST_DIR/.zshenv

# Link from HOME to persistent directory if they're different
if [ "$PERSIST_DIR" != "$HOME" ]; then
    echo "Creating symlink: $HOME/.zshenv -> $PERSIST_DIR/.zshenv"
    ln -sf $PERSIST_DIR/.zshenv $HOME/.zshenv
fi

# Zsh setup - symlink to persistent directory
echo "Creating symlink: $PERSIST_DIR/.config/zsh/.zshrc -> $DOT_DIR/config/zshrc"
ln -sf $DOT_DIR/config/zshrc $PERSIST_DIR/.config/zsh/.zshrc

echo "Creating symlink: $PERSIST_DIR/.config/zsh/.p10k.zsh -> $DOT_DIR/config/p10k.zsh"
ln -sf $DOT_DIR/config/p10k.zsh $PERSIST_DIR/.config/zsh/.p10k.zsh

# Link from HOME to persistent directory if they're different
if [ "$PERSIST_DIR" != "$HOME" ]; then
    echo "Creating symlink: $HOME/.config/zsh -> $PERSIST_DIR/.config/zsh"
    mkdir -p $HOME/.config
    ln -sf $PERSIST_DIR/.config/zsh $HOME/.config/zsh
fi

# Handle additional aliases if specified
if [ -n "${ALIASES+x}" ] && [ ${#ALIASES[@]} -gt 0 ]; then
    # Create a supplemental config file for additional aliases
    EXTRA_ALIASES_FILE="$PERSIST_DIR/.config/zsh/.zshrc_aliases"
    echo "# Additional aliases sourced by deploy.sh" > $EXTRA_ALIASES_FILE
    for alias in "${ALIASES[@]}"; do
        echo "source $DOT_DIR/config/aliases_${alias}.sh" >> $EXTRA_ALIASES_FILE
    done
    # Add source line to main zshrc if not already present
    if ! grep -q "source.*\.zshrc_aliases" $PERSIST_DIR/.config/zsh/.zshrc 2>/dev/null; then
        echo "[[ -f \$HOME/.config/zsh/.zshrc_aliases ]] && source \$HOME/.config/zsh/.zshrc_aliases" >> $PERSIST_DIR/.config/zsh/.zshrc
    fi
fi

# Tmux setup - symlink to persistent directory
echo "Creating symlink: $PERSIST_DIR/.tmux.conf -> $DOT_DIR/config/tmux.conf"
ln -sf $DOT_DIR/config/tmux.conf $PERSIST_DIR/.tmux.conf

# Link from HOME to persistent directory if they're different
if [ "$PERSIST_DIR" != "$HOME" ]; then
    echo "Creating symlink: $HOME/.tmux.conf -> $PERSIST_DIR/.tmux.conf"
    ln -sf $PERSIST_DIR/.tmux.conf $HOME/.tmux.conf
fi

# Vimrc
if [[ $VIM == "true" ]]; then
    echo "Creating symlink: $PERSIST_DIR/.vimrc -> $DOT_DIR/config/vimrc"
    ln -sf $DOT_DIR/config/vimrc $PERSIST_DIR/.vimrc

    # Link from HOME to persistent directory if they're different
    if [ "$PERSIST_DIR" != "$HOME" ]; then
        echo "Creating symlink: $HOME/.vimrc -> $PERSIST_DIR/.vimrc"
        ln -sf $PERSIST_DIR/.vimrc $HOME/.vimrc
    fi
fi

# Bash configs (for auto-launching zsh)
echo "Creating .bashrc in persistent directory"
cat > $PERSIST_DIR/.bashrc << 'BASHRC_EOF'
# Auto-launch zsh if it's installed and we're in an interactive shell
if [ -t 1 ] && command -v zsh >/dev/null 2>&1; then
    # Check if we're not already running zsh (prevent infinite loop)
    if [ -z "$ZSH_VERSION" ]; then
        export SHELL=$(which zsh)
        exec zsh
    fi
fi
BASHRC_EOF

echo "Creating .bash_profile in persistent directory"
cat > $PERSIST_DIR/.bash_profile << 'BASH_PROFILE_EOF'
# Source .bashrc if it exists
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
BASH_PROFILE_EOF

# Create .profile (symlink to .bash_profile for login shells)
ln -sf $PERSIST_DIR/.bash_profile $PERSIST_DIR/.profile

# Link from HOME to persistent directory if they're different
if [ "$PERSIST_DIR" != "$HOME" ]; then
    echo "Creating symlink: $HOME/.bashrc -> $PERSIST_DIR/.bashrc"
    ln -sf $PERSIST_DIR/.bashrc $HOME/.bashrc
    echo "Creating symlink: $HOME/.bash_profile -> $PERSIST_DIR/.bash_profile"
    ln -sf $PERSIST_DIR/.bash_profile $HOME/.bash_profile
    echo "Creating symlink: $HOME/.profile -> $PERSIST_DIR/.profile"
    ln -sf $PERSIST_DIR/.profile $HOME/.profile

    # Link git directory to persistent storage
    echo "Creating symlink: $HOME/git -> $PERSIST_DIR/git"
    mkdir -p $PERSIST_DIR/git
    ln -sf $PERSIST_DIR/git $HOME/git

    # Link CLAUDE.md to home directory
    if [ -f "$PERSIST_DIR/CLAUDE.md" ]; then
        echo "Creating symlink: $HOME/CLAUDE.md -> $PERSIST_DIR/CLAUDE.md"
        ln -sf $PERSIST_DIR/CLAUDE.md $HOME/CLAUDE.md
    fi
fi

echo "changing default shell to zsh"
chsh -s $(which zsh)

zsh
