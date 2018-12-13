Function Get-ExtrahopAPIKeys{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop apiKeys.
        .DESCRIPTION
        This function allows you to retrieve either all apiKeys or one by ID.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            allowselfsignedcert = $True
        }
        Get-ExtrahopAPIKeys @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 1
            allowselfsignedcert = $True
        }
        Get-ExtrahopAPIKeys @Splat
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
    $Endpoint = '/apikeys'
    If($id){
        $URI = $Root + $Endpoint + "/" + $id
    }
    Else{
        $URI = $Root + $Endpoint
    }
    Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
}

Function New-ExtrahopAPIKey{
    <#
        .SYNOPSIS
        Function to create Extrahop apiKeys
        .DESCRIPTION
        This function allows you to create new apiKeys but only for the setup user.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            setuppassword = 'am1'
            allowselfsignedcert = $True
        }
        New-ExtrahopAPIKey @Splat
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$setuppassword,

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
    $Endpoint = '/apikeys'
    $URI = $Root + $Endpoint
    #region body
    $body = @"
{
    "password": "$setuppassword"
}
"@
    #endregion
    Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
}