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