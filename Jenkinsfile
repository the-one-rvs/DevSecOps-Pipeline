pipeline{
    agent any
    trigger{
        pollSCM('* * * * *')
    }
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
                    sh 'mvn sonar:sonar -Dsonar.login=$SONAR_TOKEN -Dsonar.projectKey=$SONAR_PROJECT_KEY'
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