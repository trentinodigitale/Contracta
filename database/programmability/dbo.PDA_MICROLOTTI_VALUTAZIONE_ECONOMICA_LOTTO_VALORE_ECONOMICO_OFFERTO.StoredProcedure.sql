USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_VALORE_ECONOMICO_OFFERTO]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE Proc [dbo].[PDA_MICROLOTTI_VALUTAZIONE_ECONOMICA_LOTTO_VALORE_ECONOMICO_OFFERTO] (  @idDoc int , @IdPFU int )
as
begin

	--declare @IdPFU as Int 
	--declare @idDoc int

	
	--set @idDoc = 95439  
	--set @idPfu = 45094  



	declare @IdLotto					Int 
	declare @IdPDA						Int 
	declare @idOfferta					int
	declare @idHeaderLotto				int
	declare @StatoRiga					Varchar(255) 
	declare @NumeroLotto				Varchar(255) 

	-- LA STORED E' OBSOLETA e le operazioni sono state fatte singolarmente
	-- per questo si richiama la procedura singola per tutte le offerte presenti
	-- e si commenta tutto il pregresso come traccia storica nel caso qualche ragionamento si sia perso

	declare crs cursor static for 
		select O.ID , O.StatoRiga , p.idheader ,P.NumeroLotto, d.IdMsgFornitore , O.idHeaderLotto
			from Document_MicroLotti_Dettagli P with(nolock)
					inner join Document_PDA_OFFERTE d with(nolock) on d.idheader = p.idheader
					inner join Document_MicroLotti_Dettagli O with(nolock) on d.idRow = O.idheader and O.TipoDoc = 'PDA_OFFERTE' and O.statoRiga in ('Valutato' ,'ValutatoECO', 'Conforme' ,  'verificasuperata' , 'Saved'  , '' , 'SospettoAnomalo' ) and P.NumeroLotto = O.NumeroLotto and O.Voce = 0
			where P.ID = @IdDoc and P.Voce = 0

	open crs 
	fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto, @idOfferta, @idHeaderLotto
	while @@fetch_status=0 
	begin 

		-- per ogni offerta si eseguono le operazioni per calcolare il valore offerto
		exec PDA_MICROLOTTI_VALORE_ECONOMICO_OFFERTO_FORNITORE @IdPDA ,  @NumeroLotto  , @idOfferta  
		

		fetch next from crs into @IdLotto , @StatoRiga , @IdPDA , @NumeroLotto, @idOfferta, @idHeaderLotto
	end 
	close crs 
	deallocate crs


	IF EXISTS ( select id from lib_dictionary where dzt_name = 'SYS_ATTIVA_PROTOCOLLO_GENERALE' and dzt_valuedef = 'YES' )
	BEGIN

		declare @idPfuMitt INT --l'idpfu mittente dell'offerta. utile per chiamare la stored ProtGenInsert
		declare @idDaProtocollare INT
		--SOSTITUISCO IL CURSORE E LA CHIAMATA AL PROTOCOLLO ONLINE
		--CON UNA CHIAMATA SCHEDULATA
		insert into CTL_Schedule_Process ( IdDoc,IdUser,DPR_DOC_ID,DPR_ID)
			select dof.id as idDaProtocollare, d.IdMittente,'OFFERTA_BE','RICHIEDI_PROTOCOLLO' 
				from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
						INNER JOIN Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader and d.Tipodoc = 'OFFERTA'

						-- recupero l'offerta del fornitore
						INNER JOIN Document_MicroLotti_Dettagli O WITH(NOLOCK) on O.idheader = d.idRow and O.TipoDoc = 'PDA_OFFERTE' 
												and O.NumeroLotto = P.NumeroLotto and o.Voce = 0 --and O.statoRiga not in ( '' , 'Saved','InValutazione','daValutare','escluso','esclusoEco','inVerifica' ) 

						-- prendo il dettaglio offerto dal fornitore
						LEFT JOIN Document_MicroLotti_Dettagli dof with(nolock) on dof.idheader = d.IdMsgFornitore and 
												dof.TipoDoc ='OFFERTA' and dof.Voce = 0 and dof.NumeroLotto = p.NumeroLotto

						-- recupera l'evidenza di lettura economica del documento
						LEFT JOIN CTL_DOC_VALUE BD with(nolock) on BD.idHeader = d.IdMsg and BD.DSE_ID = 'OFFERTA_BUSTA_ECO' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
						LEFT JOIN CTL_DOC_VALUE v1 with(nolock) on v1.idHeader = D.IdMsg and v1.DSE_ID = 'BUSTA_ECONOMICA' and v1.DZT_Name = 'LettaBusta'

				where P.ID = @IdDoc and ( BD.IdRow is not null or v1.idrow is not null  ) -- prendiamo solo quelle la cui busta economica è stata 'aperta'/decifrata
		--DECLARE crsProt CURSOR STATIC FOR 
		--		select dof.id as idDaProtocollare, d.IdMittente 
		--			from Document_MicroLotti_Dettagli P WITH(NOLOCK) 
		--					INNER JOIN Document_PDA_OFFERTE d WITH(NOLOCK) on d.idheader = p.idheader and d.Tipodoc = 'OFFERTA'

		--					-- recupero l'offerta del fornitore
		--					INNER JOIN Document_MicroLotti_Dettagli O WITH(NOLOCK) on O.idheader = d.idRow and O.TipoDoc = 'PDA_OFFERTE' 
		--											and O.NumeroLotto = P.NumeroLotto and o.Voce = 0 --and O.statoRiga not in ( '' , 'Saved','InValutazione','daValutare','escluso','esclusoEco','inVerifica' ) 

		--					-- prendo il dettaglio offerto dal fornitore
		--					LEFT JOIN Document_MicroLotti_Dettagli dof with(nolock) on dof.idheader = d.IdMsgFornitore and 
		--											dof.TipoDoc ='OFFERTA' and dof.Voce = 0 and dof.NumeroLotto = p.NumeroLotto

		--					-- recupera l'evidenza di lettura economica del documento
		--					LEFT JOIN CTL_DOC_VALUE BD with(nolock) on BD.idHeader = d.IdMsg and BD.DSE_ID = 'OFFERTA_BUSTA_ECO' and BD.DZT_Name = 'LettaBusta' and dof.id = BD.row
		--					LEFT JOIN CTL_DOC_VALUE v1 with(nolock) on v1.idHeader = D.IdMsg and v1.DSE_ID = 'BUSTA_ECONOMICA' and v1.DZT_Name = 'LettaBusta'

		--			where P.ID = @IdDoc and ( BD.IdRow is not null or v1.idrow is not null  ) -- prendiamo solo quelle la cui busta economica è stata 'aperta'/decifrata

		--OPEN crsProt
		--FETCH NEXT FROM CrsProt into @idDaProtocollare,@idPfuMitt
		--WHILE @@fetch_status=0
		--BEGIN

		--	-- SIA PER LE MULTILOTTO CHE PER LE MONOLOTTO PASSIAMO COME ID LA RIGA DELLA Document_MicroLotti_Dettagli TIPODOC 'OFFERTA'
		--	EXEC ProtGenInsert @idDaProtocollare,@idPfuMitt, 'OFFERTA_BE'
				
		--	FETCH NEXT FROM crsProt INTO @idDaProtocollare,@idPfuMitt

		--END
		--CLOSE crsProt
		--DEALLOCATE crsProt

	END

end






















GO
