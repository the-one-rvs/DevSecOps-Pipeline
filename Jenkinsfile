pipeline{
    agent any
    triggers {
        githubPush()  
        pollSCM('H/2 * * * *')
    }
    environment{
        SONAR_URL = 'http://localhost:9000'
        PROJECT_KEY = 'devsecops-project'
        SONAR_TOKEN = credentials('sonar-token')
        SONARQUBE_URL = 'http://localhost:9000'
        GIT_URL = 'https://github.com/the-one-rvs/DevSecOps-Pipeline.git'
        GIT_BRANCH = 'master'
    }
    stages{
        stage('Check for Changes') {
            steps {
                script {
                    // Current local HEAD commit
                    def lastCommit = sh(script: "git rev-parse HEAD || echo 'NONE'", returnStdout: true).trim()

                    // Latest remote commit from the correct branch
                    def newCommit = sh(script: "git ls-remote ${GIT_URL} refs/heads/${GIT_BRANCH} | cut -f1", returnStdout: true).trim()

                    if (lastCommit == newCommit) {
                        echo "No new commits found. Aborting build."
                        currentBuild.result = 'ABORTED'
                        error("Build aborted due to no new changes.")
                    } else {
                        echo "New commit detected: ${newCommit}. Proceeding..."
                    }
                }
            }
        }
        stage('Github Repo'){
            steps{
                echo 'Pulling the project from Github...'
                git branch: 'master', url: 'https://github.com/the-one-rvs/DevSecOps-Pipeline.git'
            }
        }
        stage('SonarQube Analysis'){
            steps{
                echo 'Running SonarQube Analysis...'
                withSonarQubeEnv('SonarQube'){
                   sh '''
                    npx sonarqube-scanner \
                      -Dsonar.projectKey=${PROJECT_KEY} \
                      -Dsonar.sources=. \
                      -Dsonar.host.url=${SONARQUBE_URL} \
                      -Dsonar.login=${SONARQUBE_TOKEN}
                    '''
                }
            }
        }
        
    }
}