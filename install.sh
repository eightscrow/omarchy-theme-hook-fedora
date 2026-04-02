#!/bin/bash

set -e

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

# Returns 0 if both adw-gtk3 and adw-gtk3-dark themes are present
adw_gtk3_present() {
    { [[ -d "$HOME/.local/share/themes/adw-gtk3" ]] && [[ -d "$HOME/.local/share/themes/adw-gtk3-dark" ]]; } ||
    { [[ -d "/usr/share/themes/adw-gtk3" ]] && [[ -d "/usr/share/themes/adw-gtk3-dark" ]]; }
}

qt6ct_present() {
    command -v qt6ct >/dev/null 2>&1
}

xdg_portal_gtk_present() {
    # The portal backend binary is often not in PATH (e.g. /usr/libexec),
    # so detect via package manager first, then known install paths.
    if command -v pacman >/dev/null 2>&1; then
        pacman -Q xdg-desktop-portal-gtk >/dev/null 2>&1 && return 0
    elif command -v dpkg >/dev/null 2>&1; then
        dpkg -s xdg-desktop-portal-gtk >/dev/null 2>&1 && return 0
    elif command -v rpm >/dev/null 2>&1; then
        rpm -q xdg-desktop-portal-gtk >/dev/null 2>&1 && return 0
    fi

    [[ -x /usr/lib/xdg-desktop-portal-gtk ]] && return 0
    [[ -x /usr/libexec/xdg-desktop-portal-gtk ]] && return 0
    [[ -x /usr/lib64/xdg-desktop-portal-gtk ]] && return 0

    return 1
}

install_qt6ct() {
    if qt6ct_present; then
        return 0
    fi

    gum style --border normal --border-foreground 6 --padding "1 2" \
        '"qt6ct" is required to theme Qt6 applications such as qBittorrent.'

    if command -v pacman &>/dev/null; then
        if gum confirm 'Would you like to install "qt6ct" via pacman?'; then
            sudo pacman -S --needed qt6ct
        fi
    elif command -v dnf &>/dev/null; then
        if gum confirm 'Would you like to install "qt6ct" via dnf?'; then
            sudo dnf install -y qt6ct
        fi
    elif command -v apt-get &>/dev/null; then
        if gum confirm 'Would you like to install "qt6ct" via apt?'; then
            sudo apt-get install -y qt6ct
        fi
    fi

    if ! qt6ct_present; then
        echo -e "\e[33m[WARNING]\e[0m qt6ct is not installed. Qt6 apps will be skipped until it is available."
    fi
}

bootstrap_qt6ct() {
    mkdir -p "$HOME/.config/environment.d"
    mkdir -p "$HOME/.config/qt6ct/colors"

    if [[ ! -f "$HOME/.config/environment.d/99-qt6ct.conf" ]]; then
        cat > "$HOME/.config/environment.d/99-qt6ct.conf" << 'EOF'
QT_QPA_PLATFORMTHEME=qt6ct
EOF
    elif ! grep -q '^QT_QPA_PLATFORMTHEME=qt6ct$' "$HOME/.config/environment.d/99-qt6ct.conf"; then
        printf '\nQT_QPA_PLATFORMTHEME=qt6ct\n' >> "$HOME/.config/environment.d/99-qt6ct.conf"
    fi
}

install_xdg_portal_gtk() {
    if xdg_portal_gtk_present; then
        return 0
    fi

    gum style --border normal --border-foreground 6 --padding "1 2" \
        '"xdg-desktop-portal-gtk" is recommended for consistent GTK file dialogs and portal integration.'

    if command -v pacman &>/dev/null; then
        if gum confirm 'Would you like to install "xdg-desktop-portal-gtk" via pacman?'; then
            sudo pacman -S --needed xdg-desktop-portal-gtk
        fi
    elif command -v dnf &>/dev/null; then
        if gum confirm 'Would you like to install "xdg-desktop-portal-gtk" via dnf?'; then
            sudo dnf install -y xdg-desktop-portal-gtk
        fi
    elif command -v apt-get &>/dev/null; then
        if gum confirm 'Would you like to install "xdg-desktop-portal-gtk" via apt?'; then
            sudo apt-get install -y xdg-desktop-portal-gtk
        fi
    elif command -v zypper &>/dev/null; then
        if gum confirm 'Would you like to install "xdg-desktop-portal-gtk" via zypper?'; then
            sudo zypper --non-interactive install xdg-desktop-portal-gtk
        fi
    fi

    if ! xdg_portal_gtk_present; then
        echo -e "\e[33m[WARNING]\e[0m xdg-desktop-portal-gtk is not installed. Some GTK dialogs may not follow theme settings."
    fi
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

install_qt6ct
bootstrap_qt6ct
install_xdg_portal_gtk

# Ensure GTK config dirs and stub files exist (required by 10-gtk.sh on first install)
mkdir -p "$HOME/.config/gtk-3.0" "$HOME/.config/gtk-4.0"
[[ -f "$HOME/.config/gtk-3.0/gtk.css" ]] || touch "$HOME/.config/gtk-3.0/gtk.css"
[[ -f "$HOME/.config/gtk-4.0/gtk.css" ]] || touch "$HOME/.config/gtk-4.0/gtk.css"
[[ -f "$HOME/.config/gtk-3.0/settings.ini" ]] || cat > "$HOME/.config/gtk-3.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=adw-gtk3-dark
gtk-application-prefer-dark-theme=1
EOF
[[ -f "$HOME/.config/gtk-4.0/settings.ini" ]] || cat > "$HOME/.config/gtk-4.0/settings.ini" << 'EOF'
[Settings]
gtk-theme-name=adw-gtk3-dark
gtk-application-prefer-dark-theme=1
EOF

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
