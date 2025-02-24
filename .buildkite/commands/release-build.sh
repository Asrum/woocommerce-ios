#!/bin/bash -eu

# Workaround for https://github.com/Automattic/buildkite-ci/issues/79
echo "--- :rubygems: Fixing Ruby Setup"
gem install bundler

echo "--- :arrow_down: Installing Release Dependencies"
brew update # Update homebrew to temporarily fix a bintray issue
brew install imagemagick
brew install ghostscript
brew install sentry-cli

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- :cocoapods: Setting up Pods"
install_cocoapods

echo "--- :closed_lock_with_key: Installing Secrets"
bundle exec fastlane run configure_apply

echo "--- :hammer_and_wrench: Building"
bundle exec fastlane build_and_upload_itc \
  skip_confirm:true \
  skip_prechecks:true \
  create_release:true \
  beta_release:${1:-true} # use first call param, default to true for safety
