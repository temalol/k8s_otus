// infra Helmcharts installation pipeline
pipeline {
    agent any
    options {
        ansiColor('xterm')
        timeout(time: 1, unit: 'HOURS') 
    }
    parameters { 
        choice(name: 'HELMFILE_OPTS', choices: ['sync', 'delete'], description: '')
    }
    environment {
        KUBECONFIG = './kubeconfig'
    }
    stages {
        stage("Run helmfile") {
            steps {
               dir('helmfile_infra') {
                    withCredentials([file(credentialsId: 'kubeconfig', variable: 'kubeconfig'),
                        file(credentialsId: 'gpg_private', variable: 'helm_gpg_private'),
                        file(credentialsId: 'docker_secret', variable: 'docker_token')) {
                        sh "gpg --batch --allow-secret-key-import --import ${helm_gpg_private}"
                        //sh "helm plugin install https://github.com/jkroepke/helm-secrets --version v4.5.1"
                        //sh "helm plugin install https://github.com/aslafy-z/helm-git --version 0.15.1"
                        writeFile file: "kubeconfig", text: "${kubeconfig}"
                        sh "cat ${docker_token} | helm registry login cr.yandex --username 'json_key' --password-stdin"
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