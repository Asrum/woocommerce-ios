#!/bin/bash -eu

echo "--- 📦 Downloading Build Artifacts"
buildkite-agent artifact download build-products.tar .
tar -xf build-products.tar

# FIXIT-13.1: Temporary fix until we're on the Xcode 13.1 VM
echo "--- :rubygems: Fixing Ruby Setup"
gem install bundler

echo "--- :rubygems: Setting up Gems"
install_gems

echo "--- 🧪 Testing"
bundle exec fastlane test_without_building name:UnitTests
