# Install Java JDK (1.8)
curl -0 -L https://striim-downloads.s3.us-west-1.amazonaws.com/jdk-8u341-linux-x64.tar.gz --output jdk-8u341-linux-x64.tar.gz
mkdir -p /usr/lib/jvm
tar zxvf jdk-8u341-linux-x64.tar.gz -C /usr/lib/jvm
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_341/bin/java" 1
update-alternatives --set java /usr/lib/jvm/jdk1.8.0_341/bin/java

# Install Striim
curl -L https://striim-downloads.striim.com/Releases/4.1.0.1/striim-dbms-4.1.0.1-Linux.rpm --output striim-dbms-4.1.0.1-Linux.rpm
curl -L https://striim-downloads.striim.com/Releases/4.1.0.1/striim-node-4.1.0.1-Linux.rpm --output striim-node-4.1.0.1-Linux.rpm
sudo rpm -ivh striim-dbms-4.1.0.1-Linux.rpm
sudo rpm -ivh striim-node-4.1.0.1-Linux.rpm

# Setup Striim's credentials
sudo su - striim /opt/striim/bin/sksConfig.sh
