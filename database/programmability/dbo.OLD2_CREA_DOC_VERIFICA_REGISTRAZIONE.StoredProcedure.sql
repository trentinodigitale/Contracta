USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CREA_DOC_VERIFICA_REGISTRAZIONE]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD2_CREA_DOC_VERIFICA_REGISTRAZIONE] 
	( @IdUser bigint , @idDoc bigint output )
AS
BEGIN
	SET NOCOUNT ON

	declare @Id as int
	declare @PrevDoc as int
	set @PrevDoc=0
	
	declare @Errore as nvarchar(2000)
	set @Errore = ''

    -- cerco una versione precedente del documento gia inviato
    set @id = null
    select @id = id from CTL_DOC where idpfu = -@IdUser and deleted = 0 and TipoDoc = 'VERIFICA_REGISTRAZIONE' and statofunzionale <> 'InLavorazione'

    -- se non esiste lo creo
    if @id is null
    begin
		  
		  
		  INSERT INTO CTL_DOC ( TipoDoc,Titolo,JumpCheck, idPfuInCharge,idpfu ) ---,StatoDoc )
			 VALUES  ('VERIFICA_REGISTRAZIONE','Richiesta censimento','1-VERIFICA_REGISTRAZIONE_FORN', 0, -@IdUser ) --, 'Sent')

		  set @id = @@identity
		  
		  --*************************************************
		  --*** INSERISCO I DATI DELL'OPERATORE ECONOMICO ***
		  --*************************************************

		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','aziRagioneSociale', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'RAGSOC'
			 
		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','NaGi', tdrCodice
			 from FormRegistrazione frm ,tipidatirange,descsi 
			 where frm.sessionid = cast( @IdUser as varchar(200) ) and frm.nome_campo = 'NAGI' and  tdridtid = 131     and tdrdeleted=0     and IdDsc =  tdriddsc 
				    and frm.valore = dscTesto

		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','INDIRIZZOLEG', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'INDIRIZZOLEG'
			 
		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','aziStatoLeg',valore
			    from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'STATOLEG'
			 -- from FormRegistrazione frm,LIB_DomainValues domVal where frm.sessionid = @IdUser and frm.nome_campo = 'STATOLEG'		  
			 --	and domVal.dmv_dm_id = 'GEO' and domVal.dmv_cod = frm.valore

		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','aziStatoLeg2',valore
			    from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'aziStatoLeg2'

		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','aziProvinciaLeg2',valore
			    from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'aziProvinciaLeg2'

		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','aziLocalitaLeg2',valore
			    from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'aziLocalitaLeg2'
		 
		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','LOCALITALEG', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'LOCALITALEG'

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','PROVINCIALEG', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'PROVINCIALEG'	 

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','CAPLEG', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'CAPLEG'	 

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','ANNOCOSTITUZIONE', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'ANNOCOSTITUZIONE'	 				

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','IscrCCIAA', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'IscrCCIAA'	 

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','SedeCCIAA', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'SedeCCIAA'

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','codicefiscale', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'codicefiscale'

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','PIVA', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'PIVA'
			 
	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','NUMTEL', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'NUMTEL'
			 
	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','NUMFAX', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'NUMFAX'

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'SCHEDA_OE','EMAIL', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'EMail'


		  --*************************************************
		  --*** INSERISCO I DATI DEL RAPPRESENTANTE LEGALE***
		  --*************************************************

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'DATI_RAP_LEG','NomeRapLeg', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'NomeRapLeg'
			 
	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'DATI_RAP_LEG','CognomeRapLeg', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'CognomeRapLeg'			 
			 
	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'DATI_RAP_LEG','TelefonoRapLeg', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'TelefonoRapLeg'	

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'DATI_RAP_LEG','CellulareRapLeg', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'CellulareRapLeg'	

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'DATI_RAP_LEG','EmailRapLeg', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'PFUEMAIL'	

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'DATI_RAP_LEG','ReferenteEMail', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'EMailRiferimentoAzienda'	

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'DATI_RAP_LEG','CFRapLeg', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'CFRapLeg'	

	       -- INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
		   --	 VALUES( @id, 'DATI_RAP_LEG','pfuRuoloAziendale', 'LEGALE RAPPRESENTANTE' )
		   INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 select @id, 'DATI_RAP_LEG','pfuRuoloAziendale', valore
			 from FormRegistrazione where sessionid = cast( @IdUser as varchar(200) ) and nome_campo = 'RuoloRapLeg'	
			 
		   
			 
	      --******************************************************************************************
		  --*** INSERISCO I DESTINATARI, tutti quelli che hanno il permesso di approvazione, USATI PER INVIO MAIL ALL'INVIO DEL DOC FATTO DAL FORNITORE ***
		  --*****************************************************************************************
		  insert into CTL_DOC_Destinatari
		  ( idHeader, IdPfu, IdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb )
		  select @id, IdPfu, pfuIdAzi, aziRagioneSociale, aziPartitaIVA, aziE_Mail, aziIndirizzoLeg, aziLocalitaLeg, aziProvinciaLeg, aziStatoLeg, aziCAPLeg, aziTelefono1, aziFAX, aziDBNumber, aziSitoWeb 
			from profiliUtente 
			inner join aziende on pfuidazi=idazi
			where substring (pfufunzionalita, 306, 1)=1
			and pfuidazi=35152001


			 
			 
			 

    end	
    else	
    begin
	   set @Errore = 'Richiesta gia inviata'
    end
		
		
    if @Errore = ''
    begin

	   set @idDoc = @Id

	   -- rirorna l'id della nuova comunicazione appena creata
	   select @Id as id, '' as Errore
	
    end
    else
    begin
	   -- rirorna l'errore
	   select 'Errore' as id , @Errore as Errore
    end

SET NOCOUNT OFF
END















GO
