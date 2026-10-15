[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $BlobUrl = ''
)

$event = [ordered]@{
    topic = '/subscriptions/{subscription-id}/resourceGroups/Storage/providers/Microsoft.Storage/storageAccounts/my-storage-account'
    subject = '/blobServices/default/containers/test-container/blobs/new-file.txt'
    eventType = 'Microsoft.Storage.BlobCreated'
    eventTime = (Get-Date).ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ss.fffZ')
    id = [guid]::NewGuid().Guid
    data = [ordered]@{
        api = 'PutBlockList'
        clientRequestId = ''
        requestId = [guid]::NewGuid().Guid
        eTag = '"0x8D4BCC2E4835CD0"'
        contentType = 'text/plain'
        contentLength = 524288
        blobType = 'BlockBlob'
        url = $BlobUrl
        sequencer = '00000000000004420000000000028963'
        storageDiagnostics = [ordered]@{
            batchId = [guid]::NewGuid().Guid
        }
    }
    dataVersion = ''
    metadataVersion = '1'
}

$event | ConvertTo-Json -Depth 10
