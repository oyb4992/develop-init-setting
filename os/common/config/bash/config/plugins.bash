for bash_completion_file in \
  /opt/homebrew/etc/profile.d/bash_completion.sh \
  /opt/homebrew/etc/bash_completion \
  /usr/local/etc/profile.d/bash_completion.sh \
  /usr/local/etc/bash_completion \
  /usr/share/bash-completion/bash_completion \
  /etc/bash_completion; do
  if [[ -r "$bash_completion_file" ]]; then
    source "$bash_completion_file"
    break
  fi
done
unset bash_completion_file

if [[ -n "${BLE_VERSION:-}" ]] && command -v fzf >/dev/null 2>&1; then
  ble-import -d integration/fzf-completion
  ble-import -d integration/fzf-key-bindings
fi
