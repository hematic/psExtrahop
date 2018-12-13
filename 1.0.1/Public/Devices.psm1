Function Get-ExtrahopDevices{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop devices
        .DESCRIPTION
        This function allows you to retrieve devices from extrahop using various filters.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            limit = 15
            offset = 2
            search_type = 'name'
            value = 'am1'
            allowselfsignedcert = $True
        }
        Get-ExtrahopDevices @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = 'W4Gq69bVVWm3bpxYrjmfQVnwI-xKO_XplrlbvlbC-Wg'
            appliance = $appliancename
            id = 9851
            allowselfsignedcert = $True
        }
        Get-ExtrahopDevices @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = 'W4Gq69bVVWm3bpxYrjmfQVnwI-xKO_XplrlbvlbC-Wg'
            appliance = $appliancename
            id = 9851
            activity = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDevices @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = 'W4Gq69bVVWm3bpxYrjmfQVnwI-xKO_XplrlbvlbC-Wg'
            appliance = $appliancename
            id = 9851
            alerts = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDevices @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = 'W4Gq69bVVWm3bpxYrjmfQVnwI-xKO_XplrlbvlbC-Wg'
            appliance = $appliancename
            id = 9851
            dashboards = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDevices @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = 'W4Gq69bVVWm3bpxYrjmfQVnwI-xKO_XplrlbvlbC-Wg'
            appliance = $appliancename
            id = 9851
            devicegroups = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDevices @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = 'W4Gq69bVVWm3bpxYrjmfQVnwI-xKO_XplrlbvlbC-Wg'
            appliance = $appliancename
            id = 9851
            pages = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDevices @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = 'W4Gq69bVVWm3bpxYrjmfQVnwI-xKO_XplrlbvlbC-Wg'
            appliance = $appliancename
            id = 9851
            tags = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDevices @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = 'W4Gq69bVVWm3bpxYrjmfQVnwI-xKO_XplrlbvlbC-Wg'
            appliance = $appliancename
            id = 9851
            triggers = $true
            allowselfsignedcert = $True
        }
        Get-ExtrahopDevices @Splat
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'filter')]
        [int]$limit,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'filter')]
        [int]$offset,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'filter')]
        [Validateset("name","discovery_id","ip address","mac address","vendor","type","tag","activity","node","vlan","discover time")]
        [string]$search_type,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'filter')]
        [string]$value,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [string]$id,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$activity,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$alerts,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$dashboards,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$devicegroups,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$pages,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [switch]$tags,

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
    $FilterParams = @("limit","offset","search_type","value")
    Foreach($Item in $PSBoundParameters.keys | Where-object {$_ -in $FilterParams}){
        If(!$searchstring){
            $SearchString = "?" + $item + "=" + "$($PSBoundParameters[$Item])"
        }
        Else{
            $searchstring = $Searchstring + "&" + $item + "=" + "$($PSBoundParameters[$Item])"
        }
    }
    $Endpoint = '/devices'
    If($searchString){
        $URI = $Root + $Endpoint + $searchstring
    }
    ElseIf($ID){
        If($Activity){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "activity"
        }
        ElseIf($alerts){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "alerts"
        }
        ElseIf($dashboards){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "dashboards"
        }
        ElseIf($devicegroups){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "devicegroups"
        }
        ElseIf($pages){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "pages"
        }
        ElseIf($tags){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "tags"
        }
        ElseIf($triggers){
            $URI = $Root + $Endpoint + "/" + $id + "/" + "triggers"
        }
        Else{
            $URI = $Root + $Endpoint + "/" + $id
        }
    }
    
    $devices = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
    Return $devices
}

Function Update-ExtrahopDevice{
    <#
        .SYNOPSIS
        Function to update data for an Extrahop device.
        .DESCRIPTION
        This function allows you to edit the name, type, description or vendor for a device.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            custom_name = 'Bob's Server
            custom_type = 'Type 2'
            description = 'Bob's bad server
            vendor = 'Dell'
            allowselfsignedcert = $True
        }
        Update-ExtrahopDevice @Splat
    #>
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [string]$id,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [string]$custom_name,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [string]$custom_type,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [string]$description,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False,ParameterSetName = 'id')]
        [string]$vendor
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
    $bodyParams = @('custom_name','custom_type','description','vendor')
    Foreach($Item in $PSBoundParameters.keys | where-object {$_ -in $bodyParams}){
        $Body.$Item = $PSBoundParameters.Item($Item)
    }
    $jsonbody = ConvertTo-Json $Body
    $Endpoint = '/devices'
    $URI = $Root + $Endpoint
    Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -body $jsonbody -ErrorAction Stop
}

Function Remove-ExtrahopDeviceAssignment{
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
            id = 4538
            alerts = $true
            childID = 3615
            allowselfsignedcert = $True
        }
        Remove-ExtrahopDeviceAssignment @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 4538
            devicegroups = $true
            childID = 3615
            allowselfsignedcert = $True
        }
        Remove-ExtrahopDeviceAssignment @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 4538
            pages = $true
            childID = 3615
            allowselfsignedcert = $True
        }
        Remove-ExtrahopDeviceAssignment @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 4538
            tags = $true
            childID = 3615
            allowselfsignedcert = $True
        }
        Remove-ExtrahopDeviceAssignment @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 4538
            triggers = $true
            childID = 3615
            allowselfsignedcert = $True
        }
        Remove-ExtrahopDeviceAssignment @Splat
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
        [switch]$devicegroups,

        [Parameter(Mandatory=$false)]
        [switch]$pages,

        [Parameter(Mandatory=$false)]
        [switch]$tags,

        [Parameter(Mandatory=$false)]
        [switch]$triggers,

        [Parameter(Mandatory=$true)]
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
    $Endpoint = '/devices'

    If($alerts){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "alerts" + "/" + $childID
    }
    ElseIf($devicegroups){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "devicegroups" + "/" + $childID
    }
    ElseIf($pages){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "pages" + "/" + $childID
    }
    ElseIf($tags){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "tags" + "/" + $childID
    }
    ElseIf($triggers){
        $URI = $Root + $Endpoint + "/" + $id + "/" + "triggers" + "/" + $childID
    }
    
    Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers -ErrorAction Stop
}

