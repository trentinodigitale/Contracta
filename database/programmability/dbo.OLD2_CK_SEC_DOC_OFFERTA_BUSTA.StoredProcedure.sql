USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_SEC_DOC_OFFERTA_BUSTA]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO










CREATE proc [dbo].[OLD2_CK_SEC_DOC_OFFERTA_BUSTA] ( @SectionName as VARCHAR(255), @IdLotto as VARCHAR(255) , @IdUser as VARCHAR(255), @NoSquenza int = 0)
as
begin

	--inserita perchè non restituiva record se faceva una insert
	SET NOCOUNT ON

	-- verifico se aa sezione puo essere aperta.
	-- sulle offerte il criterio di blocco è:
	-- si deve raggiungere la data apertura offerta
	-- i documenti devono essere aperti in sequenza di arrivo
	-- devono essere aperte prima le buste di documentazione poi quelle economiche

	declare @idPfu int
	declare @idPDA int
	declare @idOfferta int
	declare @idDoc int
	declare @NumeroLotto varchar(50)
	declare @TipoDoc as varchar(200)
	declare @IdBando as int
	declare @Blocco nvarchar(1000)
	declare @IdCommissione as int	
	declare @StatoTecnicoLotto as varchar(100)
	declare @jumpcheck as varchar(200)
	declare @StatoPDA as varchar(200)
	declare @Allegato nvarchar(4000)
	declare @conformita as varchar(50)
	declare @criterioaggiudicazionegara as varchar(50)
	declare @Controllo_superamento_importo_gara  varchar(10)
	declare @Visualizzazione_Offerta_Tecnica as varchar(100)

	declare @dzt_type_decrypt varchar(max) = ''
	declare @StatoFunzionaleOfferta varchar(100)
	declare @StatoRiga varchar(500)=''
	declare @InversioneBuste  int

	
	set @idPDA = null
	set @Blocco = ''
	set @IdCommissione=-1

	-- dal dettaglio si recupera il documento
	--select @idDoc = doc.id from  Document_MicroLotti_Dettagli d
	--	inner join CTL_DOC  doc on doc.id = d.idheader --and doc.TipoDoc in ( 'OFFERTA' )
	--	where d.id = @IdLotto


	--recupero numerolotto e idofferta
	select @Numerolotto = NumeroLotto, @IdOfferta = idheader , @idDoc = idheader   from document_microlotti_dettagli with(nolock) where id=@IdLotto
	

	-- compilatore del documento
	select @idPfu = idPfu , @StatoFunzionaleOfferta = StatoFunzionale  from CTL_DOC o with(nolock) where o.id = @IdDoc 


	-- il compilatore non ha vincoli sulle sezioni
	-- neppure gli OE indiretti se l'offerta risulta inviata
	if @IdUser  = @idPfu
		or 
		(	@StatoFunzionaleOfferta <> 'InLavorazione' 
			AND
			exists ( -- l'utente collegato appartiene ad una delle aziende che partecipano all'offerta

						select P.idpfu,idazi 
							from ctl_doc C1  with(nolock) 
								inner join document_offerta_partecipanti DO  with(nolock) on DO.idheader=c1.id and TipoRiferimento in ('RTI','ESECUTRICI') and Ruolo_Impresa <> 'Mandataria'
								inner join profiliutente P  with(nolock) on P.pfuidazi=DO.idazi
								inner join ProfiliUtenteAttrib PA  with(nolock) on PA.idpfu= P.idpfu and dztnome = 'Profilo' and attvalue = 'ACCESSO_DOC_OE'
							where linkeddoc=@idDoc	and P.idpfu=@IdUser	and c1.Deleted = 0 	
								
					)
		)

	begin
		select '' as Blocco
		return 
	end	

		
	-- recupero la PDA
	select @idPDA = p.id 
		from CTL_DOC o  with(nolock) 
			inner join CTL_DOC p  with(nolock) on o.LinkedDoc = p.LinkedDoc and p.TipoDoc = 'PDA_MICROLOTTI' and p.deleted=0
		where o.id = @IdDoc 
	
	-- se la PDA non esiste esco
	if @idPDA is null 
	BEGIN
		select  'Per aprire le buste è necessario avviare la procedura di aggiudicazione' as Blocco
		RETURN
	END
	
	--recupero id del bando
	select @jumpcheck=jumpcheck,@IdBando=linkeddoc,@StatoPDA=statofunzionale--,@conformita=conformita , @criterioaggiudicazionegara=criterioaggiudicazionegara
		from 
			ctl_doc  with(nolock) --inner join document_pda_testata on id=idheader
		where id=@IdPDA

	-- recupero informazioni di controllo dal Bando
	select 
			@Controllo_superamento_importo_gara=ISNULL(Controllo_superamento_importo_gara,'') ,
			@Visualizzazione_Offerta_Tecnica =  ISNULL(Visualizzazione_Offerta_Tecnica,'una_fase'),
			@InversioneBuste = isnull(InversioneBuste,0)
		from Document_Bando  with(nolock) 
		where idHeader=@IdBando


	
	-- se la busta risulta gia aperta non sono necessari altri controlli
	if  @Blocco = '' and exists( select * from CTL_DOC_Value D  with(nolock) where @IdDoc = D.idHeader and D.DSE_ID = @SectionName and D.DZT_Name = 'LettaBusta' and d.value = '1' and Row = @IdLotto )
	begin

		-- dalla PDA recupero lo stato del lotto in valutazione
		select @StatoRiga = StatoRiga from document_microlotti_dettagli with(nolock) where idheader = @IdPDA and tipodoc = 'PDA_MICROLOTTI' and NumeroLotto = @Numerolotto and voce = 0 

		if  @SectionName = 'OFFERTA_BUSTA_TEC'  and  ( @Visualizzazione_Offerta_Tecnica = 'due_fasi' and @StatoRiga in ('InValutazione','daValutare','PrimaFaseTecnica') )
		BEGIN
			select 'BUSTA TECNICA NON DISPONIBILE. Essendo una gara "due fasi" i valori per la valutazione sono visibili nella Scheda Valutazione fino all''esecuzione del comando Chiusura punteggio tecnico' as Blocco
			return
		END
		ELSE		
		BEGIN			
			select '' as Blocco
			return 		
		END
		
	end


	select @conformita=conformita , @criterioaggiudicazionegara=criterioaggiudicazionegara from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO where @IdBando = IdBando and N_Lotto = @NumeroLotto


	if @StatoPDA = 'VERIFICA_AMMINISTRATIVA'
	begin
		select  'Per aprire la busta è necessario terminare la fase amministrativa' as Blocco
		return
	end


	--la busta tecnica non si deve aprire se nella cronologia della PDA non è presente PDA_AVVIO_APERTURE_BUSTE_TECNICHE
	--if NOT EXISTS ( Select APS_ID_DOC from CTL_ApprovalSteps where APS_ID_DOC=@idPDA and APS_Doc_Type='PDA_MICROLOTTI' and APS_State='PDA_AVVIO_APERTURE_BUSTE_TECNICHE') and ( @criterioaggiudicazionegara = '15532' or @criterioaggiudicazionegara = '25532' )

	if ( @criterioaggiudicazionegara = '15532' or @criterioaggiudicazionegara = '25532' ) and @SectionName = 'OFFERTA_BUSTA_TEC' 
	BEGIN
		if NOT EXISTS ( Select APS_ID_DOC from CTL_ApprovalSteps  with(nolock) where APS_ID_DOC=@idPDA and APS_Doc_Type='PDA_MICROLOTTI' and APS_State='PDA_AVVIO_APERTURE_BUSTE_TECNICHE') 
		begin
			select 'Per aprire la busta tecnica è necessario aver avviato la fase di apertura delle buste tecniche dalla Procedura di aggiudicazione sezione "Valutazione Tecnica"' as Blocco
			return
		end
	END

	--recupero documento commissione e se esiste faccio i controlli
	--altrimenti sono le vecchie PDA
	select @IdCommissione=ID from ctl_doc  with(nolock) where deleted=0 and linkedDoc=@IdBando and tipodoc='COMMISSIONE_PDA' and statofunzionale='pubblicato'  and JumpCheck=@jumpcheck
	
	--select jumpcheck,ID from ctl_doc where deleted=0 and linkedDoc=69141 and tipodoc='COMMISSIONE_PDA' and statofunzionale='pubblicato'  and JumpCheck=@jumpcheck
	

	
	--if @IdCommissione<>-1 and @Blocco = ''
	if @Blocco = ''
	begin

		set @Blocco = 'Apertura busta non possibile. Utente non abilitato'
		--recupero stato del lotto
		select @StatoTecnicoLotto=LP.statoriga
			from Document_MicroLotti_Dettagli L  with(nolock) 
				inner join Document_PDA_OFFERTE o  with(nolock) on o.IdMsgFornitore = L.IdHeader  
				inner join CTL_DOC D  with(nolock) on D.id = o.idHeader and d.deleted = 0
				inner join Document_MicroLotti_Dettagli LP  with(nolock) on o.idheader = LP.IdHeader and LP.TipoDoc = 'PDA_MICROLOTTI' and LP.NumeroLotto = L.NumeroLotto  and LP.Voce = 0 --and LP.StatoRiga = 'escluso'

			where L.id = @idLotto --48717

