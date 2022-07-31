# https://yvez.be/2019/09/01/lets-create-top-for-powershell/#code
function Get-MetricBar {
 
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=0, ValueFromPipelineByPropertyName)]
        [Alias('Key')]
        $Metric,
       
        [Parameter(Mandatory=$True, Position=1, ValueFromPipelineByPropertyName)]
        [Alias('Value')]
        $MetricValue
    )

    Process {
        $BufferSizeWidth = $host.UI.RawUI.BufferSize.Width
        $ColumnSize = 18
        $PadSize = ($ColumnSize - $Metric.Length)
        if ($BufferSizeWidth -lt 100) {
            $InUseSize = ($MetricValue * ($BufferSizeWidth - $ColumnSize) / 100)
            $IdleSize = (($BufferSizeWidth - $ColumnSize) - $InUseSize)
        } else {
            $InUseSize = $MetricValue
            $IdleSize = (100 - $InUseSize)
        }
        # Generate string respresenting metric bar for the metric in the pipeline.
        -join @(
            $Metric.toUpper()
            #':'
            ' ' * $PadSize
            '▓' * $InUseSize
            '░' * $IdleSize
        )
    }
}

Function Get-Graph {
    [cmdletbinding()]
    Param(
            [Parameter(Mandatory=$true)]
            [int[]] $Datapoints
    )

    # Create a 2D Array to save datapoints in a 2D format
    $Array = New-Object 'object[,]' ($Datapoints.Count + 1), 10
    $Counter = 0

    $Datapoints | ForEach-Object {
        $DatapointRounded = [Math]::Floor($_/10)
        
        1..$DatapointRounded | ForEach-Object {
            $Array[$Counter,$_] = 1
        }
        $Counter++
    }
 
    # Draw graph by drawing each row line-by-line, top-to-bottom.
    ForEach ($RowHeight in (10..0)) {
        
        #Assembly of each row.
        $Row = ''

        Foreach ($DatapointLocation in (0..($BufferSizeWidth -1))) {
            if ($null -eq $Array[$DatapointLocation,$RowHeight]) {
                $Row = [string]::Concat($Row, '░')
            }
            else {
                $Row = [string]::Concat($Row, '▓')
            }   
        }
        
        # To color the graph depending upon the datapoint value.
        switch ($RowHeight) {
            {$RowHeight -gt 8} { Write-Host $Row -ForegroundColor DarkRed }
            {$RowHeight -le 8 -and $RowHeight -gt 5} { Write-Host $Row -ForegroundColor DarkGray }
            {$RowHeight -le 5 -and $RowHeight -ge 1} { Write-Host $Row -ForegroundColor DarkCyan }
        }
    }
}

function Show-PerformanceMetrics {
    Clear-Host

    $LoadHistory = @()

    while (1) {
        # Calculate different metrics. Can be updated by editing the value-key pairs in $Currentload.
        $OS = Get-Ciminstance Win32_OperatingSystem
        $GpuUseTotal = (((Get-Counter "\GPU Engine(*engtype_3D)\Utilization Percentage" -ErrorAction Ignore).CounterSamples | where CookedValue).CookedValue | measure -sum).sum
        $CurrentLoad = [ordered]@{
            "CPU Load" = (Get-CimInstance win32_processor).LoadPercentage
            "RAM Usage" = (100 - ($OS.FreePhysicalMemory/$OS.TotalVisibleMemorySize)*100)
            "Pagefile Usage" = (100 - ($OS.FreeVirtualMemory/$OS.TotalVirtualMemorySize)*100)
            "GPU Load" = $GpuUseTotal
        }

        $LoadHistory += $CurrentLoad
 
        # Reset cursor and overwrite prior output
        $host.UI.RawUI.CursorPosition = @{x=0; y=0}

        # Output on screen
        $BufferSizeWidth = $host.UI.RawUI.BufferSize.Width
        $BufferSizeHeight = $host.UI.RawUI.BufferSize.Height

        # Save screen buffer width and clear screen when it changes
        if ($BufferSizeWidth -ne $PreviousBufferSizeWidth) {
            Clear-Host
        }
        $PreviousBufferSizeWidth = $BufferSizeWidth

        Get-Graph -Datapoints ($LoadHistory."CPU Load" | Select-Object -Last $BufferSizeWidth)
        
        Write-host ""
        
        $CurrentLoad.GetEnumerator() | Get-MetricBar -ErrorAction Ignore | Write-Host -ForegroundColor "DarkCyan"
        
        Write-host ""
        
        $ExtraHeight = $BufferSizeHeight - 22
        if ($ExtraHeight -gt 0) {
            Get-Process | Sort-Object WS -Descending | Select-Object -First $ExtraHeight | Format-Table -RepeatHeader
        }
    }
}