#Steam ID fetcher Made by khanichan

function Get-SteamIDFromRegistry {
    $RegSteamIDHash = reg query HKEY_CURRENT_USER\SOFTWARE\Valve\Steam\ActiveProcess /v ActiveUser
    $Steam32IDReg = [uint32]($RegSteamIDHash[2] -replace ".*(?=0x)","")
    $Steam64IDReg = (76561197960265728 + $($Steam32IDReg))
    Write-Host "Your Steam32 ID is: $Steam32IDReg"
    Write-Host "Your Steam64 ID is: $Steam64IDReg"
}

function Get-SteamCommunityID ($search) {

    #$searchTerm = Read-Host "Enter Steam profile URL or Steam ID"
    $url = "https://steamcommunity.com/id/$search"
    $html = Invoke-RestMethod -Uri $url
    
    #Use regular expressions to extract Steam IDs, Nick Name, and Profile URL
    $steam64ID = [regex]::Match($html, 'g_rgProfileData = {"url":"[^"]+","steamid":"(\d+)",').Groups[1].Value
    
    # Output the variables
    Write-Host "Steam64 ID: $steam64ID"
    }


function Get-SteamUserID ($username, $key) {

        $vanityURL = $userName
        $responseVanityURL = Invoke-RestMethod -URI "https://api.steampowered.com/ISteamUser/ResolveVanityURL/v1/?key=$key&vanityurl=$vanityURL"
        $steamID = $responseVanityURL.response.steamid
        Write-Output $steamID
    }

function Get-SteamVanityURL ($steamID, $key) {
    
        $playerSummary = Invoke-RestMethod -Uri "https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v2/?key=$key&steamids=$steamid"
        $playerSummaryPersonaName =  $playerSummary.response.players.personaname
        Write-Output $playerSummaryPersonaName
    }

function Get-SteamUserGames ($steamID, $key) {
    
        $getOwnedGames = Invoke-RestMethod -Uri "https://api.steampowered.com/IPlayerService/GetOwnedGames/v1/?key=$key&steamid=$steamID&include_appinfo=true"
        $ownedGames = $getOwnedGames.response.games
        Write-Output $ownedGames
    }
    

function Get-SteamLevel ($steamID, $key) {
    
        $steamLevel = Invoke-RestMethod -Uri "https://api.steampowered.com/IPlayerService/GetSteamLevel/v1/?key=$key&steamid=$steamID"
        $steamLevelPlayer = $steamLevel.response.player_level
        Write-Output $steamLevelPlayer
    }
    function Get-SteamFriendsList ($steamID, $key) {
    
        $friendsList = Invoke-RestMethod -Uri "https://api.steampowered.com/ISteamUser/GetFriendList/v1/?key=$key&steamid=$steamID"
        $friendsList.friendslist.friends
        Write-Output $friendsList
    }

function Get-SteamBans ($steamID, $key) {
    
        $playerBans = Invoke-RestMethod -Uri "https://api.steampowered.com/ISteamUser/GetPlayerBans/v1/?key=$key&steamids=$steamID"
        $playerBansSummary = $playerBans.players | Select-Object -Property CommunityBanned,VacBanned,NumberOfVACBans,DaysSinceLastBan,NumberOfGameBans,EconomyBan
        Write-Output $playerBansSummary
    }
function Get-SteamGroups ($steamID, $key) {
    
        $userGroupList = Invoke-RestMethod -Uri "https://api.steampowered.com/ISteamUser/GetUserGroupList/v1/?key=$key&steamid=$steamID"
        $userGroupListSumamry = $userGroupList.response.groups
        Write-Output $userGroupListSumamry
    }
    

function Get-SteamIDXYZ ($search) {

    $url = "https://steamid.xyz/$search"
    $html = Invoke-RestMethod -Uri $url
    
    #Use regular expressions to extract Steam IDs, Nick Name, and Profile URL
    $steamID = [regex]::Match($html, "Steam ID\s+<input type=""text"" onclick=""this\.select\(\);"" value=""([^""]+)""").Groups[1].Value
    $steamID3 = [regex]::Match($html, "Steam ID3\s+<input type=""text"" onclick=""this\.select\(\);"" value=""([^""]+)""").Groups[1].Value
    $steam32ID = [regex]::Match($html, "Steam32 ID\s+<input type=""text"" onclick=""this\.select\(\);"" value=""([^""]+)""").Groups[1].Value
    $steam64ID = [regex]::Match($html, "(steamID64 / URL|Steam64 ID)\s+<input type=""text"" onclick=""this\.select\(\);"" value=""([^""]+)""").Groups[2].Value
    $nickName = [regex]::Match($html, "Nick Name\s+<input type=""text"" onclick=""this\.select\(\);"" value=""([^""]+)""").Groups[1].Value
    $profileURL = [regex]::Match($html, "Profile URL\s+<input type=""text"" onclick=""this\.select\(\);"" value=""([^""]+)""").Groups[1].Value
    
    #Output the variables
    Write-Host "Steam ID: $steamID"
    Write-Host "Steam ID3: $steamID3"
    Write-Host "Steam32 ID: $steam32ID"
    Write-Host "Steam64 ID: $steam64ID"
    Write-Host "Nick Name: $nickName"
    Write-Host "Profile URL: $profileURL"
    }

#Define the menu options
$options = @{
    1 = "SteamID from registry"
    2 = "SteamID in all formats from steamID.xyz"
    3 = "Steam64ID from steamcommunity profile"
    4 = "SteamID from api.steampowered.com lookup (Requires API key)"
}

$optionActions = @{
    1 = { 
        Get-SteamIDFromRegistry
        Write-Host "`n"
    }
    2 = { 
        $steamUsername = Read-Host "Enter Steam username"
        Get-SteamIDXYZ -search $($steamUsername)
        Write-Host "`n"
    }
    3 = { 
        $steamUsername = Read-Host "Enter Steam username"
        Get-SteamCommunityID -search $($steamUsername)
        Write-Host "`n"
    }
    4 = { 
        $apiUsername = Read-Host "Enter Steam username"
        $apiKey = Read-Host "Enter Steam API key"
        Write-Host "`n"
        Get-SteamUserID -username $apiUsername -key $apiKey
        Write-Host "`n"
    }
}

#Display the menu and get user input
Write-Host "---------------------------" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "Powershell Steam ID fetcher" -ForegroundColor White -BackgroundColor Black
Write-Host "---------------------------" -ForegroundColor Magenta -BackgroundColor Black
Write-Host "Please choose an option:`n" -ForegroundColor White

$options.GetEnumerator() | Sort-Object Key | ForEach-Object {
    Write-Host "$($_.Key)) $($_.Value)"
}
$userChoice = Read-Host "Enter the option"

#Execute the user's choice
if ($optionActions.ContainsKey($userChoice)) {
    & $optionActions[$userChoice]
} elseif ([int]::TryParse($userChoice, [ref]$menuIndex) -and $optionActions.ContainsKey($menuIndex)) {
    & $optionActions[$menuIndex]
} else {
    $matchingOption = $options.Values | Where-Object { $_ -match $userChoice } | Select-Object -First 1
    if ($matchingOption) {
        $matchingIndex = $options.GetEnumerator() | Where-Object { $_.Value -eq $matchingOption } | Select-Object -ExpandProperty Key
        & $optionActions[$matchingIndex]
    } else {
        Write-Host "-----------------------" -ForegroundColor Red
        Write-Host "Invalid option selected" -ForegroundColor Red
        Write-Host "-----------------------" -ForegroundColor Red
    }
}