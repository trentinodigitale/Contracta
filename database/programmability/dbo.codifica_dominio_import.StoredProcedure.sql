USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[codifica_dominio_import]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO




CREATE PROCEDURE [dbo].[codifica_dominio_import] (@key_condition varchar(4000), @COLONNA_IMPORT VARCHAR(100), @DZT_Name_Dominio VARCHAR(1000),@MA_DescML nvarchar(4000), @format varchar(100) = '', @STRINGA_NOT_FOUND varchar(1000) = '(((DECODE_ERROR)))' , @Appl_Cond_Colonna_A varchar(10) ='yes', @Lng as varchar(10) = 'I', @extended_filter as NVARCHAR(400) = '' )
AS

	IF @COLONNA_IMPORT <> '' AND @DZT_Name_Dominio <> ''
	BEGIN

		SET NOCOUNT ON

		DECLARE @DZT_Type INT
		DECLARE @DZT_DM_ID varchar(500)
		DECLARE @DZT_FORMAT varchar(100)
		declare @SQL_Insert nvarchar(max)
		DECLARE @DM_Query varchar(max)

		select 
				@DZT_Type = DZT_Type, 
				@DZT_DM_ID = DZT_DM_ID, 
				@DZT_FORMAT = isnull(dzt.DZT_Format,''),
				@DM_Query = isnull(DM_Query,'')
			
			from LIB_Dictionary dzt with(nolock) 
				inner join LIB_Domain with(nolock)  on DM_ID=DZT_DM_ID
			where dzt.DZT_Name = @DZT_Name_Dominio
	
		


		-- SE E' UN DOMINIO
		IF @DZT_Type in (4,5,8)
		BEGIN

			IF isnull(@format,'') = ''
				set @format = @DZT_FORMAT
			
			
			if @DM_Query <> ''
			BEGIN

				set @DM_Query = REPLACE(@DM_Query,'#LNG#',@Lng)


				if charindex( ' order by' , @DM_Query ) > 0 
				begin 
					set @DM_Query = left( @DM_Query , charindex( ' order by' , @dm_query ) )
				end

				if charindex( 'order by' , @DM_Query ) > 0 
				begin 
					set @DM_Query = left( @DM_Query , charindex( 'order by' , @dm_query )-1 )
				end

				if @extended_filter <> ''
				BEGIN
					set @DM_Query = @DM_Query + @extended_filter 
				END

				--DOMINIO CON QUERY
				set @SQL_Insert = '
						SELECT 
								--A.id,
								--CASE WHEN b.DMV_Cod IS NULL THEN 1 else 0 end AS foglia,
								1 AS foglia,
								cast(A.DMV_DescML as nvarchar(1000)) as DMV_DescML,
								cast(A.DMV_Cod as varchar(max)) as DMV_Cod,
								A.DMV_CodExt
								into #valori_dominio 
							
							FROM   ( '  + @DM_Query + ' ) as A
							
							WHERE ISNULL(a.DMV_Deleted,0)=0
						
						'

			END
			ELSE
			BEGIN
				--DOMINIO STATICO
				set @SQL_Insert = '
						SELECT 
								--A.id,
								--CASE WHEN b.DMV_Cod IS NULL THEN 1 else 0 end AS foglia,
								1 AS foglia,
								cast( isnull( ml1.ML_Description , A.DMV_DescML) as nvarchar(1000))  as DMV_DescML ,
								A.DMV_Cod,
								A.DMV_CodExt
								into #valori_dominio 
							FROM LIB_DomainValues A with(nolock) 
								left outer join LIB_Multilinguismo ml1 with(nolock) on ml1.ML_LNG = ''' + @Lng + ''' and ml1.ML_KEY = A.DMV_DescML
							WHERE A.DMV_DM_ID = ''' + @DZT_DM_ID + ''' and ISNULL(a.DMV_Deleted,0)=0
					
					'

			
			END

			-- SE E' UN GERARCHICO 'FILTRO' I SELEZIONABILI IN FUNZIONE DELLA FORMAT, ALTRIMENTI SONO TUTTI SELEZIONABILI
			IF @DZT_Type = 5
			BEGIN

				-- se manca la A ( ALL ) nella format si vogliono selezionare solo i nodi foglia
				IF CHARINDEX('A', upper(@format)) = 0
				BEGIN
					if @DM_Query <> ''
					BEGIN 
						set @SQL_Insert = '
							select * into #tmp_q_ger from (' + @DM_Query + ') as K
							SELECT 
									--A.id,
									--CASE WHEN b.DMV_Cod IS NULL THEN 1 else 0 end AS foglia,
									1 AS foglia,
									A.DMV_DescML,
									--cast( isnull( ml1.ML_Description , A.DMV_DescML) as nvarchar(1000))  as DMV_DescML ,
									A.DMV_Cod,
									A.DMV_CodExt
									into #valori_dominio
								FROM   ( select * from #tmp_q_ger ) as A								
									left outer join ( select * from #tmp_q_ger ) as B  on  B.DMV_DM_ID = ''' + @DZT_DM_ID + ''' and A.DMV_Father = left( B.DMV_Father , len( A.DMV_Father ))  and len( a.DMV_Father ) < len( b.DMV_Father )
									--left outer join LIB_Multilinguismo ml1 with(nolock) on ml1.ML_LNG = ''' + @Lng + ''' and ml1.ML_KEY = A.DMV_DescML

								WHERE A.DMV_DM_ID = ''' + @DZT_DM_ID  + ''' and B.DMV_DM_ID is null and ISNULL(a.DMV_Deleted,0)=0
						
							'
					END
					ELSE
					BEGIN
						set @SQL_Insert = '
							SELECT 
									--A.id,
									--CASE WHEN b.DMV_Cod IS NULL THEN 1 else 0 end AS foglia,
									1 AS foglia,
									--A.DMV_DescML,
									cast( isnull( ml1.ML_Description , A.DMV_DescML) as nvarchar(1000))  as DMV_DescML ,
									A.DMV_Cod,
									A.DMV_CodExt
									into #valori_dominio
								FROM LIB_DomainValues A with(nolock) 
									left outer join LIB_DomainValues B with(nolock)  on  B.DMV_DM_ID = ''' + @DZT_DM_ID + ''' and A.DMV_Father = left( B.DMV_Father , len( A.DMV_Father ))  and len( a.DMV_Father ) < len( b.DMV_Father )
									left outer join LIB_Multilinguismo ml1 with(nolock) on ml1.ML_LNG = ''' + @Lng + ''' and ml1.ML_KEY = A.DMV_DescML

								WHERE A.DMV_DM_ID = ''' + @DZT_DM_ID  + ''' and B.id is null and ISNULL(a.DMV_Deleted,0)=0
						
							'
					END							
				END
			END	


			DECLARE @strSQL varchar(max)
			DECLARE @COLONNA_IMPORT_CONFRONTO varchar(1000)

			SET @COLONNA_IMPORT = REPLACE(@COLONNA_IMPORT, '''','''''')
			SET @COLONNA_IMPORT_CONFRONTO = 'RTRIM(LTRIM(' + @COLONNA_IMPORT + '))'

			SET @DZT_Name_Dominio = REPLACE(@DZT_Name_Dominio, '''','''''')
			SET @STRINGA_NOT_FOUND = REPLACE(@STRINGA_NOT_FOUND, '''','''''')

			

			set @strSQL = 'SET NOCOUNT ON '

			set @strSQL =  @strSQL + @SQL_Insert

			set @strSQL = @strSQL   + '
							UPDATE CTL_IMPORT
									SET ' + @COLONNA_IMPORT + ' = CASE WHEN MLG.DMV_Cod is not null then MLG.DMV_Cod
												   ELSE ''' + @STRINGA_NOT_FOUND + '''
												END									
								FROM CTL_IMPORT with(nolock)

										-- 2. ASSOCIAZIONE PER DESCRIZIONE
										LEFT JOIN 
										  #valori_dominio  MLG ON

												--mlg.dmvDESC = ' + @COLONNA_IMPORT_CONFRONTO + ' 
												mlg.DMV_DescML = ' + @COLONNA_IMPORT_CONFRONTO + ' 
												or
												mlg.DMV_COD = ' + @COLONNA_IMPORT_CONFRONTO + ' 
												or
												--mlg.DMV_CodExt + '' - '' +  mlg.dmvDESC = ' + @COLONNA_IMPORT_CONFRONTO + ' 
												mlg.DMV_CodExt + '' - '' +  mlg.DMV_DescML = ' + @COLONNA_IMPORT_CONFRONTO + ' 
												or
												mlg.DMV_CodExt = ' + @COLONNA_IMPORT_CONFRONTO + ' 

								WHERE ' + @key_condition + ' and isnull(' + @COLONNA_IMPORT_CONFRONTO + ' ,'''') <> '''' '

			--se richiesto applico condizione sulla colonna A che deve essere numerica 			
			if @Appl_Cond_Colonna_A = 'yes'				
				set @strSQL = @strSQL + ' and [A] IS NOT NULL and isnumeric(isnull([A],0))=1
						   '


			EXEC(@strSQL)
			--print (@strSQL)

		END

	END



GO
