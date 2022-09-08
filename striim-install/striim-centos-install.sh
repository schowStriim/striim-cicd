GREEN=$'\e[0;32m'
RED=$'\e[0;31m'
NC=$'\e[0m'

startup_config=/opt/striim/conf/startUp.properties

# Install Java JDK (1.8)
echo "${GREEN} Install Java JDK 1.8 ${NC}"
curl -0 -L https://striim-downloads.s3.us-west-1.amazonaws.com/jdk-8u341-linux-x64.tar.gz --output jdk-8u341-linux-x64.tar.gz
mkdir -p /usr/lib/jvm
tar zxvf jdk-8u341-linux-x64.tar.gz -C /usr/lib/jvm
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_341/bin/java" 1
update-alternatives --set java /usr/lib/jvm/jdk1.8.0_341/bin/java

# Install Striim
echo "${GREEN} Install Striim Version 4.1.0.1 ${NC}"
curl -L https://striim-downloads.striim.com/Releases/4.1.0.1/striim-dbms-4.1.0.1-Linux.rpm --output striim-dbms-4.1.0.1-Linux.rpm
curl -L https://striim-downloads.striim.com/Releases/4.1.0.1/striim-node-4.1.0.1-Linux.rpm --output striim-node-4.1.0.1-Linux.rpm
sudo rpm -ivh striim-dbms-4.1.0.1-Linux.rpm
sudo rpm -ivh striim-node-4.1.0.1-Linux.rpm

# Setup Striim's credentials
echo "${GREEN} Setup Striim Credentials ${NC}"
sudo su - striim /opt/striim/bin/sksConfig.sh

sed -i 's/WAClusterName=/'"WAClusterName=$cluster_name"'/' $startup_config
sed -i 's/CompanyName=/'"CompanyName=$company_name"'/' $startup_config
sed -i 's/# ProductKey=/'"ProductKey=$product_key"'/' $startup_config
sed -i 's/# LicenceKey=/'"LicenceKey=$licence_key"'/' $startup_config

echo "${GREEN} Successfully updated startup.properties file ${NC}"

# Start and enable Striim dbms and node

sudo systemctl enable striim-dbms
sudo systemctl start striim-dbms
sleep 5
sudo systemctl enable striim-node
sudo systemctl start striim-node
echo "${GREEN} Succesfully started Striim node and dbms ${NC}"
