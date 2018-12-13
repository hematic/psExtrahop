Function Get-ExtrahopCustomDevices{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop custom devices.
        .DESCRIPTION
        This function allows you to retrieve Extrahop custom devices a few different ways.
        .EXAMPLE
        Get-ExtrahopCustomDevices -apiKey $Apikey -appliance $appliancename
        .EXAMPLE
        Get-ExtrahopCustomDevices -apiKey $Apikey -appliance $appliancename -id 23 -AllowSelfSignedCert
        .EXAMPLE
        Get-ExtrahopCustomDevices -apiKey $Apikey -appliance $appliancename -id 23 -criteria -AllowSelfSignedCert
        .EXAMPLE
        Get-ExtrahopCustomDevices -apiKey $Apikey -appliance $appliancename -id 23 -criteria -childID 157 -AllowSelfSignedCert
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low',DefaultParameterSetName='default')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$True,ParameterSetName = 'By ID')]
        [Parameter(Mandatory=$True,ParameterSetName = 'By Criteria')]
        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$id,

        [Parameter(Mandatory=$True,ParameterSetName = 'By Criteria')]
        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$criteria,

        [Parameter(Mandatory=$false,ParameterSetName = 'By ID')]
        [Parameter(Mandatory=$false,ParameterSetName = 'By Criteria')]
        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$childID,

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
    $endpoint = "/customdevices"
    switch ($PsCmdlet.ParameterSetName){
        "By Criteria" {
            If($childID){
                $URI = $Root + $Endpoint + "/" + $id + "/" + "criteria" + "/" + $childID
            }
            Else{
                $URI = $Root + $Endpoint + "/" + $id + "/" + "criteria"
            } 
        }

        "By ID" {
            $URI = $Root + $Endpoint + "/" + $id
        }

        default {
            $URI = $Root + $Endpoint
        }
    }
    Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
}

Function Remove-ExtrahopCustomDevice{
    <#
        .SYNOPSIS
        Function to delete Extrahop custom devices.
        .DESCRIPTION
        This function allows you to delete Extrahop custom devices.
        .EXAMPLE
        Remove-ExtrahopCustomDevice -apiKey $Apikey -appliance -id 99 $appliancename
        .EXAMPLE
        Remove-ExtrahopCustomDevice -apiKey $Apikey -appliance $appliancename -id 99 -childID 45 -AllowSelfSignedCert
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
        [String]$childID,

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
    $endpoint = "/customdevices"

    If($childID){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "criteria" + "/" + $childID
    }
    Else{
        $URI = $Root + $Endpoint + "/" + $id
    } 
    
    Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers -ErrorAction Stop
}

Function Update-ExtrahopCustomDevice{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop custom devices.
        .DESCRIPTION
        This function allows you to retrieve Extrahop custom devices a few different ways.
        .EXAMPLE
        $splat = @{
            apiKey = $Apikey
            appliance = $appliancename
            id = 23
            author = 'Phillip Marshall'
            description = "best custom device ever"
            disabled = $false
            name = "Plex Servers"
            AllowSelfSignedCert = $true
        }
        Update-ExtrahopCustomDevice @Splat

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
        [switch]$author,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$description,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [bool]$disabled,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$name,

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
    $endpoint = "/customdevices"

    $Body = @{}
    $bodyParams = @('author','description','disabled','name')
    Foreach($Item in $PSBoundParameters.keys | where-object {$_ -in $bodyParams}){
        $Body.$Item = $PSBoundParameters.Item($Item)
    }
    $jsonbody = ConvertTo-Json $Body
    $Endpoint = '/customdevices'
    $URI = $Root + $Endpoint
    Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -body $jsonbody -ErrorAction Stop
}

Function New-ExtrahopCustomDevice{
    <#
        .SYNOPSIS
        Function to create a new Extrahop CustomDevice
        .DESCRIPTION
        This function allows you to create a new CustomDevice.
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$author,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$description,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [bool]$disabled,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$extrahop_id,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$name,

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
    $Endpoint = '/customdevices'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $URI = $Root + $Endpoint
    $bodyparams = @('author','description','disabled','extrahop_id','name')
    $body = @{}

    Foreach($Item in $PSBoundParameters.keys | Where-object {$_ -in $bodyparams}){
        $body.item = $($PSBoundParameters[$Item])
    }

    $jsonbody = $body | convertto-json
    Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -body $jsonbody -ErrorAction Stop
}

Function New-ExtrahopCustomDeviceCriterion{
    <#
        .SYNOPSIS
        Function to create a new Extrahop CustomDevice criterion
        .DESCRIPTION
        This function allows you to create a new CustomDevice criterion.
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$custom_device_id,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$dst_port_max,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$dst_port_min,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$ipaddr,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$src_port_max,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$src_port_min,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$vlan_max,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$vlan_min,

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
    $Endpoint = '/customdevices'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $URI = $Root + $Endpoint
    $bodyparams = @('custom_device_id','dst_port_max','dst_port_min','ipaddr','src_port_max','src_port_min','vlan_max','vlan_min')
    $body = @{}

    Foreach($Item in $PSBoundParameters.keys | Where-object {$_ -in $bodyparams}){
        $body.item = $($PSBoundParameters[$Item])
    }

    $jsonbody = $body | convertto-json
    Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -body $jsonbody -ErrorAction Stop
}