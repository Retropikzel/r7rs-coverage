pipeline {
    agent {
        label 'docker-x86_64'
    }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }

    parameters {
        string(name: 'R7RS_SCHEMES', defaultValue: 'chibi', description: '')
    }

    stages {
        stage('Coverage') {
            steps {
                script {
                    params.R7RS_SCHEMES.split().each { SCHEME ->
                        stage("${SCHEME}") {
                            agent {
                                docker {
                                    image "schemers/${SCHEME}:head"
                                }
                            }
                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                sh "./coverage ${SCHEME}"
                            }
                        }
                    }
                }
            }
        }
        stage('HTML') {
            agent {
                docker {
                    image "schemers/mit-scheme:head"
                }
            }
            steps {
                sh "mit-scheme --load stats.scm --eval '(begin (format-stats) (%exit 0))'"
            }
        }

    }
}
