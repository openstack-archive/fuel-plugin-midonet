# Define the midonet repositories based on the settings file
$midonet_settings = hiera('midonet-fuel-plugin')
$mem = $midonet_settings['mem']
$mem_version = $midonet_settings['mem_version']
$mem_user = $midonet_settings['mem_repo_user']
$mem_password = $midonet_settings['mem_repo_password']
$oss_version = 'v2015.06'

$key_content = "-----BEGIN PGP PUBLIC KEY BLOCK-----
Version: GnuPG v1

mI0ETb6aOgEEAMVw8Vnwk+zpDtsc0gSW10JEe48zKr2vpl9tQgWAFOPgOA1NglYM
w/xT6Rns7CrYxPR0cb3DeMFtFdMkfWXO0R6x4yHrozMDY/DpvwgYQclIIbcYYe0p
83nlBp793D2dSq60HWuXJu3oi0wQQuR0/jTmOnjxzCzu5jKdJeXihl95ABEBAAG0
Jk1pZG9rdXJhIChNaWRva3VyYSkgPGluZm9AbWlkb2t1cmEuanA+iLgEEwECACIF
Ak2+mjoCGwMGCwkIBwMCBhUIAgkKCwQWAgMBAh4BAheAAAoJEGezjToFQxTNAp0D
/2c+PLnRFzEXCztXT+05xoO1mPzpm3x2p5ecVPGHR8IxhozlN9DDGDdnvNfMOhi6
nv/G2l86+9Fj8Dz01ne0RZzZHSS1DF/zb6dMYrPJqiT1DXKH0Y73OL/+M7rsutEq
0B/DKhjdBfFPutk3gerEUZPNfIhScE3tnwCnVGJKPQbFuI0ETb6aOgEEANLJK3gm
Xrsp1VKnt663RoxZgoFQgQ6wHaZZWhULTteafjoThX9tj7FidR2+7qJLwpa57M9d
rib4OlbW+rE4PW199/Uqfy86gLv76Q2GZMpzaYB1ZZow0Ny1RTCwh7apkhR/8fCU
pq37aODQ4YwBpZC54iXVKfcntpdJFoObIqXtABEBAAGInwQYAQIACQUCTb6aOgIb
DAAKCRBns406BUMUzfzOBACKx4jChKTAl6HfldOxVN7o8DQpd5rgkHIEj062ym4Z
q5t2v3oaz0H0P2WV66MAhOujgX0V1duZi8fKHdIsdk0nvEa/mV0QS6pEAeZh+dbL
kKyu1J4MSi5l+L+te5XjYBGpoRa3ZGrIR3CkA0oQDCOh312SrcH6Tn9RBPChVSig
zg==
=zF5K
-----END PGP PUBLIC KEY BLOCK-----"

include apt
include apt::update

# MidoNet Neutron plugin Liberty key
apt::source {'midonet_neutron_liberty':
  comment     => 'midonet plugin repository',
  location    => 'http://builds.midonet.org/openstack-liberty',
  release     => 'stable',
  key         => '99143E75',
  key_source  => 'https://builds.midonet.org/midorepo.key',
  include_src => false
}

if $mem {
  apt::key { 'BC4E4E90DDA81C21396081CC67B38D3A054314CD':
    key_content => $key_content
  } ->

  # MEM 1.9 public key
  apt::source {'midonet_oss':
    comment     => 'midonet repository',
    location    => "http://${mem_user}:${mem_password}@apt.midokura.com/midonet/${mem_version}/stable",
    release     => 'trusty',
    include_src => false
  }

} else {

  # OSS 2015.06
  apt::source {'midonet_oss':
    comment     => 'midonet repository',
    location    => 'http://repo.midonet.org/midonet/v2015.06',
    release     => 'stable',
    key         => '50F18FCF',
    key_source  => 'https://repo.midonet.org/packages.midokura.key',
    include_src => false
  }
}
