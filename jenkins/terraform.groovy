pipeline {
    agent any

    parameters { 
        choice(name: 'TERRAFORM_OPTS', choices: ['destroy', 'apply'], description: '')
    }
    options {
        ansiColor('xterm')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('s3-terraform-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('s3-terraform-secret-access-key')
        TF_CLI_CONFIG_FILE = "terraform.tfrc"
        TF_IN_AUTOMATION      = '1'
    }    
    stages {
        stage('Terraform apply') {
            steps {
               dir('terraform') {
                    //sh "terraform providers lock -net-mirror=https://terraform-mirror.yandexcloud.net -platform=linux_amd64 -platform=darwin_arm64 yandex-cloud/yandex"
                    sh "terraform init -upgrade -migrate-state -backend-config=access_key=\"YCAJEWWeJSl30NxFUswHCkuZZ\" -backend-config=secret_key=\"YCN5rCGPmw5QvgQbyEg3QeROA6fYnNFgIpi040wF\""
               }
            }
        }
    }
}