USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[QUESTIONARIO_Crea_Field]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROCEDURE [dbo].[QUESTIONARIO_Crea_Field]( @FieldType varchar(100) , @idx int = 0) as
begin



	if not exists( select * from LIB_Dictionary where DZT_Name =  'DOMANDA_QUESTIONARIO_' + @FieldType + '_'  + cast(   @idx as char(20)) )
	begin
		
		declare @Len int
		declare @Format varchar (50)
		declare @DZT_DM_ID as varchar(20)
		
		set @Len = 200
		set @Format = ''
		set @DZT_DM_ID = ''

		-- definisce una lunghezza base per la tipologia dell'attributo
		if @FieldType = 'Testo'
		begin
			set @Len = 200
		end

		if @FieldType = 'Numero'
		begin
			set @Len = 10
			set @Format = '###,###.00'
		end

		if @FieldType = 'Dominio'
		begin
			set @Len = 50
			set @DZT_DM_ID = 'Dominio_Valori'
		end

		if @FieldType = 'TextArea'
		begin
			set @Len = 200
			set @Format = 'nl'
		end

		if @FieldType = 'Check'
		begin
			set @Len = 2
		end


		if @FieldType = 'Radio'
		begin
			set @Len = 2
		end

		insert into LIB_Dictionary ( DZT_Name, DZT_Type, DZT_DM_ID, DZT_DM_ID_Um, DZT_MultiValue, DZT_Len, DZT_Dec, DZT_DescML, DZT_Format, DZT_Sys, DZT_ValueDef, DZT_Module, DZT_Help, DZT_RegExp )
			select    'DOMANDA_QUESTIONARIO_' + @FieldType + '_'  + cast(   @idx as varchar(20) ) as DZT_Name, 
					case when @FieldType = 'Testo' then 1 
						when @FieldType = 'Numero' then 2 
						when @FieldType = 'TextArea' then 3
						when @FieldType = 'Radio' then 9 --10 sostituito a causa della gestione dei radio nella libreria
						when @FieldType = 'Check' then 9
						else 4 -- dominio
					end as DZT_Type, 
					@DZT_DM_ID as DZT_DM_ID, '' as DZT_DM_ID_Um, 0 as DZT_MultiValue, @Len as DZT_Len, 2 as DZT_Dec, @FieldType as DZT_DescML, 
					@Format as DZT_Format, 0 as DZT_Sys, '' as DZT_ValueDef, 'FABBISOGNI_QUALITATIVI_AUTO' as DZT_Module, '' as DZT_Help, '' as DZT_RegExp  

	end



end


GO
