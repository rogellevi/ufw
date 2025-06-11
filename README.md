## ABRIR PUERTOS AUTOMATICAMENTE

sudo ./abrir_puertos.sh








## ABRIR PUERTOS MANUALMENTE

Ingresar Como ROOT : 
```
sudo su
```

Puertos:
```
ufw allow 22/tcp
```
```
ufw allow 22/udp
```
```
ufw allow 1:65535/tcp
```
```
ufw allow 1:65535/udp
```
```
ufw enable
```
```
apt remove netfilter-persistent
```
```
reboot
```
