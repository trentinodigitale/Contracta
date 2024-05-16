USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ANALISI_FABBISOGNI_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE proc [dbo].[ANALISI_FABBISOGNI_CREATE_FROM_BANDO] 	( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON;

	declare @Errore as nvarchar(2000)
	declare @Id as INT
	declare @sql nvarchar(max)
	declare @ListColumn nvarchar(max)

	declare @aggiuNonRisposti int

	set @id = null
	set @Errore = ''
	set @aggiuNonRisposti = 1

	select @id = id from ctl_doc with(nolock) where tipodoc = 'ANALISI_FABBISOGNI' and deleted = 0  and linkeddoc = @idDoc

	if @id is null
	begin

		-- controllo che l'utente appartenga alla lista dei riferimenti al compilatore 

		-- creo la il documento di analisi
		insert into CTL_DOC ( [LinkedDoc] , [IdPfu], idPfuInCharge,[TipoDoc],[Data],[Titolo],[Azienda],[StrutturaAziendale],[ProtocolloRiferimento], [Fascicolo] ) 
			select id as [LinkedDoc] ,@IdUser as  [IdPfu], @IdUser , 'ANALISI_FABBISOGNI' as [TipoDoc],getdate() as [Data],'' as [Titolo],[Azienda],[StrutturaAziendale],Protocollo as [ProtocolloRiferimento], [Fascicolo] 
				from ctl_doc with(nolock)
				where id = @idDoc

		set @id = SCOPE_IDENTITY()

		-- ASSOCIO IL MODELLO PER LA RAPPRESENTAZIONE DEI DETTAGLI
		INSERT INTO CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			SELECT @id , 'PRODOTTI' , 'MODELLO_BASE_FABBISOGNI_' + TIPObando + '_Fabb_Analisi' 
				from Document_Bando with(nolock)
				where idheader = @idDoc

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
				from Document_Bando b with(nolock)
						inner join Document_MicroLotti_Dettagli d with(nolock) on d.idheader = @id and d.TipoDoc = 'ANALISI_FABBISOGNI' 
					where b.idheader = @idDoc

		INSERT INTO CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			SELECT d.id , 'ANALISI_DETTAGLIO_TESTATA' , 'MODELLO_BASE_FABBISOGNI_' + TIPObando + '_Fabb_Analisi' 
				from Document_Bando b with(nolock)
						inner join Document_MicroLotti_Dettagli d with(nolock) on d.idheader = @id and d.TipoDoc = 'ANALISI_FABBISOGNI' 
					where b.idheader = @idDoc

		-- gli aggancio le singole risposte di ogni ente 
		declare @Col nvarchar(max)

		set @col = 'a.' + replace( @ListColumn , ',' , ',a.' )

		set @sql  = 'insert into Document_MicroLotti_Dettagli ( TipoDoc , idheader , Aggiudicata , ' + @ListColumn + ' ) 
			select ''ANALISI_FABBISOGNO_DETTAGLIO'' ,  b.id , p.idAzi , ' + @col + '
				from Document_MicroLotti_Dettagli b with(nolock)
					inner join ctl_doc_destinatari p with(nolock) on p.idheader = ' + cast ( @idDoc as varchar (20)) + ' 
					inner join ctl_doc d with(nolock) on d.linkeddoc = ' + cast ( @idDoc as varchar (20)) + '  and d.deleted = 0 and d.TipoDoc =''QUESTIONARIO_FABBISOGNI'' and cast( p.idAzi as varchar(15)) = d.azienda and d.statofunzionale = ''Completato''
					inner join Document_MicroLotti_Dettagli a with(nolock) on b.tipodoc =''ANALISI_FABBISOGNI'' and a.idheader = d.id and b.NumeroRiga = a.Numeroriga
				where b.tipodoc =''ANALISI_FABBISOGNI'' and b.idheader = ' + cast ( @id as varchar (20)) + ' 
				order by b.id , p.NumRiga '

		exec( @sql )

		IF @aggiuNonRisposti = 1
		BEGIN

			-- Portarsi anche la predisposizione per gli enti che non hanno risposto
			set @sql  = 'SET NOCOUNT ON 
						insert into Document_MicroLotti_Dettagli ( TipoDoc , idheader , Aggiudicata , ' + @ListColumn + ' ) 
							select ''ANALISI_FABBISOGNO_DETTAGLIO'', a.id , p.idAzi , ' + @col + '
								from Document_MicroLotti_Dettagli a with(nolock)
											inner join ctl_doc_destinatari p with(nolock) on p.idheader = ' + cast ( @idDoc as varchar (20)) + ' and p.StatoIscrizione=''Annullato''
								where a.tipodoc = ''ANALISI_FABBISOGNI'' and a.idheader = ' + cast ( @id as varchar (20)) + ' 
								order by a.id , p.NumRiga'

			exec( @sql )

		END

		-- aggiungo la cronologia
		insert into CTL_ApprovalSteps ( [APS_Doc_Type] , [APS_ID_DOC] , [APS_State] , [APS_Note] , [APS_UserProfile] , [APS_IdPfu] , [APS_Date]) 
			values( 'ANALISI_FABBISOGNI' , @id ,    'Creato' ,  'Creazione documento di analisi' ,   dbo.GetUserRoleDefalut( @IdUser  ) , @IdUser , getdate() ) 

		EXEC ANALISI_FABBISOGNI @id

	END

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
