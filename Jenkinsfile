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
                            echo "Validating commit message..."

                            // Execute the verification script (assumed to be in your repo at scripts/check_commit.sh)
                            // If the script exits with status 1, the pipeline will fail here.
                            sh "chmod +x scripts/check_commit.sh"
                            sh "./scripts/check_commit.sh commit_msg.txt"
                        }
            }
        }
        stage('Check Dependencies') {
                    steps {
                        script {
                            echo "Verifying external service availability..."
                            sh "chmod +x scripts/check_dependencies.sh"
                            sh "./scripts/check_dependencies.sh"
                        }
                    }
                }

        stage('Static Code Analysis') {
            steps {
                script {
                    // Securely inject the credentials you created
                    withSonarQubeEnv(credentialsId: 'sonarqube-token') {
                        sh "mvn test sonar:sonar"
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
    }
}
