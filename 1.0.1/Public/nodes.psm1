Function Get-ExtrahopNodes{
    <#
        .SYNOPSIS
        Function to retrieve Extrahop Nodes
        .DESCRIPTION
        This function allows you to retrieve all nodes or a specific node.
        .EXAMPLE
        Get-ExtrahopNodes -apiKey $apikey -appliance 'Command Appliance'
        .EXAMPLE
        Get-ExtrahopNodes -apiKey $apiKey -appliance 'Command Appliance' -node 11
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low',DefaultParameterSetName='All')]
    Param(
        [Parameter(Mandatory=$True,ParameterSetName = 'All')]
        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ParameterSetName = 'All')]
        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$AllowSelfSignedCert,

        [Parameter(Mandatory=$True,ParameterSetName = 'ByID')]
        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [int]$node
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
    $Endpoint = '/nodes'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    #region Build URI
    switch ($PsCmdlet.ParameterSetName)
    {
        'All' {
            $URI = $Root + $Endpoint
        }

        'ByID' {
            $URI = $Root + $Endpoint + '/' + $ID
        }
    }

    #endregion
    $results = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers -ErrorAction Stop
    Return $results
}
Function Update-ExtrahopNode{
    <#
        .SYNOPSIS
        Function to update an Extrahop node.
        .DESCRIPTION
        This function allows you to update the friendly name or enabled status of
        a specific node.
        .EXAMPLE
        Update-ExtrahopNode -apiKey $apiKey -appliance 'Command Appliance' -friendlyname "vLan 35 (Voice)"
    #>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low',DefaultParameterSetName='Description')]
    Param(
        [Parameter(Mandatory=$True,ParameterSetName = 'Description')]
        [Parameter(Mandatory=$True,ParameterSetName = 'FriendlyName')]
        [String]$apiKey,

        [Parameter(Mandatory=$True,ParameterSetName = 'Description')]
        [Parameter(Mandatory=$True,ParameterSetName = 'FriendlyName')]
        [String]$appliance,

        [Parameter(Mandatory=$false,ValueFromPipeline=$False,ValueFromPipelineByPropertyName = $False)]
        [switch]$AllowSelfSignedCert,

        [Parameter(Mandatory=$True,ParameterSetName = 'Description')]
        [Parameter(Mandatory=$True,ParameterSetName = 'FriendlyName')]
        [string]$id,

        [Parameter(Mandatory=$True,ParameterSetName = 'Description')]
        [Parameter(Mandatory=$false,ParameterSetName = 'FriendlyName')]
        [string]$description,

        [Parameter(Mandatory=$false,ParameterSetName = 'Description')]
        [Parameter(Mandatory=$true,ParameterSetName = 'FriendlyName')]
        [string]$name
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
    $Endpoint = '/vlans'
    $headers = Get-ExtrahopHeaders -apiKey $apiKey
    $Root = "https://" + $appliance + "/api/v1"
    $URI = $Root + $Endpoint + "/" + $id
    switch ($PsCmdlet.ParameterSetName){
        'Description' {
            If($friendlyname){
                #region Body
                $Body = @"
{
    "description" : $description,
    "name" : $name
}
"@
                #endregion
            }
            Else{
                #region Body
                $Body = @"
{
    "description" : $description
}
"@
                #endregion
            }
        }

        'FriendlyName' {
            If($description){
                #region Body
                $Body = @"
{
    "description" : $description,
    "name" : $name
}
"@
                #endregion
            }
            Else{
                #region Body
                $Body = @"
{
    "name" : $name
}
"@
                #endregion
            }
        }
    }
    Write-Host "Retrieving vLan {$id} from $appliance @ $Uri"
    Invoke-RestMethod -Method Patch -Uri $uri -Headers $headers -Body $body -ErrorAction Stop
}