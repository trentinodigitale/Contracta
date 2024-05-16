USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[NOTIER_FATTURE_PA_CREATE_FROM_LISTA]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[NOTIER_FATTURE_PA_CREATE_FROM_LISTA] ( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @id INT
	declare @Errore as nvarchar(2000)
	declare @IdAzi as int
	declare @ragSoc as nvarchar(4000)
	declare @cf as varchar(100)
	declare @piva as varchar(100)
	declare @idNotier varchar(500)
	declare @pid varchar(500)
	declare @aziStatoLeg varchar(100)
	declare @aziCitta varchar(1000)
	declare @aziCap varchar(10)
	declare @aziIndirizzo varchar(1000)

	set @Id = 0
	set @Errore=''
	set @idNotier = ''
	set @pid = ''

	select   @IdAzi=pfuidazi 
			,@idNotier = isnull(d1.vatValore_FT,'')
			,@ragSoc = aziRagioneSociale 
			,@aziStatoLeg = aziStatoLeg2
			,@cf = d2.vatValore_FT 
			,@piva = aziPartitaIVA
			,@pid = d3.vatValore_FT
			,@aziCitta = aziLocalitaLeg
			,@aziCap = aziCAPLeg
			,@aziIndirizzo = aziIndirizzoLeg
		from profiliutente with(nolock)
				left join aziende with(nolock) ON pfuidazi=idazi
				left join DM_Attributi d1 with(nolock) ON d1.lnk = idazi and d1.dztNome = 'IDNOTIER' and d1.idApp = 1
				left join DM_Attributi d2 with(nolock) ON d2.lnk = idazi and d2.dztNome = 'codicefiscale' and d2.idApp = 1
				left join DM_Attributi d3 with(nolock) ON d3.lnk = idazi and d3.dztNome = 'participantid' and d3.idApp = 1
		where idpfu=@idUser  


	select * into #ipa	
		from Document_NoTIER_Destinatari a with(nolock) 
			--inner join ProfiliUtenteAttrib b with(nolock) on b.IdPfu = @idUser and b.dztNome = 'CodiceIPA_Notier' and b.attValue = a.ID_IPA 
		where piva_cf = @cf and bDeleted = 0

	IF EXISTS ( select id from #ipa ) and NOT EXISTS ( select id from #ipa where Peppol_Invio_Fatture = '1' )
	BEGIN
		set @Errore = 'Creazione Fatture non consentita. La registrazione Peppol è stata effettuata senza l''opzione ''Invio Fatture/Note Di Credito''' 
	END

	if @Errore = '' and (@idNotier <> '' OR exists ( select id from #ipa ))
		begin

		--inserisco nella ctl_doc		
		insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck)
			values			( @idUser, 'NOTIER_INVOICE', 'Saved' , 'Fattura NoTI-ER' , '' , @IdAzi , null					,''  , '' ,NULL,'InLavorazione', @idUser , '')
					
		set @Id = SCOPE_IDENTITY()		

		INSERT INTO Document_dati_protocollo (idHeader)	values	(@id)

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'PartyName', @ragSoc) 

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'PartyIdentification_ID', @cf) 

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'PartyTaxScheme_CompanyID', @piva) 

		IF @aziStatoLeg = 'M-1-11-ITA'
		BEGIN
			
			INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'PostalAddress_Country', 'IT') 

		END

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'PostalAddress_CityName', @aziCitta) 

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'PostalAddress_PostalZone', @aziCap) 

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'PostalAddress_StreetName', @aziIndirizzo) 
		end
	else
		begin
			if @errore = ''
				set @errore = 'Effettuare prima l''iscrizione a NoTI-ER'
		end

	if @Errore=''
		begin
			select @Id as id , 'NOTIER_INVOICE' as TYPE_TO, 'NOTIER_INVOICE' as JSCRIPT
		end
	else
		begin
			select 'Errore' as id , @Errore as Errore
		end
END
GO
