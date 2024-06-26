USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[SP_NUOVO_CONCORSO_SAVE]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO









CREATE PROCEDURE [dbo].[SP_NUOVO_CONCORSO_SAVE] 
	( @idDoc int  , @idUser int )
AS
BEGIN

   ---INIZIO cambio jumpcheck per aprire il bando	
   
   	declare @tb varchar(50)
	declare @pg varchar(50)
	declare @richiestaCIG varchar(10)
	declare @idAzi INT
	declare @Lista_Enti_abilitati_RCig as varchar (4000)
	declare @EvidenzaPubblica_Parametro as varchar(10)
	declare @LinkedDoc as int
	declare @TipoProceduraCaratteristica as varchar(200)

	set @richiestaCIG = 'si'
	set @TipoProceduraCaratteristica = ''

	select @idazi = pfuidazi from profiliutente with(nolock) where idpfu = @idUser

	select 	 @pg = ProceduraGara 
			, @tb = TipoBandoGara 
			, @TipoProceduraCaratteristica = isnull(TipoProceduraCaratteristica,'')
		from 
			document_bando with(nolock)
		where idheader = @IdDoc
	
	--se sono nel caso di concorso di idee svuoto tipoproceduracaratteristica
	--che potrebbe essere rimasto sporco dal wizard
	if @pg = '15586'
	begin
		set @TipoProceduraCaratteristica = ''
	end

	update ctl_doc 
			set jumpCheck = 'OK' ,
				deleted = 0
		where id = @IdDoc

	--Recupero il linked doc per capire se ci troviamo nel primo o secondo giro
	select @LinkedDoc = isnull(linkeddoc,0) 
		from 
			CTL_DOC with(nolock)
		where id = @idDoc
	

	
	if @TipoProceduraCaratteristica = 'ConcorsoInDueFasi' --Se in un concorso di progettazione a 2 fasi
	begin

		if @LinkedDoc = 0 -- se sono nel primo giro
		begin

			-- Mi setto il campo nella Document_bando per indicare che siamo nella prima fase
			update Document_Bando set FaseConcorso = 'prima' where idheader = @IdDoc
			
			-- Setto un criterio fisso per la prima fase
			if not exists (select idrow from Document_Microlotto_Valutazione with (nolock) where idheader = @idDoc)
			begin
				insert into Document_Microlotto_Valutazione (idHeader,TipoDoc,CriterioValutazione,DescrizioneCriterio,PunteggioMax)
					values
					(
						 @idDoc
						,'BANDO_CONCORSO'
						,'soggettivo'
						,'criterio di valutazione per ammissione alla seconda fase'
						,100
					)	
			end
		end
	end

	IF 
		--( @tb = '1' and @pg = '15478' ) -- SE ( Avviso - Negoziata ) 

		--OR
	   --( @tb = '2' and @pg = '15477' )	--  SE  ( Bando - Ristretta )

	   --OR

	   --( @tb in ('4','5') and @pg = '15583' )  -- avviso di un affidamento a 2 fasi

	    --OR
	   (dbo.attivoSimog() = 0 )   --SE NON ATTIVO IL SIMOG
	BEGIN

		set @richiestaCIG = 'no'

	END

	
	----se azienda corrente non è tra gli enti abilitati setto @richiestaCIG a no
	select  @Lista_Enti_abilitati_RCig= dbo.PARAMETRI('GROUP_SIMOG','ENTI_ABILITATI','DefaultValue','',-1)

	if @Lista_Enti_abilitati_RCig <> '' and CHARINDEX (',' + cast(@idazi as varchar(20)) + ',', ',' + @Lista_Enti_abilitati_RCig + ',') = 0
		set @richiestaCIG = 'no'

	update document_bando 
			set GeneraConvenzione = '0',
				RichiestaCigSimog = @richiestaCIG,
				TipoProceduraCaratteristica = @TipoProceduraCaratteristica
		where idheader = @IdDoc and ISNULL(CIG,'')=''

	-----FINE cambio jumpcheck per aprire il bando	
	
	-----INIZIO se RDO allora setto ListaAlbi con unico bando istitutivo me

	--	declare @ListaAlbi as varchar(500)
	--	if exists(select * from document_bando where idheader = @IdDoc and TipoProceduraCaratteristica='RDO')
	--	begin
	--		select top 1 @ListaAlbi=cast(id as varchar(50)) from ctl_doc where tipodoc='BANDO' and StatoFunzionale = 'Pubblicato' and StatoDoc = 'Sended' and deleted=0 and isnull(jumpcheck,'')='' order by id desc

	--		update document_bando set ListaAlbi = '###' + @ListaAlbi + '###'
	--			where idheader = @IdDoc
	--	end

	--	if exists(select * from document_bando where idheader = @IdDoc and TipoProceduraCaratteristica='Cottimo')
	--	begin
	--		select top 1 @ListaAlbi=cast(id as varchar(50)) from ctl_doc where tipodoc='BANDO' and StatoFunzionale = 'Pubblicato' and StatoDoc = 'Sended' and deleted=0 and isnull(jumpcheck,'')='BANDO_ALBO_LAVORI' order by id desc

	--		update document_bando set ListaAlbi = '###' + @ListaAlbi + '###'
	--			where idheader = @IdDoc
	--	end

	-----FINE se RDO allora setto ListaAlbi con unico bando istitutivo me

	----INIZIO Se non presente aggiungo il record nella Document_dati_protocollo 

		if not exists(select * from Document_dati_protocollo where idheader = @IdDoc)
		begin

			insert into Document_dati_protocollo ( idHeader)
				values (  @IdDoc )
		end

	----FINE Se non presente aggiungo il record nella Document_dati_protocollo 

	----INIZIO Sostituisco il modello per la testa per utilizzare quello più adeguato per il tipo di procedura

	--	exec BANDO_GARA_DEFINIZIONE_STRUTTURA  @idDoc , -1, @idazi

	----FINE Sostituisco il modello per la testa per utilizzare quello più adeguato per il tipo di procedura

	----INIZIO Porto la versione del documento a 2 per gestire le formule economiche multiple

	--	update ctl_doc set Versione = '2' where id = @idDoc

	----FINE Porto la versione del documento a 2 per gestire le formule economiche multiple

	----INIZIO se criterio aggiudicazione gara è Offerta Economicamente più vantaggiosa setta la conformità a no
	
	----se criterio aggiudicazione gara è Offerta Economicamente più vantaggiosa o COSTO FISSO setta la conformità a no
	--	update document_bando set Conformita='No'
	--		where idheader= @idDoc and CriterioAggiudicazioneGara in ( '15532','25532')

	----FINE se criterio aggiudicazione gara è Offerta Economicamente più vantaggiosa setta la conformità a no

	----INIZIO Se l'utente collegato non fa parte dell'azimaster, setto un default per l'IdentificativoIniziativa
	if not exists ( select idpfu from profiliutente with(Nolock) where idpfu = @idUser and pfuIdAzi = 35152001 )
	begin

		update document_bando 
			set IdentificativoIniziativa = '9999'
		where idheader= @idDoc

	end
	----FINE Se l'utente collegato non fa parte dell'azimaster, setto un default per l'IdentificativoIniziativa

	--INIZO Setta EnteProponente e RUPProponente	
	declare @enteprop nvarchar(MAX)
	set @enteprop=''

	select @enteprop=cast(pfuidazi as varchar(50)) from ProfiliUtente with(nolock) where IdPfu= @idUser
	--valorizzo @idUser se posso essere RupProponente altrimenti vuoto
	IF NOT EXISTS (  
				Select DMV_COD 
					from ELENCO_RESPONSABILI_AZI  
					where 
						RUOLO in ('RUP','RUP_PDG') 
						and idpfu = (select top 1 idpfu from ProfiliUtente where pfuIdAzi=@enteprop) 
						and DMV_Cod=@idUser
				)
	BEGIN
		set @idUser=0
	END
	  
	  
	  
	update document_bando 	
		set 
			EnteProponente = @enteprop + '#\0000\0000'	, 				
			RupProponente =  @idUser,
			Conformita = 'no'
		where idheader= @idDoc

	
	--FINE Setta EnteProponente e RUPProponente

	----recupero @EvidenzaPubblica_Parametro dai parametri
	----se si tratta di un invito (TipoBandoGara=3)
	--select @EvidenzaPubblica_Parametro = dbo.PARAMETRI('NUOVA_PROCEDURA-SAVE:INVITO','EvidenzaPubblica','DefaultValue','NULL',-1)
	--if @EvidenzaPubblica_Parametro <> 'NULL'  and @tb = '3'
	--begin
	--	update Document_Bando 
	--		set EvidenzaPubblica = @EvidenzaPubblica_Parametro
	--		where idheader= @idDoc
	--end
	
	----in caso di affidamento diretto avviso con destinatari
	----setto evidenza pubblica a NO
	--if @tb = '5' and @pg = '15583' 
	--begin
	--	update Document_Bando 
	--		set EvidenzaPubblica = '0'
	--		where idheader= @idDoc
	--end


END

GO
