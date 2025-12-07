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
                    def schemes = sh(script: 'compile-scheme --list-r7rs-except larceny loko', returnStdout: true).split()
                    parallel schemes.collectEntries { SCHEME ->
                        [(SCHEME): {
                            stage("${SCHEME}") {
                                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                    sh "make SCHEME=${SCHEME} test-docker"
                                }
                            }
                        }]
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
                    reportDir: '',
                    reportFiles: 'index.html',
                    reportName: 'r7rs-coverage',
                    reportTitles: 'r7rs-coverage'])
            archiveArtifacts(artifacts: '*.log', allowEmptyArchive: true, fingerprint: true)
        }
    }
}

