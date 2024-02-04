pipeline {
    agent any

    parameters { 
        choice(name: 'TERRAFORM_OPTS', choices: ['apply', 'destroy'], description: '')
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
                    withCredentials([file(credentialsId: 'terraform_key_sa', variable: 'terraform_key_sa.json')]) {
                        sh "terraform init -upgrade -input=false"
                        sh "terraform plan"
                    }
               }
            }
        }
    }
 post {
        // Clean after build
        always {
            cleanWs()
        }
    }
}