#!/bin/bash
# ----------------------------------------------------------------------------
# 02_install_awscli2.sh
# ----------------------------------------------------------------------------
# Makes sure AWS CLI v2 is present on AMI.
# Remark: On Amazon Linux 2023, AWS CLI v2 is already installed.
# ----------------------------------------------------------------------------

set -u

echo 'Check installation'
aws --version

