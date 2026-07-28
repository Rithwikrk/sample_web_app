pipeline {
    agent any

    stages {
        stage('Static Code Analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonarqube-token-v1') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
    }
}
