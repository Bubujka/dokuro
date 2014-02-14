function _remove_default_pool {
  rm /etc/php5/fpm/pool.d/www.conf
}

function _chown_php_configs {
  touch /var/log/php5-fpm.log
  touch /var/log/php5-fpm-slow.log
  chown vagrant:vagrant /var/log/php5-fpm.log
  chown vagrant:vagrant /var/log/php5-fpm-slow.log
}

function _run_install_on_each_project {
  cd /vagrant/prj
  for NAME in * ; do 
    cd $NAME
      if [ -f ./install ] ; then
        sudo -u vagrant ./install
      fi
    cd ..
  done
}

function _create_configs_for_all_projects {
  cd /vagrant/prj
  for NAME in * ; do
    _create_php_pool_config $NAME
    _create_nginx_config $NAME
    _create_mysql_database_and_fill_it $NAME
  done
}

function _create_mysql_database_and_fill_it {
  NAME=$1
  echo "drop database if exists \`$NAME\`" | mysql -uroot -pvagrant
  echo "create database \`$NAME\` character set utf8" | mysql -uroot -pvagrant
  if [ -f /vagrant/prj/$NAME/dump.sql ] ; then
    cat /vagrant/prj/$NAME/dump.sql | mysql $NAME
  fi
  if [ -f /vagrant/prj/$NAME/dump.sql.gz ] ; then
    cat /vagrant/prj/$NAME/dump.sql.gz | gunzip | mysql $NAME
  fi
}
function _create_nginx_config {
  NAME=$1
  cp /vagrant/prj/$NAME/nginx.conf /etc/nginx/prj-include/$NAME

  ROOT_DIR="/vagrant/prj/$NAME"
  if [ -d /vagrant/prj/$NAME/www ]; then
    ROOT_DIR="/vagrant/prj/$NAME/www"
  fi 
  cat << EOF > /etc/nginx/sites-enabled/$NAME
server {
  listen *:80;
  server_name $NAME.dokuro.ru;
  set \$php_pool unix:/var/run/php5-fpm-$NAME.sock;
  root $ROOT_DIR;
  location /.git { deny   all; }
  include /etc/nginx/prj-include/$NAME;
}
EOF
}

function _create_php_pool_config {
  NAME=$1
  cat << EOF > /etc/php5/fpm/pool.d/$NAME.conf
[$NAME]
user = vagrant
group = vagrant
listen = /var/run/php5-fpm-$NAME.sock
pm = dynamic
pm.max_children = 5
pm.start_servers = 2
pm.min_spare_servers = 1
pm.max_spare_servers = 3
pm.max_requests = 500
;pm.status_path = /status
;ping.path = /ping
;access.log = log/\$pool.access.log
slowlog = /var/log/php5-fpm-slow.log
request_slowlog_timeout = 10
request_terminate_timeout = 20
;chroot = 
chdir = /
catch_workers_output = yes
env[MYSQL_DATABASE]='mysql://root:vagrant@localhost/$NAME'
php_value[session.save_path]=/tmp/sessions
EOF
}

function _create_directory_for_sessions {
  mkdir /tmp/sessions
  chown vagrant /tmp/sessions
}

function _install_helper_software {
  apt-get -y install nfs-common portmap htop git curl 
}

function _restart_all_servers {
  service php5-fpm restart
  service mysql restart
  service nginx restart
}

function _install_nginx {
  apt-get -y install nginx
}

function _basic_configure_nginx {
  sed -i 's/sendfile on/sendfile off/g' /etc/nginx/nginx.conf
  mkdir /etc/nginx/prj-include
  cat > /etc/nginx/conf.d/dullhost.conf <<EOF
server_names_hash_bucket_size 256;
log_format php  '\$status \$upstream_response_time \$http_host "\$request" '
'\$bytes_sent '
'"\$http_referer" - \$remote_addr - \$remote_user - "\$http_user_agent" '
'\$request_time [\$time_local]';
access_log off;
EOF
}

function _write_php_location_for_nginx {
    cat > /etc/nginx/php_fastcgi <<EOF
location ~ \.php$ {
  access_log  /var/log/nginx/access.log php;
  fastcgi_pass   \$php_pool;
  fastcgi_index  index.php;
  fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
  fastcgi_param  REDIRECT_QUERY_STRING     \$query_string;
  include        fastcgi_params;
}
EOF

    cat > /etc/nginx/php_fastcgi_internal <<EOF
location ~ \.php$ {
  internal;
  access_log  /var/log/nginx/access.log php;
  fastcgi_pass   \$php_pool;
  fastcgi_index  index.php;
  fastcgi_param  SCRIPT_FILENAME  \$document_root\$fastcgi_script_name;
  fastcgi_param  REDIRECT_QUERY_STRING     \$query_string;
  include        fastcgi_params;
}
EOF


}

function _enable_xdebug_profile {
  echo 'xdebug.profiler_enable_trigger=on' >> /etc/php5/conf.d/xdebug.ini 
}

function _install_composer {
  curl -sS https://getcomposer.org/installer | php
  mv composer.phar /usr/local/bin/composer
}

function _install_php {
  apt-get -y install php5-mysql php5-fpm php5-curl php5-cli php5-xdebug php5-mcrypt 
}

function _update_apt {
  apt-get update
}

function _install_mysql {
  debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password vagrant'
  debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password vagrant'
  apt-get -y install mysql-server mysql-client 
}

function _allow_mysql_connect_from_any_host {
  mysql -uroot -pvagrant -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'vagrant' WITH GRANT OPTION; FLUSH PRIVILEGES;"
  sed -i 's/127\.0\.0\.1/0.0.0.0/g' /etc/mysql/my.cnf
}

function _write_mysql_config_to_mycnf {
  cat > ~/.my.cnf <<EOL
[client]
host            = localhost
user            = root
password            = vagrant
port            = 3306
default_character_set = utf8

[mysqldump]
no-tablespaces
EOL

  cat > /home/vagrant/.my.cnf <<EOL
[client]
host            = localhost
user            = root
password            = vagrant
port            = 3306
default_character_set = utf8

[mysqldump]
no-tablespaces
EOL
}
