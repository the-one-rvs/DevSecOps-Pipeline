pipeline{
    agent any
    triggers {
        pollSCM('H/2 * * * *') // Sirf naye commits check karega har 2 min me
    }
    environment{
        SONAR_URL = 'http://localhost:9000'
        PROJECT_KEY = 'devsecops-project'
        SONAR_TOKEN = credentials('sonar-token')
        SONARQUBE_URL = 'http://localhost:9000'
    }
    stages{
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