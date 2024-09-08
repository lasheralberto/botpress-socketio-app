FROM nginx:alpine

# Elimina archivos estáticos antiguos (si los hay)
RUN rm -rf /usr/share/nginx/html/*

# Copia solo los archivos de salida de tu aplicación Flutter (por ejemplo, build/web) al directorio de Nginx
COPY build/web /usr/share/nginx/html

# Copia la configuración personalizada de Nginx
COPY ./conf/app.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
