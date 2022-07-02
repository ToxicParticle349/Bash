#!/bin/sh

echo "enter First IP address"
read ip

if [[ "$ip" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
  echo "IP address accepted"
else
  echo "invalid IP address"
fi

echo "enter Last IP address"
read lip

if [[ "$lip" =~ ^(([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))\.){3}([1-9]?[0-9]|1[0-9][0-9]|2([0-4][0-9]|5[0-5]))$ ]]; then
  echo "IP address accepted"
else
  echo "invalid IP address"
fi

ip1=$(echo $ip | awk -F. '{print $4}')
echo "seperated last octet of first IP is: "$ip1

lip1=$(echo $lip| awk -F. '{print $4}')
echo "seperated last octet of last IP is: "$lip1

firstthreeoct=$(echo $ip | awk -F'.' '{print $1,$2,$3}' OFS='.') 
echo "first three octets of entered IP range: "$firstthreeoct

seq -f "$firstthreeoct.%g" $ip1 $lip1 > server_ip_range.txt

echo "enter IP you want to remove"
read rmip
sed -i /$rmip/d server_ip_range.txt

cat server_ip_range.txt | while read output
do
	ping -c 1 "$output" > /dev/null
	if [ $? -eq 0 ]; then
	echo "host $output is up"
	query="SELECT * FROM ERRORQUEUE ORDER BY DATETIME DESC"
    	mysql -u root -p errorqueue -h $output -e "$query"
	else
	echo "host $output is down"
	fi
done
rm -r server_ip_range.txt
