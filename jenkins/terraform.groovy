//Terraform apply/destroy pipeline

pipeline {
    agent any

    parameters { 
        choice(name: 'TERRAFORM_OPTS', choices: ['plan', 'apply', 'destroy'], description: '')
    }
    options {
        ansiColor('xterm')
        timeout(time: 1, unit: 'HOURS') 
    }
    environment {
        AWS_ACCESS_KEY_ID     = credentials('s3-terraform-secret-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('s3-terraform-secret-access-key')
        TF_CLI_CONFIG_FILE = "terraform.tfrc"
        TF_IN_AUTOMATION      = '1'
    }    
    stages {
        stage("Run terraform") {
            steps {
               dir('terraform') {
                    withCredentials([file(credentialsId: 'terraform_key_sa', variable: 'terraform_key_sa')]) {
                        writeFile(file: "terraform_key_sa.json", text: "${terraform_key_sa}")
                        sh "terraform init -upgrade -input=false"
                        sh "terraform ${TERRAFORM_OPTS} -auto-approve"
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