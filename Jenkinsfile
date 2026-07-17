pipeline {
    agent any

    parameters {
        string(
            name: 'PROJECT_NAME',
            defaultValue: 'sample-web-app',
            description: 'Project name'
        )
    }

    stages {
        stage('Get Remote Branches via API') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'github-api-token',
                        usernameVariable: 'GITHUB_USER',
                        passwordVariable: 'GITHUB_PAT'
                    )
                ]) {
                    script {
                        def owner = "Rithwikrk"
                        def repo = params.PROJECT_NAME

                        def response = sh(
                            script: """
                                curl -s -u \$GITHUB_USER:\$GITHUB_PAT \
                                https://api.github.com/repos/${owner}/${repo}/branches?per_page=100
                            """,
                            returnStdout: true
                        ).trim()

                        def json = new groovy.json.JsonSlurper().parseText(response)

                        if (json.message) {
                            error("GitHub API Error: ${json.message}")
                        }

                        def branchNames = json.collect { it.name }

                        echo "All branches: ${branchNames.join(', ')}"
                    }
                }
            }
        }
    }
}