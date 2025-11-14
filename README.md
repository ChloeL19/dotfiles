# Dotfiles - Persistent Configuration Setup

ZSH, Tmux, Vim, and shell setup with persistent storage configured for `/scratch/chloeloughridge/`.

## Quick Start (Most Common Use Case)

```bash
# Clone the repo
git clone <repo-url> /scratch/chloeloughridge/git/dotfiles
cd /scratch/chloeloughridge/git/dotfiles

# Install zsh and dependencies
./install.sh --zsh

# Deploy all configs with vim support (recommended)
./deploy.sh --vim

# Start using zsh
zsh
```

That's it! Your shell is now fully configured with persistence.

---

## What This Setup Provides

### Installed Software
- **Zsh** with oh-my-zsh framework
- **Powerlevel10k** theme with custom configuration
- **Zsh plugins**: autosuggestions, syntax-highlighting, completions, history-substring-search
- **Tmux** with custom theme
- **Vim** with basic configuration
- **Custom bins**: tsesh, twin, rl, yk (in `custom_bins/`)
- **System tools**: jq, ncdu, nvtop, htop, lsof, rsync, nano, less

### Auto-Configured Features
- ✅ **Persistent storage**: All configs symlinked to `/scratch/chloeloughridge/`
- ✅ **Auto-launch Zsh**: Bash automatically launches zsh on startup
- ✅ **API keys exported**: WANDB and HuggingFace tokens
- ✅ **Git directory**: `~/git` symlinked to persistent storage
- ✅ **CLAUDE.md**: Symlinked to home directory for easy access
- ✅ **XDG-compliant**: Configs stored in `~/.config/zsh/`
- ✅ **Claude Code compatible**: Works seamlessly with Anthropic's Claude CLI tool

### Environment Variables
The following are automatically exported on shell startup:
- `WANDB_API_KEY`: Weights & Biases authentication
- `HF_TOKEN`: HuggingFace Hub authentication

---

## Installation Details

### Prerequisites
- Linux system (tested on Ubuntu 22.04)
- Access to `/scratch/chloeloughridge/` directory for persistent storage
- Sudo privileges for installing packages

### Step 1: Install Dependencies

```bash
./install.sh [OPTIONS]
```

**Options:**
- `--zsh`: Install zsh shell
- `--tmux`: Install tmux
- `--extras`: Install additional tools (ripgrep, dust, jless, code2prompt, peco, shell-ask)
- `--force`: Force reinstall oh-my-zsh and plugins

**What it installs:**
1. Zsh shell (if specified)
2. System tools: jq, ncdu, nvtop, htop, lsof, rsync, nano, less
3. UV package manager
4. Oh-my-zsh framework
5. Powerlevel10k theme
6. Zsh plugins (autosuggestions, syntax-highlighting, completions, history-substring-search)
7. Tmux themepack

**Where things are installed:**
- Oh-my-zsh → `/scratch/chloeloughridge/.config/zsh/ohmyzsh/`
- Tmux themepack → `/scratch/chloeloughridge/.tmux-themepack/`
- UV → `~/.local/bin/`

### Step 2: Deploy Configuration

```bash
./deploy.sh [OPTIONS]
```

**Options:**
- `--vim`: Deploy vimrc configuration
- `--aliases=<name1,name2>`: Source additional alias files (e.g., `--aliases=speechmatics`)

**Environment Variables:**
- `PERSIST_DIR`: Override persistent directory (default: `/scratch/chloeloughridge`)

**What it does:**
1. Creates persistent storage structure in `/scratch/chloeloughridge/`
2. Symlinks all configs to persistent directory
3. Symlinks from `$HOME` to persistent configs
4. Creates `.bashrc`, `.bash_profile`, `.profile` for auto-launching zsh
5. Symlinks `~/git` to persistent storage
6. Symlinks `~/CLAUDE.md` (if exists) to persistent storage

---

## File Structure After Installation

```
/scratch/chloeloughridge/
├── git/
│   └── dotfiles/          # This repo
├── .config/
│   └── zsh/
│       ├── .zshrc → dotfiles/config/zshrc
│       ├── .p10k.zsh → dotfiles/config/p10k.zsh
│       └── ohmyzsh/       # Oh-my-zsh installation
├── .zshenv → dotfiles/config/zshenv
├── .bashrc                # Auto-launches zsh
├── .bash_profile          # Sources .bashrc
├── .profile → .bash_profile
├── .tmux.conf → dotfiles/config/tmux.conf
├── .tmux-themepack/       # Tmux themes
├── .vimrc → dotfiles/config/vimrc (if --vim used)
└── CLAUDE.md              # Documentation

/home/ubuntu/
├── .zshenv → /scratch/chloeloughridge/.zshenv
├── .bashrc → /scratch/chloeloughridge/.bashrc
├── .bash_profile → /scratch/chloeloughridge/.bash_profile
├── .profile → /scratch/chloeloughridge/.profile
├── .config/zsh → /scratch/chloeloughridge/.config/zsh
├── .tmux.conf → /scratch/chloeloughridge/.tmux.conf
├── .vimrc → /scratch/chloeloughridge/.vimrc
├── git → /scratch/chloeloughridge/git
└── CLAUDE.md → /scratch/chloeloughridge/CLAUDE.md
```

