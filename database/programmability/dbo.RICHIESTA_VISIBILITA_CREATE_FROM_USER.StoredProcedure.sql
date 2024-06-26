USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[RICHIESTA_VISIBILITA_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[RICHIESTA_VISIBILITA_CREATE_FROM_USER] 
	( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON;	

	declare @id as varchar(50)
	declare @Errore as nvarchar(2000)
	declare @IdAzi as int
	declare @AziragioneSociale as nvarchar(450)
	declare @aziIdDscFormaSoc as int
	declare @AziStatoLeg as nvarchar(80)	
	declare @aziProvinciaLeg as nvarchar(80)
	declare @aziLocalitaLeg as nvarchar(80)
	declare @aziE_Mail as nvarchar(255)
	declare @aziIndirizzoLeg as nvarchar(80)
	declare @aziCAPLeg as nvarchar(8)
	declare @AziStatoLeg2 as varchar(80)	
	declare @aziProvinciaLeg2 as varchar(80)
	declare @aziLocalitaLeg2 as nvarchar(80)
	

	set @Id = ''
	set @Errore=''
	
	
	--recupero info azienda utente collegato
	select @IdAzi=pfuidazi 
			,@AziragioneSociale = aziRagioneSociale
			,@aziIdDscFormaSoc = aziIdDscFormaSoc
			,@AziStatoLeg = AziStatoLeg
			,@aziProvinciaLeg = aziProvinciaLeg 	
			,@aziLocalitaLeg = aziLocalitaLeg
			,@aziIndirizzoLeg = aziIndirizzoLeg
			,@aziCAPLeg = aziCAPLeg
			,@aziE_Mail=aziE_Mail
			,@AziStatoLeg2 = AziStatoLeg2
			,@aziProvinciaLeg2 = aziProvinciaLeg2	
			,@aziLocalitaLeg2 = aziLocalitaLeg2
			
		from profiliutente,aziende where idpfu=@idUser and pfuidazi=idazi and pfudeleted=0
	
	if @Errore=''
	begin
		
		--Se e' ho già il profilo ACCESSO_DOC_OE esco 
		if exists (select * from profiliutenteattrib where dztnome='profilo' and attvalue='ACCESSO_DOC_OE' and idpfu=@idUser )
			set @Errore='Si e'' gia'' abilitati alla visualizzazione dei documenti aziendali'
	end
	
	if @Errore=''
	begin
		--Se e' presente una richiesta nello stato inlavorazione fatat da un altro utente esco
		if exists (select * from ctl_doc where tipodoc='RICHIESTA_VISIBILITA' and linkeddoc=@IdAzi and statofunzionale='InLavorazione' and deleted=0 and idpfu<>@idUser)
			set @Errore='Esiste una versione salvata da un altro utente. Non e'' possibile proseguire'
	end
	

	if @Errore=''
	begin
		
		set @Id=0
		
		--Se e' presente una richiesta salvata dallo stesso utente la riapro
		select @id=id from ctl_doc where tipodoc='RICHIESTA_VISIBILITA' and linkeddoc=@IdAzi and statofunzionale='InLavorazione' and deleted=0 and idpfu=@idUser
		
		if @id=0
		begin
			
			--inserisco nella ctl_doc		
			insert into CTL_DOC (
					 IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
						ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck)
			values	
					( @idUser, 'RICHIESTA_VISIBILITA', 'Saved' , 'Richiesta accesso documenti' , '' , @IdAzi ,null
						,''  , '' , @IdAzi  ,'InLavorazione', @idUser , '')
					

			set @Id = @@identity		
	
			--inserisco i campi mosidificabili nella CTL_DOC_VALUE
			insert into ctl_doc_value
			( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
			values
			(  @Id, 'TESTATA', 0, 'Not_Editable',  '  DataTermineConcordata  ') 
			

		end

	end

	
	if @Errore=''
		-- rirorna id doc creato
		select @Id as id , @Errore as Errore
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
		
	
	

END



GO
