pipeline {
    agent { label 'linux' }

    stages {
        stage('Validation & Checks') {
            parallel {
                stage('Commit Message Validation') {
                    steps {
                        script {
                            def commitMsg = sh(script: 'git log -1 --pretty=%B', returnStdout: true).trim()
                            writeFile file: 'commit_msg.txt', text: commitMsg
                            echo 'Validating commit message...'

                            sh 'chmod +x scripts/check_commit.sh'
                            catchError(buildResult: 'UNSTABLE', stageResult: 'UNSTABLE') {
                                sh './scripts/check_commit.sh commit_msg.txt'
                            }
                            sh './scripts/check_commit.sh commit_msg.txt'
                        }
                    }
                }

                stage('Check Dependencies') {
                    steps {
                        script {
                            echo 'Verifying external service availability...'
                            catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                                sh 'chmod +x script/check_dependencies.sh'
                                sh './script/check_dependencies.sh'
                            }
                        }
                    }
                }
            }
        }

        stage('Static Code Analysis') {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonarqube-token') {
                        sh 'mvn test sonar:sonar'
                    }

                    timeout(time: 1, unit: 'HOURS') {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
        stage('Build & Test') {
            steps {
                script {
                    echo "Building the application..."
                    sh "mvn clean install"
                }
            }
        }
        stage('docker build') {
            steps {
                script {
                    echo "Building Docker image..."
                    sh "docker build -t myapp:${Docker_tag} ."
                }
            }
        }

    }

    post {
        always {
            echo 'Cleaning up workspace...'
            cleanWs()
        }
    }
}
