pipeline {
    agent any

    parameters { 
        choice(name: 'TERRAFORM_OPTS', choices: ['destroy', 'apply'], description: '')
    }

    stages {
        stage('Terraform apply') {
            steps {
               dir('terraform') {
                    sh "terraform ${TERRAFORM_OPTS} -auto-approve"
               }
            }
        }
    }
}