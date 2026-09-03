pipeline {
    agent any

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