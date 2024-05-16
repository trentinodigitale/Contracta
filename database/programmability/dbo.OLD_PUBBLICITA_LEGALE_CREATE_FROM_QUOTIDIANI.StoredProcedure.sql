USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PUBBLICITA_LEGALE_CREATE_FROM_QUOTIDIANI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[OLD_PUBBLICITA_LEGALE_CREATE_FROM_QUOTIDIANI]
	( @idDoc int  , @idUser int )
AS
BEGIN

	BEGIN TRAN

		declare @newID as INT 	
		declare @APS_APC_Cod_Node as int
		declare @idAzi  as int
		declare @EnteProponente as nvarchar(200)

	
	
		SET NOCOUNT ON	-- set nocount ON è importantissimo		


		-- recupero l'ente proponente basandomi sul compilatore
		select @idAzi = pfuidazi from profiliutente with(nolock) where idpfu = @idUser

		select top 1 @EnteProponente = DMV_COD  from GESTIONE_DOMINIO_DIREZIONE where idaz = @idAzi and dmv_deleted = 0 and dmv_level = 2 order by DMV_Father


		insert into CTL_DOC ( idpfu, TipoDoc, StatoDoc, Data,Caption,idPfuInCharge,Azienda,JumpCheck  )
			select @idUser,'PUBBLICITA_LEGALE','Saved',GETDATE(),'Richiesta di Preventivo',@idUser,@idAzi, 'QUOTIDIANI' 
		
			
		
		set @newId=SCOPE_IDENTITY()
	
		
		--creo il documento nella tabella Document_RicPrevPubblic
		insert into Document_RicPrevPubblic (idheader,FAX,NumCaratteri,RigoLungo,NumRighe,Pratica,MandatoPagDett) values (@newID,'',0,0,0,'','no')


		-- aggiungo la cronologia
		insert into CTL_ApprovalSteps ( [APS_Doc_Type] , [APS_ID_DOC] , [APS_State] , [APS_Note] , [APS_UserProfile] , [APS_IdPfu] , [APS_Date],APS_IsOld) 
			values( 'PUBBLICITA_LEGALE' , @newId ,    'Creato' ,  '' ,  'DIRETTORE_OPERATIVO' , @IdUser , getdate(),1 ) 	


		--Setto il work-flow caricando la CTL_ApprovalStep per PREGARA        
		--sul primo passo della cronologia metto l'idpfu dell'utente collegato
		--select * from CTL_ApprovalCycle where APC_Doc_Type='PREGARA' order by APC_Level desc
		insert into CTL_ApprovalSteps ( APS_Doc_Type,APS_ID_DOC,APS_State,APS_UserProfile,APS_IdPfu,APS_IsOld,APS_APC_Cod_Node,APS_Date )
			select 'PUBBLICITA_LEGALE' , @newID , '' , APC_Value , '' ,0, APC_Cod_Node, null
				from CTL_ApprovalCycle where APC_Doc_Type='PUBBLICITA_LEGALE_QUOTIDIANI' order by APC_Level desc
		
		select @APS_APC_Cod_Node=MAX(APS_APC_Cod_Node) from CTL_ApprovalSteps where APS_ID_DOC=@newId and APS_Doc_Type='PUBBLICITA_LEGALE'

		update CTL_ApprovalSteps 
			set APS_IdPfu=@idUser,APS_State='InCharge',APS_Date=getdate()--,APS_IsOld=1 
				where APS_ID_DOC=@newId and APS_APC_Cod_Node=@APS_APC_Cod_Node


		INSERT INTO CTL_DOC_Value ( IdHeader,DSE_ID,DZT_Name,Value )
			select @newID , 'CRITERI_ECO','RupProponente', @idUser


		INSERT INTO CTL_DOC_Value ( IdHeader,DSE_ID,DZT_Name,Value )
			select @newID , 'NOT_EDITABLE','Not_Editable',''

		--insert into document_bando ( idheader , EnteProponente ,RupProponente) values ( @newID , @EnteProponente ,@idUser)
	

		--setto l'editabilità dei campi sul documento PREGARA_EDITABILITY
		EXEC PUBBLICITA_LEGALE_EDITABILITY  @newId  , @IdUser 



		declare @noteDef varchar(max)

		-- recupero le Note di default che si vogliono per lo stato del documento se presenti
		--select @noteDef = rel_valueoutput from ctl_relations with(nolock) where rel_type = 'DOCUMENT_PREGARA_DEF_NOTE_X_STATO' and REL_ValueInput like '%,InLavorazione,%'
		--if @noteDef is null set @noteDef = '' 
		--update CTL_DOC set Note=@noteDef , SIGN_ATTACH  = '' where  Id=@newId



		--se la richiesta di pubblicita arriva da un pregara eredito i dati 
		if exists (select * from ctl_doc with (nolock) where @iddoc=id and tipodoc='PREGARA')
		begin
				declare @protbando as varchar (50)
				declare @fascicolo as varchar (50)
				declare @tipoappalto as varchar (50)
				declare @importo as int 
				declare @pratica as varchar (50)

				select		ProtocolloBando=@protbando, fascicolo=@fascicolo, TipoAppalto=@tipoappalto , ImportoBaseAsta=@importo
					from ctl_doc WITH (NOLOCK)
						inner join document_bando  WITH (NOLOCK) on ctl_doc.id = document_bando.idheader
					where @iddoc=id and tipodoc='PREGARA'

			
				update CTL_DOC set  fascicolo=@fascicolo, LinkedDoc=@iddoc where id=@newID
				update Document_RicPrevPubblic set Protocol=@protbando, Tipologia=@tipoappalto, Importo=@importo , Pratica=@pratica where IdHeader=@newID
					
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
