#!/bin/bash

# Install Vapor (see: https://docs.vapor.codes/3.0/install/ubuntu/)
eval "$(curl -sL https://apt.vapor.sh)"
apt-get -y install vapor

# Build Vapor app
vapor build

# @todo: add testing (SwiftyMock via CocoaPods including "rake mock" etc to run tests on Linux)