USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[AZIENDA_ALLINEA_ANAGRAFICA]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[AZIENDA_ALLINEA_ANAGRAFICA] 
		 (
			 @idpfu int , 
			 @idAziSource int ,
			-- @idDocToLink int ,
			-- @TipoDocLinked varchar(100) , 
			 @Descrizione nvarchar(max)
		 )
AS
BEGIN

	-- Al termine della registrazione se il CF dell'OE registrato esiste anche come Ente occorre creare documento di variazione dati per lo storico della controparte.
	-- Facciamo una stored AZIENDA_ALLINEA_ANAGRAFICA( idpfu int , idAziSource as int , idDocToLink int , TipoDocLinked varchar(100) , Descrizione nvarchar(max) ) che invochiamo.
	-- La stored preso l'idAzi passato recupera il CF
	--   Per ogni azienda con stesso CF ma diverso id azi
	--   verifico se uno dei dati è cambiato ( RagioneSociale , Forma giuridica , indirizzo , comune , provincia , CAP , Mail Pec )
	--   crea nuovo documento del tipo ALLINEAMENTO_DATI_AZI che popolo con tutti i dati di riferimento evidenziando i dati modificati
	--   aggiorno i dati dell'azienda partendo dalla sorgente

	-- (tale documento va visto nello storico variazioni dell'azienda modificata)
	-- Fa eccezione la firma olografa, in quel caso essendo previsto il giro di verifica si adeguano i dati dell'altra azienda alla conferma dell'ente.

	SET NOCOUNT ON;

	DECLARE @idAzi INT
	DECLARE @newID INT

	DECLARE @RagSocNew nvarchar(4000)
	DECLARE @RagSocNewNorm nvarchar(4000)
	DECLARE @RagSocOLD nvarchar(4000)

	DECLARE @NagiNew INT
	DECLARE @NagiOLD INT

	DECLARE @indirizzoNew nvarchar(4000)
	DECLARE @indirizzoOLD nvarchar(4000)

	DECLARE @comuneNEW nvarchar(4000)
	DECLARE @comuneTecNEW nvarchar(4000)
	DECLARE @comuneOLD nvarchar(4000)

	DECLARE @provinciaNEW nvarchar(4000)
	DECLARE @provinciaTecNEW nvarchar(4000)
	DECLARE @provinciaOLD nvarchar(4000)

	DECLARE @capNEW nvarchar(4000)
	DECLARE @capOLD nvarchar(4000)

	DECLARE @mailpecNEW nvarchar(4000)
	DECLARE @mailpecOLD nvarchar(4000)

	DECLARE @cfNEW nvarchar(4000)
	DECLARE @cfOLD nvarchar(4000)

	DECLARE @pivaNEW nvarchar(4000)
	DECLARE @pivaOLD nvarchar(4000)

	DECLARE @campiVariati nvarchar(4000)

	set @campiVariati = ''
	set @newID = -1





	select @RagSocNEW = isnull(azi.aziRagioneSociale,'') ,
			   @NagiNEW = isnull(azi.aziIdDscFormaSoc,-1),
			   @indirizzoNEW = isnull(azi.aziIndirizzoLeg,'') ,
			   @comuneNEW = isnull(azi.aziLocalitaLeg,'') ,
			   @provinciaNEW = isnull(azi.aziProvinciaLeg,'') ,
			   @capNEW = isnull(azi.aziCAPLeg,'') ,
			   @mailpecNEW = isnull(azi.aziE_Mail ,''),
			   @RagSocNewNorm = isnull(azi.aziRagioneSocialeNorm,''),
			   @comuneTecNEW = isnull(azi.aziLocalitaLeg2,''),
			   @provinciaTecNEW = isnull(azi.aziProvinciaLeg2,''),
			   @pivaNEW = isnull(azi.aziPartitaIVA,''),
			   @cfnew = isnull(attr.vatValore_FT,'')
			from aziende azi with(nolock) 
					INNER JOIN DM_Attributi attr with(nolock) ON attr.lnk = azi.idazi and attr.dztNome = 'codicefiscale'
			where idazi = @idAziSource



	declare @Num_Enti int
	declare @Num_OE int

	--- LA MODIFICA VIENE ESEGUITA SOLAMENTE SE ESISTE UNA SOLA AZIENDA ENTE ED UN SOLO FORNITORE CON LO STESSO CODICE FISCALE
	SELECT @Num_Enti = sum( case when aziAcquirente > 0 then 1 else 0 end )
		  , @Num_OE = sum( case when aziVenditore > 0 then 1 else 0 end )
		from aziende azi with(nolock) 
			INNER JOIN DM_Attributi attr with(nolock) ON attr.lnk = azi.idazi and attr.dztNome = 'codicefiscale'
		where isnull(attr.vatValore_FT,'') = @cfnew 

	IF @Num_Enti = 1 AND @Num_OE = 1
	begin


		declare CurAziende Cursor static for  
			select azi2.IdAzi 
				from aziende azi with(nolock) 
						left join dm_attributi dm with(nolock) ON dm.lnk = azi.idazi and dm.dztNome = 'codicefiscale' 
							--stesso codice fiscale ma diverso idAzi
						left join dm_attributi dm2 with(nolock) ON dm2.dztNome = 'codicefiscale' and dm2.vatValore_FT = dm.vatValore_FT and dm.lnk <> dm2.lnk 
						left join aziende azi2 with(nolock) ON dm2.lnk = azi2.idazi and azi2.aziDeleted = 0
				where azi.idazi = @idAziSource

		open CurAziende

		FETCH NEXT FROM CurAziende  INTO @idAzi

		WHILE @@FETCH_STATUS = 0
		BEGIN

			select @RagSocOLD = isnull(azi.aziRagioneSociale,'') ,
				   @NagiOLD = isnull(azi.aziIdDscFormaSoc,-1),
				   @indirizzoOLD = isnull(azi.aziIndirizzoLeg,''),
				   @comuneOLD = isnull(azi.aziLocalitaLeg,''),
				   @provinciaOLD = isnull(azi.aziProvinciaLeg,''),
				   @capOLD = isnull(azi.aziCAPLeg,''),
				   @mailpecOLD = isnull(azi.aziE_Mail ,''),
				   @pivaOLD = isnull(azi.aziPartitaIVA,''),
				   @cfOLD = isnull(attr.vatValore_FT,'')
				from aziende azi with(nolock) 
						INNER JOIN DM_Attributi attr with(nolock) ON attr.lnk = azi.idazi and attr.dztNome = 'codicefiscale'
				where idazi = @idAzi 


			IF  ltrim(rtrim(upper(@RagSocNew))) <> ltrim(rtrim(upper(@RagSocOLD))) OR
				ltrim(rtrim(upper(@indirizzoNEW))) <> ltrim(rtrim(upper(@indirizzoOLD))) OR
				ltrim(rtrim(upper(@comuneNEW))) <> ltrim(rtrim(upper(@comuneOLD))) OR
				ltrim(rtrim(upper(@provinciaNEW))) <> ltrim(rtrim(upper(@provinciaOLD))) OR
				ltrim(rtrim(upper(@capNEW))) <> ltrim(rtrim(upper(@capOLD))) OR
				ltrim(rtrim(upper(@mailpecNEW))) <> ltrim(rtrim(upper(@mailpecOLD))) OR
				ltrim(rtrim(upper(@pivaNEW))) <> ltrim(rtrim(upper(@pivaOLD))) OR	
				ltrim(rtrim(upper(@cfNEW))) <> ltrim(rtrim(upper(@cfOLD))) OR @NagiNEW <> @NagiOLD
			BEGIN
			
				UPDATE AZIENDE
					SET aziRagioneSociale = @RagSocNew
						,aziRagioneSocialeNorm = @RagSocNewNorm
						,aziIdDscFormaSoc = @NagiNew 
						,aziIndirizzoLeg = @indirizzoNew
						,aziLocalitaLeg = @comuneNEW 
						,aziLocalitaLeg2 = @comuneTecNEW 
						,aziProvinciaLeg = @provinciaNEW 
						,aziProvinciaLeg2 = @provinciaTecNEW 
						,aziCAPLeg = @capNEW 
						,aziE_Mail = @mailpecNEW 
						,aziPartitaIVA = @pivaNEW 
				WHERE idazi = @idAzi 

				UPDATE DM_Attributi 
					set vatValore_FT = @cfNEW
						,vatValore_FV = @cfNEW
					where lnk = @idAzi and dztNome = 'codicefiscale'

				IF  ltrim(rtrim(upper(@RagSocNew))) <> ltrim(rtrim(upper(@RagSocOLD)))
				BEGIN
					set @campiVariati = 'aziRagioneSociale'
				END

				IF ltrim(rtrim(upper(@indirizzoNEW))) <> ltrim(rtrim(upper(@indirizzoOLD))) 
				BEGIN
					set @campiVariati = @campiVariati + ',aziIndirizzoLeg'
				END

				IF ltrim(rtrim(upper(@comuneNEW))) <> ltrim(rtrim(upper(@comuneOLD)))
				BEGIN
					set @campiVariati = @campiVariati + ',aziLocalitaLeg'
				END

				IF ltrim(rtrim(upper(@provinciaNEW))) <> ltrim(rtrim(upper(@provinciaOLD)))
				BEGIN
					set @campiVariati = @campiVariati + ',aziProvinciaLeg'
				END

				IF ltrim(rtrim(upper(@capNEW))) <> ltrim(rtrim(upper(@capOLD)))
				BEGIN
					set @campiVariati = @campiVariati + ',aziCAPLeg'
				END

				IF ltrim(rtrim(upper(@mailpecNEW))) <> ltrim(rtrim(upper(@mailpecOLD)))
				BEGIN
					set @campiVariati = @campiVariati + ',aziE_Mail'
				END

				IF @NagiNEW <> @NagiOLD
				BEGIN
					set @campiVariati = @campiVariati + ',aziIdDscFormaSoc'
				END

				IF  ltrim(rtrim(upper(@cfNEW))) <> ltrim(rtrim(upper(@cfOLD)))
				BEGIN
					set @campiVariati = ',codicefiscale'
				END
			
				IF  ltrim(rtrim(upper(@pivaNEW))) <> ltrim(rtrim(upper(@pivaOLD)))
				BEGIN
					set @campiVariati = ',aziPartitaIVA'
				END
			
				-- CREO IL DOCUMENTO DI VARIAZIONE
				INSERT INTO CTL_DOC ( TipoDoc, idPfu, Azienda,StatoDoc,Data, Deleted,Body,Note, DataInvio, StatoFunzionale, Titolo )
					VALUES ( 'ALLINEAMENTO_DATI_AZI',@idpfu ,@idAzi,  'Sended', getdate(), 0, @Descrizione , @campiVariati, getdate(), 'Inviato', 'Variazione anagrafica' )

				SET @newID = SCOPE_IDENTITY()

				INSERT INTO CTL_DOC_Value ( idHeader, DSE_ID, [Row], DZT_Name, Value ) 
					VALUES ( @newID, 'DATI', 0, 'aziRagioneSociale', @RagSocNew )

				INSERT INTO CTL_DOC_Value ( idHeader, DSE_ID, [Row], DZT_Name, Value ) 
					VALUES ( @newID, 'DATI', 0, 'aziIndirizzoLeg', @indirizzoNEW )

				INSERT INTO CTL_DOC_Value ( idHeader, DSE_ID, [Row], DZT_Name, Value ) 
					VALUES ( @newID, 'DATI', 0, 'aziLocalitaLeg', @comuneNEW )

				INSERT INTO CTL_DOC_Value ( idHeader, DSE_ID, [Row], DZT_Name, Value ) 
					VALUES ( @newID, 'DATI', 0, 'aziProvinciaLeg', @provinciaNEW )

				INSERT INTO CTL_DOC_Value ( idHeader, DSE_ID, [Row], DZT_Name, Value ) 
					VALUES ( @newID, 'DATI', 0, 'aziCAPLeg', @capNEW )

				INSERT INTO CTL_DOC_Value ( idHeader, DSE_ID, [Row], DZT_Name, Value ) 
					VALUES ( @newID, 'DATI', 0, 'aziE_Mail', @mailpecNEW )

				INSERT INTO CTL_DOC_Value ( idHeader, DSE_ID, [Row], DZT_Name, Value ) 
					VALUES ( @newID, 'DATI', 0, 'aziIdDscFormaSoc', @NagiNEW )

				INSERT INTO CTL_DOC_Value ( idHeader, DSE_ID, [Row], DZT_Name, Value ) 
					VALUES ( @newID, 'DATI', 0, 'Body', @Descrizione )

				INSERT INTO CTL_DOC_Value ( idHeader, DSE_ID, [Row], DZT_Name, Value ) 
					VALUES ( @newID, 'DATI', 0, 'codicefiscale', @cfNEW )

				INSERT INTO CTL_DOC_Value ( idHeader, DSE_ID, [Row], DZT_Name, Value ) 
					VALUES ( @newID, 'DATI', 0, 'aziPartitaIVA', @pivaNEW )

				-- Schedulo il processo ALLINEAMENTO_DATI_AZI-PROTOCOLLA per generare un protocollo per il documento appena creato
				INSERT INTO CTL_Schedule_Process ( IdDoc, IdUser, DPR_DOC_ID, DPR_ID )
					VALUES ( @newID , @idPfu , 'ALLINEAMENTO_DATI_AZI' , 'PROTOCOLLA' )

			END

			FETCH NEXT FROM CurAziende  INTO @idAzi

		END

		CLOSE CurAziende
		DEALLOCATE CurAziende

	end
END





GO
