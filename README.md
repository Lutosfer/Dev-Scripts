# Скрипт Мониторинга

## Задача

Разработать Bash-скрипт для мониторинга процесса 'test' в Linux. Скрипт должен:

1. Проверять наличие процесса 'test' каждую минуту.  
2. Если процесс запущен — отправлять HTTPS-запрос на https://test.com/monitoring/test/api 
3. Если процесс был перезапущен (PID изменился) — записывать это событие в лог /var/log/monitoring.log
4. Если сервер мониторинга недоступен — писать ошибку в лог.  
5. Скрипт должен запускаться автоматически при старте системы с помощью systemd timer.

---

## 📂 Структура проекта
`````
├── monitor.sh # Bash-скрипт мониторинга
├── monitor.service # systemd unit
├── monitor.timer # systemd timer
└── README.md # этот файл
`````

---

## 🔧 Установка и запуск
### 1️⃣ Копирование скрипта
`````
sudo cp monitor.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/monitor.sh
`````

### 2️⃣ Установка systemd unit и timer
`````
sudo cp monitor.service /etc/systemd/system/
sudo cp monitor.timer /etc/systemd/system/
sudo systemctl daemon-reload
`````

### 3️⃣ Активация таймера
`````
sudo systemctl enable --now monitor.timer
`````
### 4️⃣ Проверка состояния таймера
`````
systemctl list-timers | grep monitor
`````
