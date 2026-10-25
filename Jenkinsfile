pipeline {
    agent {
        label 'podman'
    }

    options {
        skipDefaultCheckout(true)
    }

    triggers {
        pollSCM('H/5 * * * *')
    }

    environment {
        REGISTRY = 'registry.assign.mnarula3.300.ops:5000'
        IMAGE = 'bind-secondary'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Verify Build Environment') {
            steps {
                sh '''
                    set -eu

                    echo "Build machine:"
                    hostname

                    echo "Build user:"
                    whoami

                    echo "Podman version:"
                    podman --version

                    echo "Git revision:"
                    git rev-parse --short HEAD
                '''
            }
        }

        stage('Build Image') {
            steps {
                sh '''
                    set -eu

                    podman build \
                      -t "${IMAGE}:${BUILD_NUMBER}" .
                '''
            }
        }

        stage('Registry Login and Push') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'registry-creds',
                        usernameVariable: 'REG_USER',
                        passwordVariable: 'REG_PASS'
                    )
                ]) {
                    sh '''
                        set +x
                        set -eu

                        REGISTRY_AUTH_FILE="$WORKSPACE/.registry-auth.json"
                        export REGISTRY_AUTH_FILE

                        trap 'rm -f "$REGISTRY_AUTH_FILE"' EXIT

                        printf '%s' "$REG_PASS" | \
                          podman login "$REGISTRY" \
                            --username "$REG_USER" \
                            --password-stdin

                        podman tag \
                          "${IMAGE}:${BUILD_NUMBER}" \
                          "${REGISTRY}/${IMAGE}:${BUILD_NUMBER}"

                        podman push \
                          "${REGISTRY}/${IMAGE}:${BUILD_NUMBER}"
                    '''
                }
            }
        }
    }

    post {
        always {
            sh '''
                rm -f "$WORKSPACE/.registry-auth.json"
            '''
        }
    }
}
