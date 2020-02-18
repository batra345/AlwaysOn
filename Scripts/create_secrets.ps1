# define variables 
$secretname1 = 'mytope' 
$keyvault1='alwaysonkv01'

#Autogenerate complex password
# Load .NET assembly
Add-Type -Assembly 'System.Web'

# Create a strong password
Write-Output ('Generating password...')
[System.String] $strDBAdminPassword = [System.Web.Security.Membership]::GeneratePassword(48, 16)
[System.Security.SecureString] $sstrDBAdminPassword = ConvertTo-SecureString $strDBAdminPassword -AsPlainText -Force

# Create new secret with complex password
Write-Host "`nCreating new secret - $secretname1" 
#Set-AzureKeyVaultSecret -VaultName $keyvault1 -Name $secretname1 -SecretValue $sstrDBAdminPassword
Set-AzKeyVaultSecret -VaultName $keyvault1 -Name $secretname1 -SecretValue $sstrDBAdminPassword