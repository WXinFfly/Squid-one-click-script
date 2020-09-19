# !/bin/bash   
echo "更新系统所有软件包"      
yum -y update 
echo "安装squid"  
yum install squid -y 
echo "安装httpd-tools"  
yum install httpd-tools -y 
read -p "代理端口：" port
read -p "代理用户名：" username
read -p "代理密码：" password
myip=$(curl -s ifconfig.me) 
echo '系统ip：' $myip
mkdir /etc/squid3/
htpasswd -cb /etc/squid3/passwords $username $password
echo '#
# Recommended minimum configuration:
#

# Example rule allowing access from your local networks.
# Adapt to list your (internal) IP networks from where browsing
# should be allowed
acl localnet src 10.0.0.0/8     # RFC1918 possible internal network
acl localnet src 172.16.0.0/12  # RFC1918 possible internal network
acl localnet src 192.168.0.0/16 # RFC1918 possible internal network
acl localnet src fc00::/7       # RFC 4193 local private network range
acl localnet src fe80::/10      # RFC 4291 link-local (directly plugged) machines

acl SSL_ports port 443
acl Safe_ports port 80          # http
acl Safe_ports port 21          # ftp
acl Safe_ports port 443         # https
acl Safe_ports port 70          # gopher
acl Safe_ports port 210         # wais
acl Safe_ports port 1025-65535  # unregistered ports
acl Safe_ports port 280         # http-mgmt
acl Safe_ports port 488         # gss-http
acl Safe_ports port 591         # filemaker
acl Safe_ports port 777         # multiling http
acl CONNECT method CONNECT

#
# Recommended minimum Access Permission configuration:
#
# Deny requests to certain unsafe ports
http_access deny !Safe_ports

# Deny CONNECT to other than secure SSL ports
http_access deny CONNECT !SSL_ports

# Only allow cachemgr access from localhost
http_access allow localhost manager
http_access deny manager

# We strongly recommend the following be uncommented to protect innocent
# web applications running on the proxy server who think the only
# one who can access services on "localhost" is a local user
#http_access deny to_localhost

#
# INSERT YOUR OWN RULE(S) HERE TO ALLOW ACCESS FROM YOUR CLIENTS
#

# Example rule allowing access from your local networks.
# Adapt localnet in the ACL section to list your (internal) IP networks
# from where browsing should be allowed
http_access allow localnet
http_access allow localhost
cache_mem 60 MB
visible_hostname ' $username '
# And finally deny all other access to this proxy
#http_access deny all
auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid3/passwords
auth_param basic realm proxy
acl authenticated proxy_auth REQUIRED
http_access allow authenticated
http_access deny all
#http_access allow all

# Squid normally listens to port 3128
http_port ' $port '
forwarded_for off

header_access Via deny all

header_access X-Forwarded-For deny all

#auth_param basic program /usr/lib64/squid/basic_ncsa_auth /etc/squid3/passwords
#auth_param basic realm proxy
#acl authenticated proxy_auth REQUIRED
#http_access allow authenticated

# Uncomment and adjust the following to add a disk cache directory.
#cache_dir ufs /var/spool/squid 100 16 256

# Leave coredumps in the first cache dir
coredump_dir /var/spool/squid
#dns_nameservers 8.8.8.8
#
# Add any of your own refresh_pattern entries above these.
#
refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern .               0       20%     4320
' >> /etc/squid/squid.conf6

mv /etc/squid/squid.conf6 /etc/squid/squid.conf
echo "==========代理信息============"
echo "代理IP："$myip
echo "代理端口："$port
echo "代理用户名："$username
echo "代理密码："$password
echo "==========代理信息============"

echo '==========代理信息============
代理IP：'$myip'
代理端口：'$port'
代理用户名：'$username'
代理密码： '$password'
==========代理信息============' >> /etc/squid/proxy.txt
echo '代理信息保存在/etc/squid/proxy.txt文件中'
echo '配置成功'
systemctl enable squid
echo '开机自启设置完成'
systemctl start squid
echo 'squid启动成功'