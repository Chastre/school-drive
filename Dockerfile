FROM tomcat:9.0-jdk11
COPY build/web/ /usr/local/tomcat/webapps/ROOT/
EXPOSE 8080
CMD ["catalina.sh", "run"]