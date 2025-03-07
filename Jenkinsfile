pipeline{
    agent any
    environment{
        SONAR_URL = 'http://localhost:9000'
        PROJECT_KEY = 'DevSecOps-Pipeline'
        REPORT_TXT = 'sonar-report.txt'
        REPORT_HTML = 'sonar-report.html'
        SONAR_TOKEN = credentials('sonar-token')
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
                   sh """
                        export SONAR_TOKEN=${SONAR_TOKEN}
                        sonar-scanner \
                        -Dsonar.projectKey=$PROJECT_KEY \
                        -Dsonar.sources=. \
                        -Dsonar.login=${env.SONAR_TOKEN} \
                        -Dsonar.qualitygate.wait=true
                    """
                }
            }
        }
        stage('Fetch SonarQube Report ') {
            steps {
                script {
                    echo 'Fetching SonarQube Report...'
                    
                    sh "curl -s '$SONAR_URL/api/issues/search?componentKeys=$PROJECT_KEY' | jq '.' > $REPORT_TXT"

                    sh "curl -s '$SONAR_URL/dashboard?id=$PROJECT_KEY' > $REPORT_HTML"
                }
            }
        }
    }
}