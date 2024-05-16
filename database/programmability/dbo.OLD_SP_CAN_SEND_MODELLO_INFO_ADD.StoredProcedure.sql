USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SP_CAN_SEND_MODELLO_INFO_ADD]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_SP_CAN_SEND_MODELLO_INFO_ADD] ( @IdDoc INT  , @classi nvarchar(MAX) ,  @out as INT output , @asp INT = 0)
AS
BEGIN

 	SET NOCOUNT ON

	declare @classi_usate as nvarchar(MAX)
	declare @path_classi_usate as nvarchar(MAX)
	declare @path_classi as nvarchar(MAX)
	declare @esito as nvarchar(MAX)

	declare @prevDoc int

	set @classi_usate=''
	set @esito=''
	set @out=0

	select @prevDoc = prevDoc
		from ctl_doc with(nolock)
		where id = @IdDoc
	
	----RECUPERO TUTTE LE CLASSI USATE SUI MODELLI VALIDI
	select 	@classi_usate = @classi_usate + ISNULL( cv.value,'') 			
		from ctl_doc a
				inner join CTL_DOC_Value CV on CV.idHeader = a.id and CV.DSE_ID='CLASSE' and CV.DZT_Name='ClasseIscriz'
			where a.TipoDoc='CONFIG_MODELLI_MERC_ADDITIONAL_INFO' 
					and a.Deleted=0 and a.StatoFunzionale in ('Pubblicato')
					and a.id <> @IdDoc   -- non il documento corrente
					and a.id <> @prevDoc -- non il documento che sto variando

	--FACCIO 2 CURSORI A CASCATA PER VERIFICARE SE LE CLASSI INSERITE SUL MODELLO VANNO BENE
	declare CurProg Cursor Static for 
				select DMV_Father as path_classi
				from dbo.split(@classi,'###')
					inner join  ClasseIscriz on dmv_cod=items and dmv_deleted=0
			
	open CurProg
	FETCH NEXT FROM CurProg INTO @path_classi

	WHILE @@FETCH_STATUS = 0 --and @out=0
	BEGIN	
					
		declare CurProg2 Cursor Static for 
						select DMV_Father as path_classi_usate
						from dbo.split(@classi_usate,'###')
								inner join  ClasseIscriz on dmv_cod=items and dmv_deleted=0

		open CurProg2

		FETCH NEXT FROM CurProg2 INTO @path_classi_usate

		WHILE @@FETCH_STATUS = 0
		BEGIN

			IF ( LEFT(@path_classi,len(@path_classi_usate) ) = @path_classi_usate or LEFT(@path_classi_usate,LEN(@path_classi))=@path_classi )
			BEGIN
				set @out=1
			END
				
			FETCH NEXT FROM CurProg2 INTO @path_classi_usate

		END

		CLOSE CurProg2
		DEALLOCATE CurProg2

		FETCH NEXT FROM CurProg  INTO @path_classi

	END 

	CLOSE CurProg
	DEALLOCATE CurProg		

	RETURN @out

END


GO
