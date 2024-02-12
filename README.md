Про что написать:

хелм чарты отделньно



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




# Логика работы 



