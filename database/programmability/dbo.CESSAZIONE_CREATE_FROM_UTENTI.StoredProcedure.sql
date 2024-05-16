USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[CESSAZIONE_CREATE_FROM_UTENTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[CESSAZIONE_CREATE_FROM_UTENTI] ( @IdPfuDaCessare int  , @idUtenteCollegato int ,  @provenienza varchar(200) = ''  )
AS
BEGIN

	SET NOCOUNT ON

	declare @id INT
	declare @Errore as nvarchar(2000)
	declare @IdAzi as int
	
	set @Id = 0
	set @Errore=''
	declare @linkeddoc as INT

	--QUANDO VENGO DA CESSAZIONE_UTENTI @idUtenteCollegato ci sta id della cessazione
	if ( @provenienza = 'CESSAZIONE_UTENTI' )
	BEGIN
		set @linkeddoc=@idUtenteCollegato
		select top 1 @idUtenteCollegato=APS_IdPfu 
			from CTL_DOC with(nolock) 
				inner join CTL_ApprovalSteps with(nolock)  on APS_ID_DOC=Id and APS_State='CESSAZIONE' and APS_IsOld=1
			where Id=@linkeddoc and TipoDoc='CESSAZIONE_UTENTI'
	END

	--VERIFICO SE @IdPfuDaCessare è valido
	IF EXISTS ( select * from ProfiliUtente where IdPfu=@IdPfuDaCessare and pfuDeleted=1)
	BEGIN
		set @Errore='Attenzione lo stato dell''utente non consente la creazione del documento'
	END

	if @Errore = ''
	BEGIN

		select @id = id 
			from ctl_doc with(nolock)
			where tipodoc = 'CESSAZIONE' and StatoFunzionale = 'InLavorazione' and Destinatario_User = @IdPfuDaCessare and deleted = 0


		

			select @IdAzi=pfuidazi 
				from profiliutente with(nolock)
						--left join aziende with(nolock) ON pfuidazi=idazi and pfudeleted=0 
				where idpfu=@idUtenteCollegato  

			declare @idPrimaIscrizione INT
			declare @cfDaControllare nvarchar(500)

			set @idPrimaIscrizione = -1
			set @cfDaControllare = ''

			IF ( @Id = 0 and @Errore='' ) or ( @provenienza = 'CESSAZIONE_UTENTI' )
			BEGIN

				--inserisco nella ctl_doc		
				insert into CTL_DOC ( IdPfu, TipoDoc, StatoDoc, Titolo, Body, Azienda,Destinatario_User,  StatoFunzionale,IdPfuInCharge, jumpcheck,LinkedDoc)
					values			( @idUtenteCollegato, 'CESSAZIONE', 'Saved' , 'Cessazione' , '', @IdAzi , @IdPfuDaCessare ,'InLavorazione', @idUtenteCollegato , @provenienza,@linkeddoc)

				set @Id = SCOPE_IDENTITY()

			END

			select top 0 * into #tmp_CTL_DOC_Value from CTL_DOC_Value where IdHeader=0

			declare @row int
			declare @idDoc int
			declare @tipodoc varchar(1000)
			declare @protocollo varchar(1000)
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
						NomeDocumento 
				FROM LISTA_GARE_DI_COMPETENZA 
				where userrup = @IdPfuDaCessare or utentecommissione = @IdPfuDaCessare or userrif = @IdPfuDaCessare 
			order by DataInvio desc

			set @row = 0

			OPEN curs 
			FETCH NEXT FROM curs INTO @idDoc,@tipoDoc,@protocollo,@titolo,@datainvio,@statofunzionale,@nomeDocumento

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

				set @row = @row + 1

				FETCH NEXT FROM curs INTO @idDoc,@tipoDoc,@protocollo,@titolo,@datainvio,@statofunzionale,@nomeDocumento

			END  

			CLOSE curs   
			DEALLOCATE curs

			--CANCELLO EVENTUALI DOCUMENTI CHE NON SERVONO Più
			delete from CTL_DOC_Value 			  	
			where IdHeader=@id and DSE_ID='Lista' and DZT_Name='idRow' and Value not in (select value from #tmp_CTL_DOC_Value where IdHeader=@id and DSE_ID='Lista' and DZT_Name='idRow' )
			--AGGIUNGO DOCUMENTI NON PRESENTI
			insert into CTL_DOC_Value ( idheader, DSE_ID, DZT_Name, [row], value )
			select  @id, t.DSE_ID, t.DZT_Name, t.[row], t.value 
				from #tmp_CTL_DOC_Value t
					left join CTL_DOC_Value c on c.IdHeader=t.IdHeader and c.DSE_ID='Lista' and c.DZT_Name='idRow' and c.Value=t.Value
			where t.IdHeader=@id and c.Value IS NULL
	END
	IF OBJECT_ID(N'tempdb..##tmp_CTL_DOC_Value') IS NOT NULL
	BEGIN
		drop table #tmp_CTL_DOC_Value
	END
	

	--QUANDO VENGO DA CESSAZIONE_UTENTI serve schedulare INVIO
	if ( @provenienza = 'CESSAZIONE_UTENTI' )
	BEGIN
		insert into CTL_Schedule_Process ( IdDoc,IdUser,DPR_DOC_ID,DPR_ID )
			select @id,@idUtenteCollegato,'CESSAZIONE_ENTI','PRE_SEND'
	END

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
