#####created by Javid Ibrahimov#####
#####Fetch Users, Groups and Group Membership from Vault for ISPSS environment#####
#####Requires IdentityAuth.psm1 file in the same directory#####
Import-Module -Name .\IdentityAuth.psm1
cls
Write-Host "This script will export list of users and groups to CSV file." -ForegroundColor Yellow
[string]$subdomain = Read-Host 'Please provide your tenant subdomain'
[string]$platformURL = "https://platform-discovery.cyberark.cloud/api/identity-endpoint/" + $subdomain

$identity = Invoke-RestMethod -Uri $platformURL -Method Get
[string]$identityURL = $identity.endpoint
[string]$identityUser = Read-Host 'Please provide your username'
[string]$FileName = Read-Host "Please provide CSV file name to export list of users and groups:"

while (Test-Path $FileName -PathType Leaf)
    {
    [string]$FileName = Read-Host "Export File already exists! Please provide an alternative file name"
    }



$logonToken = Get-IdentityHeader -IdentityTenantURL $identityURL -IdentityUserName $identityUser

[string]$pvwaURL = "https://" + $subdomain + ".privilegecloud.cyberark.cloud/PasswordVault/"
[string]$UsersGroupsListtURL = $pvwaURL + "API/UserGroups?includeMembers=true"
$UsersGroups = Invoke-RestMethod -Uri $UsersGroupsListtURL -Method Get -Headers $logonToken -ContentType "application/json"

$Result = @()

foreach ($member in $UsersGroups.value)
    {
    $i = 0
    while ($i -lt $member.members.count)
        {
        $Result += [PSCustomObject]@{
        GroupID = $member.id
        grouptType = $member.groupType
        GroupName = $member.groupName
        Description = $member.Description
        Location = $member.location
        UserName = $member.members[$i].username
        UserID = $member.members[$i].id
        }
        $i++
        }
    }
$Result | Export-csv $FileName

Write-Host 'List of Users and Groups will be exported to current directory, with ' $FileName ' filename.' -ForegroundColor Yellow

