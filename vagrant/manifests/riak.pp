Exec { 
    path => [ "/bin/", "/sbin/" , "/usr/bin/", "/usr/sbin/" ], 
    logoutput => true,
}

stage { 'preinstall':   before => Stage['main'] }
class update_first {    exec { 'apt-get -y update': }}
class { 'update_first': stage => preinstall }

# Fix locales
$locales = ["LANGUAGE=en_US.UTF-8", "LANG=en_US.UTF-8", "LC_ALL=en_US.UTF-8"]
exec { 'locale-UTF-8':
    command     => "locale-gen en_US.UTF-8; dpkg-reconfigure locales",
    environment => $locales,
}

package { 'curl':
    ensure => present
}

exec { 'riak-repository':
    command => "curl https://packagecloud.io/install/repositories/basho/riak/script.deb | bash",
    unless  => 'test $(apt-cache search riak | awk \'{print $$1}\') == ""',
    require => Package['curl'],
}

package { 'riak':
    ensure  => '2.0.0-1',
    require => Exec['riak-repository'],
}

service { 'riak':
    ensure  => 'running',
    enable  => 'true',
    require => Package['riak'],
}

file { '/etc/riak/riak.conf':
    source  => '/tmp/riak.conf',
    ensure  => present,
    replace => true,
    require => Package['riak'],
}

exec { 'riak-ip-addr-update':
    command => "sed -i s/$ipaddress_lo/$ipaddress_eth1/g /etc/riak/riak.conf",
    onlyif  => "grep $ipaddress_lo /etc/riak/riak.conf",
    require => File['/etc/riak/riak.conf'],
    notify  => Service['riak'],
}

##
## OPTIMIZATIONS
##
$ropt = "optimization-riak-"
$limits_conf = "/etc/security/limits.conf"
$sysctl_conf = "/etc/sysctl.conf"
$riak_sysctl_conf = "/tmp/riak.sysctl.conf"
$riak_sysctl_10gb_conf = "/tmp/riak.sysctl_10gb.conf"

exec { "${ropt}security-limits":
    command => "echo \"riak\tsoft\tnofile\t4096\nriak\thard\tnofile\t65536\" >> $limits_conf",
    unless  => 'test $(apt-cache search riak | awk \'{print $$1}\') == ""',
}

exec { "${ropt}ulimit-set":
    command => "ulimit -n 65536",
    unless  => "test $(ulimit -n) != 65536",
}

exec { "${ropt}sysctl":
    command => "cat ${riak_sysctl_conf} >> $sysctl_conf",
    unless  => 'test $(apt-cache search vm. | awk \'{print $$1}\') == ""'
}

exec { "${ropt}sysctl-10g":
    command => "cat ${riak_sysctl_10gb_conf} >> $sysctl_conf",
    unless  => ''
