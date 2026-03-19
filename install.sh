#!/bin/bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Returns 0 if both adw-gtk3 and adw-gtk3-dark themes are present
adw_gtk3_present() {
    { [[ -d "$HOME/.local/share/themes/adw-gtk3" ]] && [[ -d "$HOME/.local/share/themes/adw-gtk3-dark" ]]; } ||
    { [[ -d "/usr/share/themes/adw-gtk3" ]] && [[ -d "/usr/share/themes/adw-gtk3-dark" ]]; }
}

# Install prerequisites
if ! adw_gtk3_present; then
    gum style --border normal --border-foreground 6 --padding "1 2" \
        '"adw-gtk3" is required to theme GTK applications.'

    if command -v pacman &>/dev/null; then
        if gum confirm 'Would you like to install "adw-gtk-theme" via pacman?'; then
            sudo pacman -S adw-gtk-theme
        fi
    elif command -v dnf &>/dev/null; then
        if gum confirm 'Would you like to install "adw-gtk3-theme" via dnf?'; then
            sudo dnf install -y adw-gtk3-theme
        fi
    elif command -v apt-get &>/dev/null; then
        if gum confirm 'Would you like to install "adw-gtk3" via apt?'; then
            sudo apt-get install -y adw-gtk3
        fi
    fi

    # Universal fallback: download latest release from GitHub
    if ! adw_gtk3_present; then
        if gum confirm 'Would you like to download "adw-gtk3" from GitHub releases?'; then
            latest_url=$(curl -fsSL https://api.github.com/repos/lassekongo83/adw-gtk3/releases/latest \
                | grep '"browser_download_url"' | grep '\.tar\.xz' | head -1 | cut -d '"' -f 4)
            tmpdir=$(mktemp -d)
            echo "Downloading adw-gtk3..."
            curl -fsSL "$latest_url" -o "$tmpdir/adw-gtk3.tar.xz"
            mkdir -p "$HOME/.local/share/themes"
            tar -xf "$tmpdir/adw-gtk3.tar.xz" -C "$HOME/.local/share/themes"
            rm -rf "$tmpdir"
        fi
    fi

    if ! adw_gtk3_present; then
        echo -e "\e[31m[ERROR]\e[0m adw-gtk3 theme is required. Aborting."
        exit 1
    fi
fi

# Ensure GTK config dirs and stub CSS files exist (required by 10-gtk.sh on first install)
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
[[ -f "$HOME/.config/gtk-3.0/gtk.css" ]] || touch "$HOME/.config/gtk-3.0/gtk.css"
[[ -f "$HOME/.config/gtk-4.0/gtk.css" ]] || touch "$HOME/.config/gtk-4.0/gtk.css"

# Ensure target directories exist
mkdir -p "$HOME/.local/share/omarchy/bin"
mkdir -p "$HOME/.config/omarchy/hooks/theme-set.d"

# Remove any old update alias
rm -rf "$HOME/.local/share/omarchy/bin/theme-hook-update"

# Install theme control utility
cp -f "$SCRIPT_DIR/thctl" "$HOME/.local/share/omarchy/bin/thctl"
chmod +x "$HOME/.local/share/omarchy/bin/thctl"

# Create symlink in ~/.local/bin so thctl is on PATH
mkdir -p "$HOME/.local/bin"
ln -sf "$HOME/.local/share/omarchy/bin/thctl" "$HOME/.local/bin/thctl"

# Install theme-set hook
cp -f "$SCRIPT_DIR/theme-set" "$HOME/.config/omarchy/hooks/theme-set"

# Install hooklets
cp -f "$SCRIPT_DIR/theme-set.d/"* "$HOME/.config/omarchy/hooks/theme-set.d/"

# Update permissions
chmod +x "$HOME/.config/omarchy/hooks/theme-set"
chmod +x "$HOME/.config/omarchy/hooks/theme-set.d/"*

# Apply theme
echo "Running theme hook.."
omarchy-hook theme-set

omarchy-show-done
