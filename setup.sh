#!/bin/bash
local_folder="$HOME/.local"
download_folder="$local_folder/downloads"
bin_folder="$local_folder/bin"
temp_folder="$local_folder/temp"

function MK {
  mkdir -p "$1"
}

function Setup {
  MK $local_folder
  MK $bin_folder
  MK $download_folder
  MK $temp_folder
}

function WGET {
  wget -q --show-progress -O "$1" "$2"
}

function DPKG {
  dpkg --vextract "$1" "$2" >/dev/null 2>&1
}

function TAR {
  tar -xf "$1" -C "$2" --checkpoint=.1000
}

function CP {
  cp -fr $@
}

function RM {
  rm -rf "$1"
}

function ECHO {
  echo -ne "$1"
}

function ICO {
  desktop-file-install --dir=$HOME/.local/share/applications "$HOME/.local/share/applications/$1"
}

function Slack {
  ECHO "Downloading Slack...\n"
  WGET "$download_folder/slack.deb" 'https://downloads.slack-edge.com/linux_releases/slack-desktop-2.8.2-amd64.deb'
  ECHO "Extracting Slack...\n"
  DPKG "$download_folder/slack.deb" "$temp_folder/slack"
  ECHO "Installing Slack...\n"
  CP   $temp_folder/slack/usr/* $local_folder
  cat << EOF > $HOME/.local/share/applications/slack.desktop
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Application
Name=Slack
Icon=$HOME/.local/share/pixmaps/slack.png
Path=$HOME/.local
Exec=$HOME/.local/bin/slack
OnlyShowIn=Unity;
EOF
  ICO "slack.desktop"
  ECHO "Deleting temp files\n"
  RM   "$temp_folder/slack"
  RM   "$download_folder/slack.deb"
  slack </dev/null >/dev/null 2>&1 &
  ECHO "Slack installed!\n"
}

function VSCode {
  ECHO "Downloading VSCode..."
  WGET "$download_folder/vscode.deb" 'https://go.microsoft.com/fwlink/?LinkID=760868'
  ECHO "Extracting VSCode..."
  DPKG "$download_folder/vscode.deb" "$temp_folder/vscode"
  ECHO "Installing VSCode...\n"
  CP   $temp_folder/vscode/usr/* $local_folder
  ln -s $local_folder/share/code/code $bin_folder/code

  # create .desktop
  cat << EOF > $HOME/.local/share/applications/code.desktop
  [Desktop Entry]
  Name=Visual Studio Code
  Comment=Code Editing. Redefined.
  GenericName=Text Editor
  Exec=$HOME/.local/share/code/code --unity-launch %F
  Icon=$HOME/.local/share/pixmaps/code.png
  Type=Application
  StartupNotify=true
  StartupWMClass=Code
  Categories=Utility;TextEditor;Development;IDE;
  MimeType=text/plain;inode/directory;
  Actions=new-window;
  Keywords=vscode;

  [Desktop Action new-window]
  Name=New Window
  Name[de]=Neues Fenster
  Name[es]=Nueva ventana
  Name[fr]=Nouvelle fenêtre
  Name[it]=Nuova finestra
  Name[ja]=新規ウインドウ
  Name[ko]=새 창
  Name[ru]=Новое окно
  Name[zh_CN]=新建窗口
  Name[zh_TW]=開新視窗
  Exec=$HOME/.local/share/code/code --new-window %F
  Icon=$HOME/.local/share/pixmaps/code.png
EOF

  ICO "code.desktop"
  ECHO "Deleting temp files\n"
  RM   "$temp_folder/vscode"
  RM   "$download_folder/vscode.deb"
  code </dev/null >/dev/null 2>&1 &
  ECHO "VSCode installed!\n"
}

function Telegram {
  ECHO "Dowloading Telegram\n"
  WGET "$download_folder/telegram.tar" "https://telegram.org/dl/desktop/linux"
  
  ECHO "Extracting Telegram..."
  MK "$temp_folder/telegram"
  TAR "$download_folder/telegram.tar" "$temp_folder/telegram"
  ECHO "\n"
  
  ECHO "Installing Telegram\n"
  mv $temp_folder/telegram/* $local_folder/share/telegram
  ln -sf $local_folder/share/telegram/Telegram $bin_folder/telegram
  
  ECHO "Deleting temp files\n"
  RM "$download_folder/telegram.tar"
  RM "$temp_folder/telegram"
  
  telegram </dev/null >/dev/null 2>&1 &
  
  ECHO "Telegram installed\n"
}

apps=("Slack" "VSCode" "Telegram" "exit")

function PrintOpts {
  for i in "${!apps[@]}"; do
      ECHO "$i ${apps[$i]}\n"
  done
}

function Main {
  Setup
  while true; do
    PrintOpts
    read -p "Enter command: " cmd
    ${apps[$cmd]}
  done
}

Main
