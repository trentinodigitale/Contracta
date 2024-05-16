USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ESPD_SET_FIELD_VALUE_FROM_PATH]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[ESPD_SET_FIELD_VALUE_FROM_PATH] 
( 
		@idDoc  int , 
		@pathXML varchar(500), 
		@Valore nvarchar(max),
		@iterabile int = 0,				-- opzionale. indica se il campo indicato è terabile ( 0 no, 1 si )
		@iterazione varchar(100) = ''	-- opzionale. indice dell'iterazione. base 1
)
AS
BEGIN

	IF isnull(@iterazione,'') = '' 
	BEGIN
		set @iterazione = '1'
	END

	IF @iterabile = 0
	BEGIN

		set @pathXML = @pathXML + '(' + @iterazione + ',%)'

		-- SE IL CAMPO ESISTE, FACCIO UN UPDATE. ALTRIMENTI DEVO INSERIRE IL NUOVO CAMPO ED INCREMENTARE IL NUMERO DELLE ITERAZIONI. QUESTO SOLO SE IL CAMPO è ITERABILE

		UPDATE B
				set value = @Valore
			FROM ctl_doc_value a with(nolock)
					left join ctl_doc_value b with(nolock) ON b.IdHeader = a.IdHeader and b.DSE_ID = 'MODULO' and b.DZT_Name = a.DZT_Name
			WHERE a.IdHeader = @idDoc and a.DSE_ID = 'UUID' and a.Value like @pathXML 

	END
	ELSE
	BEGIN

		------------------------------------------------------------------------------------------------------------
		-- PER AVERE L'XPATH COMPLETO DI ITERAZIONI RECUPERO QUELLA NUMERO 1 ( SEMPRE PRESENTE APPLICATIVAMENTE ) --
		------------------------------------------------------------------------------------------------------------

		declare @xPathBase		varchar(1000)	--EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/FirstName(1,1,1)
		declare @dztNameBase	varchar(1000)	--MOD_C_2_1_FLD_G1(1)_2_R1
		declare @dztNameNew		varchar(1000)

		set @xPathBase = ''
		set @dztNameBase = ''
		set @dztNameNew = ''
		set @pathXML = @pathXML + '(1,%)' 
		
		select top 1 @xPathBase = [Value],
					 @dztNameBase = DZT_Name
			FROM ctl_doc_value a with(nolock)
			WHERE a.IdHeader = @idDoc and a.DSE_ID = 'UUID' and a.Value like @pathXML 

		IF @xPathBase <> ''
		BEGIN

			-- CREO IL PATH XML CORRETTO IN FUNZIONE DELL'ITERAZIONE PASSATA E DEL PATH BASE
			set @pathXML = replace(@xPathBase, '(1,', '(' + @iterazione + ',' )
			set @dztNameNew = replace(@dztNameBase, '(1)', '(' + @iterazione + ')' )

			IF EXISTS ( select idrow FROM ctl_doc_value a with(nolock) WHERE a.IdHeader = @idDoc and a.DSE_ID = 'UUID' and a.Value = @pathXML  )
			BEGIN

				UPDATE B
						set value = @Valore
					FROM ctl_doc_value a with(nolock)
							left join ctl_doc_value b with(nolock) ON b.IdHeader = a.IdHeader and b.DSE_ID = 'MODULO' and b.DZT_Name = a.DZT_Name
					WHERE a.IdHeader = @idDoc and a.DSE_ID = 'UUID' and a.Value = @pathXML  
			
			END
			ELSE
			BEGIN

				-- SE L'ITERAZIONE PASSATA NON E' PRESENTE DEVO CREARE IL RECORD PER L'UUID E PER IL MODULO

				INSERT INTO CTL_DOC_VALUE( IdHeader, DSE_ID, DZT_Name, value ) VALUES ( @idDoc, 'UUID', @dztNameNew, @pathXML )
				INSERT INTO CTL_DOC_VALUE( IdHeader, DSE_ID, DZT_Name, value ) VALUES ( @idDoc, 'MODULO', @dztNameNew, @Valore )

			END

		END



	END

	

	
	----------------------------------------------
	-- DATI DI RESPONSE/TESTATA DA RECUPERARE :  --
	----------------------------------------------

	--DATI DEL RAPPRESENTANTE LEGALE		( ITERABILE )

	--	ok EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/FirstName                          
	--	ok EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/FamilyName                        
	--	ok EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/BirthDate
	--	ok EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/BirthplaceName

	--	ok EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/Contact/Telephone
	--	ok EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/Contact/ElectronicMail
	--	ok EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/ResidenceAddress/CityName
	--	ok EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/ResidenceAddress/PostalZone

	--	ok EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/ResidenceAddress/AddressLine/Line
	--	ok EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/ResidenceAddress/Country/IdentificationCode
	--	ok EconomicOperatorParty/Party/PowerOfAttorney/AgentParty/Person/ResidenceAddress/Country/Name

	-- INFO AZIENDALI

	--      ok          EconomicOperatorParty/QualifyingParty/EmployeeQuantity                      Numero di dipendenti
	--      ok          EconomicOperatorParty/QualifyingParty/FinancialCapability/ValueAmount       Fatturato generale dell’o.e.

	--      ok          EconomicOperatorParty/Party/WebsiteURI                                      sito web dell’oe
	--	    ok          EconomicOperatorParty/Party/IndustryClassificationCode                      Utilizzato per indicare se l'azienda è una micro, piccola, media o grande impresa.
	--						se si mettere SME, ALTRIMENTI METTERE LARGE

	--	campo a video opzionale e con un secondo campo alternativo ( ma opzionale ) e privo dell'informazione sull'indicatore usato
	--		ok	  : EconomicOperatorParty/Party/PartyIdentification/ID                          Partita IVA

	--		ok		  EconomicOperatorParty/Party/PartyName/Name                                  Ragione Sociale

	-- SEDE LEGALE
	--    ok            EconomicOperatorParty/Party/PostalAddress/StreetName
	--    ok            EconomicOperatorParty/Party/PostalAddress/CityName
	--    non gestito            EconomicOperatorParty/Party/PostalAddress/PostalZone
	--     ok           EconomicOperatorParty/Party/PostalAddress/Country/IdentificationCode
	--                EconomicOperatorParty/Party/PostalAddress/Country/Name

	--CONTATTO AZIENDALE E/O PERSONA FISICA DI RIFERIMENTO
	--    ok            EconomicOperatorParty/Party/Contact/Name
	--    ok            EconomicOperatorParty/Party/Contact/Telephone
	--    ok            EconomicOperatorParty/Party/Contact/ElectronicMail

	--RUOLO DELL’OPERATORE ECONOMICO NELL’OFFERTA
	--    ok            EconomicOperatorParty/EconomicOperatorRole/RoleCode                        

END

GO
