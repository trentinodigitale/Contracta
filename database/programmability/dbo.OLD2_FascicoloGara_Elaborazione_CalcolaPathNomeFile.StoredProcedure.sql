USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_FascicoloGara_Elaborazione_CalcolaPathNomeFile]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO












--Versione=1&data=2022-05-17&Attivita=450375&Nominativo=EP
CREATE PROCEDURE [dbo].[OLD2_FascicoloGara_Elaborazione_CalcolaPathNomeFile] ( @IdDoc as int )
AS

BEGIN
	
	declare @TipoDoc as varchar(100)
	declare @Protocollo as varchar(100)
	declare @DSE_ID as varchar(200)
	declare @AreaDiAppartenenza as varchar(200)
	declare @IdRow as int
	declare @Path as varchar(500)
	declare @NomeFile as varchar(500)
	declare @JumpCheck as varchar(100)
	declare @IdDocumento as int
	declare @OperatoreEconomico as nvarchar(1000)
	declare @ProtocolloGara as varchar (50)
	declare @IdGara as int
	declare @OrganizzazioneFile as varchar (50)
	declare @StatoFunzionale as varchar (100)

	--recupero protocollo della gara 
	select 
		@ProtocolloGara = ProtocolloRiferimento
		from 
			ctl_Doc with (nolock) 
		where id = @IdDoc

	--recupero la tipologia di organizzazione che devo fare nel path dal documento di configurazione
	select 
		@OrganizzazioneFile = OrganizzazioneFile
		from
			ctl_doc with (nolock) 
				inner join Document_Config_FascicoloGara with (nolock) on idheader = id
		where 
			tipodoc='PARAMETRI_FASCICOLO_GARA' and statofunzionale='Confermato'


	--faccio un cursore per ogni allegato di ogni documento
	DECLARE crsAllegati CURSOR STATIC FOR 
		
		select top 200 idrow from Document_Fascicolo_Gara_Allegati where idheader = @IdDoc and [path] is NULL order by idrow 

	OPEN crsAllegati

	FETCH NEXT FROM crsAllegati INTO @IdRow
	WHILE @@FETCH_STATUS = 0
	BEGIN
		

		--setto il path 
		if @OrganizzazioneFile = 'fase'
			exec FascicoloGara_Elaborazione_Set_Path_PerFase @IdRow
		else
			exec FascicoloGara_Elaborazione_Set_Path_PerOE @IdRow

		--setto il nome file 
		exec FascicoloGara_Elaborazione_Set_NomeFile @IdRow , @ProtocolloGara



		FETCH NEXT FROM crsAllegati INTO @IdRow
	END

	CLOSE crsAllegati 
	DEALLOCATE crsAllegati 


	--per i documentidi offerta sostituisco gli idazi che homesso nei path con partecipante 1, ..... , partecipante N

	--recupero id gara 
	select 
		@IdGara = id,
		@StatoFunzionale = StatoFunzionale
		from 
			ctl_doc with (nolock)
		where protocollo = @ProtocolloGara


	----Nel caso di Documenti con statoFunzionale 'InRettifica', 'InEsame' 
	----vado a cancellare tutti gli allegati che non sono con path 01 GARA o indice (xslx)
	IF @StatoFunzionale in ('PresOfferte','InEsame','InRettifica') and (select dbo.PARAMETRI('CERTIFICATION','certification_req_33254','ATTIVA','NO','-1')) <> 'NO'
	BEGIN
		delete from Document_Fascicolo_Gara_Allegati where idheader = @IdDoc and [path] not like '%01 Gara%' and [path] is not null
	END

	--recupero i partecipanti alla gara e li inserisco in una temp 
	--con associata la stringa Partecipante N
	--select 
	--		azienda, 'Partecipante ' +  cast ( ROW_NUMBER() OVER(ORDER BY idrow ASC) as varchar(10) )  AS Row 
	--		into #t
	--	from 
	--		Document_Fascicolo_Gara_Documenti DF 
	--			inner join ctl_doc D  with (nolock) on D.id = DF.iddoc		
	--	where 
	--		--linkeddoc = @IdGara and tipodoc = 'OFFERTA' and deleted=0 and StatoFunzionale <> 'InLavorazione'
	--		DF.idheader  = @IdDoc
	--		order by DF.idrow

	----rimpiazzo gli idazi con la stringa PArtecipante N nella temp
	--update 
	--	 A
	--		set Path = replace(path,'\' + cast(P.azienda as varchar(50)) , '\' + P.Row )
	
	--	from 
	--		Document_Fascicolo_Gara_Allegati A 
	--			inner join #t P on  path like '%\' + azienda + '%'
	--	where 
	--		idheader =  @IdDoc and path like 'Documenti di Offerta\%'
	

	--chiamo una stored per rendere unici i nomi file all'itenrno dello zip
	Exec Fascicolo_Normalizza_NomeFile @IdDoc

END -- Fine stored









GO
