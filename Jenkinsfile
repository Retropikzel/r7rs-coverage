pipeline {
    agent {
        dockerfile {
            label 'agent1'
            filename 'Dockerfile.jenkins'
            args '--user=root --privileged -v /var/run/docker.sock:/var/run/docker.sock'
            reuseNode true
        }
    }

    triggers{ cron('0 0 * * 3') }

    options {
        disableConcurrentBuilds()
        buildDiscarder(logRotator(numToKeepStr: '10', artifactNumToKeepStr: '10'))
    }

    parameters {
        //string(name: 'R7RS_SCHEMES', defaultValue: 'chibi chicken cyclone foment gauche gerbil guile kawa larceny loko mit picrin racket sagittarius')
        string(name: 'R7RS_SCHEMES', defaultValue: 'chibi chicken')
    }

    stages {
        stage('Coverage') {
            steps {
                script {
                    params.R7RS_SCHEMES.split().each { SCHEME ->
                        stage("${SCHEME}") {
                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                sh "docker run -v ${PWD}:/workdir -w /workdir shemers/${SCHEME}:head ./coverage ${SCHEME}"
                                archiveArtifacts artifacts: '*.log', fingerprint: true
                                archiveArtifacts artifacts: '*.csv', fingerprint: true
                                publishHTML (target : [allowMissing: true,
                                alwaysLinkToLastBuild: true,
                                keepAll: true,
                                reportDir: '.',
                                reportFiles: "${SCHEME}.log",
                                reportName: "${SCHEME}.log",
                                reportTitles: "${SCHEME}.log"])
                            }
                        }
                    }
                }
            }
        }
        /*
        stage('HTML') {
            agent {
                docker {
                    image "schemers/chibi-scheme:head"
                }
            }
            steps {
                sh "chibi-scheme stats.scm"
            }
        }
        */
        stage('Publish') {
            steps {
                publishHTML (target : [allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'results.csv',
                reportName: 'results.csv',
                reportTitles: 'results.csv'])
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
