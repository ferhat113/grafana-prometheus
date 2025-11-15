# Use the official Nginx image from the Docker Hub
FROM nginx:latest

# Install necessary dependencies
RUN apt update && apt install wget -y

# Download and install node-exporter to /opt to avoid volume conflict
RUN mkdir -p /opt/node_exporter && \
    cd /tmp && \
    wget -q https://github.com/prometheus/node_exporter/releases/download/v1.10.2/node_exporter-1.10.2.linux-amd64.tar.gz && \
    tar xzvf node_exporter-1.10.2.linux-amd64.tar.gz && \
    mv node_exporter-1.10.2.linux-amd64/node_exporter /opt/node_exporter/ && \
    rm -rf node_exporter-1.10.2.linux-amd64* && \
    /opt/node_exporter/node_exporter --version

# Copy the local HTML file and other assets to the Nginx HTML directory
COPY index.html /usr/share/nginx/html/index.html
COPY style.css /usr/share/nginx/html/style.css
COPY images/ /usr/share/nginx/html/images/

# Create a startup script
RUN echo '#!/bin/bash\n\
echo "Starting node_exporter..."\n\
/opt/node_exporter/node_exporter &\n\
echo "Node exporter started with PID: $!"\n\
echo "Starting nginx..."\n\
nginx -g "daemon off;"' > /start.sh && \
    chmod +x /start.sh

# Expose ports for both nginx (80) and node-exporter (9100)
EXPOSE 80 9100

# Start both services
CMD ["/bin/bash", "/start.sh"]
