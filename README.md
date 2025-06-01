# 🎓 Proyecto-TFG-Mei


🔧 **Configuraciones del Proyecto TFG ASIR – Mei Núñez**

Este repositorio contiene los **archivos de configuración esenciales** utilizados en el despliegue de servicios para mi Proyecto de Fin de Grado del ciclo **Administración de Sistemas Informáticos en Red (ASIR)**.

---

## 📂 Archivos incluidos

🔐 `firewall.sh`  
→ Reglas `iptables` aplicadas en el router. Segmentación entre VLANs, redirección de tráfico HTTP/HTTPS al proxy, y refuerzo de seguridad.

🛡️ `squid.conf`  
→ Configuración de Squid con autenticación LDAP, control de acceso mediante ACLs y redirección a páginas personalizadas para contenido bloqueado.

🌐 `web-server-mei-nunez.conf`  
→ Virtual Host de Apache para redirigir automáticamente tráfico HTTP al puerto HTTPS (443).

🔒 `web-server-mei-nunez-ssl.conf`  
→ Virtual Host Apache con HTTPS. Sirve recursos accesibles desde el proxy, incluyendo `prohibido.html` y `denegado.html`.

---

📎 *Todos los archivos están referenciados y documentados en el desarrollo del TFG.*

✍️ **Autora**: Mei Núñez  |   📅 **Curso**: 2024–2025
