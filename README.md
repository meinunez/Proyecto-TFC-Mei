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

## ⚙️ Entorno de despliegue

Este conjunto de configuraciones ha sido desarrollado para un entorno con las siguientes características técnicas:

- 🌐 **VPN WireGuard** para acceso remoto seguro de clientes ubicados fuera de la red interna.
- 📡 **Servidor DNS interno (BIND9)** utilizado para la resolución de nombres FQDN en todo el entorno.
- 🧩 **Autenticación centralizada mediante Kerberos + OpenLDAP**.
- 🔒 **Servidor web Apache** configurado con:
  - 🧠 **SSO mediante Kerberos** (`mod_auth_kerb`)
  - 🔁 **Fallback a autenticación LDAP** si el cliente no soporta SSO
- 🧱 **Proxy Squid** configurado como proxy autenticado mediante LDAP, con:
  - 📜 **ACLs de filtrado de contenido**
  - 🚫 **Redirección personalizada** a una página de acceso denegado
- 🗂️ **Infraestructura segmentada por VLANs**, con aislamiento y control de tráfico mediante reglas `iptables`:
  - 🔧 `VLAN10_ADMIN`: Servidores internos y gestión (VPN, Kerberos+LDAP, DNS)
  - 👥 `VLAN20_USUARIOS`: Clientes finales conectados vía VPN
  - 🌍 `VLAN30_DMZ`: Servicios accesibles a través del proxy (Apache y Squid)


---

📎 *Todos los archivos están referenciados y documentados en el desarrollo oficial del TFG.*

✍️ **Autora**: Mei Núñez  
📅 **Curso**: 2024–2025 | **Centro**: Ciclo Superior ASIR
