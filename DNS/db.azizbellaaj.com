;
; BIND data file for local loopback interface
;
$TTL    604800
@    IN    SOA    ns1.azizbellaaj.com. root.azizbellaaj.com. (
                  2        ; Serial
             604800        ; Refresh
              86400        ; Retry
            2419200        ; Expire
             604800 )    ; Negative Cache TTL
;
@    IN    NS    ns1.azizbellaaj.com.
ns1.azizbellaaj.com.        IN    A    192.168.56.108
ldap.azizbellaaj.com.        IN    A    192.168.56.101
apache.azizbellaaj.com.    IN    A    192.168.56.104
openvpn.azizbellaaj.com.    IN    A    192.168.56.105
@    IN    MX    10     mail
mail    IN    A    192.168.56.108
@    IN    AAAA    ::1
