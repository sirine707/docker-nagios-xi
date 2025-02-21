FROM centos/systemd

# Fix CentOS 7 repo issue by switching to vault.centos.org
RUN sed -i 's|mirrorlist=.*|#mirrorlist=|' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|' /etc/yum.repos.d/CentOS-*.repo && \
    yum clean all && \
    yum makecache

# Install dependencies
RUN yum install -y wget tar mariadb-server httpd php php-mysql php-xml php-mbstring net-snmp perl-Net-SNMP xinetd unzip sudo cronie shadow-utils && yum clean all

WORKDIR /tmp
	
# Download and extract Nagios XI
RUN wget -nv "https://assets.nagios.com/downloads/nagiosxi/5/xi-5.4.10.tar.gz" && \
    tar -zxf xi-5.4.10.tar.gz

WORKDIR /tmp/nagiosxi

# Ensure installation files are available
RUN ls -l ./xi-sys.cfg && chmod +r ./xi-sys.cfg

# Run the installation
RUN ./init.sh && \
    . ./xi-sys.cfg && \
    . ./functions.sh && \
    run_sub ./0-repos noupdate && \
    run_sub ./1-prereqs && \
    run_sub ./2-usersgroups && \
    run_sub ./3-dbservers && \
    run_sub ./4-services && \
    run_sub ./5-sudoers && \
    run_sub ./9-dbbackups && \
    run_sub ./10-phplimits && \
    run_sub ./11-sourceguardian && \
    run_sub ./12-mrtg && \
    run_sub ./13-timezone && \
    /usr/bin/mysqld_safe --skip-grant-tables & \
    ./fix-ndoutils.sh && \
    run_sub ./A-subcomponents && \
    run_sub ./B-installxi && \
    run_sub ./C-cronjobs && \
    run_sub ./D-chkconfigalldaemons && \
    run_sub ./E-importnagiosql && \
    run_sub ./F-startdaemons && \
    run_sub ./Z-webroot

# Expose Apache port
EXPOSE 80

# Copy and set up run script
COPY run.sh /usr/local/bin/run.sh
RUN chmod +x /usr/local/bin/run.sh

# Enable systemd in Docker
VOLUME [ "/sys/fs/cgroup" ]

# Set entrypoint to run systemd and then execute Nagios
CMD ["/usr/local/bin/run.sh"]
