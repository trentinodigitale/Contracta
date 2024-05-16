USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_AVCP_LOTTO_CREATE_FROM_AVCP_LOTTO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[OLD2_AVCP_LOTTO_CREATE_FROM_AVCP_LOTTO] 
	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Errore as nvarchar(2000)

	declare @azienda as varchar(50)
	declare @Versione as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @linkedDoc as INT
	
	
	declare @Denominazione as nvarchar(200)
	declare @CF as nvarchar(200)
	
	declare @IdPfu as INT

	set @Errore = ''
	select @azienda=Azienda,@Versione=Versione,@Fascicolo=Fascicolo,@linkedDoc=linkedDoc from ctl_doc where id=@idDoc
	

	select @Denominazione=aziRagioneSociale from aziende where idazi=@azienda
	select @CF=vatValore_FT from DM_ATTRIBUTI where lnk=@azienda and dztnome='codicefiscale'


	if @Errore = '' 
	begin
				INSERT into CTL_DOC ( IdPfu,  TipoDoc, Azienda ,PrevDoc,Versione,Fascicolo,linkedDoc)
				Values (@IdUser , 'AVCP_LOTTO' ,@azienda,@idDoc,@Versione,@Fascicolo,@linkedDoc )
		
				set @id = @@identity				
				

				Insert into document_AVCP_lotti (idheader, Anno, Cig, CFprop, Denominazione, Scelta_contraente, ImportoAggiudicazione, DataInizio, Datafine, ImportoSommeLiquidate, Oggetto, DataPubblicazione, Warning)
				select @id, Anno, Cig, CFprop, Denominazione, Scelta_contraente, ImportoAggiudicazione, DataInizio, Datafine, ImportoSommeLiquidate, Oggetto, DataPubblicazione, Warning
				from document_AVCP_lotti where idheader=@idDoc

				insert into document_AVCP_Importi ( IdHeader, DataInizio, DataFine, DataLiquidazione, Importo )
				select @id, DataInizio, DataFine, DataLiquidazione, Importo 
				from document_AVCP_Importi where idheader=@idDoc
		
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
