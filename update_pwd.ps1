# I need a script, that will connect to servers provided in a text file. It will generate a password for each server ( random characters 20 chars long ) and then it will change the password for the user. Connection will be done with root. Store the password with hostname in a separate file.
# Define the path to the file containing the list of servers
$serversFile = "servers.txt"
# Define the path to the file where the passwords will be stored
$passwordsFile = "passwords.txt"

# Function to generate a random password
function Generate-RandomPassword {
    param (
        [int]$length = 20
    )
    $chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()"
    -join ((1..$length) | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
}

# Read the list of servers from the file
$servers = Get-Content -Path $serversFile

# Initialize the passwords file
"" > $passwordsFile

foreach ($server in $servers) {
    # Generate a random password
    $password = Generate-RandomPassword

    # Change the password for the root user on the server
    $command = "echo root:`$password` | chpasswd"
    ssh root@$server $command

    # Store the hostname and password in the passwords file
    "$server : $password" | Out-File -FilePath $passwordsFile -Append
}