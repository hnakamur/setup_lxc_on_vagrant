setup_lxc_on_vagrant
====================

A Vagrantfile using the shell provisioner to setup LXC

## Setup

### Ubuntu 14.04

```
cp Vagrantfile.ubuntu1404 Vagrantfile
vagrant up && vagrant reload
vagrant ssh
```

### Ubuntu 16.04

```
cp Vagrantfile.ubuntu1604 Vagrantfile
vagrant up
vagrant ssh
```

## Create and use containers

When the provision finishes, you can create and start a container like this.

```
sudo lxc-create -n trusty1 -t download -- -d ubuntu -r trusty -a amd64
sudo lxc-start -n trusty1
```

List containers.

```
$ sudo lxc-ls -f
NAME    STATE   AUTOSTART GROUPS IPV4      IPV6
trusty1 RUNNING 0         -      10.0.3.110 -
```

You can address the container with the container name or the container name followed by ".lxc".

```
vagrant@vagrant:~$ ping -c 1 trusty1
PING trusty1 (10.0.3.110) 56(84) bytes of data.
64 bytes from trusty1.lxc (10.0.3.110): icmp_seq=1 ttl=64 time=0.037 ms

--- trusty1 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.037/0.037/0.037/0.000 ms
vagrant@vagrant:~$ ping -c 1 trusty1.lxc
PING trusty1.lxc (10.0.3.110) 56(84) bytes of data.
64 bytes from trusty1.lxc (10.0.3.110): icmp_seq=1 ttl=64 time=0.064 ms

--- trusty1.lxc ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 0.064/0.064/0.064/0.000 ms
```

Stop a container.

```
sudo lxc-stop -n trusty1
```

## Use a fixed IP address for a container

```
echo 'trusty1,10.0.3.10' | sudo sh -c 'cat > /etc/lxc/dnsmasq-hosts.conf'
sudo killall -SIGHUP dnsmasq
sudo lxc-start -n trusty1
```

```
vagrant@vagrant:~$ sudo lxc-ls -f
NAME    STATE   AUTOSTART GROUPS IPV4      IPV6
trusty1 RUNNING 0         -      10.0.3.10 -
```

## Enable autostart a container

Add a line `lxc.start.auto = 1` to the /var/lib/lxc/${container_name}/config file.
See [第25回　LXCの構築・活用 \[11\] ─lxc-autostartコマンドによるコンテナの自動起動：LXCで学ぶコンテナ入門 －軽量仮想化環境を実現する技術｜gihyo.jp … 技術評論社](http://gihyo.jp/admin/serial/01/linux_containers/0025?page=1) for more details.

## Tested version

```
$ vagrant box list | grep ubuntu
box-cutter/ubuntu1604      (virtualbox, 2.0.16)
ubuntu/trusty64            (virtualbox, 20160406.0.0)
$ vagrant --version
Vagrant 1.8.1
$ VBoxManage --version
5.0.16r105871
```

## License
MIT
