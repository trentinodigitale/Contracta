USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOSSIER_Load_Messaggi_Dossier_View]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[DOSSIER_Load_Messaggi_Dossier_View] 
(@IdPfu							int,
 @idMSG                           int
)
as
	declare @Param varchar(8000)

	set nocount on

	set @Param = '#~##~#'


	declare @SQLCmd			varchar(8000)

	declare @DZT_Name varchar (50) 
	declare @TipoMem  tinyint 
	declare @Valore	  nvarchar (1000) 
	declare @Condizione varchar (50) 
	declare @TableName varchar (60)
	declare @IdDzt int

	declare @CrLf varchar (10)
	set @CrLf = '
'


	declare @i				int

-------------------------------------------------------------------
-- elimino le informazioni precedentemente popolate
-------------------------------------------------------------------
	delete from Messaggi_Dossier_View where idmsg = @idMSG


-------------------------------------------------------------------
-- recupero in una tabella temporanea gli attributi utilizzati dal dossier
-------------------------------------------------------------------
	exec GetParamDossier 'DASHBOARD_SP_DOSSIER' ,  @Param ,1 , @IdPfu

-------------------------------------------------------------------
-- compongo la query di estrazione delle colonne per la griglia
-------------------------------------------------------------------

	declare @SQLIns varchar (2000)
	declare @SQLColonne varchar (2000)
	declare @SQLWhere varchar (2000)

	set @SQLIns = ''
	set @SQLWhere  = ''
	set @SQLColonne  = ''
	set @i = 1

	declare crs cursor static for 
			SELECT      DZT_Name, TipoMem, Valore, Condizione, TableName , IdDzt
				FROM         TempAttribDossier
							where idPfu = @idPfu and Griglia = 1 and TableName <> '' 
									
	open crs
	fetch next from crs into @DZT_Name, @TipoMem, @Valore, @Condizione, @TableName , @IdDzt

	while @@fetch_status = 0
	begin

			set @SQLIns = @SQLIns + ', ' + @DZT_Name
			set @SQLColonne = @SQLColonne + ', m'  + cast( @i as varchar ) + '.vatValore as ' + @DZT_Name
			set @SQLWhere = @SQLWhere + ' left outer  join ' + @TableName + ' m' + cast( @i as varchar ) + '  WITH (NOLOCK) on m' + cast( @i as varchar ) + '.idmsg = m.idmsg and m' + cast( @i as varchar ) + '.vatIdDzt = ' + cast( @IdDzt as varchar ) + '  ' + @CrLf

			set @i = @i + 1
			fetch next from crs into @DZT_Name, @TipoMem, @Valore, @Condizione, @TableName , @IdDzt
	end
	close crs 
	deallocate crs



	set @SQLCmd =  ' 

	--insert into Messaggi_Dossier_View ( IdMsg ' + @SQLIns + ' )

	select distinct	m.IdMsg ' + @SQLColonne + @CrLf

	set @SQLCmd = @SQLCmd + ' into #TempNewMsg
			from messaggi m WITH (NOLOCK) ' + @CrLf 

    set @SQLCmd = @SQLCmd + @SQLWhere + @CrLf

    set @SQLCmd = @SQLCmd + ' where m.idMsg = ' + cast ( @idMSG  as varchar )+ @CrLf

    set @SQLCmd = @SQLCmd + ' 	insert into Messaggi_Dossier_View ( IdMsg ' + @SQLIns + ' ) select IdMsg ' + @SQLIns + ' from #TempNewMsg ' + @CrLf


	exec (@SQLCmd)
	--print @SQLCmd










GO
