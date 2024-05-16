USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ESITO_RIAMMISSIONE_CREATE_FROM_RIGA_PDA]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[ESITO_RIAMMISSIONE_CREATE_FROM_RIGA_PDA] ( @idRow int , @IdUser int  )
AS
BEGIN

	SET NOCOUNT ON

	declare @Id as INT
	declare @IdMittente as int
	declare @IdAziMittente as int
	declare @Destinatario_Azi as int
	declare @ProtocolloOfferta as varchar(50)
	declare @Oggetto as nvarchar(4000)
	declare @ProtocolloBando as varchar(50)
	declare @Fascicolo as  varchar(50)
	declare @IdDestinatario as int
	declare @TipoDoc as  varchar(50)
	declare @IdPDA as int
	declare @Errore as nvarchar(2000)
	declare @IdLast as int
	declare @IdOff as int
	declare @EsclusioneLotti as varchar(20)
	declare @statoPDA varchar(50)
	declare @Attivare varchar(10)
	declare @TipoDocPDA as varchar(500)

	set @Errore=''
	set @TipoDoc='OFFERTA'

	--recupero id della pda
	select  @IdPDA=Idheader,
			@IdOff=idMsg,
			@EsclusioneLotti = isnull(EsclusioneLotti,''),
			@statoPDA = StatoPDA,
			@Destinatario_Azi=idAziPartecipante,
			@TipoDocPDA = PDA.tipodoc
		from document_pda_offerte PDA_OFF with(nolock) 
				inner join ctl_Doc  PDA with(nolock)  on PDA.id = PDA_OFF.idheader 
		where idrow=@idRow

	set  @Errore=''

	
	IF NOT EXISTS ( 
					SELECT us.UtenteCommissione 
						from ctl_doc pda with(nolock)
								inner join ctl_doc gara with(nolock) ON gara.id = pda.LinkedDoc and gara.Deleted = 0
								inner join ctl_doc co with(nolock) ON co.LinkedDoc = gara.ID and co.tipodoc = 'COMMISSIONE_PDA' and co.Deleted = 0
								inner join Document_CommissionePda_Utenti us with(nolock) ON us.idheader = co.id and us.TipoCommissione = 'A' and us.ruolocommissione='15548' and us.UtenteCommissione = @idUser
						where pda.id = @idPDA and pda.tipodoc in ( 'PDA_MICROLOTTI' , 'PDA_CONCORSO')
					)
	BEGIN

		SET @errore = 'Operazione consentita solo al presidente della commissione A'

	END

	IF @errore = ''
	BEGIN

		select  @statoPDA = StatoPDA
				from Document_PDA_OFFERTE a with(nolock)
			where a.IdRow = @idRow

		SELECT DISTINCT d.NumeroLotto , d.StatoRiga, d.Descrizione, d.CIG , case when l.id is null then '1' else '0' end as Attivare
			INTO #lotti_da_riammettere
				from Document_PDA_OFFERTE o with(nolock)
					inner join  Document_MicroLotti_Dettagli d with(nolock) on d.TipoDoc = case when isnull(o.TipoDoc , '') = '' then '55;186' else o.TipoDoc end  and d.IdHeader = o.IdMsgFornitore and isnull(voce,0) = 0
					inner join CTL_DOC p with(nolock) on p.id = o.IdHeader 
					left join Document_MicroLotti_Dettagli l with(nolock) on l.IdHeader = o.idrow and l.TipoDoc = 'PDA_OFFERTE' and l.voce = 0  and l.statoriga in ( 'decaduta' , 'esclusoEco' , 'escluso' )
				where  o.idrow = @idRow 

		-- SE LA GARA E' A LOTTI E SE L'OFFERTA NON ERA STATA ESCLUSA IN TOTO MA SOLTANTO SU ALCUNI LOTTI
		IF isnull(@statoPDA,'0') <> '1'
		BEGIN

			DELETE FROM #lotti_da_riammettere 
				WHERE NumeroLotto in ( 
										select distinct d.NumeroLotto 
											from Document_MicroLotti_Dettagli d WITH(NOLOCK)
											where idheader = @idRow  and d.TipoDoc = 'PDA_OFFERTE' 
									 )

		END


		------------------------------------------------------------------------------------------------
		-- BLOCCARE SE NON CI SONO LOTTI PER I QUALI SI E' STATI ESCLUSI
		------------------------------------------------------------------------------------------------

		IF exists ( select * from #lotti_da_riammettere )
		BEGIN

			-- Recupero ultimo doc ESITO_RIAMMISSIONE inlavorazione legato all'offerta
			set @Id=-1

			select @Id=id 
				from ctl_doc with(nolock) 
				where tipodoc='ESITO_RIAMMISSIONE' and IdDoc=@IdOff 
						and linkeddoc=@idRow and StatoFunzionale in ('InLavorazione') 
						and deleted=0

			IF @Id = '-1' 
			BEGIN
		
				--recupero info dell'offerta
				select @ProtocolloOfferta=Protocollo,
						@Fascicolo=Fascicolo
					from ctl_doc with(nolock)
					where id=@IdOff

				--recupero azienda utente collegato
				select @IdAziMittente=pfuidazi 
					from profiliutente with(nolock)
					where idpfu=@IdUser
				

				if @TipoDocPDA <> 'PDA_CONCORSO'
					set @TipoDocPDA = ''

				insert into CTL_DOC 
					   ( IdPfu, TipoDoc, Body ,Azienda, IdDoc,
					ProtocolloRiferimento, Fascicolo, LinkedDoc, StatoFunzionale, StatoDoc,deleted,Destinatario_Azi,jumpcheck ) 
				values ( @IdUser, 'ESITO_RIAMMISSIONE', '', @IdAziMittente , @IdOff,
					@ProtocolloOfferta, @Fascicolo, @idRow , 'InLavorazione', 'Saved',0 ,@Destinatario_Azi, @TipoDocPDA )   

				set @Id = SCOPE_IDENTITY()


			

				DECLARE @numeroLotto varchar(500)
				DECLARE @StatoRiga nvarchar(1000)
				DECLARE @Descrizione nvarchar(max)
				DECLARE @CIG nvarchar(500)
				declare @row int

				set @row = 0

				DECLARE curs CURSOR STATIC FOR     
					select NumeroLotto , StatoRiga, Descrizione, CIG , Attivare from #lotti_da_riammettere


				OPEN curs 
				FETCH NEXT FROM curs INTO @numeroLotto, @StatoRiga, @Descrizione, @CIG , @Attivare


				WHILE @@FETCH_STATUS = 0   
				BEGIN  

					insert into ctl_doc_value ( IdHeader, DSE_ID, [Row], DZT_Name, Value )
							values ( @Id, 'LOTTI_RIAMMESSI', @row, 'NumeroLotto', @numeroLotto )

					insert into ctl_doc_value ( IdHeader, DSE_ID, [Row], DZT_Name, Value )
							values ( @Id, 'LOTTI_RIAMMESSI', @row, 'StatoRiga', @StatoRiga )

					insert into ctl_doc_value ( IdHeader, DSE_ID, [Row], DZT_Name, Value )
							values ( @Id, 'LOTTI_RIAMMESSI', @row, 'Descrizione', @Descrizione )

					insert into ctl_doc_value ( IdHeader, DSE_ID, [Row], DZT_Name, Value )
							values ( @Id, 'LOTTI_RIAMMESSI', @row, 'CIG', @CIG )

					insert into ctl_doc_value ( IdHeader, DSE_ID, [Row], DZT_Name, Value )
							values ( @Id, 'LOTTI_RIAMMESSI', @row, 'SelRow',@Attivare)

					set @row = @row + 1

					FETCH NEXT FROM curs INTO @numeroLotto, @StatoRiga, @Descrizione, @CIG , @Attivare

				END  


				CLOSE curs   
				DEALLOCATE curs

			END

		END
		ELSE
		BEGIN
			set  @Errore = 'Non sono presenti lotti da riammettere'
		END

	END

	IF @Errore=''
	BEGIN

		-- rirorna l'id del documento
		select @Id as id

	END
	ELSE
	BEGIN

		-- Ritorna l'errore
		select 'ERRORE' as id , @Errore as Errore

	END
	
END
GO
