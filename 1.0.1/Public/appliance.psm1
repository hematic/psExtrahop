Function Get-ExtrahopAppliance{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop appliances.
        .DESCRIPTION
        This function allows you to retrieve extrahop appliance information including data on
        cloudservices and the product key from the command appliance.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 15
            allowselfsignedcert = $True
        }
        Get-ExtrahopAppliance @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 15
            cloudservices = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopAppliance @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 15
            productkey = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopAppliance @Splat
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
        [switch]$cloudservices,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$productkey,

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
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        [System.Net.servicePointManager]::CertificatePolicy = New-Object TrustAllcertsPolicy
        #endregion
    }
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $Endpoint = '/appliances'
    If($id){
        If($cloudservices){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "cloudservices"
        }
        ElseIf($productkey){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "productkey"
        }
        Else{
            $URI = $Root + $Endpoint + "/" + $id
        }
    }
    Else{
        $URI = $Root + $Endpoint
    }
    $uri
    Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
}
