USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SEDUTA_VIRTUALE_DATI]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



















CREATE PROCEDURE [dbo].[OLD_SEDUTA_VIRTUALE_DATI]
	( @idDoc int , @IdUser int ,@command as varchar(200) )
AS
BEGIN
	SET NOCOUNT ON;
	
	declare @Errore as nvarchar(MAX)
	declare @SQL as nvarchar(MAX)
	declare @idbando as int
	declare @idpda as int
	declare @str as varchar(max)
	declare @strcond as varchar(max)
	declare @strEco as varchar(max)
	declare @strcondEco as varchar(max)
	declare @NAME_ALLEGATI_BUSTA_AMM as varchar(max)
	DECLARE @cols AS NVARCHAR(MAX)
	declare @IDLotto int
	declare @Divisione_lotti varchar(10)
	declare @NumeroLotto varchar(10)
	declare @OE_Escluso int
	declare @iddAzi_OE int
	set @IDLotto=-1

	set @cols=''
	set @str=''
	set @strcond=''	
	set @strEco=''
	set @strcondEco=''	
	set @Errore = ''
	set @SQL = ''
	set @NAME_ALLEGATI_BUSTA_AMM = ''
	set @NumeroLotto= ''
	

	----------------------------------------------
	-- DALL'IDENTIFICATIVO PASSATO RECUPERO ID BANDO ED ID PDA
	----------------------------------------------
	IF @command = 'INFO_LOTTO_DETTAGLIO'
	BEGIN
		select @idpda=lotto.IdHeader,@idbando=pda.LinkedDoc , @NumeroLotto = NumeroLotto
			from Document_MicroLotti_Dettagli lotto with(NOLOCK) 
				inner join ctl_doc PDA with(NOLOCK) on PDA.id=lotto.IdHeader
			where lotto.id=@idDoc

		--select @idSeduta = s.id 
		--	from ctl_doc b with(NOLOCK) 
		--		inner join ctl_doc s with(NOLOCK) on b.id = s.linkeddoc and s.tipodoc = 'SEDUTA_VIRTUALE'
		--		inner join profiliutente p with(NOLOCK) on 

		set @IDLotto = @idDoc
	END
	ELSE
	BEGIN
		select @idbando=sv.LinkedDoc,@idpda=DOC.id
			from ctl_doc sv with(NOLOCK) 
				inner join ctl_doc DOC with(NOLOCK) on DOC.LinkedDoc=SV.LinkedDoc and DOC.TipoDoc in ('PDA_MICROLOTTI','PDA_CONCORSO') and DOC.Deleted=0
			where sv.id=@idDoc

		select @IDLotto = id , @NumeroLotto = NumeroLotto from Document_MicroLotti_Dettagli  with(NOLOCK) where TipoDoc in ('PDA_MICROLOTTI','PDA_CONCORSO') and voce = 0 and idheader = @idpda 
	END

	select @Divisione_lotti = divisione_Lotti from document_bando with(nolock) where idheader = @idbando


	--print @SQL
	--select * from #TMP_ALLEGATI_AMM

	
	--print @str
	---------------------------------------
	-- Elenco dei lotti nella gara
	---------------------------------------
	IF @command = 'INFO_LOTTI'	
	BEGIN

		select @iddAzi_OE = pfuidazi from ProfiliUtente with(nolock) where idpfu = @IdUser

		set @OE_Escluso = 0


		-- se l'utente è stato escluso in fase amministrativa
