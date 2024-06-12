$Time = Get-Date
$Runtime = (get-date).AddHours(3)

Set-AzContext -Subscription "679f3d56-bed2-429f-9e31-4d7bf67e14c7"

while ($currentTime -ne $Runtime) {
try {

    Get-AzResourceGroup -Name "Alok_Maheshwari_RG" -ErrorAction Stop    
    $currentTime = $currentTime.AddMinutes(4)
    sleep 50    
    
}
catch {
    Write-Output "Activity Started at $($Time) and Exception Occurred at $($currentTime) following was the exception
    
    $_.Exception
    
    "
    break
}

}#end



# $currentNumber = Get-Date
# $future = $currentNumber.AddDays(4)

# while ($currentNumber -ne $future) {

#    $currentNumber= $currentNumber.AddDays(1)
#     Write-Output $currentNumber
# } 
