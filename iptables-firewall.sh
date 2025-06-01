#!/bin/bash
# Script de configuración de iptables para entorno ASIR
# Autor: Mei Núñez
# Proyecto: VPN con filtrado proxy y autenticación Kerberos+LDAP
# Fecha: 2025-05-01

# === 1. DEFINICIÓN DE VARIABLES ===

# Interfaces asignadas a cada VLAN
Interface_Admin="ens33"      # INTERFAZ VLAN10_Admin
Interface_Usuarios="ens37"   # INTERFAZ VLAN20_Usuarios
Interface_DMZ="ens38"        # INTERFAZ VLAN30_DMZ
Interface_NAT="ens39"        # INTERFAZ Salida a Internet (NAT)

# Subredes de cada VLAN
VLAN10_ADMIN="192.168.10.0/24"      # VLAN10_Admin
VLAN20_USUARIOS="192.168.20.0/24"   # VLAN20_Usuarios
VLAN30_DMZ="192.168.30.0/24"        # VLAN30_DMZ
VPN_SUBNET="10.10.0.0/24"           # VPN

# IPs de servicios
IP_VPN="192.168.10.10"       # Servidor VPN (WireGuard)
IP_LDAP="192.168.10.20"      # Servidor de Autenticación (Kerberos + LDAP + Bind9)
IP_PROXY="192.168.30.10"     # Servidor Proxy (Squid)
IP_WEB="192.168.30.20"       # Servidor Web (Apache)


# === 2. LIMPIEZA DE REGLAS ===
echo "[ 0. ] Limpiando reglas anteriores y aplicando políticas por defecto..."

iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X

iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

# Loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Conexiones establecidas/relacionadas
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT


# === 3. TRÁFICO INTERNO ===
# VLAN10
echo "[ 1. ] Tráfico interno en VLAN10_Admin..."
iptables -A INPUT  -i "$Interface_Admin" -s "$VLAN10_ADMIN" -j ACCEPT
iptables -A OUTPUT -o "$Interface_Admin" -d "$VLAN10_ADMIN" -j ACCEPT
iptables -A FORWARD -i "$Interface_Admin" -o "$Interface_Admin" -s "$VLAN10_ADMIN" -d "$VLAN10_ADMIN" -j ACCEPT

# VLAN20
echo "[ 2. ] Tráfico interno en VLAN20_Usuarios..."
iptables -A INPUT  -i "$Interface_Usuarios" -s "$VLAN20_USUARIOS" -j ACCEPT
iptables -A OUTPUT -o "$Interface_Usuarios" -d "$VLAN20_USUARIOS" -j ACCEPT
iptables -A FORWARD -i "$Interface_Usuarios" -o "$Interface_Usuarios" -s "$VLAN20_USUARIOS" -d "$VLAN20_USUARIOS" -j ACCEPT

# VLAN30
echo "[ 3. ] Tráfico interno en VLAN30_DMZ..."
iptables -A INPUT  -i "$Interface_DMZ" -s "$VLAN30_DMZ" -j ACCEPT
iptables -A OUTPUT -o "$Interface_DMZ" -d "$VLAN30_DMZ" -j ACCEPT
iptables -A FORWARD -i "$Interface_DMZ" -o "$Interface_DMZ" -s "$VLAN30_DMZ" -d "$VLAN30_DMZ" -j ACCEPT

iptables -A FORWARD -s "$VLAN30_DMZ" -d "$IP_LDAP" -p tcp -m multiport --dports 88,389,636,464 -j ACCEPT
iptables -A FORWARD -s "$VLAN30_DMZ" -d "$IP_LDAP" -p udp -m multiport --dports 88,389,464 -j ACCEPT


# === 4. TRÁFICO DESDE VPN ===
echo "[ 4. ] Permitiendo tráfico para establecer el túnel WireGuard (UDP/51820)..."

# Cliente (192.168.20.100) → Servidor VPN (192.168.10.10)
iptables -A FORWARD -i "$Interface_Usuarios" -o "$Interface_Admin" -s "$VLAN20_USUARIOS" -d "$IP_VPN" -p udp --dport 51820 -j ACCEPT


# === 5. VPN: Conectividad entre cliente y servidor VPN ===
echo "[ 5. ] Permitiendo tráfico interno tras establecer la VPN..."

echo "[ 5.1 ] Permitiendo tráfico entre cliente y servidor VPN..."
# VPN cliente (10.10.0.2) ↔ Servidor VPN (10.10.0.1)
iptables -A FORWARD -s "$VPN_SUBNET" -d "$IP_VPN" -j ACCEPT
iptables -A FORWARD -s "$IP_VPN" -d "$VPN_SUBNET" -j ACCEPT

