# Prepare the system

DEBIAN_FRONTEND=noninteractive sudo apt-get -y update
DEBIAN_FRONTEND=noninteractive sudo apt-get upgrade -y
DEBIAN_FRONTEND=noninteractive sudo apt-get install -y crudini git

# Clone devstack repo

git clone https://git.openstack.org/openstack-dev/devstack -b stable/newton

sed -i -e 's/pip_version<6/pip_version>0/g' devstack/inc/python

cd devstack

# Prepare 'local.conf'
cat <<- EOF > local.conf
[[local|localrc]]
ADMIN_PASSWORD=openstack
DATABASE_PASSWORD=openstack
RABBIT_PASSWORD=openstack
SERVICE_PASSWORD=openstack
enable_service s-proxy s-object s-container s-account
enable_service h-eng h-api h-api-cfn h-api-cw
SWIFT_HASH=66a3d6b56c1f479c8b4e70ab5c2000f5
SWIFT_REPLICAS=1
SWIFT_DATA_DIR=$DEST/data/swift
EOF

./stack.sh

externalip=$(curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/access-configs/0/external-ip)
sudo crudini --set /etc/nova/nova-cpu.conf vnc novncproxy_base_url "http://$externalip:6080/vnc_auto.html"
sudo systemctl restart devstack@n-cpu.service

echo "You can access Horizon Dashboard at External IP address: http://$externalip/dashboard"
