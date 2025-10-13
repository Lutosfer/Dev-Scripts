#!/bin/bash
#
# Мониторинг процесса "test"
# Проверяет каждую минуту:
#  - запущен ли процесс
#  - если да — стучится на https://test.com/monitoring/test/api
#  - если процесс был перезапущен — пишет в лог
#  - если сервер недоступен — пишет в лог

# Конфигурация
readonly PROCESS_NAME="test"
readonly LOG_FILE="/var/log/monitoring.log"
readonly LAST_PID_FILE="/var/run/${PROCESS_NAME}_last.pid"
readonly MONITOR_URL="https://test.com/monitoring/test/api"
readonly CURL_TIMEOUT=5

# Вспомогательные функции
log_info() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [INFO] $*" >> "$LOG_FILE"
}

log_error() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') [ERROR] $*" >> "$LOG_FILE"
}

# Проверяем, запущен ли процесс
PID=$(pgrep -x "$PROCESS_NAME")

if [ -z "$PID" ]; then
    exit 0
fi

# Проверяем, был ли перезапуск
mkdir -p "$(dirname "$LAST_PID_FILE")"

if [ -f "$LAST_PID_FILE" ]; then
    LAST_PID=$(cat "$LAST_PID_FILE" 2>/dev/null)
else
    LAST_PID=""
fi

if [ "$PID" != "$LAST_PID" ]; then
    log_info "Процесс $PROCESS_NAME перезапущен (PID: $PID)"
    echo "$PID" > "$LAST_PID_FILE" || log_error "Не удалось записать PID в $LAST_PID_FILE"
fi

# Проверяем доступность мониторингового сервера
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time "$CURL_TIMEOUT" --retry 2 "$MONITOR_URL")

if [ -z "$HTTP_CODE" ]; then
    log_error "Не удалось получить ответ от $MONITOR_URL (возможно, сетевая ошибка)"
    exit 1
fi

if [ "$HTTP_CODE" -lt 200 ] || [ "$HTTP_CODE" -ge 300 ]; then
    log_error "Сервер мониторинга недоступен (HTTP $HTTP_CODE)"
fi

