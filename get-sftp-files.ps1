
#install-module posh-ssh
#https://github.com/darkoperator/Posh-SSH

# SFTP Creds
#(get-credential).password | ConvertFrom-SecureString | set-content “C:\scripts\passwords\sftp-password.txt”
$username = “sftpusernamehere”
$password = Get-Content “C:\scripts\passwords\sftp-password.txt” | ConvertTo-SecureString
$credential = New-Object System.Management.Automation.PsCredential($username,$password)

# SFTP Variables
#$credential = Get-Credential sccogorders
#sftpserver = "ipordnsofserverhere"
$session = New-SFTPSession -ComputerName $sftpserver -Credential $credential -ErrorOnUntrusted -Verbose
$sessionid = $session.sessionid
$files = Get-SFTPChildItem -Index 0 -Path / 
$cogfiles = Get-SFTPChildItem -Index 0 -Path /Exscribe-Files

# SMTP Variables
$mailserver = "mxrecordofdomain"
$recipient = "receipientofemail"


foreach ($file in $files) {
    if ($file.name -like "*.pdf"){ 
        Write-Host $file.name
        Get-SFTPFile -SessionId 0 -RemoteFile "/$($file.name)" -LocalPath "localpathfordownloadedfile" -Verbose
        Move-SFTPItem -SessionId 0 -Path "/$($file.name)" -Destination "/Downloaded/$($file.name)" -Verbose

        Send-MailMessage -To $recipient `
                    -From "mailserviceaccount" `
                    -Subject “New File!” `
                    -Body "A file was created here: '\\somedomain\someshare\sftp\$($file.name)'" `
                    -SmtpServer $mailserver `
                    -UseSSL
                    #-Credential $anon
    }
}

Write-Host ($sessionid)

Remove-SFTPSession -sessionid $sessionid

#Get-SFTPSession | Remove-SFTPSession
