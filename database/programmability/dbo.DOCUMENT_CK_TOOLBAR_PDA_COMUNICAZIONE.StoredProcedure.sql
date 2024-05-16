USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_CK_TOOLBAR_PDA_COMUNICAZIONE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[DOCUMENT_CK_TOOLBAR_PDA_COMUNICAZIONE](  @DocName nvarchar(500) , @IdDoc as nvarchar(500) , @idUser int ) as

BEGIN
	set nocount on
	declare @idPda int
	declare @idGara int
	declare @COM_ID int
	declare @Contesto varchar(500)
	declare @TipoDocSource varchar(200)
	declare @Dati_In_Chiaro as varchar(10)
	declare @LinkedDoc as int
	declare @ATTIVO_VIS_INFO_MAIL as varchar(10)

	set @Dati_In_Chiaro='0'
	set @ATTIVO_VIS_INFO_MAIL = 'si'

	--ricavo il tipodoc sorgente da cui ho creato la comunicazionme
	select 
			@TipoDocSource = S.TipoDoc , @LinkedDoc = C.LinkedDoc
		from 
			ctl_doc C with (nolock)
				inner join ctl_doc S with (nolock) on S.id = C.LinkedDoc
		where
			C.id = @IdDoc

	if @TipoDocSource in ('BANDO_CONCORSO','PDA_CONCORSO')
	begin
		
		select
			@Dati_In_Chiaro = isnull([Value],0)
			from 
				ctl_doc_value  with(nolock) 
			where idheader = @LinkedDoc 
				and DSE_ID = 'ANONIMATO' 
				and DZT_Name = 'DATI_IN_CHIARO' 
				and Row = 0
		
		if @Dati_In_Chiaro = '0'
		begin
			set @ATTIVO_VIS_INFO_MAIL = 'no'
		end

	end

	--dalla COMUNICAZIONE ricavo id della pda
	select @idPda = linkeddoc, @Contesto = JumpCheck from ctl_doc with (nolock) where id = @IdDoc 

	--verifico che la comunicazione è legata ad una PDA alla funzione
	if exists ( select id from ctl_doc with (nolock) where id = @idPda and TipoDoc = 'PDA_MICROLOTTI' ) 
	begin 

		--dalla PDA_MICROLOTTI ricavo l'id della gara 
		select @idGara = linkeddoc from ctl_doc with (nolock) where id = @idPda

		--ricavo id della COMMISSIONE a partire dalla gara
		select @COM_ID = id from ctl_doc with (nolock) where linkeddoc = @idGara and TipoDoc ='COMMISSIONE_PDA' and statofunzionale ='pubblicato' and deleted=0
	
	end
	else
	begin 
		set @COM_ID = -1
	end

	if @Contesto <> '' 
		set @Contesto = right (@Contesto,len(@Contesto)-2)


	select 
			*
			, dbo.CAN_CREATE_COMUNICAZIONI(@idUser , @COM_ID, @Contesto) as CAN_CREATE_COMUNICAZIONI
			
			,@ATTIVO_VIS_INFO_MAIL as ATTIVO_VIS_INFO_MAIL

		from 
			CTL_DOC with(nolock) 
		where 
			Id = @IdDoc 
	

END
			
GO
