FROM nginx:alpine
# Copy your local files to the Nginx HTML directory
COPY index.html /usr/share/nginx/html/

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
