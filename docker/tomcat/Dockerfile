FROM tomcat:9.0
ARG IIQ_VERSION
ARG IIQ_PATCH
ARG IIQ_CUSTOM_WAR
ENV IIQ_VERSION=${IIQ_VERSION}
ENV IIQ_PATCH=${IIQ_PATCH}
ENV IIQ_CUSTOM_WAR=${IIQ_CUSTOM_WAR}
WORKDIR /work

# Get identityiq-<version>.zip and identityiq.war from host.
COPY identityiq-${IIQ_VERSION}.zi* .
COPY identityiq.wa* .

# If IIQ_CUSTOM_WAR is NOT set to yes, remove custom identityiq.war if the file is present and unzip identityiq-<version>.zip to get default war file.
RUN if [ "$IIQ_CUSTOM_WAR" != "yes" ]; then rm -f identityiq.war && unzip identityiq-${IIQ_VERSION}.zip; fi
# If IIQ_CUSTOM_WAR is set to yes, remove identityiq.zip file and patch.jar if they are present in order to reduce the image size.
RUN if [ "$IIQ_CUSTOM_WAR" = "yes" ]; then rm -f identityiq-${IIQ_VERSION}.zip && rm -f identityiq-${IIQ_VERSION}${IIQ_PATCH}.jar; fi

# Unzip war file
RUN mv identityiq.war /usr/local/tomcat/webapps/
RUN unzip /usr/local/tomcat/webapps/identityiq.war -d /usr/local/tomcat/webapps/identityiq
RUN rm /usr/local/tomcat/webapps/identityiq.war

# Get identityiq<version><patch>.jar if exist.
COPY identityiq-${IIQ_VERSION}${IIQ_PATCH}.ja* .
# Unzip the patch in webapps tomcat directory if there is no custom war and if the IIQ_PATCH variable environment is set.
RUN if [ "$IIQ_CUSTOM_WAR" != "yes" ] && [ ! -z "$IIQ_PATCH" ]; then unzip -o identityiq-${IIQ_VERSION}${IIQ_PATCH}.jar -d /usr/local/tomcat/webapps/identityiq; fi

# Copy container startup script.
WORKDIR /usr/local/tomcat/
COPY entrypoint.sh .
RUN chmod +x entrypoint.sh
ENTRYPOINT [ "./entrypoint.sh" ]