--			select LP.statoriga,l.*
--			from Document_MicroLotti_Dettagli L 
--				inner join Document_PDA_OFFERTE o on o.IdMsgFornitore = L.IdHeader  
--				inner join CTL_DOC D on D.id = o.idHeader and d.deleted = 0
--				inner join Document_MicroLotti_Dettagli LP on o.idheader = LP.IdHeader and LP.TipoDoc = 'PDA_MICROLOTTI' and LP.NumeroLotto = L.NumeroLotto  and LP.Voce = 0 --and LP.StatoRiga = 'escluso'
--			where L.id = 50408
				
		
		--se in uno stato finale sblocco per tutti
		if @StatoTecnicoLotto in ('NonGiudicabile','Deserta','interrotto','AggiudicazioneDef','NonAggiudicabile')
			set @Blocco = ''
			
		else
		begin
			
			set @Blocco = ''

			-- Effettuo Controllo in base al tipo di utente
			-- se BUSTA ECONOMICA solo presidente commissione C/A
			if @SectionName = 'OFFERTA_BUSTA_ECO'
			begin
				if @IdCommissione<>-1
				begin
    
				    --controllo che l'utente loggato è il presidente della commissione A		
				    if exists(select UtenteCommissione from	Document_CommissionePda_Utenti  with(nolock) where idheader=@IdCommissione and TipoCommissione='C')
				    begin
					    if NOT exists(select UtenteCommissione from	Document_CommissionePda_Utenti  with(nolock) where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='C' and UtenteCommissione=@IdUser)					
						    --set @Blocco = ''
						    set @Blocco = 'Apertura busta economica non possibile. Utente non abilitato'
				    end
				    else
				    begin
					    if NOT exists(select UtenteCommissione from	Document_CommissionePda_Utenti  with(nolock) where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='A' and UtenteCommissione=@IdUser)					
						    --set @Blocco = ''
						    set @Blocco = 'Apertura busta economica non possibile. Utente non abilitato'
				    end
				end
			end
						
			-- se BUSTA TECNICA presidente commissione B se valutazione tecnica in corso
			--				   presidente commissione A se valutazione tecnica conclusa
			if @SectionName = 'OFFERTA_BUSTA_TEC' 
			begin

				if  @conformita <> 'ex-post' 
				begin
				    
				    --controllo che ho avviato la fase tecnica
				    if NOT EXISTS ( Select * from CTL_ApprovalSteps  with(nolock) where APS_ID_DOC=@idPDA and APS_Doc_Type='PDA_MICROLOTTI' and APS_State='PDA_AVVIO_APERTURE_BUSTE_TECNICHE')
					   set @Blocco = 'Per aprire la busta tecnica è necessario aver avviato la fase di apertura delle buste tecniche dalla Procedura di aggiudicazione sezione "Valutazione Tecnica"'
				    
				    
    				if @Blocco = ''
				    begin
					   if  @StatoTecnicoLotto not in ( 'InValutazione','daValutare' )
					   begin
						  set @Blocco = 'Per aprire la busta tecnica è necessario essere nella fase di valutazione tecnica del lotto'
					   end
				    end

				end
				else
				begin
				    --se conformita ex-post deve esistere il doc di conformita legato al lotto
				   -- if not exists(	
						 -- select * 
							-- from ctl_doc C
							--	inner join document_microlotti_dettagli CD on CD.idheader=C.id and CD.tipodoc = C.tipodoc and CD.NumeroLotto = @Numerolotto
							-- where  C.tipodoc='CONFORMITA_MICROLOTTI' and C.linkeddoc = @idPDA and Deleted = 0 
						 -- )
					  
					  --set @Blocco = 'Per aprire la busta tecnica è necessario aver avviato la fase di conformita'

					  -- IL CONTROLLO SI E' MODIFICATO
					--if NOT EXISTS ( select * from ctl_doc where  tipodoc='CONFORMITA_MICROLOTTI' and linkeddoc = @idPDA and Deleted = 0 )
					-- verifico che per l'offerta sia stato calcolato il punteggio complessivo. la presenza del valore ci  garanatisce che è stato eseguito il calcolo economico
					if not exists( select * 
										from document_pda_offerte p with(nolock) 
											inner join document_microlotti_dettagli d with(nolock) on d.idheader = p.idrow and d.tipodoc = 'PDA_OFFERTE' and d.voce = 0  and D.NumeroLotto = @Numerolotto and isnull( d.valoreofferta , '' ) <> '' 
										where  p.idheader = @idPDA and p.IdMsg = @idOfferta
										)

					BEGIN					
						--set @Blocco = 'Per aprire la busta tecnica e'' necessario aver avviato la fase di conformita'
						set @Blocco = 'Per aprire la busta tecnica e'' necessario aver avviato il calcolo economico'
					END
						

				        	   
				end

				--controllo che l'utente loggato è il presidente della commissione B		

				if @Blocco=''
				begin
				    if @IdCommissione<>-1
				    begin
					   if NOT exists(select UtenteCommissione from	Document_CommissionePda_Utenti  with(nolock) where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='G' and UtenteCommissione=@IdUser)
						  set @Blocco = 'Apertura busta tecnica non possibile. Utente non abilitato'				    
				    end
				end


			end
		end
	end	




	--se il lotto è stato escluso esco

	if  @Blocco = ''  
		and exists( select * from Document_Pda_Escludi_Lotti  with(nolock) where numerolotto=@Numerolotto
								and idheader in (select id from ctl_doc  with(nolock) where tipodoc='escludi_lotti' and linkeddoc=@IdOfferta and iddoc=@idPDA and StatoFunzionale ='Confermato') and StatoLotto='Escluso')
		and not exists( -- non deve esistere il documento di riammissione per quel lotto
					select l.* 
						from Document_PDA_OFFERTE o with(nolock) 
							inner join ctl_doc r with(nolock) on r.LinkedDoc = o.IdRow and r.TipoDoc = 'ESITO_RIAMMISSIONE' and r.StatoFunzionale = 'Confermato' and r.Deleted = 0
							inner join ctl_doc_value l with(nolock) on l.IdHeader = r.id and l.DSE_ID = 'LOTTI_RIAMMESSI' and l.DZT_Name = 'NumeroLotto' and l.Value = @Numerolotto
							inner join ctl_doc_value s with(nolock) on s.IdHeader = r.id and s.DSE_ID = 'LOTTI_RIAMMESSI' and s.DZT_Name = 'SelRow' and s.Value = '1' and s.row = l.row
						where o.IdMsg = @IdOfferta and o.IdHeader = @idPDA
			)		

	begin
		set @Blocco = 'Il Lotto è stato Escluso'
	end

	--se il lotto è stato escluso revocato
	if  @Blocco = ''  and @StatoTecnicoLotto = 'Revocato'
	begin
		set @Blocco = 'Il Lotto è stato Revocato'
	end



	-- se la RDA risulta esclusa sulla PDA allora non è possibile aprire le restanti sezioni
