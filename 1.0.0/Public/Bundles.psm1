Function Get-ExtrahopBundles{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop bundles.
        .DESCRIPTION
        This function allows you to retrieve Extrahop bundles.
        .EXAMPLE
        Get-ExtrahopBundles -apiKey $Apikey -appliance $appliancename
        .EXAMPLE
        Get-ExtrahopBundles -apiKey $Apikey -appliance $appliancename -id 23 -AllowSelfSignedCert
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
    $endpoint = "/bundles"
    If($id){
        $URI = $Root + $Endpoint + "/" + $id
    }
    Else{
        $URI = $Root + $Endpoint
    }
    Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
}

Function Remove-ExtrahopBundles{
    <#
        .SYNOPSIS
        Function to Remove Extrahop bundles.
        .DESCRIPTION
        This function allows you to Remove Extrahop bundles.
        .EXAMPLE
        Remove-ExtrahopBundles -apiKey $Apikey -appliance $appliancename
        .EXAMPLE
        Remove-ExtrahopBundles -apiKey $Apikey -appliance $appliancename -id 23 -AllowSelfSignedCert
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
    $endpoint = "/bundles"
    $URI = $Root + $Endpoint + "/" + $id
    Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers -ErrorAction Stop
}

Function Add-ExtrahopBundle{
    <#
        .SYNOPSIS
        Function to upload an Extrahop bundles.
        .DESCRIPTION
        This function allows you to upload a JSON formatted Extrahop bundle.
        .EXAMPLE
        Add-ExtrahopBundle -apiKey $Apikey -appliance $appliancename -bundle $bundle
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$bundle,

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
    $endpoint = "/bundles"
    $URI = $Root + $Endpoint
    Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $bundle -ErrorAction Stop
}

Function Apply-ExtrahopBundle{
    <#
        .SYNOPSIS
        Function to apply an Extrahop bundles.
        .DESCRIPTION
        This function allows you to apply an Extrahop bundle.
        .EXAMPLE
        Apply-ExtrahopBundle -apiKey $Apikey -appliance $appliancename
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$id,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$include_assignments,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [array]$node_ids,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$policy,

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
    $endpoint = "/bundles"
    $URI = $Root + $Endpoint
    $array = $node_ids | convertto-json
    #region body
    $body = @"
{
   "include_assignments": $include_assignments
   "node_ids": $array
   "policy": $policy
}
"@
#endregion
    Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -Body $body -ErrorAction Stop
}