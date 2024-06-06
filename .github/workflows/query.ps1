$Time = Get-Date
$Runtime = (get-date).AddHours(3)

while ($Time -eq $Runtime) {
    Get-AzResourceGroup -Name Alok_Maheshwari_RG 
    $Time.AddMinutes(5)
    sleep 5    
}



