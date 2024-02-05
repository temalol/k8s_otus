// infra Helmcharts installation pipeline
pipeline {
    agent any
    options {
        ansiColor('xterm')
        timeout(time: 1, unit: 'HOURS') 
    }
    environment {
        KUBECONFIG = './kubeconfig'
    }
    stages {
        stage("Run helm") {
            steps {
               dir('bookinfo_helm/bookinfo') {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'kubeconfig'),
                        file(credentialsId: 'gpg_private', variable: 'helm_gpg_private')]) {
                        sh "gpg --batch --allow-secret-key-import --import ${helm_gpg_private}"
                        writeFile file: "kubeconfig", text: "${kubeconfig}"
                        sh "helm plugin list"
                        sh "helm secrets upgrade  --install bookinfo . -f ./secret.yaml --namespace bookinfo --create-namespace"
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