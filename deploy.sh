#!/bin/bash
set -euo pipefail
USAGE=$(cat <<-END
    Usage: ./deploy.sh [OPTIONS] [--aliases <alias1,alias2,...>], eg. ./deploy.sh --vim --aliases=speechmatics,custom
    Creates XDG-compliant symlinks for dotfiles:
    - ~/.zshenv (XDG bootstrap)
    - ~/.config/zsh/.zshrc (main zsh config)
    - ~/.config/zsh/.p10k.zsh (powerlevel10k theme)
    - ~/.tmux.conf (tmux config)

    OPTIONS:
        --vim                   deploy vimrc config symlink
        --aliases               specify additional alias scripts to source in .zshrc, separated by commas
END
)

export DOT_DIR=$(dirname $(realpath $0))

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

# Create XDG directories
mkdir -p $HOME/.config/zsh

# XDG Bootstrap - symlink ~/.zshenv
echo "Creating symlink: ~/.zshenv -> $DOT_DIR/config/zshenv"
ln -sf $DOT_DIR/config/zshenv $HOME/.zshenv

# Zsh setup - symlink to ~/.config/zsh/
echo "Creating symlink: ~/.config/zsh/.zshrc -> $DOT_DIR/config/zshrc"
ln -sf $DOT_DIR/config/zshrc $HOME/.config/zsh/.zshrc

echo "Creating symlink: ~/.config/zsh/.p10k.zsh -> $DOT_DIR/config/p10k.zsh"
ln -sf $DOT_DIR/config/p10k.zsh $HOME/.config/zsh/.p10k.zsh

# Handle additional aliases if specified
if [ -n "${ALIASES+x}" ] && [ ${#ALIASES[@]} -gt 0 ]; then
    # Create a supplemental config file for additional aliases
    EXTRA_ALIASES_FILE="$HOME/.config/zsh/.zshrc_aliases"
    echo "# Additional aliases sourced by deploy.sh" > $EXTRA_ALIASES_FILE
    for alias in "${ALIASES[@]}"; do
        echo "source $DOT_DIR/config/aliases_${alias}.sh" >> $EXTRA_ALIASES_FILE
    done
    # Add source line to main zshrc if not already present
    if ! grep -q "source.*\.zshrc_aliases" $HOME/.config/zsh/.zshrc 2>/dev/null; then
        echo "[[ -f \$HOME/.config/zsh/.zshrc_aliases ]] && source \$HOME/.config/zsh/.zshrc_aliases" >> $HOME/.config/zsh/.zshrc
    fi
fi

# Tmux setup
echo "Creating symlink: ~/.tmux.conf -> $DOT_DIR/config/tmux.conf"
ln -sf $DOT_DIR/config/tmux.conf $HOME/.tmux.conf

# Vimrc
if [[ $VIM == "true" ]]; then
    echo "Creating symlink: ~/.vimrc -> $DOT_DIR/config/vimrc"
    ln -sf $DOT_DIR/config/vimrc $HOME/.vimrc
fi

echo "changing default shell to zsh"
chsh -s $(which zsh)

zsh
