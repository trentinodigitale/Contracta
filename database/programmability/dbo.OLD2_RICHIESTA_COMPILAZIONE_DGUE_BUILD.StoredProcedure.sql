USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_RICHIESTA_COMPILAZIONE_DGUE_BUILD]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE PROC [dbo].[OLD2_RICHIESTA_COMPILAZIONE_DGUE_BUILD] ( @iduser as int , @idOfferta as int , @idAzi as int, @TipoRiferimento as varchar(50))
as
BEGIN

set nocount on;	
declare @Id as INT
declare @Errore as nvarchar(2000)
declare @newId as INT
declare @titolo as nvarchar(500)
declare @CIG as nvarchar(500)

set @id=0
	
	---verifica se per l’azienda e l’offerta esiste già un documento di richiesta, se esiste lo associa all’offerta con StatoDGUE = ‘InviataRichiesta” ed avvalora anche IdDocRicDGUE con il doc di richiesta.
	select @Id = id 
		from CTL_DOC 
		where TipoDoc = 'RICHIESTA_COMPILAZIONE_DGUE' and Deleted = 0 and LinkedDoc=@idOfferta and JumpCheck=@TipoRiferimento and StatoFunzionale <> 'Annullato'
		
	
	--se esiste lo associa all’offerta con StatoDGUE = ‘InviataRichiesta” ed avvalora anche IdDocRicDGUE con il doc di richiesta.	
	if @Id > 0
	begin
		update Document_Offerta_Partecipanti  set StatoDGUE='InviataRichiesta' , IdDocRicDGUE=@id where idazi=@idAzi and idheader=@idOfferta and TipoRiferimento=@TipoRiferimento
	end
	--,Avvalimento,Consorzio 
	--genera per l’azienda indicata un documento di RICHIESTA_COMPILAZIONE_DGUE
	if @Id = 0
	BEGIN
		
		select @CIG=ISNULL(CIG,'') from ctl_doc inner join Document_Bando on idheader=LinkedDoc where id=@idOfferta

		set @titolo='Richiesta DGUE per la gara CIG:' + @CIG +' - ' + case when @TipoRiferimento='RTI' then 'Mandante' when @TipoRiferimento='ESECUTRICI' then 'Consorzio' when @TipoRiferimento='AUSILIARIE'  then 'Avvalimento' end 
		-- CREO IL DOCUMENTO
		INSERT into CTL_DOC (IdPfu,idPfuInCharge,LinkedDoc, titolo, TipoDoc,Destinatario_Azi ,Body,JumpCheck,StatoFunzionale,Azienda,Fascicolo,ProtocolloRiferimento)
			select  @IdUser,0,@idOfferta,@titolo,'RICHIESTA_COMPILAZIONE_DGUE'  ,@idAzi,body,@TipoRiferimento,'InLavorazione',Azienda,Fascicolo,ProtocolloRiferimento
				from ctl_doc
				where id=@idOfferta

		set @newId = SCOPE_IDENTITY()

		---AGGIORNA I RIFERIMENTI SULLA RIGA RELATIVA 
		update Document_Offerta_Partecipanti set StatoDGUE='InviataRichiesta' , IdDocRicDGUE=@newId where idazi=@idAzi and idheader=@idOfferta and TipoRiferimento=@TipoRiferimento
		
		
		--Per tutti i nuovi documenti viene inviata una mail 
		INSERT INTO CTL_Schedule_Process (iddoc,iduser,DPR_DOC_ID,DPR_ID,State)
		select @newId,@IdUser,'RICHIESTA_COMPILAZIONE_DGUE','SEND_MAIL','0'

		--inserisce nella ctl_attvità il record per far uscire la richiesta nella lista alla login
		--con data scadenza datapresentazioneofferte, non bloccante
		insert into ctl_attivita
			(ATV_Object, ATV_DateInsert, ATV_Obbligatory, ATV_Execute,ATV_ExpiryDate, 
				ATV_DocumentName, ATV_IdDoc, ATV_IdPfu,ATV_IdAzi )
			Select C.Titolo , getdate()   ,'no'			,	'no'	 , isnull( b1.DataScadenzaOfferta , dateadd( month , 6 ,getdate())),
					C.tipoDoc			, C.id	   , NULL  ,C.Destinatario_Azi 
				from CTL_DOC C 
					inner join ctl_doc CO on CO.id=C.LinkedDoc
					INNER JOIN Document_Bando b1 on CO.LinkedDoc = b1.idheader
				where  C.id= @newId

	END 
	

END




GO
