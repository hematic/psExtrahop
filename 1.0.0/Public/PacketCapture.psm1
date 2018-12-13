Function Get-ExtrahopPacketCapture{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop packet captures.
        .DESCRIPTION
        This function allows you to retrieve Extrahop packet captures.
        .EXAMPLE
        Get-ExtrahopPacketCapture -apiKey $Apikey -appliance $appliancename
        .EXAMPLE
        Get-ExtrahopPacketCapture -apiKey $Apikey -appliance $appliancename -id 23 -AllowSelfSignedCert
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$id,

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
    $endpoint = "/packetcaptures"
    If($id){
        $URI = $Root + $Endpoint + "/" + $id
    }
    Else{
        $URI = $Root + $Endpoint
    }
    Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
}

Function Remove-ExtrahopPacketCapture{
    <#
        .SYNOPSIS
        Function to delete Extrahop PacketCapture.
        .DESCRIPTION
        This function allows you to delete Extrahop PacketCaptures.
        .EXAMPLE
        Remove-ExtrahopPacketCapture -apiKey $Apikey -appliance -id 99 $appliancename
        .EXAMPLE
        Remove-ExtrahopPacketCapture -apiKey $Apikey -appliance $appliancename -id 99 -childID 45 -AllowSelfSignedCert
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$id,

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
    $endpoint = "/packetcaptures"
    $URI = $Root + $Endpoint + "/" + $id
    
    Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers -ErrorAction Stop
}