## SSH, Apche, Openvpn authentification via OpenLdap

### Section1: OpenLdap

OpenLDAP, or the Open Lightweight Directory Access Protocol, is an open-source implementation of the LDAP standard. LDAP is a protocol designed to access and manage directory information services, which are commonly used for storing and retrieving information about users and resources within a network

LDAP is instrumental in streamlining the authentication process by enabling applications and services to retrieve necessary information from a central directory server. This tutorial focuses on harnessing the capabilities of OpenLDAP to enhance authentication across diverse services such as SSH, Apache, and OpenVPN.

#### LDAP Server

The server VM instance
**![A computer screen shot of a server
Description automatically generated](https://lh7-us.googleusercontent.com/FtmosN-gTaPe-f3c48iN6mw5YOELnVmRdmkUMK99xoowZFMTSAysS7MpQ4Naa_emrX9hHfnF58AEXmKwYrRralPSqgJDxMZXY5SHEslIf7a0dAwu3QhEh_oMPwmRP7zmAIevC3uiC1p2w4ErA9vSzQ)**

##### Installing OpenLdap and Ldap Account Manager

first we nedd to make sure that we have the necessary packages installed
then we proceed and install openLdap packages ldap and ldap utils
sudo apt install slapd ldap-utils -y
When you install the OpenLDAP packages (`slapd` and `ldap-utils`), you will be prompted to provide several configuration details to set up your LDAP server.
Here are the key parameters you will typically be asked for during the installation process:

1. **Common Name (CN):**

   - The common name is typically associated with the LDAP server itself or a specific service. It helps identify the entity for which the SSL certificate is issued.

2. **Administrator Account (admin):**

   - You will be asked to set up an administrative account (commonly referred to as the "admin" account). This account will have privileges to perform administrative tasks on the LDAP server.

3. **Admin Password:**

   - You will need to set a password for the admin account. This password is crucial as it grants administrative access to the LDAP server.

make a note of these credentials, as you will need them later for configuring services and authenticating users against the LDAP server.

**![A screenshot of a computer
Description automatically generated](https://lh7-us.googleusercontent.com/wJBkWBhvjJxDjDFVXBDhpQPAXKwMP3lKrjeky7WJ3xIQrKfoa8qUD-Q_f6Kot5AmL7UiSzGvUE7mFdpC3VeiPaoTntbYdavbv3wwKJjAEY91bolEU9rrp_oX6hjluH3kKvQqOGHuI8xmQi5_fU7UlA)**

##### LDAP account manager

Since we will be using[ LDAP Account Manager (LAM)](https://www.ldap-account-manager.org/lamcms/) , we have to make sure that we have apache and php installed
**sudo apt install apache2 php php-cgi libapache2-mod-php php-mbstring php-common php-pear -y**
sudo apt -y install ldap-account-manager

then we run these command to configure php

sudo a2enconf php\*-cgi

systemctl reload apache2

we can now access the Account Manager in 192.168.56.101(our ip address)/lam
**![A screenshot of a computer
Description automatically generated](https://lh7-us.googleusercontent.com/67QEyWOS6zY2NvU92xKoVDHk53JZQWaLO3kLfFbdi0-Fxyh4yxRh2KJzNK9YbjSTBD5Z3y-VxFktHjVEEMFb1vnGntGcLejMemTKTLSOdOlOs0OV9mB6NYRD8JygcliJOpWH8BcuFMbv7eMdOlWxow)**

##### Adding users and groups

we log as the administor of the server ( here the default password in manager)
**![A screenshot of a computer
Description automatically generated](https://lh7-us.googleusercontent.com/7eHvSv4l6I-FgznzlRb7XTEZGnCZq2Bt7TV7J2ZzRrydf9md4QhKgqpzHEEhR0mQ9nkJnmWwATyNexwuvHZ61hG39o87pWXLmnkUYhB-36ZV92xzw9FnIt2eEe6v4slo3_TMHHtFFFkZRO1wwi9ecA)**
**![A screenshot of a computer
Description automatically generated](https://lh7-us.googleusercontent.com/fvTQj_u6tU4AEEhFjSIMqePZ0S32yY4rrlkDYDtD4eLp6cF8oPqTbon05VN_soCy0Jsn_BzWFU8WDFJuyc5eZ1NcwceyZ7Sc8G9Rp5Tjzt4mIr6iC4QjRB3hvlVX3MAq7m78vQcmRZfONq6vrLtyvw)**

here, using the web interface, we have created:

- two organizational units (OU): **Department** and **Group**
- under group we have created two groups with the common names (CN) : grp-GL and grp-RT
- two users with common names (cn) :** Mohamed Aziz Bellaaj** and **Louay Badri**
  To check a user's information we can run :
   **ldapsearch -x -b "dc=local" "(uid=badri)"**
   **![A screenshot of a computer program
Description automatically generated](https://lh7-us.googleusercontent.com/l5ClTrlscwos9HDG6N_zPjYaL7h2pFf1G0q02OtqWamfIpx3bEN4Y9QMqntnbuoP2stDdeh13xEOsS7XZlX8tjMJD9yyU-A37-UijKLgQZnL48F8LYhvA87utnqUTDVMWe0Fmn8_d8jsBIlffz4efg)**

##### Add certificztes to users with OpenSSL

We want to create the certificates for each user then send these certificates to their user entries in the ldap server. The procedure is as follows:

1.  **generate a private key for Louay:**
    - openssl genpkey -algorithm RSA -out louay_pkey.pem
2.  **create a certificate signing request (CSR)**:

```
openssl req -new -key louay_pkey.pem -out csr.pem
```

3.  **create a self-sgined certificate**

```
openssl req -x509 -key louay_pkey.pem -in csr.pem -out louay_certificate.pem
```

5. \*\*If we want to send the certificate we have to modify it to be in binary format, we can do by running

```
openssl x509 -in /home/azizb/Desktop/louay_certificate.pem -out /home/azizb/Desktop/louay_certificate.der -outform DER
```

7. **We then create a badri.ldif file that will allow us to add the certificate to the user’s entries.**
   **![A computer screen with white text
Description automatically generated](https://lh7-us.googleusercontent.com/ZbZ_J4xQhYSqbkBLiYPt2Tgm1EjEsB5MFjtDRfNYxoW8GWM7zkv3qQMj-UrmSM5G6_d4hFDqZVMPWkzwhaxxMiU7g9xU-WHObK8wsWd2Exkjm6Yd6hyQ8s6MLI5ia-gBdwQdBqSdJvXOYa8Wch7Etw)**
8. **we send it to the server with the command**

```
ldapmodify -x -D "cn=admin,dc=local" -W -f /home/azizb/Desktop/badri.ldif
```

Let's check our users after adding their respective certificates

```
ldapsearch -x -b "ou=RT,ou=Department,dc=local" "(uid=badri)

```

**![A screenshot of a computer
Description automatically generated](https://lh7-us.googleusercontent.com/JjbHMVclLaYUOUHmk4oGOR6yy1pDpEWSuu6db2sX8_iWftnYZHHttnGVXgeVuFfDcTx03rNknbUQwXtIyChsTrdxmT0J7EybL0MRRYF_5pJzMEmGfrD4Y2Qe0Et1Ukxmmz7VIDhede9g5SakhYVuxA)**

**![A screenshot of a computer program
Description automatically generated](https://lh7-us.googleusercontent.com/ALuA4dgxk_aPaBCjHRDIN5T5UKoSkEO57vod3tpiT9NRXVeQZ-o1sARGyZ_cD-cAmbEvZwC6py9WZI-RVPuLhEM-G19N-F49s-TIGp63yml9YOBOSq4UlusvZhi22fQd5j-nQAHGCSmnBbr41iNdBA)**



#### LDAP Client

The client VM instance

##### PAM

##### installing ldap client packages

we will be needing three config files:

```
sudo apt install libnss-ldap libpam-ldap ldap-utils nscd -y
```

1. **libnss-ldap:**

   - This package integrates LDAP with the Name Service Switch (NSS) on Linux systems. It allows user and group information, including passwords, to be retrieved from LDAP.

2. **libpam-ldap:**

   - Pluggable Authentication Modules (PAM) provide a framework for authentication on Unix systems, enabling LDAP-based authentication for various services.

3. **ldap-utils:**

   - This package includes utilities for interacting with LDAP directories. ( command-line tools like `ldapsearch`)

4. **nscd (Name Service Caching Daemon):**
   - nscd is a daemon that caches name service requests, including those for LDAP. It helps improve performance by reducing the need to repeatedly query the LDAP server for the same information.

##### Adding necessary configurations

After installing the LDAP client packages, we need to modify three configuration files

1.  /etc/nsswitch.conf
    The Name Service Switch configuration file determines the order in which different services, including LDAP, are queried for information such as users, groups, and passwords.
    We will configure it to instruct the system to check LDAP for user passwords during authentication.
    **![A screenshot of a computer
Description automatically generated](https://lh7-us.googleusercontent.com/tJqzdnJAZ1YTTB-riluDoDa5RAk3mN0e1OYEBOeorqEdlyPoOfBZBu_qKgWTU2tMnT-g_h0NSZrUyoWwizEqB3OcGyIMRXiLLGUO1CbOEkHfuE_y1AvfXuzwCn9c_jrKpWUdJbvg8mOl72KBPb5Dug)
2.  /etc/pam.d/common_password
    The Pluggable Authentication Modules configuration file for common password-related settings.
    **![A computer screen with text and images
Description automatically generated](https://lh7-us.googleusercontent.com/7qo7YQzPsuGSYRePWLhQ17X9EE2moeqQxiZBh3A2Fc_3gxpqgn2Dwzy3fBjQfb-spbupDVkvuVtI1yup87xYqQ5rf_kQia_dPaII1eBdYKs_U0lM4j_xgiLkKC-FTdpQTjbZojeNqqo4uU8IxUbhJQ)**
    We remove the 'use_authtok' option: this option is used to reuse the password provided during authentication to update the password.
3.  /etc/pam.d/common_session
    we add this line at the end of the file:
    `
	session optional pam_mkhomedir.so skel=/etc/skel umask=077
	`
    This step is particularly useful to ensure that users have a secure initial home directory upon their first connection.
    Then we need to restart the `ncsd` service by running

```
sudo systemctl restart nscd
sudo systemctl enable nscd
```

##### Logging in as an LDAP user

With our client machine all set up, let's try and log in as one of our added users, by running

```
sudo login
```

![[successful login.png]]
**and it works!**

#### LDAPS

##### establishing ssl/ tls connection with the server

The procedure is as follows:

1. generate a private key for our server

```
openssl genrsa -aes128 -out ldap-server.local.key 4096

```

2. create a csr for our server

```
openssl req -new -days 3650 -key ldap-server.local.key -out ldap-server.local.csr
```

![[csr server.png]]

- make sure that the Common Name matches the FQDN of our server

3.  sign the CSR

```
sudo openssl x509 -in ldap-server.local.csr -out ldap-server.local.crt -req -signkey ldap-server.local.key -days 3650
```

4. Copy the certificate and key to /etc/ldap/sasl2 directory
   ![[sasl2.png]]
5. change the ownership to the openldap user by running

```
sudo chown -R openldap:openldap /etc/ldap/sasl2
```

6. create the configuration file ssl-ldap.ldif containing

```
dn: cn=config
changetype: modify
add: olcTLSCACertificateFile
olcTLSCACertificateFile: /etc/ldap/sasl2/ca-certificates.crt
-
//replace: olcTLSCertificateFile
olcTLSCertificateFile: /etc/ldap/sasl2/ldap-server.local.crt
-
//replace: olcTLSCertificateKeyFile
olcTLSCertificateKeyFile: /etc/ldap/sasl2/ldap-server.local.key

```

7. modify the ldap server configuration

```
sudo ldapmodify -Y EXTERNAL -H ldapi:/// -f ssl-ldap.ldif
```

8. add the ldaps route in  **/etc/default/slapd**
   ![[ldapsRoutes.png]]
9. edit **/etc/ldap/ldap.conf**

- omment the line containing TLS_CACERT
   - add the following lines:

```
TLS_CACERT /etc/ldap/sasl2/ca-certificates.crt
TLS_REQCERT allow
```

![[ldap.conf.png]] 10. After restarting the slapd service we verify
`	ldapsearch -x -H ldaps://192.168.56.101 -b "dc=local
	`
![[ldapsResponse.png]]![[ldapsResponse.png]]

##### Advantages of LDAPS

### Section 2: SSH authentification via OpenLDAP

In this section, the objective is to enable SSH connections without the need for password entry by leveraging OpenLDAP.

#### preresuiqtes

install openssh on the client machine

```
sudo apt install ssh-server
```

#### Connect to ssh

1. Create a pair of keys for the user in the client machine
   ```
   ssh-keygen -t rsa
   ```
   ![[point.ssh.png]]
2. Copy the public key to the ldap
   ```
   ssh-copy-id bellaaj@client
   ```
3. Edit /etc/ssh/sshd_config
   ```
   PubkeyAuthentication yes
   AuthorizedKeysFile  .ssh/authorized_keys
   ```
4. Restart ssh service
   ```
   sudo service ssh restart
   ```
5. Connect to the ldap user without the need of a password

   ![[ssh_bellaaj.png]]
   At this stage, we cannot login to the other ldap user (badri) without the password
   ![[ssh_badri.png]]

6. Edit **/etc/ssh/sshd_config**
   we need to specify which groups are allowed to establish an ssh connection without the need of a password
   we add AllowGroups followed by the name of the group

   ![[allowgroups.png]]

7. Test the connections
   We have configured our ldap server such that bellaaj belongs the the grp-GL and badri belongs to grp-RT.
   **Let’s test the connection with a user belonging to the allowed group (bellaaj):**
   ![[ssh_bellaaj2.png]]
   and it works!
   **And now let's test the connection with a member of the other group:**
   ![[ssh_badri2.png]]
   Since badri isn't a memeber of the grp-GL, we cannot establish an ssh connection without providing a password.

### Section 3: Apache authentification via OpenLDAP
In this section, we focus on integrating Apache with OpenLDAP for user authentication. The objective is to secure access to a website hosted on Apache by leveraging OpenLDAP credentials. Below are the key steps involved in configuring Apache for OpenLDAP authentication:
1. create a new folder under /var/www/gci/
	```
	sudo mkdir /var/www/gci/
	```
	 We create an inedx.html file in there which contains the code for our website.
2.  Edit the **000-default.conf file**, 
	We need to ensure that the DocumentRoot attribute is configured to point to the desired HTML file.
	**![](https://lh7-us.googleusercontent.com/be-2hKfBoWlIihcAFECh8GXUmsgoyIun9GJclMrZzkXkGI5lHrjvPp6Tbi11dgxpNQuu2WL7Ul0S6ahD3kO-O0q9xoyxBZA1mqeLpJugwqRkrVQHLCjp8IjL2zHeN-Ua1uiI6rw5tApy)**
3. Enable LDAP authentication, 
	We include the credentials of our ldap server
	![](https://lh7-us.googleusercontent.com/7yHNlJxg9JKByW6mOKilAd6t260gNx0AecoPhmfzfO2myvi1PiH-7DzFTsDYsZy8lxWQZjlgv20FHWOxvZtaMKFiHWBi5qNEkbjPmpDJOhmgQlJ4tcvp2hnIHfzsbMDrSZ3K35eS31ou)
	then run the command:
	
	```
	a2enmod authnz_ldap.
	``` 
4.  Specify the allowed memebers to access the website on the apache server
	add the following ` Require ldap-group` directive in the `Directory` tag
	![](https://lh7-us.googleusercontent.com/rcZ_kvzdX_AJyJRWr2ss2Z5z_9c9wrmGYLmD08VNQ4WZwLKRcL01sB56MEVVSfkdhQu-UFO0LA4thiXdPLWM1zoIm30wFXP--xERBHs_lI21jZIfoiZfR9pwyG02Hy94brN6HbxCBnyY)
	However, specifying this alone is insufficient. Apache's method of identifying users within certain groups differs from SSH. While SSH examines the gid of each LDAP user and permits connections only for those with the gid of authorized groups, Apache searches our groups for the memberUid attribute. It grants access exclusively to users with the specified uid in the memberUid attribute.
5. Define the attribute memberUid
	To address the current group configuration in LDAP, where the memberUid attribute is not defined, we resolve this by creating the file 'fix_groups.ldif' with the following content
	![](https://lh7-us.googleusercontent.com/vwuGlmqrsraJbwKL0dboBO-efsYRl4N4nwnf_Y6Swa1rZE7-pW444yCJ2XY5tIfWQAa-Z8pgH_5T7bye1sel74_JjlSoaWBTDmyIrSTog5r-mgQ0hPJ_p7zhKgGR6USt_RL4dqTtVD_g)
	then we run: 
	```
	ldapmodify -x -D "cn=admin,dc=local" -W -f fix_groups.ldif
	```
6. Test the authorazations 
	The user “bellaaj” won’t be able to connect while “badri“ (belonging to the allowed group grp-RT ) can.
	![](https://lh7-us.googleusercontent.com/gzIkboCaHVqxrYmEFzHP_GQgif115WIUsgpWhkY4MbyJyGuiqBezDTWVXTLNCL4a-gvVYFKCRA3HDhfTg15jQFxuTPUakKORuaefTvcLt9bSi4NuHZhCMZHb1hQtPeG3jRoS3TPki4XZ)
	![](https://lh7-us.googleusercontent.com/yBwJhsEr-pB9oh7-abc2gJUce09-HDnxcK7z21uy0BJEvTLuF6cFVmSinZIr4NhAtntd9HyaCR6x0DnFnOcTQgex9pBT9DULMV6D49H7mq5tn2CZWfilccx4eJ48ne-FOp8lYsjfUqEN)
	![](https://lh7-us.googleusercontent.com/mBj86hfpV6sqRZIALbh5_pwts4j-8jo90i7LSJgql6qWt11ri8iwtiY9-Jbswvu2ZijXgdVLw2bpeSnJf1VeUJ5ApLnNlXpMfo53HeTBV1Bq1g4G6f-sR7slx4WahPraZo9ePqspUGIh)

### Section 4: OpenVPN
In this section, our focus shifts to OpenVPN, a powerful and secure open-source virtual private network (VPN) solution.The objective is to establish a secure VPN connection using OpenLDAP credentials,
##### Install the necessary packages
We have two machines: openvpn-server and open-vpn client. let’s install openvpn on both machines:
```
sudo apt install openvpn
```
we also need ssh server on both machines  (we’ll need it later)
```
sudo apt install openssh-server
```
we'll also use easy-rsa. It is a set of scripts and tools that simplifies the process of managing a Public Key Infrastructure (PKI) for applications like OpenVPN
```
sudo make-cadir /etc/openvpn/easy-rsa
```
and for the follwing steps, we'll need root privileges so we'll run : 
```
sudo su
```
#### PKI set up 
##### Generate the Certification Authority's (CA) certificate
let's first initilize our PKI by running accessing the easy-rsa directory ad running 
```
./easyrsa init-pk
```
we the generate the certificate  with 
``` 
./easyrsa  build-ca 
```
![](https://lh7-us.googleusercontent.com/74j5rzCz3kPA2JtvbhgnoLXsg1eNQ9FcAO9Kx3WfF4RBQrPBc0r2kK5Aq8G5xVnNyw22e_O8vOsK3G-rL8XZk-ZXUsbWSF8Xw3Q5taQjhZ-40Rr0iI8BuTFTwv_XsrYcGp4NtlAwqNyz)
Now if we take a look at the generated files:
![](https://lh7-us.googleusercontent.com/RSyGd8vhlGfIZmvSTZ85J8HU1mm43TjJ-sdiNUpcWtnlQIxT741yq0eWSIHLMq1VpL0v8VTMHDdma_bmrqwLQJRjHAm4dXh_WVecMOMZJ9OW3D5em9lXB1-lxBb6NcRm3X8Q8TiURq91)

##### Diffie-Hellman key 
OpenVPN uses the Diffie-Hellman key exchange during the initial phase of the connection to securely negotiate a shared secret between the client and server.
```
./easyrsa gen-dh
```
![](https://lh7-us.googleusercontent.com/uywV-kNK4qDFZ4Nkos6WN1FbfOan0JVrr9Mr4fyv-Vu0-pAvWSiWGfZzk2RpZBPE845j8A5fJj85Rv5NopwzR1Bq39gyIQhEOwWmzWcy5ly5qRzBhNk5DAKbmK_wVodz4kZNJA5rSGNH)

##### Server's certificate
We first create the certification request for the server
```
./easyrsa gen-req SERVER nopass
```
And then we sign the request
```
./easyrsa sign-req server SERVER
```
We execute this command to copy the following files in our openvpn directory for ease of access
```
cp pki/dh.pem pki/ca.crt pki/issued/SERVER.crt pki/private/SERVER.key /etc/openvpn/
```
![](https://lh7-us.googleusercontent.com/zQt0pY3MNhOQ0d63C7UDFULfiz67YdHoaHcw6t9Q09q8hVSoRO86FoecaZ5WwGrgGud74LlUKsbIXvPBukKxvkeQOj7cm3t9avpi2Cx422rP2GeQRERvtipbXf8Pm07BuiFUiiJKW_YK)
##### Client's certificate
We’ll do the same thing for the client but we will copy the generated files in its home directory:
```
scp ca.crt issued/CLIENT.crt private/CLIENT.key azizb@openvpn-client:/home/azizb
```
With that, the home directory of the client looks like
![](https://lh7-us.googleusercontent.com/Kt42_iYy0BpBqNs3o2LSTyzHGWYnW-4vVqKKBjdRSbgBQkWLNfSY-5ChDK6Y9xf1fdQ7b9iRp4qjUasOyZVfe0oj-bbZlv8hqGhboTWRfAqDmEOfTKi3YU-u7TaAhtCluAurKj82kwUr)
#### Server configurations
 To configure our OpenVPN server, we'll have to create the file server.config under the **/etc/openvpn** directory. For ease of access, we'll copy the example in **/usr/share/doc/openvpn/examples/sample-config-files/server.conf** 
 ```
 cp /usr/share/doc/openvpn/examples/sample-config-files/server.conf /etc/openvpn/
```
In this file we'll specify our **certification authority**,our **server’s certification**,**our server's key** and the **dh key**. 
![](https://lh7-us.googleusercontent.com/ftnpdAN-U5JDu537YMQADyVgEKSEZXB1DqXKd_vBPk3bMmSxQ0cwu6CxNgBoJWSivkiGve9mxFAfmcE_yXggQpc7qnxcm3udouZReKtb7ivskalMI76J_P7uYn7i_dTqVlMmyFG3M1-o)
 ![](https://lh7-us.googleusercontent.com/umeS3pTvci3aiKa7G27LCG7PEDqlNZ3SHNFqSYgLvVFs0r8az2d-S1VYbpoDlXSqrkeFtqcfq0obRgscOm6q5lI-_TKG11_m3FV_FA9Bu0qWyieGAea916BCSre18PL45Og3GdM-qwD5)
 we then generate the openvpn static key and send it the client
 ```
 openvpn --genkey secret ta.key
```
![](https://lh7-us.googleusercontent.com/FL6QSTUwNnSPTGpu6_lx5OORonJ3UTvzaIufYDHMk9l47btppTjzK13fOTKMYNDdmlbLuVyVKhqasVQ0bJSfo2OklCI1sDL3XWHB47QLF9zOU2Ee6CWXaexk5BWxoe8UEFSJzXcH3v_h)
![](https://lh7-us.googleusercontent.com/ZaAsacNp8zcro_uxYFrxoR8-VIPbiGYOmUgEQfFGRGKI7z9yXRgtP5NZzwLkyA76gKYR0gYyInMI3uUCYFrsvXqmCvZ1zKjPQ2eCnXZch9skC6R4mv5qyJpw6FNrejmc-8lZaCKQUtyb)
We’ll then edit **/etc/sysctl.conf **to enable packet forwarding for ipv4:
![](https://lh7-us.googleusercontent.com/zhMMNO9M0r64suUvr7PrYA7WuyNNF2jZQmfjD6WFaRVcpSL_arHPL7_C1MAe9GGO_4RCyWqPAVNiLefwXu5hXxwOIem2MRcRGK5D75F_u_2WaZ1jUcwU9mycZypKLrW4-MPsSJYdkoX1)
We then activate these changes
![](https://lh7-us.googleusercontent.com/a62jBP5lWj6o5Tjh8J1u7ywGdI6PfyzSaC2pHTMmmskb4ZqLwMTmVblWWLXWVHcuh4BQBVLNqsEQsFNYtM0uX-rkUW8C8TVLmQIVhJ-SmzVwDKzJ1CtY6bf246Iirn4tNS0fgf6FbkRB)
Finally we activate the openvpn tunnel on the server
```
openvpn server.conf
```
![](https://lh7-us.googleusercontent.com/0daBfWIxlCPt6RHB4WTtxl9_vbxipDTvRFBAUMxpgI8LMtxV7qsx8KwACCigDj1EjBqAIQxRy52GaEFi-xawfxU1eBt23J6iP3HUNlLPSdUGSB92RELZ5JDjuMkRNoNleGxtsOZNybha)
We check the exposed interfaces by our server
![](https://lh7-us.googleusercontent.com/mHJ-sWcLTFHx3MTDRqnVY0IKC5CCOF5OI0n20mhgPlUHSwxlHm28XM61Kmv4-eigPrvSyfXdaVqe8nuDGp9xudZM9TmQaNSIAQ0SyRdhKt25ZzwJbCDYVPjXI_mUgRuJA1O3-KvLJUWD)
With our server up and running, let's configure the client machine
#### Client configurations
As usual let’s copy the certifications and the key to /etc/openvpn for convenience:
```
cp ca.crt CLIENT.crt CLIENT.key ta.key /etc/openvpn/
```
![](https://lh7-us.googleusercontent.com/1pDnQM0G7etrqRR_K71s1AVpezOSdjRGPFruZoNAglS1pIzDcqlsLmVaihh5mwrbMBgxxpZqRmDksHhx2arzDcmnnYnsmDCnDch1K6moj6ooJcn2r5ezOQQ7CEukhGtfBHb9d8_q9s9Y)
Similarly, we’ll copy the client.conf exampe file in this directory
```
cp /usr/share/doc/openvpn/examples/sample-config-files/client.conf 
```
We add to the `remote` directive the IP address of our OpenVPN server
![](https://lh7-us.googleusercontent.com/x2GQLglxpP1rsOW6OFMjGNRnVDds-kcatwnPMvct854W5SrmT7pZDN9JJmerkiZNznZTangkAodzSVRX1PJUoAQNwK8S3tNpYVN10aEJz6rP0KnLZkDTEUHvDHfjkTd5nXIdX2bKOReF)
And just like in server.conf we specify the path to our certificates and key
![](https://lh7-us.googleusercontent.com/baFfgjeC6vhmfrnR4t7pcabXWHSGYZnl4ov5qvOxjpIJQeuDF73905Y5WnVHDDdNFTpmM3uEOotNd1xWW_yP1RVlkjeGRmO1KG4Uw4jVa0VA39b5smQyzCmOGjm_lshWNWF4NIQb3tnY)
And that of the ta.key
![](https://lh7-us.googleusercontent.com/1M6whwX4csC-u62Y-KuAxyIDdxJb9ju7HIwKRRTBa3DzWXrYkqCQrQop_xFJyIYrUsCV7oMHFm1n0sSAbBgmJCv5vzDf5TNHYFkTH5yOihshqVD8E9UIBcM11AVEdj0XmA83OV2Nem2v)
Finally, let’s establish the tunnel on the client’s side
![](https://lh7-us.googleusercontent.com/xi9prOTa5rF66L-hFqv6McrLXiNJcacRZ9OIaQTVDSSegAFvQDe1LIWSG-m43VkoyJEKmeighfYG_i3_G8zlKb-JNCthnTRZY5eqYM9yUiKPMTxf4_2C4EY9Zp-eMLgGWCMtNxRokFbT)
**Here are the interfaces provided by the client**
![](https://lh7-us.googleusercontent.com/S12NdRb2xOxX5jI12rKw1vojBuQgZXNDXsS2k_awCTUgfJL6Gr72UecIMuVw_lBUXVXPhZLl7zVqpMir63V6sTGg_6wJ18nTJ7PWhfxv3bVbWVN9unSJveOmPrMCzfMrqF_dE-ifyBqn)

#### Authentication against openldap
First we need the package ` openvpn-auth-ldap`
```
sudo apt install openvpn-auth-ldap
```
Then,  let’s copy the auth-ldap.conf from  **/usr/share/doc/openvpn-auth-ldap/examples/** to the a directory called auth under **/etc/openvpn/**
```
cp /usr/share/doc/openvpn-auth-ldap/examples/auth-ldap.conf  /etc/openvpn/auth
```
now we'll edit this file with the relevant information of our LDAP server
```
“<LDAP>
    # LDAP server URL
    URL   	 ldap://192.168.56.101
    # Bind DN (If your LDAP server doesn't support anonymous binds)
    BindDN   	 cn=admin,dc=local
    # Bind Password
    Password    1337
    # Network timeout (in seconds)
    Timeout   	 15
    # Enable Start TLS
    TLSEnable    no
    # Follow LDAP Referrals (anonymously)
    # FollowReferrals yes
    # TLS CA Certificate File
    TLSCACertFile    /etc/openvpn/ca.crt
    # TLS CA Certificate Directory
    # TLSCACertDir    /etc/ssl/certs
    # Client Certificate and key
    # If TLS client authentication is required
    TLSCertFile    /etc/openvpn/SERVER.crt
    TLSKeyFile    /etc/openvpn/SERVER.key
</LDAP>
<Authorization>
    # Base DN
    BaseDN   	 "dc=local"
    # User Search Filter
    SearchFilter    "(&(uid=%u)(objectClass=posixAccount))"
    # Require Group Membership
    RequireGroup    false
</Authorization>”

```
In ** the server.conf file** add the following lines: 
```
plugin /usr/lib/openvpn/openvpn-auth-ldap.so /etc/openvpn/auth/auth-ldap.conf

verify-client-cert optional

```
And in **client.conf:**
```
tls-client
auth-user-pass
```
After restarting openvpn on both the client and server we can authenticate using the login of an LDAP user
![](https://lh7-us.googleusercontent.com/fklldxQJR6AXPBDIhkk73T6JpTnhNauFlgTbyNGMbYU4sFVzGcooF-fqQBR4NecgNwiFjoAyv8otFNXykWbCbqfRiFvO5dqbVq6FvbPhlYTIaB9MxQ3GJSeMKod-q1pH5l8KGOS1cjmn)
![](https://lh7-us.googleusercontent.com/WKyqxZn11y9heI8kIc3ocPbcRMl3Wf9oj4e98KZ5Po1z9argC2TpxW6eaPtY2_m-O9UarMeBKONqFqAz5IdJyhjS0q6rhy26BmOohgaAjn7iRWw3DobqN0StWjY-7gC1yBKtuxgHL4rk)
Now, if we want to grant group based authorizations we need to replace  the Authorization tag in auth-ldap.conf by this:
```
<Authorization>

    # Base DN

    BaseDN   "dc=local"

    # User Search Filter

    SearchFilter "1"

    # Require Group Membership

    RequireGroup    true

    <Group>

    BaseDN   "ou=Group,dc=local"

    RFC2307bis false

    SearchFilter    "(|(cn=grp-GL))"

    MemberAttribute    memberUid

    </Group>

</Authorization>
```
Now users of grp-GL such as bellaaj should connect with openvpn.
