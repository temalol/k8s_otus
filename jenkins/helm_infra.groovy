// Helmcharts installation pipeline
pipeline {
    agent any
    options {
        ansiColor('xterm')
        timeout(time: 1, unit: 'HOURS') 
    }
    environment {
        KUBECONFIG="kube.conf" 
    }    
    stages {
        stage("Run helmfile") {
            steps {
               dir('helmfile_infra') {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'kubeconfig'),
                                    file(credentialsId: 'helm_gpg_key', variable: 'helm_gpg_key')]) {
                        writeFile(file: "kube.conf", text: "${kubeconfig}") 
                        writeFile(file: "key.gpg", text: "${helm_gpg_key}") 
                        sh "gpg --allow-secret-key-import --import key.gpg"
                        sh "helm plugin list"
                        sh "helmfile sync"
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