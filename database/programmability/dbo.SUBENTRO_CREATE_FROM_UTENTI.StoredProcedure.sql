USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SUBENTRO_CREATE_FROM_UTENTI]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[SUBENTRO_CREATE_FROM_UTENTI] ( @IdPfuDaCessare int  , @idUtenteCollegato int )
AS
BEGIN

	SET NOCOUNT ON

	declare @id INT
	declare @Errore as nvarchar(2000)
	declare @IdAzi as int
	declare  @new_doc as int
	set @new_doc=0
	
	set @Id = 0
	set @Errore=''
	
	----VERIFICO SE @IdPfuDaCessare è valido
	--IF EXISTS ( select * from ProfiliUtente where IdPfu=@IdPfuDaCessare and pfuDeleted=1)
	--BEGIN
	--	set @Errore='Attenzione lo stato dell''utente non consente la creazione del documento'
	--END

	if @Errore = ''
	BEGIN

		select @id = id 
			from ctl_doc with(nolock)
			where tipodoc = 'SUBENTRO' and StatoFunzionale = 'InLavorazione' and Destinatario_User = @IdPfuDaCessare and deleted = 0


		select @IdAzi=pfuidazi 
		   from profiliutente with(nolock)
					--left join aziende with(nolock) ON pfuidazi=idazi and pfudeleted=0 
		   where idpfu=@idUtenteCollegato  

		declare @idPrimaIscrizione INT
		declare @cfDaControllare nvarchar(500)

		set @idPrimaIscrizione = -1
		set @cfDaControllare = ''


		--se il documento di subentro non esiste lo creo    
		IF @Id = 0 
		BEGIN
			--inserisco nella ctl_doc		
			insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_User,  StatoFunzionale,IdPfuInCharge, jumpcheck)
				values			( @idUtenteCollegato, 'SUBENTRO', 'Saved' , 'Subentro' , '', @IdAzi , @IdPfuDaCessare ,'InLavorazione', @idUtenteCollegato , '')
			set @new_doc=1
			set @Id = SCOPE_IDENTITY()

			insert into CTL_DOC_Value (idheader, DSE_ID, DZT_Name, [row], value )
				select @Id,'SUBENTRATO','SenzaCessazione',0,'1'
		END
		--ELSE
		--BEGIN
		--   --cancello le entrate precedenti della ctl_doc_value
		--   delete CTL_DOC_VALUE where idheader=@Id
		--END
		--temp table usata nel ciclo
		select top 0 * into #tmp_CTL_DOC_Value from CTL_DOC_Value where IdHeader=0

		--inserisco le entrate della ctl_doc_value
		declare @row int
		declare @idDoc int
		declare @tipodoc varchar(1000)
		declare @protocollo varchar(1000)
		declare @fascicolo varchar(1000)
		declare @nomeDocumento varchar(1000)
		declare @titolo nvarchar(max)
		declare @datainvio varchar(100)
		declare @statoFunzionale varchar(500)
		declare @rup int
		declare @utenteCommissione int
		declare @userRif int
		
		DECLARE curs CURSOR STATIC FOR     
		   SELECT distinct 
					idDoc,
					tipoDoc,
					protocollo,
					titolo,
					convert( VARCHAR(19) , datainvio, 126) as DataInvio,
					statofunzionale,
					NomeDocumento,
					Fascicolo
				FROM LISTA_GARE_DI_COMPETENZA 
				where ( userrup = @IdPfuDaCessare or utentecommissione = @IdPfuDaCessare or userrif = @IdPfuDaCessare )
					and ISNULL(protocollo,'') <> ''
				order by protocollo desc
				

		select @row=max(Row)+1 from CTL_DOC_Value with(nolock) where IdHeader=@id and DSE_ID='LISTA'
		IF ISNULL(@row,0)=0
			set @row=0

		OPEN curs 
		FETCH NEXT FROM curs INTO @idDoc,@tipoDoc,@protocollo,@titolo,@datainvio,@statofunzionale,@nomeDocumento,@fascicolo

		WHILE @@FETCH_STATUS = 0   
		BEGIN  
			
		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'idRow', @row, @idDoc )

		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'OPEN_DOC_NAME', @row, @tipoDoc )

		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'NomeDocumento', @row, @nomeDocumento )

		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'Protocollo', @row, @protocollo )
			
		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'Titolo', @row, @titolo )

		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'DataInvio', @row, @datainvio )

		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'StatoFunzionale', @row, @statofunzionale )

		   INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'Fascicolo', @row, @fascicolo )

			 INSERT INTO #tmp_CTL_DOC_VALUE( idheader, DSE_ID, DZT_Name, [row], value )
							  values ( @Id, 'LISTA', 'NumeroRiga', @row, @row+1 )


		   set @row = @row + 1

		   FETCH NEXT FROM curs INTO @idDoc,@tipoDoc,@protocollo,@titolo,@datainvio,@statofunzionale,@nomeDocumento,@fascicolo

		END  

		CLOSE curs   
		DEALLOCATE curs



		
			--AGGIUNGO DOCUMENTI NON PRESENTI		
			select t.[Row] into #tmp_row_add		
				from #tmp_CTL_DOC_Value t
					left join CTL_DOC_Value c with(nolock) on c.IdHeader=t.IdHeader and c.DSE_ID='Lista' and c.DZT_Name='idRow' and c.Value=t.Value
			where t.IdHeader=@id and t.DSE_ID='Lista' and t.DZT_Name='idRow' and c.Value IS NULL
		
			insert into CTL_DOC_Value ( idheader, DSE_ID, DZT_Name, [row], value )
				select  @id, t.DSE_ID, t.DZT_Name, t.[row], t.value 
					from #tmp_CTL_DOC_Value t
					where t.Row in (select row from #tmp_row_add) and  IdHeader=@id
		
		IF @new_doc = 0
		BEGIN
		--CANCELLO EVENTUALI DOCUMENTI CHE NON SERVONO Più SE NON STO CREANDO ORA IL DOCUMENTO
		
			select Row into #tmp_row
				from CTL_DOC_Value 	with(nolock)		  	
				where IdHeader=@id and DSE_ID='Lista' and DZT_Name='idRow' and Value not in (select value from #tmp_CTL_DOC_Value where IdHeader=@id and DSE_ID='Lista' and DZT_Name='idRow' )
			delete from CTL_DOC_Value where IdHeader=@id and DSE_ID='Lista' and row in (select row from #tmp_row)
		END
		
		select * into #lavoro from CTL_DOC_Value with(nolock) where IdHeader=@id  and DSE_ID='LISTA'
		update #lavoro set Row=-1
		---FACCIO UN CURSORE PER RIORDINARE LE ROW SULLA GRIGLIA, togliendo eventuali buchi e riordina per Protocollo
		set @row=0
		declare @protocollo_TO_UPD as varchar(200)
		declare @ROW_UPD as int
		
		DECLARE curs2 CURSOR STATIC FOR  
			select row 
				from CTL_DOC_Value  with(nolock) where IdHeader=@id and DZT_Name='Protocollo' and DSE_ID='LISTA'							
				order by right(cast(Value as nvarchar (200)), 2) desc, cast(Value as nvarchar (200)) desc

		OPEN curs2 
		FETCH NEXT FROM curs2 INTO @ROW_UPD

		WHILE @@FETCH_STATUS = 0   
		BEGIN  						
			update #lavoro 
					set row=@row 
				from ctl_doc_value CV with(nolock) 
					inner join #lavoro L on CV.IdRow=L.IdRow			
				where CV.IdHeader=@id and CV.Row=@ROW_UPD and CV.DSE_ID='LISTA'
			
			set @row = @row + 1			

		   FETCH NEXT FROM curs2 INTO @ROW_UPD

		END  

		CLOSE curs2   
		DEALLOCATE curs2

		update CV set Row=L.Row
			from CTL_DOC_Value CV with(nolock)
				inner join #lavoro L on CV.IdRow=L.IdRow
	END
	
	--RETTIFICA IL NUMERO RIGA
	update CTL_DOC_Value set Value=Row+1 where IdHeader=@id and DSE_ID='LISTA' and DZT_Name='NumeroRiga'
	

	if @Errore=''
	begin
		select @Id as id , @Errore as Errore
	end
	else
	begin
		select 'Errore' as id , @Errore as Errore
	end

END






























GO
