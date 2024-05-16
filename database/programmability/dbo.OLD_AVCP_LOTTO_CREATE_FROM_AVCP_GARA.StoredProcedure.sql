USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_AVCP_LOTTO_CREATE_FROM_AVCP_GARA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [dbo].[OLD_AVCP_LOTTO_CREATE_FROM_AVCP_GARA] 
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
	declare @versione as INT
	
	declare @IdPfu as INT

	set @Errore = ''

	Select @azienda=azienda,@versione=versione from ctl_doc where id=@idDoc

	

	select @Denominazione=aziRagioneSociale from aziende where idazi=@azienda
	select @CF=vatValore_FT from DM_ATTRIBUTI where lnk=@azienda and dztnome='codicefiscale'


	if @Errore = '' 
	begin
				INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda,Linkeddoc )
				Values (@IdUser , 'AVCP_LOTTO' ,@azienda,@versione )
		
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
