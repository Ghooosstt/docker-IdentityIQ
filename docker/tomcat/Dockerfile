FROM tomcat:9.0
ARG IIQ_VERSION
ARG IIQ_PATCH
ENV IIQ_VERSION=${IIQ_VERSION}
ENV IIQ_PATCH=${IIQ_PATCH}
WORKDIR /work

# Get identityiq-<version>.zip from host and unzip it in webapps tomcat directory
COPY identityiq-${IIQ_VERSION}.zip .
RUN unzip identityiq-${IIQ_VERSION}.zip
RUN mv identityiq.war /usr/local/tomcat/webapps/
RUN unzip /usr/local/tomcat/webapps/identityiq.war -d /usr/local/tomcat/webapps/identityiq
RUN rm /usr/local/tomcat/webapps/identityiq.war

# Get identityiq<version><patch>.jar if exist, and unzip it in webapps tomcat directory if the IIQ_PATCH variable environment is set
COPY identityiq-${IIQ_VERSION}${IIQ_PATCH}.ja* .
RUN if [ ! -z "$IIQ_PATCH" ]; then unzip -o identityiq-${IIQ_VERSION}${IIQ_PATCH}.jar -d /usr/local/tomcat/webapps/identityiq; fi

# Copy container startup script
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]