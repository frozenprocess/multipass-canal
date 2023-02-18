#!/bin/bash

rm -rf release
mkdir release

PREPARE=`base64 prepare.sh -w 0`
CONTROL=`base64 control.sh -w 0`
NODE=`base64 node.sh -w 0`

cat > release/control-init.yaml <<-EOF
package_update: true
packages:
  - conntrack
disable_root: false
users:
  - default
  - name: ubuntu
    groups: sudo
    shell: /bin/bash
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvW2dRLu0PLQeQ5q5X76RaPvh8/lhhTzucdOizgzJfbUClve4KVCivtB1/S0rX6uuZL6TZhtRDrB1bVGAkwnt6zTT/irQ1ly1AseLAGIdA+03ikQ4gD1hL+MPURko4O9qWyDpBzPtjinRkXYTPdDe3g5jj1CZMI8uw+oOwdxf/9efeEfiQZ+pZuqgtEJttxWx3NrLqiyZhiciSVoRxyXkOltMdovzNeeeRB0KkFKhjSWhjTW0QRJ19ZsDtH3lxChQd7YFfTtYL0oe3ZkRINzHwfr1vzTVaolWTF70H4LWFaTZpmFWZ+WmmXNriUHwov2TBsCYRMAJkM72PAi8WmtWR calico@cloud
write_files:
- encoding: b64
  content: $PREPARE
  owner: root:root
  path: /root/prepare.sh
- encoding: b64
  content: $CONTROL
  owner: root:root
  path: /root/control.sh

runcmd:
  - [ /usr/bin/chmod, +x, /root/prepare.sh ]
  - [ /root/prepare.sh ]
  - [ /usr/bin/chmod, +x, /root/control.sh ]
  - [ /root/control.sh ]
  - [ /usr/bin/chown, -R, ubuntu:ubuntu, /home/ubuntu ]


power_state:
  mode: reboot
EOF


cat > release/node-init.yaml <<-EOF
package_update: true
packages:
  - conntrack
ssh_keys:
  rsa_private: |
    -----BEGIN RSA PRIVATE KEY-----
    MIIEowIBAAKCAQEAr1tnUS7tDy0HkOauV++kWj74fP5YYU87nHTos4MyX21Apb3u
    ClQor7Qdf0tK1+rrmS+k2YbUQ6wdW1RgJMJ7es00/4q0NZctQLHiwBiHQPtN4pEO
    IA9YS/jD1EZKODvalsg6Qcz7Y4p0ZF2Ez3Q3t4OY49QmTCPLsPqDsHcX//Xn3hH4
    kGfqWbqoLRCbbcVsdzay6osmYYnIklaEccl5DpbTHaL8zXnnkQdCpBSoY0loY01t
    EESdfWbA7R95cQoUHe2BX07WC9KHt2ZESDcx8H69b801WqJVkxe9B+C1hWk2aZhV
    mflpplza4lB8KL9kwbAmETACZDO9jwIvFprVkQIDAQABAoIBAGGevNGREh+UrdWY
    1g3WNuSWkbbj0Ue62DCtVK46p1xAcfDS3yWY3F2UI6etvqic+zN4NolyadCSjHU/
    b5aHPj6K5qosCU6cLnEJlnXiMcmXHTC4F+j5IeqJPlt6Fe9gQrwWE3h2KKytc0Y8
    Waczx6C9/es3O2q/srF/hLhEVHQFAUzVQ0VAYdHZUcWgrTRtCi+etXaYssXLbuH/
    R0UVb4qctEHRbE9LwLOG8u7o+xC9xYnmMUKAKgyEwwYIR5F1kR3Ebl/cx10owfqV
    YhF7V3hbpAbNUdsdhG/Wv3Q3pRFzz3hRGQpfFPG1PINpf3j5oGTbMzdxuT6ddbq+
    1wNsWcECgYEA3HXqkoRx5bSvIMhrOQJmrXjxo5ecWfa8sLohJJYkka9G3TprA4fy
    9p1IbPgkzDO0RQmCxKQt3Z7OC5mk1owevpF+sJEEFYKhRdOoS8u3VONp6vWUikVc
    hdpeWAOWOc7tiYMyew6+NprBNF2YbgnRnNXdErfGYGt4p2+Yn19+jIUCgYEAy6Ah
    OR8pTaGu2p6WYHJtYPa90zHwVSSBcpNREVoNrIPo/YEOZDPCnKTEX+rHoEdSS1lC
    n2E3hytP7vv/sPGRz2R7h2+2Off47smdt4wJ6zoioOTPjWnCUfix4Kjay5WGswSJ
    tsMVe2WTaUV/bG/d23du4CLmVHnZOmJK0Ml4iJ0CgYBCBgJhLM8bdvg3vi32XdS4
    QQ9E6gPGIZGy75s7ZMfA5Zg4auVfolhOKR5mnA4RJa7oOgfysiSWSZf1e2cVZdNT
    SSmC4XsyofOAgPnW8USPZKf02OVKX6ls4M/+VdyopWMYGrWEiw7GNaSE9T7QPZqL
    +LSDhYwgli8FHfO8TxIMLQKBgQCv5frtIjsGwcWPOvGCDTbpTRw7pWcL1cYw2Itu
    JtGrFiQdYO+ypXfW4wp0JRcfIJ05U7kWft99129sbam6C2O+uPlwzJKozsnuVKH2
    nXUwCv9A54dXjGV9dA0MmjCvLtK2MBRamXkkKGHHzW4+mQAYhrpzyhIYJU3+fkxM
    wc1qjQKBgF7erwUBI5zt+vPcurh/pANDWuEOz1zqBr3svqXytI8UvySuHP9qfHY0
    JLdAyiMNRolMOEVe7umTbB95DifK7DqK2bTw9jrtUdOJ18G5cTf3+pv8NZKCg0B8
    56E90uQJS9aJ/qVZiubWiZpFuIX2tqjulqpp9aN3NbA/Uv8YJa78
    -----END RSA PRIVATE KEY-----

  rsa_public: ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCvW2dRLu0PLQeQ5q5X76RaPvh8/lhhTzucdOizgzJfbUClve4KVCivtB1/S0rX6uuZL6TZhtRDrB1bVGAkwnt6zTT/irQ1ly1AseLAGIdA+03ikQ4gD1hL+MPURko4O9qWyDpBzPtjinRkXYTPdDe3g5jj1CZMI8uw+oOwdxf/9efeEfiQZ+pZuqgtEJttxWx3NrLqiyZhiciSVoRxyXkOltMdovzNeeeRB0KkFKhjSWhjTW0QRJ19ZsDtH3lxChQd7YFfTtYL0oe3ZkRINzHwfr1vzTVaolWTF70H4LWFaTZpmFWZ+WmmXNriUHwov2TBsCYRMAJkM72PAi8WmtWR calico@cloud

write_files:
- encoding: b64
  content: $PREPARE
  owner: root:root
  path: /root/prepare.sh
- encoding: b64
  content: $NODE
  owner: root:root
  path: /root/node.sh

runcmd:
  - [ /usr/bin/chmod, +x, /root/prepare.sh ]
  - [ /root/prepare.sh ]
  - [ /usr/bin/chmod, +x, /root/node.sh ]
  - [ /root/node.sh ]
  - [ /usr/bin/chown, -R, ubuntu:ubuntu, /home/ubuntu ]

power_state:
  mode: reboot
EOF
