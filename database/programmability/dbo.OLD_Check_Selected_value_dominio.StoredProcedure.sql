USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_Check_Selected_value_dominio]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE PROCEDURE [dbo].[OLD_Check_Selected_value_dominio] (@key_condition varchar(4000), @COLONNA VARCHAR(100), @DZT_Name_Dominio VARCHAR(1000) ,@format varchar(100) = '', @DescColonna as nvarchar(max), @Lng as varchar(10) = 'I')
AS

	IF @COLONNA <> '' AND @DZT_Name_Dominio <> ''
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


				--DOMINIO CON QUERY
				set @SQL_Insert = '
						
						SELECT 
								--A.id,
								--CASE WHEN b.DMV_Cod IS NULL THEN 1 else 0 end AS foglia,
								1 AS foglia,
								cast(A.DMV_DescML as nvarchar(1000)) as DMV_DescML,
								A.DMV_Cod,
								A.DMV_CodExt,
								a.DMV_Deleted,
								a.DMV_Father
							
							INTO #valori_dominio 
							
							FROM   ( '  + @DM_Query + ' ) as A
							
							--WHERE ISNULL(a.DMV_Deleted,0)=0
						
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
								A.DMV_CodExt,
								a.DMV_Deleted,
								a.DMV_Father

							INTO #valori_dominio 

							FROM LIB_DomainValues A with(nolock) 
							
								left outer join LIB_Multilinguismo ml1 with(nolock) on ml1.ML_LNG = ''' + @Lng + ''' and ml1.ML_KEY = A.DMV_DescML
							
							WHERE A.DMV_DM_ID = ''' + @DZT_DM_ID + ''' --and ISNULL(a.DMV_Deleted,0)=0
					
					'

			
			END

			-- SE E' UN GERARCHICO 'FILTRO' I SELEZIONABILI IN FUNZIONE DELLA FORMAT, ALTRIMENTI SONO TUTTI SELEZIONABILI
			IF @DZT_Type = 5
			BEGIN

				-- se manca la A ( ALL ) nella format si vogliono selezionare solo i nodi foglia
				IF CHARINDEX('A', upper(@format)) = 0
				BEGIN

					--set @SQL_Insert = '
					--	SELECT 
					--			--A.id,
					--			--CASE WHEN b.DMV_Cod IS NULL THEN 1 else 0 end AS foglia,
					--			1 AS foglia,
					--			--A.DMV_DescML,
					--			cast( isnull( ml1.ML_Description , A.DMV_DescML) as nvarchar(1000))  as DMV_DescML ,
					--			A.DMV_Cod,
					--			A.DMV_CodExt,
					--			a.DMV_Deleted
					--			into #valori_dominio
					--		FROM LIB_DomainValues A with(nolock) 
					--			left outer join LIB_DomainValues B with(nolock)  on  B.DMV_DM_ID = ''' + @DZT_DM_ID + ''' and A.DMV_Father = left( B.DMV_Father , len( A.DMV_Father ))  and len( a.DMV_Father ) < len( b.DMV_Father )
					--			left outer join LIB_Multilinguismo ml1 with(nolock) on ml1.ML_LNG = ''' + @Lng + ''' and ml1.ML_KEY = A.DMV_DescML

					--		WHERE A.DMV_DM_ID = ''' + @DZT_DM_ID  + ''' and B.id is null --and ISNULL(a.DMV_Deleted,0)=0
						
					--	'
					
					--ho tutto il dominio quindo tolgo tutti i nodi che hanno figli e lascio solo le foglie
					set @SQL_Insert = @SQL_Insert + '
						

						--travaso le foglie in una tabella temporanea #Foglie_Dominio
						select A.dmv_cod 
								
								INTO #Foglie_Dominio 

								from #valori_dominio A
									
									left join #valori_dominio B on   A.DMV_Father = left( B.DMV_Father , len( A.DMV_Father ))  and len( a.DMV_Father ) < len( b.DMV_Father )
								where b.foglia is  null				


						--elimino dal dominio i nodi che non sono foglie
						delete from #valori_dominio  where 	dmv_cod not in (select dmv_cod from #Foglie_Dominio)		
				
					'
							
				END
			END	


			DECLARE @strSQL varchar(max)
			DECLARE @COLONNA_CONFRONTO varchar(1000)

			SET @COLONNA = REPLACE(@COLONNA, '''','''''')

			set @DescColonna = REPLACE(@DescColonna, '''','''''')

			set @strSQL = 'SET NOCOUNT ON '

			set @strSQL =  @strSQL + @SQL_Insert

			set @strSQL = @strSQL   + '
							
							UPDATE Document_microlotti_dettagli
									SET EsitoRiga = EsitoRiga +  CASE WHEN MLG.DMV_Cod is not null then ''<br>Nel campo ' + @DescColonna + ' il valore selezionato nella codifica regionale '''''' + MLG.DMV_DescML + '''''' non è più valido, è stato cancellato. E'''' necessario correggere la codifica del codice regionale''
												   ELSE ''<br>Nel campo ' + @DescColonna + ' il codice '' + ' + @COLONNA + ' + '' presente nella codifica regionale non è più valido, non è presente nei valori selezionabili. E'''' necessario correggere la codifica del codice regionale.''
												END									
								FROM Document_microlotti_dettagli 
										
										cross apply ( select items from dbo.Split(' + @COLONNA + ',''###'') ) as VALORI_COLONNA

										--LEFT JOIN  #valori_dominio  MLG ON  ( mlg.DMV_COD = ' + @COLONNA + ' or ''###'' + mlg.DMV_COD + ''###'' = ' + @COLONNA + ' )
										
										LEFT JOIN  #valori_dominio  MLG ON mlg.DMV_COD = VALORI_COLONNA.Items
												

								WHERE ' + @key_condition + ' and isnull(' + @COLONNA + ' ,'''') <> '''' and ( mlg.DMV_COD is null or mlg.DMV_Deleted = 1 )
							
							
							DROP TABLE #valori_dominio

						   '


			EXEC(@strSQL)
			--print @strSQL

		END

	END


















GO
