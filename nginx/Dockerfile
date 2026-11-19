FROM nginx:stable AS base

COPY default.conf /etc/nginx/conf.d/default.conf
COPY nginx.conf   /etc/nginx/nginx.conf

FROM base AS saml

COPY default-saml.conf /etc/nginx/conf.d/default.conf
