 

# $AzOidcTokenFileGuid = (New-Guid).Guid
# Start-AzTokenRefreshJob -FileGuid $AzOidcTokenFileGuid -ErrorAction Stop


$currentTime = Get-Date
$Runtime = (get-date).AddHours(3)
$attempt = 0
Set-AzContext -Subscription "679f3d56-bed2-429f-9e31-4d7bf67e14c7"


try {
    while ($currentTime -ne $Runtime) {

        Get-AzResourceGroup -Name "Alok_Maheshwari_RG" -ErrorAction Stop | Out-Null   
        Write-Output "Attempt Number: $attempt"
        $currentTime = $currentTime.AddMinutes(4)
        sleep 120    
        $attempt++

    # Wait-AzTokenRefreshStatus -FileGuid $AzOidcTokenFileGuid -ErrorAction Stop

    }
}
catch {
    Write-Output "Attempt: $attempt, Activity Started at $($Time) and Exception Occurred at $($currentTime) following was the exception
    
    $_.Exception
    
    "
    
    # Stop-AzTokenRefreshJob -FileGuid $AzOidcTokenFileGuid -ErrorAction Stop

    break
}



