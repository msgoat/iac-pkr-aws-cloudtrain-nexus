#!/bin/bash
# ----------------------------------------------------------------------------
# 00_init.sh
# ----------------------------------------------------------------------------
# Performs some basic initialization steps like updating all packages etc.
# ----------------------------------------------------------------------------

echo 'updating installed packages'
sudo dnf update -y

echo 'installing missing packages'
sudo dnf install -y gettext