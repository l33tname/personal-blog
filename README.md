Personal Blog
=========


# Production

To run with mysql you need the mysql header files:

```
sudo dnf install mysql-devel
```

Prepare the enviroment:

```
export PASS='YOUR_BCRYPT_HASH'

MariaDB [(none)]> create database $mydbname;
Query OK, 1 row affected (0.00 sec)
```

Run it (local):

```
MYSQL_BLOG_URI=mysql2://user:pass@host/$mydbname bin/rackup -E production
```

Run it (with puma)

```
MYSQL_BLOG_URI=mysql2://user:pass@host/$mydbname bundle exec pumactl -F puma.rb start
MYSQL_BLOG_URI=mysql2://user:pass@host/$mydbname bundle exec pumactl -F puma.rb stop
MYSQL_BLOG_URI=mysql2://user:pass@host/$mydbname bundle exec pumactl -F puma.rb status
MYSQL_BLOG_URI=mysql2://user:pass@host/$mydbname bundle exec pumactl -F puma.rb restart
```

How to create a password

```
bundle exec irb
2.4.2 :001 > require 'bcrypt'
 => true 
2.4.2 :002 > BCrypt::Password.create("mypassword")
 => "$2a$10$nVLSVW6..8SPr4jYH1Glgehme2lXtW50z.p251kQ7mm/lP3rrh4Yi" 
```


# Development

Remove `mysql2` from the gem file if you don't need it.


Install deps:

```
$ bundle install --binstubs --path vendor
$ bin/rackup
```
