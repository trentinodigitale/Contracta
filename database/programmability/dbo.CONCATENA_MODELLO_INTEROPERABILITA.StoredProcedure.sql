USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CONCATENA_MODELLO_INTEROPERABILITA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE Proc [dbo].[CONCATENA_MODELLO_INTEROPERABILITA] ( @NomeModello as varchar(200) , @Att as varchar(50) ,  @idDoc as int , @Modulo as varchar(200) , @Modello_da_concatenare as varchar(200) )
as
begin

	declare @NewNomeModello  as varchar(500)
	--declare @ModelloBase  as varchar(500)
	--declare @contesto as varchar(500) = 'LOTTO'
	declare @max as int

	--if ( CHARINDEX('_MONOLOTTO',@NomeModello) > 0 ) 
	--BEGIN
	--	set @ModelloBase = 'MODELLO_BASE_' + @contesto + '_' + @Att + '_MONOLOTTO' 
	--END
	--ELSE
	--if ( CHARINDEX('_COMPLEX',@NomeModello) > 0 ) 
	--BEGIN
	--	set @ModelloBase = 'MODELLO_BASE_' + @contesto + '_' + @Att + '_COMPLEX' 
	--END
	--ELSE
	--BEGIN
	--	set @ModelloBase = 'MODELLO_BASE_' + @contesto + '_' + @Att  
	--END


	set @NewNomeModello = @NomeModello + '_' + @Att  
	--select @NewNomeModello + '--' + @Modello_da_concatenare

	--PCP mi conservo gli attributi presenti per escludere quelli già presenti 
	--oppure alcuni in modo specifico: pcp_SommeOpzioniRinnovi se presente IMPORTO_OPZIONI
	declare @CurrTempAttrib  TABLE  ( dzt_name varchar(100) )

	insert into @CurrTempAttrib
		(dzt_name)
	select MA_DZT_Name
		from 
			CTL_ModelAttributes with (nolock)
		where
			MA_MOD_ID = @NewNomeModello
	
	if exists (select dzt_name from @CurrTempAttrib where  dzt_name='IMPORTO_OPZIONI')
	begin
		insert into @CurrTempAttrib
			(dzt_name)
			values
			('pcp_SommeOpzioniRinnovi')
	end


	select @max = max(Ma_Pos) + 1 from CTL_ModelAttributes with (nolock) where MA_MOD_ID = @NewNomeModello

	--print @max
	--print @NewNomeModello

	INSERT INTO                    CTL_ModelAttributes( MA_MOD_ID , MA_DZT_Name , MA_DescML , MA_Pos , MA_Len , MA_Order , MA_Module )
		   SELECT            *
			   FROM
			   (
				   SELECT    
							@NewNomeModello AS MA_MOD_ID , 
							N.MA_DZT_Name , 
							case 
								when  isnull(MAP_Value,0) = 1 then  '<div class="Grid_CaptionObblig">' + cast( isnull( m.ml_description , MA_DescML ) as nvarchar(max)) + '</div>'
								else isnull( m.ml_description , MA_DescML ) 
							end as  MA_DescML , 
						
							(@max + MA_Pos) as MA_Pos , MA_Len , 
							(@max + MA_Order + MA_Order) as MA_Order , @Modulo AS MA_Module
					   
					   FROM  LIB_ModelAttributes N with (nolock)
								left join LIB_Multilinguismo m with (nolock) on m.ML_KEY = MA_DescML and m.ML_LNG = 'I' and m.ML_Context = 0
								left join LIB_ModelAttributeProperties with (nolock) on MA_MOD_ID=MAP_MA_MOD_ID and MAP_MA_DZT_Name=MA_DZT_Name and  MAP_Propety='Obbligatory' and MAP_Value='1'
								left join @CurrTempAttrib C on C.DZT_Name = N.MA_DZT_Name
					   
					   WHERE MA_MOD_ID = @Modello_da_concatenare
							 and c.DZT_Name is null

			   ) AS a

	
	INSERT INTO                             CTL_ModelAttributeProperties( MAP_MA_MOD_ID , MAP_MA_DZT_Name , MAP_Propety , MAP_Value , MAP_Module )
		   SELECT            *
			   FROM
			   (
				   SELECT    @NewNomeModello AS MAP_MA_MOD_ID , MAP_MA_DZT_Name , MAP_Propety , MAP_Value , @Modulo AS MAP_Module
					   FROM  LIB_ModelAttributeProperties with (nolock)
							left join @CurrTempAttrib C on C.DZT_Name = MAP_MA_DZT_Name
					   WHERE MAP_MA_MOD_ID = @Modello_da_concatenare
						 and c.DZT_Name is null
			   ) AS a
end
GO
