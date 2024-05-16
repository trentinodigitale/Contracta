USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[GetInfoClassiIscrizForPrintIstanza]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[GetInfoClassiIscrizForPrintIstanza] ( @idDoc int, @HtmlOut nvarchar(max) output  )

AS
BEGIN
	set nocount on

	--declare @idDoc int
	declare @idDocAddInfo int
	declare @TipoDocAddInfo varchar(500)

	--set @idDoc = 84707

	set @HtmlOut = ''

	-- recupera il documento di informazioni aggiuntive collegato
	select 
			@idDocAddInfo = id  
			, @TipoDocAddInfo  = tipoDoc
		from ctl_doc with(nolock) 
		where linkeddoc = @idDoc and tipodoc like 'INSTANZA_ME_INFO_AGGIUNTIVE_%' and deleted = 0 

--select *
--	from ctl_doc with(nolock) 
--	where linkeddoc = 84707 and tipodoc like 'INSTANZA_ME_INFO_AGGIUNTIVE_%' and deleted = 0 
		
--select dse_id , dse_mod_id , des_table , *
--			from ctl_documentsections with(nolock)
--			where dse_doc_id = 'INSTANZA_ME_INFO_AGGIUNTIVE_84707' and dse_id <> 'TESTATA'
--			order by des_order
--select * from Document_MicroLotti_Dettagli where idheader = 84708
--	--select * from ctl_doc_value where idheader = 84708

-- select AddInfo_Att_SOA from Document_MicroLotti_Dettagli where idheader = 84708 and Tipodoc='INFO_ADD_45452000_0_MOD_Modello_84707 ' 

 
	declare @Modello varchar(1000)
	declare @dse_id varchar(1000)
	declare @des_table  varchar(500)

	declare @Ma_dzt_name  varchar(500)
	declare @ma_descML  nvarchar(max)
	declare @dzt_type  varchar(500)
	declare @dzt_dm_id  varchar(500)
	declare @Des_TableFilter varchar(500)
	declare @SQL nvarchar(max)
	declare @Desc nvarchar(max)
	declare @ClasseIScriz varchar(max)
	declare @item varchar(100) 

	declare @crlf nvarchar(10)

	set @crlf = '
'


	create table #T ( Descr nvarchar(max) );
	

	declare @HTML nvarchar(max)
	set @HTML = ''
 

	-- recupera le classi di iscrizione selezionate sul documento istanza
	select @ClasseIScriz = value from CTL_DOC_Value with(nolock) where  idheader = @idDoc and dse_id = 'DISPLAY_ABILITAZIONI' and dzt_name = 'ClasseIscriz'

	


	-- cicla sulle classi quelle presenti sul documento  e che non hanno schede aggiuntive di ADD INFO
	DECLARE CurProg CURSOR STATIC READ_ONLY FORWARD_ONLY FOR 
		select items
			from dbo.split( @ClasseIScriz , '###' ) 
				left join ctl_doc_value v with(nolock) on idheader = @idDocAddInfo and 
														--dse_id = @dse_id and 
														dzt_name = 'ClasseIscriz' and
														'###' + items + '###' = value
			where v.IdRow is null
		
	OPEN CurProg


	FETCH NEXT FROM CurProg  INTO @item
	WHILE @@FETCH_STATUS = 0
	BEGIN

		set @HTML = @HTML + '<HR>'

		set @HTML = @HTML + '<table><tr><td>'
		select @HTML = @HTML + dbo.Get_Desc_ClasseIscriz(@item, 'I') 
		set @HTML = @HTML + '</td></tr></table>'

		FETCH NEXT FROM CurProg  INTO @item
 
	END
 
	CLOSE CurProg
	DEALLOCATE CurProg





	-- cicla sulle sezioni del modello
	DECLARE CurProg CURSOR STATIC READ_ONLY FORWARD_ONLY FOR 
		select dse_id , dse_mod_id , des_table , Des_TableFilter
			from ctl_documentsections with(nolock)
			where dse_doc_id = @TipoDocAddInfo and dse_id <> 'TESTATA'
			order by des_order

		
	OPEN CurProg


	FETCH NEXT FROM CurProg  INTO @dse_id , @Modello , @des_table , @Des_TableFilter
	WHILE @@FETCH_STATUS = 0
	BEGIN

		set @HTML = @HTML + '<HR>'

 
		-- per la parte statica recupera le descrizioni delle classi di iscrizione
		if @Modello = 'ISTANZA_ME_INFO_AGGIUNTIVE_CLASSE' 
		begin

			set @HTML = @HTML + '<table><tr><td>'
			select @HTML = @HTML + dbo.Get_Desc_ClasseIscriz(Value, 'I') from ctl_doc_value with(nolock) where idheader = @idDocAddInfo and dse_id = @dse_id and dzt_name = 'ClasseIscriz'
			set @HTML = @HTML + '</td></tr></table>'

		end
		else
		begin

			-- per le altre sezione recupera il modello 
			set @HTML = @HTML + '<table>'

			-- per ogni attributo del modello
			DECLARE CurProgMod CURSOR STATIC READ_ONLY FORWARD_ONLY FOR 
				select Ma_dzt_name , ma_descML , d.dzt_type , d.dzt_dm_id 
					from ctl_modelattributes with(nolock)
						inner join lib_dictionary d with(nolock) on dzt_name = ma_dzt_name
					where ma_mod_id = @Modello and  Ma_dzt_name <> 'colonnatecnica'
					order by ma_order

 
		
			OPEN CurProgMod


			FETCH NEXT FROM CurProgMod  INTO @Ma_dzt_name , @ma_descML , @dzt_type , @dzt_dm_id 
			WHILE @@FETCH_STATUS = 0
			BEGIN
 
				set @HTML = @HTML + @crlf + '<tr>'


				set @SQL = ' truncate table #T
						insert into #T ( descr ) 
							select dbo.GetDescsValuesFromDztDom( ''' + @Ma_dzt_name + ''' , ' + @Ma_dzt_name + ',''I'' ) from ' +@des_table + ' where idheader = '+ cast( @idDocAddInfo as varchar(20)) + ' and ' + @Des_TableFilter
				exec (@SQL)
				select @Desc = descr from #T

				set @HTML = @HTML + @crlf + '<td>' + @ma_descML + '</td>' 
				set @HTML = @HTML + @crlf + '<td>' + @Desc + '</td>' 
				set @HTML = @HTML + @crlf + '</tr>'


 
				FETCH NEXT FROM CurProgMod  INTO @Ma_dzt_name , @ma_descML , @dzt_type , @dzt_dm_id 
 
			END
 
			CLOSE CurProgMod
			DEALLOCATE CurProgMod

			set @HTML = @HTML + '</table>'



		end


 
		FETCH NEXT FROM CurProg  INTO  @dse_id , @Modello , @des_table , @Des_TableFilter
 
	END
 
	CLOSE CurProg
	DEALLOCATE CurProg
 
	drop table #t

	--print @HTML
	set @HtmlOut = @HTML
 
 end

-- select  dbo.GetDescsValuesFromDztDom( 'AddInfo_Att_SOA' , AddInfo_Att_SOA,'I' ) from Document_MicroLotti_Dettagli where idheader = 84708 and Tipodoc='INFO_ADD_45452000_0_MOD_Modello_84707 ' 
GO
