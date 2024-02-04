pipeline {
    agent any

    parameters { 
        choice(name: 'TERRAFORM_OPTS', choices: ['destroy', 'apply'], description: '')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('s3-terraform-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('s3-terraform-secret-access-key')
    }    
    stages {
        stage('Terraform apply') {
            steps {
               dir('terraform') {
                    sh "terraform init -migrate-state -backend-config=access_key=$AWS_ACCESS_KEY_ID -backend-config=secret_key=$AWS_SECRET_ACCESS_KEY"
               }
            }
        }
    }
}