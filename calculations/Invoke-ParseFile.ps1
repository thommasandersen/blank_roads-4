Import-Module SqlServer

$table = New-Object System.Data.DataTable 'MeshValues'
$col = New-Object System.Data.DataColumn  ObjectName,([String]); $table.columns.add($col)
$col = New-Object System.Data.DataColumn MeshValue,([String]); $table.columns.add($col)

$path = "C:\projects\roads\import\" 
Get-ChildItem -Path $path -Filter *.obj |
ForEach-Object {
    $filename = $_.Name
    foreach($line in Get-Content $path$_) {
        $row = $table.NewRow()
        $row.ObjectName = $filename
        $row.MeshValue = $line
        $table.Rows.Add($row)
    }
    Write-Output "$filename Done"
}
Write-SqlTableData -InputData $table -ServerInstance 'WIN-L70TDQ3OSLR' -Database 'Assets' -SchemaName 'dbo' -TableName 'MeshValues' -Force