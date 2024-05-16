USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_DOCUMENT_CK_TOOLBAR_PDA_COMUNICAZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[OLD2_DOCUMENT_CK_TOOLBAR_PDA_COMUNICAZIONE](  @DocName nvarchar(500) , @IdDoc as nvarchar(500) , @idUser int ) as

BEGIN
	set nocount on
	declare @idPda int
	declare @idGara int
	declare @COM_ID int
	declare @Contesto varchar(500)


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
		from 
			CTL_DOC with(nolock) 
		where 
			Id = @IdDoc 
	

END
			
GO
