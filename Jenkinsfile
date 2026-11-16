pipeline {
    agent any

    parameters {
        choice(
            name: 'TEST_PROFILE',
            choices: ['SMOKE', 'LOAD', 'STRESS'],
            description: 'Select performance test profile'
        )
    }

    stages {

        stage('Environment Check') {
            steps {
                bat '''
                    set "PATH=C:\\Windows\\System32;%PATH%"
                    java -version
                    "C:\\Performance Testing\\apache-jmeter-5.6.3\\bin\\jmeter.bat" --version
                '''
            }
        }

        stage('Configure Test Profile') {
            steps {
                script {
                    if (params.TEST_PROFILE == 'SMOKE') {
                        env.THREADS = '1'
                        env.RAMPUP = '1'
                        env.LOOPS = '1'
                    } else if (params.TEST_PROFILE == 'LOAD') {
                        env.THREADS = '25'
                        env.RAMPUP = '25'
                        env.LOOPS = '10'
                    } else if (params.TEST_PROFILE == 'STRESS') {
                        env.THREADS = '50'
                        env.RAMPUP = '25'
                        env.LOOPS = '10'
                    }
                }
            }
        }

        stage('Run JMeter Test') {
            steps {
                bat '''
                    if not exist "results" mkdir "results"
                    if exist "results\\results.jtl" del /q "results\\results.jtl"
                    if exist "report" rmdir /S /Q "report"

                    "C:\\Performance Testing\\apache-jmeter-5.6.3\\bin\\jmeter.bat" -n ^
                    -t "jmeter\\API Performance Test.jmx" ^
                    -Jthreads=%THREADS% ^
                    -Jrampup=%RAMPUP% ^
                    -Jloops=%LOOPS% ^
                    -l "results\\results.jtl" ^
                    -e ^
                    -o "report"

                    if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
                '''
            }
        }

        stage('Performance Quality Gate') {
            steps {
                bat '''
                    "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" ^
                    -ExecutionPolicy Bypass ^
                    -File check-results.ps1 ^
                    -JtlFile "results\\results.jtl"

                    if %ERRORLEVEL% NEQ 0 exit /b %ERRORLEVEL%
                '''
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'results/results.jtl', allowEmptyArchive: true

            publishHTML(target: [
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'report',
                reportFiles: 'index.html',
                reportName: 'JMeter Performance Report'
            ])
        }
    }
}