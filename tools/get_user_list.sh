#------------------------------------------------------
# Get all users from fence
#------------------------------------------------------
ACCESS_TOKEN=""

users=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $ACCESS_TOKEN" https://portal.pedscommons.org/user/admin/user)
file="./user_list.txt"

echo "${users}"  

echo $users | jq -r '.users[].name' | while read user ; do
    echo $user
    printf "$user \n" >> $file
done
