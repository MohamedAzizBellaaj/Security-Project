# Table of content
- [SSH, Apche, Openvpn authentification via OpenLdap](#SSH-Apche-Openvpn-authentification-via-OpenLdap)
    - [Section1: OpenLdap](#Section1-OpenLdap)
    - [Section 2: SSH authentification via OpenLDAP](#Section-2-SSH-authentification-via-OpenLDAP)
    - [Section 3: Apache authentification via OpenLDAP](#Section-3-Apache-authentification-via-OpenLDAP)
    - [Section 4: OpenVPN](#Section-4-OpenVPN)
- [DNS Server](#DNS-Server)
  - [Install the necessary packages](###DNS-server-configuration)
  - [DNS server configuration](#DNS-server-configuration)
  - [Testing the DNS Server](#Testing-the-DNS-Server)
- [Kerberos](#Kerberos)
  - [Installing necessary packages](#Installing-necessary-packages)
  - [Adding principals and password policies for users](#Adding-principals-and-password-policies-for-users)
  - [SSH Service authentification](#SSH-Service-authentification)
    
# SSH, Apche, Openvpn authentification via OpenLdap
  - [SSH, Apche, Openvpn authentification via OpenLdap](#SSH-Apche-Openvpn-authentification-via-OpenLdap)
    - [Section1: OpenLdap](#Section1-OpenLdap)
    - [Section 2: SSH authentification via OpenLDAP](#Section-2-SSH-authentification-via-OpenLDAP)
    - [Section 3: Apache authentification via OpenLDAP](#Section-3-Apache-authentification-via-OpenLDAP)
    - [Section 4: OpenVPN](#Section-4-OpenVPN)

   

### Section1: OpenLdap

OpenLDAP, or the Open Lightweight Directory Access Protocol, is an open-source implementation of the LDAP standard. 

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

5. If we want to send the certificate we have to modify it to be in binary format, we can do by running

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

**![A screenshot of a computer program
Description automatically generated](https://lh7-us.googleusercontent.com/QVGrSF9YGgZ-H9Jk5b5wRBH3uPRkM2v8WGrA-xevdOZ99cXDBTc2zva9t7qAoOtjrZ_s6Tyxky5kQu-SJ0AU8LtsjEfX4mc5hlZmsok1xu54Jg7ae89HF2C_S-ORmW_h7HRLApYW3BFBYN9FKUPitQ)**
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

![](https://lh7-us.googleusercontent.com/ancIs8g8zWAvu70X1sjQdXAmZ9uaYaOXgD87HLJZPc76lO_NWf74uWJh9g0lMt4FoStQkDa-Q4wYX4atylEp_a-BnRdbHnSPgGhRbUUxHM0VQDPCzqxVBstf4vKvK08CL69hwosWKQQ1)

- make sure that the Common Name matches the FQDN of our server

3.  sign the CSR

```
sudo openssl x509 -in ldap-server.local.csr -out ldap-server.local.crt -req -signkey ldap-server.local.key -days 3650
```
![](https://lh7-us.googleusercontent.com/4pPu9-hzQbZ_OdQBSULrE1EX2HLWevQ6ZtKkNVaUZstDAcSptslArQhM8YSYyOvrvBW2ISoN0n62Z302T0rNGET7V8Ecl76SLFmnfUvGGcWtJC08pjJ6fypCd8n-BLzlz9fh1Rm_Sywe)
4. Copy the certificate and key to /etc/ldap/sasl2 directory
   ![](https://lh7-us.googleusercontent.com/ypfqGrC-Z8I7XKcdzWpQnQXPcrNFZNXZrNWsJQto8X0R1i0yEg_1a5YTmsTzjGmKz2Zg_C6AOEvv6lQSkm9UN2E1YocfdliQdZ0fB5zag8MQCdFhfayw7U1kE_IQdvtI-94aSjLe9oZb)
5. change the ownership to the openldap user by running

```
sudo chown -R openldap:openldap /etc/ldap/sasl2
```
![](https://lh7-us.googleusercontent.com/CHEDAm4eHrZYrI3rbcQZN7KbPRWCaPrG892lUkVyHXN8K6IB6sAHN3csEbGs6M3hNNZpdwMBHxKgWEuj7Vv_xW7lJZPujQVmU78XEBShI_4dQpoZm7XQvFX6znLOjpe9_Xb0fiE2UTYh)
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

8. add the ldaps route in  **/etc/default/slapd**
   ![](https://lh7-us.googleusercontent.com/w0Ej7CmxXEucDj2gBI4wukaV6FJ-nND4o4MMXZNO750MvhHn2GXWUz5CeOKZbdpq0vF-sugKiNtbtrdXP3hVMd4uRs8WEj5RhpFiSMoNFUJFLsZL-KHSlu-Xhj26eglyVRGSax_SpleG)
9. edit **/etc/ldap/ldap.conf**

- comment the line containing TLS_CACERT and add the following lines:

```
TLS_CACERT /etc/ldap/sasl2/ca-certificates.crt
TLS_REQCERT allow
```
![](https://lh7-us.googleusercontent.com/w0Ej7CmxXEucDj2gBI4wukaV6FJ-nND4o4MMXZNO750MvhHn2GXWUz5CeOKZbdpq0vF-sugKiNtbtrdXP3hVMd4uRs8WEj5RhpFiSMoNFUJFLsZL-KHSlu-Xhj26eglyVRGSax_SpleG)
 10. After restarting the slapd service we verify
`	ldapsearch -x -H ldaps://192.168.56.101 -b "dc=local
	`
![](https://lh7-us.googleusercontent.com/43VWZ1g8eMn0ZoznQw5cGbo0yFmgyBWVEUdeSTpAWeT6PxhzNib9nYRY5U4w2lzgX5NDjTi1TI6Njo_A0_4k0380HlN0Sqd0P-mqSaJ6iew2Ld5qzAF-zLlYfBwOP5szJhrqyUAgptTn)

##### Advantages of LDAPS
  
-  **Data Security:**
    
    - The primary advantage of LDAPS is the enhanced security it provides by encrypting the data transmitted between the client and the LDAP server. This is crucial when dealing with sensitive information such as user credentials or personal details.
-  **Confidentiality:**
    
    - LDAPS ensures the confidentiality of the information exchanged during LDAP operations. This is especially important in environments where data privacy and security compliance are critical.

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
   ![](https://lh7-us.googleusercontent.com/PomPoJVlbjthfFRiuaERXo_LHPL285nb4v99qgiBEsI0IH94DP4JJuRJhXW3OLECnNg2WkxDFzRpz6owu-7s8_FlgYZG3MPeOZkEKZtSYfaEBnQTsGazqAWsb6dnbt9U9s2cpKZINdJu)
2. Copy the public key to the ldap
   ```
   ssh-copy-id bellaaj@client
   ```
3. Edit /etc/ssh/sshd_config
   ```
   PubkeyAuthentication yes
   AuthorizedKeysFile  .ssh/authorized_keys
   ```
4. Restart ssh service
   ```
   sudo service ssh restart
   ```
5. Connect to the ldap user without the need of a password

   ![](https://lh7-us.googleusercontent.com/7j1sQqdsJzNRd01YHOiXQ4al6TRUXQWSzIm_dq7iW-DYiDwv93HVcLEqDF8FxZ47ZI5FNTz5vicrdyWmVnOY6gOKsCBV4VEEqjWua9QcddVe8ZLXDUGMUd02ya8naY-PVmH9MuNSHV0_)
   At this stage, we cannot login to the other ldap user (badri) without the password
   ![](https://lh7-us.googleusercontent.com/UQEGxBfth-eOPALGK9QyTyKOawZEKWM6zJJdRhbTdzJVyTg8nvHfhzWXDjkfcLCdIM88FitmTE7kV_0z8PkaXqI9wrlDZZN8X2fVFN6zyqe9FIWijYKgkagmN6Ofe_hhM1LF5vIiiB3J)

6. Edit **/etc/ssh/sshd_config**
   we need to specify which groups are allowed to establish an ssh connection without the need of a password
   we add AllowGroups followed by the name of the group

   ![](https://lh7-us.googleusercontent.com/8CvNhQ2DcUhF_trLqyrsjAnywYgRxHyk2tYBZ5dflTg_Prdx7NQqQJQPiBdaZjHIsRXuXSjf6BNPJmxq9W7cBc5JP27_59dFZV3ftlmc19PeMHDgE9p0usqncdylbV91vdwm6XvzElWe)

7. Test the connections
   We have configured our ldap server such that bellaaj belongs the the grp-GL and badri belongs to grp-RT.
   **Let’s test the connection with a user belonging to the allowed group (bellaaj):**
   ![](https://lh7-us.googleusercontent.com/PxQD3W1Uu2DaEobeY0P055S_3elOekyh9A0isj3FfMlW2Lf0Bg0w8gawOANNABxAU-5fNIzQYQRPKC26sMEecoCF4ZJ7fRTrv4ug8Lm2Aa4H-HXGqDorXuG95aOJAOZ07kZHGDdmdu1p)
   and it works!
   **And now let's test the connection with a member of the other group:**
   ![](https://lh7-us.googleusercontent.com/2KWwnq9r3SzJQD57TakmT-FO90sGKMbfKWaPZeGOU-2U5KuM8r5Aig_Ksf0zO3uVmqzijlsYzcQixNhwtfBiQltXuIklEMJiOBTLZ9RJT00K4EGyGTPY7v3SIouclgOLZrIQRs4pTwL-)
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
First we need the package ` openvpn-auth-ldap`
```
sudo apt install openvpn-auth-ldap
```
Then,  let’s copy the auth-ldap.conf from  **/usr/share/doc/openvpn-auth-ldap/examples/** to the a directory called auth under **/etc/openvpn/**
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

    BaseDN   "dc=local"

    # User Search Filter

    SearchFilter "1"

    # Require Group Membership

    RequireGroup    true

    <Group>

    BaseDN   "ou=Group,dc=local"

    RFC2307bis false

    SearchFilter    "(|(cn=grp-GL))"

    MemberAttribute    memberUid

    </Group>

</Authorization>
```
Now users of grp-GL such as bellaaj should connect with openvpn.
# DNS Server
  - [Install the necessary packages](### DNS server configuration)
  - [DNS server configuration](#DNS-server-configuration)
  - [Testing the DNS Server](#Testing-the-DNS-Server)
## Install the necessary packages
```
sudo apt install bind9 bind9utils bind9-doc dnsutils
```
1. **bind9:**
    
    -  the core package that provides the BIND (Berkeley Internet Name Domain) DNS server software.
2. **bind9utils:**
    
    - The `bind9utils` package contains utility programs and tools that complement the functionality of `bind9`.
    
3. **bind9-doc:**
    
    -  The `bind9-doc` package contains documentation and manuals related to BIND9.
    
4. **dnsutils:**
    
    -  The `dnsutils` package provides utilities for querying DNS servers and performing DNS-related tasks.

## DNS server configuration
We  go to  **/etc/bin** and edit named.conf.local
the  named.conf.local file is used to define local zone configurations.
Zones in DNS are logical partitions of the domain name space. 
Here we have created a new zone called azizbellaaj.com that has the configuration file db.azizbellaaj.com under **/etc/bind/db.azizbellaaj.com**.
![](https://lh7-us.googleusercontent.com/2yGO3pxAKElBwEaCsb1YgGlbcaLkF0-ayHhOnSYfE4AccSdlLXbi3BJg_O8ehIA4jXH0vYmCtUJ9sHBNZbxScLH8CRcNxQcdj61aRgj8XnY5xaCeldBbKBwvLcUMNK0nSR2YxI2hL-qi)

We now create the file db.azizbellaaj.com. We specify the addresses of our LDAP, Apache and OpenVPN servers with their domain names.
![](https://lh7-us.googleusercontent.com/4Y5az2gdRdYyToVJY9dpFlOKsxzfVMEzgXWfTwcjm0MA43oSpjjUJeSnVV2_6baLgdrw9UFFjKOLrOFlpU9lxLmtr-DSs6LrhvFeokHHzaM9fwMiFjGYrmYeaEEwCyNiSuUfCrbAq7YY)Then we execute: 
```
named-checkconf
named-checkzone azizbellaaj.com db.azizbellaaj.com
```
And we finally restart bind9.
## Testing the DNS Server
In the machines of the our LDAP, Apache and OpenVPN servers,  we edit /etc/resolv.conf:
We add the ip address of the dns machine above nameserver 127.0.0.53.
![](https://lh7-us.googleusercontent.com/URo7bDWeTZcjwFIStZjFMvcy8QIou7GeRUJ2rjUCTLLkj1-I3SFgs2Dwc8jHCt8Twe962PDjHJNyrlBAZtgrSSxPNkbmUEEemymi_vt1x8s-laq7uRsn_-TfTtyHWGtb2SPRsgMQRgGc)In the client machine, we can now connect to the diffrent servers with the names  specified in named.conf
![](https://lh7-us.googleusercontent.com/p2yqPzYvyGwinJWbOxkCmE_J9ket1fUj60BMSc8WMNBFpiUy7t3jS3xFAiHeDE7AzoKBJjADQ4Vfyxn62UWyAb1buUsdTH0CF6knXQy4sJTeAc6QAbZwRrxU0wJbuMJLoZzJ5v-RPq_u)
![](https://lh7-us.googleusercontent.com/BTmePG_pgRgcWwyMZnoEYVzwggCzLM2_GSBYcac_hZRVGlBp29G96_8ajQlHVC30rq4Gu4yzwyhtFSDs5Ws9hMwDnK-fKUM1vxPWVBVrN9EUC-AwG-i6Ug6yhp0D0xyTXW6VYqmtsEzL)
Even if the service is offline, the name resolution still works!
![](https://lh7-us.googleusercontent.com/aQRgkWJG0uIkBCkaDoGFESPv_6AHWr6Tj1Il_00FvYcjZ3Hgfen6g8_nXvY3RftVaaKcbYcuFZyrUh9nkGdYNzw2HeE4gdCHZQvJF-n66XMdgOg5FaCM70BSNNT_qDs_u3xn_WZ9NNzx)
![](https://lh7-us.googleusercontent.com/i6S8LjF8g6TU333DhV-IdMzC7Un8vzKbBg2_-m4nh7uelXaEA-3POS4GP_1D3T8ZvjxTt-QwkDozxp9KmQmcYc0Gc-umMqsRoBGH0ye_JUB5Qsr4U1I_t4GDMGjJ1H4mDPzew5NJ5Kr6)
# Kerberos

  - [Installing necessary packages](#Installing-necessary-packages)
  - [Adding principals and password policies for users](#Adding-principals-and-password-policies-for-users)
  - [SSH Service authentification](#SSH-Service-authentification)
    - [install ssh server](#install-ssh-server)
    - [edit sshd_config](#edit-sshd_config)
    - [adding user and **root/admin** principals](#adding-user-and-rootadmin-principals)
    - [Assigning the keytab to the admin and changepwd principals](#Assigning-the-keytab-to-the-admin-and-changepwd-principals)
    - [Add a new user](#Add-a-new-user)
    
Kerberos is a network authentication protocol designed to provide secure authentication for client-server applications over an insecure network.It operates based on the concept of a trusted third party (Key Distribution Center or KDC) and uses symmetric key cryptography to secure communication between entities
## Installing necessary packages 
```
sudo apt install krb5-kdc krb5-admin-server krb5-config  -y
```
1. **krb5-kdc:**
    - **Description:** `krb5-kdc` is the Key Distribution Center (KDC) component of the Kerberos system. The KDC is responsible for issuing ticket-granting tickets (TGTs) and service tickets.
    
2. **krb5-admin-server:**
    
    -  `krb5-admin-server`  provides administrative tools and interfaces for managing the Kerberos database and policies.
    
3. **krb5-config:**
    
    -  `krb5-config` is a utility package that provides scripts and tools for querying and configuring Kerberos settings.
During installation, we will be prompted to enter information of our realm. 
In Kerberos, a "realm" is a logical administrative domain where networked systems share a common Kerberos database and trust each other for authentication
![](https://lh7-us.googleusercontent.com/i8tLK4sYHdqj8gYwpvo47aLMD19N6pMy_XqQJ5M5mJJ3fMTkMGX-zDB-cU9gDHSTJfQg3XNbyOodLBQqyRDU67WFsZAaKBIAL31ylMpZgvSuqqTJjzNLY2IAyPKg3dvSA5NLKZtfHcFIz8fpM36aG6U)   
![](https://lh7-us.googleusercontent.com/KCK66TrnlhwyCFYvsw1p1Qyj2NGQF8dCqsq5LB10IB8ASE0oEY8Z13Osa6z6LtL0P2cLwk7W7XsSzAg4DSl8lK9IU1YD-4ignY2aFwSHUAJgDG-lLbtlABkII6Hj5FDnJQJcWmn6MJSoJQdAArUhhKk)
![](https://lh7-us.googleusercontent.com/5HI8WDvxJo5uxcxWZzs9KErTMiF_MDMJe0E_1XYjDIon1CnWBzXLcnkKncxas1YNJfONJ1VUpyedEtg2FNXEwjYow4vnSqLXBsDar0aIndvH14DSah7XNH96J3Cp0Q54TfNjjW1Eh3FLj4Ssx7-fey8)
![](https://lh7-us.googleusercontent.com/beZXKF6l6Q66bSyCLkq-lG5tINpofp1D8qAuMRUa5uVDIiQDF-Ht0B2mGXK87xKZtJXhBMpcDSsoCP1F9664W-n9Ej51QfmZzN29RRBhnr6NiXI-k8hLSKbKg332IsOtboOIt-LUO_x77eDbZ8_uPP4)
With the installation done, we can check krb5kdc.conf file. This file specifies  parameters related to the operation and behavior of the Key Distribution Center. 
![](https://lh7-us.googleusercontent.com/_c8o7sp4xHLr1V1WqDywKJCuEn22u68moU1U8zwwt68-H0WsRpfp1YasLUxSg4lypsK5kTp2AM1TbKNnWacaj14qINpaC835A8HbKHcknfa-RPxpjgHOc3mYo5hMaeoM1C7TRy1FjcHy6I20UjTZ6AE)
## Adding principals and password policies for users
First, let's create a new Kerberos realm and enter the master key.
```
krb5_newrealm 
```
![](https://lh7-us.googleusercontent.com/aRb3xgtk44hvoPYJYSwJ7qGLXxJY-4tUQA7Ff8A0Jo3vpIHulz2VwygpGsk_1OagJ8muasdLrvHjDizGrri3umTOj5yUkFDR8BJOVHHjD25tzKZFR-WNbxOKMGuFi7XSstHv56U9rwX9xNvvQEUzV6I)
![](https://lh7-us.googleusercontent.com/uObPx0uBniixdAK-OSTo1Nyzc6ATM9U-71jQLHhWtqr5bWC21R-M8ocK3xzKXB1xZjZC-gTPVJaPoDpEAGrm8HhmQdF5VRB-wRpl63UbROc6jeguOtycdnv-BJJ2lEAHYhNJQCoK0e9YgyKygeSZYXc)
we'll find under **/var/lib/krb5kdc** the created principal's files
![](https://lh7-us.googleusercontent.com/0gZd-arVKQbEWNGRyXOS96DGRWw5sJ9049kFDzQpEBNsHYgWYtn-oOYTcNHbNGz51Ou_EHuougd6THO654UhF0hFr_OuFPbQbeVLNQAYgpdPN6Xtv_0xTUjOzZiEz3NNa-odaO6FdMnaRCjFJae3Dhk)
now let's check the principal's permessions in kadm5.acl and uncomment the last line. 
An access control list (ACL) file  defines the permissions and restrictions on administrative operations within the Kerberos database.
![](https://lh7-us.googleusercontent.com/F_jhpjg3VYZ56okEXBXl0c_oLD5MTDkTzaPKiyIOzuzz7fAPrB96qajprx8hD2lQcV-Z-XesBBris3Edtbb_g7Q_gY4V_PdGcrwEsgpw7xnquUwYplcogFlLq8qsoMZeC4qBp84OSg6dMtpz50c4svM)
To create a user, we  authenticate as our root principal and run 
```
kadmin.local
```
![](https://lh7-us.googleusercontent.com/NtDu06PRkCit0UQP3zsHgd1K4XkPddSGHvZQlRUHYWtOs6chQ6XQDrebd2wt4G1P-7zmBKDKr80uOm_fyd7lx8qpOIDsOEhBlr4MVdkqWrV0-WmRKFW7QIQBM38k8__-npccshglA0EeAdO3cd8ROOk)
We can now create a principal `user` by  running 
``` 
add_principal user
```
![](https://lh7-us.googleusercontent.com/mIBhUqojkbRBDFS1Hna7RFWbmHLgEJos4U1Sez2-YmEhFeRY2TRo_hESmxMuMfUJZMg02a5qCtMIwc0z2kz03MtyRdgoSVAnl1vcCG46WyEpjNi5fEt5mxF2u94y8lh6SX_z3s9WT82f4TbJ4np3pkA)
Then, we add the principals `root/admin`  and host/kdc.server.tn
(we can list all our principals running `list_principals`)
![](https://lh7-us.googleusercontent.com/-wdSrkkYK0ox9RbfIDuyraq2_9-tO43FaAHiwwYcLHu_ZDqQkPrHUwXKj5EFy8yRLn-MMJvLFABKp0pt2xp8OJnx69838_8WrRbsiyxWYphin3R59nzIMwobWupgvIS-iYaa47lGRJM10iryHDXeA-s)![](https://lh7-us.googleusercontent.com/C_2GPvP_svp5uOydx-PPP2hNFeoVxJUDboLYfAOXXPV1HmjxdcGZFmScG-bTY37YqpL8lxf29GuWIeQQfh_1yhOqpTndiB3-8H9K-2WccU5HRz0jjhQlQWvzdCA1Q1DluWlfWPRi2X8sz3y7IoQnyVc)
Before proceeding, we need to restart the kerberos service 
![](https://lh7-us.googleusercontent.com/7lJtJjkZDzv9nQpcWwf7VO8SmuFQ9NscByJY3XDga8HsU4aIliAkS4JLeW0xyCoBTYkbuTNFhRnKO-RNQxcdw2Xe15haq_EddzK51ddh52uslKgR1v_ETMZoF2Yrbu0Kd5PilTdf3QiI7zjvdyfwG2g)
Now let's proceed and create the keytab using  **ktutils**
A keytab  is a file used in Kerberos authentication systems to store one or more secret keys for Kerberos principals.
let's run 

```
kutils
```
![](https://lh7-us.googleusercontent.com/muB2ppWI3AAhfQi_y68xc8Gg7Hpz2rsoKDj0A8jumf1ErvXyiKy5-bHqfliX9ON2_MaxWoIUH4VTDd2vVgUbsAw01rq0QX-Pb9F6xSLvFZBkh9ssW-Vqd3z9BVdyVX8zrpivYC3-A8H6anrBTqqGqz0)

let's add an entry to our keytab file with the principal roo/admin
```
addent -passowrod -p root/admin@SERVER.TN -k 1 -e aes-256-cts-hmac-sha1-96
```
in order to write the line into our file we run wkt follwoed by the path of the keytab file
```
wkt /etc/krb5kdc/kadm5.keytab
```

![](https://lh7-us.googleusercontent.com/b6XfiIb7xEBigPEj-fWGrJyy3SUJsGYB-6bPWFmPHjJr2hLG6dY9rm-p8-wtska7rstcmkHk2Odvks7PZ1eNe5-m_gBLpKd2KVhIHfqK3ACWK1QW7UyeQ6qVNdw4Fb-T6ymH2FKTIvHU9vziuAZgnZs)

let's check the added entry in the keytab file
![](https://lh7-us.googleusercontent.com/xO-JNfEkJ-DO4LNHKXATRTLhuH4Ab3iAb9k5M53NTtTvKJ6ZlowIp7FmZSaBJnqjS94rFyjAGH6sWlX3kKxfO3j_W9iT_8Yqo208ojXMXNTAItZnbTXqkGTdGoV2lVwFDFj0OYzqcnBsVQ0nac7AsqI)
And if we want to read from our keytab
```
rkt /etc/krb5kdc/kadm5.keytab
```
![](https://lh7-us.googleusercontent.com/QsMKzDFhxyF7FKQXz4sSTS9q35j5Mf1gnQpKQvE1Fe7_FUInyaRV0rMwEt1rdCu7gUiHLpaFWqIa14pOdCqeqKjYYoiI9-WiOSUAEJoz-hk94gJjkzOGsDE47ji49QnXsVcXKlmGxR9SU6Ubq2rgbXM)
We'll do the same proceedure to add an entry for the host principal
![](https://lh7-us.googleusercontent.com/mJvUWFYX_JzGErDPXpkd5LATMzTObDF5YzHbIXmYXK4Uiem3Y3fzkPBnBamBUTx1aoqRpmiMPNfNTmMBpGgzQH0FWrSK3O9auH7DagGxE4xhP7Hl6aeVD98j9heDTeMPZymzMuAslECYfFm6Cai7CUE)
To display all the entries in our keytab so far we run 
```
klist -k kadm5.keytab
```
![](https://lh7-us.googleusercontent.com/W6pZUob2GaNUMpQ823Tlq-uv2Yt0XbttRabmUfdaUioZUPbJLUNbpAYDky28NWcPefBI2PjJrEJtkf2m_CsEX0hUA6-BuvybsFMHNB2ExoYV0Xz7z3PQ1eZnUb78OBv_lWYdXnkya3K0Zfga5BxKoRk)
## SSH Service authentification
### install ssh server
```
sudo apt install openssh-server
```
### edit sshd_config
we will uncomment the lines 27, 28, 71 and 72
**![](https://lh7-us.googleusercontent.com/RRqIftHScQUF1TS-xpMw8DFxf1NNfwnpNHkv0PbwFj2M4umF1Min7KacMDDau0vtu39UKmTf300z321gUj2pvY2Zb281qVa0hp8SAINuTbDSmEcm4Xv_BipplzlegWPvOBP9ytELbTwlmbOAXBkOkEM)**
**![](https://lh7-us.googleusercontent.com/t7EbXdqk3Gw5sAe1W3OUnZt-pCSTWr-qfdfQ6JAt76gt6HwWaufZgQDQZeXbdpIvGNiVlRmJCSSSfar-k00jw09YesoL39kSmISyTEqfzdkNQ9GSWL5crp5_NTylcPFA7zz167LHLDGKUMpKJznH-u0)**
### adding user and **root/admin** principals

![](https://lh7-us.googleusercontent.com/YBz3TyiuJnsTO5KtwbECUe5yU30l8iFu6w5c7Q-CWqzJjWKFOSIX75cCShZdipw1QRp00Gd6fZI3r7x-N7oDlLIGTPy-MBdmhyFmKvTrJxWGWxaj0M3mtaDMSu2zEUzfy4WGD1ic_s9RbErgxK9nfkM)
### Assigning the keytab to the admin and changepwd principals 
```
ktadd -k /etc/krb5kdc/kadm5.keytab kadmin/admin
```
![](https://lh7-us.googleusercontent.com/1kfFPex7CCDSp1d1kfIJMYW_c7UpPbIZe0Q3IY7E3sASmIuheHBrWjnyVCGF4e2oYbtqK63YatZus7rmujdHb4CoGewNMPepuga_yFS2OFDVCqtAtIeqpF-3XqFvw3x0c9fx8VR1qZpIbKrTVPvU1b4)
### Add a new user
we'll add the user 'utilisateur'
```
adduser utilisateur
```
![](https://lh7-us.googleusercontent.com/vEPufwt9uEfA61BN2NsgGSAhQon3aSOSuRCph_5WcUx8bwle9ySM54IDotxWb9XpJ7ibLkIN1cVGguTMjtiJqCKPP5hidqNwoYUMU-rQQJ8f1hqObQL57_njD394r-zIIl7Dgepy9Mfk1jyLC1z8yxc)we authenticate as the new user 
```
sudo  -l utilisateur
```
![](https://lh7-us.googleusercontent.com/mbCMdkL7sMPwOUEI1o4mrKLW34vOMs2XEevZAmfXMFXPIH9I-4YkGufPhvPQXi4l_LH233YCTe7-cKE_1LVri8IgZ9pExZdt6tWtYPEHS8boFwG2xRBSEiDlI2of7nV1uhOToE873d60C689gtH5bJU)
then we'll try to ssh to the kdc server without being asked to enter its paswword 
**![](https://lh7-us.googleusercontent.com/mbCMdkL7sMPwOUEI1o4mrKLW34vOMs2XEevZAmfXMFXPIH9I-4YkGufPhvPQXi4l_LH233YCTe7-cKE_1LVri8IgZ9pExZdt6tWtYPEHS8boFwG2xRBSEiDlI2of7nV1uhOToE873d60C689gtH5bJU)**
