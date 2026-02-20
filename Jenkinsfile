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
        cron('@monthly')
    }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }

    parameters {
        string(name: 'SCHEMES', defaultValue: 'capyscheme chibi chicken cyclone foment gauche gambit guile kawa larceny loko meevax mit-scheme mosh racket sagittarius skint stklos tr7 ypsilon', description: '')
    }


    stages {
        stage('Clean') {
            steps {
                sh "make clean"
            }
        }

        stage('Tests') {
            steps {
                script {
                    params.SCHEMES.split().each { SCHEME ->
                        stage("${SCHEME}") {
                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                sh "make SCHEME=${SCHEME} test-docker"
                            }
                        }
                    }
                }
            }
        }
    }

    post {
        success {
            sh "make report"
            sh "chmod -R 755 ." // HTML Publish fails without this
            publishHTML (target : [allowMissing: false,
                    alwaysLinkToLastBuild: true,
                    keepAll: true,
                    reportDir: '',
                    reportFiles: 'index.html',
                    reportName: 'r7rs-coverage',
                    reportTitles: 'r7rs-coverage'])
            archiveArtifacts(artifacts: 'logs/*.log', allowEmptyArchive: true, fingerprint: true)
            cleanWs()
        }
        failure {
            cleanWs()
        }
    }
}

