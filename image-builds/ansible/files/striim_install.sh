#Install Java

curl -0 -J -L https://striim-downloads.s3.us-west-1.amazonaws.com/jdk-8u341-linux-x64.tar.gz --output jdk-8u341-linux-x64.tar.gz
mkdir -p /usr/lib/jvm
tar zxvf jdk-8u341-linux-x64.tar.gz -C /usr/lib/jvm
update-alternatives --install "/usr/bin/java" "java" "/usr/lib/jvm/jdk1.8.0_341/bin/java" 1
update-alternatives --set java /usr/lib/jvm/jdk1.8.0_341/bin/java
java -version

#Install Striim
curl -0 -J -L https://striim-downloads.s3.us-west-1.amazonaws.com/Releases/4.1.0/Striim_4.1.0.tgz --output /opt/striim.tgz
tar -xvf /opt/striim.tgz
