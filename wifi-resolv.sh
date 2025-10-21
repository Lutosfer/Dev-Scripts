#!/bin/bash

LAST_SSID=""

# Функция для обновления resolv.conf
update_resolv() {
    if [[ "$1" =~ Network ]]; then
        NEW_NS="192.168.1.1"
    else
        NEW_NS="1.1.1.1"
    fi

    if [[ "$(cat /etc/resolv.conf 2>/dev/null)" != "nameserver $NEW_NS" ]]; then
        echo "nameserver $NEW_NS" > /etc/resolv.conf
    fi
}

# Основной цикл: реагируем на изменения соединений через nmcli
nmcli monitor | while read -r line; do
    # Получаем текущий SSID
    CURRENT_SSID=$(iwgetid -r)
    
    # Обновляем только при смене сети
    if [[ "$CURRENT_SSID" != "$LAST_SSID" ]]; then
        update_resolv "$CURRENT_SSID"
        LAST_SSID="$CURRENT_SSID"
    fi
done

