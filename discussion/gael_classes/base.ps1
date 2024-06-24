class base {

    base ()
    {
        throw 'Should not be implemented directly'
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

} 