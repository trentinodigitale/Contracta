USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_SP_DOSSIER_LISTINI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  proc [dbo].[DASHBOARD_SP_DOSSIER_LISTINI] 
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as
set nocount on

declare @SQLCmd                 varchar(8000)
declare @SQLSelect              varchar(8000)
declare @SQLSubSelect           varchar(8000)
declare @SQLFilterT             varchar(8000)
declare @SQL_Join               varchar(8000)
declare @SQLFilterTSave         varchar(8000)
declare @SQLFilterDSave         varchar(8000)
declare @SQLFilterOrdT          varchar(8000)
declare @SQLFilterOrdD          varchar(8000)

declare @strTmpVal              varchar(8000)
declare @strTmpAttr             varchar(8000)
declare @strTmpVal1             varchar(8000)
declare @strTmpAttr1            varchar(8000)
declare @strTmpOp               varchar(8000)
declare @strTmpOp1              varchar(8000)
declare @SQL_COL              varchar(8000)

declare @op                     varchar(8000)

declare @idAzi varchar(100)

declare @ma_dzt_name            varchar(100)
declare @TipoMem            varchar(100)
declare @DZT_Name            varchar(100)

declare @CARDataIniListino		varchar(100)
declare @CARDataIniListinoA		varchar(100)
declare @CARDataFineListino		varchar(100)
declare @CARDataFineListinoA	varchar(100)


declare @bUnion                 bit
declare @posAttr                int
declare @posVal                 int
declare @posOp                  int
declare @i	int

declare @cols                   table (colname varchar(100), coltype char(1))

set @IdPfu = null

insert into @cols (colname, coltype) 
select a.name, 'T' 
  from syscolumns a, sysobjects b
 where a.id = b.id
   and b.name = 'Articoli'
   and b.xtype = 'u'

set @SQLSelect     = ''
set @SQLSubSelect  = ''
set @SQLFilterT    = ''
set @SQL_Join    = ''
set @bUnion        = 0

set @SQL_COL = ''

declare @CrLf varchar (100)
set @CrLf = '
'

declare @Param varchar(8000)
set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp


set @CARDataIniListino				= dbo.GetParam( 'CARDataIniListino' , @Param ,1) 
set @CARDataIniListinoA				= dbo.GetParam( 'CARDataIniListinoA' , @Param ,1) 
set @CARDataFineListino				= dbo.GetParam( 'CARDataFineListino' , @Param ,1) 
set @CARDataFineListinoA			= dbo.GetParam( 'CARDataFineListinoA' , @Param ,1) 

-------------------------------------------------------------------
-- recupero la lingua dell'utente 
-------------------------------------------------------------------
declare @SuffLNG varchar(50)
set @SuffLNG = 'I'

select @SuffLNG = lngSuffisso from ProfiliUtente inner join Lingue on pfuIdLng = IdLng where idpfu = @IdPfu


--------------------------------------------------------------
-- nel filtro viene passata la lista di idazi di cui si rappresenta il listino
--------------------------------------------------------------
set @idAzi = @Filter

--------------------------------------------------------------
-- determino i criteri di restrizione passati
--  se l'attributo appartiene alla tabella articoli si cerca sulla tabella articoli
--  altrimenti si mette in join la dm_attributi
--------------------------------------------------------------

set @strTmpAttr = isnull(@AttrName, '')
set @strTmpVal  = isnull(@AttrValue, '')
set @strTmpOp   = isnull(@AttrOp, '')
set @SQL_Join = ''
set @i = 1

