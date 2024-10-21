# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.define "Debian12-inetRouter" do |inetrouter|
  inetrouter.vm.box = "/home/max/vagrant/images/debian12"
  inetrouter.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.1.1',
       :libvirt__netmask => '255.255.255.252',
       :libvirt__network_name => 'vagrant-libvirt-inet1',
       :libvirt__always_destroy => false
  inetrouter.vm.provider "libvirt" do |lvirt|
      lvirt.memory = "1024"
      lvirt.cpus = "1"
      lvirt.title = "Debian12-inetRouter"
      lvirt.description = "Виртуальная машина на базе дистрибутива Debian Linux. inetRouter"
      lvirt.management_network_name = "vagrant-libvirt-mgmt"
      lvirt.management_network_address = "192.168.121.0/24"
      lvirt.management_network_keep = "true"
      lvirt.management_network_mac = "52:54:00:27:28:83"
  end
  inetrouter.vm.provision "shell", inline: <<-SHELL
      brd='*************************************************************'
      echo "$brd"
      echo 'Set Hostname'
      hostnamectl set-hostname inetrouter
      echo "$brd"
      sed -i 's/debian12/inetrouter/' /etc/hosts
      sed -i 's/debian12/inetrouter/' /etc/hosts
      echo "$brd"
      echo 'Изменим ttl для работы через раздающий телефон'
      echo "$brd"
      sysctl -w net.ipv4.ip_default_ttl=66
      echo "$brd"
      echo 'Если ранее не были установлены, то установим необходимые  пакеты'
      echo "$brd"
      apt update
      export DEBIAN_FRONTEND=noninteractive
      apt install -y iptables iptables-persistent traceroute
      # Политика по умолчанию для цепочки INPUT - DROP
      iptables -P INPUT DROP
      # Политика по умолчанию для цепочки OUTPUT - DROP
      iptables -P OUTPUT DROP
      # Политика по умолчанию для цепочки FORWARD - DROP
      iptables -P FORWARD DROP
      # Создаём пользовательскую цепочку KNOCKING.
      iptables -N KNOCKING
      # Базовый набор правил: разрешаем локалхост, запрещаем доступ к адресу сети обратной петли не от локалхоста, разрешаем входящие пакеты со статусом установленного сонединения.
      iptables -A INPUT -i lo -j ACCEPT
      iptables -A INPUT ! -i lo -d 127.0.0.0/8 -j REJECT
      iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
      # Разрешим транзит трафика.
      iptables -A FORWARD -j ACCEPT
      # Открываем исходящие
      iptables -A OUTPUT -j ACCEPT
      # NAT
      iptables -t nat -A POSTROUTING ! -d 192.168.0.0/16 -o ens5 -j MASQUERADE
      # Разрешим входящие с хоста управления.
      iptables -A INPUT -s 192.168.121.1 -j ACCEPT
      # Также, разрешим входящие для всех хостов, кроме centralRouter
      iptables -A INPUT ! -s 192.168.1.2 -p tcp -m tcp --dport 22 -j ACCEPT
      # Откроем ICMP ping
      iptables -A INPUT -p icmp -m icmp --icmp-type 8 -j ACCEPT
      # Все входящие соединения, которые ранее не попали ни под одно правило, отправляются в таблицу KNOCKING.
      iptables -A INPUT -j KNOCKING
      # Если IP-адрес источника находится в списке knockfinal (но не более 60 сек.), то пропустить его
      iptables -A KNOCKING -m state --state NEW -p tcp -m tcp --dport 22 -m recent --rcheck --seconds 60 --reap --name knockfinal -j ACCEPT
      # Если IP-адрес источника не находится ни в одном списке и первый порт для аутентификации верный, отбросить пакет и добавить источник в список knock1
      iptables -A KNOCKING -p tcp -m tcp --dport 1111 -m recent --set --name knock1 -j DROP
      # Если IP-адрес источника находится в списке knock1 (но не более 10сек) и второй порт для аутентификации верен, то отбросить пакет и добавить источник в список knock2
      iptables -A KNOCKING -p tcp -m recent --rcheck --seconds 10 --reap --name knock1 -m tcp --dport 2222 -m recent --set --name knock2 -j DROP
      # Если IP-адрес источника находится в списке knock2 (но не более 10сек) и третий порт для аутентификации верен, то отбросить пакет и добавить источник в список knock3
      iptables -A KNOCKING -p tcp -m recent --rcheck --seconds 10 --reap --name knock2 -m tcp --dport 3333 -m recent --set --name knock3 -j DROP
      # Если IP-адрес источника находится в списке knock3 (но не более 10сек) и четвёртый порт для аутентификации верен, то отбросить пакет и добавить источник в список knockfinal
      iptables -A KNOCKING -p tcp -m recent --rcheck --seconds 10 --reap --name knock3 -m tcp --dport 4444 -m recent --set --name knockfinal -j DROP
      # Всё, что не соответствует ни одному из ранее описаных правил, отбрасывается
      iptables -A KNOCKING -j DROP
      netfilter-persistent save
      echo "net.ipv4.conf.all.forwarding = 1" >> /etc/sysctl.conf
      sysctl -p
      ip route add 192.168.1.4/30 via 192.168.1.2
      ip route add 192.168.1.8/30 via 192.168.1.2
      ip route add 192.168.2.0/24 via 192.168.1.2
      ip route add 192.168.3.0/24 via 192.168.1.2
      ip route add 192.168.4.0/24 via 192.168.1.2
      ip route save > /etc/my-routes
      echo 'up ip route restore < /etc/my-routes' >> /etc/network/interfaces
      SHELL
  end

  # \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
  config.vm.define "Debian12-inetRouter2" do |inetrouter2|
  inetrouter2.vm.box = "/home/max/vagrant/images/debian12"
  inetrouter2.vm.network :private_network,
       :type => 'ip',
       :libvirt__host_ip => '192.168.1.22',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.1.17',
       :libvirt__netmask => '255.255.255.248',
       :libvirt__network_name => 'vagrant-libvirt-inet4',
       :libvirt__always_destroy => false
      # :libvirt__mac => '52:54:00:33:c6:0b'
  inetrouter2.vm.provider "libvirt" do |lvirt|
      lvirt.memory = "1024"
      lvirt.cpus = "1"
      lvirt.title = "Debian12-inetRouter2"
      lvirt.description = "Виртуальная машина на базе дистрибутива Debian Linux. inetRouter2"
      lvirt.management_network_name = "vagrant-libvirt-mgmt"
      lvirt.management_network_address = "192.168.121.0/24"
      lvirt.management_network_keep = "true"
      lvirt.management_network_mac = "52:54:00:27:28:90"
   #  lv.storage :file, :size => '1G', :device => 'vdb', :allow_existing => false
  end
    inetrouter2.vm.provision "shell", inline: <<-SHELL
      brd='*************************************************************'
      echo "$brd"
      echo 'Set Hostname'
      hostnamectl set-hostname inetrouter2
      echo "$brd"
      sed -i 's/debian12/inetrouter2/' /etc/hosts
      sed -i 's/debian12/inetrouter2/' /etc/hosts
      echo "$brd"
      echo 'Изменим ttl для работы через раздающий телефон'
      echo "$brd"
      sysctl -w net.ipv4.ip_default_ttl=66
      echo "$brd"
      echo 'Если ранее не были установлены, то установим необходимые  пакеты'
      echo "$brd"
      apt update
      export DEBIAN_FRONTEND=noninteractive
      apt install -y iptables iptables-persistent traceroute
      # Redirect
      iptables -t nat -A PREROUTING -p tcp --dport 8080 -j DNAT --to-destination 192.168.2.2:80
      iptables -t nat -A POSTROUTING -j MASQUERADE
      netfilter-persistent save
      echo "net.ipv4.conf.all.forwarding = 1" >> /etc/sysctl.conf
      sysctl -p
      # ip route del default
      # ip route add default via 192.168.1.18
      ip route add 192.168.1.4/30 via 192.168.1.18
      ip route add 192.168.1.8/30 via 192.168.1.18
      ip route add 192.168.2.0/24 via 192.168.1.18
      ip route add 192.168.3.0/24 via 192.168.1.18
      ip route add 192.168.4.0/24 via 192.168.1.18
      ip route save > /etc/my-routes
      echo 'up ip route restore < /etc/my-routes' >> /etc/network/interfaces
      SHELL
  end

  # //////////////////////////////////////////////////////

  config.vm.define "Debian12-centralRouter" do |centralrouter|
  centralrouter.vm.box = "/home/max/vagrant/images/debian12"
  centralrouter.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.2.1',
       :libvirt__netmask => '255.255.255.224',
       :libvirt__network_name => 'vagrant-libvirt-central1',
       :libvirt__always_destroy => false
  centralrouter.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.2.33',
       :libvirt__netmask => '255.255.255.224',
       :libvirt__network_name => 'vagrant-libvirt-central2',
       :libvirt__always_destroy => false
  centralrouter.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.2.65',
       :libvirt__netmask => '255.255.255.192',
       :libvirt__network_name => 'vagrant-libvirt-central3',
       :libvirt__always_destroy => false
  centralrouter.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.1.2',
       :libvirt__netmask => '255.255.255.252',
       :libvirt__network_name => 'vagrant-libvirt-inet1',
       :libvirt__always_destroy => false
  centralrouter.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.1.5',
       :libvirt__netmask => '255.255.255.252',
       :libvirt__network_name => 'vagrant-libvirt-inet2',
       :libvirt__always_destroy => false  
  centralrouter.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.1.9',
       :libvirt__netmask => '255.255.255.252',
       :libvirt__network_name => 'vagrant-libvirt-inet3',
       :libvirt__always_destroy => false 
  centralrouter.vm.network :private_network,
       :type => 'ip',
       :libvirt__host_ip => '192.168.1.22',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.1.18',
       :libvirt__netmask => '255.255.255.248',
       :libvirt__network_name => 'vagrant-libvirt-inet4',
       :libvirt__always_destroy => false
  centralrouter.vm.provider "libvirt" do |lvirt|
      lvirt.memory = "1024"
      lvirt.cpus = "1"
      lvirt.title = "Debian12-centralRouter"
      lvirt.description = "Виртуальная машина на базе дистрибутива Debian Linux. centralRouter"
      lvirt.management_network_name = "vagrant-libvirt-mgmt"
      lvirt.management_network_address = "192.168.121.0/24"
      lvirt.management_network_keep = "true"
      lvirt.management_network_mac = "52:54:00:27:28:84"
  #   lv.storage :file, :size => '1G', :device => 'vdb', :allow_existing => false
  end
  centralrouter.vm.provision "shell", inline: <<-SHELL
      brd='*************************************************************'
      echo "$brd"
      echo 'Set Hostname'
      hostnamectl set-hostname centralrouter
      echo "$brd"
      sed -i 's/debian12/centralrouter/' /etc/hosts
      sed -i 's/debian12/centralrouter/' /etc/hosts
      echo "$brd"
      echo 'Изменим ttl для работы через раздающий телефон'
      echo "$brd"
      sysctl -w net.ipv4.ip_default_ttl=66
      echo "$brd"
      echo 'Если ранее не были установлены, то установим необходимые  пакеты'
      echo "$brd"
      apt update
      export DEBIAN_FRONTEND=noninteractive
      apt install -y iptables traceroute nmap
      ip route del default
      ip route add default via 192.168.1.1
      ip route add 192.168.3.0/24 via 192.168.1.6
      ip route add 192.168.4.0/24 via 192.168.1.10
      ip route save > /etc/my-routes
      echo 'up ip route restore < /etc/my-routes' >> /etc/network/interfaces
      echo "net.ipv4.conf.all.forwarding = 1" >> /etc/sysctl.conf
      sysctl -p
      echo '#!/bin/bash' > /home/vagrant/knock.sh
      echo 'HOST="$1"' >> /home/vagrant/knock.sh
      echo 'shift' >> /home/vagrant/knock.sh
      echo 'for ARG in "$@"' >> /home/vagrant/knock.sh
      echo 'do' >> /home/vagrant/knock.sh
      echo '        nmap -Pn --host-timeout 100 --max-retries 0 -p "$ARG" "$HOST"' >> /home/vagrant/knock.sh
      echo 'done' >> /home/vagrant/knock.sh
      chown vagrant:vagrant /home/vagrant/knock.sh
      chmod u+x /home/vagrant/knock.sh
      SHELL
  end
  config.vm.define "Debian12-centralServer" do |centralserver|
  centralserver.vm.box = "/home/max/vagrant/images/debian12"
  centralserver.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.2.2',
       :libvirt__netmask => '255.255.255.224',
       :libvirt__network_name => 'vagrant-libvirt-central1',
       :libvirt__always_destroy => false
  centralserver.vm.provider "libvirt" do |lvirt|
      lvirt.memory = "1024"
      lvirt.cpus = "1"
      lvirt.title = "Debian12-centralServer"
      lvirt.description = "Виртуальная машина на базе дистрибутива Debian Linux. centralServer"
      lvirt.management_network_name = "vagrant-libvirt-mgmt"
      lvirt.management_network_address = "192.168.121.0/24"
      lvirt.management_network_keep = "true"
      lvirt.management_network_mac = "52:54:00:27:28:89"
  #   lv.storage :file, :size => '1G', :device => 'vdb', :allow_existing => false
  end
  centralserver.vm.provision "file", source: "dhcp/dhcpd.conf", destination: "~/dhcpd.conf"
  centralserver.vm.provision "file", source: "dhcp/isc-dhcp-server", destination: "~/isc-dhcp-server"
  centralserver.vm.provision "file", source: "dhcp/preseed.cfg", destination: "~/preseed.cfg"
  centralserver.vm.provision "shell", inline: <<-SHELL
      brd='*************************************************************'
      echo "$brd"
      echo 'Set Hostname'
      hostnamectl set-hostname centralserver
      echo "$brd"
      sed -i 's/debian12/centralserver/' /etc/hosts
      sed -i 's/debian12/centralserver/' /etc/hosts
      echo "$brd"
      echo 'Изменим ttl для работы через раздающий телефон'
      echo "$brd"
      sysctl -w net.ipv4.ip_default_ttl=66
      echo "$brd"
      echo 'Если ранее не были установлены, то установим необходимые  пакеты'
      echo "$brd"
      apt update
      export DEBIAN_FRONTEND=noninteractive
      apt install -y traceroute nginx tftpd-hpa isc-dhcp-server
      cp -p /etc/default/isc-dhcp-server $_.bak
      cp -p /etc/dhcp/dhcpd.conf $_.bak
      cp /home/vagrant/isc-dhcp-server /etc/default/
      cp /home/vagrant/dhcpd.conf /etc/dhcp/
      systemctl start isc-dhcp-server.service
      mkdir /var/www/auto
      chown -R www-data: /var/www/auto
      sed -i 's/root \\/var\\/www\\/html;/root \\/var\\/www\\/auto;/' /etc/nginx/sites-enabled/default
      cp /home/vagrant/preseed.cfg /var/www/auto/
      systemctl restart nginx
      wget --directory-prefix=/home/vagrant/ https://deb.debian.org/debian/dists/bookworm/main/installer-amd64/current/images/netboot/netboot.tar.gz
      tar -xzvf /home/vagrant/netboot.tar.gz -C /srv/tftp
      ip route del default
      ip route add default via 192.168.2.1
      ip route save > /etc/my-routes
      echo 'up ip route restore < /etc/my-routes' >> /etc/network/interfaces
      SHELL
  end
  config.vm.define "Debian12-office1Router" do |office1router|
  office1router.vm.box = "/home/max/vagrant/images/debian12"
  office1router.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.1.6',
       :libvirt__netmask => '255.255.255.252',
       :libvirt__network_name => 'vagrant-libvirt-inet2',
       :libvirt__always_destroy => false  
  office1router.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.3.1',
       :libvirt__netmask => '255.255.255.192',
       :libvirt__network_name => 'vagrant-libvirt-office1-1',
       :libvirt__always_destroy => false
  office1router.vm.network :private_network,
       :type => 'ip', 
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.3.65',
       :libvirt__netmask => '255.255.255.192',
       :libvirt__network_name => 'vagrant-libvirt-office1-2',
       :libvirt__always_destroy => false
  office1router.vm.network :private_network,
       :type => 'ip', 
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.3.129',
       :libvirt__netmask => '255.255.255.192',
       :libvirt__network_name => 'vagrant-libvirt-office1-3',
       :libvirt__always_destroy => false
  office1router.vm.network :private_network,
       :type => 'ip', 
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.3.193',
       :libvirt__netmask => '255.255.255.192',
       :libvirt__network_name => 'vagrant-libvirt-office1-4',
       :libvirt__always_destroy => false
  office1router.vm.provider "libvirt" do |lvirt|
      lvirt.memory = "1024"
      lvirt.cpus = "1"  
      lvirt.title = "Debian12-office1Router"
      lvirt.description = "Виртуальная машина на базе дистрибутива Debian Linux. office1Router"
      lvirt.management_network_name = "vagrant-libvirt-mgmt"
      lvirt.management_network_address = "192.168.121.0/24"
      lvirt.management_network_keep = "true"
      lvirt.management_network_mac = "52:54:00:27:28:85"
  #   lv.storage :file, :size => '1G', :device => 'vdb', :allow_existing => false
  end
  office1router.vm.provision "shell", inline: <<-SHELL
      brd='*************************************************************'
      echo "$brd"
      echo 'Set Hostname'
      hostnamectl set-hostname office1router
      echo "$brd"
      sed -i 's/debian12/office1router/' /etc/hosts
      sed -i 's/debian12/office1router/' /etc/hosts
      echo "$brd"
      echo 'Изменим ttl для работы через раздающий телефон'
      echo "$brd"
      sysctl -w net.ipv4.ip_default_ttl=66
      echo "$brd"
      echo 'Если ранее не были установлены, то установим необходимые  пакеты'
      echo "$brd"
      apt update
      apt install -y traceroute
      export DEBIAN_FRONTEND=noninteractive
      echo "net.ipv4.conf.all.forwarding = 1" >> /etc/sysctl.conf
      sysctl -p
      ip route del default
      ip route add default via 192.168.1.5
      ip route save > /etc/my-routes
      echo 'up ip route restore < /etc/my-routes' >> /etc/network/interfaces
      SHELL
  end
  config.vm.define "Debian12-office2Router" do |office2router|
  office2router.vm.box = "/home/max/vagrant/images/debian12"
  office2router.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.1.10',
       :libvirt__netmask => '255.255.255.252',
       :libvirt__network_name => 'vagrant-libvirt-inet3',
       :libvirt__always_destroy => false
  office2router.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.4.1',
       :libvirt__netmask => '255.255.255.128',
       :libvirt__network_name => 'vagrant-libvirt-office2-1',
       :libvirt__always_destroy => false
  office2router.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.4.129',
       :libvirt__netmask => '255.255.255.192',
       :libvirt__network_name => 'vagrant-libvirt-office2-2',
       :libvirt__always_destroy => false
  office2router.vm.network :private_network,
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.4.193',
       :libvirt__netmask => '255.255.255.192',
       :libvirt__network_name => 'vagrant-libvirt-office2-3',
       :libvirt__always_destroy => false
  office2router.vm.provider "libvirt" do |lvirt|
      lvirt.memory = "1024"
      lvirt.cpus = "1"
      lvirt.title = "Debian12-office2Router"
      lvirt.description = "Виртуальная машина на базе дистрибутива Debian Linux. office2Router"
      lvirt.management_network_name = "vagrant-libvirt-mgmt"
      lvirt.management_network_address = "192.168.121.0/24"
      lvirt.management_network_keep = "true"
      lvirt.management_network_mac = "52:54:00:27:28:86"
  #   lv.storage :file, :size => '1G', :device => 'vdb', :allow_existing => false
  end
  office2router.vm.provision "shell", inline: <<-SHELL
      brd='*************************************************************'
      echo "$brd"
      echo 'Set Hostname'
      hostnamectl set-hostname office2router
      echo "$brd"
      sed -i 's/debian12/office2router/' /etc/hosts
      sed -i 's/debian12/office2router/' /etc/hosts
      echo "$brd"
      echo 'Изменим ttl для работы через раздающий телефон'
      echo "$brd"
      sysctl -w net.ipv4.ip_default_ttl=66
      echo "$brd"
      echo 'Если ранее не были установлены, то установим необходимые  пакеты'
      echo "$brd"
      apt update
      apt install -y traceroute
      export DEBIAN_FRONTEND=noninteractive
      echo "net.ipv4.conf.all.forwarding = 1" >> /etc/sysctl.conf
      sysctl -p
      ip route del default
      ip route add default via 192.168.1.9
      ip route save > /etc/my-routes
      echo 'up ip route restore < /etc/my-routes' >> /etc/network/interfaces
      SHELL
  end
  config.vm.define "Debian12-office1Server" do |office1server|
  office1server.vm.box = "/home/max/vagrant/images/debian12"
  office1server.vm.network :private_network,
      # :type => 'dhcp',
      # :libvirt__network_address => '192.168.1.0',
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.3.130',
       :libvirt__netmask => '255.255.255.192',
       :libvirt__network_name => 'vagrant-libvirt-office1-3',
       :libvirt__always_destroy => false
      # :libvirt__mac => '52:54:00:33:c6:0b'
  office1server.vm.provider "libvirt" do |lvirt|
      lvirt.memory = "1024"
      lvirt.cpus = "1"  
      lvirt.title = "Debian12-office1Server"
      lvirt.description = "Виртуальная машина на базе дистрибутива Debian Linux. office1Server"
      lvirt.management_network_name = "vagrant-libvirt-mgmt"
      lvirt.management_network_address = "192.168.121.0/24"
      lvirt.management_network_keep = "true"
      lvirt.management_network_mac = "52:54:00:27:28:87"
  #   lv.storage :file, :size => '1G', :device => 'vdb', :allow_existing => false
  end
  office1server.vm.provision "shell", inline: <<-SHELL
      brd='*************************************************************'
      echo "$brd"
      echo 'Set Hostname'
      hostnamectl set-hostname office1server
      echo "$brd"
      sed -i 's/debian12/office1server/' /etc/hosts
      sed -i 's/debian12/office1server/' /etc/hosts
      echo "$brd"
      echo 'Изменим ttl для работы через раздающий телефон'
      echo "$brd"
      sysctl -w net.ipv4.ip_default_ttl=66
      echo "$brd"
      echo 'Если ранее не были установлены, то установим необходимые  пакеты'
      echo "$brd"
      apt update
      export DEBIAN_FRONTEND=noninteractive
      apt install -y traceroute
      ip route del default
      ip route add default via 192.168.3.129
      ip route save > /etc/my-routes
      echo 'up ip route restore < /etc/my-routes' >> /etc/network/interfaces
      SHELL
  end
  config.vm.define "Debian12-office2Server" do |office2server|
  office2server.vm.box = "/home/max/vagrant/images/debian12"
  office2server.vm.network :private_network,
      # :type => 'dhcp',
      # :libvirt__network_address => '192.168.1.0',
       :type => 'ip',
       :libvirt__forward_mode => 'veryisolated',
       :libvirt__dhcp_enabled => false,
       :ip => '192.168.4.2',
       :libvirt__netmask => '255.255.255.128',
       :libvirt__network_name => 'vagrant-libvirt-office2-1',
       :libvirt__always_destroy => false
      # :libvirt__mac => '52:54:00:33:c6:0b'
  office2server.vm.provider "libvirt" do |lvirt|
      lvirt.memory = "1024"
      lvirt.cpus = "1"
      lvirt.title = "Debian12-office2Server"
      lvirt.description = "Виртуальная машина на базе дистрибутива Debian Linux. office2Server"
      lvirt.management_network_name = "vagrant-libvirt-mgmt"
      lvirt.management_network_address = "192.168.121.0/24" 
      lvirt.management_network_keep = "true"
      lvirt.management_network_mac = "52:54:00:27:28:88"
  #   lv.storage :file, :size => '1G', :device => 'vdb', :allow_existing => false
  end
  office2server.vm.provision "shell", inline: <<-SHELL
      brd='*************************************************************'
      echo "$brd"
      echo 'Set Hostname'		
      hostnamectl set-hostname office2server
      echo "$brd"
      sed -i 's/debian12/office2server/' /etc/hosts
      sed -i 's/debian12/office2server/' /etc/hosts
      echo "$brd"
      echo 'Изменим ttl для работы через раздающий телефон'
      echo "$brd"
      sysctl -w net.ipv4.ip_default_ttl=66
      echo "$brd"
      echo 'Если ранее не были установлены, то установим необходимые  пакеты'
      echo "$brd"
      apt update
      export DEBIAN_FRONTEND=noninteractive
      apt install -y traceroute
      ip route del default
      ip route add default via 192.168.4.1
      ip route save > /etc/my-routes
      echo 'up ip route restore < /etc/my-routes' >> /etc/network/interfaces
      SHELL
  end
end
