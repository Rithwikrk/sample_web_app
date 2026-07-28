pipeline {
    agent any
    stages {
        stage('Static Code Analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonarqube-token-lat') {
                        sh 'mvn sonar:sonar'
                    }
                }
            }
        }
    }
}
