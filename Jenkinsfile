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
        //string(name: 'R7RS_SCHEMES', defaultValue: 'chibi chicken cyclone foment gauche gerbil guile kawa larceny loko mit-sheme picrin racket sagittarius')
        string(name: 'R7RS_SCHEMES', defaultValue: 'chibi chicken')
    }

    stages {
        stage('Coverage') {
            steps {
                script {
                    params.R7RS_SCHEMES.split().each { SCHEME ->
                        stage("${SCHEME}") {
                            catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                                sh "docker run -v ${WORKSPACE}:/workdir -w /workdir schemers/${SCHEME}:head sh -c \"./coverage ${SCHEME}\""
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
                sh "make markdown"
            }
        }
        stage('Publish') {
            steps {
                sh "tar -zcvf logs.tgz *.log"
                archiveArtifacts artifacts: 'logs.tgz', fingerprint: true

                archiveArtifacts artifacts: 'report.md', fingerprint: true

                sh "echo '<pre>' > markdown.html"
                sh "cat markdown.md >> markdown.html"
                sh "echo '</pre>' >> markdown.html"

                publishHTML (target : [allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: '.',
                reportFiles: 'markdown.html',
                reportName: 'markdown.html',
                reportTitles: 'markdown.html'])
            }
        }
    }
    post {
        always {
            cleanWs()
        }
    }
}
