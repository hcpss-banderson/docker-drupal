FROM nginx:mainline

COPY default-saml.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf   /etc/nginx/nginx.conf
