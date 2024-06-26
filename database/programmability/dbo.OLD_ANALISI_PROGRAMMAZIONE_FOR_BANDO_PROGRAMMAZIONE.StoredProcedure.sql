USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_ANALISI_PROGRAMMAZIONE_FOR_BANDO_PROGRAMMAZIONE]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_ANALISI_PROGRAMMAZIONE_FOR_BANDO_PROGRAMMAZIONE]  	( @idDoc int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON;

	declare @Errore as nvarchar(2000)
	declare @Id as INT
	declare @sql nvarchar(max)
	declare @ListColumn nvarchar(max)


	set @id = null


	--VERIFICO SE IL BANDO E' NELLO STATO GIUSTO PER FARE ANALISI
	select @id = id 
		from ctl_doc with(nolock) 
			where id=@idDoc and tipodoc = 'BANDO_PROGRAMMAZIONE' and deleted = 0  and 
				StatoFunzionale not in ('Inviato')

	if @id is null
	BEGIN		

		-- aggiungo la cronologia al BANDO_PROGRAMMAZIONE
		insert into CTL_ApprovalSteps ( [APS_Doc_Type] , [APS_ID_DOC] , [APS_State] , [APS_Note] , [APS_UserProfile] , [APS_IdPfu] , [APS_Date]) 
			values( 'BANDO_PROGRAMMAZIONE' , @idDoc ,    'Creato' ,  'Avvio Analisi sulla Richiesta' ,   dbo.GetUserRoleDefalut( @IdUser  ) , @IdUser , getdate() ) 


		-- ASSOCIO IL MODELLO PER LA RAPPRESENTAZIONE DEI DETTAGLI
		INSERT INTO CTL_DOC_SECTION_MODEL ( IdHeader, DSE_ID, MOD_Name )
			SELECT @idDoc , 'ANALISI' , 'MODELLO_BASE_PROGRAMMAZIONE_' + TIPObando + '_Prog_Analisi' 
				from Document_Bando with(nolock)
				where idheader = @idDoc
		

		declare @elenco_q as nvarchar(max)
		set @elenco_q=''
		select @elenco_q = @elenco_q + cast(id as varchar(20))+ ',' from CTL_DOC where TipoDoc='QUESTIONARIO_PROGRAMMAZIONE' and StatoFunzionale='Completato'
		set @elenco_q = SUBSTRING(@elenco_q,0,len(@elenco_q))

		-- copio i prodotti dai questionari
		set @ListColumn = dbo.GetColumnTableList ('Document_Programmazione_Dettagli' , 'Id,TipoDoc,IdHeader')
		set @sql  = 'insert into Document_Programmazione_Dettagli ( TipoDoc , idheader , ' + @ListColumn + ' ) 
			select ''BANDO_PROGRAMMAZIONE'' , ' + cast ( @idDoc as varchar (20)) + ' , ' + @ListColumn + '
				from Document_Programmazione_Dettagli where tipodoc =''QUESTIONARIO_PROGRAMMAZIONE'' and idheader in (' + @elenco_q + ') 
				order by id '
		exec( @sql )

		--RICALCOLO IL NUMERO RIGA		
		update Document_Programmazione_Dettagli 
				set NumeroRiga= V.RowNUm
			from	 Document_Programmazione_Dettagli A
				 inner join (  select  id,ROW_NUMBER() over (order by id) as RowNUm
								from Document_Programmazione_Dettagli where idheader=@IDDOC  and tipodoc='BANDO_PROGRAMMAZIONE' ) V on A.id=V.id


		--CAMBIO LO STATO AL BANDO_PROGRAMMAZIONE
		update ctl_doc set StatoFunzionale='Completato' where Id=@idDoc
	END

		
		

	END

GO
