# Use the official Nginx image from the Docker Hub
FROM nginx:latest

# Copy the local HTML file and other assets to the Nginx HTML directory
COPY index.html /usr/share/nginx/html/index.html
COPY style.css /usr/share/nginx/html/style.css
COPY images/ /usr/share/nginx/html/images/

# Expose port 80 to the outside world
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
