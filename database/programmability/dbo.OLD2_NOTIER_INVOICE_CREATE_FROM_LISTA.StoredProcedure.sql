USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_NOTIER_INVOICE_CREATE_FROM_LISTA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[OLD2_NOTIER_INVOICE_CREATE_FROM_LISTA] ( @IdDoc int  , @idUser int )
AS
BEGIN

	SET NOCOUNT ON

	declare @id INT
	declare @Errore as nvarchar(2000)
	declare @IdAzi as int
	declare @ragSoc as nvarchar(1000)
	declare @cf as varchar(100)
	declare @piva as varchar(100)

	declare @aziStatoLeg varchar(100)
	declare @aziCitta varchar(1000)
	declare @aziCap varchar(10)
	declare @aziIndirizzo varchar(1000)

	declare @idNoter varchar(500)

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
			,@piva = aziPartitaIVA
		from profiliutente with(nolock)
				left join aziende with(nolock) ON pfuidazi=idazi
				left join DM_Attributi d1 with(nolock) ON d1.lnk = idazi and d1.dztNome = 'IDNOTIER'
				left join DM_Attributi d2 with(nolock) ON d2.lnk = idazi and d2.dztNome = 'codicefiscale'
		where idpfu=@idUser  
	
	if @idNoter <> ''
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

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'StatoLiquidazione', '') 

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'SocioUnico', '') 

		INSERT INTO CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, value )
						   values ( @Id, 'ACCOUNTINGSUPPLIERPARTY', 0,'CapitaleSociale', '') 



	end
	else
	begin
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
