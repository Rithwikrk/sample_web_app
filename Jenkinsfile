pipeline {
    agent any
    parameters {
        string(name: 'PROJECT_NAME', defaultValue: 'sample-web-app', description: 'Project name')
    }
       
    stage('Get Remote Branches via API') {
    steps {
        // Use the ID you just created in the Jenkins UI.
        withCredentials([usernamePassword(credentialsId: 'github-api-token', passwordVariable: 'GITHUB_PAT', usernameVariable: 'GITHUB_USER')]) {
            script {
                def owner = "Rithwikrk"
                
                // Fetch branches from the GitHub API (handles pagination up to 100 branches)
                def response = sh(
                    script: "curl -s -u \$GITHUB_USER:\$GITHUB_PAT https://api.github.com/repos/${owner}/${repo}/branches?per_page=100",
                    returnStdout: true
                ).trim()
                
                // Parse the JSON response using Groovy's JsonSlurper
                def json = new groovy.json.JsonSlurper().parseText(response)
                
                // Extract branch names into a list
                def branchNames = json.collect { it.name }
                
                echo "All branches in repo: ${branchNames.join(', ')}"
            }
        }
    }
}
            
