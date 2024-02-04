pipeline {
    agent any

    parameters { 
        choice(name: 'TERRAFORM_OPTS', choices: ['destroy', 'apply'], description: '')
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('s3-terraform-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('s3-terraform-secret-access-key')
        TF_CLI_CONFIG_FILE = "/var/lib/jenkins/workspace/test_job/terraform/terraform.tfrc"
    }    
    stages {
        stage('Terraform apply') {
            steps {
               dir('terraform') {
                    sh "whoami"
                    sh "sudo terraform init -migrate-state -backend-config=access_key=$ACCESS_KEY -backend-config=secret_key=$SECRET_KEY"
               }
            }
        }
    }
}