// Helmcharts installation pipeline
pipeline {
    agent any
    options {
        ansiColor('xterm')
        timeout(time: 1, unit: 'HOURS') 
    }
    stages {
        stage("Run helmfile") {
            steps {
               dir('helmfile_infra') {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'kubeconfig'),
                        file(credentialsId: 'gpg_private', variable: 'helm_gpg_private')]) {
                                    
                        sh "gpg --batch --allow-secret-key-import --import ${helm_gpg_private}"
                        //sh "helm plugin install https://github.com/jkroepke/helm-secrets --version v4.5.1"
                        //sh "helm plugin install https://github.com/aslafy-z/helm-git --version 0.15.1"
                        sh "helm plugin list"
                    withEnv(["KUBECONFIG=${kubeconfig}"]){
                        sh "printenv"
                        sh "cat ${kubeconfig}"
                        sh "helmfile sync"
                    }
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