---

## Key Modifications from Standard Dotfiles

### 1. Persistent Storage (deploy.sh)
- Default `PERSIST_DIR=/scratch/chloeloughridge`
- All configs stored in persistent directory
- Symlinks from `$HOME` to persistent locations
- Survives instance reboots/rebuilds

### 2. Auto-Launch Zsh (deploy.sh)
- `.bashrc` automatically execs zsh when bash starts
- Works for SSH, new terminals, and interactive shells
- Prevents infinite loops with safety checks

### 3. Conditional File Sourcing (config/zshenv, config/zshrc)
- All optional dependencies checked before sourcing
- No errors if cargo, brew, uv, or other tools not installed
- Gracefully skips missing files

### 4. API Key Exports (config/zshrc)
- `WANDB_API_KEY` and `HF_TOKEN` automatically exported
- Available to all scripts and Python environments

### 5. Git Directory Persistence (deploy.sh)
- `~/git` symlinked to `/scratch/chloeloughridge/git`
- All git repos automatically in persistent storage

### 6. Claude Code Compatibility (config/zshrc, config/extras.sh)
- **Instant prompt disabled** for non-interactive shells
- **ASCII art startup** skipped when `CLAUDE_CODE` env var is set
- **Auto-ls on cd** disabled in restricted environments
- **~/.local/bin** added to PATH for Claude CLI access
- Ensures Claude Code can properly initialize terminal without interference

**Important**: These features check for the `CLAUDE_CODE` environment variable. Normal interactive zsh sessions are unaffected.

---

## Configuration Files

### config/zshenv
- XDG base directory specification
- Sets `ZDOTDIR` to `~/.config/zsh`
- Adds `~/.local/bin` to PATH for user-installed binaries (e.g., Claude Code)
- Conditionally sources cargo and homebrew environments

### config/zshrc
- Loads oh-my-zsh and plugins
- Sources aliases, extras, and key bindings
- Exports API keys (WANDB, HuggingFace)
- Configures pyenv, fnm, micromamba (if installed)
- Displays startup banner from `start.txt` (skipped for Claude Code)
- Disables Powerlevel10k instant prompt for non-interactive shells

### config/aliases.sh
- Common shell aliases and shortcuts
- Project-specific aliases

### config/extras.sh
- Additional shell functions and utilities
- Auto-ls on directory change (disabled for Claude Code)
- Extract function for archives
- Git quick commit functions

### config/key_bindings.sh
- Custom zsh key bindings

### config/tmux.conf
- Tmux configuration with custom keybindings

### config/vimrc
- Basic vim configuration

### config/p10k.zsh
- Powerlevel10k theme configuration
- Reconfigure with: `p10k configure`

---

## Customization

### Adding Aliases
Edit `config/aliases.sh` and add your aliases:
```bash
alias myalias='command'
```

### Adding Environment Variables
Edit `config/zshrc` and add exports:
```bash
export MY_VAR="value"
```

### Installing Additional Tools
Edit `install.sh` and add to the package installation section:
```bash
sudo apt-get install -y your-package
```

### Changing Persistent Directory
Set environment variable before deploying:
```bash
PERSIST_DIR=/your/custom/path ./deploy.sh
```

---

## Troubleshooting

### Shell shows "no such file or directory" errors
- All optional dependencies are checked conditionally
- If you see these errors, the config files may need updating
- Check that conditional checks use `-f` for files, `-d` for directories

### Zsh doesn't auto-launch
- Verify `.bashrc` is symlinked: `ls -la ~/.bashrc`
- Check `.bash_profile` and `.profile` exist
- Test manually: `bash -i` should launch zsh

### Oh-my-zsh or plugins missing
- Run `./install.sh --zsh --force` to reinstall
- Check that `/scratch/chloeloughridge/.config/zsh/ohmyzsh/` exists

### Configs don't persist after reboot
- Verify all configs are in `/scratch/chloeloughridge/`
- Check symlinks: `ls -la ~/` should show symlinks to persistent directory
- Ensure `/scratch/chloeloughridge/` is actually persistent storage on your system

