# ASA Enrollment token
$asa_enrollment_token = "ENROLLMENT_TOKEN_HERE"

$canonical_file = "---
# CanonicalName: Specifies the name clients should use/see when connecting to this host.
CanonicalName: \"${::hostname}\"
"

#Class for installing ASA
class asa_setup {
    if $facts['os']['family'] == 'Debian' {
        notice("This is: ${::osfamily} - ${::fqdn}")
        include install_deb
    }
    elsif $facts['os']['family'] == 'RedHat' {
        notice("This is: ${::osfamily} - ${::fqdn}")
        include install_rpm
    }
    elsif $facts['os']['family'] == 'Suse' {
        notice("This is: ${::osfamily} - ${::fqdn}")
        include install_rpm
    }
    else {
        notice("This sample doesn't work yet on: ${::osfamily} - ${::fqdn}")
    }
}

#Installing deb package
class install_deb {
    file { '/tmp/scaleft-server-tools_latest_amd64.deb' :
        source => 'https://dist.scaleft.com/server-tools/linux/latest/scaleft-server-tools_latest_amd64.deb'
    } -> package { 'scaleft-server-tools' :
        provider => 'dpkg',
        ensure => 'present',
        source => '/tmp/scaleft-server-tools_latest_amd64.deb'
    }
    include enroll_server
}

#Installing rpm package
class install_rpm {
    #Download and install ASA Server agent
    file { '/tmp/scaleft-server-tools-latest.x86_64.rpm' :
        source => 'https://dist.scaleft.com/server-tools/linux/latest/scaleft-server-tools-latest.x86_64.rpm'
    } -> package { 'scaleft-server-tools' :
        provider => 'rpm',
        ensure => 'present',
        source => '/tmp/scaleft-server-tools-latest.x86_64.rpm'
    }
    include enroll_server
}

class enroll_server {
    notice("inside enroll server")

    # Create canonical file
    file { "/etc/sft":
        ensure => "directory"
    }

    file { "/etc/sft/sftd.yaml":
        ensure => "present",
        content => $canonical_file
    }

    # Set enrollment token
    file { "/var/lib/sftd":
        ensure => "directory"
    }

    file { "/var/lib/sftd/enrollment.token":
        ensure => "present",
        content => $asa_enrollment_token
    }

    service { "sftd":
        ensure => running,
        subscribe => File["/var/lib/sftd/enrollment.token"],
    }

}

include asa_setup

