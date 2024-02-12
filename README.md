Про что написать:

хелм чарты отделньно
алертинг
приложение



# K8s
В качестве среды k8s для развертывания приложения был выбран managed k8s yandex cloud.

Тип мастера: Региональный
Версия: 1.28
Кластер, worker nodes и остальные облачные ресурсы описываются при помощи terraform и деплоятся через jenkins job.

Ноды развернуты в разных сетевых сегментах (ru-central1-a и ru-central1-b)

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
     - Заккомититься
     - Запустить jenkins задачу для деплоя инфраструктурных helm чартов

# Инфраструктурные helm чарты

Для декларативного описания и установки используется helmfile (директория helmfile_infra). Некоторые helm чарты были перенесены в свои (публичные) репозитории, для удобства работы и большого количества переопределений.
Все секреты переопределены, зашифрованы инструментом sops и подключаются опцией secrets.
Инфраструктурные чарты устанавливаются к кластер в определенном порядке и используется флаг wait во избежание проблем отсутствующих ресурсов для зависимых друг от друга чартов (например для kube-prometheus-stack необходим yc-csi-s3)

# Приложение

В качестве примера используется микросервисное приложение bookinfo

![Alt text](pics/bookinfo.png?raw=true "jenkins")

Микросервис productpage делает запросы на details и reviewsg для отрисовки страницы

- **details** предоставляет информацию о книге
- **reviews** предоставляет отзыв о книге, а так-же делает запросы на ratings
- **ratings** предоставляет рейтинг книги от 1 до 5

reviews представлен в качестве 3х версий
- **v1** - не делает запросов в ratings
- **v2** - делает запросы и отрисовывает рейтинг звездами черного цвета
- **v3** - трисовывает рейтинг звездами красного цвета




