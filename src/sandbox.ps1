$sourceFiles = @('Private', 'Public', 'Classes')

$sourceFiles.ForEach({
    New-Item "src/$_" -ItemType Directory -Force })

git init