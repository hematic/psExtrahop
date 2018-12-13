Function Get-ExtrahopActivityGroups{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop activity groups
        .DESCRIPTION
        This function allows you to retrieve extrahop activity group and associated dashboards.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            allowselfsignedcert = $True
        }
        Get-ExtrahopActivityGroups @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apikey
            appliance = $appliancename
            id = 11
            dashboard = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopActivityGroups @Splat
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True)]
        [String]$apiKey,

        [Parameter(Mandatory=$True)]
        [String]$appliance,

        [Parameter(Mandatory=$false)]
        [int]$id,

        [Parameter(Mandatory=$false)]
        [switch]$dashboards,

        [Parameter(Mandatory=$false)]
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
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        [System.Net.servicePointManager]::CertificatePolicy = New-Object TrustAllcertsPolicy [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        #endregion
    }
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $Endpoint = '/activitygroups'
    if($id){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "dashboards"
    }
    else{
        $URI = $Root + $Endpoint
    }
    $uri
    Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
}