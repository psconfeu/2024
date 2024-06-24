class Car
{
    [string]$color
    [int]$speed

    Car([string]$color, [int]$speed)
    {
        $this.color = $color
        $this.speed = $speed
    }

    # Car ([string]$properties)
    # {
    #     $this.color, $this.speed = $properties -split ','
    # }

    Car ([PScustomObject]$Properties)
    {
        Write-verbose -Message 'Casting PSCustomObject to Car'
        $this._setProperties($Properties)
    }

    Car ([System.Collections.IDictionary]$Properties)
    {
        Write-verbose -Message 'Casting IDictionary to Car'
        $this._setProperties($Properties)
        # $this.color = $Properties.color
        # $this.speed = $Properties.speed
    }

    hidden [void] _setProperties([Object]$Properties)
    {
        # $Properties.psobject.properties.name.Foreach{
        #     $this.$_ = $Properties.$_
        # }
        $this.psobject.properties.Where{$_.IsSettable}.Foreach{
            if ($null -ne $Properties.($_)) 
            {
                $this.psobject.propeties.$_.Name = $Properties.$_.Name
            }
        }
    }

    [void]Drive()
    {
        Write-Host "Driving at $($this.speed) mph"
    }
}