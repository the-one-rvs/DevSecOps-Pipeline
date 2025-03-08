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
    }
    stages{
        stage('Check for Changes') {
            steps {
                script {
                    def lastCommit = sh(script: "git rev-parse HEAD", returnStdout: true).trim()
                    sh "git fetch origin ${GIT_BRANCH}"
                    def newCommit = sh(script: "git rev-parse FETCH_HEAD", returnStdout: true).trim()
                    
                    if (lastCommit == newCommit) {
                        echo "No new commits found. Aborting build."
                        currentBuild.result = 'ABORTED'
                        error("Build aborted due to no changes.")
                    } else {
                        echo "New commits detected. Proceeding with build..."
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