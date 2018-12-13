Function Get-ExtrahopDeviceGroups{
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
            name = 'laptop'
            all = 'name'
            allowselfsignedcert = $True
        }
        Get-ExtrahopDeviceGroups @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apikey
            appliance = $appliancename
            id = 77
            allowselfsignedcert = $True
        }
        Get-ExtrahopDeviceGroups @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apikey
            appliance = $appliancename
            id = 77
            alerts = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDeviceGroups @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apikey
            appliance = $appliancename
            id = 77
            dashboards = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDeviceGroups @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apikey
            appliance = $appliancename
            id = 77
            devices = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDeviceGroups @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apikey
            appliance = $appliancename
            id = 77
            pages = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDeviceGroups @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apikey
            appliance = $appliancename
            id = 77
            triggers = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDeviceGroups @Splat
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'filter')]
        [string]$name,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'filter')]
        [bool]$all,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [string]$id,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$alerts,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$dashboards,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$devices,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$pages,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$triggers,

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
    $FilterParams = @("name","all","search_type","value")
    Foreach($Item in $PSBoundParameters.keys | Where-object {$_ -in $FilterParams}){
        If(!$searchstring){
            $SearchString = "?" + $item + "=" + "$($PSBoundParameters[$Item])"
        }
        Else{
            $searchstring = $Searchstring + "&" + $item + "=" + "$($PSBoundParameters[$Item])"
        }
    }
    $Endpoint = '/devicegroups'
    If($searchString){
        $URI = $Root + $Endpoint + $searchstring
    }
    ElseIf($ID){
        If($alerts){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "alerts"
        }
        ElseIf($dashboards){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "dashboards"
        }
        ElseIf($devices){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "devices"
        }
        ElseIf($pages){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "pages"
        }
        ElseIf($triggers){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "triggers"
        }
        Else{
            $URI = $Root + $Endpoint + "/" + $id
        }
    }
    Write-host $uri -ForegroundColor yellow
    Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
}

Function Update-ExtrahopDeviceGroup{
    <#
        .SYNOPSIS
        Function to update data for an Extrahop devicegroup.
        .DESCRIPTION
        This function allows you to edit the description, field, name, value
        and include_custom_devices properties for a devicegroup.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 77
            field = 'tag'
            include_custome_devices = $true
            name = 'Dell'
            value = 'Dell'
        }
        Update-ExtrahopDeviceGroup @Splat
    #>
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$id,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$description,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [ValidateSet('any','name','ip address','mac address','vendor','type','tag','vlan','activity','node','discover time')]
        [string]$field,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [bool]$include_custom_devices,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$name,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$value,

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
    $bodyParams = @('field','include_custom_devices','description','name','value')
    Foreach($Item in $PSBoundParameters.keys | where-object {$_ -in $bodyParams}){
        $Body.$Item = $PSBoundParameters.Item($Item)
    }
    $jsonbody = ConvertTo-Json $Body
    $Endpoint = '/devicegroups'
    $URI = $Root + $Endpoint + "/" + $id
    Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -body $jsonbody -ErrorAction Stop
}

Function Remove-ExtrahopDeviceGroup{
    <#
        .SYNOPSIS
        Function to remove various objects assigned to Extrahop devices.
        .DESCRIPTION
        This function allows you to remove assignments for a device such as alerts, devicegroups,
        pages, tags and triggers.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 77
            allowselfsignedcert = $True
        }
        Remove-ExtrahopDeviceGroup @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 77
            alerts = $true
            childID = 500
            allowselfsignedcert = $True
        }
        Remove-ExtrahopDeviceGroup @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 77
            devices = $true
            childID = 500
            allowselfsignedcert = $True
        }
        Remove-ExtrahopDeviceGroup @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 77
            pages = $true
            childID = 33
            allowselfsignedcert = $True
        }
        Remove-ExtrahopDeviceGroup @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 77
            triggers = $true
            childID = 25
            allowselfsignedcert = $True
        }
        Remove-ExtrahopDeviceGroup @Splat
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true)]
        [string]$id,

        [Parameter(Mandatory=$false)]
        [switch]$alerts,

        [Parameter(Mandatory=$false)]
        [switch]$devices,

        [Parameter(Mandatory=$false)]
        [switch]$pages,

        [Parameter(Mandatory=$false)]
        [switch]$triggers,

        [Parameter(Mandatory=$false)]
        [int]$childID,

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
    $Endpoint = '/devicegroups'

    If($alerts){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "alerts" + "/" + $childID
    }
    ElseIf($devices){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "devices" + "/" + $childID
    }
    ElseIf($pages){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "pages" + "/" + $childID
    }
    ElseIf($triggers){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "triggers" + "/" + $childID
    }
    Else{
        $URI = $Root + $Endpoint + "/" + $id
    }
    
    Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers -ErrorAction Stop
}

Function New-ExtrahopDeviceGroup{ 
    <#
        .SYNOPSIS
        Function to create Extrahop devices
        .DESCRIPTION
        This function allows you to create devices in extrahop.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            description = 'Test Description'
            dynamic = $false
            field = 'tag'
            include_custom_devices = $false
            value = 'laptops'
            name = 'Laptop group'
            allowselfsignedcert = $True
        }
        New-ExtrahopDeviceGroup @Splat
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$description,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [bool]$dynamic,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [ValidateSet('any','name','ip address','mac address','vendor','type','tag','vlan','activity','node','discover time')]
        [string]$field,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [bool]$include_custom_devices,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$name,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$value,

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
    $Endpoint = '/devicegroups'
    $bodyfields = @('description','dynamic','field','include_custom_devices','name','value')
    $Body = @{}
    Foreach($Item in $PSBoundParameters.keys | Where-object {$_ -in $bodyfields}){
        $body.$item = $($PSBoundParameters[$Item])
    }
    $body = $body | convertto-json
    $URI = $Root + $Endpoint
    
    Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -body $body -ErrorAction Stop
}

Function New-ExtrahopDevicegroupAssignment{
    <#
        .SYNOPSIS
        Function to create new Extrahop devicegroup assignments..
        .DESCRIPTION
        This function allows you to assign various things to device groups in extrahop.
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$id,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$alerts,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$devices,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$pages,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$triggers,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [array]$childIDs,

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
    $FilterParams = @("name","all","search_type","value")
    $Endpoint = '/devicegroups'
    If($alerts){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "alerts"
    }
    ElseIf($devices){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "devices"
    }
    ElseIf($pages){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "pages"
    }
    ElseIf($triggers){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "triggers"
    }
    $jsonArray = $childIDs | Convertto-JSON
    #region Body
    $Body = @"
{
    "assign": $jsonArray
}
"@
    #endregion
    
    Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -body $body -ErrorAction Stop
}