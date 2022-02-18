#!/bin/bash
# 使用rpm安装mysql8.0.25

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
cur_dir=$(pwd)

Color_Text()
{
    echo -e " \e[0;$2m$1\e[0m"
}

Echo_Red()
{
    echo $(Color_Text "$1" "31")
}

Echo_Green()
{
    echo $(Color_Text "$1" "32")
}

Echo_Yellow()
{
    echo $(Color_Text "$1" "33")
}

Echo_Blue()
{
    echo $(Color_Text "$1" "34")
}

# Check if user is root
if [ $(id -u) != "0" ]; then
    Echo_Red "Error: 请使用root权限"
    exit 1
fi

cd ~

if [ ! -d "/root/mysql" ];then
    Echo_Blue '[info] 创建文件夹：/root/mysql'
    mkdir /root/mysql
else
    Echo_Yellow "[info] 文件夹/root/mysql已经存在，继续执行..."
fi

cd /root/mysql
# wget https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-8.0.18-1.el8.x86_64.rpm-bundle.tar

if [ ! -f "/root/mysql/mysql-8.0.25-1.el8.x86_64.rpm-bundle.tar" ];then
    Echo_Blue '[info] Mysql包不存在，正在下载'
    wget https://mirrors.huaweicloud.com/mysql/Downloads/MySQL-8.0/mysql-8.0.25-1.el8.x86_64.rpm-bundle.tar
else
    Echo_Blue "[info] Mysql包已存在，继续执行..."
fi

if [ ! -f "/root/mysql/mysql-8.0.25-1.el8.x86_64.rpm-bundle.tar" ];then
    Echo_Red '[error] 下载mysql安装包失败'
    exit
else
    Echo_Blue "[info] 解压中，继续执行..."
    tar -xvf mysql-8.0.25-1.el8.x86_64.rpm-bundle.tar
fi

#rpm -qa|grep mariadb
#rpm -e mariadb-libs-5.5.56-2.el7.x86_64 --nodeps

# 原代码：if command -v libaio >/dev/null 2>&1 ; then
# if [[ `command -v libaio` = "" ]];then
#     Echo_Yellow '[OK] libaio已安装';
# else
#     Echo_Yellow '[info] 正在安装libaio';
#     yum install libaio -y
# fi

if [ ! -f "mysql-community-common-8.0.25-1.el8.x86_64.rpm" ];then
    Echo_Red '[error] 解压失败，请检查'
    exit
else
    Echo_Green "[info] MySQL安装中，继续执行..."
    rpm -ivh mysql-community-common-8.0.25-1.el8.x86_64.rpm --nodeps --force
    rpm -ivh mysql-community-libs-8.0.25-1.el8.x86_64.rpm --nodeps --force
    rpm -ivh mysql-community-client-8.0.25-1.el8.x86_64.rpm --nodeps --force
    rpm -ivh mysql-community-server-8.0.25-1.el8.x86_64.rpm --nodeps --force
fi

# 添加到/etc/my.cnf mysqld下
if [ `grep -c "default_authentication_plugin=mysql_native_password" /etc/my.cnf` -eq '0' ]; then
    sed -i 's/\[mysqld\]/\[mysqld\]\ndefault_authentication_plugin=mysql_native_password/' /etc/my.cnf
    Echo_Blue "[info] 配置default_authentication_plugin=mysql_native_password"
else
    Echo_Yellow "[info] /etc/my.cnf已存在default_authentication_plugin=mysql_native_password"
fi
#sql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES
if [ `grep -c "sql_mode" /etc/my.cnf` -eq '0' ]; then
    sed -i 's/\[mysqld\]/\[mysqld\]\nsql_mode=NO_ENGINE_SUBSTITUTION,STRICT_TRANS_TABLES/' /etc/my.cnf
    Echo_Green "[info] 配置sql_mode完成"
else
    Echo_Blue "[info] /etc/my.cnf已存在sql_mode"
fi

# 添加自定义内容
if [ `grep -c "huahuacaocao" /etc/my.cnf` -eq '0' ]; then
    # 往MySQL配置文件追加内容
    cat >> /etc/my.cnf<<EOF
log_bin=huahuacaocao
slow_query_log=1
slow-query-log-file=/var/log/mysql-slow.log
long_query_time=1
EOF
fi

# default_authentication_plugin=mysql_native_password

mysqld --initialize
if [ `grep -c "mysql" /etc/group` -eq '0' ]; then
    Echo_Yellow "[info] 不存在mysql用户，正在添加"
    groupadd mysql
    useradd -s /sbin/nologin -M -g mysql mysql
else
    Echo_Yellow "[info] 授予mysql用户权限"
    chown mysql:mysql /var/lib/mysql -R
    if [ ! -f "/var/log/mysqld.log" ];then
        Echo_Red "[error] /var/log/mysqld.log文件不存在，请检查。"
    else
        Echo_Green "[info] 原始密码："
        cat /var/log/mysqld.log|grep "A temporary password is generated for root@localhost:" |awk -F "host:" '{print $2}'
        Echo_Yellow "[info] 请先修改密码mysql_secure_installation"
    fi
    Echo_Green "[info] 安装完成，正在启动... 请耐心等待"
fi

systemctl start mysqld.service

Echo_Green "[info] 执行完成，请退出。"

# /var/log/mysqld.log生成随机密码
# 重置密码：mysql_secure_installation
# sql_mode=STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISIO

# 自动创建用户和数据库
#mysql -uroot -palpha6789 -e "show databases;"