FROM tomcat:9.0-jdk11
COPY web/ /usr/local/tomcat/webapps/ROOT/
COPY build/web/WEB-INF/ /usr/local/tomcat/webapps/ROOT/WEB-INF/
EXPOSE 8080
CMD ["catalina.sh", "run"]