echo "[ 5.2 ] Permitiendo tráfico entre cliente VPN y VLAN10_Admin..."
# VPN ↔ VLAN10_Admin
iptables -A FORWARD -s "$VPN_SUBNET" -d "$VLAN10_ADMIN" -j ACCEPT
iptables -A FORWARD -s "$VLAN10_ADMIN" -d "$VPN_SUBNET" -j ACCEPT

echo "[ 5.3 ] Permitiendo tráfico entre cliente VPN y servidor LDAP/Kerberos..."
# VPN ↔ LDAP/Kerberos (TCP y UDP: 88, 464, 389, 636)
iptables -A FORWARD -s "$VPN_SUBNET" -d "$IP_LDAP" -p tcp -m multiport --dports 88,389,636,464 -j ACCEPT
iptables -A FORWARD -s "$VPN_SUBNET" -d "$IP_LDAP" -p udp -m multiport --dports 88,389,464 -j ACCEPT

echo "[ 5.4 ] Permitiendo tráfico entre cliente VPN y proxy Squid..."
# Permitir tráfico desde clientes VPN al proxy Squid (TCP/3128)
iptables -A FORWARD -s "$VPN_SUBNET" -d "$IP_PROXY" -p tcp --dport 3128 -j ACCEPT

# [ 5.5 ] Bloqueo explícito de tráfico HTTP/HTTPS directo desde clientes VPN (deben usar el proxy)
iptables -A FORWARD -s "$VPN_SUBNET" ! -d "$IP_PROXY" -p tcp -m multiport --dports 80,443 -j REJECT


# === 6. PERMITIR AL PROXY SQUID ACCESO DIRECTO HACIA SERVIDOR WEB ===
echo "[ 6. ] Permitiendo acceso al proxy Squid..."

# Permitir al proxy acceder al servidor web interno (HTTP y HTTPS)
iptables -A FORWARD -s "$IP_PROXY" -d "$IP_WEB" -p tcp -m multiport --dport 80,443 -j ACCEPT

# Permitir acceso a Internet desde el proxy
iptables -A FORWARD -s "$IP_PROXY" -o "$Interface_NAT" -p tcp -m multiport --dports 80,443 -j ACCEPT
# NAT para salida a Internet desde el proxy
iptables -t nat -A POSTROUTING -o "$Interface_NAT" -s "$IP_PROXY" -j MASQUERADE


# 7. PERMITIR DNS A TODAS LAS VLAN HACIA EL SERVIDOR INTERNO
echo "[ 7. ] Permitimos consultas DNS al servidor LDAP..."

# Permitir DNS desde VLAN10 a LDAP
iptables -A FORWARD -s "$VLAN10_ADMIN" -d "$IP_LDAP" -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s "$VLAN10_ADMIN" -d "$IP_LDAP" -p tcp --dport 53 -j ACCEPT

# Permitir DNS desde VLAN20 a LDAP
iptables -A FORWARD -s "$VLAN20_USUARIOS" -d "$IP_LDAP" -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s "$VLAN20_USUARIOS" -d "$IP_LDAP" -p tcp --dport 53 -j ACCEPT

# Permitir DNS desde VLAN30 a LDAP
iptables -A FORWARD -s "$VLAN30_DMZ" -d "$IP_LDAP" -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s "$VLAN30_DMZ" -d "$IP_LDAP" -p tcp --dport 53 -j ACCEPT

# Permitir DNS desde VPN a LDAP
iptables -A FORWARD -s "$VPN_SUBNET" -d "$IP_LDAP" -p udp --dport 53 -j ACCEPT
iptables -A FORWARD -s "$VPN_SUBNET" -d "$IP_LDAP" -p tcp --dport 53 -j ACCEPT


# === 8. REGLAS DE ADMINISTRACIÓN ===
echo "[ 8. ] SSH: Permitir conexiones SSH al router"
iptables -A INPUT  -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# SSH desde el router hacia VLAN10
iptables -A OUTPUT -o "$Interface_Admin" -d "$VLAN10_ADMIN" -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# SSH desde el router hacia VLAN20
iptables -A OUTPUT -o "$Interface_Usuarios" -d "$VLAN20_USUARIOS" -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT

# SSH desde el router hacia VLAN30
iptables -A OUTPUT -o "$Interface_DMZ" -d "$VLAN30_DMZ" -p tcp --dport 22 -m conntrack --ctstate NEW -j ACCEPT


# === 9. GUARDAR REGLAS ===
echo "[ 9. ] Guardando reglas..."

# Guardar reglas iptables
iptables-save > /etc/iptables/rules.v4
echo "[ ✓ ] Reglas iptables guardadas en /etc/iptables/rules.v4."
echo "[ ✓ ] Script de configuración de iptables finalizado."
echo ""
echo "---------------------------------------------"
echo "Contenido actual de /etc/iptables/rules.v4:"
echo "---------------------------------------------"
echo ""
cat /etc/iptables/rules.v4
echo ""
echo "[✓] Reglas iptables aplicadas correctamente."
echo ""
echo " Script: iptables-firewall.sh"
echo ""
