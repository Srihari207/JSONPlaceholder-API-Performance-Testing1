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

        stage('Execute JMeter Test') {
    steps {
        bat '''
            set "JAVA_HOME=C:\\Users\\91885\\Downloads\\OpenJDK21U-jdk_x64_windows_hotspot_21.0.12_8\\jdk-21.0.12+8"
            set "PATH=%JAVA_HOME%\\bin;C:\\Windows\\System32;C:\\Windows;%PATH%"

            java -version
            where findstr

            if not exist results mkdir results
            if not exist reports mkdir reports

            if exist results\\results.jtl del /q results\\results.jtl
            if exist reports\\jmeter-report rmdir /s /q reports\\jmeter-report

            call "C:\\Performance Testing\\apache-jmeter-5.6.3\\bin\\jmeter.bat" -n ^
            -t "jmeter\\API Performance Test.jmx" ^
            -Jthreads=%THREADS% ^
            -Jrampup=%RAMPUP% ^
            -Jloops=%LOOPS% ^
            -l "results\\results.jtl" ^
            -e ^
            -o "reports\\jmeter-report"

            if errorlevel 1 exit /b 1
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
            archiveArtifacts artifacts: 'reports/jmeter-report/**', allowEmptyArchive: true

            publishHTML(target: [
                allowMissing: true,
                alwaysLinkToLastBuild: true,
                keepAll: true,
                reportDir: 'reports/jmeter-report',
                reportFiles: 'index.html',
                reportName: 'JMeter Performance Report'
            ])
        }
    }
}