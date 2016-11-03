param (
    [string] $packageDir = 'Packages',
    [string] $directory = './',
    [int] $port = 8080
)

Add-Type -AssemblyName "System.Net.Http"


#function Load-Packages
#{
#    $assemblies = Get-ChildItem $packageDir -Recurse -Filter '*.dll' | Select -Expand FullName
#    foreach ($assembly in $assemblies) { [System.Reflection.Assembly]::LoadFrom($assembly) }
#}

function Write-Http-Response($content, $response)
{
    $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
    $response.ContentLength64 = $buffer.Length
    $response.OutputStream.Write($buffer, 0, $buffer.Length)
}


Load-Packages

#$routes = @{
#    "/" = { return '<html><body>Hello world!</body></html>' }
#}

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

        #$route = $routes.Get_Item($requestUrl.LocalPath)

        #if ($route -eq $null)
        #{
        #    $response.StatusCode = 404
        #}
        #else
        #{
        #    $content = & $route
        #    $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        #    $response.ContentLength64 = $buffer.Length
        #    $response.OutputStream.Write($buffer, 0, $buffer.Length)
        #}
    
        $response.Close()

        $responseStatus = $response.StatusCode
        Write-Host "< $responseStatus"

    }

}