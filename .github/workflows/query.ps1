$Time = Get-Date
$Runtime = (get-date).AddHours(3)

Set-AzContext -SubscriptionObject "679f3d56-bed2-429f-9e31-4d7bf67e14c7"

while ($Time -eq $Runtime) {
    Get-AzResourceGroup -Name Alok_Maheshwari_RG 
    $Time.AddMinutes(5)
    sleep 5    
}



