#Requires -PSEdition Desktop
<#
    .SYNOPSIS
        Tests connectivity for the Citrix Cloud Connector.

    .DESCRIPTION
        Reads ports and URLs required for outbound connectivity for the Citrix Cloud Connector. Tests each URL and returns a result for pass or fail.

    .NOTES
        Name: Test-CitrixCloudConnector.ps1
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        http://stealthpuppy.com

    .EXAMPLE
        .\Test-CitrixCloudUrls.ps1

        Description:
        Reads the URLs listed in Citrix Cloud Internet Connectivity Requirements article, tests them and returns the result.
#>
[CmdletBinding(SupportsShouldProcess = $False, DefaultParameterSetName = 'Base')]
param (
    [Parameter(Mandatory = $False, Position = 0, HelpMessage = "URI to the Citrix Cloud connectivity article.")]
    [string] $Uri = "https://docs.citrix.com/en-us/citrix-cloud/overview/requirements/internet-connectivity-requirements.html",

    [Parameter(Mandatory = $False, Position = 1, HelpMessage = "Port to test.")]
    [string] $Port = "443"
)

# Read the Citrix article documenting the Citrix Cloud URLs
Try {
    Write-Verbose -Message "Reading Citrix Cloud Internet Connectivity Requirements article."
    $content = Invoke-WebRequest -UseBasicParsing -Uri $uri
}
Catch {
    Throw "Failed to read Citrix URLs source document."
}

If ($Null -ne $content) {
    Write-Verbose -Message "Successfully read Citrix Cloud Internet Connectivity Requirements article."

    # Find <code> elements in the HTML that are the URLs
    Write-Verbose -Message "Filtering article for URLs."
    $code = $content.Content -Replace "`r|`n" -Replace ">\s*<", "><" -Replace "<code", "`n<code" -Replace "/code>", "/code>`n" -Split "`n" | `
        Where-Object { $_ -match "</code>$" }

    # URLs are repeated, so sort for unique
    Write-Verbose -Message "Sorting for unique URLs."
    $code = $code | Select-Object -Unique

    # Grab the URLs inside <code></code>
    Write-Verbose -Message "Extracting URL strings."
    $regEx = "^<code.*>(.*?)<\/\w+>"
    $urls = $code | ForEach-Object { If ($_ -match $regEx) { $matches[1] } }
    
    # Strip out
    Write-Verbose -Message "Stripping URIs."
    $regEx = "https:\/\/|\*\."
    $urls = $urls -replace $regEx

    # Output object
    $output = @()
    
    # Test each URL and output the result
    ForEach ($url in $urls) {
        Write-Verbose -Message "Testing connection to: $url."
        $item = New-Object PSCustomObject
        
        $result = Test-NetConnection -ComputerName $url -Port $Port -InformationLevel Quiet
        If ($result) {
            $item | Add-Member -type NoteProperty -Name 'Result' -Value "Success"
        }
        Else {
            $item | Add-Member -type NoteProperty -Name 'Result' -Value "Fail"
        }
        $item | Add-Member -type NoteProperty -Name 'Host' -Value $url
        $item | Add-Member -type NoteProperty -Name 'Port' -Value $Port
        $output += $item
    }

    # Return output to the pipeline
    Write-Output $output
}
