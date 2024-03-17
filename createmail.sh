#!/bin/bash
# Created by dyeadal
# Licensing information

#####################################################################
# formatted value of date output as day and timestamp marker
# most likely will differ based on distribution
# Originally created for ProxMox (Debian) distrbution

daystamp=$(date | awk '{print $3, $2, $4}')
timestamp=$(date | awk '{print $1, ",", $3, $2, $4, "@", $5, $6, $7}')

#####################################################################
### easy to edit fields to insert to email. 

# stores the subject line contents of email
subjectline="Server Update Pending: ${daystamp}"

# content of email head (currently empty)
emailhead=""

# stores email's head content
emailtitle="Pending Updates for HOSTNAME: $HOSTNAME"

# You can use <br> to start new lines in email body
emailbody="System Time: ${timestamp}<br><br>Packages that are upgradable:"

#####################################################################

# copy email template and create custom email 
cp template.html email.html

# inserts subject line
sed -i "3 s/$/${subjectline}/" email.html

# inserts head content and ending html element
sed -i "9 s/$/${emailhead}<\/head>/" email.html

# inserts main title
sed -i "11 s/$/${emailtitle}<\/h2>/" email.html

# inserts body text
sed -i "12 s/$/${emailbody}<\/p>/" email.html

# stores upgradable packages in txt file
# pipes output to awk which removes first line
# stores awk output in txt file
apt list --upgradeable | awk 'NR > 1 {print}' > packagelist.txt

### loop to insert packages needing to be upgraded to HTML table
# checks if file exists and opens file
if [ -f "packagelist.txt" ]; then 
	# while loop to parse lines and add table row HTML elements 
	while IFS= read -r line; do
		
		# start row
		echo "<tr>" >> email.html

		echo "<td>" >> email.html
		# package name value for 1st row
		echo "$line" | awk '{print $1}' >> email.html
		echo "</td>" >> email.html 
		echo "<td>" >> email.html
		# package current version value for 2nd row
		echo "$line" | awk '{print $6}'| sed 's/.$//' >> email.html
		# package version available value for 3rd row
		echo "</td>" >> email.html
		echo "<td>" >> email.html
		echo "$line" | awk '{print $2}' >> email.html

		# end row
		echo "</tr>" >> email.html

	done < "packagelist.txt"
else
	echo "Error: file not found"
fi

# inserts end of HTML email elements
printf "</table>\n</body>\n</html>\n" >> email.html
