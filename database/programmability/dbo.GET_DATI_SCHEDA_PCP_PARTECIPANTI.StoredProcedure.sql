USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GET_DATI_SCHEDA_PCP_PARTECIPANTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE  PROCEDURE [dbo].[GET_DATI_SCHEDA_PCP_PARTECIPANTI] ( @IdGara int  )
AS
BEGIN

	SET NOCOUNT ON
	
	--PER L'AFFIDAOMENTO VA BENE MA PER LE ALTRE GARE NON VA BENE
	--PER UNA GARA A LOTTI CI POSSONO ESSERE N CONTRATTI.
	--DOVREMMO PASSARE IN INPUT ANCHE IL CONTRATTO SE VOGLIAMO RIUSARLA
	
	declare @IdPda as int
	declare @IdContratto as int
	declare @IdCom as int
	declare @DataStipula as varchar(50)
	declare @ValoreContratto as varchar(100)
	declare @Aggiudicatario as int
	declare @IdOff as int
	declare @GuidOff as varchar(100)
	declare @RicorriAvvalimento as int
	declare @Oggetto as nvarchar(max)
	declare @TipoAppaltoGara as varchar(10)
	declare @AziIddsc as varchar(100)
	declare @tipoOE as varchar(20)
	declare @TipoDocSource as varchar(100)
	declare @pcp_VersioneScheda varchar(50)

	select  @TipoDocSource = Gara.Tipodoc , 
			@Oggetto = Body 
		from CTL_DOC Gara with (nolock) 
		where id=@IdGara

	--recupero info della gara
	select @TipoAppaltoGara=TipoAppaltoGara 
		from document_bando with (nolock)  
		where idHeader=@IdGara
	
	--recupero la versione della PCP da una SYS
	set @pcp_VersioneScheda = '01.00.00'

	select @pcp_VersioneScheda = DZT_ValueDef  from LIB_Dictionary with (nolock) where dzt_name='SYS_VERSIONE_PCP'

	--RECUPERO LA PDA COLLEGATA ALLA GARA
	if @TipoDocSource in ('BANDO_GARA' , 'BANDO_SEMPLIFICATO')
	begin

		select @IdPda=id 
			from 
				CTL_DOC WITH (nolock) 
			where LinkedDoc = @IdGara and TipoDoc='PDA_MICROLOTTI' and Deleted=0

	

		--RECUOPERO LA AMNDATARIA / UNICA AZIENDA AGGIUDICATARIA DEI LOTTI
		select 
		
			PDA_DETT.NumeroLotto,

			vatValore_FT as codiceFiscale,

			A.aziRagioneSociale as Denominazione,
			--presenza MANDATARIA passiamo 1 altrimenti 3
			case when DO.IdRow is not null  then '1' else '3' end  as ruoloOE,

			case 
				when dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0) = A.aziIdDscFormaSoc then '1'
				else dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0)
			end  as tipoOE,

			OFFERTA.GUID AS idPartecipante,

			aziLocalitaLeg  as paeseOperatoreEconomico,

			case	
				when AUS.value <> '1' then 'false'
				else 'true'
			end as avvalimento,

			--PDA_LO.ValoreImportoLotto AS importo,
			--Valore Offerto + Ulteriori somme non ribasso + Oneri sicurezza non ribasso + somme ripetizioni
			--att. 581081
			ltrim( str(  
						PDA_LO.ValoreImportoLotto + 
						isnull(PDA_LO.IMPORTO_ATTUAZIONE_SICUREZZA,0) +	
						isnull(PDA_LO.pcp_UlterioriSommeNoRibasso,0) + 
						isnull(PDA_LO.pcp_SommeRipetizioni,0)	
								
						, 25 , 2 ) ) as importo,

			dbo.GetStrTecDateUTC( GETDATE()) as dataAggiudicazione,

			case
				when @TipoAppaltoGara = 1 then 'supplies'   --forniture
				when @TipoAppaltoGara = 2 then 'works'		--lavori
				when @TipoAppaltoGara = 3 then 'services' --forniture

			end as oggettoContratto,

			@Oggetto AS Oggetto 

			from 
				--prendo tutti i lotti in uno stato valido per il recupera cig
				Document_MicroLotti_Dettagli PDA_DETT with (nolock)
					--salgo sull'offerta dell'aggiudicatario
					inner join Document_PDA_OFFERTE PDA_OFF  with (nolock)
									on PDA_OFF.IdHeader=PDA_DETT.IdHeader and  PDA_OFF.idAziPartecipante = PDA_DETT.Aggiudicata 
										and PDA_OFF.StatoPDA in ('2','22')
					--vado su offerta lotto dell'aggiudicataria
					inner join Document_MicroLotti_Dettagli PDA_LO with (nolock)  on PDA_LO.IdHeader = PDA_OFF.IdRow and PDA_LO.TipoDoc ='PDA_OFFERTE'
										and PDA_LO.NumeroLotto = PDA_DETT.NumeroLotto and PDA_LO.Voce=0
					--salgo su offerta complessiva
					inner join CTL_DOC OFFERTA with (nolock) on OFFERTA.Id = PDA_OFF.IdMsg
					--vedo se ricorre ausiliaria
					left join ctl_doc_Value AUS with (nolock)  on AUS.idheader = OFFERTA.Id and dse_id='AUSILIARIE' and dzt_name='RicorriAvvalimento'
					--recupero info aggiudicataria
					inner join aziende A with (nolock) on A.idazi = PDA_DETT.Aggiudicata
					inner join dm_Attributi with (nolock) on lnk=A.idazi and dztNome ='codicefiscale'					
					left join Document_Offerta_Partecipanti DO with(nolock) on OFFERTA.id = DO.IdHeader and TipoRiferimento in ('RTI')
						and Ruolo_Impresa ='Mandataria'
				where PDA_DETT.IdHeader=@IdPda and PDA_DETT.TipoDoc ='PDA_MICROLOTTI'
						and PDA_DETT.StatoRiga in ('AggiudicazioneProvv','Controllato','AggiudicazioneCond','AggiudicazioneDef')
	
	
		union 
	
		select 

			PDA_DETT.NumeroLotto,

			vatValore_FT as codiceFiscale,

			A.aziRagioneSociale as Denominazione,

			 case	
				when Ruolo_Impresa = 'Mandante' then '2'
				when TipoRiferimento = 'AUSILIARIE' then '4'
				--CON LA VERSIONE 01.00.00 passiam le esecutrici come mandanti
				when TipoRiferimento = 'ESECUTRICI' and @pcp_VersioneScheda = '01.00.00' then '2'
				when TipoRiferimento = 'ESECUTRICI' and @pcp_VersioneScheda <> '01.00.00' then '11'
				else ''
			 end as ruoloOE,

			case 
				when dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0) = A.aziIdDscFormaSoc then '1'
				else dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0)
			end  as tipoOE,

			OFFERTA.GUID AS idPartecipante,

			aziLocalitaLeg  as paeseOperatoreEconomico,

			case	
				when AUS.value <> '1' then 'false'
				else 'true'
			end as avvalimento,

			--PDA_LO.ValoreImportoLotto AS importo,
			ltrim( str(  
						PDA_LO.ValoreImportoLotto + 
						isnull(PDA_LO.IMPORTO_ATTUAZIONE_SICUREZZA,0) +	
						isnull(PDA_LO.pcp_UlterioriSommeNoRibasso,0) + 
						isnull(PDA_LO.pcp_SommeRipetizioni,0)	
								
							, 25 , 2 ) ) as importo,

			dbo.GetStrTecDateUTC( GETDATE()) as dataAggiudicazione,

			case
				when @TipoAppaltoGara = 1 then 'supplies'   --forniture
				when @TipoAppaltoGara = 2 then 'works'		--lavori
				when @TipoAppaltoGara = 3 then 'services' --forniture

			end as oggettoContratto,

			@Oggetto AS Oggetto 
	
			from 
				--prendo tutti i lotti in uno stato valido per il recupera cig
				Document_MicroLotti_Dettagli PDA_DETT with (nolock)
					--salgo sull'offerta dell'aggiudicatario
					inner join Document_PDA_OFFERTE PDA_OFF  with (nolock)
									on PDA_OFF.IdHeader=PDA_DETT.IdHeader and  PDA_OFF.idAziPartecipante = PDA_DETT.Aggiudicata 
										and PDA_OFF.StatoPDA in ('2','22')
					--vado su offerta lotto dell'aggiudicataria
					inner join Document_MicroLotti_Dettagli PDA_LO with (nolock)  on PDA_LO.IdHeader = PDA_OFF.IdRow and PDA_LO.TipoDoc ='PDA_OFFERTE'
										and PDA_LO.NumeroLotto = PDA_DETT.NumeroLotto and PDA_LO.Voce=0
					--salgo su offerta complessiva
					inner join CTL_DOC OFFERTA with (nolock) on OFFERTA.Id = PDA_OFF.IdMsg
					--vedo se ricorre ausiliaria
					left join ctl_doc_Value AUS with (nolock)  on AUS.idheader = OFFERTA.Id and dse_id='AUSILIARIE' and dzt_name='RicorriAvvalimento'
					--recupero info aggiudicataria

					inner join CTL_DOC OFF_PAR with(nolock) on OFF_PAR.LinkedDoc = OFFERTA.id
				
					inner join Document_Offerta_Partecipanti DO with(nolock) on OFF_PAR.id = DO.IdHeader 
								and ( Ruolo_Impresa in ('Mandante') or TipoRiferimento in ('ESECUTRICI','AUSILIARIE') )

					--EVITO DI MANDARE LA STESSA COME MANDATARIA E COME ESECUTRICE IN QUANTO ANAC DA ERRORE
					inner join aziende A with (nolock) on A.idazi = DO.IdAzi and A.IdAzi <>  PDA_DETT.Aggiudicata
					inner join dm_Attributi with (nolock) on lnk=A.idazi and dztNome ='codicefiscale'

				where PDA_DETT.IdHeader=@IdPda and PDA_DETT.TipoDoc ='PDA_MICROLOTTI'
						and PDA_DETT.StatoRiga in ('AggiudicazioneProvv','Controllato','AggiudicazioneCond','AggiudicazioneDef')
	
	END

	-- Nel caso di AFFIDAMENTO_SENZA_NEGOZIAZIONE recupero i valori dalla CTL_DOC_VALUE
	IF @TipoDocSource='AFFIDAMENTO_SENZA_NEGOZIAZIONE'
	BEGIN

		select 	'1' as NumeroLotto,

				cf.Value as codiceFiscale,

				rag.Value as Denominazione,

				--'3' as ruoloOE,
				case when a.pcp_tipoScheda <> 'AD3'
					then '3'
					else ruolo_oe.Value 
				end as ruoloOE,

				--case 
				--	when dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0) = A.aziIdDscFormaSoc then '1'
				--	else dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0)
				--end  as tipoOE,
				case when a.pcp_tipoScheda <> 'AD3'
					then null
					else tipo_oe.Value
				end as tipoOE,


				d.GUID AS idPartecipante,

				--aziLocalitaLeg  as paeseOperatoreEconomico,
				case when a.pcp_tipoScheda <> 'AD3'
					then null
					else localita_oe.Value 
				end as paeseOperatoreEconomico,

				--case	
				--	when AUS.value <> '1' then 'false'
				--	else 'true'
				--end as avvalimento,
				case when a.pcp_tipoScheda <> 'AD3'
					then null
					else Avvalimento.Value 
				end as avvalimento,

				ltrim( str( b.ImportoBaseAsta , 25 , 2 ) ) AS importo,

				dbo.GetStrTecDateUTC( GETDATE()) as dataAggiudicazione,

				case
					when @TipoAppaltoGara = 1 then 'supplies'   --forniture
					when @TipoAppaltoGara = 2 then 'works'		--lavori
					when @TipoAppaltoGara = 3 then 'services' --forniture

				end as oggettoContratto,

				@Oggetto AS Oggetto

		 from CTL_DOC d with(nolock)
				inner join Document_Bando b with(nolock) on d.id = b.idHeader
				left join Document_pcp_Appalto a with(nolock) on a.idheader = d.id
				left join CTL_DOC_VALUE cf with(nolock) on d.id = cf.IdHeader and cf.DSE_ID = 'InfoTec_SIMOG' and cf.DZT_Name = 'aziCodiceFiscale'
				left join CTL_DOC_VALUE rag with(nolock) on d.id = rag.IdHeader and rag.DSE_ID = 'InfoTec_SIMOG' and rag.DZT_Name = 'aziRagioneSociale'
				left join CTL_DOC_VALUE ruolo_oe with(nolock) on d.id = ruolo_oe.idheader and ruolo_oe.DSE_ID = 'InfoTec_comune' and ruolo_oe.DZT_Name = 'RUOLO_OE'
				left join CTL_DOC_VALUE tipo_oe with(nolock) on d.id = tipo_oe.idheader and tipo_oe.DSE_ID = 'InfoTec_comune' and tipo_oe.DZT_Name = 'TIPO_OE'
				left join CTL_DOC_VALUE avvalimento with(nolock) on d.id = avvalimento.idheader and avvalimento.DSE_ID = 'InfoTec_comune' and avvalimento.DZT_Name = 'RicorriAvvalimento'
				left join CTL_DOC_VALUE localita_oe with(nolock) on d.id = localita_oe.idheader and localita_oe.DSE_ID = 'InfoTec_comune' and localita_oe.DZT_Name = 'aziLocalitaLeg'
			where d.id = @IdGara

	END

	IF @TipoDocSource='ODC'
	BEGIN

		select 	
		
				'1' as NumeroLotto,

				C.vatValore_FT as codiceFiscale,

				aziRagioneSociale  as Denominazione,

				'3' as ruoloOE,

				case 
					when dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0) = A.aziIdDscFormaSoc then '1'
					else dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0)
				end  as tipoOE,

				
				lower(NEWID()) AS idPartecipante,

				aziLocalitaLeg  as paeseOperatoreEconomico,

				'false' as avvalimento,
				
				ltrim( str( RDA_Total , 25 , 2 ) ) AS importo,
				 

				dbo.GetStrTecDateUTC( GETDATE()) as dataAggiudicazione,

				case
					when TipoAppaltoGara = 1 then 'supplies'   --forniture
					when TipoAppaltoGara = 2 then 'works'		--lavori
					when TipoAppaltoGara = 3 then 'services' --forniture

				end as oggettoContratto,

				d.Note  AS Oggetto

		 from CTL_DOC d with(nolock)
				inner join Document_ODC Dett_O with(nolock) on Dett_O.RDA_ID =  d.id
				inner join Aziende A with(nolock) on A.IdAzi = Destinatario_Azi
				inner join DM_Attributi C with(nolock) on C.lnk = A.IdAzi and C.dztNome='codiceFiscale'
				
			where d.id = @IdGara
	END

	IF @TipoDocSource='ODA'
	BEGIN

		select 	'1' as NumeroLotto,
				C.vatValore_FT as codiceFiscale,
				aziRagioneSociale  as Denominazione,

				'3' as ruoloOE,

				case 
					when dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0) = A.aziIdDscFormaSoc then '1'
					else dbo.Get_Transcodifica_Verso('TipoOe','','',A.aziIdDscFormaSoc ,0)
				end  as tipoOE,

				
				lower(NEWID()) AS idPartecipante,
				aziLocalitaLeg  as paeseOperatoreEconomico,
				
				'false' as avvalimento,
				
				--TotaleEroso AS importo,

				ltrim( str( TotaleEroso , 25 , 2 ) ) AS importo,

				dbo.GetStrTecDateUTC( GETDATE()) as dataAggiudicazione,

				case
					when TipoAppaltoGara = 1 then 'supplies'   --forniture
					when TipoAppaltoGara = 2 then 'works'		--lavori
					when TipoAppaltoGara = 3 then 'services' --forniture
				end as oggettoContratto,

				d.Note  AS Oggetto

		 from CTL_DOC d with(nolock)
				inner join Document_ODA Dett_O with(nolock) on Dett_O.idHeader = d.id
				inner join Aziende A with(nolock) on A.IdAzi = Destinatario_Azi
				inner join DM_Attributi C with(nolock) on C.lnk = A.IdAzi and C.dztNome='codiceFiscale' and c.idApp = 1
		where d.id = @IdGara

	END --IF @TipoDocSource='ODA'

END
	



GO
