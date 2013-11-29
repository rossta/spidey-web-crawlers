#!/usr/bin/env bash
RUBY_VERSION=ruby-1.9.3-p484
apt-get -y update
apt-get -y install build-essential libyaml-dev zlib1g-dev openssl libssl-dev libreadline-gplv2-dev
cd /tmp
wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/$RUBY_VERSION.tar.gz
tar -xvzf $RUBY_VERSION.tar.gz
cd $RUBY_VERSION/
sudo ./configure --prefix=/usr/local
sudo make
sudo make install
gem install chef ruby-shadow --no-ri --no-rdoc
