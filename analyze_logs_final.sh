#!/bin/bash

# Создаем лог-файл для тестирования
cat <<EOL > access.log
192.168.1.1 - - [28/Jul/2024:12:34:56 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.2 - - [28/Jul/2024:12:35:56 +0000] "POST /login HTTP/1.1" 200 567
192.168.1.3 - - [28/Jul/2024:12:36:56 +0000] "GET /home HTTP/1.1" 404 890
192.168.1.1 - - [28/Jul/2024:12:37:56 +0000] "GET /index.html HTTP/1.1" 200 1234
192.168.1.4 - - [28/Jul/2024:12:38:56 +0000] "GET /about HTTP/1.1" 200 432
192.168.1.2 - - [28/Jul/2024:12:39:56 +0000] "GET /index.html HTTP/1.1" 200 1234
EOL

# Создаем отчет
echo "Отчет анализа логов" > report.txt
echo "===================" >> report.txt
echo "" >> report.txt

# 1. Подсчет общего количества запросов
total_requests=$(wc -l < access.log)
echo "1. Общее количество запросов: $total_requests" >> report.txt

# 2. Подсчет количества уникальных IP-адресов (с использованием awk)
unique_ips=$(awk '{print $1}' access.log | sort | uniq | wc -l)
echo "2. Количество уникальных IP-адресов: $unique_ips" >> report.txt

# 3. Подсчет количества запросов по методам (с использованием awk)
echo "3. Количество запросов по HTTP методам:" >> report.txt
awk '{
    # Извлекаем метод из кавычек: "GET /index.html HTTP/1.1"
    method = $6
    # Убираем кавычку в начале
    gsub(/^"/, "", method)
    # Подсчитываем количество каждого метода
    count[method]++
}
END {
    # Выводим результаты
    for (m in count) {
        print "   - " m ": " count[m]
    }
}' access.log >> report.txt

# 4. Поиск самого популярного URL (с использованием awk)
echo "4. Самый популярный URL:" >> report.txt
awk '{
    # Извлекаем URL (второе поле в кавычках): "GET /index.html HTTP/1.1"
    url = $7
    # Подсчитываем количество каждого URL
    count[url]++
}
END {
    # Находим максимальное значение
    max = 0
    max_url = ""
    for (u in count) {
        if (count[u] > max) {
            max = count[u]
            max_url = u
        }
    }
    print "   - " max_url " (количество запросов: " max ")"
}' access.log >> report.txt

# Выводим уведомление о создании отчета
echo "Отчет успешно создан в файле report.txt"

# Показываем содержимое отчета
echo -e "\nСодержимое отчета:"
cat report.txt