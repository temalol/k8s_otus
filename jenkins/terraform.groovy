pipeline {
    agent any

    stages {
        stage('Terraform apply') {
            steps {
                echo 'apply..'
            }
        }
    }
}