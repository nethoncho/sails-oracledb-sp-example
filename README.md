# sails-oracledb-sp-example

## About
Example sails project using the [sails-oracledb-sp](https://github.com/Buto/sails-oracledb-sp) adapter

The current version exposes the Oracle HR Employee table via a REST API and websockets.
It includes an Angular UI.


#Installation
The setup procedure relies on Oracle's VM.

install VirtualBox
Download and install [Oracle VM VirtualBox](http://www.oracle.com/technetwork/server-storage/virtualbox/downloads/index.html "download VirtualBox") on your host system

##Download the Oracle 12c VM
The Oracle 12c VM is provided in an Open Virtual Appliance (OVA) file.  An ova is essentially an archive that includes a disk image and other supporting files that are suitable to be imported into VirtualBox as a VM.  The VM provided by this ova includes Oracle Linux 7 and Oracle Database 12c Release 1 Enterprise Edition.

Download the [Oracle 12c ova](http://www.oracle.com/technetwork/database/enterprise-edition/databaseappdev-vm-161299.html "Oracle DB Developer VM"), which is the Oracle DB Developer VM. Launch it by double clicking it and then import it into VirtualBox.

Enable the Oracle 12c's VM's bidirectional clipboard. In the VM's menu: Devices->shared clipboard->bidirectional.

Set the VM's memory for 3GB. Set the VM's memory for 3GB. In the VM's menu: Machine->settings->system and configure for 3GB of memory.
Database Information:
1 Oracle SID    : cdb1
2 Pluggable DB  : orcl
3 ALL PASSWORDS ARE : oracle
4 The Linux Username and password is oracle.

## Install Node

```javascript
$sudo su -
# cd Downloads
# wget https://nodejs.org/dist/v0.12.7/node-v0.12.7-linux-x64.tar.gz
# tar xzf node-v0.12.7-linux-x64.tar.gz
# cd node-v0.12.7-linux-x64
```
We install Node.js in /usr/local directory. Use following command to copy the files to appropriate sub-directotories in /usr/local:
```javascript
#for dir in bin include lib share; do cp -par ${dir}/* /usr/local/${dir}/; done
```
To verify version of node and npm, type:
```javascript
#node --version
v0.12.7
#npm --version
3.3.8
```
Now install npm

```javascript
#npm install -g npm
```

##Install the Oracle Instant Client 'Basic' and 'SDK' RPMs
The Oracle VM comes with FireFox preinstalled.


# Download both the Oracle Instant Client 'Basic' and Oracle Instant Client 'SDK' RPMs

[Oracle Instant Client 'Basic' and Oracle Instant Client 'SDK' RPMs](http://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html#ic_x64_inst "download Instant Client RPMs")

copy the downloaded rpms to /home/oracle/rpms and then install the packages as root
```javascript
$mkdir /home/oracle/rpms
$mv /home/oracle/Downloads/*.rpm /home/oracle/rpms
$sudo su -
#cd /home/oracle/rpms
#rpm -ivh oracle-instantclient12.1-basic-12.1.0.2.0-1.x86_64.rpm
#rpm -ivh oracle-instantclient12.1-devel-12.1.0.2.0-1.x86_64.rpm
#exit
```
Add the following lines to /home/oracle/.bashrc:
```javascript
export LD_LIBRARY_PATH=$ORACLE_HOME/lib:$LD_LIBRARY_PATH
export PATH=/opt/node-v4.1.0-linux-x64/bin:$PATH
```

##Install git
```javascript
sudo su -
#yum install git
exit
```

[text](http://www.oracle.com/ "title")

## Installation

```bash
$ git clone https://github.com/nethoncho/sails-oracledb-sp-example.git
$ cd sails-oracledb-sp-example
$ npm install
$ bower install
```

## Configuration

Edit the oraclehr adapter in the config/connections.js file to match your needs

```javascript
module.exports.connections = {
  oraclehr: {
    adapter: 'oracle-sp',
    user: 'scott',
    password: 'tiger',
    package: 'HR',
    cursorName: 'DETAILS',
    connectString: 'localhost/orcl'
  }
};
```

Apply the stored procedures to the HR schema in db/

```bash
$ cd db
```

The order is important

```bash
sqlplus "scott/tiger@localhost/orcl" < create_pkg_hr-child.pls
sqlplus "scott/tiger@localhost/orcl" < create_pkgbdy_hr-child.plb
sqlplus "scott/tiger@localhost/orcl" < create_pkg_hr.pls
sqlplus "scott/tiger@localhost/orcl" < create_pkgbdy_hr.plb
sqlplus "scott/tiger@localhost/orcl" < create_type_retcodes.sql
```

```bash
$ cd ..
```

## Run the application

```bash
$ cd ~/sails-oracledb-sp-example
$ sails lift
```

Point your browser to http://localhost:1337/#/employees

#### License

**[MIT](./LICENSE)**
&copy; 2015