while rtrim(@strTmpAttr) <> ''
begin
        set @posAttr = charindex('#@#', @strTmpAttr)
        set @posVal = charindex('#@#', @strTmpVal)
        set @posOp = charindex('#@#', @strTmpOp)
                
        if @posAttr = 0
        begin
                set @strTmpAttr1 = @strTmpAttr
                set @strTmpVal1 = @strTmpVal
                set @strTmpOp1 = @strTmpOp
                set @strTmpAttr  = ''
        end
        else
        begin
                set @strTmpAttr1 = substring(@strTmpAttr, 1, @posAttr - 1)
                set @strTmpAttr = substring(@strTmpAttr, @posAttr + 3, len(@strTmpAttr) - @posAttr)
                set @strTmpVal1 = substring(@strTmpVal, 1, @posVal - 1)
                set @strTmpVal = substring(@strTmpVal, @posVal + 3, len(@strTmpVal) - @posVal)
                set @strTmpOp1 = substring(@strTmpOp, 1, @posOp - 1)
                set @strTmpOp = substring(@strTmpOp, @posOp + 3, len(@strTmpOp) - @posOp)
        end

		-- esclude dal filtro in automatico le seguenti colonne
        if @strTmpAttr1 not in ( 'CARDataIniListino' , 'CARDataIniListinoA' , 'CARDataFineListino' , 'CARDataFineListinoA' ) 
        begin
			if @strTmpAttr1 = 'aziRagionesociale'
			begin
					set @SQL_Join = @SQL_Join  + ' inner join aziende on  artIdAzi = idAzi and aziRagionesociale ' + @strTmpOp1 + ' ' +  @strTmpVal1  + @CrLf
			end
			else
			if @strTmpAttr1 = 'Descrizione'
			begin
					set @SQL_Join = @SQL_Join  + ' inner join descs' + @SuffLNG  + ' on  IdDsc = artIdDscDescrizione and dscTesto ' + @strTmpOp1 + ' ' +  @strTmpVal1 + @CrLf
			end
			else
			if @strTmpAttr1 =  'artCode' 
			begin
					set @SQLFilterT = @SQLFilterT  + ' artCode ' + @strTmpOp1 + ' ' +  @strTmpVal1
			end
			else
			if @strTmpAttr1 = 'MercerceologiaFornitore' 
			begin
					set @SQLFilterT = @SQLFilterT  + ' artCspValue ' + @strTmpOp1 + ' ' +  @strTmpVal1
			end
			else
			if exists (select * from @cols where colname = @strTmpAttr1 and coltype = 'T')
			begin
					set  @SQLFilterT = @SQLFilterT  + ' and ' + @strTmpAttr1 + @strTmpOp1 + ' ' +   @strTmpVal1
			end
			else
			begin

					set @SQL_Join = @SQL_Join  + ' inner join  DM_Attributi dm' + cast ( @i as varchar ) + ' on dm' + cast ( @i as varchar ) + '.idApp = 2 and dm' + cast ( @i as varchar ) + '.lnk = idArt  and  dm' + cast ( @i as varchar ) + '.dztNome = ''' + @strTmpAttr1 + ''' and dm' + cast ( @i as varchar ) + '.vatValore_FT ' + @strTmpOp1 + ' ' +   @strTmpVal1 + @CrLf

			end
		end
	
		set @i = @i + 1        
end

if @CARDataIniListino <> '' or @CARDataIniListinoA <> ''
begin
	if @CARDataIniListino <> ''
		set @SQLFilterT = @SQLFilterT  + ' and CARDataIniListino >= ''' + @CARDataIniListino + ''' '

	if @CARDataIniListinoA <> ''
		set @SQLFilterT = @SQLFilterT  + ' and CARDataIniListino <= ''' + @CARDataIniListinoA + ''' '

end

if @CARDataFineListino <> '' or @CARDataFineListinoA <> ''
begin


	set @SQL_Join = @SQL_Join  + ' inner join  DM_Attributi dfm on dfm.idApp = 2 and dfm.lnk = idArt  and  dfm.dztNome = ''CARDataFineListino''  ' 


	if @CARDataFineListino <> '' 
		set @SQL_Join = @SQL_Join  + ' and dfm.vatValore_FT >= ''' + @CARDataFineListino + ''' ' + @CrLf


	if @CARDataFineListinoA <> '' 
		set @SQL_Join = @SQL_Join  + ' and dfm.vatValore_FT <= ''' + @CARDataFineListinoA + ''' ' + @CrLf


end

--------------------------------------------------------------
-- compone la query per determinare gli id articoli
--------------------------------------------------------------
set @SQLCmd = 'set nocount on 
			select IdArt into #TempArticoli from Articoli ' + @CrLf

if @SQL_Join <> ''
	set @SQLCmd = @SQLCmd + @SQL_Join

set @SQLCmd = @SQLCmd + ' where artDeleted = 0 and artIdAzi in ( ' + @idAzi + ' ) ' + @CrLf

if @SQLFilterT <> ''
begin
	set @SQLCmd = @SQLCmd +  @SQLFilterT  + @CrLf
end


--------------------------------------------------------------
-- compone i criteri per la visualizzazione
--------------------------------------------------------------


	set @i = 1

	declare crs cursor static for 
			SELECT      rtrim( MA_DZT_Name ) , coltype
				FROM         LIB_ModelAttributes 
								left outer join ( select a.name , 'T' as coltype
													  from syscolumns a, sysobjects b
													 where a.id = b.id
													   and b.name = 'Articoli'
													   and b.xtype = 'u'  ) as a
												on  name = MA_DZT_Name
							where MA_MOD_ID = 'DASHBOARD_SP_DOSSIER_LISTINIGriglia' 



	open crs
	fetch next from crs into @DZT_Name, @TipoMem

	set @SQL_Join = ''

	while @@fetch_status = 0
	begin


        if @DZT_Name = 'aziRagionesociale'
        begin
				set @SQL_COL = @SQL_COL + ' aziRagionesociale ,'
                set @SQL_Join = @SQL_Join  + ' inner join aziende on  artIdAzi = idAzi '+ @CrLf
        end
        else
        if @DZT_Name = 'Descrizione'
        begin
				set @SQL_COL = @SQL_COL + ' dscTesto as Descrizione ,'
                set @SQL_Join = @SQL_Join  + ' inner join descs' + @SuffLNG  + ' on  IdDsc = artIdDscDescrizione ' + @CrLf
        end
        else
        if @DZT_Name =  'artCode' 
        begin
				set @SQL_COL = @SQL_COL + ' artCode ,'
        end
        else
        if @DZT_Name = 'MercerceologiaFornitore' 
        begin
                set @SQL_COL = @SQL_COL + ' artCspValue  as MercerceologiaFornitore ,'
        end
        else
		if @TipoMem = 'T'
		begin
                set @SQL_COL = @SQL_COL + @DZT_Name + ' ,'
		end
		else
		begin
				set @SQL_COL = @SQL_COL + ' dm' + cast ( @i as varchar ) + '.vatValore_FT as  ' + @DZT_Name + ' ,'
				set @SQL_Join = @SQL_Join  + ' left outer join  DM_Attributi dm' + cast ( @i as varchar ) + ' on dm' + cast ( @i as varchar ) + '.idApp = 2 and dm' + cast ( @i as varchar ) + '.lnk = idArt  and  dm' + cast ( @i as varchar ) + '.dztNome = ''' + @DZT_Name + '''  ' + @CrLf

		end


		set @i = @i + 1
		fetch next from crs into @DZT_Name, @TipoMem

	end
	close crs 
	deallocate crs

	set @i = @i + 1



set @SQLCmd = @SQLCmd + @CrLf + 'select ' + @SQL_COL + ' idArt into #TempResArticoli from articoli ' +@CrLf

if @SQL_Join <> ''
	set @SQLCmd = @SQLCmd + @SQL_Join

set @SQLCmd = @SQLCmd + ' where  IdArt in ( select idart from #TempArticoli ) ' + @CrLf


set @SQLCmd = @SQLCmd + ' select * from #TempResArticoli '
if @Sort <> ''
        set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort

set nocount off

--print @SQLCmd
exec (@SQLCmd)

--set @cnt = @@rowcount



GO
