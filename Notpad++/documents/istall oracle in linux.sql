<IP-address>  <fully-qualified-machine-name>  <machine-name>
127.0.0.1       localhost localhost.localdomain localhost4 localhost4.localdomain4
192.168.56.107  ol9-19.localdomain  ol9-19
ol9-19.localdomain
dnf install -y oracle-database-preinstall-19c
dnf update -y
curl -o oracle-database-preinstall-19c-1.0-1.el9.x86_64.rpm https://yum.oracle.com/repo/OracleLinux/OL9/appstream/x86_64/getPackage/oracle-database-preinstall-19c-1.0-1.el9.x86_64.rpm

dnf -y localinstall oracle-database-preinstall-19c-1.0-1.el9.x86_64.rpm

vi /etc/sysctl.conf"
fs.file-max = 6815744
kernel.sem = 250 32000 100 128
kernel.shmmni = 4096
kernel.shmall = 1073741824
kernel.shmmax = 4398046511104
kernel.panic_on_oops = 1
net.core.rmem_default = 262144
net.core.rmem_max = 4194304
net.core.wmem_default = 262144
net.core.wmem_max = 1048576
net.ipv4.conf.all.rp_filter = 2
net.ipv4.conf.default.rp_filter = 2
fs.aio-max-nr = 1048576
net.ipv4.ip_local_port_range = 9000 65500


/sbin/sysctl -p

vi /etc/security/limits.d/oracle-database-preinstall-19c.conf
oracle   soft   nofile    1024
oracle   hard   nofile    65536
oracle   soft   nproc    16384
oracle   hard   nproc    16384
oracle   soft   stack    10240
oracle   hard   stack    32768
oracle   hard   memlock    134217728
oracle   soft   memlock    134217728




dnf install -y bc
dnf install -y binutils
dnf install -y compat-openssl11
dnf install -y elfutils-libelf
dnf install -y fontconfig
dnf install -y glibc
dnf install -y glibc-devel
dnf install -y ksh
dnf install -y libaio
dnf install -y libasan
dnf install -y liblsan
dnf install -y libX11
dnf install -y libXau
dnf install -y libXi
dnf install -y libXrender
dnf install -y libXtst
dnf install -y libxcrypt-compat
dnf install -y libgcc
dnf install -y libibverbs
dnf install -y libnsl
dnf install -y librdmacm
dnf install -y libstdc++
dnf install -y libxcb
dnf install -y libvirt-libs
dnf install -y make
dnf install -y policycoreutils
dnf install -y policycoreutils-python-utils
dnf install -y smartmontools
dnf install -y sysstat

dnf install -y glibc-headers
dnf install -y ipmiutil
dnf install -y libnsl2
dnf install -y libnsl2-devel
dnf install -y net-tools
dnf install -y nfs-utils 

# Added by me.
dnf install -y gcc
dnf install -y unixODBC

groupadd -g 54321 oinstall
groupadd -g 54322 dba
groupadd -g 54323 oper 
#groupadd -g 54324 backupdba
#groupadd -g 54325 dgdba
#groupadd -g 54326 kmdba
#groupadd -g 54327 asmdba
#groupadd -g 54328 asmoper
#groupadd -g 54329 asmadmin
#groupadd -g 54330 racdba

useradd -u 54321 -g oinstall -G dba,oper oracle
passwd oracle
vi /etc/selinux/config
SELINUX=permissive
setenforce Permissive

systemctl stop firewalld
systemctl disable firewalld

mkdir -p /u01/app/oracle/product/19C/dbhome_1
mkdir -p /u02/oradata
chown -R oracle:oinstall /u01 /u02
chmod -R 775 /u01 /u02

xhost +<machine-name>

mkdir /home/oracle/scripts

cat > /home/oracle/scripts/setEnv.sh <<EOF
# Oracle Settings
export TMP=/tmp
export TMPDIR=\$TMP

export ORACLE_HOSTNAME=ol9-19.localdomain
export ORACLE_UNQNAME=cdb1
export ORACLE_BASE=/u01/app/oracle
export ORACLE_HOME=\$ORACLE_BASE/product/19c/dbhome
export ORA_INVENTORY=/u01/app/oraInventory
export ORACLE_SID=prod
export PDB_NAME=pdb1
export DATA_DIR=/u02/oradata

export PATH=/usr/sbin:/usr/local/bin:\$PATH
export PATH=\$ORACLE_HOME/bin:\$PATH

export LD_LIBRARY_PATH=\$ORACLE_HOME/lib:/lib:/usr/lib
export CLASSPATH=\$ORACLE_HOME/jlib:\$ORACLE_HOME/rdbms/jlib
EOF
Add a reference to the "setEnv.sh" file at the end of the "/home/oracle/.bash_profile" file.

echo ". /home/oracle/scripts/setEnv.sh" >> /home/oracle/.bash_profile
Create a "start_all.sh" and "stop_all.sh" script that can be called from a startup/shutdown service. Make sure the ownership and permissions are correct.

cat > /home/oracle/scripts/start_all.sh <<EOF
#!/bin/bash
. /home/oracle/scripts/setEnv.sh

export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES

dbstart \$ORACLE_HOME
EOF





cat > /home/oracle/scripts/stop_all.sh <<EOF
#!/bin/bash
. /home/oracle/scripts/setEnv.sh

export ORAENV_ASK=NO
. oraenv
export ORAENV_ASK=YES

