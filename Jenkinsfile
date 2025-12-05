pipeline {

    agent {
        dockerfile {
            label 'docker-x86_64'
            filename 'Dockerfile.jenkins'
            args '--user=root --privileged -v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    triggers{
        cron('0 4 * * *')
    }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }


    stages {
        stage('Tests') {
            steps {
                script {
                    def schemes = sh(script: 'compile-scheme --list-r7rs-except larceny', returnStdout: true).split()
                    schemes.each { SCHEME ->
                        stage("${SCHEME}") {
                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                sh "timeout 600 make SCHEME=${SCHEME} SRFI=${SRFI} test-r7rs-docker"
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            sh "make html"
            publishHTML (target : [allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: 'reports',
                    reportFiles: 'index.html',
                    reportName: 'r7rs-coverage',
                    reportTitles: 'r7rs-coverage'])
        }
    }
}

