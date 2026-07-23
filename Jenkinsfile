def getDockerTag() {
    def tag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
    return tag
}

pipeline {
    agent { label 'linux' }

    environment {
        DOCKER_TAG = getDockerTag()
    }

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
                        }
                    }
                }

                stage('Check Dependencies') {
                    steps {
                        script {
                            echo 'Verifying external service availability...'
                            catchError(buildResult: 'SUCCESS', stageResult: 'UNSTABLE') {
                                sh 'chmod +x scripts/check_dependencies.sh'
                                sh './scripts/check_dependencies.sh'
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
                        sh 'mvn sonar:sonar'
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
                    echo 'Building the application...'
                    sh 'MAVEN_OPTS="--add-opens java.base/java.util=ALL-UNNAMED" mvn clean install'
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    echo 'Building Docker image...'
                    sh "docker build -t myapp:${DOCKER_TAG} ."
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
