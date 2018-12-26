#!/bin/bash
      mkdir /dev/sr0
      DLIST="/var/lib/etcd /etc/kubernetes /etc/cni /opt/cni /var/lib/cni /var/run/calico /opt/rke"
        for dir in $DLIST; do
          echo "Removing $dir"
          rm -rf $dir
        done
      CLIST=$(docker ps -qa)
      if [ "x"$CLIST == "x" ]; then
        echo "No containers exist - skipping container cleanup"
        else
          docker rm -f $CLIST
      fi
      ILIST=$(docker images -a -q)
      if [ "x"$ILIST == "x" ]; then
        echo "No images exist - skipping image cleanup"
      else
       docker rmi $ILIST
      fi
      VLIST=$(docker volume ls -q)
      if [ "x"$VLIST == "x" ]; then
        echo "No volumes exist - skipping volume cleanup"
      else
        docker volume rm -f $VLIST
      fi
      wait-for-docker
      sudo ros service enable kernel-extras
      sudo ros service up kernel-extras
      modprobe ipmi_devintf; modprobe ipmi_si
      new_hostname=$(sudo system-docker run --privileged -v /usr/src:/usr/src -v /lib/modules:/lib/modules kfox1111/ipmitool lan print 1 | grep "IP Address  " | sed 's/.* //' | sed 's/\./-/g')
      echo ${new_hostname}
      match="#cloud-config"
      script="hostname: "
      insert="$script$new_hostname"
      sudo wget -O /etc/cloud-config.yml https://raw.githubusercontent.com/kachind/rancheros-cloud-config/master/cloud-config.yml
      sudo sed -i "s/$match/$match\n$insert/" /etc/cloud-config.yml
      echo Y | ros install -f -c /etc/cloud-config.yml -d /dev/sda
