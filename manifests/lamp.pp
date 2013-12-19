group { 'puppet': ensure => present }
Exec { path => [ '/bin/', '/sbin/', '/usr/bin/', '/usr/sbin/'] }
File { owner => 0, group => 0, mode => 0644 }
 
class httpd {

    package { "httpd":
        ensure => present
    }

    package { "httpd-devel":
        ensure  => present
    }

    package {[
			"iptables",

		]: 
			ensure => present;
	}


    service { 
        "iptables":
			require    => Package["iptables"],
			hasstatus  => true,
			status     => "true",
			hasrestart => false
			;
        'httpd':
            name      => 'httpd',
            require   => Package["httpd"],
            ensure    => running,
            enable    => true,
	    hasrestart => true
    }

    file {
        "/etc/sysconfig/iptables":
		    owner   => "root",
		    group   => "root",
		    mode    => 600,
		    replace => true,
		    ensure  => present,
		    source  => "/vagrant/files/iptables.txt",
		    require => Package["iptables"],
		    notify  => Service["iptables"]
		;
		
        "/etc/hosts":
		    replace => true,
		    ensure  => present,
		    source  => "/vagrant/files/etc/hosts",
		    recurse => true
		;
        
        "/etc/httpd/conf/httpd.conf":
		    replace => true,
		    ensure  => present,
		    source  => "/vagrant/files/httpd/conf/httpd.conf",
		    recurse => true
		;
		
        "/etc/httpd/conf.d/vhost.conf":
		    replace => true,
		    ensure  => present,
		    source  => "/vagrant/files/httpd/conf.d/vhost.conf"
		;

	    "/etc/httpd/vhosts":
		    replace => true,
		    ensure  => present,
		    source  => "/vagrant/files/httpd/vhosts",
		    recurse => true
		;
	}

    exec {
		'yum-update':
			command => '/usr/bin/yum -y update',
			require => Exec["grap-epel"],
            timeout => 0
			;
		"grap-epel":
			command => "/bin/rpm -Uvh http://www.mirrorservice.org/sites/dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm",
			creates => "/etc/yum.repos.d/epel.repo",
			alias   => "grab-epel"
			;
	}
}



class { '::mysql::server':
    root_password    => 'root',
    override_options => { 'mysqld' => { 'max_connections' => '1024' } }
}


class php {

    package { "php":
        ensure  => present,
    }

	package { "php-cli":
        ensure  => present,
    }

    package { "php-mcrypt":
        ensure  => present,
        require => Exec["grab-epel"],
    }

    package { "php-common":
        ensure  => present,
    }

    package { "php-devel":
        ensure  => present,
    }

    package { "php-mbstring":
        ensure  => present,
    }

    package { "php-xmlrpc":
        ensure  => present,
    }

    package { "php-soap":
        ensure  => present,
    }

    package { "php-gd":
        ensure  => present,
    }

    package { "php-xml":
        ensure  => present,
	    require => Package["httpd"],
	    notify  => Service["httpd"]
    }

    package { "php-intl":
        ensure  => present,
    }

    package { "php-mysql":
        ensure  => present,
    }

    package { "php-pdo":
        ensure  => present,
    }

    package { "php-pear":
        ensure  => present,
    }

    package { "php-pecl-apc":
        ensure  => present,
    }
}

include httpd
include '::mysql::server'
include php
