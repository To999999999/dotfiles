#!/bin/sh

WG="/run/current-system/sw/bin/wg"
WG_QUICK="/run/current-system/sw/bin/wg-quick"

is_connected() {
    sudo -n "$WG" show 2>/dev/null | grep -q '^interface:'
}

show_info() {
    INFO="$(sudo "$WG" show)"

    osascript <<EOF
display dialog "$INFO" buttons {"OK"} default button "OK" with title "WireGuard Info"
EOF
}

case "$1" in
    toggle)
        if is_connected; then
            sudo "$WG_QUICK" down wg0
        else
            sudo "$WG_QUICK" up wg0
        fi
        exit 0
        ;;

    info)
        show_info
        exit 0
        ;;
esac

if is_connected; then
    echo ":house.fill: | symbolize=true size=15"
    echo "---"
    echo "Disconnect | bash=$0 param0=toggle terminal=false refresh=true"
else
    echo ":house.slash.fill: | symbolize=true size=15"
    echo "---"
    echo "Connect | bash=$0 param0=toggle terminal=false refresh=true"
fi

echo "Infos | bash=$0 param0=info terminal=false refresh=false"
echo "---"
echo "Refresh | refresh=true"
