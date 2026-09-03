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
    }
}