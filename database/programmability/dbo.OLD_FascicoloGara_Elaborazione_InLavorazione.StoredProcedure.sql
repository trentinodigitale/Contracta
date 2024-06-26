USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_FascicoloGara_Elaborazione_InLavorazione]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







--Versione=1&data=2022-05-11&Attivita=450375&Nominativo=EP
CREATE PROCEDURE [dbo].[OLD_FascicoloGara_Elaborazione_InLavorazione] ( @IdDoc as int )
AS
BEGIN

	declare @Fascicolo as varchar(50)
	declare @IdGara as int
	declare @TipoDoc_Gara as varchar(100)
	declare @GeneraConvenzione as char(1)
	declare @Divisione_Lotti as varchar(1)
	--recupero il fascicolo di gara
	select @Fascicolo = fascicolo from ctl_doc with (nolock) where id = @IdDoc

	--recupero id gara 
	select 
		@IdGara = id , @TipoDoc_Gara = TipoDoc, @GeneraConvenzione = isnull(GeneraConvenzione,'0'), 
		@Divisione_Lotti = Divisione_lotti
		from 
			ctl_Doc with (nolock) 
				inner join document_bando with (nolock) on idheader = id
		where 
			tipodoc in ('BANDO_GARA','BANDO_SEMPLIFICATO') and fascicolo = @Fascicolo 
			and statofunzionale  = 'Chiuso' and Deleted = 0 
	
	--recupero i quesiti inviati dagli OE 
	select 
		id 
		into #Temp_Quesiti_Inviati
			from 
				document_chiarimenti  with (nolock)
			where 
					domanda<>'' and isnull(protocol,'') <>'' 
					and id_origin = @IdGara
			order by datacreazione desc
	
	--recupero le risposte ai quesiti 
	select 
		id 
		into #Temp_Quesiti_Risposte
			from 
				document_chiarimenti  with (nolock)
			where 
					isnull ( ProtocolRispostaQuesito,'') <>'' and statofunzionale in ('Evaso','Pubblicato')
					and id_origin = @IdGara
			order by datacreazione desc	 
		 

	
	--SE LA GARA SFOCIA IN CONVEZIONE,per tutti i cig contentuti nella gara, AGGIUNGO LISTINO_CONVEZIONE E CONTRATTO_CONVENZIONE
	--recupero cig della gara 
	if @GeneraConvenzione ='1'
	begin

		select top 0 '12345678901234567890' as cig into #Temp_Cig_Gara
		
		--gara monolotto
		if @Divisione_Lotti = '0'
		begin
			insert into #Temp_Cig_Gara
					(cig)
				select cig
					from 
						document_bando with (nolock) 
					where 
						idHeader = @IdGara and isnull(cig,'')<>''
		end
		else
		begin
			insert into #Temp_Cig_Gara
					(cig)
				select distinct cig
				
					from 
						document_microlotti_dettagli with (nolock) 
					where 
						idheader = @IdGara  and tipodoc = @TipoDoc_Gara and isnull(cig,'')<>''
		end
		
		--recupero tutti i documenti convenzione diversi da in lavorazione che hanno i cig della gara
		if exists (select top 1 cig from #Temp_Cig_Gara)
		begin
			select 
				distinct C.id 
				into #Temp_Convenzioni
				from 
					ctl_doc C with (nolock)
						inner join document_microlotti_dettagli DC with (nolock) on DC.idheader = C.id 
																				and DC.TipoDoc = C.TipoDoc 			
				where 
					C.Tipodoc='CONVENZIONE' and StatoFunzionale <> 'InLavorazione' and c.Deleted =0
					and cig in (select * from #Temp_Cig_Gara)
		end

		if exists (select * from #Temp_Convenzioni)
		begin
			select 
				id 
					into #Temp_List_Contr_Convenzioni
				from 
					ctl_doc with (nolock)
				where tipodoc in ('LISTINO_CONVENZIONE','CONTRATTO_CONVENZIONE') and Deleted = 0
						and StatoFunzionale <> 'InLavorazione'
						and LinkedDoc in (select id from #Temp_Convenzioni)
		end

	end
	

	--POPOLO LA TABELLA DEI DOCUMENTI CON I DOCUMENTI CHE HANNO IL FASCICOLO DELLA GARA
	insert into Document_Fascicolo_Gara_Documenti
		( [IdHeader], [IdDoc], [TipoDoc], [Protocollo], [Titolo], [DataInvio], [Esito], [NumRetry], [GeneraPdf])
		
		select 
			@IdDoc as IdHeader, id as IdDoc, Tipodoc , ISNULL( Protocollo , '' ) , isnull(Titolo,'') as Titolo , DataInvio ,'',0, 
			case 
					when  DOC_PDF.REL_ValueOutput is not null then 1
					else 0
				end as GeneraPdf

			from 
				ctl_Doc with (nolock) 
					left join
						( select 
								REL_ValueOutput  
							from 
								ctl_relations with (nolock) 
							where 
								rel_type='FASCICOLO_GARA' and REL_ValueInput  in ( 'DOCUMENTI_GENERA_PDF')
								 ) as DOC_PDF on DOC_PDF.REL_ValueOutput = Tipodoc 
	    	where 
				fascicolo = @Fascicolo 
				
				and deleted = 0

				--ESCLUDO I DOC INDICATI DA UNA RELAZIONE
				and Tipodoc not in ( select 
											REL_ValueOutput  
										from 
											ctl_relations with (nolock) 
										where 
											rel_type='FASCICOLO_GARA' and REL_ValueInput ='DOCUMENTI_DA_ESCLUDERE'
									)
				
				and ( 
						( statofunzionale <> 'InLavorazione' ) or ( statodoc in ('Evasa') )  
					)  
				
				--escludiamo dall'elenco dei docuimenti le comunicazioni di dettaglio invalidate
				and not ( Tipodoc='PDA_COMUNICAZIONE_GARA' and statofunzionale='Invalidato' ) 
		
			order by ID
		
		
		
		--andiamo ad aggiungere eventuali documenti da mappare tramite la relazione FASCICOLO_GARA_MAPPATURA_DOCUMENTI  
		insert into Document_Fascicolo_Gara_Documenti
		( [IdHeader], [IdDoc], [TipoDoc], [Protocollo], [Titolo], [DataInvio], [Esito], [NumRetry], [GeneraPdf])
		
		select 
			@IdDoc as IdHeader, id as IdDoc, FG_MA.REL_ValueOutput as Tipodoc , ISNULL( Protocollo , '' ) , isnull(Titolo,'') as Titolo , DataInvio ,'',0,0
			

			from 
				ctl_Doc with (nolock)
				inner join
						( select 
								REL_ValueOutput, REL_ValueInput
							from 
								ctl_relations with (nolock) 
							where 
								rel_type='FASCICOLO_GARA_MAPPATURA_DOCUMENTI' 
								 ) as FG_MA on FG_MA.REL_ValueInput = Tipodoc 
			where 
				fascicolo = @Fascicolo 
				
				
				and deleted = 0
				order by ID

	
	--SE LA GARA SFOCIA IN CONVEZIONE CONVENZIONE, AGGIUNGO LISTINO CONVENZIONE E CONTRATTO_CONVENZIONE
	--SE NON SONO GIA' PRESENTI NELLA TABELLA DEI DOCUMENTI
	if @GeneraConvenzione ='1'
	begin
		if exists (select * from #Temp_Convenzioni)
		begin
			insert into Document_Fascicolo_Gara_Documenti
				( [IdHeader], [IdDoc], [TipoDoc], [Protocollo], [Titolo], [DataInvio], [Esito], [NumRetry], [GeneraPdf])
			select 
				@IdDoc as IdHeader, id as IdDoc, Tipodoc , ISNULL( Protocollo , '' ) , isnull(Titolo,'') as Titolo , DataInvio ,'',0, 0	
					from 
						ctl_doc with (nolock)
						
					where id in (
							select id from #Temp_Convenzioni
							union 
							select id from #Temp_List_Contr_Convenzioni
						)
						and 
						id not in (select iddoc from Document_Fascicolo_Gara_Documenti with (nolock) where idheader = @IdDoc )
					
		end
	end

	--AGGIUNGO i QUESITI INVIATI
	if exists ( select top 1 id from #Temp_Quesiti_Inviati )
	begin
		insert into Document_Fascicolo_Gara_Documenti
			( [IdHeader], [IdDoc], [TipoDoc], [Protocollo], [Titolo], [DataInvio], [Esito], [NumRetry], [GeneraPdf])
		select 
			@IdDoc as IdHeader, id as IdDoc, 'DETAIL_CHIARIMENTI_BANDO_DOMANDA' , ISNULL( Protocol , '' )  
			,'Quesito Inviato' as Titolo , DataCreazione  ,'',0, 1 as GeneraPdf	
				from 
					document_chiarimenti with (nolock)
					where id in ( select id from #Temp_Quesiti_Inviati)
					
		
	end

	--AGGIUNGO QUESITI INVIATI PER I QUALI RICHIEDO IL PDF 
	if exists ( select top 1 id from #Temp_Quesiti_Risposte  )
	begin
		insert into Document_Fascicolo_Gara_Documenti
			( [IdHeader], [IdDoc], [TipoDoc], [Protocollo], [Titolo], [DataInvio], [Esito], [NumRetry], [GeneraPdf])
		select 
			@IdDoc as IdHeader, id as IdDoc, 'DETAIL_CHIARIMENTI_BANDO_RISPOSTA' , ISNULL( ProtocolRispostaQuesito , '' )  
			,'Risposta Quesito' as Titolo , DataRisposta  ,'',0, 0 as GeneraPdf	
				from 
					document_chiarimenti with (nolock)
					where id in ( select id from #Temp_Quesiti_Risposte)
					
		
	end

	--prima di aggiornare lo stato funzionale se la colonna titolo è vuota la rettifico con il valore della colonna TipoDoc
	update 
		DF
		SET DF.TITOLO= 
			case 
				when dbo.GetValue('CUSTOM_CAPTION',convert(varchar(MAX),doc_param)) ='caption' then D.Caption
					 else ISNULL(ML_DESCRIPTION,DF.TipoDoc)
			end

		from
				Document_Fascicolo_Gara_Documenti DF
					left join CTL_DOC D with (nolock) on D.Id = DF.IdDoc 
					left join LIB_Documents with (nolock) on doc_id = DF.TipoDoc	
					left join lib_multilinguismo with (nolock) on ml_key= doc_descml and ml_LNG='I'	
			where 
				IdHeader=@IdDoc and DF.titolo = ''


	--aggiorno lo stato funzionale del documento in GenerazionePDF
	update ctl_Doc set StatoFunzionale = 'GenerazionePDF' where id = @IdDoc

END -- Fine stored









GO
