USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[VALUTAZIONE_BUSTA_AMMINISTRATIVA_CREATE_FROM_OFFERTA]    Script Date: 5/16/2024 2:38:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE  proc [dbo].[VALUTAZIONE_BUSTA_AMMINISTRATIVA_CREATE_FROM_OFFERTA] ( @idoff as int, @idPfu as int) 
as
BEGIN
	SET NOCOUNT ON;

	declare @Errore as nvarchar(2000)
	declare @Id as INT
	declare @idbando as int
	declare @IdPDA as int
	declare @sign_attach as nvarchar(1000)
	declare @fascicolo as varchar(50)

	select 
			@idbando=offerta.LinkedDoc ,
			@IdPDA=	pda.id,
			@fascicolo = offerta.Fascicolo
		from ctl_doc offerta with(NOLOCK)
			inner join ctl_doc pda with(NOLOCK) on pda.LinkedDoc=offerta.LinkedDoc and pda.TipoDoc='PDA_MICROLOTTI' and pda.Deleted=0
		where offerta.id=@idoff

	set @Errore=''
	
	
	IF EXISTS (Select * from ctl_doc where id=@idoff and tipodoc in ('OFFERTA','DOMANDA_PARTECIPAZIONE') and StatoFunzionale <> 'Inviato'  )
	BEGIN
		set @Errore='Operazione non consentita per lo stato del documento offerta'
	END

	IF NOT EXISTS ( select * from CTL_DOC_VALUE BD with(nolock) where  BD.idHeader= @idoff and BD.DSE_ID = 'BUSTA_DOCUMENTAZIONE' and BD.DZT_Name = 'LettaBusta' )
	BEGIN
		set @Errore='Operazione non consentita bisogna prima aprire la busta di documentazione'
	END


	select @Id=id from ctl_doc where LinkedDoc=@idoff and TipoDoc='VALUTAZIONE_BUSTA_AMMINISTRATIVA' and StatoFunzionale <> 'Annullato' and Deleted=0
	
	--SOLO IL RUP OPPURE IL PRESIDENTE POSSONO CREARE IL DOCUMENTO
	if @id is null
	BEGIN
		IF NOT EXISTS ( 
						select * 
							from CTL_DOC pda
								left outer join ctl_doc_value rup on pda.LinkedDoc = rup.idHeader and  rup.dzt_name = 'UserRup' and rup.dse_id = 'InfoTec_comune'
								left outer join ctl_doc COM with(nolock) on COM.linkeddoc=pda.linkeddoc and COM.tipodoc='COMMISSIONE_PDA' and COM.deleted=0 and COM.statofunzionale='pubblicato'
								left outer join Document_CommissionePda_Utenti CU with(nolock) on COM.id=CU.idheader and CU.TipoCommissione='A' and CU.ruolocommissione='15548'
								where pda.id = @IdPDA 
								and ( 
											-- presidente commissione economica
											@idPfu = CU.UtenteCommissione
					
											or					
											-- RUP
											@idPfu = rup.Value
										)
					  )
		set @Errore='Operazione non consentita solo il presidente del Seggio di gara oppure il RUP possono creare il documento'
	END
	

	if @Errore='' and @id is null
	BEGIN		
			insert into ctl_doc(IdPfu,TipoDoc,LinkedDoc,idPfuInCharge,fascicolo)
				select @idPfu,'VALUTAZIONE_BUSTA_AMMINISTRATIVA',@idoff,@idPfu,@fascicolo

			set @id=SCOPE_IDENTITY()

			--TABELLA DI LAVORO DOVE INSERISCO TUTTE GLI ALLEGATI E LA USO PER POPOLARE LA CTL_DOC_VALUE
			--CREATE TABLE [dbo].TMP_WORK_AMMI
			CREATE TABLE #TMP_WORK_AMMI
			(
				[IdRow] [int] IDENTITY(1,1) NOT NULL,
				[EsitoRiga] [nvarchar](max) COLLATE database_default NULL,
				[Descrizione] [nvarchar](max)  COLLATE database_default NULL,
				[Allegato] [nvarchar](1000) COLLATE database_default NULL
		     )

			--INSERISCO EVENTUALE DGUE SE RICHIESTO
			IF EXISTS (Select * from ctl_doc_value where idheader=@idbando and DSE_ID='DGUE' and DZT_Name='PresenzaDGUE' and ISNULL(value,'')='si')
			BEGIN
				--DGUE MANDATARIA
					Select 
						@sign_attach=SIGN_ATTACH 
					from ctl_doc 
						where tipodoc='MODULO_TEMPLATE_REQUEST' 
						and LinkedDoc=@idoff and deleted = 0 
					
				insert into #TMP_WORK_AMMI ( EsitoRiga , Descrizione,Allegato)
						Select case when ISNULL(@sign_attach,'')='' then '<img src="../images/Domain/State_Warning.gif"><br>Allegato DGUE non presente' else '<img src="../images/Domain/State_OK.gif">'  end ,'Allegato DGUE',@sign_attach					
				
				--CONTROLLO DGUE PARTECIPANTI
				insert into #TMP_WORK_AMMI ( EsitoRiga , Descrizione,Allegato)
					select case when ISNULL(AllegatoDGUE,'')='' then '<img src="../images/Domain/State_Warning.gif"><br>Allegato DGUE non presente' else '<img src="../images/Domain/State_OK.gif">'  end ,TipoRiferimento + ' - Allegato DGUE',AllegatoDGUE
						from Document_Offerta_Partecipanti where IdHeader=@idoff and ISNULL(Ruolo_Impresa,'') <> 'Mandataria' and isnull(idazi,0)<>0
			
			END
			
			--INSERISCO GLI ALLEGATI RICHIESTI SUL BANDO 
				insert into #TMP_WORK_AMMI ( EsitoRiga , Descrizione,Allegato)
					select 
						case when OFFERTA.Descrizione IS NULL then '<img src="../images/Domain/State_Warning.gif"><br>Allegato previsto dal bando e non presente'
							 else EsitoRiga 
						end
						,BANDO.descrizione, OFFERTA.allegato
						from OFFERTA_ALLEGATI_FROM_BANDO_GARA BANDO
							left join CTL_DOC_ALLEGATI OFFERTA with(nolock)  on OFFERTA.idHeader=@idoff and OFFERTA.Descrizione=BANDO.Descrizione
						where BANDO.id_from = @idbando --and BANDO.obbligatorio=1
			
			--INSERISCO ALTRI ALLEGATI INSERITI DA OE SUL DOCUMENTO OFFERTA
				insert into #TMP_WORK_AMMI ( EsitoRiga , Descrizione,Allegato)
					select OFFERTA.EsitoRiga,OFFERTA.descrizione, OFFERTA.allegato
						 from CTL_DOC_ALLEGATI OFFERTA with(nolock)  
							left join #TMP_WORK_AMMI T on T.Descrizione=OFFERTA.Descrizione
						  where OFFERTA.idHeader=@idoff  and ( T.Descrizione IS NULL or ( Offerta.Descrizione = 'ALLEGATO DGUE' and OFFERTA.NotEditable = '') )
						  --kpf 547502  per far uscire eventuali allegati di iniziativa con descrizione ALLEGATO DGUE
			--RECUPERO ANOMALIE ATTESTATO PARTECIPAZIONE SE RICHIESTO			
			IF EXISTS (select * from document_bando where IdHeader=@idbando and ISNULL(ClausolaFideiussoria,0)=1)
			BEGIN
				
				select @sign_attach=F2_SIGN_ATTACH from CTL_DOC_SIGN where idHeader=@idoff
				
				insert into #TMP_WORK_AMMI ( EsitoRiga , Descrizione,Allegato)
					Select case when ISNULL(@sign_attach,'')='' then '<img src="../images/Domain/State_Warning.gif"><br>Attestato di Partecipazione non presente' else '<img src="../images/Domain/State_OK.gif">'  end ,'Attestato di Partecipazione',@sign_attach					
				
			END		


			--COLLEZIONO ELENCO ANOMALIE SUL DOCUMENTO
			insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				select @id,'DETTAGLI','EsitoRiga',EsitoRiga,[IdRow]-1 
					from #TMP_WORK_AMMI 
						order by [IdRow]

			insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				select @id,'DETTAGLI','Descrizione',Descrizione,[IdRow]-1 
					from #TMP_WORK_AMMI 
						order by [IdRow]

			insert into CTL_DOC_Value (IdHeader,DSE_ID,DZT_Name,Value,Row)
				select @id,'DETTAGLI','Allegato',Allegato,[IdRow]-1 
					from #TMP_WORK_AMMI 
						order by [IdRow]

			
			drop table #TMP_WORK_AMMI
		
	END


	if @Errore = ''
	begin
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end

END




GO
