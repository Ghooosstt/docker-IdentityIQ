FROM tomcat:9.0
ARG IIQ_VERSION
ENV IIQ_VERSION=${IIQ_VERSION}
WORKDIR /work

# Get identityiq-<version>.zip from host and unzip it in webapps tomcat directory
COPY identityiq-${IIQ_VERSION}.zip .
RUN unzip identityiq-${IIQ_VERSION}.zip
RUN mv identityiq.war /usr/local/tomcat/webapps/
RUN unzip /usr/local/tomcat/webapps/identityiq.war -d /usr/local/tomcat/webapps/identityiq
RUN rm /usr/local/tomcat/webapps/identityiq.war

# Copy container startup script
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]