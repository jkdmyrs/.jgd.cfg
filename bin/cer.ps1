[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $EventType = '',

    [Parameter(Position = 1)]
    [string] $QueueName = '',

    [Parameter(Position = 2)]
    [string] $FilePath = ''
)

$sourceUris = @()
if ($FilePath -and (Test-Path -LiteralPath $FilePath -PathType Leaf)) {
    $sourceUris = [System.IO.File]::ReadAllText((Resolve-Path -LiteralPath $FilePath)) -split ',' |
        ForEach-Object { $_.Trim() } |
        Where-Object { $_ }
}

$event = [ordered]@{
    EventType = $EventType
    QueueName = $QueueName
    SourceUris = @($sourceUris)
    MessageExtensions = [ordered]@{
        dismessagereplay = 'true'
    }
}

$event | ConvertTo-Json -Depth 10
