pipeline {
    agent {
        dockerfile {
            label 'docker-x86_64'
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

    //string(name: 'R7RS_SCHEMES', defaultValue: 'chibi chicken cyclone foment gauche gerbil guile kawa larceny loko mit-sheme picrin racket sagittarius')

    stages {
        stage('Coverage') {
            steps {
                script {
                    'chibi:head chicken:5 chicken:head'.split().each { SCHEME ->
                        stage("${SCHEME}") {
                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                scheme="${SCHEME}".split(":")
                                sh "docker run -v ${WORKSPACE}:/workdir -w /workdir schemers/${SCHEME} sh -c \"./coverage ${scheme[0]}\""
                                archiveArtifacts artifacts: '*.log', fingerprint: true
                                archiveArtifacts artifacts: '*.csv', fingerprint: true
                            }
                        }
                    }
                }
            }
        }
        stage('Markdown report') {
            steps {
                sh "make report.md"
                archiveArtifacts artifacts: 'report.md', fingerprint: true
            }
        }
        stage('Log tar') {
            steps {
                sh "tar -zcvf logs.tgz *.log"
                archiveArtifacts artifacts: 'logs.tgz', fingerprint: true
            }
        }
        stage('Publish') {
            steps {

                sh "echo '<pre>' > report.md.html"
                sh "cat report.md >> report.md.html"
                sh "echo '</pre>' >> report.md.html"

                publishHTML (target : [allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'report.md.html',
                reportName: 'report.md.html',
                reportTitles: 'report.md.html'])
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
