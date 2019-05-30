#Requires -PSEdition Desktop
<#
    .SYNOPSIS
        Tests connectivity for the Citrix Cloud Connector.

    .DESCRIPTION
        Reads ports and URLs required for outbound connectivity for the Citrix Cloud Connector. Tests each URL and returns a result for pass or fail.

    .NOTES
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        http://stealthpuppy.com

    .EXAMPLE
        .\Test-CitrixCloudUrls.ps1

        Description:
        Reads the URLs listed in Citrix Cloud Internet Connectivity Requirements article, tests them and returns the result.
#>
[CmdletBinding(SupportsShouldProcess = $False)]
param (
    [Parameter(Mandatory = $False, Position = 1, HelpMessage = "Port to test.")]
    [string] $Port = "443"
)

#region Functions
Function Get-CitrixCloudArticleUrls {
    param(
        [Parameter(Mandatory = $False, Position = 0)]
        [string] $Uri = "https://docs.citrix.com/en-us/citrix-cloud/overview/requirements/internet-connectivity-requirements.html"
    )

    Try {
        # Read the Citrix article documenting the Citrix Cloud URLs
        Write-Verbose -Message "Reading Citrix Cloud Internet Connectivity Requirements article."
        $content = Invoke-WebRequest -UseBasicParsing -Uri $Uri
    }
    Catch {
        Throw "Failed to read Citrix URLs source document."
    }

    If ($Null -ne $content) {
        Write-Verbose -Message "Successfully read: $(Split-Path -Path $Uri -Leaf)."

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

        # Return the URLs
        Write-Output $urls
    }
}

Function Get-UrlsFromCsv {
    param(
        [Parameter(Mandatory = $False, Position = 0)]
        [string] $Uri = "https://raw.githubusercontent.com/aaronparker/CitrixCloud/master/tools/CitrixCloudHosts.csv"
    )

    Try {
        # Read the Citrix article documenting the Citrix Cloud URLs
        Write-Verbose -Message "Reading content from: $(Split-Path -Path $Uri -Leaf)."
        $content = Invoke-WebRequest -UseBasicParsing -Uri $Uri
    }
    Catch {
        Throw "Failed to read source document."
    }

    If ($Null -ne $content) {
        Write-Verbose -Message "Successfully read: $(Split-Path -Path $Uri -Leaf)."
        $output = $content.Content | ConvertFrom-Csv
        Write-Output $output
    }
}
Function Test-Hosts {
    param(
        [Parameter(Mandatory = $True, Position = 0)]
        [string[]] $Urls,

        [Parameter(Mandatory = $False, Position = 1)]
        [string] $Port = 443
    )

    # Output object
    $output = @()
    
    # Test each URL and output the result
    ForEach ($url in $Urls) {
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
#endregion

# Grab the URLs and test them. Return the result
$urls = Get-CitrixCloudArticleUrls 
If ($Null -ne $urls) {
    $result = Test-Hosts -Urls $urls -Port $Port
    Write-Output $result
}

$urls = Get-UrlsFromCsv 
If ($Null -ne $urls) {
    ForEach ($url in $urls) {
        $result = Test-Hosts -Urls $url.Host -Port $url.Port
        Write-Output $result
    }
}
