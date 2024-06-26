USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetParamDossier]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GetParamDossier] (
 @Field		    varchar(80),
 @Value		    varchar(8000),
 @N		        int,
 @idPfu	        int
)

AS
BEGIN 

 	declare @AttrName				varchar(8000)
 	declare @AttrValue				varchar(8000)
	declare @AttrCon				varchar(8000)
	declare @Condition				varchar(80) 
	declare @Ret					varchar(200)
	
	declare @i int
	SET @Ret = ''

	set @i =  charindex('#~#', @Value)
	set @AttrName = substring(@Value, 1, @i - 1)

	set @Value = right( @Value , len( @Value ) - @i - 1 )
	set @i =  charindex('#~#', @Value)
	
	set @AttrValue = substring(@Value, 1, @i - 1)
	set @AttrCon  = right( @Value , len( @Value ) - @i - 1 )


	declare @strTmpVal              varchar(8000)
	declare @strTmpAttr             varchar(8000)
	declare @strTmpVal1             varchar(8000)
	declare @strTmpAttr1            varchar(8000)
	declare @strTmpCon              varchar(8000)
	declare @strTmpCon1             varchar(8000)
	declare @op                     varchar(8000)
	declare @SQLFilterT             varchar(8000)

	declare @posAttr                int
	declare @posVal                 int
	declare @posCon                 int
	declare @Valore					nVARCHAR(1000)
	declare @Condizione				VARCHAR(100)


	declare @cols                   table (colname varchar(100), coltype char(1))

	set @i = 0

	SET @Valore					= ''
	SET @Condizione				= ''


--	drop table #TempAttribDossier
--	declare @Field				varchar(80) 
--	set @Field	 = 'DASHBOARD_SP_DOSSIER'
	-- creo la tabella temporanea per accogliere i campi filtro

	delete from TempAttribDossier  where idPfu = @idPfu
	insert into TempAttribDossier ( idPfu, DZT_Name , TipoMem , IdApp , Griglia , Filtro , Valore , Condizione , TableName , MA_Order , IdDzt)

	select distinct @idPfu as idPfu, MA_DZT_Name as DZT_Name , tidTipoMem as TipoMem ,  apatIdApp as IdApp
			, case when MA_MOD_ID =  @Field + 'Griglia' 
					then 1 else 0 end as Griglia 
			, case when MA_MOD_ID =  @Field + 'Filtro' 
					then 1 else 0 end as Filtro 
			, '' as Valore
			, case when tidTipoMem = 4 then ' like ' else ' = ' end  as Condizione
			, 
				case when MA_DZT_Name not in (  'Name' , 'Protocol' , 'DocumentType' ) 
						then 'MSG' + case when apatIdApp = 14 then '_ART' else '' end + '_Att_Val_' + cast( tidTipoMem as varchar ) 
						else '' 
					end
					as TableName
			, MA_Order 
			, IdDzt
--		into TempAttribDossier
		from LIB_ModelAttributes 
				inner join DizionarioAttributi on ( dztNome = MA_DZT_Name or  (  dztNome = 'TipoAppalto' and MA_DZT_Name = 'TipoAppaltoGaraDossier' ) or  (  dztNome = 'TipoBando' and MA_DZT_Name = 'TipoBandoGara' )  ) and dztDeleted = 0
				inner join TipiDati on dztIdTid = IdTid
				inner join AppartenenzaAttributi on apatIdDzt = idDzt and apatIdApp in ( 14 ,15 )
		where MA_MOD_ID =  @Field + 'Griglia'  -- 'DASHBOARD_SP_DOSSIERGriglia' --
			or MA_MOD_ID =  @Field + 'Filtro'
		--order by 1

		

	set @strTmpAttr = isnull(@AttrName, '')
	set @strTmpVal  = isnull(@AttrValue, '')
	set @strTmpCon  = isnull(@AttrCon, '')

	set @Condition = ''
	set @Ret = ''

			
	
	set @posAttr = 0
--	set @posAttr = charindex( @Field, @strTmpAttr) 
--	if @posAttr  <> 0
	begin 
		while rtrim(@strTmpAttr) <> '' and @Condition = ''
		begin

			set @i = @i +1


				set @posAttr = charindex('#@#', @strTmpAttr)
				set @posVal = charindex('#@#', @strTmpVal)
				set @posCon = charindex('#@#', @strTmpCon)
		                
				if @posAttr = 0
				begin
						set @strTmpAttr1 = @strTmpAttr
						set @strTmpVal1 = @strTmpVal
						set @strTmpCon1 = @strTmpCon
						set @strTmpAttr  = ''
				end
				else
				begin
						set @strTmpAttr1 = substring(@strTmpAttr, 1, @posAttr - 1)
						set @strTmpAttr = substring(@strTmpAttr, @posAttr + 3, len(@strTmpAttr) - @posAttr)
						set @strTmpVal1 = substring(@strTmpVal, 1, @posVal - 1)
						set @strTmpVal = substring(@strTmpVal, @posVal + 3, len(@strTmpVal) - @posVal)
						set @strTmpCon1 = substring(@strTmpCon, 1, @posCon - 1)
						set @strTmpCon = substring(@strTmpCon, @posCon + 3, len(@strTmpCon) - @posCon)
				end

				-- inserisco l'attributo nella tebella temporanea con i dati per il filtro

				update TempAttribDossier set Valore =substring( @strTmpVal1 , 1 + @N , len( @strTmpVal1 ) - (@N * 2 ) )  , 
								Condizione = @strTmpCon1
					WHERE idPfu = @idPfu and DZT_Name = @strTmpAttr1
												
--				if @strTmpAttr1 = @Field
--				begin 
--					set @Condition = @strTmpCon1
--					set @Ret = @strTmpVal1
--				end

		end

		--set @Ret = substring( @Ret , 1 + @N , len( @Ret ) - (@N * 2 ) )

	end

--	RETURN   @Ret

END
GO
