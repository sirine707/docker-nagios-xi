FROM centos:7 
# Fix CentOS 7 repository issue
RUN sed -i 's|mirrorlist=.*|#mirrorlist=|' /etc/yum.repos.d/CentOS-*.repo && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|' /etc/yum.repos.d/CentOS-*.repo && \
    yum clean all && \
    yum makecache

RUN yum install -y wget tar && \
    yum clean all
WORKDIR /tmp
	
RUN wget -nv "https://assets.nagios.com/downloads/nagiosxi/5/xi-5.4.10.tar.gz"

RUN tar -zxf xi-5.4.10.tar.gz
		
WORKDIR /tmp/nagiosxi

ENV INTERACTIVE="False"
ENV INSTALL_PATH=/tmp/nagiosxi

RUN sed -i "s/selinux/sudoers/g" 9-dbbackups 

COPY xi-sys.cfg ./xi-sys.cfg
COPY fix-ndoutils.sh ./fix-ndoutils.sh


# Run Nagios XI Installation
RUN ./init.sh ; \
    . ./xi-sys.cfg ; \
    . ./functions.sh ; \
    run_sub ./0-repos noupdate ; \
    run_sub ./1-prereqs ; \
    run_sub ./2-usersgroups ; \
    run_sub ./3-dbservers ; \
    run_sub ./4-services ; \
    run_sub ./5-sudoers ; \
    run_sub ./9-dbbackups ; \
    run_sub ./10-phplimits ; \
    run_sub ./11-sourceguardian ; \
    run_sub ./12-mrtg ; \
    run_sub ./13-timezone ; \
    /usr/bin/mysqld_safe --skip-grant-tables & \
    ./fix-ndoutils.sh ; \
    run_sub ./A-subcomponents ; \
    run_sub ./B-installxi ; \
    run_sub ./C-cronjobs ; \
    run_sub ./D-chkconfigalldaemons ; \
    run_sub ./E-importnagiosql ; \
    run_sub ./F-startdaemons ; \
    run_sub ./Z-webroot

    EXPOSE 80

    COPY run.sh /usr/local/bin/run.sh
    CMD ["run.sh"]
    