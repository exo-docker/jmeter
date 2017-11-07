FROM exoplatform/base-jdk:jdk8

ARG JMETER_VERSION=3.1

# RUN apt-get update && apt-get install
RUN groupadd --gid 1000 jmeter && useradd --gid 1000 --uid 1000 -d /usr/local/jmeter jmeter

RUN cd /usr/local && wget -O jmeter.tgz https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-${JMETER_VERSION}.tgz && tar xzf jmeter.tgz \
    && ln -s apache-jmeter-${JMETER_VERSION} jmeter && rm jmeter.tgz \
    && chown -R jmeter:jmeter apache-jmeter-${JMETER_VERSION}

ARG JMETER_PLUGIN_VERSION=1.4.0

RUN cd /usr/local/jmeter && wget -O jmeter-plugins-standard.zip https://jmeter-plugins.org/downloads/file/JMeterPlugins-Standard-1.4.0.zip \
    && unzip -n jmeter-plugins-standard.zip \
    && rm jmeter-plugins-standard.zip

RUN cd /usr/local/jmeter && wget -O jmeter-plugins-extras.zip https://jmeter-plugins.org/downloads/file/JMeterPlugins-Extras-1.4.0.zip \
    && unzip -n jmeter-plugins-extras.zip \
    && rm jmeter-plugins-extras.zip

RUN cd /usr/local/jmeter && wget -O jmeter-plugins-extraslibs.zip https://jmeter-plugins.org/downloads/file/JMeterPlugins-ExtrasLibs-1.4.0.zip \
    && unzip -n jmeter-plugins-extraslibs.zip \
    && rm jmeter-plugins-extraslibs.zip

COPY entrypoint.sh /
RUN chmod a+x /entrypoint.sh

####
## Configuration
RUN echo "# This switch is needed for some JMeter Plugins reports" >> /usr/local/jmeter/bin/user.properties \
    && echo "jmeter.save.saveservice.thread_counts=true" >> /usr/local/jmeter/bin/user.properties

ENV JVM_ARGS=-"Duser.language=en -Duser.region=EN"

USER jmeter

WORKDIR /usr/local/jmeter

ENTRYPOINT ["/entrypoint.sh"]
