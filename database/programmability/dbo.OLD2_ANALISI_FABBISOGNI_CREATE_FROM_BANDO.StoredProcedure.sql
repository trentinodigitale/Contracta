USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_ANALISI_FABBISOGNI_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[OLD2_ANALISI_FABBISOGNI_CREATE_FROM_BANDO] 	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Errore as nvarchar(2000)
	declare @Id as INT
	declare @sql nvarchar(max)
	declare @ListColumn nvarchar(max)

	set @id = null
	set @Errore = ''


	select @id = id from ctl_doc where tipodoc = 'ANALISI_FABBISOGNI' and deleted = 0  and linkeddoc = @idDoc

	if @id is null
	begin

		-- controllo che l'utente appartenza alla lista dei riferimentio al compilatore 

		-- creo la il documento di analisi
		insert into CTL_DOC ( [LinkedDoc] , [IdPfu], idPfuInCharge,[TipoDoc],[Data],[Titolo],[Azienda],[StrutturaAziendale],[ProtocolloRiferimento], [Fascicolo] ) 
			select id as [LinkedDoc] ,@IdUser as  [IdPfu], @IdUser , 'ANALISI_FABBISOGNI' as [TipoDoc],getdate() as [Data],'Senza Titolo' as [Titolo],[Azienda],[StrutturaAziendale],Protocollo as [ProtocolloRiferimento], [Fascicolo] 
				from ctl_doc where id = @idDoc

		set @id = @@IDENTITY

		-- ASSOCIO IL MODELLO PER LA RAPPRESENTAZIONE DEI DETTAGLI
		INSERT INTO CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			SELECT @id , 'PRODOTTI' , 'MODELLO_BASE_FABBISOGNI_' + TIPObando + '_Fabb_Analisi' 
				from Document_Bando where idheader = @idDoc

		-- copio i prodotti della richiesta
		set @ListColumn = dbo.GetColumnTableList ('Document_MicroLotti_Dettagli' , 'Id,TipoDoc,IdHeader,Aggiudicata')
		set @sql  = 'insert into Document_MicroLotti_Dettagli ( TipoDoc , idheader , ' + @ListColumn + ' ) 
			select ''ANALISI_FABBISOGNI'' , ' + cast ( @id as varchar (20)) + ' , ' + @ListColumn + '
				from Document_MicroLotti_Dettagli where tipodoc =''BANDO_FABBISOGNI'' and idheader = ' + cast ( @idDoc as varchar (20)) + ' 
				order by id '
		exec( @sql )



		-- ASSOCIO IL MODELLO PER LA RAPPRESENTAZIONE DEI DETTAGLI 
		INSERT INTO CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			SELECT d.id , 'ANALISI_DETTAGLIO' , 'MODELLO_BASE_FABBISOGNI_' + TIPObando + '_Fabb_AnalisiDettaglio' 
				from Document_Bando b
					inner join Document_MicroLotti_Dettagli d on d.idheader = @id and d.TipoDoc = 'ANALISI_FABBISOGNI' 
					where b.idheader = @idDoc

		INSERT INTO CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			SELECT d.id , 'ANALISI_DETTAGLIO_TESTATA' , 'MODELLO_BASE_FABBISOGNI_' + TIPObando + '_Fabb_Analisi' 
				from Document_Bando b
					inner join Document_MicroLotti_Dettagli d on d.idheader = @id and d.TipoDoc = 'ANALISI_FABBISOGNI' 
					where b.idheader = @idDoc


		-- li aggrego con le risposte


		-- creo un documento di dettaglio per ogni prodotto
		--declare @IdHeader INT
		--declare @IdRow1 INT
		--declare @idr INT

		--declare CurProg Cursor Static for 
		--	select  id 
		--		from Document_MicroLotti_Dettagli 
		--		where idheader = @id
		--		order by id

		--open CurProg

		--FETCH NEXT FROM CurProg INTO @idr
		
		--WHILE @@FETCH_STATUS = 0
		--BEGIN


		--	FETCH NEXT FROM CurProg INTO @idr
			
		--END 

		--CLOSE CurProg
		--DEALLOCATE CurProg


		-- gli aggancio le singole risposte di ogni ente 
		declare @Col nvarchar(max)

		set @col = 'a.' + replace( @ListColumn , ',' , ',a.' )

		set @sql  = 'insert into Document_MicroLotti_Dettagli ( TipoDoc , idheader , Aggiudicata , ' + @ListColumn + ' ) 
			select ''ANALISI_FABBISOGNO_DETTAGLIO'' ,  b.id , p.idAzi , ' + @col + '
				from Document_MicroLotti_Dettagli b
					inner join ctl_doc_destinatari p on p.idheader = ' + cast ( @idDoc as varchar (20)) + ' 
					inner join ctl_doc d on d.linkeddoc = ' + cast ( @idDoc as varchar (20)) + '  and d.deleted = 0 and d.TipoDoc =''QUESTIONARIO_FABBISOGNI'' and cast( p.idAzi as varchar(15)) = d.azienda and d.statofunzionale = ''Completato''
					inner join Document_MicroLotti_Dettagli a on b.tipodoc =''ANALISI_FABBISOGNI'' and a.idheader = d.id and b.NumeroRiga = a.Numeroriga
				where b.tipodoc =''ANALISI_FABBISOGNI'' and b.idheader = ' + cast ( @id as varchar (20)) + ' 
				order by b.id , p.NumRiga '
		exec( @sql )


		-- aggiungo la cronologia
		insert into CTL_ApprovalSteps ( [APS_Doc_Type] , [APS_ID_DOC] , [APS_State] , [APS_Note] , [APS_UserProfile] , [APS_IdPfu] , [APS_Date]) 
			values( 'ANALISI_FABBISOGNI' , @id ,    'Creato' ,  'Creazione documento di analisi' ,   dbo.GetUserRoleDefalut( @IdUser  ) , @IdUser , getdate() ) 
	
		EXEC ANALISI_FABBISOGNI @id
	
	end
	



	if @Errore = ''
	begin
		-- rirorna l'id del documento
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END






GO
