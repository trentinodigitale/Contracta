USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_TERMINA_PROGRAMMAZIONE_FOR_BANDO_PROGRAMMAZIONE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD2_TERMINA_PROGRAMMAZIONE_FOR_BANDO_PROGRAMMAZIONE]  	( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON;

	declare @Errore as nvarchar(2000)
	declare @Id as INT
	declare @sql nvarchar(max)
	declare @ListColumn nvarchar(max)
	declare @modello as nvarchar(max)

	set @id = null


	--VERIFICO SE IL BANDO E' NELLO STATO GIUSTO PER FARE ANALISI
	select @id = id 
		from ctl_doc with(nolock) 
			where id=@idDoc and tipodoc = 'BANDO_PROGRAMMAZIONE' and deleted = 0  and 
				StatoFunzionale not in ('Completato')

	if @id is null
	BEGIN		

		-- aggiungo la cronologia al BANDO_PROGRAMMAZIONE
		insert into CTL_ApprovalSteps ( [APS_Doc_Type] , [APS_ID_DOC] , [APS_State] , [APS_Note] , [APS_UserProfile] , [APS_IdPfu] , [APS_Date]) 
			values( 'BANDO_PROGRAMMAZIONE' , @idDoc ,    'Creato' ,  'Avvio Termina Richiesta' ,   dbo.GetUserRoleDefalut( @IdUser  ) , @IdUser , getdate() ) 

		--PER OGNI ENTRATA SULLA Document_Programmazione_Dettagli crea una PROGRAMMAZIONE
		--COdice_cui esiste un solo documento di PROGRAMMAZIONE
		insert into CTL_DOC ( IdPfu ,Titolo, NumeroDocumento , TipoDoc , StatoFunzionale)
			select @IdUser , 'Programmazione:' + CODICE_CUI ,CODICE_CUI , 'PROGRAMMAZIONE', 'DA_PROGRAMMARE'
				from Document_Programmazione_Dettagli with(nolock) where IdHeader=@idDoc
					and TipoDoc='BANDO_PROGRAMMAZIONE'
		
		-- copio i prodotti dai questionari
		set @ListColumn = dbo.GetColumnTableList ('Document_Programmazione_Dettagli' , 'Id,TipoDoc,IdHeader')
		set @sql  = 'insert into Document_Programmazione_Dettagli ( TipoDoc , idheader , ' + @ListColumn + ' ) 
			select ''PROGRAMMAZIONE'' , ' + cast ( @idDoc as varchar (20)) + ' , ' + @ListColumn + '
				from Document_Programmazione_Dettagli where tipodoc =''BANDO_PROGRAMMAZIONE'' and idheader in (' + cast ( @idDoc as varchar (20)) + ') 
				order by id '
		exec( @sql )

		--aggiorno il riferimento con la ctl_doc
		update D set IdHeader=C.id
			from CTL_DOC C
				inner join Document_Programmazione_Dettagli D on D.TipoDoc='PROGRAMMAZIONE' and D.CODICE_CUI=C.NumeroDocumento
			where C.idpfu=@IdUser and C.StatoFunzionale='DA_PROGRAMMARE' and C.TipoDoc='PROGRAMMAZIONE'
		
		-- ASSOCIO IL MODELLO PER LA RAPPRESENTAZIONE DEI DETTAGLI
		SELECT 
			@modello = 'MODELLO_BASE_PROGRAMMAZIONE_' + TIPObando + '_Fabb_questionario' 
			from Document_Bando with(nolock)
				where idheader = @idDoc
		
		INSERT INTO CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			SELECT C.id , 'PRODOTTI' , @modello
				from CTL_DOC C with(nolock)
				where idpfu=@IdUser  and C.StatoFunzionale='DA_PROGRAMMARE' and C.TipoDoc='PROGRAMMAZIONE'
		
		--SCHEDULO INVIO PER QUESTI DOCUMENTI
		insert into CTL_Schedule_Process ( iddoc,IdUser,DPR_DOC_ID,DPR_ID)
			select Id,@IdUser,'PROGRAMMAZIONE','SEND'
				from CTL_DOC C with(nolock)
					where idpfu=@IdUser  and C.StatoFunzionale='DA_PROGRAMMARE' and C.TipoDoc='PROGRAMMAZIONE'
		update CTL_DOC set StatoFunzionale = 'InLavorazione'	
			where idpfu=@IdUser and  StatoFunzionale='DA_PROGRAMMARE' and TipoDoc='PROGRAMMAZIONE'
		
		--CAMBIO LO STATO AL BANDO_PROGRAMMAZIONE
		update ctl_doc set StatoFunzionale='Concluso' where Id=@idDoc
	END

		
		

	END
GO
