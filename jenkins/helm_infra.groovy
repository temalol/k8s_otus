// Helmcharts installation pipeline
pipeline {
    agent any
    options {
        ansiColor('xterm')
        timeout(time: 1, unit: 'HOURS') 
    }
    environment {
        KUBECONFIG="kube.conf"
        GNUPGHOME="/home/admin/"
    }    
    stages {
        stage("Run helmfile") {
            steps {
               dir('helmfile_infra') {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'kubeconfig'),
                                    file(credentialsId: 'gpg_private', variable: 'helm_gpg_private'),
                                    file(credentialsId: 'pgp_public', variable: 'helm_gpg_public')]) {
                                    
                                    writeFile(file: "kube.conf", text: "${kubeconfig}") 
                                    sh "gpg --batch --import ${helm_gpg_public}"
                                    sh "gpg --batch --allow-secret-key-import --import ${helm_gpg_private}"
                    }
                        sh "helm plugin list"
                        sh "helmfile sync"
                }
            }
        }
    }

 post {
        // Clean after build
        always {
           // cleanWs()
           println("HEllo")
        }
    }
}