//Docker images build and push pipeline

pipeline {
    agent any

    options {
        ansiColor('xterm')
        timeout(time: 1, unit: 'HOURS') 
    }
    environment {
        BOOKINFO_HUB = "cr.yandex/crpmugbv6k1atn1lldsi"
        BOOKINFO_TAG = "v3"
    }    
    stages {
        stage("build") {
            steps {
               dir('bookinfo_src') {
                    withCredentials([file(credentialsId: 'docker_secret', variable: 'docker_token')]) {
                        sh "cat ${docker_token} | docker login --username json_key --password-stdin cr.yandex"
                        sh "./build-services.sh --push"
                    }                    
               }
            }
        }
    }
 post {
        always {
            cleanWs()
        }
    }
}