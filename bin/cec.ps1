[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Type = '',

    [Parameter(Position = 1)]
    [string] $DataSource = ''
)

$subject = if ($DataSource) {
    $DataSource -replace '^https://salesdatahub\.blob\.core\.windows\.net', ''
} else {
    ''
}

$event = [ordered]@{
    id = '7539199f-12cb-4e4a-a346-a2d2ae4f8b99'
    source = 'sales'
    type = $Type
    data = [ordered]@{
        source = $DataSource
    }
    time = '2025-07-24T18:56:07.7003458+00:00'
    specversion = '1.0'
    dataschema = 'v2'
    datacontenttype = 'application/json'
    subject = $subject
    traceparent = '00-a53f94fdca46c27192233f1479105041-6e549b66c8a7e7c7-00'
    tracestate = ''
}

$event | ConvertTo-Json -Depth 10
