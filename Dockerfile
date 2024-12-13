FROM debian

ENV VERIFIER_VERSION=1.6.3
ENV LOGSTASH_VERSION=8

# Add unstable repo before updating, since openjdk-11-jre no longer exists in stable repo.
RUN echo "deb http://deb.debian.org/debian unstable main non-free contrib" | tee -a /etc/apt/sources.list.d/java.list
RUN apt-get update -y && apt-get install wget gnupg2 openjdk-11-jre apt-transport-https ca-certificates -y --no-install-recommends && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | gpg --dearmor -o /usr/share/keyrings/elastic.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/elastic.gpg] https://artifacts.elastic.co/packages/$LOGSTASH_VERSION.x/apt stable main" | tee /etc/apt/sources.list.d/elastic-${LOGSTASH_VERSION}.x.list
RUN apt-get update -y && apt-get install logstash -y --no-install-recommends && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN wget -q https://github.com/magnusbaeck/logstash-filter-verifier/releases/download/${VERIFIER_VERSION}/logstash-filter-verifier_${VERIFIER_VERSION}_linux_amd64.tar.gz \
    && tar -xvzf logstash-filter-verifier_${VERIFIER_VERSION}_linux_amd64.tar.gz -C /usr/bin \
    && rm logstash-filter-verifier_${VERIFIER_VERSION}_linux_amd64.tar.gz
RUN apt-get clean && rm -rf /var/lib/apt/lists/*
COPY runtests.sh /
CMD ["/runtests.sh"]
