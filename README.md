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

## 🧪 Entorno de despliegue

Este conjunto de configuraciones ha sido desarrollado para un entorno con las siguientes características técnicas:

- 🌐 VPN WireGuard para acceso remoto seguro
- 📡 Servidor DNS interno con BIND9
- 🧩 Autenticación Kerberos + OpenLDAP
- 🧱 Proxy Squid con ACLs y autenticación
- 🗂️ Infraestructura segmentada por VLANs:
  - VLAN10_ADMIN (Administración)
  - VLAN20_USUARIOS (Usuarios)
  - VLAN30_DMZ (Servicios públicos)

---

📎 *Todos los archivos están referenciados y documentados en el desarrollo oficial del TFG.*

✍️ **Autora**: Mei Núñez  
📅 **Curso**: 2024–2025 | **Centro**: Ciclo Superior ASIR
