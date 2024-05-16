USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SUBENTRO_OE_CREATE_FROM_UTENTI]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[OLD_SUBENTRO_OE_CREATE_FROM_UTENTI] ( @IdPfuACuiSubentrare int  , @idUtenteCollegato int )
AS
BEGIN

	SET NOCOUNT ON

	declare @id INT
	
	declare @IdAzi as int
	declare  @new_doc as int
	set @new_doc=0
	
	set @Id = 0
	
	BEGIN

		select @id = id 
			from ctl_doc with(nolock)
			where tipodoc = 'SUBENTRO_OE' and StatoFunzionale = 'InLavorazione' and Destinatario_User = @IdPfuACuiSubentrare and deleted = 0


		select @IdAzi=pfuidazi 
		   from profiliutente with(nolock)
		   where idpfu=@idUtenteCollegato  

		--se il documento di subentro non esiste lo creo    
		IF @Id = 0 
		BEGIN
			--inserisco nella ctl_doc		
			insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_User,  StatoFunzionale,IdPfuInCharge, jumpcheck)
				values			( @idUtenteCollegato, 'SUBENTRO_OE', 'Saved' , 'Subentro' , '', @IdAzi , @IdPfuACuiSubentrare ,'InLavorazione', @idUtenteCollegato , '')
			set @new_doc=1
			set @Id = SCOPE_IDENTITY()

			/*insert into CTL_DOC_Value (idheader, DSE_ID, DZT_Name, [row], value )
				select @Id,'SUBENTRATO','SenzaCessazione',0,'1'*/
		END
		
		--temp table usata nel ciclo
		select top 0 * into #tmp_CTL_DOC_Value from CTL_DOC_Value where IdHeader=0

		--inserisco le entrate della ctl_doc_value
		declare @row int
		declare @idDoc int
		declare @tipodoc varchar(1000)
		declare @protocollo varchar(1000)
		declare @fascicolo varchar(1000)
		declare @titolo nvarchar(max)
		declare @datacreazione varchar(100)
		
		declare @rup int
		declare @utenteCommissione int
		declare @userRif int
		
		DECLARE curs CURSOR STATIC FOR     
		   -- Prelevo tutti i documenti che 
			-- Appartengono all'utente a cui bisogna subentrare
			-- Sono nello stato 'InLavorazione' 
			-- che sono di Tipo 'OFFERTA' o che iniziano per 'ISTANZA'
			
			SELECT d.Id as idDoc
				, d.TipoDoc 
				, d.protocollo
				, d.Fascicolo
				, dl.titolo as TitoloProcedura				
				, convert( VARCHAR(19) , d.Data, 126) as DataCreazione

				FROM ctl_doc d with(nolock)
					left outer join ctl_doc dl  with(nolock) ON dl.id= d.LinkedDoc
					left outer join Document_Bando  db with(nolock) ON dl.id = db.idHeader 
					
				WHERE
					d.IdPfu = @IdPfuACuiSubentrare
					AND d.StatoFunzionale in ('Inlavorazione')
					AND (
						(d.TipoDoc = 'OFFERTA' and GETDATE()< isnull(db.DataScadenzaOfferta, DATEADD(day, -1, GETDATE())))
						or 
						(d.TipoDoc like 'ISTANZA%' and dl.DataScadenza >= GETDATE() )
					)

				ORDER BY d.Data desc

		-- Elimina tutti i riferimenti sulla CTL_DOC_VALUE del documento corrente se era già esistente
		IF @new_doc = 0
			delete CTL_DOC_Value WHERE IdHeader=@id and DSE_ID='LISTA'

		set @row=0

		OPEN curs 
		FETCH NEXT FROM curs INTO @idDoc, @tipoDoc,@protocollo,@fascicolo,@titolo,@datacreazione

		WHILE @@FETCH_STATUS = 0   
		BEGIN  
			
		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'idRow', @row, @idDoc )

		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'OPEN_DOC_NAME', @row, @tipoDoc )

		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'NomeDocumento', @row, @tipoDoc )
			
		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'Protocollo', @row, @protocollo )
	
			INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'Fascicolo', @row, @fascicolo )

		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'Titolo', @row, @titolo )

		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'DataCreazione', @row, @datacreazione )

			INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'NumeroRiga', @row, @row+1 )

		   set @row = @row + 1

		   FETCH NEXT FROM curs INTO @idDoc, @tipoDoc,@protocollo,@fascicolo,@titolo,@datacreazione

		END  

		CLOSE curs   
		DEALLOCATE curs

		insert into CTL_DOC_Value ( idheader, DSE_ID, DZT_Name, [row], value )
				select  @id, t.DSE_ID, t.DZT_Name, t.[row], t.value 
					from #tmp_CTL_DOC_Value t
					
		
	END
	
	select @Id as id , '' as Errore	
END




























GO
