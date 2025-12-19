# Use official nginx image as base
FROM nginx:alpine

# Copy the HTML file to nginx's default directory
COPY index.html /usr/share/nginx/html/index.html

# Copy all image files
COPY *.jpeg /usr/share/nginx/html/
COPY *.png /usr/share/nginx/html/
COPY *.jpg /usr/share/nginx/html/

# Copy covers directory
COPY covers/ /usr/share/nginx/html/covers/

# Copy nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
