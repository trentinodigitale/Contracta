USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CATALOGO_MEA_CREATE_FROM_MODELLO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[OLD2_CATALOGO_MEA_CREATE_FROM_MODELLO] 
	( @idDoc int  , @idUser int )
AS
BEGIN


	BEGIN TRAN

	SET NOCOUNT ON	-- set nocount ON è importantissimo

	DECLARE @newId INT
	set @newId = -1
	DECLARE @idModello INT
	DECLARE @idalbo INT
	DECLARE @idAzi INT
	DECLARE @idEnte INT


	-- recupero dalla tabella di appoggio il modello_albo da collegare / aprire
	select top 1 @idModello = dbo.GetPos( A , '_' , 1 ) , @idalbo = dbo.GetPos( A , '_' , 2 ) from CTL_Import with(nolock) where idPfu = @idUser

	select @idAzi =pfuidazi from ProfiliUtente with(nolock) where IdPfu = @idUser

	-- verifico se per l'albo e modello esiste già un documento in lavorazione, nel caso lo riapre
	select top 1 @newId = id from CTL_DOC with(nolock) where tipodoc = 'CATALOGO_MEA' and Azienda = @idAzi and LinkedDoc = @idalbo and IdDoc = @idModello and Deleted = 0 order by Id desc

	if @newId = -1 
	begin

		select @idEnte = azienda from CTL_DOC with(nolock) where Id = @idalbo

		-- creo il documento per il nuovo catalogo
		insert into CTL_DOC (  idpfu, TipoDoc, StatoDoc, Data, Protocollo, PrevDoc, Deleted,
								fascicolo,linkedDoc,richiestaFirma, 
								protocolloRiferimento, strutturaAziendale,
								Body, Azienda, DataScadenza, Destinatario_Azi, 
								Destinatario_User, JumpCheck , IdDoc , idPfuInCharge
								, SIGN_LOCK , SIGN_HASH
							)
			select @idUser as idpfu , 'CATALOGO_MEA' as Tipodoc , 'Saved' as StatoDoc, getdate() as Data, '' as Protocollo, 0 as PrevDoc, 0 as Deleted 
					,Fascicolo, id as Linkeddoc , '' as richiestaFirma, 
					protocollo as protocolloRiferimento ,'' as  strutturaAziendale
					,'' as Body, @idAzi as Azienda , NULL as DataScadenza, @idEnte as Destinatario_Azi, 
					NULL as Destinatario_User, '' as JumpCheck, @idModello as IdDoc, @idUser as idPfuInCharge
					,  '0'  as SIGN_LOCK, '' as SIGN_HASH
				from CTL_DOC with(nolock) 
				where Id = @idalbo 



		IF @@ERROR <> 0 
		BEGIN
			raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
			rollback tran
			return 99
		END

		set @newId = @@identity

		-----------------------------------------------------
		--Copio il modello per specializzare il filtro sulle classi con l'intersezione di classi fra modello e abilitazione
		-----------------------------------------------------
		declare @NomeModello varchar(1000)
		declare @NomeModelloNew varchar(1000)

		select  @NomeModello = 'MODELLI_MEA_' + Titolo + '_Mod_Modello'
			from CTL_DOC with(nolock) 
			where Id = @idModello

		set @NomeModelloNew = @NomeModello + '_' + CAST( @newId as varchar(100))

		insert into CTL_Models  ( [MOD_ID], [MOD_Name], [MOD_DescML], [MOD_Type], [MOD_Sys], [MOD_help], [MOD_Param], [MOD_Module], [MOD_Template] )
			select  @NomeModelloNew as [MOD_ID], @NomeModelloNew as [MOD_Name], [MOD_DescML], [MOD_Type], [MOD_Sys], [MOD_help], [MOD_Param], [MOD_Module], [MOD_Template]
				from CTL_Models with(nolock) 
				where [MOD_ID] = @NomeModello

		insert into CTL_ModelAttributes ( [MA_MOD_ID], [MA_DZT_Name], [MA_DescML], [MA_Pos], [MA_Len], [MA_Order], [DZT_Type], [DZT_DM_ID], [DZT_DM_ID_Um], [DZT_Len], [DZT_Dec], [DZT_Format], [DZT_Help], [DZT_Multivalue], [MA_Module] )
			select @NomeModelloNew as [MA_MOD_ID], [MA_DZT_Name], [MA_DescML], [MA_Pos], [MA_Len], [MA_Order], [DZT_Type], [DZT_DM_ID], [DZT_DM_ID_Um], [DZT_Len], [DZT_Dec], [DZT_Format], [DZT_Help], [DZT_Multivalue], [MA_Module] 
				from CTL_ModelAttributes with(nolock) 
				where  [MA_MOD_ID] = @NomeModello
				order by [MA_ID]

		insert into CTL_ModelAttributeProperties ([MAP_MA_MOD_ID], [MAP_MA_DZT_Name], [MAP_Propety], [MAP_Value], [MAP_Module] ) 
			select @NomeModelloNew as [MAP_MA_MOD_ID], [MAP_MA_DZT_Name], [MAP_Propety], [MAP_Value], [MAP_Module]
				from CTL_ModelAttributeProperties 
				where [MAP_MA_MOD_ID] = @NomeModello
				order by [MAP_ID]


		-- specializzo il filtro dele classi di iscrizione
		-----------------------------------------------------------
		-- recupero le classi di iscrizione dell'azienda utente prese dall'ultima conferma
		-----------------------------------------------------------
		declare @ClasseIscriz				varchar(max)	
		set @ClasseIscriz = ''
		select @ClasseIscriz = @ClasseIscriz + Cl.Value 

			from CTL_DOC AL with (nolock)

				-- recupera l'ultima istanza approvata
				inner join CTL_DOC_Destinatari I with (nolock) on I.idHeader = AL.id and I.IdAzi = @idAzi

				-- approvazione dell'istanza dove sono presenti le classi di iscrizione valide
				inner join CTL_DOC Ap with(nolock) on Ap.LinkedDoc = I.Id_Doc and Ap.TipoDoc = 'CONFERMA_ISCRIZIONE' and Ap.Deleted = 0  

				-- recupero le classi confermate
				inner join ctl_doc_value Cl with(nolock ) on Cl.IdHeader = Ap.Id and   Cl.DZT_Name = 'ClasseIscriz' 

			where AL.id = @idalbo


		-----------------------------------------------------------
		-- esplode la selezione sulle foglie nel caso in cui sia stato consentito selezionare un ramo 
		-- le interseco con quelle del modello per restringere ulteriormente
		-----------------------------------------------------------
		set @ClasseIscriz =  dbo.ExplodeClasseIscriz( @ClasseIscriz )

		delete from CTL_ModelAttributeProperties where  MAP_MA_MOD_ID = @NomeModelloNew and  MAP_MA_DZT_Name = 'ClasseIscriz_S' and   MAP_Propety = 'Filter'
		insert into CTL_ModelAttributeProperties(MAP_MA_MOD_ID, MAP_MA_DZT_Name, MAP_Value, MAP_Propety, MAP_Module) 			
			select
					@NomeModelloNew as MAP_MA_MOD_ID, 
					'ClasseIscriz_S' as MAP_MA_DZT_Name, 
					[dbo].[GetSQL_WHERE]('ClasseIscriz_S', dbo.Intersezione_Insiemi( @ClasseIscriz , Value , '###' ) ), 
					'Filter' as MAP_Propety, 
					'MODELLI_MEA' as MAP_Module
				from CTL_DOC_Value with(nolock)
				where DZT_Name = 'ClasseIscrizFoglie'and IdHeader = @idDoc	



		-- associo il modello per la sezione prodotti
		insert into CTL_DOC_SECTION_MODEL ( [IdHeader], [DSE_ID], [MOD_Name] ) 
			select  @newId , 'PRODOTTI' , @NomeModelloNew 
				from CTL_DOC with(nolock) 
				where Id = @idModello


		-- inserisco il nome del modello per le operazioni di upload e download

		insert into CTL_DOC_VALUE ( [IdHeader], [DSE_ID], Value , [Row] , [DZT_Name]) 
			select  @newId , 'TESTATA_PRODOTTI' , @NomeModelloNew  , 0 , 'Modello'
				from CTL_DOC with(nolock) 
				where Id = @idModello

		

	end




	IF @@ERROR <> 0 
	BEGIN
		raiserror ('Errore creazione record in ctl_doc.  ', 16, 1)  --, CAST(@@ERROR AS NVARCHAR(4000)))
		rollback tran
		return 99
	END

	COMMIT TRAN

	-- rirorna l'id del documento appena creato
	select @newId as id

	return 

END




GO
