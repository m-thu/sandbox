#!/bin/sh

# Cowrie logfile
LOG=/home/cowrie/cowrie/log/audit.log

# Generated HTML file
HTML=/home/pi/cowrie-stats.html

# HTML header

cat >$HTML <<HTML_HEADER
<!DOCTYPE html>
<html>
<head>
	<meta charset="utf-8">
	<title>Cowrie SSH Honeypot Statistics</title>
	<style>
		table {
			border-collapse: collapse;
		}

		td, th {
			border: 1px solid #dddddd;
			text-align: left;
			padding: 8px;
		}

		tr:nth-child(even) {
			background-color: #dddddd;
		}
	</style>
</head>
<body>
<h1>Cowrie SSH Honeypot Statistics</h1>
HTML_HEADER

# Table: connections / IP

cat >>$HTML <<IP_TABLE_HEADER
<table>
<tr>
	<th>IP (Hostname)</th>
	<th>Connections</th>
</tr>
IP_TABLE_HEADER

<$LOG awk '/New connection/ {
	split($4, ip_address, ":")
	ip[ip_address[1]]++
}

END {
	for (i in ip) {
		"dig +noall +answer -x " i | getline rev_dns
		if (rev_dns != "") {
			split(rev_dns, host)
			gsub(/\.$/, "", host[5])
			print i " (" host[5] "):" ip[i]
		} else {
			print i ":" ip[i]
		}
	}
}' | sort -nr -k 2,2 -t ':' | sed 's/\(.*\):\(.*\)/<tr><td>\1<\/td><td>\2<\/td><\/tr>/' >>$HTML

cat >>$HTML <<IP_TABLE_FOOTER
</table>
<br>
IP_TABLE_FOOTER

# Table: username/password

cat >>$HTML <<USER_TABLE_HEADER
<table>
<tr>
	<th>Username/password</th>
	<th>Attempts</th>
</tr>
USER_TABLE_HEADER

<$LOG awk '/login attempt/ {
	user_password[$4]++
}

END {
	for (i in user_password) {
		count = user_password[i]
		gsub(/&/, "\\&amp;", i)
		gsub(/>/, "\\&gt;", i)
		gsub(/</, "\\&lt;", i)
		gsub(/"/, "\\&quot;", i)
		print i ":" count
	}
}' | tr -d '[]' | sort -nr -k 2,2 -t ':' | sed 's/\(.*\):\(.*\)/<tr><td>\1<\/td><td>\2<\/td><\/tr>/' >>$HTML

cat >>$HTML <<USER_TABLE_FOOTER
</table>
<br>
USER_TABLE_FOOTER

# Table: remote SSH versions

cat >>$HTML <<VERSION_TABLE_HEADER
<table>
<tr>
	<th>Remote SSH version</th>
	<th>Count</th>
</tr>
VERSION_TABLE_HEADER

<$LOG awk '/Remote SSH version/ {
	ssh_version[$5]++
}

END {
	for (i in ssh_version)
		print i ":" ssh_version[i]
}' | sort -nr -k 2,2 -t ':' | sed 's/\(.*\):\(.*\)/<tr><td>\1<\/td><td>\2<\/td><\/tr>/' >>$HTML

cat >>$HTML <<VERSION_TABLE_FOOTER
</table>
VERSION_TABLE_FOOTER

# HTML footer

DATE=`date`

cat >>$HTML <<HTML_FOOTER
<br>
<p>Generated on ${DATE}</p>
</body>
</html>
HTML_FOOTER
