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
                                    file(credentialsId: 'gpg_private', variable: 'helm_gpg_private'),
                                    file(credentialsId: 'pgp_public', variable: 'helm_gpg_public')]) {
                        def var = $helm_gpg_private
                        writeFile(file: "kube.conf", text: "${kubeconfig}") 
                        writeFile(file: "private.gpg", text: "${helm_gpg_private}")
                        writeFile(file: "public.gpg", text: "${helm_gpg_public}")
                        }
                        println ("${var}")
                        sh "gpg --import public.gpg"
                        sh "gpg --import private.gpg"
                        sh "helm plugin list"
                        sh "helmfile sync"
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