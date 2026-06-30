pipeline {
    agent any

    environment {
        CC = 'gcc'
        CXX = 'g++'   
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
                sh "printenv"
                echo "this is build_number ${env.BUILD_NUMBER}"
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}