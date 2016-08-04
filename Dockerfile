# The MIT License (MIT)
#
# Copyright (c) 2016 Sabaka OÜ
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

FROM ubuntu:14.04

# Install prerequisites.
RUN export DEBIAN_FRONTEND=noninteractive \
  && apt-get update -qq \
  && BUILD_DEPS="curl make g++" \
  && apt-get install -y -q $BUILD_DEPS inotify-tools \
  && /usr/bin/curl -L https://td-toolbelt.herokuapp.com/sh/install-ubuntu-trusty-td-agent2.sh | sh \
  && td-agent-gem install \
    fluent-plugin-concat \
    fluent-plugin-elasticsearch \
    fluent-plugin-kubernetes_metadata_filter \
    fluent-plugin-parser \
    fluent-plugin-rewrite-tag-filter \
  && apt-get autoremove -y ${BUILD_DEPS} \
  && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
    /usr/share/man /usr/share/doc /usr/share/doc-base

RUN ulimit -n 65536 \
    && sed -i -e "s/USER=td-agent/USER=root/" -e "s/GROUP=td-agent/GROUP=root/" /etc/init.d/td-agent \
    && mkdir /etc/td-agent/conf.d

COPY td-agent.conf /etc/td-agent/
COPY conf.d/main.conf /etc/td-agent/conf.d/
COPY plugin/out_logentries.rb /etc/td-agent/plugin/ 
COPY run.sh /

ENTRYPOINT ["/run.sh"]
