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
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'kubeconfig')]) {
                        writeFile(file: "kube.conf", text: "${kubeconfig}") 
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