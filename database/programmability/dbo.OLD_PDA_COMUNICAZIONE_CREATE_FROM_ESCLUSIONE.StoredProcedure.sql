USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_PDA_COMUNICAZIONE_CREATE_FROM_ESCLUSIONE]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO






CREATE PROCEDURE [dbo].[OLD_PDA_COMUNICAZIONE_CREATE_FROM_ESCLUSIONE] 
	( @idDoc int , @IdUser int  )
AS
--Versione=2&data=2013-01-29&Attivita=40053&Nominativo=Sabato
--Versione=2&data=2015-06-19&Attivita=76719&Nominativo=Sabato
BEGIN
	SET NOCOUNT ON;

	declare @Id as INT
	declare @c as INT
	declare @n as INT
	declare @ProtocolloRiferimento as varchar(40)
	declare @Body as nvarchar(2000)
	declare @azienda as varchar(50)
	declare @StrutturaAziendale as varchar(150)
	declare @ProtocolloGenerale as varchar(50)
	declare @Fascicolo as varchar(50)
	declare @DataProtocolloGenerale as datetime
	declare @IdPfu as INT

	Select @IdPfu=IdPfu,@Fascicolo=Fascicolo,@ProtocolloGenerale=ProtocolloGenerale,
			@DataProtocolloGenerale=DataProtocolloGenerale,@ProtocolloRiferimento=ProtocolloRiferimento,
			@Body=Body,@azienda=azienda,@StrutturaAziendale=StrutturaAziendale 
			from 
				CTL_DOC with (nolock)
			where id=@idDoc
	

	-- verifica se ci sono esclusioni da comunicare
	if exists( 
			select PA.IdRow --@IdPfu,'PDA_COMUNICAZIONE_GARA','Comunicazione di Esclusione',@Fascicolo,@Id,cast(@Body as varchar(max)) + char(13) + cast(C.Body as varchar(max)) ,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,idaziPartecipante,getDate(),dbo.PDA_MICROLOTTI_Esito(IdRow),'0-ESCLUSIONE' 
			from Document_PDA_OFFERTE PA with (nolock)
					left outer join ctl_doc C with (nolock) on PA.idrow=C.LinkedDoc and C.TipoDoc in ('ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA')  and C.IdDoc=@idDoc and C.StatoFunzionale='Confermato'
			where PA.idHEader=@idDoc and ( PA.StatoPda=1 or ( PA.StatoPDA in ( 2 , 22 )  and ( isnull(PA.VerificaCampionatura,'')='warning' or isnull(PA.EsclusioneLotti,'')='warning') ) )
				-- escludo dalla comunicazione i fornitori che già hanno una comunicazione di esclusione
				and PA.idaziPartecipante not in ( 
										select c.destinatario_azi 
											from 
												CTL_DOC c with (nolock)
													inner join CTL_DOC l on l.id = c.LinkedDoc  and l.TipoDoc = 'PDA_COMUNICAZIONE'
											where c.TipoDoc ='PDA_COMUNICAZIONE_GARA' and c.deleted = 0 and l.deleted = 0 
													and l.LinkedDoc = @idDoc and c.StatoDoc='Sended' and substring( c.JumpCheck , 3 , 10)  ='ESCLUSIONE'
									)
		)
	begin	


		---Insert nella CTL_DOC per creare la comunicazione 
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,LinkedDoc,Azienda,StrutturaAziendale,JumpCheck)
			VALUES(@IdUser,'PDA_COMUNICAZIONE','Comunicazione di Esclusione',@Fascicolo,@Body,@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@idDoc,@azienda,@StrutturaAziendale,'0-ESCLUSIONE' )

		set @Id = @@identity	

		-- invalido precednti comunicazioni non inviate
		update CTL_DOC set StatoFunzionale='Invalidato',StatoDoc='Invalidate' 
				where JumpCheck='0-ESCLUSIONE' and TipoDoc='PDA_COMUNICAZIONE_GARA' and 
						StatoFunzionale='InLavorazione' 
				and LinkedDoc in (Select id from CTL_DOC where LinkedDoc=@idDoc )



		declare @PrecComunicazioneEsclusione int
		set @PrecComunicazioneEsclusione = null
		-- se esiste una comuniacazione di esclusione precedente viene cambiata di stato
		Select @PrecComunicazioneEsclusione = id 
				from CTL_DOC 
				where TipoDoc = 'PDA_COMUNICAZIONE' and 
						substring( JumpCheck , 3 , 10 ) = 'ESCLUSIONE' and 
						LinkedDoc=@idDoc and 
						StatoFunzionale='InLavorazione' and
						@Id <> id

		if @PrecComunicazioneEsclusione is not null 
		begin

			select @c = count(*) , @n = sum(case when StatoFunzionale='Invalidato' then 1 else 0 end )
				from CTL_DOC 
					where LinkedDoc = @PrecComunicazioneEsclusione
		
			if @c > @n 
				update ctl_doc set StatoFunzionale='Inviato', StatoDoc='Sended' where id=@PrecComunicazioneEsclusione
			else
				update ctl_doc set StatoFunzionale='Invalidato', StatoDoc='Invalidate' where id=@PrecComunicazioneEsclusione
	
		end 



		---inserisco la riga per tracciare la cronologia nella PDA
		declare @userRole as varchar(100)
		select    @userRole= isnull( attvalue,'')
			from ctl_doc d 
				left outer join profiliutenteattrib p on d.idpfu = p.idpfu and dztnome = 'UserRoleDefault'  
			where id = @id

		
		insert into CTL_ApprovalSteps 
			( APS_Doc_Type , APS_ID_DOC    , APS_State     , APS_Note    , APS_IdPfu , APS_UserProfile , APS_IsOld , APS_Date ) 
			values ('PDA_MICROLOTTI' , @idDoc , 'PDA_COMUNICAZIONE_GARA' , 'Comunicazione di Esclusione' , @IdUser , @userRole   , 1  , getdate() )
		
		
		declare @RuoloNascosto as int
		declare @ModelloGriglia as varchar(200)
		set @RuoloNascosto=1
		set @ModelloGriglia='PDA_COMUNICAZIONE_DETTAGLI_Ruolo'
		select @RuoloNascosto= dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1)
	
		if   @RuoloNascosto = 1
			set @ModelloGriglia='PDA_COMUNICAZIONE_DETTAGLI_SenzaRuolo'
		
		-- aggiungo nella ctl_doc_section_model il modello di griglia con il ruolo
		insert into CTL_DOC_SECTION_MODEL			
			( [IdHeader], [DSE_ID], [MOD_Name]	)
			values
			( @Id,'DETTAGLI',@ModelloGriglia)			
		

		--metto in una tabella temporanea i destinatari della comunicazione
		CREATE TABLE #TempDestinatari_Comunicazioni(
				[ProtocolloRiferimento] [varchar] (200) collate DATABASE_DEFAULT ,
				[idaziPartecipante] int,
				[Ruolo_Partecipante] [varchar] (200) collate DATABASE_DEFAULT,
				[idaziRiferimento] int,
				[CodiceFiscale] [varchar] (200) collate DATABASE_DEFAULT,
				[RagSocRiferimento] [varchar] (1000) collate DATABASE_DEFAULT,
				[Note] [ntext] ,
				[Body] [ntext]
			) 
		
		insert into #TempDestinatari_Comunicazioni
				(ProtocolloRiferimento,idaziPartecipante,Ruolo_Partecipante,idaziRiferimento,CodiceFiscale,RagSocRiferimento,Note,Body)
					
				--singolo partecipante oppure mandataria di una rti
				select 
					distinct 
					OFFERTA.protocollo,
					idaziPartecipante,	
					case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as Ruolo_Partecipante,
					idaziPartecipante,
					do.codicefiscale,
					DO.RagSocRiferimento,
					case when ISNULL(dbo.PDA_MICROLOTTI_Esito(PA.IdRow),'')='' then dbo.getLottiSenzaCampioni(PA.IdRow) else ISNULL(dbo.PDA_MICROLOTTI_Esito(PA.IdRow),'') end ,
					cast(@Body as varchar(max)) + char(13) + cast(ISNULL(C.Body,'') as varchar(max))

					from Document_PDA_OFFERTE PA 
						inner join ctl_doc OFFERTA with(nolock)  on OFFERTA.id=PA.idmsg
						left outer join ctl_doc C with(nolock) on PA.idrow=C.LinkedDoc and C.TipoDoc in ('ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA')  and C.IdDoc=@idDoc and C.StatoFunzionale='Confermato'
						left join CTL_DOC P with(nolock) on P.tipodoc='OFFERTA_PARTECIPANTI' and P.statofunzionale='Pubblicato' and P.linkeddoc=pa.idmsg
						left join Document_Offerta_Partecipanti DO with(nolock) on P.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
						cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H

					where PA.idHEader=@idDoc and ( PA.StatoPda=1 or ( PA.StatoPDA in ( 2 , 22 )  and ( isnull(PA.VerificaCampionatura,'')='warning' or isnull(PA.EsclusioneLotti,'')='warning') ) )
						-- escludo dalla comunicazione i fornitori che già hanno una comunicazione di esclusione
						and PA.idaziPartecipante not in ( 
											select c.destinatario_azi from CTL_DOC c 
												inner join CTL_DOC l on l.id = c.LinkedDoc  and l.TipoDoc = 'PDA_COMUNICAZIONE'
											where c.TipoDoc ='PDA_COMUNICAZIONE_GARA' and c.deleted = 0 and l.deleted = 0 
												and l.LinkedDoc = @idDoc and c.StatoDoc='Sended' and substring( c.JumpCheck , 3 , 10)  ='ESCLUSIONE'
										) 

				UNION 
				--lista altre partecipanti(mandanti/esecutrici)
				select 
					distinct
					DPO.ProtocolloRiferimento, 
					PARTECIPANTE , 
					Ruolo_Partecipante ,
					DPO.idaziriferimento,
					DPO.codicefiscale,
					DPO.RagSocRiferimento,
					case when ISNULL(dbo.PDA_MICROLOTTI_Esito(DPO.IdRow),'')='' then dbo.getLottiSenzaCampioni(DPO.IdRow) else ISNULL(dbo.PDA_MICROLOTTI_Esito(DPO.IdRow),'') end ,
					cast(@Body as varchar(max)) + char(13) + cast(ISNULL(C.Body,'') as varchar(max))
 
						from dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI (@idDoc) DPO 
								left outer join ctl_doc C on DPO.idrow=C.LinkedDoc and C.TipoDoc in ('ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA')  and C.IdDoc=@idDoc and C.StatoFunzionale='Confermato'						
						where ( DPO.StatoPda=1 or ( DPO.StatoPDA in ( 2 , 22 )  and ( isnull(DPO.VerificaCampionatura,'')='warning' or isnull(DPO.EsclusioneLotti,'')='warning') ) )
							-- escludo dalla comunicazione i fornitori che già hanno una comunicazione di esclusione
							and DPO.idaziPartecipante not in ( 
											select c.destinatario_azi 
												from CTL_DOC c 
													inner join CTL_DOC l on l.id = c.LinkedDoc  and l.TipoDoc = 'PDA_COMUNICAZIONE'
												where c.TipoDoc ='PDA_COMUNICAZIONE_GARA' and c.deleted = 0 and l.deleted = 0 
													and l.LinkedDoc = @idDoc and c.StatoDoc='Sended' and substring( c.JumpCheck , 3 , 10)  ='ESCLUSIONE'
										)
		-- lista dei fornitori - creiamo le singole comunicazioni
		-- aggiungiamo i fornitori ammessi ma con verificacampionatura parziale
		insert into CTL_DOC (IdPfu,TipoDoc,Titolo,Fascicolo,LinkedDoc,Body,ProtocolloRiferimento,ProtocolloGenerale,DataProtocolloGenerale,Azienda,Destinatario_Azi,Data,Note,JumpCheck ,VersioneLinkedDoc ) 
			
			--select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione di Esclusione',@Fascicolo,@Id,
			--	cast(@Body as varchar(max)) + char(13) + cast(ISNULL(C.Body,'') as varchar(max)) ,
			--	@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,idaziPartecipante,
			--	getDate(),
			--		case when ISNULL(dbo.PDA_MICROLOTTI_Esito(PA.IdRow),'')='' then dbo.getLottiSenzaCampioni(PA.IdRow) else ISNULL(dbo.PDA_MICROLOTTI_Esito(PA.IdRow),'') end ,
			--		'0-ESCLUSIONE' 
			--		, case when do.idrow is null or H.Hide <> '0' then '' else 'Mandataria' end as VersioneLinkedDoc
			
			--	from Document_PDA_OFFERTE PA 
			--			left outer join ctl_doc C on PA.idrow=C.LinkedDoc and C.TipoDoc in ('ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA')  and C.IdDoc=@idDoc and C.StatoFunzionale='Confermato'
			--			left join CTL_DOC P with(nolock) on P.tipodoc='OFFERTA_PARTECIPANTI' and P.statofunzionale='Pubblicato' and P.linkeddoc=pa.idmsg
			--			left join Document_Offerta_Partecipanti DO with(nolock) on P.id = DO.IdHeader and  DO.Ruolo_Impresa in ('Mandataria') 
			--			cross join ( select  dbo.PARAMETRI('PDA_COMUNICAZIONE_DETTAGLI','Ruolo_Impresa','Hide','0',-1) as Hide ) as H

			--	where PA.idHEader=@idDoc and ( PA.StatoPda=1 or ( PA.StatoPDA in ( 2 , 22 )  and ( isnull(PA.VerificaCampionatura,'')='warning' or isnull(PA.EsclusioneLotti,'')='warning') ) )
			--		-- escludo dalla comunicazione i fornitori che già hanno una comunicazione di esclusione
			--		and PA.idaziPartecipante not in ( 
			--								select c.destinatario_azi from CTL_DOC c 
			--									inner join CTL_DOC l on l.id = c.LinkedDoc  and l.TipoDoc = 'PDA_COMUNICAZIONE'
			--								where c.TipoDoc ='PDA_COMUNICAZIONE_GARA' and c.deleted = 0 and l.deleted = 0 
			--									and l.LinkedDoc = @idDoc and c.StatoDoc='Sended' and substring( c.JumpCheck , 3 , 10)  ='ESCLUSIONE'
			--							)
			
			--UNION 

			--AGGIUNGO LA UNION CHE RECUPERA EVENTUALI MANDANTI O ESECUTRICI DA AGGIUNGERE ALLA COMUNICAZIONE
			--select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione di Esclusione',@Fascicolo,@Id,
			--		cast(@Body as varchar(max)) + char(13) + cast(ISNULL(C.Body,'') as varchar(max)) ,
			--		@ProtocolloRiferimento,@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,PA.PARTECIPANTE ,
			--		getDate(),
			--		case when ISNULL(dbo.PDA_MICROLOTTI_Esito(PA.IdRow),'')='' then dbo.getLottiSenzaCampioni(PA.IdRow) else ISNULL(dbo.PDA_MICROLOTTI_Esito(PA.IdRow),'') end 
			--		,'0-ESCLUSIONE' ,Ruolo_Partecipante

			--	from dbo.GET_IDAZI_COMUNICAZIONE_PARTECIPANTI_RTI (@idDoc) PA 
			--			left outer join ctl_doc C on PA.idrow=C.LinkedDoc and C.TipoDoc in ('ESITO_AMMESSA' , 'ESITO_AMMESSA_CON_RISERVA')  and C.IdDoc=@idDoc and C.StatoFunzionale='Confermato'						
			--	where ( PA.StatoPda=1 or ( PA.StatoPDA in ( 2 , 22 )  and ( isnull(PA.VerificaCampionatura,'')='warning' or isnull(PA.EsclusioneLotti,'')='warning') ) )
			--		-- escludo dalla comunicazione i fornitori che già hanno una comunicazione di esclusione
			--		and PA.idaziPartecipante not in ( 
			--								select c.destinatario_azi from CTL_DOC c 
			--									inner join CTL_DOC l on l.id = c.LinkedDoc  and l.TipoDoc = 'PDA_COMUNICAZIONE'
			--								where c.TipoDoc ='PDA_COMUNICAZIONE_GARA' and c.deleted = 0 and l.deleted = 0 
			--									and l.LinkedDoc = @idDoc and c.StatoDoc='Sended' and substring( c.JumpCheck , 3 , 10)  ='ESCLUSIONE'
			--							)
		
			select @IdUser,'PDA_COMUNICAZIONE_GARA','Comunicazione di Esclusione',@Fascicolo,@Id,Dest.Body,
					DEST.ProtocolloRiferimento,
					@ProtocolloGenerale,@DataProtocolloGenerale,@azienda,DEST.idaziPartecipante,getDate(),
					DEST.Note,'0-ESCLUSIONE' ,
					--compongo la colonna Ruolo a seconda della tipologia del partecipante nella RTI
					case
						when DEST.Ruolo_Partecipante='' then ''
						when DEST.Ruolo_Partecipante in ('Mandataria','Mandante') then DEST.RagSocRiferimento + ' - ' + DEST.Ruolo_Partecipante
						when DEST.Ruolo_Partecipante in ('Esecutrice') then isnull(DEST_RIF.RagSocRiferimento,'') + ' Esecutrice di ' + DEST.RagSocRiferimento
					end as VersioneLinkedDoc
					from 
						#TempDestinatari_Comunicazioni DEST
							left join #TempDestinatari_Comunicazioni DEST_RIF on 
									DEST_RIF.ProtocolloRiferimento = DEST.ProtocolloRiferimento 
									and DEST.idaziRiferimento = DEST_RIF.idaziPartecipante 
		


		--recupero le comunicazioni figlie appena create e per ognuna aggiungo 
		--il record nella ctl_doc_value con il campo "NumeroDocumento" che determina l'ordinamento
		select 
			id,ProtocolloRiferimento,Destinatario_Azi 
				into #temp_com_dettagli 
			from 
				ctl_doc with (nolock) 
			where 
				linkeddoc = @Id and tipodoc='PDA_COMUNICAZIONE_GARA'
				

		insert into ctl_Doc_value
			( [IdHeader], [DSE_ID], [Row], [DZT_Name], [Value] )

			select 
				id,'SORTEGGIO' as DSE_ID ,0 as Row ,'NumeroDocumento' as DZT_Name,

				COM_DET.ProtocolloRiferimento + ' - ' + 
					case 
						when DEST.Ruolo_Partecipante='' then '0'
						when DEST.Ruolo_Partecipante='mandataria' then '1 - ' + DEST.codicefiscale
						when DEST.Ruolo_Partecipante='mandante' then '2 - '+ DEST.codicefiscale
						when DEST.Ruolo_Partecipante='esecutrice' then '3 - ' + isnull(DEST_RIF.codicefiscale,'') + ' - ' + DEST.codicefiscale
					end  as value		
								
				from 
					#temp_com_dettagli COM_DET
						inner join #TempDestinatari_Comunicazioni DEST 
														on  DEST.ProtocolloRiferimento=COM_DET.ProtocolloRiferimento 
															and DEST.idaziPartecipante=COM_DET.Destinatario_Azi 
						left join #TempDestinatari_Comunicazioni DEST_RIF 
														on DEST_RIF.ProtocolloRiferimento=COM_DET.ProtocolloRiferimento 
															and DEST_RIF.idaziPartecipante  = DEST.idaziriferimento
		
		-- rirorna l'id della nuova comunicazione appena creata
		select @Id as id




	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , 'Non ci sono esclusioni da comunicare' as Errore
	end
END







GO
