USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_SP_CAN_INSERT_INFO_ADD_ISTANZA]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[OLD2_SP_CAN_INSERT_INFO_ADD_ISTANZA] ( @IdDoc INT  , @classi nvarchar(MAX) ,  @out as INT = NULL output , @asp INT = 0)
AS
BEGIN
set nocount on

	set @out=0
	declare @classi_usate as nvarchar(MAX)
	declare @path_classi as nvarchar(MAX)
	declare @path_classi_mod as nvarchar(MAX)
	declare @classi_INFO_ADD as nvarchar(MAX)
	

	set @classi_INFO_ADD=''
	set @classi_usate=''
	set @path_classi_mod=''

	--RECUPERO TUTTE LE CLASSI CHE RICHIEDONO INFORMAZIONI AGGIUNTIVE
	select 	@classi_usate=@classi_usate + ISNULL(value,'') 			
		from ctl_doc
				inner join CTL_DOC_Value CV on CV.idHeader=id and CV.DSE_ID='CLASSE' and CV.DZT_Name='ClasseIscriz'
		where TipoDoc='CONFIG_MODELLI_MERC_ADDITIONAL_INFO' and Deleted=0 and StatoFunzionale in ('Pubblicato')					

	--print @classi_usate
	--FACCIO 2 CURSORI A CASCATA PER VERIFICARE SE LE CLASSI INSERITE SUL DOC ISTANZA RICHIEDONO INFO AGGIUNTIVE
	declare CurProg Cursor Static for 
			select DMV_Father as path_classi
				from dbo.split(@classi,'###')
						inner join  ClasseIscriz on dmv_cod=items and dmv_deleted=0		

	open CurProg

	FETCH NEXT FROM CurProg INTO @path_classi

	WHILE @@FETCH_STATUS = 0 --and @out=0
	BEGIN	
					
		declare CurProg2 Cursor Static for 
					select DMV_Father as path_classi_mod
						from dbo.split(@classi_usate,'###')
							inner join  ClasseIscriz on dmv_cod=items and dmv_deleted=0

		open CurProg2

		FETCH NEXT FROM CurProg2 INTO @path_classi_mod

		WHILE @@FETCH_STATUS = 0
		BEGIN							

			if ( LEFT(@path_classi,LEN(@path_classi_mod)) = @path_classi_mod )
			BEGIN
				set @classi_INFO_ADD=@classi_INFO_ADD + @path_classi_mod + '###' 
				set @out=1
			END			
				
			FETCH NEXT FROM CurProg2 INTO @path_classi_mod

		END

		CLOSE CurProg2
		DEALLOCATE CurProg2

		FETCH NEXT FROM CurProg  INTO @path_classi

	END 

	CLOSE CurProg
	DEALLOCATE CurProg

	--RIMUOVO I PATH DUPLICATI
	declare @value as nvarchar(max)
	set @value='###'
	
	select   @value = @value + items  + '###' 
		from dbo.split(@classi_INFO_ADD,'###')
		group by (items)
		order by items

	if @asp=1
	BEGIN
		return @out
	END
	ELSE
		select @value as ELENCO_PATH_CLASSI_MODELLO


	
END






GO
