Function Get-ExtrahopDetections{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop detections.
        .DESCRIPTION
        This function allows you to retrieve all detections or one by ID
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = '15'
            allowselfsignedcert = $True
        }
        Get-ExtrahopDetections @Splat
        .EXAMPLE
        $Splat = @{
            apiKey = $apikey
            appliance = $appliancename
            allowselfsignedcert = $True
        }
        Get-ExtrahopDetections @Splat
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
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
        [System.Net.servicePointManager]::CertificatePolicy = New-Object TrustAllcertsPolicy
        #endregion
    }
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $Endpoint = '/detections'
    If($id){
        $URI = $Root + $Endpoint + "/" + $id
    }
    Else{
        $URI = $Root + $Endpoint
    }
    Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
}

Function Update-ExtrahopDetection{
    <#
        .SYNOPSIS
        Function to update data for an Extrahop detection.
        .DESCRIPTION
        This function allows you to edit the description, field, name, value
        and include_custom_devices properties for a devicegroup.
        .EXAMPLE
        $Splat = @{
            apiKey = $apiKey
            appliance = $appliancename
            id = 77
            assignee = 'tag'
            resolution = 'action_taken'
            status = 'new'
            ticket_id = '8675309'
        }
        Update-ExtrahopDetection @Splat
    #>
    Param(
        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [String]$appliance,

        [Parameter(Mandatory=$true,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$id,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$assignee,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [ValidateSet('action_taken','no_action_taken')]
        [string]$resolution,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [ValidateSet('new','in_progress','closed')]
        [string]$status,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [string]$ticket_id,

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

    $Body = @{}
    $bodyParams = @('assignee','resolution','status','ticket_id')
    Foreach($Item in $PSBoundParameters.keys | where-object {$_ -in $bodyParams}){
        $Body.$Item = $PSBoundParameters.Item($Item)
    }
    $jsonbody = ConvertTo-Json $Body
    $Endpoint = '/devicegroups'
    $URI = $Root + $Endpoint + "/" + $id
    Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -body $jsonbody -ErrorAction Stop
}