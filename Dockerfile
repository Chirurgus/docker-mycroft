FROM arm32v7/debian:10.7-slim

ENV TERM linux
ENV DEBIAN_FRONTEND noninteractive

# Install Server Dependencies for Mycroft
RUN set -x \
	&& sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get -y install git python3 python3-pip locales sudo \
	&& pip3 install future msm \
	# Checkout Mycroft
	&& git clone https://github.com/MycroftAI/mycroft-core.git /opt/mycroft \
	&& cd /opt/mycroft \
	&& mkdir /opt/mycroft/skills \
	# git fetch && git checkout dev && \ this branch is now merged to master
	&& CI=true /opt/mycroft/./dev_setup.sh --allow-root \
	&& mkdir /opt/mycroft/scripts/logs \
	&& touch /opt/mycroft/scripts/logs/mycroft-bus.log \
	&& touch /opt/mycroft/scripts/logs/mycroft-voice.log \
	&& touch /opt/mycroft/scripts/logs/mycroft-skills.log \
	&& touch /opt/mycroft/scripts/logs/mycroft-audio.log \
	&& apt-get -y autoremove \
	&& apt-get clean \
	&& rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* \
	&& rm -rf /opt/mycroft/.git /opt/mycroft/.github /opt/mycroft/doc /opt/mycroft/test \
	&& mv /opt/mycroft/mimic /opt/mycroft/mimic.bak \
	&& mkdir /opt/mycroft/mimic \
	&& mv /opt/mycroft/mimic.bak/bin /opt/mycroft/mimic/ \
	&& mv /opt/mycroft/mimic.bak/lib /opt/mycroft/mimic/ \
	&& mv /opt/mycroft/mimic.bak/voices /opt/mycroft/mimic/ \
	&& rm -rf /opt/mycroft/mimic.bak

# Set the locale
RUN locale-gen en_EI.UTF-8
ENV LANG en_EI.UTF-8
ENV LANGUAGE en_EI:en
ENV LC_ALL en_EI.UTF-8

WORKDIR /opt/mycroft
COPY startup.sh /opt/mycroft
ENV PYTHONPATH $PYTHONPATH:/mycroft/ai

RUN echo "PATH=$PATH:/opt/mycroft/bin" >> $HOME/.bashrc \
        && echo "source /opt/mycroft/.venv/bin/activate" >> $HOME/.bashrc

RUN chmod +x /opt/mycroft/start-mycroft.sh \
	&& chmod +x /opt/mycroft/startup.sh

EXPOSE 8181

ENTRYPOINT "/opt/mycroft/startup.sh"
