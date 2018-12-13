Function Get-ExtrahopTriggers{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop triggers
        .DESCRIPTION
        This function allows you to retrieve triggers and the devicegroups and devices they are applied to.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            allowselfsignedcert = $True
        }
        Get-ExtrahopTriggers @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 27
            allowselfsignedcert = $True
        }
        Get-ExtrahopTriggers @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 27
            devices = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopTriggers @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 27
            devicegroups = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopTriggers @Splat
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$id,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$devicegroups,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$devices,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$AllowSelfSignedCert
    )

    #Set Protocol type to work with Self Signed SSL Cert
    If($AllowSelfSignedCert){
        #region Cert
        add-type @"
using System.Net;
        using System.Security.Cryptography.X509Certificates;
        public class TrustAllCertsPolicy : ICertificatePolicy {
            public bool CheckValidationResult(
                ServicePoint srvPoint, X509Certificate certificate,
                WebRequest request, int certificateProblem) {
                return true;
            }
        }
"@
        [System.Net.servicePointManager]::CertificatePolicy = New-Object TrustAllcertsPolicy
        #endregion
    }
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $Endpoint = '/triggers'
    if($id){
        If($devicegroups){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "devicegroups"
        }
        ElseIf($devices){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "devices"
        }
        Else{
            $URI = $Root + $Endpoint + "/" + $id
        }
    }
    else{
        $URI = $Root + $Endpoint
    }
    Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
}
