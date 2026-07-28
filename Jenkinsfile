pipeline {
    agent { label 'linux' }
    
    tools {
        maven 'Maven 3'
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
            echo 'Skipping SonarQube analysis for now...'
            // withSonarQubeEnv('sonarqube') {
            //     sh 'mvn org.sonarsource.scanner.maven:sonar-maven-plugin:sonar'
            // }
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
                    def dockerTag = sh(script: 'git rev-parse --short HEAD', returnStdout: true).trim()
                    echo "Building Docker image with tag: ${dockerTag}"
                    sh "docker build -t myapp:${dockerTag} ."
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
