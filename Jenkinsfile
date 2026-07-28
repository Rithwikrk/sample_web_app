pipeline {
    agent any
    stages {
        stage('Static Code Analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonarqube-token-latest') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
    }
}
