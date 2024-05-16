USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GET_DATI_SCHEDA_PCP_OFFERTE_PRESENTATE]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  PROCEDURE [dbo].[GET_DATI_SCHEDA_PCP_OFFERTE_PRESENTATE] 
	( @IdContratto int , @Contesto varchar(100) )
AS
BEGIN
	SET NOCOUNT ON;
	
	--@Contesto='LOTTI' restituisce I CIG DEL CONTRATTO con il quadro economico
	--@Contesto='PARTECIPANTI' restituisce i partecipanti ad ogni CIG
	--RESTITUISCE PER UNA SCHEDA A1_29 LA LISTA DEI CIG
	--AGGIUDICATI NEL CONTRATTO E PER OGNUNO I PARTECIPANTI
	

	declare @IdPda as int
	declare @IdGara as int
	declare @Divisione_lotti as varchar(10)
	declare @Cig as varchar (100)
	declare @TipoAppaltoGara as varchar(100)

	--declare @IdContratto int 

	--set @IdContratto = 481065

	--DAL CONTRATTO RECUPERO LA PDA COLLEGATA e LA GARA 
	select 
		@Idpda=COM.linkeddoc , @IdGara = PDA.linkeddoc , 
		@Divisione_lotti = DG.Divisione_lotti, @Cig=DG.CIG , @TipoAppaltoGara = TipoAppaltoGara
		from CTL_DOC C
			inner join CTL_DOC COM with (nolock) on COM.id=C.linkeddoc
			inner join ctl_Doc PDA with (nolock) on PDA.id=COM.linkeddoc 
			inner join Document_Bando DG with (nolock) on DG.idHeader=PDA.linkeddoc
		where
			C.Id=@IdContratto
	
	--tab dei lotti del contratto
	CREATE TABLE #lotticontratto
	(
		numeroLotto varchar(50) collate DATABASE_DEFAULT NULL ,
		CIG nvarchar(50)  collate DATABASE_DEFAULT NULL 
	)

	--select * from #lotticontratto
	

	if	@Divisione_lotti = '0'
	begin
		-- PER LE GARE MONOLOTTO
		INSERT INTO #lotticontratto( numeroLotto, cig )
						values ( '1', @Cig )
		--select '1' as numeroLotto , @Cig as cig  into #lotticontratto
	end
	else
	begin

		--DAL CONTRATTO MI RECUPERO I CIG AGGIUDICATI (voce=0)
		insert into #lotticontratto(numeroLotto,CIG)
			select 
				NumeroLotto , CIG 
				from 
					document_microlotti_dettagli with (nolock)
				where idheader=@IdContratto and tipodoc='CONTRATTO_GARA' and Voce=0  
	end

	--select * from #lotticontratto
	
	--recuperiamo il quadro economico standard dalla gara @IdGara
				--"impLavori": "double",
	 --             "impServizi": "double",
	 --             "impForniture": "double",
	 --             "impTotaleSicurezza": "double",
	 --             "ulterioriSommeNoRibasso": "double",
	 --             "impProgettazione": "double",
	 --             "sommeOpzioniRinnovi": "double",
	 --             "sommeRipetizioni": "double",
	 --             "#sommeADisposizione*": "double"

	if @Contesto='LOTTI'
	BEGIN
		select 
			CONTR.*,
			case
				when @TipoAppaltoGara=2 then ValoreImportoLotto
				else 0
			end as impLavori,
			case
				when @TipoAppaltoGara=3 then ValoreImportoLotto
				else 0
			end as impServizi,
			case
				when @TipoAppaltoGara=1 then ValoreImportoLotto
				else 0
			end as impForniture,

			IMPORTO_ATTUAZIONE_SICUREZZA as impTotaleSicurezza,
			ltrim( str( isnull(DETT_GARA.pcp_UlterioriSommeNoRibasso,0) , 25 , 2 ) ) as ulterioriSommeNoRibasso,
			ltrim( str( isnull(DETT_GARA.impProgettazione ,0), 25 , 2 ) ) as impProgettazione,
			ltrim( str( isnull(DETT_GARA.pcp_SommeOpzioniRinnovi,0) , 25 , 2 ) ) as sommeOpzioniRinnovi,
			ltrim( str( isnull(DETT_GARA.pcp_SommeADisposizione,0) , 25 , 2 ) ) as sommeADisposizione ,
			ltrim( str( isnull(DETT_GARA.pcp_SommeRipetizioni,0) , 25 , 2 ) ) as sommeRipetizioni

			from
				#lotticontratto CONTR
				inner join
					Document_MicroLotti_Dettagli DETT_GARA on DETT_GARA.NumeroLotto = CONTR.numeroLotto and DETT_GARA.voce =0
			where
				DETT_GARA.IdHeader = 481038 and TipoDoc='bando_Gara'
	END
	 
	--select COM.linkeddoc as IdPda, PDA.linkeddoc as Idgara
	--	from CTL_DOC C
	--		inner join CTL_DOC COM with (nolock) on COM.id=C.linkeddoc
	--		inner join ctl_Doc PDA with (nolock) on PDA.id=COM.linkeddoc 
	--	where
	--		C.Id=481065

	--pda 326340
	--gara 307730
	
	--SE CONTESTO PARTECIPANTI RECUPERO I PARTECIPANTI 
	--"#idPartecipante
	--importo
	--aggiudicatario
	--ccnl ???
	if @Contesto='PARTECIPANTI'
	BEGIN
		select 
	
			CONTR.*, 
			--PDA.Aggiudicata , o.idAziPartecipante,
			Offe.guid as idPartecipante, od.ValoreImportoLotto as importo,
			case 
				when PDA.Aggiudicata = o.idAziPartecipante then 'true'
				else 'false'
			end as aggiudicatario

			from 
			#lotticontratto CONTR
				inner join document_microlotti_dettagli PDA  with(nolock)
					on CONTR.NumeroLotto=PDA.NumeroLotto collate DATABASE_DEFAULT
				--vado a prendere ipartecipanti al lotto
				inner join Document_PDA_OFFERTE o with(nolock) on PDA.idheader =  o.idheader
				inner join CTL_DOC Offe with(nolock) on Offe.Id = o.IdMsg
				inner join Document_MicroLotti_Dettagli od with(nolock) 
						on o.idRow = od.idHeader and od.tipoDoc = 'PDA_OFFERTE' and od.NumeroLotto = PDA.NumeroLotto and od.voce = 0
				
			where  pda.idheader=@IdPda and pda.tipodoc='PDA_MICROLOTTI' and PDA.voce=0
				order by cast(PDA.Numerolotto as int)

	END

	drop table #lotticontratto
	return
	

	
	--select * from ctl_doc where id in (326340,307730)
	--SE GARA A LOTTI ALLORA PER GNI CIG DEL CONTRATTO OTTENGO LA LISTA DEI PARTECIPANTI
	--IN QUESTO MODO
		--RECUPERO ID DELLA RIGA PDA_MICROLOTTI CON QUEL CIG
			--select id from document_microlotti_Dettagli where = <idpda> AND cig=<CIG>
		--la lista dei partecipanti a quel CIG e'
			--select ValoreImportoLotto ,* from PDA_DRILL_MICROLOTTO_LISTA_VIEW where IdRowLottoBando = <id dell ariga pda_microlotti >
	
	--SE GARA MONOLOTTO LA LISTA DEI PARTECIPANTI E DATA 
	    -- IL cig E UNICO quello sulla testata
		--select * from PDA_DRILL_MICROLOTTO_LISTA_MONOLOTTO_VIEW where idPDA =481001

END







GO
