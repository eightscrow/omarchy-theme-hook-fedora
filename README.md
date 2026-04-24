
<div align="center">

![Preview](assets/preview.png)

# Omarchy Theme Hook Universal

[![Themed Apps](https://img.shields.io/badge/themed_apps-15-blue?style=for-the-badge&labelColor=0C0D11&color=A5CAB8)](https://github.com/eightscrow/omarchy-theme-hook-fedora/tree/main/theme-set.d)
[![GitHub Issues](https://img.shields.io/github/issues/eightscrow/omarchy-theme-hook-fedora?style=for-the-badge&labelColor=0C0D11&color=EB7A73)](https://github.com/eightscrow/omarchy-theme-hook-fedora/issues)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/eightscrow/omarchy-theme-hook-fedora?style=for-the-badge&labelColor=0C0D11&color=8ECD84)](https://github.com/eightscrow/omarchy-theme-hook-fedora/commits/main/)

**A lightweight, clean solution to extending your Omarchy theme to other apps.**

> This is a fork of [imbypass/omarchy-theme-hook](https://github.com/imbypass/omarchy-theme-hook) by [@imbypass](https://github.com/imbypass).  
> Full credit for the original concept, architecture, and hooklets goes to the original author.  
> This fork adapts the installer to work on **Fedora-based Omarchy installations** without requiring an Arch Linux package manager.

</div>

## Overview
The Omarchy Theme Hook is a lightweight, clean solution to extending your Omarchy theme to other apps. It will check your Omarchy theme for the existence of any extended theme files and will install them automatically for you when a theme is applied. If a theme is applied that contains extended theme files, they will be copied to their proper folders. If the theme does *not* contain any extended theme files, a new set of each will be generated dynamically using the theme's color config and copied to their proper folders.

## What is different in this fork?
The upstream project targets Arch Linux and uses `pacman` to install the required `adw-gtk-theme` dependency. This fork replaces that with a distro-aware installer:

1. **Fedora / RPM-based**: installs `adw-gtk3-theme`, `qt6ct`, and `kvantum` via `dnf`
2. **Debian / Ubuntu-based**: installs `adw-gtk3`, `qt6ct`, and `kvantum` via `apt-get`
3. **Arch-based**: falls back to the original `pacman` path for GTK and installs `qt6ct` plus `kvantum`
4. **openSUSE-based**: installs `xdg-desktop-portal-gtk` via `zypper` when available
5. **Universal fallback**: downloads the latest `adw-gtk3` release tarball from GitHub and installs it to `~/.local/share/themes/` — no root access needed

The installer no longer downloads itself from the internet during installation; it uses the files from the cloned repository directly.
It also bootstraps Qt6 theming by creating a `qt6ct` environment override and default `qt6ct` configuration files so Qt apps consistently pick up Omarchy colors. Kvantum is installed as an available style backend, but it is not globally forced.
For GTK integration, it now also ensures `xdg-desktop-portal-gtk` is present when possible and writes `~/.config/gtk-3.0/settings.ini` plus `~/.config/gtk-4.0/settings.ini` so native file pickers follow dark/light mode reliably.

## Installing
Clone this repository and run the installer:
```bash
git clone https://github.com/eightscrow/Omarchy-Theme-Hook-Universal.git /tmp/Omarchy-Theme-Hook-Universal
bash /tmp/Omarchy-Theme-Hook-Universal/install.sh
rm -rf /tmp/Omarchy-Theme-Hook-Universal
```


> Qt6 applications may require a new login or a full reboot after install or update.
> The installer writes `QT_QPA_PLATFORMTHEME=qt6ct`, but your current desktop session may not pick up that environment change until the next session starts.

## Updating
You can update the theme hook by running the following command, or by re-running the installation script:
```bash
thctl update
```

## Theme Hook Controller (`thctl`)
The Theme Hook Controller (`thctl`) is a command-line tool that allows you to manage your Theme Hook installation. It provides a simple interface for updating the hook as well as toggling hooklettes on and off.
You can access it via the terminal by running `thctl`.

## Themed Apps
- Cava
- Cursor
- Discord
- Firefox
- GTK (requires `adw-gtk3`; installer also configures `settings.ini` for GTK3/GTK4 and attempts to install `xdg-desktop-portal-gtk`)
- QT6 (via `qt6ct` + `kvantum`, including apps such as qBittorrent)
- Kvantum
- Spotify
- Steam
- Superfile
- Vicinae
- VS Code
- Waybar
- Windsurf
- Zed
- Zen Browser (experimental - requires manual enabling of legacy userchrome styling)

## Uninstalling
```bash
thctl uninstall
```

## FAQ

#### I installed the hook, but none of my apps are theming!
1. The theme hook will generate and install themes, but cannot apply all of them.
2. You may need to manually set the theme to "Omarchy" one time for each app that supports theming.
3. Qt6 applications may require a new login or reboot after install so `QT_QPA_PLATFORMTHEME=qt6ct` is present in the session.

#### qBittorrent still does not match the theme after install/update!
1. Make sure `qt6ct` and `kvantum` were installed successfully.
2. Fully close qBittorrent and start it again as a new process.
3. If it still does not change, log out and back in or reboot so the Qt environment variables are loaded into your desktop session.

#### My Firefox/Zen Browser isn't theming!
- Firefox and Zen Browser may require manual enabling of legacy userchrome styling.
- To do this, open the browser, go to `about:config`, search for `toolkit.legacyUserProfileCustomizations.stylesheets`, and set it to `true`.

#### My Discord isn't theming!
1. Make sure you are using a third-party Discord client, like Vesktop or Equibop.
2. Apply your desired theme in Omarchy.
3. Enable the Omarchy theme in Discord.

#### My Spotify isn't theming!
1. Make sure that you *properly* installed Spicetify, including any permission edits that may need to be made for Linux systems.
2. See a [note for Linux users](https://spicetify.app/docs/advanced-usage/installation#note-for-linux-users).
3. Apply your desired theme in Omarchy.

#### My Spotify stopped theming!
A Spotify client update may have caused Spicetify to stop working. You can fix this by running `spicetify restore backup apply` or by reinstalling Spotify and Spicetify, and running `spicetify backup apply`.

#### I get a "colors.toml not found" error!
Omarchy 3.3+ requires themes to include `colors.toml`. Update your theme to a version compatible with Omarchy 3.3+, or add a valid `colors.toml` file to the theme directory.

#### What if I encounter issues?
If you encounter any issues with this fork, please open an issue at [eightscrow/omarchy-theme-hook-fedora](https://github.com/eightscrow/omarchy-theme-hook-fedora/issues).  
For issues unrelated to the Fedora/installer changes, consider also checking the [upstream issue tracker](https://github.com/imbypass/omarchy-theme-hook/issues).

## Credits
This fork is based on [imbypass/omarchy-theme-hook](https://github.com/imbypass/omarchy-theme-hook).  
All original work, including the hook architecture, hooklet scripts, and `thctl` controller, is the work of [@imbypass](https://github.com/imbypass).  
This fork contributes only the cross-distro installer compatibility layer.

## Contributing
Contributions are welcome. If you have improvements to the Fedora compatibility layer or additional hooklets, please open a pull request at [eightscrow/omarchy-theme-hook-fedora](https://github.com/eightscrow/omarchy-theme-hook-fedora).  
For application-specific hooklet contributions, consider contributing upstream to [imbypass/omarchy-theme-hook](https://github.com/imbypass/omarchy-theme-hook) as well.
