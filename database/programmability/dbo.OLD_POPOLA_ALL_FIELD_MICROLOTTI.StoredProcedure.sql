USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_POPOLA_ALL_FIELD_MICROLOTTI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD_POPOLA_ALL_FIELD_MICROLOTTI]( @IdDoc int)
as
BEGIN

 

    
    declare @IdMod int
    declare @dzt_name varchar(250)
    declare @DZT_Type varchar(20)
    declare @DZT_DM_ID varchar(250)
    declare @MySQL nvarchar(max)

 

    -- convenzione
    --set @IdDoc = 190764
    if not exists (select id from ctl_doc where id = @IdDoc and TipoDoc = 'convenzione' )
    begin
        return
    end

 

    -- recupera modello
    select @IdMod=value 
        from CTL_DOC_Value with (nolock)
            where IdHeader = @IdDoc
                and dse_id='TESTATA_PRODOTTI'
                and DZT_Name = 'id_modello'

 


    -- cursore sui campi del modello (escludiamo quelli numerici)
    --set @MySQL = 'select '
    set @MySQL = 'update  Document_MicroLotti_Dettagli set ALL_FIELD = '

 

    declare crs cursor static
    for 
        select b.dzt_name,DZT_Type ,rtrim(isnull(DZT_DM_ID  ,''))
            from CTL_DOC_Value  a with (nolock)
                inner join LIB_Dictionary b with (nolock) on b.DZT_Name = a.Value 
                    where IdHeader = @IdMod
                        and DSE_ID = 'MODELLI'
                        and a.dzt_name='DZT_Name'
                        and DZT_Type <> 2

 

    open crs

 

    fetch next from crs into @dzt_name, @DZT_Type, @DZT_DM_ID

 

    while @@fetch_status=0
    begin
        
            --set @MySQL = @MySQL + 'isnull(' + @dzt_name + ','''') as ' + @dzt_name + ','
            --dbo.GetDescsValuesFromDztDom('UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO',isnull(UM_QUANTITA_PRODOTTO_SINGOLO_PEZZO,''),'I')
            if @DZT_Type <> 1 and @DZT_DM_ID <> ''
                -- caso dei domini chiusi, prende la descrizione
                set @MySQL = @MySQL + 'cast(dbo.GetDescsValuesFromDztDom(''' + @dzt_name + ''',' + 'isnull(' + @dzt_name + ',''''),''I'') as nvarchar(max)) + ''#'' + ' 
            else
                set @MySQL = @MySQL + 'cast(isnull(' + @dzt_name + ','''') as nvarchar(max)) + ''#'' + ' 

 

            fetch next from crs into @dzt_name, @DZT_Type, @DZT_DM_ID
        
    end

 

    close crs

 

    deallocate crs

 

    --elimina i caratteri superlfui  in coda
    --set @MySQL = SUBSTRING(@MySQL, 1, len(@MySQL)-1)
    --set @MySQL = @MySQL + ' from Document_MicroLotti_Dettagli where idheader = ' + cast(@IdDoc as varchar(20))
    --set @MySQL = @MySQL + ' AND TipoDoc = ''CONVENZIONE'''
    set @MySQL = SUBSTRING(@MySQL, 1, len(@MySQL)-7)
    set @MySQL = @MySQL + '  where idheader = ' + cast(@IdDoc as varchar(20))
    set @MySQL = @MySQL + ' AND TipoDoc = ''CONVENZIONE'''

 

    --print @MySQL

 

    exec ( @MySQL )

 


    --select * from Document_MicroLotti_Dettagli 
    --    where IdHeader = @IdDoc 
    --        and tipodoc = 'CONVENZIONE'

 

    
END
GO
