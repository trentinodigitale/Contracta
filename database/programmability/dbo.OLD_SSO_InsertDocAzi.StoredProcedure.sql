USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SSO_InsertDocAzi]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD_SSO_InsertDocAzi] ( @idUser INT )
AS
BEGIN

	SET NOCOUNT ON

	declare		@Id INT
	declare		@idAzi INT
	declare		@aziVenditore INT

	declare		@CodiceFiscaleAzi varchar(100)
	declare		@RagioneSocialeAzi nvarchar(1000)
	declare		@EmailAzi nvarchar(1000)
	declare		@PartitaIvaAzi varchar(100)
	declare		@CittaAzi nvarchar(500)
	declare		@ViaAzi nvarchar(500)
	declare		@CapAzi varchar(100)
	declare		@TelefonoAzi varchar(500)
	declare		@FaxAzi varchar(500)
	declare		@NazioneAzi nvarchar(500)
	declare		@ProvinciaAzi varchar(500)

	DECLARE @CF varchar(100)
	DECLARE @COGNO nvarchar(4000)
	DECLARE @NOME nvarchar(4000)
	DECLARE @MAIL nvarchar(1000)
	DECLARE @TEL varchar(500)

	-- Recupero il flag per capire se l'azienda è un ente o meno
	select top 1 @aziVenditore = aziVenditore, 
				 @idAzi = azi.IdAzi,
				 @RagioneSocialeAzi = azi.aziRagioneSociale,
				 @EmailAzi = azi.aziE_Mail,
				 @PartitaIvaAzi = azi.aziPartitaIVA,
				 @CittaAzi = azi.aziLocalitaLeg,
				 @ViaAzi = azi.aziIndirizzoLeg,
				 @CapAzi = azi.aziCAPLeg,
				 @TelefonoAzi = azi.aziTelefono1,
				 @FaxAzi = azi.aziFAX,
				 @NazioneAzi = azi.aziStatoLeg,
				 @ProvinciaAzi = azi.aziProvinciaLeg,
				 @CodiceFiscaleAzi = dm1.vatValore_FT,
				 @NOME = pfu.pfunomeutente,
				 @COGNO = pfu.pfuCognome,
				 @TEL = pfu.pfuTel,
				 @MAIL = pfu.pfuE_Mail,
				 @CF = pfu.pfuCodiceFiscale
		from profiliutente pfu with(nolock) 
					inner join aziende azi with(nolock) ON azi.idazi = pfu.pfuidazi 
					left join dm_attributi dm1 with(nolock) ON dm1.lnk = azi.idazi AND dm1.dztnome = 'codicefiscale'
		where pfu.idpfu = @idUser 

	-- Se è un operatore economico
    IF @aziVenditore <> 0
    BEGIN

		  INSERT INTO CTL_DOC ( TipoDoc,Titolo,JumpCheck, idPfuInCharge,idpfu, statoDoc, statoFunzionale )
			 VALUES  ('VERIFICA_REGISTRAZIONE','SSO - Censimento','1-VERIFICA_REGISTRAZIONE_FORN', 0,@IdUser, 'Sended','Confermato' )

		  set @id = @@identity
		  
		  --*************************************************
		  --*** INSERISCO I DATI DELL'OPERATORE ECONOMICO ***
		  --*************************************************

		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			VALUES ( @id, 'SCHEDA_OE','aziRagioneSociale', @RagioneSocialeAzi )

		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'SCHEDA_OE','INDIRIZZOLEG', @ViaAzi )

		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'SCHEDA_OE','aziStatoLeg', @NazioneAzi )
 
		  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES (  @id, 'SCHEDA_OE','LOCALITALEG', @CittaAzi )

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'SCHEDA_OE','PROVINCIALEG', @ProvinciaAzi ) 

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'SCHEDA_OE','CAPLEG', @CapAzi ) 

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'SCHEDA_OE','codicefiscale', @CodiceFiscaleAzi  )

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'SCHEDA_OE','PIVA', @PartitaIvaAzi ) 
			 
	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'SCHEDA_OE','NUMTEL', @TelefonoAzi )
			 			 
	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'SCHEDA_OE','NUMFAX', @FaxAzi  )

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'SCHEDA_OE','EMAIL', @EmailAzi )
			 
			 --INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				 --VALUES ( @id, 'SCHEDA_OE','aziStatoLeg2', '' )

			  --INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				 --VALUES (  @id, 'SCHEDA_OE','aziProvinciaLeg2', '' )

			  --INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				 --VALUES (  @id, 'SCHEDA_OE','aziLocalitaLeg2','' )

				--INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				-- select @id, 'SCHEDA_OE','ANNOCOSTITUZIONE', valore

				--  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				-- select @id, 'SCHEDA_OE','IscrCCIAA', valore

				--  INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
				-- select @id, 'SCHEDA_OE','SedeCCIAA', valore

			 --INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 --select @id, 'SCHEDA_OE','NaGi', tdrCodice
			 --from FormRegistrazione frm ,tipidatirange,descsi 
			 --where frm.sessionid = cast( @IdUser as varchar(200) ) and frm.nome_campo = 'NAGI' and  tdridtid = 131 and tdrdeleted=0 and IdDsc = tdriddsc and frm.valore = dscTesto


		  --*************************************************
		  --*** INSERISCO I DATI DELL'UTENTE  ***************
		  --*************************************************

	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'DATI_RAP_LEG','NomeRapLeg', @NOME )
			 
	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'DATI_RAP_LEG','CognomeRapLeg', @COGNO ) 
			 			 
	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'DATI_RAP_LEG','TelefonoRapLeg', @TEL ) 
			 
	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'DATI_RAP_LEG','EmailRapLeg', @MAIL ) 
			 
	       INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 VALUES ( @id, 'DATI_RAP_LEG','CFRapLeg', @CF ) 
			 

	   --    INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 --select @id, 'DATI_RAP_LEG','CellulareRapLeg', valore
		  -- INSERT INTO ctl_doc_value (IdHeader,DSE_ID,DZT_Name,Value)
			 --select @id, 'DATI_RAP_LEG','pfuRuoloAziendale', valore
			 
 

    END	
	ELSE
	BEGIN

		-- SE è un ente
		INSERT INTO Document_Aziende
				   (IdPfu,TipoOperAnag,Stato,isOld,IdAzi,aziDataCreazione,aziRagioneSociale,aziIdDscFormaSoc,aziPartitaIVA,aziE_Mail
				   ,aziAcquirente,aziVenditore,aziProspect,aziIndirizzoLeg,aziLocalitaLeg,aziProvinciaLeg,aziStatoLeg,aziCAPLeg,aziTelefono1
				   ,aziTelefono2,aziFAX,aziProssimoProtRdo,aziProssimoProtOff,aziGphValueOper,aziDeleted
				   ,aziSitoWeb,aziProfili,aziProvinciaLeg2,aziStatoLeg2
				   ,codicefiscale,TipoDiAmministr,TIPO_AMM_ER,aziLocalitaLeg2,aziRegioneLeg,aziRegioneLeg2)
			 VALUES ( @idUser,'AZI_ENTE', 'Sended', 0, @idAzi, getdate(), @RagioneSocialeAzi, 0, @PartitaIvaAzi, @EmailAzi,
					  3, 0, 0, @ViaAzi, @CittaAzi,@ProvinciaAzi,@NazioneAzi,@CapAzi,@TelefonoAzi 
					  ,'',@FaxAzi,1,1,0,0 ,'','PE','','' 
					  ,@CodiceFiscaleAzi,'','','','','')

		  set @id = @@identity

	END

END






GO
