USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GET_COLUMN_LOTTI_TO_EXTRACT_CSV]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[GET_COLUMN_LOTTI_TO_EXTRACT_CSV] ( @Modelli as varchar(500) , @HideCol as varchar(500), @cnv as int = 0 , @ShowAttach as varchar(10)='SI', @Table as nvarchar(max)='') as
begin
	SET NOCOUNT ON

    declare @idx int       
    declare @slice varchar(8000)       
	
    DECLARE @HideColumn varchar(8000)       
    
    declare @IsCtl as int

    set @IsCtl = 0

	--SET @HideColumn = ',' +  @HideCol + ',EsitoRiga,NotEditable,TipoDoc,FNZ_DEL,' 
	SET @HideColumn = ',' +  @HideCol + ',NotEditable,TipoDoc,FNZ_DEL,'

	--conservo le colonne ritorante dalla tabella/vista in una tabella temporanea
	select column_name into #Column_Of_Table from information_schema.columns where table_name = @Table
	
		
	-- preparo una tabella temporanea dove inserire le colonne
    SELECT  top 0 MA_DZT_Name as DZT_Name , 0 as DZT_Type , MA_DescML as Caption , 0 as MA_Order, MA_DescML as DZT_Format
		into #Temp
		from LIB_ModelAttributes with (nolock)
		where MA_MOD_ID = 'XXX'

      
    select @idx = 1       
      
    while @idx!= 0       
    begin       
        set @idx = charindex(',',@Modelli)
        if @idx!=0
            set @slice = left(@Modelli,@idx - 1)
        else
            set @slice = @Modelli

        if(len(@slice)>0)
		begin  
			--CONTROLLO SE IL MODELLO E' PRESENTE NELLE CTL_MODELS
			IF EXISTS (SELECT * from CTL_Models with(nolock) where MOD_ID=@slice)
			BEGIN
				
				set @IsCtl = 1

				if @Table = ''
				begin
					insert into #Column_Of_Table
						select MA_DZT_Name from CTL_ModelAttributes with (nolock) where MA_MOD_ID = @slice 
				end


				insert into #Temp ( DZT_Name , DZT_Type , Caption , MA_Order, DZT_Format)
					SELECT  
						DZT_Name , L.DZT_Type , dbo.StripHTML( isnull( CM.ML_Description, MA_DescML) ) as Caption , MA_Order, isnull(A.DZT_Format, l.DZT_Format) as dzt_format
						from CTL_ModelAttributes A with (nolock)
							--inner join LIB_Dictionary L on L.DZT_Name = MA_DZT_Name and L.DZT_Type not in ( 18 , 11 )
							inner join LIB_Dictionary L with (nolock) on L.DZT_Name = MA_DZT_Name and L.DZT_Type not in ( 11 ) and ( ( @ShowAttach='SI') or ( L.dzt_type <> 18 and @ShowAttach='NO' ) )

							LEFT JOIN CTL_ModelAttributeProperties D with (nolock) ON D.MAP_MA_MOD_ID = A.MA_MOD_ID and D.MAP_MA_DZT_Name = A.MA_DZT_Name and D.MAP_Propety = 'Hide'
							left join CTL_Multilinguismo CM with (nolock) on CM.ml_key=MA_DescML and ML_LNG='I'
							inner join #Column_Of_Table on column_name= DZT_Name

						where MA_MOD_ID = @slice 
							and charindex(  ',' + DZT_Name + ',' , @HideColumn ) = 0
							and DZT_Name not in ( select DZT_Name from #Temp )
							and isnull(d.map_value,'0') = '0'
						order by MA_Order

			END
			ELSE
			BEGIN
				
				if @Table = ''
				begin
					insert into #Column_Of_Table
						select MA_DZT_Name from LIB_ModelAttributes with (nolock) where MA_MOD_ID = @slice 
				end


				insert into #Temp ( DZT_Name , DZT_Type , Caption , MA_Order, DZT_Format)
					SELECT  
						DZT_Name , DZT_Type , dbo.StripHTML( MA_DescML ) as Caption , MA_Order , isnull(props.MAP_Value , L.DZT_Format) as dzt_format
							from LIB_ModelAttributes A with (nolock)
								--inner join LIB_Dictionary L on DZT_Name = MA_DZT_Name and DZT_Type not in ( 18 , 11 )
								inner join LIB_Dictionary L with (nolock)on DZT_Name = MA_DZT_Name and DZT_Type not in ( 11 )   and ( ( @ShowAttach='SI') or ( DZT_Type <> 18 and @ShowAttach='NO' ) )
								LEFT JOIN LIB_ModelAttributeProperties props with (nolock) ON a.MA_MOD_ID = props.MAP_MA_MOD_ID and MAP_MA_DZT_Name = a.MA_DZT_Name and props.MAP_Propety = 'Format' and isnull(props.MAP_Value,'') <> ''
								LEFT JOIN LIB_ModelAttributeProperties D with (nolock) ON D.MAP_MA_MOD_ID = A.MA_MOD_ID and D.MAP_MA_DZT_Name = A.MA_DZT_Name and D.MAP_Propety = 'Hide'
								left join CTL_Parametri CP with(nolock) on CP.Contesto=A.MA_MOD_ID and CP.oggetto=A.MA_DZT_Name and CP.Proprieta='Hide'
								inner join #Column_Of_Table on column_name= DZT_Name

							where MA_MOD_ID = @slice 
								and charindex(  ',' + DZT_Name + ',' , @HideColumn ) = 0
								and DZT_Name not in ( select DZT_Name from #Temp )
								--and isnull(d.map_value,'0') = '0'
								and COALESCE( CP.Valore,D.MAP_Value,'0')='0' 
							order by MA_Order

			END
		end

        set @Modelli = right(@Modelli,len(@Modelli) - @idx)
        if len(@Modelli) = 0 break

    end

	IF @cnv = 0 
	BEGIN

		select  * from #Temp order by MA_Order

	END
	ELSE
	BEGIN
		
		select DZT_Name , DZT_Type , case when @IsCtl=0 then dbo.CNV( Caption, 'I') else Caption end  as Caption, MA_Order, isnull(DZT_Format,'') as DZT_Format
			from #Temp order by MA_Order

	END

end








GO
