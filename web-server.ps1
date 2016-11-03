param (
    [string] $packageDir = 'Packages',
    [string] $directory = './',
    [int] $port = 8080
)

Add-Type -AssemblyName "System.Net.Http"

function Write-Http-Response($content, $response)
{
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
}

Load-Packages

$url = "http://localhost:$port/"
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "Listening at $url..."

while ($listener.IsListening)
{
    $context = $listener.GetContext()
    $requestUrl = $context.Request.Url
    $response = $context.Response

    Write-Host ''
    Write-Host "> $requestUrl"

    if($requestUrl.LocalPath -eq "/kill")
    {
        $content = "HTTP Listener stopped"
        Write-Http-Response $content $response
        $listener.Stop()
        Write-Host $content
    }
    else
    {
        $localPath = $requestUrl.LocalPath
        if([System.IO.File]::Exists(".$localPath"))
        {
            $content = [System.IO.File]::ReadAllText(".$localPath")
            Write-Http-Response $content $response
        }
        else 
        {
            $response.StatusCode = 404
        }

        $response.Close()
        $responseStatus = $response.StatusCode

    }
}