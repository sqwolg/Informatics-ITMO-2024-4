# Лабораторная работа №4

### Инструменты 
Терминал, docker

### Ход работы

**1. Создание Dockerfile**

```Dockerfile
# Используем Ubuntu в качестве базового
FROM ubuntu:latest

# Обновляем списки пакетов и устанавливаем необходимые программы:
RUN apt-get update && apt-get install -y caca-utils iputils-ping

# Устанавливаем команду по умолчанию, которая просто ждет.
# Это нужно, чтобы контейнер не завершал работу сразу после запуска.
# Aafire является интерактивным и требует подключенного терминала, даже при запуске в фоновом режиме, поэтому подход был изменём.
CMD ["tail", "-f", "/dev/null"]
```

**2. Сборка образа**

С помощью команды `docker build -t testimage .` создадаём образ с понятным именем.

**3. Запуск контейнеров**

Запустим два контейнера в фоновом режиме (`-d`) с именами `container1` и `container2` из образа `testimage`:
```bash
docker run -d --name container1 testimage
docker run -d --name container2 testimage
```

**4. Создание и настройка сети**

Создадим изолированную сеть `myNetwork` командой `docker network create`. Затем мы подключим оба запущенных контейнера к этой сети.

```bash
docker network create myNetwork
docker network connect myNetwork container1
docker network connect myNetwork container2
```

Для проверки конфигурации сети можно использовать команду `docker network inspect <network_name>`.

В конфигурации будут указаны все контейнеры, которые к ней подлкючены, а также их IP-адрес в этой сети.
```bash
docker network inspect myNetwork                                                                                                                                                                                                                                o.chernykh@192-168-1-59
[
    {
        "Name": "myNetwork",
        "Id": "bce431ed9d41ccb6e083f87d13511d417477cf6fc923e3cd42e98ba64a96bb2b",
        "Created": "2025-09-07T18:47:22.636447296Z",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": {},
            "Config": [
                {
                    "Subnet": "172.18.0.0/16",
                    "Gateway": "172.18.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": false,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "6f011ae7f9ddf9971b6e544e62917944ac0fe693e517b06c44cf2bc657112814": {
                "Name": "container2",
                "EndpointID": "e5d3aecf4f923a1752b5fa8952ece80134c9d1d2bd56f7f631cdbc4736b8063e",
                "MacAddress": "02:42:ac:12:00:03",
                "IPv4Address": "172.18.0.3/16",
                "IPv6Address": ""
            },
            "bb67ade9ae55270363a025c9b2294c83d983dbd3d363528da2d203fd5d755021": {
                "Name": "container1",
                "EndpointID": "a0780f83994777e6103047d913f448d5ff8c45921ce67c341311980bd9a2b050",
                "MacAddress": "02:42:ac:12:00:02",
                "IPv4Address": "172.18.0.2/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {}
    }
]
```

**5. Проверка сетевого соединения**

Для проверки связи необходимо зайти в контейнер, выполнив `ping` до другого контейнера:

```bash
docker exec -it container1 /bin/bash                                                                                                                                                                                                                      130 ↵ o.chernykh@192-168-1-59
root@bb67ade9ae55:/# ping -c 4 container2
PING container2 (172.18.0.3) 56(84) bytes of data.
64 bytes from container2.myNetwork (172.18.0.3): icmp_seq=1 ttl=64 time=0.629 ms
64 bytes from container2.myNetwork (172.18.0.3): icmp_seq=2 ttl=64 time=0.267 ms
64 bytes from container2.myNetwork (172.18.0.3): icmp_seq=3 ttl=64 time=0.190 ms
64 bytes from container2.myNetwork (172.18.0.3): icmp_seq=4 ttl=64 time=0.181 ms

--- container2 ping statistics ---
4 packets transmitted, 4 received, 0% packet loss, time 3013ms
rtt min/avg/max/mdev = 0.181/0.316/0.629/0.183 ms
```

*Результат: получено 4 ответа от контейнера `container2`, что подтверждает установление сетевого соединения между контейнерами.*
