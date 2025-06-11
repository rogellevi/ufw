## ABRIR PUERTOS AUTOMATICAMENTE

sudo ./abrir_puertos.sh

```
wget https://raw.githubusercontent.com/rogellevi/ufw/master/install.sh && chmod +x install.sh && ./install.sh
```



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
