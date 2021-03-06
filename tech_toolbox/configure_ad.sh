#######################################################################
# Project           : FSE.CIDSE-Ubuntu
#
# Program name      : configure_ad.sh
# Author            : James White III
#
# Date created      : July 23, 2018
#
# Purpose           : This script can be used to remotely join Ubuntu clients to Active Directory
#
#
# 1. Enter hostname of remote system
# 2. Initiate remote SSH Into HostSytem
# 3. Authenticate as "techs"
# 4. Add PBIS Repositories
# 5. Verify the hostname
# 6. Verfiy the computer is prestaged in Active Directory
# 7. Reboot
#######################################################################
#
##### Get Host Name ####
echo 'enter hostname in "enXXXXXXXl" format'
read HOST
HOST='techs@'$HOST'.cidse.dhcp.asu.edu'
#
#
#### Connect to the System ####
echo 'Enter Techs password When Prompted'
ssh -t $HOST '
#
####enter commands to run in remote system in here####
####ONLY USE DOUBLE QUOTES IN HERE####

##########################################################################################
#################################     SET HOSTNAME      ##################################
##########################################################################################

#Assign existing hostname to $hostn
hostn=$(cat /etc/hostname)

#Display existing hostname
#echo "The current hostname of this systems is $hostn"

#Ask for new hostname $newhost

echo " ******************************************************************************"
echo " ******************************************************************************"
echo " Please enter the desired hostname for this system: "
read newhost
echo " ******************************************************************************"
echo " ******************************************************************************"
#change hostname in /etc/hosts & /etc/hostname
sed -i "s/$hostn/$newhost/g" /etc/hosts
sed -i "s/$hostn/$newhost/g" /etc/hostname
echo " **********************************************************************************"
echo " **********************************************************************************"
#display new hostname
echo "Your new hostname is $newhost"
echo " **********************************************************************************"
echo " **********************************************************************************"

hostname $newhost


##########################################################################################
#######################         Add PBIS Client Repo        ##############################
##########################################################################################

wget -O - http://repo.pbis.beyondtrust.com/apt/RPM-GPG-KEY-pbis|sudo apt-key add - 
sudo wget -O /etc/apt/sources.list.d/pbiso.list http://repo.pbis.beyondtrust.com/apt/pbiso.list 
sudo apt-get update
echo $(date) ${filename} SUCCESS: PBIS-OPEN Repo Added >> /var/log/fse.log

##########################################################################################
##########################           Install PBIS Client        ##########################
##########################################################################################

apt-get install pbis-open -y
echo $(date) ${filename} SUCCESS: PBIS-OPEN Installed >> /var/log/fse.log



##########################################################################################
##########################################################################################
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " *************                 **WARNING**                   **********************"
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " *************      ALL NEW SYSTEMS MUST BE PRE-STAGED       **********************"
echo " *************         WITHIN ACTIVE DIRECTORY               **********************"
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " *************   ARE YOU SETTING UP AN EXISTING SYSTEM ???   **********************"
echo " *************         PLEASE VERIFY THAT THE DEVICE         **********************"
echo " *************            IS IN THE PROPER OU                **********************"
echo " **********************************************************************************"
##########################################################################################
##############################    Verify AD PreStage    ##################################
##########################################################################################
#
#  This section requires the technician to verify whether or not the computer has been prestaged in AD. 
#
echo " **********************************************************************************"
echo " **********************************************************************************"
echo " *"
echo " *"
read -p " *  Has this computer already been pre-staged in Active Directory? (Y)es/(N)o?  " choice
case "$choice" in 
  y|Y ) echo "yes";;
  n|N ) echo "****************************************************************************"
        echo "****************************************************************************"
        echo "****************************************************************************"
        echo "        UBUNTU CLIENT CONFIGURATION CAN NOT BE RUN AT THIS TIME :(          "
        echo "Please pre-stage this system in Active Directory, with the desired hostname"
        echo "****************************************************************************"; return;;
  * ) echo "invalid"; return;;
esac
echo " **********************************************************************************"
echo " **********************************************************************************"
#
##########################################################################################
##########################################################################################
######################        BIND TO ACTIVE DIRECTORY         ###########################
##########################################################################################
##########################################################################################
#
#
#
##########################################################################################
#############################        Join FULTON.AD.ASU.EDU.           ###################
##########################################################################################
#
echo ???Joining this machine to Active Directory???
#
domainjoin-cli join fulton.ad.asu.edu 
#
#
##########################################################################################
#############################       Configure Login PBIS-OPEN          ###################
##########################################################################################
#
/opt/pbis/bin/config UserDomainPrefix ASUAD
/opt/pbis/bin/config AssumeDefaultDomain true 
/opt/pbis/bin/config LoginShellTemplate /bin/bash 
#/opt/pbis/bin/config HomeDirTemplate %H/%U 
#/opt/pbis/bin/config RequireMembershipOf 
#
#
echo "ACTIVE DIRECTORY BIND COMPLETE"
echo "Your computer must restart to complete the installation...rebooting in 10 seconds!
#
sleep 10
reboot'