--	if @Blocco = '' and exists( select * from Document_PDA_OFFERTE o
--						left outer join CTL_DOC_VALUE D on o.idMsg = D.idHeader and D.DSE_ID = 'BUSTA_DOCUMENTAZIONE' and D.DZT_Name = 'LettaBusta' 
--					where o.idHeader = @idPDA and o.StatoPDA in ( '1' , '99' ) and D.idHeader is null 
--							and o.idMsg  = @IdDoc
--						)
	--se l'offerta risulta esclusa oppure invalidata non posso proseguire
	if @Blocco = '' and exists(select * from Document_PDA_OFFERTE  with(nolock) where idHeader = @idPDA and StatoPDA in ( '1' , '99' ) and idMsg  = @IdDoc)      
		set @Blocco = 'Lo stato del documento non consente l''apertura della busta'


		
	--per aprire la sezione economica verifichiamo che tutte le BUSTA_DOCUMENTAZIONE sono aperte
	if @SectionName = 'OFFERTA_BUSTA_ECO' and @Blocco = ''
	begin
		if exists( select * from Document_PDA_OFFERTE o with(nolock) 
						left outer join CTL_DOC_VALUE D  with(nolock) on o.idMsg = D.idHeader and D.DSE_ID = 'BUSTA_DOCUMENTAZIONE' and D.DZT_Name = 'LettaBusta' 
					where o.idHeader = @idPDA and o.StatoPDA not in ( '1' , '99' ) and D.idHeader is null )
		begin
			set @Blocco = 'Per aprire la busta Economica è necessario aprire prima tutte le buste di documentazione'
		end

	end



	--per aprire la sezione tecnica verifichiamo che tutte le BUSTA_DOCUMENTAZIONE sono aperte
	if @SectionName = 'OFFERTA_BUSTA_TEC' and @Blocco = ''
	begin
		if exists( select * from Document_PDA_OFFERTE o with(nolock) 
						left outer join CTL_DOC_VALUE D  with(nolock) on o.idMsg = D.idHeader and D.DSE_ID = 'BUSTA_DOCUMENTAZIONE' and D.DZT_Name = 'LettaBusta' 
					where o.idHeader = @idPDA and o.StatoPDA  not in ( '1' , '99' )  and D.idHeader is null )
		begin
			set @Blocco = 'Per aprire la busta Tecnica è necessario aprire prima tutte le buste di documentazione'
		end

	end	

	--per aprire la sezione economica verifichiamo la busta tecnica sia aperta
	--solo se prevista la busta tecnica (conformita = ex-ante oppure criterioaggiuiducazione gara=econ. più vantaggiosa)
	if @criterioaggiudicazionegara='15532' or @criterioaggiudicazionegara='25532' or  @conformita='Ex-Ante' 
	begin

		--per aprire la sezione economica verifichiamo la busta tecnica sia aperta
		if @SectionName = 'OFFERTA_BUSTA_ECO' and @Blocco = ''
		begin
			if not exists( select * from CTL_DOC_Value D  with(nolock) where @IdDoc = D.idHeader and D.DSE_ID = 'OFFERTA_BUSTA_TEC' and D.DZT_Name = 'LettaBusta' and d.value = '1' and Row = @IdLotto )
			begin
				set @Blocco = 'Per aprire la busta Economica è necessario aprire prima la busta Tecnica'
			end

		end	
	end
		
	
	if @SectionName = 'OFFERTA_BUSTA_ECO' and @Blocco = ''
	begin
		if exists( 
		
					select L.id
						from Document_MicroLotti_Dettagli L  with(nolock) 
							inner join Document_PDA_OFFERTE o  with(nolock) on o.IdMsgFornitore = L.IdHeader  --L.TipoDoc = 'OFFERTA' and L.Voce = 0 
							inner join CTL_DOC D  with(nolock) on D.id = o.idHeader and d.deleted = 0
							inner join Document_MicroLotti_Dettagli LP  with(nolock) on o.idRow = LP.IdHeader and LP.TipoDoc = 'PDA_OFFERTE' and LP.NumeroLotto = L.NumeroLotto  and LP.StatoRiga = 'escluso' and LP.Voce = 0 
						
							where L.id = @idLotto
			 )
		begin
			set @Blocco = 'La busta non può essere aperta a causa di una esclusione tecnica'
		end

	end


	if @SectionName = 'OFFERTA_BUSTA_ECO' and @Blocco = ''
	begin
		if exists( 
		
					select L.id
						from Document_MicroLotti_Dettagli L  with(nolock) 
							inner join Document_PDA_OFFERTE o  with(nolock) on o.IdMsgFornitore = L.IdHeader  --L.TipoDoc = 'OFFERTA' and L.Voce = 0 
							inner join CTL_DOC D  with(nolock) on D.id = o.idHeader and d.deleted = 0
							inner join Document_MicroLotti_Dettagli LP  with(nolock) on d.id = LP.IdHeader and LP.TipoDoc = 'PDA_MICROLOTTI' and LP.NumeroLotto = L.NumeroLotto  and LP.StatoRiga in ( 'daValutare' , '' , 'InValutazione' , 'NonGiudicabile' ) and LP.Voce = 0 
						
							where L.id = @idLotto
			 )
			 and(  @criterioaggiudicazionegara='15532' or @criterioaggiudicazionegara='25532' or  @conformita='Ex-Ante' )
		begin
			set @Blocco = 'La busta non può essere aperta perchè non è terminata la valutazione tecnica'
		end

	end
	

	-- verifica la presenza della comunicazione amministrativa prima dell'apertura delle buste tecniche per gare non al prezzo
	if @SectionName = 'OFFERTA_BUSTA_TEC' and @Blocco = '' and @criterioaggiudicazionegara <> '15531'
	begin
		if not exists( 
					select * from CTL_DOC o with(nolock) 
						inner join Document_PDA_OFFERTE p  with(nolock) on p.idmsg = o.id
						inner join CTL_DOC D  with(nolock) on p.idheader = D.LinkedDoc 
												and substring( D.JumpCheck , 3 , 23 ) = 'VERIFICA_AMMINISTRATIVA' 
											--and d.StatoDoc = 'Sended' 
											and d.StatoFunzionale = 'Inviato' and d.Deleted = 0 
										where o.id = @IdDoc  
					) 
			--l'inversione delle buste non richiede il vincolo della presenza della comunicazione
			and @InversioneBuste=0
		begin
			set @Blocco = 'La busta tecnica non può essere aperta non è stata inviata la Comunicazione Verifica Amministrativa'
		end

	end





	-- verifico che il documento arrivato prima di questo sia stato aperto
	if @Blocco = ''
	begin


		-- se è la prima arrivata non esclusa si puo aprire
		if not exists( select top 1 * from Document_PDA_OFFERTE  with(nolock) 
					where @idPDA = idHeader 
						and idMsg = @IdDoc 
						and cast( NumRiga as int ) = ( select min(cast( NumRiga as int ))  from Document_PDA_OFFERTE  with(nolock) where @idPDA = idHeader and StatoPDA  not in ( '1' , '99' )  )
					)
		begin

			--recuper il numero lotto 
			select @NumeroLotto = NumeroLotto from dbo.Document_MicroLotti_Dettagli  with(nolock) where id = @IdLotto
			set @NumeroLotto = isnull( @NumeroLotto , '1' )



			-- se esiste una offerta arrivata prima che non è stata aperta blocco la busta
			if exists( select top 1 * from Document_PDA_OFFERTE  with(nolock) 
							where @idPDA = idHeader 
								and idMsg = @IdDoc 
								and cast( NumRiga as int ) > ( -- la prima busta non letta relativa al lotto in esame
													select min(cast( NumRiga as int ))  
														from Document_PDA_OFFERTE o with(nolock) 
	
															inner join Document_MicroLotti_Dettagli L  with(nolock) on o.IdMsgFornitore = L.IdHeader and L.TipoDoc = 'OFFERTA' and L.NumeroLotto = @NumeroLotto and L.Voce = 0 
															inner join Document_MicroLotti_Dettagli LP  with(nolock) on o.idRow = LP.IdHeader and LP.TipoDoc = 'PDA_OFFERTE' and LP.NumeroLotto = @NumeroLotto and LP.StatoRiga not in ( 'esclusoEco', 'escluso') and LP.Voce = 0 
															left outer join CTL_DOC_VALUE D  with(nolock) on o.idMsg = D.idHeader 
																								and D.DSE_ID = @SectionName 
																								and D.DZT_Name = 'LettaBusta' 
																								and D.Row = L.id
	
														where o.idHeader = @idPDA and o.StatoPDA  not in ( '1' , '99' )  and D.idHeader is null 
													
												)
						)
						-- viene esclusa dal controllo di sequenza la busta tecnica delle conformità ex-post
						and not ( @SectionName = 'OFFERTA_BUSTA_TEC'  and @conformita='ex-post'  )
						and @NoSquenza = 0
			begin
				set @Blocco = 'Per aprire la busta è necessario rispettare la sequenza di arrivo delle offerte'
			end
		end
	end


	-- se non ci sono blocchi per la busta allora si segna che è stata aperta
	if @Blocco = '' and left( @IdDoc , 3 ) <> 'new'
	begin
		if not exists( select * from CTL_DOC_VALUE D  with(nolock) where @IdDoc = D.idHeader and D.DSE_ID = @SectionName and D.DZT_Name = 'LettaBusta' and Row = @IdLotto )
		begin
			insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
				values ( @IdDoc , @SectionName , @IdLotto , 'LettaBusta' , '1' )
			
			--QUANDO APRE LA BUSTA TEC, SOLO LA PRIMA, TRACCIO LA CRONOLOGIA "Prima Seduta Tecnica <Lotto N° xxx>"
			IF @SectionName = 'OFFERTA_BUSTA_TEC'
			BEGIN
				insert into CTL_ApprovalSteps ( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
					select top 1 'PDA_MICROLOTTI' , @idPDA  , 'Ricognizione Offerte Tecniche <Lotto N° ' + @NumeroLotto +'>' , '', @IdUser , attvalue , 1 , getdate() 
						from profiliutenteattrib 
							left outer join CTL_ApprovalSteps on APS_ID_DOC=@idPDA and APS_Doc_Type='PDA_MICROLOTTI' and APS_State='Ricognizione Offerte Tecniche <Lotto N° ' + @NumeroLotto +'>'
								where idpfu = @IdUser and dztnome = 'UserRoleDefault' and CTL_ApprovalSteps.APS_ID_DOC IS null
			END


			--QUANDO APRE LA BUSTA ECO, SOLO LA PRIMA, TRACCIO LA CRONOLOGIA "Prima Seduta Tecnica <Lotto N° xxx>"
			IF @SectionName = 'OFFERTA_BUSTA_ECO'
			BEGIN
				insert into CTL_ApprovalSteps ( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
					select top 1 'PDA_MICROLOTTI' , @idPDA  , 'Apertura Offerte Economiche <Lotto N° ' + @NumeroLotto +'>' , '', @IdUser , attvalue , 1 , getdate() 
						from profiliutenteattrib 
							left outer join CTL_ApprovalSteps on APS_ID_DOC=@idPDA and APS_Doc_Type='PDA_MICROLOTTI' and APS_State='Apertura Offerte Economiche <Lotto N° ' + @NumeroLotto +'>'
								where idpfu = @IdUser and dztnome = 'UserRoleDefault' and CTL_ApprovalSteps.APS_ID_DOC IS null
			END




			declare @modellobando varchar(200)
			declare @modelloofferta varchar(200)
			declare @FiltroRighe varchar(200)
			declare @idRow int
			--recuper il numero lotto 
			select @NumeroLotto = NumeroLotto from dbo.Document_MicroLotti_Dettagli  with(nolock) where id = @IdLotto
			set @NumeroLotto = isnull( @NumeroLotto , '1' )
			set @FiltroRighe = ' NumeroLotto = ''' + @NumeroLotto  + ''''


			--recupero modello selezionato
			select @modellobando = b.TipoBando 
				from Document_Bando b  with(nolock) 
						inner join CTL_DOC d  with(nolock) on b.idHeader = d.LinkedDoc
				where d.id = @iddoc



			------------------------------------------------------------------------
			-- sulle offerte quando si apre la busta si decifra il contenuto
			------------------------------------------------------------------------
			if @SectionName = 'OFFERTA_BUSTA_ECO'
			begin 
				set @modelloofferta = 'MODELLI_LOTTI_' + @modellobando + '_MOD_Offerta'

				exec AFS_DECRYPT_DATI  @IdUser ,  'Document_MicroLotti_Dettagli' , 'BUSTA_ECONOMICA' ,  'idHeader'  ,  @IdDoc   ,@modelloofferta  , 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,NumeroRiga,idHeaderLotto' , @FiltroRighe , 1 
				-- Ricopio i dati legati alla parte di valutazione dell'offerta
				exec COPY_DATI_VALUTAZIONE_OFFERTA @IdDoc , @modelloofferta , @NumeroLotto
			
				select @Allegato = F1_SIGN_ATTACH from Document_Microlotto_Firme where idheader = @IdLotto
				exec AFS_DECRYPT_ATTACH  @IdUser ,    @Allegato , @idDoc-- @IdLotto		
				
				-- La stored deve creare il documento OFFERTA_ALLEGATI se mancante ed aggiungere i dati 
				 -- decrittografati degli allegati presenti nella busta al documento OFFERTA_ALLEGATI
				 exec POPOLA_OFFERTA_ALLEGATI  @idPDA , @IdOfferta , @NumeroLotto , @SectionName ,@IdUser,@modelloofferta	

			end 

			if @SectionName = 'OFFERTA_BUSTA_TEC' 
			begin
				
				set @modelloofferta = 'MODELLI_LOTTI_' + @modellobando + '_MOD_OffertaTec'

				--se il campo "visualizzazione offerta tecnica" ha il valore "due fasi" 
				--mettiamo a null tutti i campi del modello della busta tecnica tranne quelli di tipo allegato 
				if @Visualizzazione_Offerta_Tecnica = 'due_fasi'
				BEGIN
					set @Blocco='BUSTA TECNICA NON DISPONIBILE. Essendo una gara "due fasi" i valori per la valutazione sono visibili nella Scheda Valutazione fino all''esecuzione del comando Chiusura punteggio tecnico'									
					--SE TRA I CRITERI TECNICI DELLA GARA SONO PRESENTI ALLEGATI DA OSCURARE PER IL LOTTO VALORIZZO LA VARIABILE
					--CON LE COLONNE ALTRIMENTI CI METTO 18 per preservare quello fatto prima di questa seconda evoluzione
					set @dzt_type_decrypt='18'
					--VEDIAMO SE PER IL LOTTO ESISTE LA SPECIALIZZAZIONE DEI CRITERI
					IF EXISTS ( select v.Allegati_da_oscurare
									from Document_MicroLotti_Dettagli d 
										inner join Document_Microlotto_Valutazione v on v.TipoDoc = 'LOTTO' and v.idHeader = d.id and v.CriterioValutazione = 'quiz'
									where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando  and NumeroLotto = @NumeroLotto and Voce = 0 
									and ISNULL(v.Allegati_da_oscurare,'')<>''
								)
					BEGIN
						set @dzt_type_decrypt=''
						select @dzt_type_decrypt=@dzt_type_decrypt + v.Allegati_da_oscurare
									from Document_MicroLotti_Dettagli d 
										inner join Document_Microlotto_Valutazione v on v.TipoDoc = 'LOTTO' and v.idHeader = d.id and v.CriterioValutazione = 'quiz'
									where d.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and d.idheader = @idBando  and NumeroLotto = @NumeroLotto and Voce = 0 
									and ISNULL(v.Allegati_da_oscurare,'')<>''					
						
					END
					
					--VEDIAMO SE CI SONO QUELLI NON SPECIALIZZATI 
					ELSE IF EXISTS ( select v.Allegati_da_oscurare
										from Document_Microlotto_Valutazione v
										where v.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and v.idheader = @idBando  and v.CriterioValutazione = 'quiz'
										and ISNULL(v.Allegati_da_oscurare,'')<>''
								)
					BEGIN
						set @dzt_type_decrypt=''
						select @dzt_type_decrypt=@dzt_type_decrypt + v.Allegati_da_oscurare
									from Document_Microlotto_Valutazione v
										where v.TipoDoc in (  'BANDO_SEMPLIFICATO' , 'BANDO_GARA' ) and v.idheader = @idBando  and v.CriterioValutazione = 'quiz'
										and ISNULL(v.Allegati_da_oscurare,'')<>''					
						
					END
					
					set @dzt_type_decrypt=REPLACE(@dzt_type_decrypt,'###',',')
					set @dzt_type_decrypt=REPLACE(@dzt_type_decrypt,'.',',')
				END
				
				exec AFS_DECRYPT_DATI  @IdUser ,  'Document_MicroLotti_Dettagli' , 'BUSTA_TECNICA' ,  'idHeader'  ,  @IdDoc   ,@modelloofferta  , 'id,idheader,TipoDoc,NumeroLotto,Voce,Variante,CIG,Descrizione,EsitoRiga,NumeroRiga,idHeaderLotto' , @FiltroRighe  , 1 ,@dzt_type_decrypt
				-- Ricopio i dati legati alla parte di valutazione dell'offerta
				exec COPY_DATI_VALUTAZIONE_OFFERTA @IdDoc , @modelloofferta , @NumeroLotto

				select @Allegato = F2_SIGN_ATTACH from Document_Microlotto_Firme where idheader = @IdLotto
				exec AFS_DECRYPT_ATTACH  @IdUser ,    @Allegato , @idDoc -- @IdLotto			

				-- eseguo la VALUTAZIONE TECNICA DEL LOTTO
				select @idRow = LO.id
							from 
								CTL_DOC m  with(nolock) 
								inner join CTL_DOC D  with(nolock) on d.deleted = 0 and  m.LinkedDoc = d.linkedDoc and d.TipoDoc = 'PDA_MICROLOTTI'
								inner join Document_PDA_OFFERTE o  with(nolock) on o.IdMsgFornitore = m.id and d.id = o.idheader
								inner join Document_MicroLotti_Dettagli LO  with(nolock) on LO.IdHeader = o.idRow and LO.TipoDoc = 'PDA_OFFERTE' 
							where   m.id = @IdDoc and LO.NumeroLotto = @NumeroLotto and Voce = 0 

				exec PDA_VALUTAZIONE_TEC_ELAB_LOTTO @idRow

				


				 -- La stored deve creare il documento OFFERTA_ALLEGATI se mancante ed aggiungere i dati 
				 -- decrittografati degli allegati presenti nella busta al documento OFFERTA_ALLEGATI
				 exec POPOLA_OFFERTA_ALLEGATI  @idPDA , @IdOfferta , @NumeroLotto , @SectionName ,@IdUser,@modelloofferta

				 --QUANDO SIAMO SULLE DUE FASI
				 --SPOSTO IL RIFERIMENTO TECNICO DEL FILE DELLA BUSTA TECNICA FIRMATA NEL CAMPO f4, il quale verrà ripristinato
				 --dal comando Chiusura punteggio tecnico
				if @Visualizzazione_Offerta_Tecnica = 'due_fasi'
				BEGIN
					update Document_Microlotto_Firme set F4_SIGN_ATTACH=F2_SIGN_ATTACH
						where idheader = @IdLotto

					update Document_Microlotto_Firme set F2_SIGN_ATTACH=NULL
						where idheader = @IdLotto and ISNULL(F4_SIGN_ATTACH,'')<>''

				END
			end


			-- se si apre la busta economica e la SYS dice che si deve fare la verifica di base asta in apertura
			if @SectionName = 'OFFERTA_BUSTA_ECO' 
				and (
						@Controllo_superamento_importo_gara = 'si' or
						( @Controllo_superamento_importo_gara = '' and exists( select * from  LIB_Dictionary  with(nolock) where DZT_Name = 'SYS_VERIFICA_SUPERAMENTO_BASE_ASTA' and DZT_ValueDef = 'PDA' ) )
					) 					
			begin
				exec VerificaBaseAstaOffertaLotto @IdUser , @idPDA , @IdLotto , @IdDoc
			end
		end	

	end
	
	select @Blocco as Blocco

end



























GO
