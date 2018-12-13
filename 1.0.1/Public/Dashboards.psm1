Function Get-ExtrahopDashboards{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop device groups.
        .DESCRIPTION
        This function allows you to retrieve device groups from extrahop.
        You can filter these groups using the regex enabled param 'name' and the 
        bool param 'all' to decide if you want internal groups or not. You can also filter by ID
        and get certain properties of that devicegroup.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            allowselfsignedcert = $True
        }
        Get-ExtrahopDashboards @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apikey
            appliance = $appliancename
            id = 15
            allowselfsignedcert = $True
        }
        Get-ExtrahopDashboards @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apikey
            appliance = $appliancename
            id = 15
            sharing = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDashboards @Splat
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [string]$id,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$sharing,

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
    $Endpoint = '/dashboards'
    If($ID){
        If($sharing){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "sharing"
        }
        Else{
            $URI = $Root + $Endpoint + "/" + $id
        }
    }
    Else{
        $URI = $Root + $Endpoint
    }
    Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
}

Function Update-ExtrahopDashboardOwner{
    <#
        .SYNOPSIS
        Function to update the owner of a dashboard.
        .DESCRIPTION
        This function allows you to update the owner of a dashboard
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 13
            owner = 'setup'
            AllowSelfSignedCert = $true
        }
        Update-ExtrahopDashboardOwner @Splat
    #>
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$id,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$owner,

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
[System.Net.servicePointManager]::CertificatePolicy = New-Object TrustAllcertsPolicy
        #endregion
    }
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"

    $Body = @{}
    $body.owner = $owner
    $jsonbody = ConvertTo-Json $Body
    $Endpoint = '/dashboards'
    $URI = $Root + $Endpoint + "/" + $id
    Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -body $jsonbody -ErrorAction Stop
}

Function Remove-ExtrahopDashboard{
    <#
        .SYNOPSIS
        Function to remove Extrahop dashboards.
        .DESCRIPTION
        This function allows you to remove dashboards from extrahop.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = '17'
            allowselfsignedcert = $True
        }
        Remove-ExtrahopDashboards @Splat
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [string]$id,

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
    $Endpoint = '/dashboards'
    $URI = $Root + $Endpoint + "/" + $id
    Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers -ErrorAction Stop
}