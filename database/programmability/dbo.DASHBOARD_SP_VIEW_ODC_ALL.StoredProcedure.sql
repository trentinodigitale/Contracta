USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_VIEW_ODC_ALL]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE  proc [dbo].[DASHBOARD_SP_VIEW_ODC_ALL]

						(
							@IdPfu							int,
							@AttrName						nvarchar(max),
							@AttrValue						nvarchar(max),
							@AttrOp 						nvarchar(max),
							@Filter                        nvarchar(max),
							@Sort                          nvarchar(max),
							@Top                           int,
							@Cnt                           int output
						)
as
begin

	declare @Param nvarchar(max)
	
	
	declare @MacroConvenzione as nvarchar(max)
	declare @Convenzione as nvarchar(max)
	declare @PrimoLivelloStruttura as nvarchar(max)	
	declare @TIPO_AMM_ER as nvarchar(max)	
	declare @IdentificativoIniziativa as nvarchar(max)
	declare @Stato1 as nvarchar(max)
	declare @azi_Ente as nvarchar(max)	
	declare @azi_Dest as nvarchar(max)	
	
	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	
	--costruisco select da eseguire
	declare @SQLCmd			nvarchar(max)
	declare @SQLWhere		nvarchar(max)
	
	set @SQLWhere=''
	declare @AttrNameTemp nvarchar(max)

	--tolgo gli attributi che gestisco in modo personalizzato
	set @AttrNameTemp =REPLACE( @AttrName , 'dataApposizioneFirmaDal' , '')
	set @AttrNameTemp =REPLACE( @AttrNameTemp , 'dataApposizioneFirmaAl' , '')
	set @AttrNameTemp =REPLACE( @AttrNameTemp , 'Macro_Convenzione' , '')

	set @AttrNameTemp =REPLACE( @AttrNameTemp , 'DataInvioDal' , '')
	set @AttrNameTemp =REPLACE( @AttrNameTemp , 'DataInvioAl' , '')

	set @AttrNameTemp =REPLACE( @AttrNameTemp , 'StatoDoc1' , '')
	set @AttrNameTemp =REPLACE( @AttrNameTemp , 'IdentificativoIniziativa' , '')
	set @AttrNameTemp =REPLACE( @AttrNameTemp , 'Convenzione' , '')
	set @AttrNameTemp =REPLACE( @AttrNameTemp , 'PrimoLivelloStruttura' , '')
	set @AttrNameTemp =REPLACE( @AttrNameTemp , 'TIPO_AMM_ER' , '')
	set @AttrNameTemp =REPLACE( @AttrNameTemp , 'Azi_Dest' , '')
	set @AttrNameTemp =REPLACE( @AttrNameTemp , 'Azi_Ente' , '')

	--ricavo la condizone di where di base basata sulle colonne della vista  da cui tolgo l'ambito per gestirlo separatamente
	set @SQLWhere = dbo.GetWhere( 'DASHBOARD_VIEW_ODC_ALL' , 'V', @AttrNameTemp ,  @AttrValue ,  @AttrOp )
	
	--print @SQLWhere

	--select ma_dzt_name from LIB_ModelAttributes where ma_mod_id='DASHBOARD_VIEW_TestataOrdini_VisualeGriglia' order by 1

	--aggiungo condizione su macro_convenzione (multivalore) se presente
	set @azi_Ente	= dbo.GetParam( 'Azi_Ente'	, @Param ,1)
	set @azi_Dest	= dbo.GetParam( 'Azi_Dest'	, @Param ,1)


	declare @DataApposizioneDal as varchar(50)
	declare @DataApposizioneAl as varchar(50)

	declare @DataInvioDal as varchar(50)
	declare @DataInvioAl as varchar(50)
	
	set @DataInvioDal						= replace(dbo.GetParam( 'DataInvioDal' , @Param ,1) ,'''','''''')
	set @DataInvioAl						= replace(dbo.GetParam( 'DataInvioAl'  , @Param ,1) ,'''','''''')

	set @DataApposizioneDal						= replace(dbo.GetParam( 'dataApposizioneFirmaDal' , @Param ,1) ,'''','''''')
	set @DataApposizioneAl						= replace(dbo.GetParam( 'dataApposizioneFirmaAl'  , @Param ,1) ,'''','''''')
	


	set @SQLCmd =  '
					
					select 
						DMV_Cod, isnull(ml_description,dmv_descml) as dmv_descml
						into #t1
						from LIB_DomainValues with (nolock)
							left join lib_multilinguismo with (nolock) on ml_key=dmv_descml and ml_key=''I''
						where dmv_dm_id=''TIPO_AMM_ER''


					select 
						DMV_Cod, isnull(ml_description,dmv_descml) as dmv_descml
						into #t11
						from LIB_DomainValues with (nolock)
							left join lib_multilinguismo with (nolock) on ml_key=dmv_descml and ml_key=''I''
						where dmv_dm_id=''Ambito''


					
						  '


	set @SQLCmd =  @SQLCmd + ' select 
								O.RDA_ID,
								O.Id, O.IdPfu, O.Data , O.dataapposizionefirma, O.dataapposizionefirmaDal, O.dataapposizionefirmaAl,
								O.aziprovinciaLeg,O.aziRagioneSociale,O.NumeroOrdinativo,O.UserRup,O.NumOrd,
								O.OPEN_DOC_NAME, O.Protocollo,O.ProtocolloOrdinativoIntegrato, O.rda_object,
								O.RDA_Total,O.StatoFunzionale,O.Azi_Dest,O.Convenzione,O.PrimoLivelloStruttura, O.TIPO_AMM_ER,
	   							--A.aziragionesociale as RAGIONE_SOCIALE_FORNITORE , 
								--C.titolo as DOC_Name, P.dmv_descml as CampoTesto_1, S. dmv_descml as CampoTesto_2
								--,PU.pfunome as NomeUtente, 
								O.Multiplo,O.Titolo,O.DataI, O.RDA_DataScad,O.DataInvio,O.APS_Date						
								,O.NoteContratto
								,O.RDA_DataCreazione
								,O.macro_convenzione
								, DataInvioDal,DataInvioAl,azi_ente,StatoDoc1,o.pfuNome
								, o.CIG
								, o.fuoripiattaforma
								--, dc.IdentificativoIniziativa
								--, PUA.attvalue as AreaDiAppartenenza
								,O.ambito
								,O.CIG_MADRE
								--,AB. dmv_descml as CampoTesto_3
								,O.rda_stato
								,O.StatoDoc
							into #t 
								from DASHBOARD_VIEW_ODC_ALL O with (nolock)
								
							'
	declare @InsertWhere as int
	
	set @InsertWhere = 0

	if @Filter <> ''
	begin
		

		set @Filter = REPLACE( @Filter , 'StatoDoc' , 'O.StatoDoc')		
		set @Filter = REPLACE( @Filter , 'StatoFunzionale' , 'O.StatoFunzionale')		
		set   @SQLCmd = @SQLCmd + ' where ( ' + @Filter + ' ) '
		set @InsertWhere = 1
	end
	

	if 	@SQLWhere <> ''
	begin
		
		set @SQLWhere = REPLACE( @SQLWhere , 'Titolo' , 'O.Titolo')
		set @SQLWhere = REPLACE( @SQLWhere , 'Protocollo' , 'O.Protocollo')
		--set @SQLWhere = REPLACE( @SQLWhere , 'AZI_Dest' , 'O.AZI_Dest')
		set @SQLWhere = REPLACE( @SQLWhere , 'UserRUP' , 'O.UserRUP')
		set @SQLWhere = REPLACE( @SQLWhere , 'Ambito' , 'O.Ambito')
		--set @SQLWhere = REPLACE( @SQLWhere , 'Macro_Convenzione' , 'O.Macro_Convenzione')
		if  @InsertWhere = 1
		BEGIN
			set   @SQLCmd = @SQLCmd +  ' and  ' + @SQLWhere
		END
		ELSE
		BEGIN 
			set   @SQLCmd = @SQLCmd +  ' where  ' + @SQLWhere
		END
		
		set @InsertWhere = 1
	end

	if @azi_Dest <> ''
	begin
	
		if @InsertWhere = 1

			set @SQLCmd = @SQLCmd + ' and o.Azi_dest in ( ''' + replace( @Azi_dest, '###' , ''',''') + ''')'
		
		else
			begin
				set @SQLCmd = @SQLCmd + ' where o.Azi_dest in ( ''' + replace( @Azi_dest, '###' , ''',''') + ''')'
				set @InsertWhere = 1
			end
	end	

	if @azi_Ente <> ''
	begin
	
		if @InsertWhere = 1

			set @SQLCmd = @SQLCmd + ' and o.Azi_Ente in ( ''' + replace( @azi_Ente, '###' , ''',''') + ''')'
		
		else
			begin
				set @SQLCmd = @SQLCmd + ' where o.Azi_Ente in ( ''' + replace( @azi_Ente, '###' , ''',''') + ''')'
				set @InsertWhere = 1
			end
	end	

	if @DataInvioDal <> ''
	begin
		if @InsertWhere = 1
			set @SQLCmd = @SQLCmd + ' and DataInvioDal >= ''' + @DataInvioDal + ''''
		else
		begin
			set @SQLCmd = @SQLCmd + ' where DataInvioDal >= ''' + @DataInvioDal + ''''
			set @InsertWhere = 1
		end
	end

	if @DataInvioAl <> ''
	begin
		if @InsertWhere = 1
			set @SQLCmd = @SQLCmd + ' and DataInvioAl <= ''' + @DataInvioAl + ''''
		else
		begin
			set @SQLCmd = @SQLCmd + ' where DataInvioAl <= ''' + @DataInvioAl + ''''
			set @InsertWhere = 1
		end
	end


	if @DataApposizioneDal <> ''
	begin
		if  @InsertWhere = 1
			set @SQLCmd = @SQLCmd + ' and o.dataApposizioneFirmaDal >= ''' + @DataApposizioneDal + ''''
		else
		begin
			set @SQLCmd = @SQLCmd + ' where o.dataApposizioneFirmaDal >= ''' + @DataApposizioneDal + ''''
			set @InsertWhere = 1
		end
	end

	if @DataApposizioneAl <> ''
	begin
		if @InsertWhere = 1
			set @SQLCmd = @SQLCmd + ' and o.dataApposizioneFirmaAl <= ''' + @DataApposizioneAl + ''''
		else
		begin
			set @SQLCmd = @SQLCmd + ' where o.dataApposizioneFirmaAl <= ''' + @DataApposizioneAl + ''''
			set @InsertWhere = 1
		end
	end


	--aggiungo condizione su macro_convenzione (multivalore) se presente
	set @MacroConvenzione	= dbo.GetParam( 'Macro_Convenzione'	, @Param ,1)
	
	if @MacroConvenzione <> ''
	begin
	
		if @InsertWhere = 1

			set @SQLCmd = @SQLCmd + ' and o.macro_convenzione in ( ''' + replace( @MacroConvenzione, '###' , ''',''') + ''')'
		
		else
			begin
				set @SQLCmd = @SQLCmd + ' where o.macro_convenzione in ( ''' + replace( @MacroConvenzione, '###' , ''',''') + ''')'
				set @InsertWhere = 1
			end
	end	

	
	

	--aggiungo condizione su macro_convenzione (multivalore) se presente
	set @Convenzione	= dbo.GetParam( 'Convenzione'	, @Param ,1)
	
	if @Convenzione <> ''
	begin
	
		if @InsertWhere = 1

			set @SQLCmd = @SQLCmd + ' and o.convenzione in ( ''' + replace( @Convenzione, '###' , ''',''') + ''')'
		
		else
			begin
				set @SQLCmd = @SQLCmd + ' where o.convenzione in ( ''' + replace( @Convenzione, '###' , ''',''') + ''')'
				set @InsertWhere = 1
			end
	end	


	

	--aggiungo condizione su macro_convenzione (multivalore) se presente
	set @PrimoLivelloStruttura	= dbo.GetParam( 'PrimoLivelloStruttura'	, @Param ,1)
	
	if @PrimoLivelloStruttura <> ''
	begin
	
		if @InsertWhere = 1

			set @SQLCmd = @SQLCmd + ' and o.PrimoLivelloStruttura in ( ''' + replace( @PrimoLivelloStruttura, '###' , ''',''') + ''')'
		
		else
			begin
				set @SQLCmd = @SQLCmd + ' where o.PrimoLivelloStruttura in ( ''' + replace( @PrimoLivelloStruttura, '###' , ''',''') + ''')'
				set @InsertWhere = 1
			end
	end	

	--aggiungo condizione su macro_convenzione (multivalore) se presente
	set @TIPO_AMM_ER	= dbo.GetParam( 'TIPO_AMM_ER'	, @Param ,1)
	
	if @TIPO_AMM_ER <> ''
	begin
	
		if @InsertWhere = 1

			set @SQLCmd = @SQLCmd + ' and o.TIPO_AMM_ER in ( ''' + replace( @TIPO_AMM_ER, '###' , ''',''') + ''')'
		
		else
			begin
				set @SQLCmd = @SQLCmd + ' where o.TIPO_AMM_ER in ( ''' + replace( @TIPO_AMM_ER, '###' , ''',''') + ''')'
				set @InsertWhere = 1
			end
	end	

	set @SQLCmd = @SQLCmd + '
	CREATE NONCLUSTERED INDEX [index_temp_#t]
								ON [dbo].[#t] ([Convenzione])
									INCLUDE ([RDA_ID],[Id],[IdPfu],[Data],[dataapposizionefirma],[dataapposizionefirmaDal],[dataapposizionefirmaAl],[aziprovinciaLeg],[aziRagioneSociale],[NumeroOrdinativo],[UserRup],[NumOrd],[OPEN_DOC_NAME],[Protocollo],[ProtocolloOrdinativoIntegrato],[rda_object],[RDA_Total],[StatoFunzionale],[Azi_Dest],[PrimoLivelloStruttura],[TIPO_AMM_ER],[Multiplo],[Titolo],[DataI],[RDA_DataScad],[DataInvio],[APS_Date],[NoteContratto],[RDA_DataCreazione],[macro_convenzione],[DataInvioDal],[DataInvioAl],[azi_ente],[StatoDoc1],[pfuNome],[CIG],[fuoripiattaforma],[ambito],[CIG_MADRE])
									
									'

	set @SQLCmd =  @SQLCmd + ' 
							  select 
								O.RDA_ID,
								O.Id, O.IdPfu, O.Data , O.dataapposizionefirma, O.dataapposizionefirmaDal, O.dataapposizionefirmaAl,
								O.aziprovinciaLeg,O.aziRagioneSociale,O.NumeroOrdinativo,O.UserRup,O.NumOrd,
								O.OPEN_DOC_NAME, O.Protocollo,O.ProtocolloOrdinativoIntegrato, O.rda_object,
								O.RDA_Total,O.StatoFunzionale,O.Azi_Dest,O.Convenzione,O.PrimoLivelloStruttura, O.TIPO_AMM_ER,
	   							A.aziragionesociale as RAGIONE_SOCIALE_FORNITORE , 
								C.titolo as DOC_Name, P.dmv_descml as CampoTesto_1, S. dmv_descml as CampoTesto_2
								,PU.pfunome as NomeUtente 
								,O.Multiplo,O.Titolo,O.DataI, O.RDA_DataScad,O.DataInvio,O.APS_Date						
								,O.NoteContratto
								,O.RDA_DataCreazione
								,O.macro_convenzione
								, DataInvioDal,DataInvioAl,azi_ente,StatoDoc1,o.pfuNome
								, o.CIG
								, o.fuoripiattaforma
								, dc.IdentificativoIniziativa
								, PUA.attvalue as AreaDiAppartenenza
								,O.ambito
								,O.CIG_MADRE
								,AB. dmv_descml as CampoTesto_3
								,u.IdPfu as DOC_Owner
								into #t_finale
								from #t O
									inner join aziende A with (nolock)  on A.IdAzi=O.AZI_Dest
									inner join document_convenzione DC  with (nolock) on O.Convenzione = DC.id
									inner join ctl_doc C with (nolock) on C.id= DC.id 
									inner join  #t1 P on  PrimoLivelloStruttura = P.dmv_cod
									inner join  #t1 S on  TIPO_AMM_ER = S.dmv_cod
									inner join  #t11 AB on  O.ambito = AB.dmv_cod
									inner join profiliutente PU with (nolock) on PU.idpfu= O.UserRup
									left join profiliutenteattrib PUA with (nolock) on PUA.idpfu= O.UserRup and dztnome = ''AreaDiAppartenenza''
									inner join ProfiliUtente compilatore with(nolock) on compilatore.idpfu = c.idpfu
									inner join ProfiliUtente u with(nolock) on u.pfuidazi = compilatore.pfuidazi
								'

	set @InsertWhere = 0
	--------------------------------------------------------------------
	
	--print @DataApposizioneDal
	--print @DataApposizioneAl
	
	if @IdPfu <> ''
	begin
		if  @InsertWhere = 1
			set @SQLCmd = @SQLCmd + ' and u.IdPfu = ' + cast( @IdPfu as varchar(20))
		else
		begin
			set @SQLCmd = @SQLCmd + ' where u.IdPfu = ' + cast( @IdPfu as varchar(20))
			set @InsertWhere = 1
		end
		
	end 

	
	

	
	--aggiungo condizione su macro_convenzione (multivalore) se presente
	set @IdentificativoIniziativa	= dbo.GetParam( 'IdentificativoIniziativa'	, @Param ,1)
	if @IdentificativoIniziativa <> ''
	begin
	
		if @InsertWhere = 1

			set @SQLCmd = @SQLCmd + ' and dc.IdentificativoIniziativa in ( ''' + replace( @IdentificativoIniziativa, '###' , ''',''') + ''')'
		
		else
			begin
				set @SQLCmd = @SQLCmd + ' where dc.IdentificativoIniziativa in ( ''' + replace( @IdentificativoIniziativa, '###' , ''',''') + ''')'
				set @InsertWhere = 1
			end
	end	

	--aggiungo condizione su StatoDoc1 (multivalore) se presente
	set @Stato1	= dbo.GetParam( 'StatoDoc1'	, @Param ,1)

	if @Stato1 <> ''
	begin
	
		if @InsertWhere = 1

			set @SQLCmd = @SQLCmd + ' and StatoDoc1 in ( ''' + replace( @Stato1, '###' , ''',''') + ''')'
		
		else
		begin
			set @SQLCmd = @SQLCmd + ' where StatoDoc1 in ( ''' + replace( @Stato1, '###' , ''',''') + ''')'
			set @InsertWhere = 1
		end
	end	
	---------------------------------
	

	--if rtrim( @Sort ) <> ''
	--	set @SQLCmd=@SQLCmd + ' order by ' + @Sort 

  --print @SQLCmd
   --return
   
	
	--valorizzo NoteContratto sull'insieme ritornato
	--set @SQLCmd= @SQLCmd + '

	--					CREATE CLUSTERED INDEX IDX_C_ODC_ID ON #t(id)

	--					update #t 
	--						set NoteContratto=N.value
	--							from #t
	--								inner join ctl_doc_value N with (nolock) on N.IdHeader=id and N.dse_id=''NOTECONTRATTO'' and N.DZT_Name=''NoteContratto'' and N.Row=0 '
	
	
	set @SQLCmd = @SQLCmd + '

					  select * from #t_finale '
	
	
	


	if rtrim( @Sort ) <> ''
		set @SQLCmd= @SQLCmd + ' order by ' + @Sort 
	
	--set nocount on
	--insert into CTL_LOG_UTENTE ([form],idpfu) values (@SQLCmd,-99999)
	--select @SQLCmd
	exec (@SQLCmd)

	--print @SQLCmd

	--select @cnt = count(*) from #temp
	--set @cnt = @@rowcount

end






GO
