USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[DOCUMENT_LOAD_SEC_LISTINO_ORDINI_OE_PRODOTTI]    Script Date: 5/16/2024 2:38:53 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[DOCUMENT_LOAD_SEC_LISTINO_ORDINI_OE_PRODOTTI] (  @DocName nvarchar(500) , @Section nvarchar (500) , @IdDoc nvarchar(500) , @idUser int  )
AS
begin
	
	set nocount on
	
	declare @SQL varchar(max)
	declare @ColumnList varchar(max)
	declare @Modello as varchar(1000)
	declare @colonne_not_edit as varchar(1000)
	set @colonne_not_edit=''
	
	select @Modello=MOD_Name from CTL_DOC_SECTION_MODEL with(nolock) where idheader=@IdDoc and DSE_ID=@Section

	set @ColumnList = ' D.id,D.idheader,D.Tipodoc, '

	select 
				@ColumnList  = @ColumnList  + 'D.' +  c.name + ' , '
				from syscolumns c
					inner join sysobjects o on o.id = c.id
					inner join systypes s on c.xusertype = s.xusertype
					inner join CTL_ModelAttributes a with(nolock) on c.name = MA_DZT_Name and a.MA_MOD_ID = @Modello
				where 
					o.name = 'Document_MicroLotti_Dettagli'
	
	--MI RECUPERO IL MODELLO 
	select @colonne_not_edit=dbo.GetPos(DM.value,'###',4)
		from ctl_doc LO with (nolock)  
			--salgo sul modello specifico legato alla convezione
			inner join ctl_doc M  with (nolock) on M.LinkedDoc = LO.LinkedDoc and M.tipodoc ='CONFIG_MODELLI'
			--vado a prendere l'informazione per le colonne non editabili 
			--da considerare
			left join CTL_DOC_Value DM with (nolock) on DM.IdHeader = M.id and DM.dse_id='STATO_MODELLO' and DM.DZT_Name ='colonne_non_editabili'
		where LO.id=@IdDoc

	--print @ColumnList
	set @SQL = ' select' + @ColumnList + '
	case  
		when d.StatoRiga = ''Inserted'' then '''' 
		when d.StatoRiga in (''Saved'',''Deleted'','''') then ''' + @colonne_not_edit + '''
		else ''''	 
	  end as 	NotEditable
	  
	, case 
			when D.StatoRiga =''Deleted'' then ''../toolbar/ripristina.png''
			else ''../toolbar/Delete_Light.GIF''
		end as 	FNZ_DEL
	--,
	--DM.value
	from Document_MicroLotti_Dettagli D with (nolock)													
			
		where 
			D.tipodoc=''LISTINO_ORDINI_OE'' and D.idheader=' + cast(@IdDoc as varchar(50))

	exec( @SQL )
	--print ( @SQL )

	--select * from Document_Listino_Ordini_OE_Prodotti_View where IdHeader=@IdDoc
end
GO
