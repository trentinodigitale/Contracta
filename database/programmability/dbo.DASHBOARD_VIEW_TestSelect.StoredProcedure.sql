USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DASHBOARD_VIEW_TestSelect]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[DASHBOARD_VIEW_TestSelect] 
(@IdPfu			        int,
 @AttrName		        varchar(8000),
 @AttrValue		        varchar(8000),
 @Criteria                        varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as
--select * from DASHBOARD_VIEW_COM_ESCLUSIONE

--exec DASHBOARD_VIEW_TestSelect 1,'StatoEsclusione','''Saved''','','',1,1

set nocount on

declare @SQLCmd                 varchar(8000)
declare @SQLSelect              varchar(8000)
declare @SQLSubSelect           varchar(8000)
declare @SQLFilterT             varchar(8000)
declare @SQLFilterD             varchar(8000)
declare @SQLFilterTSave         varchar(8000)
declare @SQLFilterDSave         varchar(8000)
declare @SQLFilterOrdT          varchar(8000)
declare @SQLFilterOrdD          varchar(8000)

declare @strTmpVal              varchar(8000)
declare @strTmpAttr             varchar(8000)
declare @strTmpVal1             varchar(8000)
declare @strTmpAttr1            varchar(8000)
declare @op                     varchar(8000)

declare @ma_dzt_name            varchar(100)
declare @bUnion                 bit
declare @posAttr                int
declare @posVal                 int

declare @cols                   table (colname varchar(100), coltype char(1))


insert into @cols (colname, coltype) 
select a.name, 'T' 
  from syscolumns a, sysobjects b
 where a.id = b.id
   and b.name = 'DASHBOARD_VIEW_COM_ESCLUSIONE'
   and b.xtype = 'u'
/*
union all
select a.name, 'D' 
  from syscolumns a, sysobjects b
 where a.id = b.id
   and b.name = 'document_bolla_product'
   and b.xtype = 'u'
*/
set @SQLSelect     = ''
set @SQLSubSelect  = ''
set @SQLFilterT    = ''
set @SQLFilterD    = ''
set @bUnion        = 0

if @Top <> -1
   set @SQLSelect = 'select top ' + cast(@top as varchar) + ' '
else
   set @SQLSelect = 'select ' 
/*
declare crsMod cursor static for select replace(ma_dzt_name, 'StatoBolle', 'Stato as StatoBolle') as ma_dzt_name from lib_modelattributes where ma_mod_id = 'DASHBOARD_VIEW_BOLLE_CLIENTEGriglia' order by ma_order


open crsMod

fetch next from crsMod into @ma_dzt_name

set @SQLSelect = @SQLSelect + @ma_dzt_name

while @@fetch_status = 0
begin

        fetch next from crsMod into @ma_dzt_name
        
        if @@fetch_status <> 0 break

        set @SQLSelect = @SQLSelect + ', ' + @ma_dzt_name
end 

close crsMod
deallocate crsMod
*/
set @SQLSelect = @SQLSelect + ' *  from DASHBOARD_VIEW_COM_ESCLUSIONE'


set @strTmpAttr = isnull(@AttrName, '')
set @strTmpVal  = isnull(@AttrValue, '')

while rtrim(@strTmpAttr) <> ''
begin
        set @posAttr = charindex('#@#', @strTmpAttr)
        set @posVal = charindex('#@#', @strTmpVal)
                
        if @posAttr = 0
        begin
                set @strTmpAttr1 = @strTmpAttr
                set @strTmpVal1 = @strTmpVal
                set @strTmpAttr  = ''
        end
        else
        begin
                set @strTmpAttr1 = substring(@strTmpAttr, 1, @posAttr - 1)
                set @strTmpAttr = substring(@strTmpAttr, @posAttr + 3, len(@strTmpAttr) - @posAttr)
                set @strTmpVal1 = substring(@strTmpVal, 1, @posVal - 1)
                set @strTmpVal = substring(@strTmpVal, @posVal + 3, len(@strTmpVal) - @posVal)
        end

        if @strTmpAttr1 = 'DataBolla'
                set @op = ' >= '
        else
        if @strTmpAttr1 = 'DataBollaA'
        begin
                set @strTmpAttr1 = 'DataBolla'
                set @op = ' <= '
        end    
        else
        if @strTmpAttr1 = 'StatoBolle'
        begin
                set @strTmpAttr1 = 'Stato'
        end       
        else if charindex('%', @strTmpVal1) <> 0
           set @op = ' like '
        else
           set @op = ' = '
           
        if @strTmpAttr1 = 'RifOrdCli' or @strTmpAttr1 = 'RifDettOrdCli'
        begin
                set @bUnion = 1
                set @SQLFilterOrdT = ' RifOrdCli ' + @op + @strTmpVal1
                set @SQLFilterOrdD = ' RifDettOrdCli ' + @op + @strTmpVal1

        end
        else
        /*if exists (select * from @cols where colname = @strTmpAttr1 and coltype = 'T')
        begin
                if @SQLFilterT = ''
                        set  @SQLFilterT = ' where ' + @strTmpAttr1  + @op +  @strTmpVal1
                else
                        set  @SQLFilterT = @SQLFilterT  + ' and ' + @strTmpAttr1 + @op +  @strTmpVal1
        end
        else*/
        begin
                if @SQLFilterD = ''
                        set  @SQLFilterD = ' where ' + @strTmpAttr1  + @op +  @strTmpVal1
                else
                        set  @SQLFilterD = @SQLFilterD + ' and ' + @strTmpAttr1 + @op +  @strTmpVal1
        end
        
end


set @SQLCmd = 'select * from DASHBOARD_VIEW_COM_ESCLUSIONE ' + @SQLFilterD 

if @Filter <> ''
	if @SQLFilterT = ''
        set @SQLCmd = @SQLCmd + 'where ' + @Filter
	else
        set @SQLCmd = @SQLCmd + ' and ' + @Filter

 

if @Sort <> ''
        set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort

set nocount off

--print @SQLCmd
exec (@SQLCmd)

set @cnt = @@rowcount

GO
