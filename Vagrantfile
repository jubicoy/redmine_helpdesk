# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.define "mysql" do |c|
    c.vm.box = "ubuntu/trusty64"
    c.vm.hostname = "mysql"
    c.vm.network "forwarded_port", guest: 3306, host: 3306
    c.vm.provision "shell", inline: <<-HERE
      sudo -i
      DEBIAN_FRONTEND=noninteractive apt-get install -y mysql-server
      echo "CREATE DATABASE redmine" | mysql -uroot
      echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;" | mysql -uroot
      sed -i 's/^bind-address.*/bind-address    = 0\.0\.0\.0/' /etc/mysql/my.cnf
      service mysql restart
    HERE
  end

  config.vm.define "postgresql" do |c|
    c.vm.box = "ubuntu/trusty64"
    c.vm.hostname = "postgresql"
    c.vm.network "forwarded_port", guest: 5432, host: 5432
    c.vm.provision "shell", inline: <<-HERE
      sudo -i
      DEBIAN_FRONTEND=noninteractive apt-get install -y postgresql postgresql-contrib
      sudo -H -u postgres bash -c "psql -c 'create database redmine;' -U postgres"
      echo "host    all     all     0.0.0.0/0   trust" >> /etc/postgresql/9.3/main/pg_hba.conf
      echo "listen_addresses = '*'" >> /etc/postgresql/9.3/main/postgresql.conf
      service postgresql restart
    HERE
  end
end
