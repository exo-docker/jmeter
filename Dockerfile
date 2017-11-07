FROM exoplatform/base-jdk:jdk8

ARG JMETER_VERSION=2.13
ARG JMETER_PLUGIN_VERSION=1.1.0

# RUN apt-get update && apt-get install
RUN groupadd --gid 1000 jmeter && useradd --gid 1000 --uid 1000 -d /usr/local/jmeter jmeter

RUN cd /usr/local && wget -O jmeter.tgz https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && tar xzf jmeter.tgz \
    && ln -s apache-jmeter-${JMETER_VERSION} jmeter && rm jmeter.tgz \
    && chown -R jmeter:jmeter apache-jmeter-${JMETER_VERSION}

WORKDIR /usr/local/jmeter

RUN cd /usr/local/jmeter/lib/ext && wget -O jmeter-plugins.zip https://jmeter-plugins.org/downloads/file/JMeterPlugins-${JMETER_PLUGIN_VERSION}.zip \
    && unzip -n jmeter-plugins.zip \
    && rm jmeter-plugins.zip

RUN cd /usr/local/jmeter/lib/ext && wget -O jmeter-plugins-lib.zip https://jmeter-plugins.org/downloads/file/JMeterPlugins-libs-${JMETER_PLUGIN_VERSION}.zip \
    && unzip -n jmeter-plugins-lib.zip \
    && rm jmeter-plugins-lib.zip

####
## Configuration
RUN echo "# This switch is needed for some JMeter Plugins reports" >> /usr/local/jmeter/bin/user.properties \
    && echo "jmeter.save.saveservice.thread_counts=true" >> /usr/local/jmeter/bin/user.properties

USER jmeter

ENTRYPOINT ["/usr/local/jmeter/bin/jmeter"]
