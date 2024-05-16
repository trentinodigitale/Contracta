USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Get_Valore_Attributo_CriterioTecnico]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE procedure [dbo].[Get_Valore_Attributo_CriterioTecnico] (@Attrib VARCHAR(500) , @IdHeaderPda_Offerte int, @LottoVoce as varchar(50), @NumeroLotto as varchar(50), @Dzt_Type as varchar(10) , @Dzt_Domain as varchar(100) )
AS
BEGIN 
 	
	declare @StrSql as nvarchar(max)
	
	set nocount on
	
	set @StrSql=''
	--se attributo non a dominio recupero i valori e li metto su più righe con
	--il trattino davanti
	if @Dzt_Type not in ('4','5','8')
	begin
		
		set @StrSql = '
				declare @Ret as varchar(max)
				set  @Ret = ''''
				select  @Ret = @Ret  +  
				'
		--if @LottoVoce <> 'lotto'
		--begin
		--	set @StrSql = @StrSql + '  '' - '' +  ' 
		--end


		set @StrSql	= @StrSql + 
					
					case @Dzt_Type
						when '2' then ' dbo.AF_FormatNumber(' +  @Attrib + ',0)'
						else + 'cast(' + @Attrib  + ' as varchar(100)) '  
					end +
					
					' + ''<br>''
					from
						document_microlotti_dettagli with (nolock) 
			 		where 
			 			tipodoc=''PDA_OFFERTE'' and idheader = ' +   cast(@IdHeaderPda_Offerte as varchar(50)) + ' and NumeroLotto = ' + @NumeroLotto
		
		if @LottoVoce = 'lotto'
			set @StrSql = @StrSql  + ' and voce = 0 ' 
		
		if @LottoVoce = 'voce'
			set @StrSql = @StrSql  + ' and voce <> 0 ' 
		
		set @StrSql	= @StrSql +  ' select @Ret as Descrizione '

		--print (@StrSql)
		exec (@StrSql)

	end
	else
	begin
		
		--in un cursore recupero i codici poi di questi le desc e li concateno 
		set @StrSql = '
				
				declare @Codice as nvarchar(max)
				declare @Ret as varchar(max)

				DECLARE @ListDesc TABLE
				(
					Descrizione  nvarchar(max)
				)
				
				DECLARE @ListDescRow TABLE
				(
					Descrizione  nvarchar(max)
				)
					
				DECLARE crscodici CURSOR STATIC FOR 

					select ' +  @Attrib + ' as Codice
						from
							document_microlotti_dettagli with (nolock) 
			 			where 
			 				tipodoc=''PDA_OFFERTE'' and idheader = ' +   cast(@IdHeaderPda_Offerte as varchar(50)) + ' and NumeroLotto = ' + @NumeroLotto 

				
				if @LottoVoce = 'lotto'
					set @StrSql = @StrSql  + ' and voce = 0 ' 
		
				if @LottoVoce = 'voce'
					set @StrSql = @StrSql  + ' and voce <> 0 ' 
		
				set @StrSql = @StrSql  + '

				OPEN crscodici

				FETCH NEXT FROM crscodici INTO @Codice
				WHILE @@FETCH_STATUS = 0
				BEGIN
						
						delete @ListDescRow

						--chiamo la stored che risolve il codice e lo inserisco nella tabella delle desc
						insert into @ListDescRow
							exec Get_Desc_Dom ''' + @Dzt_Domain + ''', @Codice ,''I''
						
						set  @Ret = ''''
						select  @Ret = @Ret  +  descrizione + '','' from @ListDescRow

						--tolgo la , finale
						if right(@Ret,1)='',''
							set @Ret = LEFT(@Ret,LEN(@Ret)-1)

						insert into @ListDesc
							select @Ret
								

				FETCH NEXT FROM crscodici INTO @Codice
				END

				CLOSE crscodici 
				DEALLOCATE crscodici 
				
				
				set  @Ret = ''''
				select  @Ret = @Ret  +  '

				--if @LottoVoce <> 'lotto'
				--begin
				--	set @StrSql = @StrSql + ' '' - '' + ' 
				--end
				
				set @StrSql = @StrSql + ' descrizione + ''<br>'' from @ListDesc
				
				select @Ret as Descrizione

				'
			
			--print ( @StrSql	)
			exec ( @StrSql	)
						
						
					
			

	end
	

END






GO
