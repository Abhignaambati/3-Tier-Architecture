pipeline {
    agent any

    environment {
        PATH = "/opt/homebrew/bin:${env.PATH}"
    }

    stages {
        stage('Unit Test') {
            steps {
                dir('frontend') {
                    sh 'npm test'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'

                    withSonarQubeEnv('SonarQube') {
                        sh "${scannerHome}/bin/sonar-scanner"
                    }
                }
            }
        }
    }
}