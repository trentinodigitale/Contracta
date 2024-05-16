USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_NOTIER_DDT_CREATE_FROM_LISTA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD2_NOTIER_DDT_CREATE_FROM_LISTA] ( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @id INT
	declare @Errore as nvarchar(2000)
	declare @IdAzi as int
	declare @ragSoc as nvarchar(1000)
	declare @cf as varchar(100)

	declare @aziStatoLeg varchar(100)
	declare @aziCitta varchar(1000)
	declare @aziCap varchar(10)
	declare @aziIndirizzo varchar(1000)

	declare @idNoter varchar(500)
	declare @participantID varchar(500)

	set @Id = 0
	set @Errore=''
	set @idNoter = ''

	select   @IdAzi=pfuidazi 
			,@idNoter = isnull(d1.vatValore_FT,'')
			,@ragSoc = aziRagioneSociale 
			,@cf = d2.vatValore_FT
			,@aziStatoLeg = aziStatoLeg2
			,@aziCitta = aziLocalitaLeg
			,@aziCap = aziCAPLeg
			,@aziIndirizzo = aziIndirizzoLeg
			,@participantID = d3.vatValore_FT
		from profiliutente with(nolock)
				left join aziende with(nolock) ON pfuidazi=idazi
				left join DM_Attributi d1 with(nolock) ON d1.lnk = idazi and d1.dztNome = 'IDNOTIER'
				left join DM_Attributi d2 with(nolock) ON d2.lnk = idazi and d2.dztNome = 'codicefiscale'
				left join DM_Attributi d3 with(nolock) ON d3.lnk = idazi and d3.dztNome = 'PARTICIPANTID'
		where idpfu=@idUser  

	select * into #ipa 
		from Document_NoTIER_Destinatari a with(nolock) 
			--inner join ProfiliUtenteAttrib b with(nolock) on b.IdPfu = @idUser and b.dztNome = 'CodiceIPA_Notier' and b.attValue = a.ID_IPA 
		where piva_cf = @cf and bDeleted = 0 

	
	IF EXISTS ( select id from #ipa ) and NOT EXISTS ( select id from #ipa where Peppol_Invio_DDT = '1' )
	BEGIN
		set @Errore = 'Creazione DDT non consentita. La registrazione Peppol è stata effettuata senza l''opzione ''Invio DDT''' 
	END

	if @Errore = '' 
		and ( 
				@idNoter <> ''
					OR
				exists ( select id from #ipa )
		)
	begin
			
		--inserisco nella ctl_doc		
		insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_Azi,  ProtocolloRiferimento,  Fascicolo,LinkedDoc, StatoFunzionale,IdPfuInCharge, jumpcheck, Versione)
			values			( @idUser, 'NOTIER_DDT', 'Saved' , 'DDT NoTI-ER' , '' , @IdAzi , null					,''  , '' ,NULL,'InLavorazione', @idUser , '', '3.0')
					
		set @Id = SCOPE_IDENTITY()		

		INSERT INTO Document_dati_protocollo (idHeader)	values	(@id)

		-- se ho una sola IPA/UFFICIO collegato, preavvaloro l'identificativo con il codice ipa, altrimenti utilizziamo il cf
		declare @totIPA as INT
		set @totIPA = 0

		select @totIPA = count(*) from #ipa

		if @totIPA = 1 and isnull(@participantID,'') = ''
		begin
			select @participantID = a.ID_PEPPOL from #ipa a
		end

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'DESPATCHSUPPLIERPARTY', 0,'PARTICIPANTID',@participantID ) 

		-- se abbiamo il participant id singolo blocchiamo il campo
		IF @participantID <> ''
		BEGIN
			
			INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
								   values ( @Id, 'DESPATCHSUPPLIERPARTY', 0,'Not_Editable', ' PARTICIPANTID ' )

		END

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'SELLERSUPPLIERPARTY', 0,'PartyName', @ragSoc) 

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'SELLERSUPPLIERPARTY', 0,'PartyIdentification_ID', @cf) 

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'DESPATCHSUPPLIERPARTY', 0,'PartyName', @ragSoc) 

		-- da collaudo è emerso che IC non vuole più i campi "Tipo Identificativo EndPoint" e "Identificativo (CF/PIVA/IPA)" per l'area 'mittente'
		--INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
		--				   values ( @Id, 'DESPATCHSUPPLIERPARTY', 0,'PartyIdentification_ID', @cf) 


		IF @aziStatoLeg = 'M-1-11-ITA'
		BEGIN
			
			INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'DESPATCHSUPPLIERPARTY', 0,'PostalAddress_Country', 'IT') 

		END

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'DESPATCHSUPPLIERPARTY', 0,'PostalAddress_CityName', @aziCitta) 

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'DESPATCHSUPPLIERPARTY', 0,'PostalAddress_PostalZone', @aziCap) 

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'DESPATCHSUPPLIERPARTY', 0,'PostalAddress_StreetName', @aziIndirizzo) 

	end
	else
	begin
		if @errore = ''
			set @errore = 'Effettuare prima l''iscrizione a NoTI-ER'
	end
	

	if @Errore=''
	begin
		select @Id as id , @Errore as Errore
	end
	else
	begin
		select 'Errore' as id , @Errore as Errore
	end


END








GO
