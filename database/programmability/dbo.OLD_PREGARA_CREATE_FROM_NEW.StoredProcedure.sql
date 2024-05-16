USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PREGARA_CREATE_FROM_NEW]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO








CREATE PROCEDURE [dbo].[OLD_PREGARA_CREATE_FROM_NEW] 
	( @idDoc int  , @idUser int )
AS
BEGIN

	BEGIN TRAN

		declare @newID as INT 	
		declare @APS_APC_Cod_Node as int
		declare @idAzi  as int
		declare @EnteProponente as nvarchar(200)
		declare @Lista_Enti_abilitati_RCig as varchar (4000)
		declare @Azi_Abilitata_RCig as int
	
		SET NOCOUNT ON	-- set nocount ON è importantissimo		

		

		-- recupero l'ente proponente basandomi sul compilatore
		select @idAzi = pfuidazi from profiliutente with(nolock) where idpfu = @idUser

		select top 1 @EnteProponente = DMV_COD  from GESTIONE_DOMINIO_DIREZIONE where idaz = @idAzi and dmv_deleted = 0 and dmv_level = 2 order by DMV_Father

		

		insert into CTL_DOC ( idpfu, TipoDoc, StatoDoc, Data,Caption,idPfuInCharge,Azienda  )
			
			select top 1 @idUser as idpfu ,'PREGARA' as TipoDoc ,'Saved' as StatoDoc,
				GETDATE() as Data ,'Indizione Procedura di Gara' as Caption ,@idUser as idPfuInCharge ,
					case when REL_idRow is null then mpidazimaster  else null end as Azienda
				 from marketplace with (nolock)
					left join CTL_Relations with (nolock) on REL_Type = 'PREGARA_ENTE_APPALTANTE' 
		
		set @newId=SCOPE_IDENTITY()
	
			-- aggiungo la cronologia
		insert into CTL_ApprovalSteps ( [APS_Doc_Type] , [APS_ID_DOC] , [APS_State] , [APS_Note] , [APS_UserProfile] , [APS_IdPfu] , [APS_Date],APS_IsOld) 
			values( 'PREGARA' , @newId ,    'Creato' ,  '' ,  'DIRETTORE_OPERATIVO' , @IdUser , getdate(),1 ) 	


		--Setto il work-flow caricando la CTL_ApprovalStep per PREGARA        
		--sul primo passo della cronologia metto l'idpfu dell'utente collegato
		--select * from CTL_ApprovalCycle where APC_Doc_Type='PREGARA' order by APC_Level desc
		insert into CTL_ApprovalSteps ( APS_Doc_Type,APS_ID_DOC,APS_State,APS_UserProfile,APS_IdPfu,APS_IsOld,APS_APC_Cod_Node )
			select APC_Doc_Type , @newID , '' , APC_Value , '' ,0, APC_Cod_Node
				from CTL_ApprovalCycle where APC_Doc_Type='PREGARA' order by APC_Level desc
		
		select @APS_APC_Cod_Node=MAX(APS_APC_Cod_Node) from CTL_ApprovalSteps where APS_ID_DOC=@newId and APS_Doc_Type='PREGARA'

		update CTL_ApprovalSteps 
			set APS_IdPfu=@idUser,APS_State='InCharge'--,APS_IsOld=1 
				where APS_ID_DOC=@newId and APS_APC_Cod_Node=@APS_APC_Cod_Node



		INSERT INTO CTL_DOC_Value ( IdHeader,DSE_ID,DZT_Name,Value )
			select @newID , 'NOT_EDITABLE','Not_Editable',''
		
		
		--recupero default dal parametro 
		declare @HideRichiestaCigPreGara as varchar(10)
		select @HideRichiestaCigPreGara = dbo.PARAMETRI('PREGARA_TESTATA','RichiestaCigPreGara','Hide','0',-1)

		
		--se azienda corrente non è tra gli enti abilitati setto @richiestaCIG a no
		set @Azi_Abilitata_RCig = 1
		select  @Lista_Enti_abilitati_RCig= dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1)
		if @Lista_Enti_abilitati_RCig <> '' and CHARINDEX (',' + cast(@idAzi as varchar(20)) + ',', ',' + @Lista_Enti_abilitati_RCig + ',') = 0
			set @Azi_Abilitata_RCig = 0

		--se non nascosto e l'ente è abilitato alloro lo setto a si altrimenti a no
		if @HideRichiestaCigPreGara ='0' and @Azi_Abilitata_RCig = 1
			INSERT INTO CTL_DOC_Value ( IdHeader,DSE_ID,DZT_Name,Value )
				select @newID , 'CRITERI_ECO','RichiestaCigPreGara','si_cig'
		else
			INSERT INTO CTL_DOC_Value ( IdHeader,DSE_ID,DZT_Name,Value )
				select @newID , 'CRITERI_ECO','RichiestaCigPreGara','no'

		insert into document_bando ( idheader , EnteProponente ,RupProponente) values ( @newID , @EnteProponente ,@idUser)
	

		--setto l'editabilità dei campi sul documento PREGARA_EDITABILITY
		EXEC PREGARA_EDITABILITY  @newId  , @IdUser 



		declare @noteDef varchar(max)

		-- recupero le Note di default che si vogliono per lo stato del documento se presenti
		select @noteDef = rel_valueoutput from ctl_relations with(nolock) where rel_type = 'DOCUMENT_PREGARA_DEF_NOTE_X_STATO' and REL_ValueInput like '%,InLavorazione,%'
		if @noteDef is null set @noteDef = '' 
		update CTL_DOC set Note=@noteDef , SIGN_ATTACH  = '' where  Id=@newId



	

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
