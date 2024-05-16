USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AVCP_GARA_CREATE_FROM_VIEW_GESTIONE_AVCP]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[AVCP_GARA_CREATE_FROM_VIEW_GESTIONE_AVCP] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @Denominazione as nvarchar(200)
	declare @CF as nvarchar(200)
	
	declare @IdPfu as INT

	set @Errore = ''

	set @azienda=@idDoc

	select @Denominazione=aziRagioneSociale from aziende where idazi=@idDoc
	select @CF=vatValore_FT from DM_ATTRIBUTI where lnk=@azienda and dztnome='codicefiscale'

	if @Errore = '' 
	begin
				INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda )
				Values (@IdUser , 'AVCP_GARA' ,@azienda )
		
				set @id = @@identity
				
				update ctl_doc set Versione=@id,Fascicolo='AVCP-' + cast ( @id as varchar(10)) where id=@id

				Insert into document_AVCP_lotti (Idheader,CFprop,Denominazione)
				VALUES(@id,@CF,@Denominazione)
		
	end
		
	



	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END








GO
