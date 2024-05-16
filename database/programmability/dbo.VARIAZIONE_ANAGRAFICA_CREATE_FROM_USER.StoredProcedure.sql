USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[VARIAZIONE_ANAGRAFICA_CREATE_FROM_USER]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO














CREATE PROCEDURE [dbo].[VARIAZIONE_ANAGRAFICA_CREATE_FROM_USER] ( @IdDoc int  , @idUser int )
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
	declare @AssenzaPIVA varchar(1)

	declare @aziPartitaIVA varchar(100)

	declare @AttoOperazioneStraordinaria nvarchar(1000)
	declare @DataVariazione nvarchar(100)
	declare @OperazioniStraordinarie nvarchar(10)
	declare @aziCAPAmm nvarchar(1000)
	declare @aziIndirizzoAmm nvarchar(1000)
	declare @aziLocalitaAmm nvarchar(1000)
	declare @aziLocalitaAmm2 nvarchar(1000)
	declare @aziProvinciaAmm2 nvarchar(1000)
	declare @aziProvinciaAmm nvarchar(1000)
	declare @aziRegioneAmm2 nvarchar(1000)
	declare @aziRegioneAmm nvarchar(1000)
	declare @aziStatoAmm2 nvarchar(1000)
	declare @aziStatoAmm nvarchar(1000)
	declare @CodiceEORI nvarchar(1000)
	declare @DataDecorrenzaVariazioni varchar(50)
	declare @classificazione as nvarchar(MAX)
	DECLARE @classi_ok as varchar(MAX)

	declare @Not_Editable nvarchar(1000)

	declare @Telefono1 nvarchar(1000)
	declare @Telefono2 nvarchar(1000)
	declare @sitoWeb nvarchar(1000)

	set @classi_ok=''
	set @classificazione=''


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
			,@AttoOperazioneStraordinaria = b1.vatValore_FT
			,@DataVariazione = b2.vatValore_FT
			,@OperazioniStraordinarie = b3.vatValore_FT
			,@aziCAPAmm = b4.vatValore_FT
			,@aziIndirizzoAmm = b5.vatValore_FT
			,@aziLocalitaAmm = b6.vatValore_FT
			,@aziLocalitaAmm2 = b7.vatValore_FT
			,@aziProvinciaAmm2 = b8.vatValore_FT
			,@aziProvinciaAmm = b9.vatValore_FT
			,@aziRegioneAmm2 = B10.vatValore_FT
			,@aziRegioneAmm = b11.vatValore_FT
			,@aziStatoAmm2 = b12.vatValore_FT
			,@aziStatoAmm = b13.vatValore_FT
			,@CodiceEORI = b14.vatValore_FT
			,@aziPartitaIVA = b.aziPartitaIVA
			,@DataDecorrenzaVariazioni = b15.vatValore_FT
			,@Telefono1 = b.aziTelefono1
			,@Telefono2 = b.aziTelefono2
			,@sitoWeb = b.aziSitoWeb
		from profiliutente a with(nolock) 
				inner join aziende b with(nolock) ON b.idazi = a.pfuIdAzi
				left join dm_attributi b1 with(nolock) ON b1.lnk = b.IdAzi and b1.dztNome = 'AttoOperazioneStraordinaria'
				left join dm_attributi b2 with(nolock) ON b2.lnk = b.IdAzi and b2.dztNome = 'DataVariazione'
				left join dm_attributi b3 with(nolock) ON b3.lnk = b.IdAzi and b3.dztNome = 'OperazioniStraordinarie'
				left join dm_attributi b4 with(nolock) ON b4.lnk = b.IdAzi and b4.dztNome = 'aziCAPAmm'
				left join dm_attributi b5 with(nolock) ON b5.lnk = b.IdAzi and b5.dztNome = 'aziIndirizzoAmm'
				left join dm_attributi b6 with(nolock) ON b6.lnk = b.IdAzi and b6.dztNome = 'aziLocalitaAmm'
				left join dm_attributi b7 with(nolock) ON b7.lnk = b.IdAzi and b7.dztNome = 'aziLocalitaAmm2'
				left join dm_attributi b8 with(nolock) ON b8.lnk = b.IdAzi and b8.dztNome = 'aziProvinciaAmm2'
				left join dm_attributi b9 with(nolock) ON b9.lnk = b.IdAzi and b9.dztNome = 'aziProvinciaAmm'
				left join dm_attributi b10 with(nolock) ON b10.lnk = b.IdAzi and b10.dztNome = 'aziRegioneAmm2'
				left join dm_attributi b11 with(nolock) ON b11.lnk = b.IdAzi and b11.dztNome = 'aziRegioneAmm'
				left join dm_attributi b12 with(nolock) ON b12.lnk = b.IdAzi and b12.dztNome = 'aziStatoAmm2'
				left join dm_attributi b13 with(nolock) ON b13.lnk = b.IdAzi and b13.dztNome = 'aziStatoAmm'
				left join dm_attributi b14 with(nolock) ON b14.lnk = b.IdAzi and b14.dztNome = 'CodiceEORI'		
				left join dm_attributi b15 with(nolock) ON b15.lnk = b.IdAzi and b15.dztNome = 'DataDecorrenzaVariazioni'	
				
		where idpfu=@idUser and pfudeleted=0


	set @Not_Editable = '' 


	-- aggiungendo aziE_Mail  nel caso l'azienda abbia na PEC in INIPEC con stato <> da 'NonPresente'
	if exists( select dzt_name from lib_dictionary with(nolock) where dzt_name = 'SYS_MODULI_GRUPPI' and ',' + DZT_ValueDef + ',' like '%,GESTIONE_INIPEC,%' )
		and
		exists( select * from document_inipec with(nolock) where idheader = 0 and idazi = @idazi and statoinipec <> 'NonPresente' )
	begin
		set @Not_Editable = ' aziE_Mail ' 
	end
	
	if @Errore=''
	begin
		--Se e' presente una richiesta nello stato di :InValutazione esco con messaggio di blocco "E' gia' presente una richiesta di annullamento in corso"
		if exists (select * from ctl_doc where tipodoc='VARIAZIONE_ANAGRAFICA' and linkeddoc=@IdAzi and statofunzionale='InValutazione' and deleted=0 )
			set @Errore='E'' gia'' presente una richiesta di variazione in corso'
	end
	
	if @Errore=''
	begin
		--Se e' presente una richiesta nello stato inlavorazione fatat da un altro utente esco
		if exists (select * from ctl_doc where tipodoc='VARIAZIONE_ANAGRAFICA' and linkeddoc=@IdAzi and statofunzionale='InLavorazione' and deleted=0 and idpfu<>@idUser)
			set @Errore='Esiste una versione salvata da un altro utente.Per proseguire e'' necessario eliminarla'
	end
	

	if @Errore=''
	begin
		
		set @Id=0
		
		--Se e' presente una richiesta salvata dallo stesso utente la riapro
		select @id=id from ctl_doc where tipodoc='VARIAZIONE_ANAGRAFICA' and linkeddoc=@IdAzi and statofunzionale='InLavorazione' and deleted=0 and idpfu=@idUser
		
		if @id=0
		begin
			
			--inserisco nella ctl_doc		
			insert into CTL_DOC (
					 IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  
						ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck)
			values	
					( @idUser, 'VARIAZIONE_ANAGRAFICA', 'Saved' , 'Variazione Anagrafica ' , '' , @IdAzi ,null
						,''  , '' , @IdAzi  ,'InLavorazione', null , dbo.PARAMETRI('VARIAZIONE_ANAGRAFICA_DOCUMENT','JumpCheck','DefaultValue','',-1))
						

			set @Id = SCOPE_IDENTITY()		
	

			--inserisco i campi mosidificabili nella CTL_DOC_VALUE
			insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values
				(  @Id, 'TESTATA', 0, 'AziRagioneSociale',  @AziragioneSociale) 
			
			insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values
				(  @Id, 'TESTATA', 0, 'aziIdDscFormaSoc',  @aziIdDscFormaSoc) 
			
			insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values
				(  @Id, 'TESTATA', 0, 'AziStatoLeg',  @AziStatoLeg) 
			
			insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values
				(  @Id, 'TESTATA', 0, 'aziProvinciaLeg',  @aziProvinciaLeg) 

			insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values
				(  @Id, 'TESTATA', 0, 'aziLocalitaLeg',  @aziLocalitaLeg) 

			insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values
				(  @Id, 'TESTATA', 0, 'aziIndirizzoLeg',  @aziIndirizzoLeg) 

			insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values
				(  @Id, 'TESTATA', 0, 'aziCAPLeg',  @aziCAPLeg) 
			
			insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values
				(  @Id, 'TESTATA', 0, 'aziE_Mail',  @aziE_Mail) 

			insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values
				(  @Id, 'TESTATA', 0, 'AziStatoLeg2',  @AziStatoLeg2) 
			
			insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values
				(  @Id, 'TESTATA', 0, 'aziProvinciaLeg2',  @aziProvinciaLeg2) 

			insert into ctl_doc_value
				( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values
				(  @Id, 'TESTATA', 0, 'aziLocalitaLeg2',  @aziLocalitaLeg2) 

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values (  @Id, 'TESTATA', 0, 'AttoOperazioneStraordinaria',  @AttoOperazioneStraordinaria) 

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value ) 
				values (  @Id, 'TESTATA', 0, 'DataVariazione',  @DataVariazione) 

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'OperazioniStraordinarie',  @OperazioniStraordinarie)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziCAPAmm',  @aziCAPAmm)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziIndirizzoAmm',  @aziIndirizzoAmm)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziLocalitaAmm',  @aziLocalitaAmm)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziLocalitaAmm2',  @aziLocalitaAmm2)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziProvinciaAmm2',  @aziProvinciaAmm2)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziProvinciaAmm',  @aziProvinciaAmm)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziRegioneAmm2',  @aziRegioneAmm2)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziRegioneAmm',  @aziRegioneAmm)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziStatoAmm2',  @aziStatoAmm2)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziStatoAmm',  @aziStatoAmm)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'CodiceEORI',  @CodiceEORI)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziPartitaIVA',  @aziPartitaIVA)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziTelefono1',  @Telefono1)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziTelefono2',  @Telefono2)

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'aziSitoWeb',  @sitoWeb)
			
			-------------------------------------------------------------------------
			if @aziPartitaIVA = ''
				set @AssenzaPIVA ='1'
			else
				set @AssenzaPIVA ='0'

			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'AssenzaPIVA',  @AssenzaPIVA)
			-------------------------------------------------------------------------

			--recupero se presente oppure no dalla funzione nuova
			declare @strPIVA_Obbligatoria as varchar(10)
			select @strPIVA_Obbligatoria = dbo.Get_PIVA_Obbligatoria(@IdAzi)

			
			if @strPIVA_Obbligatoria = 'no'
			--IF ISNULL(@aziPartitaIVA,'') = ''
			BEGIN
				insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'colonnatecnica',  'PARTITA_IVA_NON_PRESENTE')	
			END


			insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values (  @Id, 'TESTATA', 0, 'DataDecorrenzaVariazioni',  @DataDecorrenzaVariazioni)
			
			--SE IL PERMESSO E' ATTIVO SU UTENTE, ALLORA POPOLO LE CLASSI SUL DOCUMENTO
			IF EXISTS (SELECT  * from profiliUtente  with(nolock) where idpfu=@idUser and substring(pfufunzionalita,309,1)='1')
			BEGIN
				set @classificazione='###'
				select @classificazione=@classificazione + vatValore_FT + '###' 
					from DM_Attributi with(nolock) where lnk=@IdAzi and dztNome='ClasseIscriz'

				---RIMUOVO LE CLASSIISCRIZ NON PRESENTI NEL DOMINIO 				
				set @classi_ok='###'
				select @classi_ok=@classi_ok + items + '###' 
					from dbo.Split(@classificazione,'###')
						inner join ClasseIscriz on DMV_Cod=items and ISNULL(dmv_deleted,0)=0

				insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					values (  @Id, 'CLASSI', 0, 'ClasseIscriz',  @classi_ok)



				set @classificazione='###'
				select @classificazione=@classificazione + vatValore_FT + '###' 
					from DM_Attributi with(nolock) where lnk=@IdAzi and dztNome='ClassificazioneSOA'

				---RIMUOVO LE ClassificazioneSOA NON PRESENTI NEL DOMINIO 				
				set @classi_ok='###'
				select @classi_ok=@classi_ok + items + '###' 
					from dbo.Split(@classificazione,'###')
						inner join GerarchicoSOA on DMV_Cod=items and ISNULL(dmv_deleted,0)=0

				insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					values (  @Id, 'CLASSI', 0, 'ClassificazioneSOA',  @classi_ok)

				set @classificazione='###'
				select @classificazione=@classificazione + vatValore_FT + '###' 
					from DM_Attributi with(nolock) where lnk=@IdAzi and dztNome='ATECO'
			
				insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					values (  @Id, 'CLASSI', 0, 'ATECO',  @classificazione)
			
				insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
					select  @Id, 'REFERENTE', 0, DZT_Name, Value
						from SCHEDA_ANAGRAFICA_DATI_AGGIUNTIVI_view 
						where dzt_name like 'referente%' 
						AND IdHeader = @IdAzi

				
			END
			

		end
		else
		begin
			if @aziPartitaIVA = ''
				set @AssenzaPIVA ='1'
			else
				set @AssenzaPIVA ='0'
			update CTL_DOC_Value set Value = @AssenzaPIVA where IdHeader = @id and DZT_Name = 'AssenzaPIVA' and DSE_ID = 'TESTATA'
		end

	end


	delete from ctl_doc_value where IdHeader = @id and DSE_ID = 'TESTATA' and Row = 0 and  DZT_Name = 'Not_Editable' 

	insert into ctl_doc_value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
		values (  @Id, 'TESTATA', 0, 'Not_Editable',  @Not_Editable )

	
	if @Errore=''
		-- rirorna id odc creato
		select @Id as id , @Errore as Errore
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
		
	
	

END


GO
