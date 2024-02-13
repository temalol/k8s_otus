# K8s
В качестве среды k8s для развертывания приложения был выбран managed k8s yandex cloud.

Тип мастера: Региональный
Версия: 1.28
Кластер, worker nodes и остальные облачные ресурсы описываются при помощи terraform и деплоятся через jenkins job.

Ноды (по две штуки на один сегмент) развернуты в разных сетевых сегментах (ru-central1-a и ru-central1-b)

# Terraform

Версия: 1.7.2
Описание инфраструктуры хранистя в terraform
Для хранения state файлов подключен s3 backend,(yandex cloud) секрет для подключения хранится в jenkins(terraform_key_sa.json)

# Jenkins

Версия: 2.426.3
Используется как предустановленное на ВМ решение yandex cloud marketplace
Декларативные пайпланы находятся в директории jenkins

![Alt text](pics/jenkins.png?raw=true "jenkins")


# Логика и порядок деплоя

1) Первым запускается пайплайн terraform.groovy для применения ресурсов в облако.
Для корректной работы в секреты jenkins нужно добавить AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY terraform_key_sa (ключ создается в терминальной утилите yc)

2) После успешного создания инфраструктуры нужно получить необходимые секреты для работы приожения/инфраструктурных компонентов. 
    Для этого придется совершить ряд ручных действий:
     - Заполнить переменные CLUSTER_ID и SOPS_PGP в bash скрипте etc/get_yc_credentials.sh
     - Запустить bash скрипт 
     - Секреты docker (pull/push) и kubeconfig добавить в jenkins
     - Секреты инфраструктурных helm чартов скопировать в папку helmfile_infra (создаются уже шифрованные через sops)
     - В Jenkins загрузить файл с gpg ключами для расшифровки (Без passphrase)
     - commit
     - Запустить jenkins задачу для деплоя инфраструктурных helm чартов

# Инфраструктурные helm чарты

Для декларативного описания и установки используется helmfile (директория helmfile_infra). Некоторые helm чарты были перенесены в свои (публичные) репозитории, для удобства работы и большого количества переопределений.
Все секреты переопределены, зашифрованы инструментом sops и подключаются опцией secrets.
Инфраструктурные чарты устанавливаются к кластер в определенном порядке и используется флаг wait во избежание проблем отсутствующих ресурсов для зависимых друг от друга чартов (например для kube-prometheus-stack необходим yc-csi-s3)

# Приложение

В качестве примера используется микросервисное приложение bookinfo

![Alt text](pics/bookinfo.png?raw=true "jenkins")

Микросервис productpage делает запросы на details и reviews для отрисовки страницы

- **details** предоставляет информацию о книге
- **reviews** предоставляет отзыв о книге, а так-же делает запросы на ratings
- **ratings** предоставляет рейтинг книги от 1 до 5

reviews представлен в качестве 3х версий
- **reviews v1** - не делает запросов в ratings
- **reviews v2** - делает запросы и отрисовывает рейтинг звездами черного цвета
- **reviews v3** - отрисовывает рейтинг звездами красного цвета

# Сборка приложения

Для сборки используется build.groovy
Исходники находятся в директории bookinfo_src
Необходимо заполнить переменные BOOKINFO_HUB и BOOKINFO_TAG для загрузки образов в registry
В моем случае используется yandex cloud registry, созданное ранее через terraform.
Для сборки используется плагин docker buildx

# Деплой приложения

Развертывание приложения происходит при помощи helm чарта в директории bookinfo_helm/bookinfo задачей jenkins (helm_app.groovy)
ingress доступен по адресу https://k8s-uptime.ru/productpage?u=normal
Единсвенный секрет приложения - tls сертификат (secret.yaml (зашифрованно sops))


# Мониторинг
Графана доступна по адресу https://grafana.k8s-uptime.ru
Используется kube-prometheus-stack с стандартными дашбордами. Дополнительные дашборды устанавливаются с прикладным helm чартом (bookinfo_helm/bookinfo/dashboards)
Дефолтных дашбордов достаточно для базовых задач мониторинга
Что было доработано:
 - Мониторинг ingress как основная точка входа траффика в приложение
    ![Alt text](pics/ingress.png?raw=true "grafana ingress")
 - Прикладной мониторинг (с сожалению, приклад оказался достаточно скудным на мониторинг, метрики возвращает только один микросервис, но он является входной точкой приложения и собирает коды ответов с сервисов, которых вызывает, что вцелом дает понимание о состоянии приложения)
    ![Alt text](pics/flask.png?raw=true "grafana flask")
 - Для хранения метрик подключен csi-s3 volume (в виде helm чарта от yandex cloud) и примонтирован в prometheus (values.yaml  в репозитории с helm чартом)

# Aлертинг

В качестве алертинга используется alermanager
 - К обширному количеству дефолтных алертов добавлены алерты nginx-ingress (срок сертификата, latency P95, 4xx, 5xx)
 - Прикладные алерты также настроены на превышение 5xx, latency
 - Алерты отправляются в telegram, секрет зашфирован в файле helmfile_infra/telegram_secret.yaml
 - Алерты описываются ресурсом PrometheusRule и находятся в прикладном helm чарте в директории prometheusrules

# Логирование

Логирование мастера и прикладной части реализовано с использованием yandex cloud logging
Для этого, на этапе развертывания terraform создаются необходимые logging group и сервисные аккаунты.
На следующем этапе применяется helm чарт с патченным fluent-bit для работы в yandex cloud (name: fluent-bit)

# Что не получилось и что можно улучшить

- Не получилось собрать метрики распределенного мастера k8s (похоже, особенность yc), но мониторинг доступен в консоли yandex cloud.
- Расширить мониторинг приложения, возможно через подключение istio и сбор метрик с сайдкаров.
- Уменьшить количество ручных операций.
- Для хранения метрик в s3 (вместо csi volume) подключить thanos
