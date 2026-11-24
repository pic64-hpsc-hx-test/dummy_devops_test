#! groovy
// (c) 2026 Microchip Technology Inc.
// SPDX-License-Identifier: MIT

// HPSC-9071 validation branch: the BUILD job of devops_dummy_project for the relpipe release pipeline.
// It stands in for a component build job (like p64h-toolchain's Jenkinsfile.p64h): it builds, tests and archives
// the release artifacts and its build vars, and never publishes. The release job (Jenkinsfile_Release) releases
// one of its builds without rebuilding (relpipeArtifacts.resolve / checkBuild).
//
// Archived per build (what relpipeArtifacts reads):
//   devops_dummy_project-<v>_build_vars.txt              release=v<v>, git_id, branch_name, build_num
//   devops_dummy_project-<v>-x86_64-linux.tar.gz(.sha256) the "release artifacts" attached to the GitHub release
// SIMULATE breaks a build on purpose, to check that the release job refuses it (validation guide, phase C).

pipeline {
    agent {
        node {
            label 'hpsc_build_node_alma9'
        }
    }
    parameters {
        choice(name: 'SIMULATE', choices: ['none', 'fail-unit-tests', 'skip-package'], description: '''none: normal build.
fail-unit-tests: the "Unit tests" stage fails (the build is FAILURE).
skip-package: the "Package" stage is skipped (the build is SUCCESS but a required stage did not run and nothing is archived).''')
        booleanParam(name: 'PUBLISH_RELEASE', defaultValue: false, description: 'Only to test the release job: a build that ran with a publish parameter set must be refused (forbidden_build_params)')
    }
    environment {
        COMPONENT = 'devops_dummy_project'
        RELEASE_VERSION = '0.1.0'
    }
    options {
        buildDiscarder(logRotator(numToKeepStr: '20', artifactNumToKeepStr: '10'))
        timestamps()
    }
    stages {
        stage('Checkout') {
            steps {
                script {
                    def results = checkout scm
                    env.GIT_COMMIT = results.GIT_COMMIT
                    sh label: 'built commit', script: 'git log -1 --format="%H %s"'
                    // Build vars first, so that even a failed or incomplete build has them and the release job's
                    // build check (not a missing file) is what refuses it. Keys read by relpipeArtifacts.resolveBuild
                    // (same format as buildVars.write).
                    writeFile file: "${env.COMPONENT}-${env.RELEASE_VERSION}_build_vars.txt", text: """release=v${env.RELEASE_VERSION}
git_id=${env.GIT_COMMIT}
branch_name=${env.BRANCH_NAME}
build_num=${env.BUILD_NUMBER}
"""
                    archiveArtifacts artifacts: "${env.COMPONENT}-*_build_vars.txt", fingerprint: true
                }
            }
        }
        stage('Build') {
            steps {
                sh label: 'build', script: 'make clean all'
            }
        }
        stage('Unit tests') {
            steps {
                script {
                    if (params.SIMULATE == 'fail-unit-tests') {
                        error 'SIMULATE=fail-unit-tests'
                    }
                    sh label: 'unit tests', script: 'make unit-tests'
                }
            }
        }
        stage('Package') {
            when { expression { params.SIMULATE != 'skip-package' } }
            steps {
                script {
                    String name = "${env.COMPONENT}-${env.RELEASE_VERSION}-x86_64-linux.tar.gz"
                    sh label: 'package', script: """
                        set -e
                        make package VERSION='${env.RELEASE_VERSION}'
                        cp 'build/${env.COMPONENT}_${env.RELEASE_VERSION}.tar.gz' '${name}'
                        sha256sum '${name}' > '${name}.sha256'
                    """
                    archiveArtifacts artifacts: "${env.COMPONENT}-*-x86_64-linux.tar.gz*", fingerprint: true
                }
            }
        }
    }
}
