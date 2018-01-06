param(
    [Parameter(Position=0)]
    [string] $bookName,
    [Parameter(Position=1)]
    [string]
    $authorName
)

function Add-Post($bookName, $authorName)
{
    $date =  Get-Date -uformat "%Y-%m-%d"
    $fileName= "$date-¶Á¡¶$bookName¡·.md"
    
    Write-Host $fileName -f Green
    
    Copy-Item _drafts/template.md _posts/$fileName
    
    Push-Location _posts
    
    $content = (Get-Content $fileName -Encoding UTF8)
    $content = $content.Replace("%bookname%", "$bookname").Replace("%author%", "$authorName") 

    $filePath = $PSScriptRoot + "\_posts\" + $fileName
    [System.IO.File]::WriteAllLines($filePath, $content)
    
    Write-Host "$filePath Added." -f Green
    
    Pop-Location    
}

function Search-Online($bookName)
{
    start "https://book.douban.com/subject_search?search_text=$bookName&cat=1001"
}

function Add-FakeImage($bookName){
    echo "" > .\assets\images\books\$bookName.jpg
}

Add-Post $bookName $authorName
Search-Online $bookName
Add-FakeImage $bookName



