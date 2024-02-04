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
                    sh "terraform -reconfigure"
               }
            }
        }
    }
}