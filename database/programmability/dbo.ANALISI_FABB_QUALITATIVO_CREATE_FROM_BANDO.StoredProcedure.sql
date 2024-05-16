USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ANALISI_FABB_QUALITATIVO_CREATE_FROM_BANDO]    Script Date: 5/16/2024 2:38:52 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE proc [dbo].[ANALISI_FABB_QUALITATIVO_CREATE_FROM_BANDO] 	( @idDoc int , @IdUser int  )
AS
BEGIN
	SET NOCOUNT ON;

	declare @Errore as nvarchar(2000)
	declare @Id as INT
	declare @sql nvarchar(max)
	declare @ListColumn nvarchar(max)

	set @id = null
	set @Errore = ''


	select @id = id from ctl_doc where tipodoc = 'ANALISI_FABB_QUALITATIVO' and deleted = 0  and linkeddoc = @idDoc

	if @id is null
	begin

		-- controllo che l'utente appartenga alla lista dei riferimentio al compilatore 

		-- creo il documento di analisi
		insert into CTL_DOC ( [LinkedDoc] , [IdPfu], idPfuInCharge,[TipoDoc],[Data],[Titolo],[Azienda],[StrutturaAziendale],[ProtocolloRiferimento], [Fascicolo] ) 
			select id as [LinkedDoc] ,@IdUser as  [IdPfu], @IdUser , 'ANALISI_FABB_QUALITATIVO' as [TipoDoc],getdate() as [Data],'Senza Titolo' as [Titolo],[Azienda],[StrutturaAziendale],Protocollo as [ProtocolloRiferimento], [Fascicolo] 
				from ctl_doc where id = @idDoc

		set @id = @@IDENTITY

		-- riporto le righe del template
		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			select @id as IdHeader, DSE_ID, Row, DZT_Name, Value 
				from CTL_DOC_Value 
				where idheader = @idDoc and DSE_ID = 'VALORI' and DZT_Name in ( 'Domanda_Sezione' , 'Descrizione' , 'Domanda_Elenco' , 'Keyriga' )

		-- riporto il body della domanda
		insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
			select @id as IdHeader, DSE_ID, Row, 'Body' as DZT_Name, Body as Value 
				from CTL_DOC_Value 
					inner join CTL_DOC on cast( guid as varchar(1000)) = replace( value , '_' , '-' )
				where idheader = @idDoc and DSE_ID = 'VALORI' and DZT_Name in (  'Domanda_Elenco' )

		
		--Ciclo sulle righe del template di tipo domanda per creare i documenti di analisi con i dati 
		declare @idRow INT

		declare CurProg Cursor static for 
			Select [Row]  from CTL_DOC_Value 	
				where idHeader=@ID and DZT_Name = 'Domanda_Sezione' and Value = 'domanda'
				order by IdRow
		open CurProg

		FETCH NEXT FROM CurProg INTO @idrow
		WHILE @@FETCH_STATUS = 0
		BEGIN

			exec ANALISI_DOMANDA_QUESTIONARIO @id , @idrow
	             
			FETCH NEXT FROM CurProg INTO @idrow
		END 
		CLOSE CurProg
		DEALLOCATE CurProg


		-- aggiungo la cronologia
		insert into CTL_ApprovalSteps ( [APS_Doc_Type] , [APS_ID_DOC] , [APS_State] , [APS_Note] , [APS_UserProfile] , [APS_IdPfu] , [APS_Date]) 
			values( 'ANALISI_FABB_QUALITATIVO' , @id ,    'Creato' ,  'Creazione documento di analisi' ,   dbo.GetUserRoleDefalut( @IdUser  ) , @IdUser , getdate() ) 
	
	
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
