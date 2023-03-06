FROM jenkins/jenkins:lts-jdk11
ARG gid_docker=999
ARG uid_user=root
ARG gid_user=root
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
https://download.docker.com/linux/debian \
$(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce docker-ce-cli
containerd.io docker-compose-plugin build-essential curl vim ssh netcat
RUN systemctl enable docker.service
RUN systemctl enable containerd.service
RUN groupmod -g ${gid_docker} docker # gid grupo docker
RUN usermod -aG docker jenkins
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
RUN apt-get install -y nodejs
USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean:1.25.6
docker-workflow:521.v1a_a_dd2073b_2e docker-plugin:1.2.9
docker-build-step:2.8"
USER root
RUN usermod -u $uid_user jenkins # uid usuario equipo base
RUN groupmod -g $gid_user jenkins # gid grupo principal usuario base
RUN chown -R jenkins:jenkins /usr/share/jenkins/
RUN chown -R jenkins:jenkins /var/jenkins_home/
USER jenkins