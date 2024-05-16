USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[E_FORMS_CAN29_TENDERING_PARTY]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[E_FORMS_CAN29_TENDERING_PARTY] ( @idProc int, @idPDA int , @idUser int = 0, 
														@guidOperation varchar(500), 
														@numeroLotto varchar(1000) = '',
														@idDocContrConv int = 0,
														@debug int = 0 )
AS
BEGIN

	SET NOCOUNT ON

	declare @idRowOrg INT = 0
	declare @contatore INT = 0
	declare @RTI INT = 0
	declare @RagSocRTI nvarchar(2000) = ''
	declare @PartyName nvarchar(1000) = ''
	declare @PartyIdentification varchar(100) = ''
	declare @Ruolo_Impresa varchar(100) = ''
	declare @idOfferta INT = 0
	declare @partyID varchar(10) = ''
	declare @leadIndicator varchar(10) = ''
	declare @xmlRTI nvarchar(4000) = ''

	--select * from Document_E_FORM_ORGANIZATION with(nolock) where recordType = 'aggiudicatari'

	-- prendiamo tutti gli idOfferta in modo distinto
	--select distinct idOfferta into #offerte from Document_E_FORM_ORGANIZATION a with(nolock) where a.operationGuid = @guidOperation

	create table #TENDERING_PARTY
	(
		partyID varchar(100),
		rti int null, 
		RagSocRTI nvarchar(2000) null, 
		PartyName nvarchar(1000) null, 
		PartyIdentification varchar(100) null, 
		leadIndicator varchar(10) null, 
		idOfferta int null,
		xmlRTI nvarchar(4000) null
	)

	-- associamo ad ogni offerta un tendering party id ( per ogni offerta potremmo avere N record, caso RTI )
	DECLARE curs CURSOR FAST_FORWARD FOR
		select rti, RagSocRTI, PartyName, PartyIdentification, Ruolo_Impresa, idOfferta, a.idRow
			from Document_E_FORM_ORGANIZATION a with(nolock) 
			where a.operationGuid = @guidOperation and Ruolo_Impresa = 'mandataria'
			order by a.idOfferta, a.idaziRTI

	OPEN curs 
	FETCH NEXT FROM curs INTO @RTI, @RagSocRTI, @PartyName, @PartyIdentification, @Ruolo_Impresa, @idOfferta, @idRowOrg

	WHILE @@FETCH_STATUS = 0   
	BEGIN  

		set @contatore = @contatore + 1

		set @partyID = 'TPA-' + RIGHT('0000' + CAST( @contatore AS VARCHAR(4)), 4)
		set @PartyName = LEFT( case when @RTI = 1 then @RagSocRTI else @PartyName end , 400 ) 
		set @leadIndicator = 'true' --TENDERING_PARTY_TENDERER_GROUPLEADINDICATOR
		set @xmlRTI = ''

		IF @RTI = 1
		BEGIN
			
			select @xmlRTI = @xmlRTI + '<efac:Tenderer>
                        <cbc:ID>' + PartyIdentification + '</cbc:ID>
                        <efbc:GroupLeadIndicator>false</efbc:GroupLeadIndicator>
                     </efac:Tenderer>'
				from Document_E_FORM_ORGANIZATION a with(nolock) 
				where a.operationGuid = @guidOperation and idOfferta = @idOfferta and Ruolo_Impresa <> 'mandataria'

		END

		INSERT INTO #TENDERING_PARTY( partyid, PartyName, PartyIdentification, leadIndicator, xmlRTI )
							values ( @partyID, @PartyName, @PartyIdentification, @leadIndicator, @xmlRTI )

		update Document_E_FORM_ORGANIZATION
				set TENDERING_PARTY_ID = @partyID
			where idrow = @idRowOrg

		FETCH NEXT FROM curs INTO @RTI, @RagSocRTI, @PartyName, @PartyIdentification, @Ruolo_Impresa, @idOfferta, @idRowOrg

	END  

	CLOSE curs   
	DEALLOCATE curs

	select  partyID as TENDERING_PARTY_ID,
			PartyName  as TENDERING_PARTY_NAME,
			PartyIdentification as TENDERING_PARTY_TENDERER_ID,
			leadIndicator as TENDERING_PARTY_TENDERER_GROUPLEADINDICATOR,
			xmlRTI as TENDERING_PARTY_NO_ENCODE_TENDERER_RTI
		from #TENDERING_PARTY
		order by partyID

END
GO
