
function Start-AzTokenRefreshJob {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.Guid]$FileGuid

    )

    begin {

        # inform that function has started
        Write-Information -MessageData "`n`"$($MyInvocation.MyCommand.Name)`" function has started..."

    }

    process {

        # create a file at runner volatile path
        Write-Information -MessageData "Creating temporary job control file with `"0`" boolean value..."
        $JobControlFileName = "AzTokenRefreshJob-" + $FileGuid
        try {
            0 | Out-File -FilePath "$ENV:RUNNER_TEMP\$JobControlFileName.txt" -NoNewline -Encoding utf8 -Force -ErrorAction Stop
        }
        catch {
            Write-Information -MessageData "Failed to create temporary job control file with `"0`" boolean value.`n" -InformationAction Continue
            Write-Information -MessageData $($_.Exception | Out-String) -InformationAction Continue; Write-Information -MessageData $($_.InvocationInfo | Out-String) -InformationAction Continue; throw
        }

        # fetch az oidc token refresh sleep time
        $AzTokenRefreshSleep = Get-ValueFromJson -ModuleID "CommonConfiguration" -TaskID "Data" -KeyName "AzTokenRefreshSleep"

        # job status file name
        $JobStatusFileName = "AzTokenRefreshStatus-" + $FileGuid

        # submit az oidc token refresh job in background
        Write-Information -MessageData "Starting az oidc token refresh job in the background..."
        try {
            $SubmitAzTokenRefreshJob = Start-Job -Name "AzTokenRefreshJob" -ScriptBlock {

                # passed arguments as parameters
                param ($AzTokenRefreshSleep, $JobControlFileName, $JobStatusFileName)

                # initialize iteration count variable
                $IterationCount = 1

                # az oidc token refresh logic loop
                while ((Get-Content -Path "$ENV:RUNNER_TEMP\$JobControlFileName.txt") -eq 0) {
                    Write-Information -MessageData "Sleeping for $AzTokenRefreshSleep seconds before running iteration `"$IterationCount`"..."
                    Start-Sleep -Seconds $AzTokenRefreshSleep
                    Write-Information -MessageData "Updating job control file status and invoking api to refresh az oidc token..."
                    try {
                        "NotReady" | Out-File -FilePath "$ENV:RUNNER_TEMP\$JobStatusFileName.txt" -NoNewline -Encoding utf8 -Force -ErrorAction Stop
                        $Null = Invoke-RestMethod -Uri "$($ENV:ACTIONS_ID_TOKEN_REQUEST_URL)&audience=api://AzureADTokenExchange" -Headers @{Authorization = "Bearer $($ENV:ACTIONS_ID_TOKEN_REQUEST_TOKEN)"}
                        Start-Sleep -Seconds 2
                        "Ready" | Out-File -FilePath "$ENV:RUNNER_TEMP\$JobStatusFileName.txt" -NoNewline -Encoding utf8 -Force -ErrorAction Stop
                    }
                    catch {
                        Write-Information -MessageData "Failed to update job control file status and invoke api to refresh az oidc token.`n" -InformationAction Continue
                        Write-Information -MessageData $($_.Exception | Out-String) -InformationAction Continue; Write-Information -MessageData $($_.InvocationInfo | Out-String) -InformationAction Continue; throw
                    }
                    $IterationCount++
                }

                # warn that job has been stopped
                Write-Warning -Message "Received `"1`" boolean value in temporary job control file. Background job for az oidc token refresh has been stopped."

            } -ArgumentList $AzTokenRefreshSleep, $JobControlFileName, $JobStatusFileName -ErrorAction Stop
        }
        catch {
            Write-Information -MessageData "Failed to start az oidc token refresh job in the background.`n" -InformationAction Continue
            Write-Information -MessageData $($_.Exception | Out-String) -InformationAction Continue; Write-Information -MessageData $($_.InvocationInfo | Out-String) -InformationAction Continue; throw
        }

    }

    end {

        # return submitted az oidc token refresh job
        Write-Information -MessageData "Returning submitted background job object..."
        return $SubmitAzTokenRefreshJob

    }

}


function Stop-AzTokenRefreshJob {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.Guid]$FileGuid

    )

    begin {

        # inform that function has started
        Write-Information -MessageData "`n`"$($MyInvocation.MyCommand.Name)`" function has started..."

    }

    process {

        # create a file at runner volatile path
        Write-Information -MessageData "Updating temporary job control file with `"1`" boolean value..."
        $JobControlFileName = "AzTokenRefreshJob-" + $FileGuid
        try {
            1 | Out-File -FilePath "$ENV:RUNNER_TEMP\$JobControlFileName.txt" -NoNewline -Encoding utf8 -Force -ErrorAction Stop
        }
        catch {
            Write-Information -MessageData "Failed to update temporary job control file with `"1`" boolean value.`n" -InformationAction Continue
            Write-Information -MessageData $($_.Exception | Out-String) -InformationAction Continue; Write-Information -MessageData $($_.InvocationInfo | Out-String) -InformationAction Continue; throw
        }

        # wait for az oidc token refresh job to end gracefully
        Write-Information -MessageData "Waiting for az oidc token refresh job to end gracefully..."
        try {
            $Null = Wait-Job -Name "AzTokenRefreshJob" -ErrorAction Stop
        }
        catch {
            Write-Information -MessageData "Failed to wait for az oidc token refresh job to end gracefully.`n" -InformationAction Continue
            Write-Information -MessageData $($_.Exception | Out-String) -InformationAction Continue; Write-Information -MessageData $($_.InvocationInfo | Out-String) -InformationAction Continue; throw
        }

        # get completed az oidc token refresh background job
        Write-Information -MessageData "Getting completed az oidc token refresh job..."
        try {
            $GetAzTokenRefreshJob = Get-Job -Name "AzTokenRefreshJob" -ErrorAction Stop
        }
        catch {
            Write-Information -MessageData "Failed to get completed az oidc token refresh job.`n" -InformationAction Continue
            Write-Information -MessageData $($_.Exception | Out-String) -InformationAction Continue; Write-Information -MessageData $($_.InvocationInfo | Out-String) -InformationAction Continue; throw
        }

    }

    end {

        # return submitted and completed az oidc token refresh jobs
        Write-Information -MessageData "Returning completed background job object..."
        return $GetAzTokenRefreshJob

    }

}


function Wait-AzTokenRefreshStatus {

    param (

        [Parameter(Mandatory = $True)]
        [ValidateNotNullOrEmpty()]
        [System.Guid]$FileGuid

    )

    begin {

        # inform that function has started
        Write-Information -MessageData "`n`"$($MyInvocation.MyCommand.Name)`" function has started..."

    }

    process {

        # job status file name
        $JobStatusFileName = "AzTokenRefreshStatus-" + $FileGuid

        # wait until az oidc token refresh api request is completed
        Write-Information "Waiting for az oidc token refresh api request to complete..."
        try {
            $JobStatus = (Get-Content -Path "$ENV:RUNNER_TEMP\$JobStatusFileName.txt")
        }
        catch {
            Write-Information -MessageData "Az oidc token refresh status file doesn't exist.`n" -InformationAction Continue
            Write-Information -MessageData $($_.Exception | Out-String) -InformationAction Continue; Write-Information -MessageData $($_.InvocationInfo | Out-String) -InformationAction Continue; throw
        }
        while ($JobStatus -ne "Ready") {
            Start-Sleep -Seconds 2
            $JobStatus = (Get-Content -Path "$ENV:RUNNER_TEMP\$JobStatusFileName.txt")
        }

    }

    end {

        # return job status
        return $JobStatus

    }

}





$currentTime = Get-Date
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