--		if exists( select * from SEDUTA_VIRTUALE_INFO_AMM s where s.idAziPartecipante=@iddAzi_OE and  s.id=@idDoc and StatoPda=1 )
		IF  not EXISTS ( SELECT * FROM Document_PDA_OFFERTE with(nolock) where idheader = @idpda and idAziPartecipante=@iddAzi_OE and statopda not in ( '99' , '999' , '1' )  )
		begin
			
			set @OE_Escluso = 1

		end
		else 
		begin		
			-- oppure è stato escluso in tutti i lotti a cui ha partecipato nella fase tecnica
			if not exists( select o.idrow 
							from Document_PDA_OFFERTE o with(nolock)
								inner join Document_MicroLotti_Dettagli LO with(nolock) on  LO.tipodoc = 'PDA_OFFERTE' and LO.IdHeader = o.idrow and LO.voce = 0 
							where o.IdHeader = @idpda and o.idAziPartecipante = @iddAzi_OE and LO.statoriga<>'Escluso' 
			)
			begin
				
				set @OE_Escluso = 1

			end

		end

		if @OE_Escluso = 1 
			set @SQL = 'select top 0 s.* '
		else
			set @SQL='select s.* '

		set @SQL= @SQL + ' from SEDUTA_VIRTUALE_LST_LOTTI_TEC_VIEW S						
						where S.id =' + cast(@idDoc as varchar(50))
	
	END
	
	
	-- dettaglio 
	IF @command = 'INFO_LOTTO'
	BEGIN
		set @SQL='select  
					VALORI_ECO.*,VALORI_TEC.*,
					dbo.[get_Attributi_Busta_Tecnica] (' + cast(@idbando as varchar(50)) + ',''DZT_DESC'') as Name_COl_TEC,
					dbo.[get_Attributi_Busta_Economica] (' + cast(@idbando as varchar(50)) + ',''DZT_DESC'') as Name_COl_ECO,
					C.id as Id,
					V.aziRagioneSociale,
					--La gara prevede la busta tecnica quando OEV, Costo Fisso, oppure conformità							
					case when ( vl.CriterioAggiudicazioneGara in (25532,15532) or ISNULL(DB.Conformita,'''') <> ''No'') then ''VIS'' else ''HIDE'' end as BustaTecnica_VIS ,
					V.Sorteggio, 
					V.Graduatoria 
					,V.ValoreImportoLotto 

					,case when vl.CriterioAggiudicazioneGara not in (15532) and ISNULL(vl.Conformita,'''') = ''no''then ''HIDE'' else case when ISNULL(vl.Conformita,'''') <>''no'' then ISNULL(V.StatoRiga,'''')  else cast(V.PunteggioTecnico as varchar)  end  end as StatoRiga
					,case when vl.CriterioAggiudicazioneGara not in (15532) then ''HIDE'' else cast(V.punteggioEconomico as varchar(100))  end as punteggioEconomico
					,case when vl.CriterioAggiudicazioneGara not in (25532,15532) then ''HIDE'' else cast(V.ValoreOfferta as varchar(100))  end as ValoreOfferta


					,case when CS.F3_SIGN_ATTACH IS NULL or cdv.value IS NULL then ''NULL'' when CS.F3_SIGN_ATTACH = '''' then ''ko'' when CS.F3_SIGN_ATTACH <> '''' then ''ok'' end as BustaTecnica,
					case when CS.F1_SIGN_ATTACH IS NULL or cde.value IS NULL or V.statoriga = ''escluso'' then ''NULL'' when CS.F1_SIGN_ATTACH = '''' then ''ko'' when CS.F1_SIGN_ATTACH <> '''' then ''ok'' end as BustaEconomica,
					case when ISNULL(DB.Conformita,'''') <> ''NO'' then ''VIS'' else ''HIDE'' end as CONFORMITA,
					ISNULL(DB.CalcoloAnomalia,0) as CalcoloAnomalia,
					DVA.StatoAnomalia
					,OFFERTA.titolo as Progressivo_Risposta

					from CTL_DOC C with(NOLOCK)
						inner join CTL_DOC C2 with(NOLOCK) on C2.linkeddoc=C.linkeddoc and c2.Tipodoc in (''PDA_MICROLOTTI'',''PDA_CONCORSO'')
						inner join PDA_DRILL_MICROLOTTO_LISTA_VIEW V on V.idpda=C2.id
						inner join document_bando DB with(NOLOCK) on DB.idheader=C.linkeddoc 
						inner join ctl_doc_sign CS with(NOLOCK) on CS.idheader=V.idMsg
						left join ctl_doc OFFERTA with(NOLOCK) on OFFERTA.id=V.idMsg 
						left join ctl_doc_value cdv with(NOLOCK) on cdv.idheader= V.idMsg and cdv.dzt_Name=''lettabusta'' and cdv.DSE_id=''BUSTA_TECNICA''
						left join ctl_doc_value cde with(NOLOCK) on cde.idheader= V.idMsg and cde.dzt_Name=''lettabusta'' and cde.DSE_id=''BUSTA_ECONOMICA''
						left join ( select 
										distinct idAziPartecipante as idAziPartecipante_TEC ,
												 NumeroLotto as NumeroLotto_TEC' + @str +			
										' from Document_PDA_OFFERTE PO with(NOLOCK)
											inner join Document_MicroLotti_Dettagli DM with(NOLOCK) on DM.IdHeader=PO.IdRow and DM.tipodoc=''PDA_OFFERTE''
										where PO.IdHeader=' + cast(@idpda as varchar(50)) + @strcond +
										' group by idAziPartecipante,NumeroLotto
									) as VALORI_TEC on VALORI_TEC.NumeroLotto_TEC=V.NumeroLotto and VALORI_TEC.idAziPartecipante_TEC=OFFERTA.Azienda
						left join ( select 
										distinct idAziPartecipante as idAziPartecipante_ECO,
												 NumeroLotto as NumeroLotto_ECO' + @strEco +			
										' from Document_PDA_OFFERTE PO with(NOLOCK)
											inner join Document_MicroLotti_Dettagli DM with(NOLOCK) on DM.IdHeader=PO.IdRow and DM.tipodoc=''PDA_OFFERTE''
										where PO.IdHeader=' + cast(@idpda as varchar(50)) + @strcondEco +
										' group by idAziPartecipante,NumeroLotto
									) as VALORI_ECO on VALORI_ECO.NumeroLotto_ECO=V.NumeroLotto and VALORI_ECO.idAziPartecipante_ECO=OFFERTA.Azienda
						left join ctl_doc ANOMALIA with(NOLOCK) on ANOMALIA.linkeddoc=V.IdRowLottoBando and ANOMALIA.Tipodoc=''VERIFICA_ANOMALIA'' and ANOMALIA.DEleted=0 and ANOMALIA.Statofunzionale=''Confermato''
						left join Document_Verifica_Anomalia DVA with(NOLOCK) on DVA.idheader=ANOMALIA.id 
					where C.id='+ cast(@idDoc as varchar(50))					
	END


	--------------------------------------------------------------------
	-- DETTAGLIO DEL LOTTO PER I DATI TECNICI ED ECONOMICI
	--------------------------------------------------------------------
	IF @command in (  'INFO_LOTTO_DETTAGLIO' , 'INFO_LOTTO' )
	BEGIN

		declare @Col_TEC nvarchar(max)
		declare @Col_ECO nvarchar(max)
		set @Col_TEC= isnull( dbo.[get_Attributi_Busta_Tecnica] (@idbando , 'DZT_DESC' )  , '' ) 
		set @Col_ECO= isnull( dbo.[get_Attributi_Busta_Economica] (@idbando , 'DZT_DESC' ) , '' ) 

		set @OE_Escluso = 0

		-- recupero l'azienda dell'utente collegato
		select @iddAzi_OE = pfuidazi from ProfiliUtente with(nolock) where idpfu = @IdUser

		--select @IDLotto = case when StatoPda=1 then -1 else @IDLotto end from SEDUTA_VIRTUALE_INFO_AMM s where s.idAziPartecipante=@iddAzi_OE and  s.id=@idDoc
		IF  not EXISTS ( SELECT * FROM Document_PDA_OFFERTE with(nolock) where idheader = @idpda and idAziPartecipante=@iddAzi_OE and statopda not in ( '99' , '999' , '1' )  )
		begin
			
			set @OE_Escluso = 1

		end
		else 
		begin		
			-- oppure è stato escluso in tutti i lotti a cui ha partecipato nella fase tecnica
			if not exists( select o.idrow 
							from Document_PDA_OFFERTE o with(nolock)
								inner join Document_MicroLotti_Dettagli LO with(nolock) on  LO.tipodoc = 'PDA_OFFERTE' and LO.IdHeader = o.idrow and LO.voce = 0 
								--ENRPAN aggiunto condizione per numero lotto per verificare la mia esclusione sullo specifico lotto
								--e non per tutti i lotti
							where o.IdHeader = @idpda and o.idAziPartecipante = @iddAzi_OE and LO.statoriga<>'Escluso'  and lo.NumeroLotto = @NumeroLotto
			)
			begin
				
				set @OE_Escluso = 1

			end

		end


		--set @OE_Escluso = isnull( @OE_Escluso ,  0 ) 	

		--if @OE_Escluso=0
		--begin 
		--	select @OE_Escluso = case when  count(LO.statoriga)>0 then 0 else 1 end 
		--		from Document_PDA_OFFERTE o with(nolock)
		--			inner join Document_MicroLotti_Dettagli LO with(nolock) on  LO.tipodoc = 'PDA_OFFERTE' and LO.IdHeader = o.idrow and LO.voce = 0 
		--		where o.IdHeader = @idpda and o.idAziPartecipante = @iddAzi_OE and LO.statoriga<>'Escluso' 
		--end

		---------------------------------------------
		-- definisco la parte variabile della griglia con l'elenco delle colonne della busta tecnica ed economica
		---------------------------------------------
		select 
				@str=@str + ' case when max(' + items + ') IS NULL then '''' when   max(' + items + ') = '''' then ''ko'' else ''ok'' end as '  + items + ',' ,
				@strcond=@strcond + ' and ' + items + ' <> '''''
			from dbo.Split(dbo.[get_Attributi_Busta_Tecnica] (@idbando,'DZT_NAME'),'@@@')
			where items <> ''

		select 
				@strEco = @strEco + ' case when max(' + items + ') IS NULL then '''' when   max(' + items + ') = '''' then ''ko'' else ''ok'' end as '  + items + ',' , 
				@strcondEco =@strcondEco + ' and ' + items + ' <> '''''
			from dbo.Split(dbo.[get_Attributi_Busta_Economica] (@idbando,'DZT_NAME'),'@@@')
			where items <> ''

		if ISNULL(@str,'') <> ''
			set @str =',' +  SUBSTRING ( @str , 0 , len(@str)) 	
		if ISNULL(@strEco,'') <> ''
			set @strEco =',' + SUBSTRING ( @strEco , 0 , len(@strEco)) 	



		set @SQL = '
					--conservo in una temp le info dei lottidel bando
					select * into #temp 
							from BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO 
							where idbando =  ' + cast(@idbando as varchar(50)) + '

					select 
						VALORI_ECO.*
						,VALORI_TEC.*
						--dbo.[get_Attributi_Busta_Tecnica] (' + cast(@idbando as varchar(50)) + ',''DZT_DESC'') as Name_COl_TEC
						--dbo.[get_Attributi_Busta_Economica] (' + cast(@idbando as varchar(50)) + ',''DZT_DESC'') as Name_COl_ECO
						,''' + Replace(@Col_TEC,'''','''''') + ''' as Name_COl_TEC
						,''' + Replace(@Col_ECO,'''','''''')   + ''' as Name_COl_ECO

						,ISNULL(DB.CalcoloAnomalia,0) as CalcoloAnomalia
						,DB.CriterioFormulazioneOfferte
						,D.id as Id
						,V.aziRagioneSociale
						--La gara prevede la busta tecnica quando OEV, Costo Fisso, oppure conformità							
						,case when ( vl.CriterioAggiudicazioneGara in (25532,15532) or ISNULL(vl.Conformita,'''') <> ''No'') then ''VIS'' else ''HIDE'' end as BustaTecnica_VIS 
						,case 
							WHEN  ( isnull( cdv.value,'''' )  <> ''1'' ) then ''NULL'' 

							WHEN db.divisione_lotti <> ''0'' then
								case 
									when DF.F2_SIGN_ATTACH IS NULL or cdv.value IS NULL then ''NULL'' 
									when DF.F2_SIGN_ATTACH = ''''    then ''ko'' 
									when DF.F2_SIGN_ATTACH <> '''' then ''ok'' 
									end
							else
								case 
									when C2.Tipodoc=''PDA_CONCORSO'' then ''ok''
									when CS.F3_SIGN_ATTACH IS NULL or cdv.value IS NULL then ''NULL'' 
									when CS.F3_SIGN_ATTACH = '''' then ''ko'' 
									when CS.F3_SIGN_ATTACH <> '''' then ''ok'' 
									end 
							end as BustaTecnica
						 
					    ,case when vl.CriterioAggiudicazioneGara not in (15532) and ISNULL(vl.Conformita,'''') = ''no'' 
						 
							then ''HIDE'' 
							else
								 
								case
									when d.statoriga in ( '''' , ''Saved'' , ''daValutare'' , ''InValutazione'' ) then '''' 
									when ISNULL( vl.Conformita,'''') <>''no''  then dbo.IsLottoOffertoConforme( D.StatoRiga ,vl.Conformita , v.statoriga)  
									
									
									else isnull( cast(V.PunteggioTecnico as varchar)  , '''' )
								end  
								
							end as PunteggioTecnico 

						 --,''HIDE'' as PunteggioTecnico
						,isnull( case when vl.CriterioAggiudicazioneGara not in (15532) then ''HIDE'' else case  when OE_Escluso = 1 or  V.statoriga = ''escluso''  then '''' else cast(V.punteggioEconomico as varchar(100))  end end , '''' ) as punteggioEconomico
						,isnull( case when vl.CriterioAggiudicazioneGara not in (25532,15532) then ''HIDE'' else  case  when OE_Escluso = 1 then '''' else case when isnull(db.FaseConcorso,'''') = ''prima'' then '''' else cast(V.ValoreOfferta as varchar(100))  end  end end , '''' ) as ValoreOfferta -- punteggio totale
						
						,case 
							when OE_Escluso = 1 then ''NULL'' 
							WHEN  ( isnull( cde.value,'''' )  <> ''1'' ) then ''NULL'' 

							WHEN db.divisione_lotti <> ''0'' then
								case 
									when DF.F1_SIGN_ATTACH IS NULL or cde.value IS NULL or V.statoriga = ''escluso'' then ''NULL'' 
									when DF.F1_SIGN_ATTACH = '''' then ''ko'' 
									when DF.F1_SIGN_ATTACH <> '''' then ''ok'' 
									end 
							else
								case 
									when CS.F1_SIGN_ATTACH IS NULL or cde.value IS NULL or V.statoriga = ''escluso'' then ''NULL'' 
									when CS.F1_SIGN_ATTACH = '''' then ''ko'' 
									when CS.F1_SIGN_ATTACH <> '''' then ''ok'' 
									end 
									
							end as BustaEconomica					
													
						,case when ISNULL(DB.Conformita,'''') <> ''NO'' then ''VIS'' else ''HIDE'' end as CONFORMITA
						,case  when OE_Escluso = 1 then null else DVA.StatoAnomalia end as StatoAnomalia
						,case  when OE_Escluso = 1 then null else V.Sorteggio end as Sorteggio 
						,
						case when isnull(db.FaseConcorso,'''') = ''prima'' then null when OE_Escluso = 1 then null else V.Graduatoria end as Graduatoria 
						'
		--faccio a pezzi perchè sembra ci sono limiti nell'assegnazione
		set @SQL= @SQL + '
						,case  when OE_Escluso = 1 then null else V.ValoreImportoLotto  end as ValoreImportoLotto 
						,case  when OE_Escluso = 1 then null else V.ValoreSconto  end as ValoreSconto 
						
						,case  
							when d.statoriga in ( '''' , ''Saved'' , ''daValutare'' , ''InValutazione'' ) then null 
							when OE_Escluso = 1 and v.StatoRiga <> ''escluso'' then null 
							else v.StatoRiga 
						 end as StatoRiga

						,case when isnull(db.FaseConcorso,'''') = ''prima'' then null when OE_Escluso = 1 then null else V.Posizione end as Posizione

						,isnull( cde.value,'''' ) as letta_busta_economica		

						,case 
							when OE_Escluso = 1  or isnull( cde.value,'''' )  <> ''1'' then ''NO_Lente.gif'' 
							else ''''	
 						 end as FNZ_OPEN
						, v.id as IdOffertaLotto,OE_Escluso,RIS.Titolo as Progressivo_Risposta '
		
		--faccio a pezzi perchè sembra ci sono limiti nell'assegnazione
		set @SQL= @SQL + '

					from document_microlotti_dettagli D with(NOLOCK)						
						
						inner join CTL_DOC C2 with(NOLOCK) on C2.id=D.idheader and (c2.Tipodoc=''PDA_MICROLOTTI'' or c2.Tipodoc=''PDA_CONCORSO'')
						inner join PDA_DRILL_MICROLOTTO_LISTA_VIEW V on V.idpda=C2.id and V.numeroLotto=D.NUmeroLotto and V.voce=0
						inner join document_bando DB with(NOLOCK) on DB.idheader=C2.linkeddoc 
						inner join document_microlotti_dettagli Do with(NOLOCK) on Do.IdHeader=V.idMsg and DO.tipodoc in (''OFFERTA'',''RISPOSTA_CONCORSO'') and do.NumeroLotto=V.NumeroLotto and Do.Voce=0
						inner join ctl_doc RIS with (nolock) on RIS.id = V.idMsg
						--ENRPAN sostituita con accesso ad una tabella temporanea dove ho travasato le info del bando in gioco
						--inner join BANDO_GARA_CRITERI_VALUTAZIONE_PER_LOTTO vl on vl.idbando = ' + cast(@idbando as varchar(50)) + ' and vl.N_Lotto = V.NumeroLotto
						inner join #temp vl on vl.N_Lotto = V.NumeroLotto
					'

		if @Divisione_lotti <> '0' 
		begin
			set @SQL= @SQL + '
						left join ctl_doc_value cdv with(NOLOCK) on cdv.idheader= V.idMsg and cdv.dzt_Name=''lettabusta'' and cdv.DSE_id=''OFFERTA_BUSTA_TEC'' and cdv.row = do.id
						left join ctl_doc_value cde with(NOLOCK) on cde.idheader= V.idMsg and cde.dzt_Name=''lettabusta'' and cde.DSE_id=''OFFERTA_BUSTA_ECO'' and cde.row = do.id
						'
		end
		else
		begin
			set @SQL= @SQL + '
						left join ctl_doc_value cdv with(NOLOCK) on cdv.idheader= V.idMsg and cdv.dzt_Name=''lettabusta'' and cdv.DSE_id=''BUSTA_TECNICA'' 
						left join ctl_doc_value cde with(NOLOCK) on cde.idheader= V.idMsg and cde.dzt_Name=''lettabusta'' and cde.DSE_id=''BUSTA_ECONOMICA''
						'
		end

		set @SQL= @SQL + '
						left join ctl_doc OFFERTA with(NOLOCK) on OFFERTA.id=V.idMsg 
						left join ctl_doc_sign CS with(NOLOCK) on CS.idheader=V.idMsg

						left join Document_Microlotto_Firme DF with(NOLOCK) on DF.IdHeader=DO.id

						left join ( select 
										idAziPartecipante as idAziPartecipante_TEC,
													NumeroLotto as NumeroLotto_TEC ' +  @str + '

										from Document_PDA_OFFERTE PO with(NOLOCK)
											inner join Document_MicroLotti_Dettagli DM with(NOLOCK) on DM.IdHeader=PO.IdRow and DM.tipodoc=''PDA_OFFERTE'' and dm.numerolotto = ''' + @NumeroLotto + ''' 
										where PO.IdHeader=' + cast(@idpda as varchar(50)) + --@strcond +
										' group by idAziPartecipante,NumeroLotto
									) as VALORI_TEC on VALORI_TEC.NumeroLotto_TEC=V.NumeroLotto and VALORI_TEC.idAziPartecipante_TEC=OFFERTA.Azienda and ( isnull( cdv.value,'''' )  = ''1''  )
						
						left join ( 
									select ' + case when @OE_Escluso = 0 then ' ' else ' top 0 ' end + '
										 idAziPartecipante as idAziPartecipante_ECO,
													NumeroLotto as NumeroLotto_ECO ' + @strEco +			
										' from Document_PDA_OFFERTE PO with(NOLOCK)
											inner join Document_MicroLotti_Dettagli DM with(NOLOCK) on DM.IdHeader=PO.IdRow and DM.tipodoc=''PDA_OFFERTE'' and dm.numerolotto = ''' + @NumeroLotto + ''' 
										where PO.IdHeader=' + cast(@idpda as varchar(50)) + --@strcondEco +
										' group by idAziPartecipante,NumeroLotto
									) as VALORI_ECO on VALORI_ECO.NumeroLotto_ECO=V.NumeroLotto and VALORI_ECO.idAziPartecipante_ECO=OFFERTA.Azienda and ( isnull( cde.value,'''' )  = ''1''  )

						left join ctl_doc ANOMALIA with(NOLOCK) on ANOMALIA.linkeddoc=V.IdRowLottoBando and ANOMALIA.Tipodoc=''VERIFICA_ANOMALIA'' and ANOMALIA.DEleted=0 and ANOMALIA.Statofunzionale=''Confermato''
						left join Document_Verifica_Anomalia DVA with(NOLOCK) on DVA.idheader=ANOMALIA.id and DVA.id_rowLottoOff=V.id
						cross join ( select ' + cast(  @OE_Escluso as varchar) + ' as  OE_Escluso ) as E
				where D.id='+ cast(@IDLotto as varchar(50))		

	END

	--SELECT @SQL
	--return

	---------------------------------------------
	-- recupero dati della parte amministrativa
	---------------------------------------------
	IF @command = 'INFO_AMM'
	BEGIN

		PRINT(@idbando)
		
		-- recupero descrizioni degli allegati richiesti nella parte amministrativa
		select 
				ROW_NUMBER() over (order by idrow) as id,
				cast(DescrizioneRichiesta as nvarchar(MAX))as DescrizioneRichiesta, 
				cast('' as varchar(50)) as Nome_Tecnico 
			into #TEMP_W
			from Document_Bando_DocumentazioneRichiesta 
			where idHeader=@idbando


		-- aggiungo la fisso la riga per gestire altri allegati inseriti di iniziativa
		Insert into #TEMP_W ( id,DescrizioneRichiesta,Nome_Tecnico)
			select ISNULL(max(id),0)+1,'Altri Allegati','AltriAllegati' from #TEMP_W
	
		-- associo iun nome tecnico ad ogni allegato
		update #TEMP_W set Nome_Tecnico='All_'+cast(id as varchar(20)) where Nome_Tecnico=''

		-- creo l'elenco di colonne degli allegati, con le releative descrizioni
		select @NAME_ALLEGATI_BUSTA_AMM=@NAME_ALLEGATI_BUSTA_AMM + Nome_Tecnico + '###' + replace(DescrizioneRichiesta,'''','''''') + '@@@' 
			from #TEMP_W 
			order by id

		ALTER TABLE #TEMP_W ADD IDMSG  INT NULL;

		-- recupero nella tabella temporanea tutti gli allegati delle varie offerte presentate sulla gara
		select 
			   -- case when W.id IS NULL and A.Allegato <> '' then 'AltriAllegati' else w.Nome_Tecnico end as Nome_Tecnico ,
				case 
					when W.id IS NULL and A.Allegato <> '' then 'AltriAllegati' 
					when A.Allegato <> '' then w.Nome_Tecnico 
					else NULL 
				end as Nome_Tecnico ,
				PDA.IdMsg  as ID_MSG  
		into #TMP_NEW
		from  Document_PDA_OFFERTE PDA with(NOLOCK)
			left join CTL_DOC_ALLEGATI A with(NOLOCK) on A.idHeader=PDA.IdMsg 
			left join #TEMP_W W with(NOLOCK)  on  DescrizioneRichiesta=Descrizione			
		where  PDA.IdHeader=@idpda
	
		-- creo la tabella temporanea di appoggio per gestire gli allegati
		select top 0 1 as ID_MSG_ALLEGATI into #TMP_ALLEGATI_AMM

		-- se esistono allegati nelle offerte
		IF EXISTS (select * from #TMP_NEW)
		BEGIN

			-- COSTRUISCO LA TABELLA TEMPORANEA, UN RECORD PER OGNI OFFERTA , CON TANTE COLONNE PER QUANTI ALLEGATI SONO PRESENTI NELLA BUSTA AMMINISTRATIVA + ALTRI ALLEGATI
			select  @cols=@cols +  Nome_Tecnico + '@@@' from (select distinct Nome_tecnico from #TEMP_W) as v	
			select  @SQL = @SQL +' ALTER TABLE #TMP_ALLEGATI_AMM ADD ' +  items + ' varchar(50);' from dbo.split(@cols,'@@@') 
			EXEC (@SQL)


			-- RECUPERO LE COLONNE DEGLI ALLEGATI PER ESPRIMERLE NELLA QUERY COMPLESSIVA NELLA CONDIZIONE DEL PIVOT
			SET @cols = STUFF((SELECT distinct ',' + QUOTENAME(c.Nome_Tecnico) 
									FROM #TEMP_W c
									FOR XML PATH(''), TYPE
									).value('.', 'NVARCHAR(MAX)') 
								,1,1,'')
	

			set @SQL = '	
			select * from 
				(
					select distinct Nome_Tecnico,ID_MSG as ID_MSG_ALLEGATI from #TMP_NEW 
				) as P
				pivot
					(
						min(Nome_Tecnico)
						for p.Nome_Tecnico in ('+@cols+')
					) as PIV'
			
			--print @SQL
			--- ottengo  gli allegati presentati per ogni offerta
			insert into #TMP_ALLEGATI_AMM
				execute(@SQL)
					
			set @sql=''
			set @cols=''
			select  @cols=@cols +  Nome_Tecnico + '@@@' from (select distinct Nome_tecnico from #TEMP_W) as v	

			-- mette le spunte sul risultato
			select  @SQL = @SQL +' update #TMP_ALLEGATI_AMM set ' +  items + '=case when ' + items  + ' IS NULL then ''ko'' else ''ok'' end ;' from dbo.split(@cols,'@@@') 
			EXEC (@SQL)

		END


		-- costruisco la query finale per la parte amministrativa
		set @SQL='select ''' +  @NAME_ALLEGATI_BUSTA_AMM  + ''' as NAME_ALLEGATI_BUSTA_AMM, S.* ,AL.*
					from SEDUTA_VIRTUALE_INFO_AMM S						
						LEFT join #TMP_ALLEGATI_AMM AL on AL.ID_MSG_ALLEGATI=S.idmsg and lettabustadocumentazione=''1'' and ( ( StatoPDA <> ''222'' and ( isnull(InversioneBuste,0) = ''1'' and StatoPDA <> ''8'') ) or isnull(InversioneBuste,0) = ''0'' ) 
					where S.id =' + cast(@idDoc as varchar(50))

	END
	
		
	if @Errore = ''
	begin
		-- rirorna il RS
		 exec (@SQL)
		--select @SQL
	
	end
	else
	begin
		-- rirorna l'errore
		select 'Errore' as id , @Errore as Errore
	end
END











GO
