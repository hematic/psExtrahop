Function Get-ExtrahopRunningConfig{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop runningconfiguration.
        .DESCRIPTION
        This function allows you to retrieve the entire running configuration or one specific section.
        .EXAMPLE
        Get-ExtrahopRunningConfig -apiKey $apiKey -appliance 'Command Appliance'
        .EXAMPLE
        Get-ExtrahopRunningConfig -apiKey $apiKey -appliance 'Command Appliance' -section 'dns' -AllowSelfSignedCert
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$AllowSelfSignedCert,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$section
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
    $Endpoint = '/runningconfig'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    If($section){
        $URI = $Root + $Endpoint + "?section" + "=" + $section.tolower()
    }
    Else{
        $URI = $Root + $Endpoint
    }
    $vLans = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
    Return $vLans
}

Function Get-ExtrahopSavedConfig{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop SavedConfig
        .DESCRIPTION
        Function to retrieve Extrahop SavedConfig
        .EXAMPLE
        Get-ExtrahopSavedConfig -apiKey $APIKey -appliance "Command Appliance" -AllowSelfSignedCert
        .EXAMPLE
        Get-ExtrahopSavedConfig -apiKey $APIKey -appliance "Command Appliance"
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

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
    $Endpoint = '/runningconfig/saved'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $URI = $Root + $Endpoint
    $Config = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
    Return $Config
}

Function Save-ExtrahopRunningConfig{
    <#
        .SYNOPSIS
        Function to save the Extrahop Runningconfig
        .DESCRIPTION
        Function to save the Extrahop Runningconfig
        .EXAMPLE
        Save-ExtrahopRunningConfig -apiKey $APIKey -appliance "Command Appliance" -AllowSelfSignedCert
        .EXAMPLE
        Save-ExtrahopRunningConfig -apiKey $APIKey -appliance "Command Appliance"
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

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
    $Endpoint = '/runningconfig/save'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $URI = $Root + $Endpoint
    Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ErrorAction Stop
}

Function Update-ExtrahopRunningConfig{
    <#
        .SYNOPSIS
        Function to update the extrahop config
        .DESCRIPTION
        This function allows you to pass a json formatted string for the config.
        .EXAMPLE
        Update-ExtrahopRunningConfig -apiKey $APIKey -appliance "Command Appliance" -config $config -AllowSelfSignedCert
        .EXAMPLE
        Update-ExtrahopRunningConfig -apiKey $APIKey -appliance "Command Appliance" -config $config
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$config,

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
    $Endpoint = '/runningconfig'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $URI = $Root + $Endpoint
    Invoke-RestMethod -Method Put -Uri $uri -Headers $headers -body $config -ErrorAction Stop
}