### Claude Code doesn't work in zsh
- Verify `~/.local/bin` is in PATH: `echo $PATH | grep local`
- Check Claude is installed: `ls -la ~/.local/bin/claude`
- If "command not found", reload shell: `exec zsh`
- Ensure `config/zshenv` includes PATH export (should be automatic)
- The setup disables Powerlevel10k instant prompt and ASCII art for Claude Code

### Claude Code hangs or shows garbled output
- This was caused by Powerlevel10k instant prompt interfering with terminal initialization
- The fix is already in `config/zshrc:5-7` (checks for interactive shells and `$CLAUDE_CODE` var)
- If still having issues, manually set: `export CLAUDE_CODE=1` before launching

---

## Advanced Usage

### Using Additional Alias Sets
```bash
./deploy.sh --aliases=speechmatics,custom
```

This sources additional alias files from `config/aliases_<name>.sh`

### Reinstalling Everything
```bash
./install.sh --zsh --force
./deploy.sh --vim
```

### Testing in Docker
```bash
docker run -it -v $PWD/runpod/entrypoint.sh:/dotfiles/runpod/entrypoint.sh \
  -e USE_ZSH=true jplhughes1/runpod-dev /bin/zsh
```

### Using with Claude Code
This setup is fully compatible with [Claude Code](https://docs.claude.com/en/docs/claude-code), Anthropic's CLI tool:

```bash
# Install Claude Code (if not already installed)
# Follow instructions at https://docs.claude.com/en/docs/claude-code

# After deploying dotfiles, Claude should be in PATH
claude

# If you get "command not found", reload your shell
exec zsh
```

**How it works**:
- `~/.local/bin` (where Claude installs) is automatically added to PATH in `config/zshenv`
- Powerlevel10k instant prompt is disabled for non-interactive shells to prevent terminal conflicts
- ASCII art and auto-ls features skip execution when `$CLAUDE_CODE` environment variable is detected
- All interactive zsh features remain fully functional in normal terminal sessions

---

## Security Notes

⚠️ **API Keys**: This setup stores API keys in plaintext in `config/zshrc`. Keep your dotfiles repository private if pushing to GitHub or other public locations.

⚠️ **Credentials**: Never commit sensitive credentials to version control. Consider using environment-specific config files outside the repo for production systems.

---

## Maintenance

### Updating Dotfiles
```bash
cd /scratch/chloeloughridge/git/dotfiles
git pull
./deploy.sh --vim  # Reapply symlinks if needed
```

### Updating Oh-My-Zsh
```bash
cd ~/.config/zsh/ohmyzsh
git pull
```

### Updating Plugins
```bash
cd ~/.config/zsh/ohmyzsh/custom/plugins/<plugin-name>
git pull
```

---

## What Makes This Setup Different

This dotfiles repo has been specifically configured for persistent storage setups (like GPU compute instances, RunPod, etc.) where:

1. **Home directory is ephemeral** but `/scratch/` persists
2. **Automatic shell configuration** is desired (auto-launch zsh)
3. **API keys need to be available** without manual setup each time
4. **Git repositories should persist** across instance restarts
5. **No manual intervention** should be needed after initial setup

If you're setting this up on a standard machine where `$HOME` persists normally, you can set `PERSIST_DIR=$HOME` when running `deploy.sh`.

---

## Quick Reference

### Most Common Commands
```bash
# Clone and setup
git clone <repo> /scratch/chloeloughridge/git/dotfiles
cd /scratch/chloeloughridge/git/dotfiles
./install.sh --zsh
./deploy.sh --vim

# Reconfigure powerlevel10k theme
p10k configure

# Reload shell config
exec zsh

# Check what's exported
env | grep -E "WANDB|HF_TOKEN"
```

### File Locations
- **Dotfiles repo**: `/scratch/chloeloughridge/git/dotfiles/`
- **Zsh config**: `~/.config/zsh/.zshrc`
- **Oh-my-zsh**: `~/.config/zsh/ohmyzsh/`
- **Persistent storage**: `/scratch/chloeloughridge/`
- **Custom bins**: `/scratch/chloeloughridge/git/dotfiles/custom_bins/`

### Useful Links
- [Oh My Zsh Documentation](https://github.com/ohmyzsh/ohmyzsh)
- [Powerlevel10k Documentation](https://github.com/romkatv/powerlevel10k)
- [Nerd Fonts (for icons)](https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k)
- [XDG Base Directory Spec](https://wiki.archlinux.org/title/XDG_Base_Directory)
