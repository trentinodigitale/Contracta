USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_CK_SEC_DOC_OFFERTA_MIGLIORATIVA_RISP]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[OLD2_CK_SEC_DOC_OFFERTA_MIGLIORATIVA_RISP] ( @SectionName as VARCHAR(255), @IdDoc as VARCHAR(255) , @IdUser as VARCHAR(255))
as
begin
	
	--inserita perchè non restituiva record se faceva una insert
	SET NOCOUNT ON

	-- verifico se aa sezione puo essere aperta.
	-- sulle offerte migliorative il criterio di blocco è:
	-- Deve essere il chi ha creato il documento
	-- i documenti devono essere aperti dal presidente della Commissione C
	

	declare @idPfu int
	declare @idPDA int
	set @idPDA = null
	declare @Blocco nvarchar(1000)
	set @Blocco = ''
	declare @TipoDoc as varchar(200)
	declare @IdBando as int
	declare @IdCommissione as int
	declare @divisione_lotti  varchar(10)
	declare @StatoFunzionale varchar(100)
	declare @CriterioAggiudicazioneGara varchar(100)
	declare @Allegato nvarchar(4000)
	declare @idRow int
	declare @Conformita varchar(100)
	declare @query as nvarchar(MAX)
	declare @ColToExclud as nvarchar(MAX)
	set @Allegato=''
	declare @id_PDA int
	declare @numero_lotto as int
	declare @idlotto as int
	


	select @IdBando=c3.LinkedDoc,@TipoDoc=c3.JumpCheck
		from ctl_doc c
		inner join ctl_doc c1 on c1.id=c.LinkedDoc and c1.TipoDoc='PDA_COMUNICAZIONE_OFFERTA'
		inner join ctl_doc c2 on c2.id=c1.LinkedDoc and c2.TipoDoc='PDA_COMUNICAZIONE'
		inner join ctl_doc c3 on c3.id=c2.LinkedDoc and c3.TipoDoc='PDA_MICROLOTTI'
	where c.id=@IdDoc  and c.TipoDoc='PDA_COMUNICAZIONE_OFFERTA_RISP'
	
	
	if  @SectionName = 'PRODOTTI' 
	begin
		---------------------------------------------------------------------------------------
		-- il compilatore o un utente della stessa azienda non ha vincoli sulla sezione
		---------------------------------------------------------------------------------------
		IF EXISTS (Select * from ctl_doc inner join profiliutente p on p.idpfu = @IdUser and pfuidazi = cast( Destinatario_Azi as int ) where id=@IdDoc   )
		BEGIN
			select @Blocco as Blocco 
			return
		END	
		
		--SE LA BUSTA E' STATA APERTA
		IF  EXISTS ( select * from CTL_DOC_Value  where @IdDoc = idHeader and DSE_ID = 'PRODOTTI' and DZT_Name = 'LettaBusta' and value = '1')
		BEGIN
			set @Blocco = ''
		END
		---------------------------------------------------------------------------------------
		-- Le buste possono essere aperte solo dal Presidente della valutazione economica'
		---------------------------------------------------------------------------------------
		ELSE
		BEGIN
			set @Blocco = 'Apertura busta non possibile, utente non abilitato. Le buste possono essere aperte solo dal Presidente della valutazione economica'

			select @IdCommissione=ID 
				from ctl_doc 
					where deleted=0 and linkedDoc=@IdBando and tipodoc='COMMISSIONE_PDA' 
						and statofunzionale='pubblicato'  and substring( JumpCheck , 1 , len( @TipoDoc )  ) = @TipoDoc 
			
			--controllo che l'utente loggato è il presidente della commissione C se esiste		
			if exists(select UtenteCommissione from	Document_CommissionePda_Utenti where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='C' and UtenteCommissione=@IdUser)
			BEGIN
				set @Blocco = ''
			END

			--controllo che l'utente loggato è il presidente della commissione A 
			if exists(select UtenteCommissione from	Document_CommissionePda_Utenti where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='A' and UtenteCommissione=@IdUser)
				and not exists (select * from	Document_CommissionePda_Utenti where idheader=@IdCommissione and ruolocommissione='15548' and TipoCommissione='C')
			BEGIN
				set @Blocco = ''
			END
			---se posso aprire le buste e non è stato fatto allora procedo con l'apertura
			IF  ( @Blocco = '')
			BEGIN
				IF NOT EXISTS ( select * from CTL_DOC_Value  where @IdDoc = idHeader and DSE_ID = 'PRODOTTI' and DZT_Name = 'LettaBusta' and value = '1')
				BEGIN
					select @id_PDA=c3.id,@idlotto=cast( c2.VersioneLinkedDoc as int)
						from ctl_doc c
						inner join ctl_doc c1 on c1.id=c.LinkedDoc and c1.TipoDoc='PDA_COMUNICAZIONE_OFFERTA'
						inner join ctl_doc c2 on c2.id=c1.LinkedDoc and c2.TipoDoc='PDA_COMUNICAZIONE'
						inner join ctl_doc c3 on c3.id=c2.LinkedDoc and c3.TipoDoc='PDA_MICROLOTTI'
					where c.id=@IdDoc  and c.TipoDoc='PDA_COMUNICAZIONE_OFFERTA_RISP'

					select @numero_lotto=NumeroLotto from Document_MicroLotti_Dettagli where id=@idlotto

					 ---per ogni offerta migliorativa DECIFRA l'allegato inserito dal fornitore
					select @Allegato = SIGN_ATTACH from CTL_DOC where id = @IdDoc
					
					exec AFS_DECRYPT_ATTACH  @IdUser ,    @Allegato , @IdDoc
					
					--per ogni offerta migliorativa inviata sblocco i dati
					exec  START_PDA_COMUNICAZIONE_OFFERTA_RISP_CHECK_PRODUCT @IdDoc ,  @IdUser  

					set @Query = 'select rd.id , d.id 
					from Document_MicroLotti_Dettagli d
						inner join Document_PDA_OFFERTE o on d.TipoDoc = ''PDA_OFFERTE'' and d.IdHeader = o.IdRow
				
						-- comunicazione 
						inner join CTL_DOC c on c.LinkedDoc = o.idheader 
											--and c.StatoFunzionale in ( ''Inviato'' ,''Inviata Risposta'' )
											and c.StatoFunzionale not in  ( ''InLavorazione'' ,''Invalidato'' )
											and c.deleted = 0
											and c.TipoDoc = ''PDA_COMUNICAZIONE''
											and c.JumpCheck = ''1-OFFERTA''

						-- Richiesta offerta migliorativa 
						inner join CTL_DOC m on m.LinkedDoc = c.id
											and m.StatoDoc = ''Sended'' 
											and m.deleted = 0
											and m.TipoDoc = ''PDA_COMUNICAZIONE_OFFERTA''

						-- offerte ricevute
						inner join CTL_DOC r on r.LinkedDoc = m.id
											and r.StatoDoc = ''Sended'' 
											and r.deleted = 0
											and r.TipoDoc = ''PDA_COMUNICAZIONE_OFFERTA_RISP''
											and r.JumpCheck = ''0-PDA_COMUNICAZIONE_OFFERTA_RISP''
											and r.Destinatario_Azi = o.idAziPartecipante

						-- offerta migliorativa
						inner join Document_MicroLotti_Dettagli rd on rd.tipodoc = ''PDA_COMUNICAZIONE_OFFERTA_RISP''
											and rd.IdHeader = r.id
											and rd.NumeroLotto = d.NumeroLotto
											and rd.Voce = d.voce

					where RD.IDHEADER=' + cast(@IdDoc as varchar(200)) + ' AND o.IdHeader = ' + cast(@id_PDA as varchar(200)) + ' and d.NumeroLotto= ' + cast(@numero_lotto as varchar(200))
					set @ColToExclud='Id,IdHeader,TipoDoc,Graduatoria,Sorteggio,Posizione,Aggiudicata,Exequo,StatoRiga,EsitoRiga,ValoreOfferta,NumeroLotto,CIG,ValoreAccessorioTecnico,TipoAcquisto,Subordinato,ArticoliPrimari,SelRow,Erosione,Variante,PesoVoce,NumeroRiga,ValoreEconomico,PunteggioTecnico,ValoreImportoLotto,idHeaderLotto,Voce,ValoreSconto,ValoreRibasso,PunteggioTecnicoAssegnato,PunteggioTecnicoRiparCriterio,PunteggioTecnicoRiparTotale'
					exec COPY_DETTAGLI_MICROLOTTI  @query ,@ColToExclud 

					insert into CTL_DOC_Value ( IdHeader, DSE_ID, Row, DZT_Name, Value )
								values ( @IdDoc , 'PRODOTTI' , 0 , 'LettaBusta' , '1' )

				END

			END




		END			
			
			
	end
	
	
			
	select @Blocco as Blocco 
	
	

end


GO