dbshut \$ORACLE_HOME
EOF

chown -R oracle:oinstall /home/oracle/scripts
chmod u+x /home/oracle/scripts/*.sh

/scripts/start_all.sh
~/scripts/stop_all.sh

DISPLAY=<machine-name>:0.0; export DISPLAY

# Patch names and directories may vary depending patch numbers. Adjust as required.
export SOFTWARE_DIR=/u01/software
export OPATCH_FILE="p6880880_190000_Linux-x86-64.zip"
export PATCH_FILE="p35742413_190000_Linux-x86-64.zip"
export PATCH_TOP=${SOFTWARE_DIR}/35742413
export PATCH_PATH1=${PATCH_TOP}/35643107
export PATCH_PATH2=${PATCH_TOP}/35648110

# Unzip software.
cd $ORACLE_HOME
unzip -oq ${SOFTWARE_DIR}/LINUX.X64_193000_db_home.zip
unzip -oq ${SOFTWARE_DIR}/${OPATCH_FILE}

cd ${SOFTWARE_DIR}
unzip -oq ${SOFTWARE_DIR}/${PATCH_FILE}


# Fake Oracle Linux 8.
# Should not be necessary, but the installation fails without it on 19.21 DB RU + OJVM combo.
cd $ORACLE_HOME
export CV_ASSUME_DISTID=OL8

# Interactive mode.
./runInstaller

# Silent mode. Includes application of patch.
./runInstaller -ignorePrereq -waitforcompletion -silent                        \
    -applyRU ${PATCH_PATH1}                                                    \
    -responseFile ${ORACLE_HOME}/install/response/db_install.rsp               \
    oracle.install.option=INSTALL_DB_SWONLY                                    \
    ORACLE_HOSTNAME=${ORACLE_HOSTNAME}                                         \
    UNIX_GROUP_NAME=oinstall                                                   \
    INVENTORY_LOCATION=${ORA_INVENTORY}                                        \
    SELECTED_LANGUAGES=en,en_GB                                                \
    ORACLE_HOME=${ORACLE_HOME}                                                 \
    ORACLE_BASE=${ORACLE_BASE}                                                 \
    oracle.install.db.InstallEdition=EE                                        \
    oracle.install.db.OSDBA_GROUP=dba                                          \
    oracle.install.db.OSBACKUPDBA_GROUP=dba                                    \
    oracle.install.db.OSDGDBA_GROUP=dba                                        \
    oracle.install.db.OSKMDBA_GROUP=dba                                        \
    oracle.install.db.OSRACDBA_GROUP=dba                                       \
    SECURITY_UPDATES_VIA_MYORACLESUPPORT=false                                 \
    DECLINE_SECURITY_UPDATES=true
Run the root scripts when prompted.

As a root user, execute the following script(s):
        1. /u01/app/oraInventory/orainstRoot.sh
        2. /u01/app/oracle/product/19.0.0/dbhome_1/root.sh
		
		
		
		export SOFTWARE_DIR=/u01/software
export PATH=${ORACLE_HOME}/OPatch:${PATH}
export OPATCH_FILE="p6880880_190000_Linux-x86-64.zip"
export PATCH_FILE="p35742413_190000_Linux-x86-64.zip"
export PATCH_TOP=${SOFTWARE_DIR}/35742413
export PATCH_PATH1=${PATCH_TOP}/35643107
export PATCH_PATH2=${PATCH_TOP}/35648110

cd ${PATCH_PATH2}
opatch prereq CheckConflictAgainstOHWithDetail -ph ./
opatch apply -silent


# Start the listener.
lsnrctl start

# Interactive mode.
dbca

# Silent mode.
dbca -silent -createDatabase                                                   \
     -templateName General_Purpose.dbc                                         \
     -gdbname ${ORACLE_SID} -sid  ${ORACLE_SID} -responseFile NO_VALUE         \
     -characterSet AL32UTF8                                                    \
     -sysPassword SysPassword1                                                 \
     -systemPassword SysPassword1                                              \
     -createAsContainerDatabase true                                           \
     -numberOfPDBs 1                                                           \
     -pdbName ${PDB_NAME}                                                      \
     -pdbAdminPassword PdbPassword1                                            \
     -databaseType MULTIPURPOSE                                                \
     -memoryMgmtType auto_sga                                                  \
     -totalMemory 2000                                                         \
     -storageType FS                                                           \
     -datafileDestination "${DATA_DIR}"                                        \
     -redoLogFileSize 50                                                       \
     -emConfiguration NONE                                                     \
     -ignorePreReqs
	 
	 
	 cdb1:/u01/app/oracle/product/19.0.0/dbhome_1:Y
	 
	 sqlplus / as sysdba <<EOF
alter system set db_create_file_dest='${DATA_DIR}';
alter pluggable database ${PDB_NAME} save state;
exit;
EOF

create tablespace tbs on datafile 'D:/
create user user1 IDENTIFIED by asd 
Create TABLE emp (id INTEGER,name VARCHAR(10),city VARCHAR(10));

insert into emp values(2,'mahe','kdp');
insert into emp values(3,'mass','bng');
insert into emp values(1,'mahesh','bng');
insert into emp values(1,'mahesh','bng');

insert into emp values(1,'mahesh','bng');
commit;
=================


  192.168.223.134  ol8-19.localdomain  ol8-19


