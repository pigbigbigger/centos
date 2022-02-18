#! /bin/bash
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/pigbigbigger/centos/main/init_centos.sh)"
# yum -y install dos2unix
#  dos2unix filename
# sudo visudo
#
# /etc/ssh/sshd_config
# change to:
# PasswordAuthentication yes
sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/g' /etc/ssh/sshd_config
systemctl restart sshd

# create user
adduser yaoo
passwd='Yangok1234567'
if [ "$1" != "" ];then
    passwd=$1
fi
echo  "set yaoo pass [$passwd]"
echo -e "$passwd\n$passwd" | passwd yaoo
grep '^yaoo' /etc/sudoers
if [ "$?" != 0 ];then
    # add sudo users.
    sed -i "/^root/a yaoo ALL=(ALL) ALL" /etc/sudoers
fi

# hostnamectl --static set-hostname bcweb.tw
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-*
sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*
yes | yum update

yes | yum install epel-release -y
yes | yum install httpd -y
#systemctl restart httpd


yum install zsh -y
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/p' ~/.zshrc 
source ~/.zshrc   


yes | yum install nginx -y
yum -y install gcc automake autoconf libtool make 
yum install -y centos-release-scl-rh centos-release-scl
yum install devtoolset-7-gcc.x86_64 devtoolset-7-gcc-c++.x86_64 -y
scl enable devtoolset-7 bash
systemctl enable nginx

sudo dnf groupinstall 'development tools'
sudo dnf install wget openssl-devel bzip2-devel libffi-devel
sudo curl https://www.python.org/ftp/python/3.9.1/Python-3.9.1.tgz -O
tar -xvf Python-3.9.1.tgz
cd Python-3.9.1
sudo ./configure --enable-optimizations
sudo make install


if [ ! -f /var/www/html/index.html ];then
	echo "install black index.html"
	echo "" >/var/www/html/index.html
fi

# nginx default html(blank)
if [ ! -f /usr/share/nginx/html/index.html-orig ]; then
	mv /usr/share/nginx/html/index.html /usr/share/nginx/html/index.html-orig
	echo "" >/usr/share/nginx/html/index.html
fi

yes | yum install git
yes | yum install unzip
yes | yum install libconfig

# disable selinux
setenforce 0
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config

curl -sL https://rpm.nodesource.com/setup_16.x | sudo bash -
yes | yum install nodejs -y
npm install -g web3
npm install -g tronweb
npm install -g yarn
npm install -g react-scripts
npm install -g bignumber.js
npm install -g @solana/web3.js
npm install -g bs58
npm install -g tronweb
npm install -g deasync
npm install -g cross-fetch

#export NODE_PATH=/usr/local/lib/node_modules
if ! grep -q '^export NODE_PATH=/usr/local/lib/node_modules' /home/yaoo/.bashrc ; then
	echo 'export NODE_PATH=/usr/local/lib/node_modules' >>/home/yaoo/.bashrc
	source /home/yaoo/.bashrc
fi

alternatives --set python /usr/bin/python3

# install epel-release
dnf install epel-release -y
#dnf install snapd -y
#systemctl enable --now snapd.socket
#systemctl start snapd
#snap install shadowsocks-libev

# add chmod
chmod +rx /var/log/nginx

# ssh passwd
ssh1='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCk8RrRsAAO7MwPh/tzQGG8BD5zc6NpVq1WbMxwQIOBX1YbesW+EZNXvswafECvk+KLPWyRDoAoGJdcS2zJoRzRSYXMdMl+gV4Cexrd6EofuZlB5UiXlTwKMzkKfnPZyHAM+Nwsh0C9ybG9tjSj1QEFralfggOxKVSOHm/ozB0r6GxWWtZtnGjm2COq2XTysgKrSHnPFZnkH29uthm4NvqGTyXC5EikC7yVLKH3tD3sP2MFF7RXiIWH8tCg5co+u4dF0qyXwj0eeengsAZmUbrMvVwK8znb3jIyvW71HSkwuEMj6Q2paNEOzLCL3+HU+nE3ETy8KZ067fTBWEWkfCAFbvme+ckYaAdkYYylDuQGWOWesr+l3PU/T/CZy6IbqV3TaAvIArfu3aiYXG1kwA3AJz3Ylyj7L2il3CS5+5P1kghYUG3xXSQihzQbFwebdXtQXfCqAb6BJCn/881YzOEgG2CJlF/NjpkpdE1zr30FND1s+8nKNL4Bj6ewyDhRdG0= root@instance-1'

mkdir /home/yaoo/.ssh
mkdir /root/.ssh
chmod 700 /home/yaoo/.ssh
chmod 700 /root/.ssh
echo $ssh1 >>/home/yaoo/.ssh/authorized_keys
echo $ssh1 >>/root/.ssh/authorized_keys
chown -R yaoo.yaoo /home/yaoo/.ssh