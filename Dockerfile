FROM    exoplatform/base-jdk:jdk8
LABEL   maintainer="eXo Platform <docker@exoplatform.com>"

ARG JMETER_VERSION=3.3

# RUN apt-get update && apt-get install
RUN groupadd --gid 1000 jmeter && useradd --gid 1000 --uid 1000 -d /usr/local/jmeter jmeter

RUN cd /usr/local && wget -O jmeter.tgz https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && tar xzf jmeter.tgz \
    && ln -s apache-jmeter-${JMETER_VERSION} jmeter && rm jmeter.tgz \
    && chown -R jmeter:jmeter apache-jmeter-${JMETER_VERSION}

RUN cd /usr/local/jmeter/lib/ext && wget -O plugins-manager.jar https://jmeter-plugins.org/get/

# Install Console status logger 0.1
RUN cd /usr/local/jmeter && wget -O plugin.zip https://jmeter-plugins.org/files/packages/jpgc-csl-0.1.zip && unzip plugin.zip && rm plugin.zip

# Install Custom Thread Group 2.4
RUN cd /usr/local/jmeter && wget -O plugin.zip https://jmeter-plugins.org/files/packages/jpgc-casutg-2.4.zip && unzip plugin.zip && rm plugin.zip

####
## Configuration
RUN echo "# This switch is needed for some JMeter Plugins reports" >> /usr/local/jmeter/bin/user.properties \
    && echo "jmeter.save.saveservice.thread_counts=true" >> /usr/local/jmeter/bin/user.properties

ENV JVM_ARGS=-"Duser.language=en -Duser.region=EN"

USER jmeter

WORKDIR /usr/local/jmeter

ENTRYPOINT ["/usr/local/jmeter/bin/jmeter"]
