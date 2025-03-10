# Load environment variables from .env file
$envFile = ".env"
if (Test-Path $envFile) {
    Get-Content $envFile | ForEach-Object {
        if ($_ -match "^(.*?)=(.*)$") {
            [System.Environment]::SetEnvironmentVariable($matches[1], $matches[2])
        }
    }
}

# Define the path to the file containing the list of servers and passwords
$serverList = "servers.txt"
$passwordFile = "passwords.txt"

# Function to generate a random password
function New-RandomPassword {
    $length = 16
    $characters = $env:CHARACTERS
    return -join (1..$length | ForEach-Object { $characters[(Get-Random -Maximum $characters.Length)] })
}

# Read the list of servers from the file
$servers = Get-Content $serverList

# Go through each server and change the password for the root user
foreach ($server in $servers) {
    Write-Host "Connecting to $server..."
    
    $newPassword = New-RandomPassword
    $escapedPassword = $newPassword -replace "'", "'\\''"
    
    $command = "echo 'root:$escapedPassword' | chpasswd"
    
    try {
        ssh root@$server "$command"
        if ($?) {
            "$server : $newPassword" | Out-File -Append -Encoding UTF8 $passwordFile
            Write-Host "Pwd for $server was successfuly changed."
        } else {
            Write-Host "There was a problem during the Pwd change $server."
        }
    } catch {
        Write-Host "Couldn't connect to the server $server."
    }
}