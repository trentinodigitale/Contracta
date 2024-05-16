USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[INIT_DOMINIO_AttributoCriterio]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE proc [dbo].[INIT_DOMINIO_AttributoCriterio] ( @IdDoc as int)
as
begin
    
    --declare @IdDoc as int
    --set @IdDoc=81872

    declare @Titolo as nvarchar(500)

	if @IdDoc > 0 
	begin

		--recupero titolo del modello
		select  @Titolo=Titolo from ctl_doc where id=@IdDoc

		--print @Titolo
		--select * from DOMINIO_AttributoCriterio where TipoBando like @Titolo + '%'
		--truncate table DOMINIO_AttributoCriterio
    
		--cancello le entrate relative al modello
		delete DOMINIO_AttributoCriterio where TipoBando like @Titolo + '%'

	end
	else
	begin
		truncate table DOMINIO_AttributoCriterio
	end

    --reinserisco le entrate relative al modello
	insert into DOMINIO_AttributoCriterio ( 
		DMV_DM_ID  ,DMV_Cod , DMV_Father , DMV_Level ,DMV_DescML , DMV_Image ,DMV_Sort ,DMV_CodExt, DZT_NAME , TipoBando , DZT_Type, Attributo, DZT_Format 
		)
		select DMV_DM_ID  ,DMV_Cod , DMV_Father , DMV_Level ,DMV_DescML , DMV_Image ,DMV_Sort ,DMV_CodExt, DZT_NAME , TipoBando , DZT_Type, Attributo, DZT_Format 
				from (
					select 
						9 as DMV_DM_ID  ,
						Titolo + '.' + d.DZT_Name as  DMV_Cod ,
						'' as DMV_Father ,
						0 as DMV_Level ,
						v1.Value as DMV_DescML ,
						'' as DMV_Image ,
						0 as DMV_Sort ,
						'' as DMV_CodExt,
						v2.DZT_NAME , 
						Titolo + a.Tipo as TipoBando ,
						DZT_Type,
						d.DZT_Name as Attributo,
						d.DZT_Format
						from ctl_doc M with(nolock)
						inner join ctl_doc_value v1 with(nolock) on id = v1.idheader and v1.dzt_name = 'Descrizione' and v1.DSE_ID = 'MODELLI' 
						inner join ctl_doc_value v2 with(nolock) on id = v2.idheader and /*v2.dzt_name = 'MOD_OffertaTec' and*/ v2.DSE_ID = 'MODELLI'  and v2.Value in ( 'scrittura' , 'obblig' , 'calc' ) and v1.Row = v2.Row
						inner join ctl_doc_value v3 with(nolock) on id = v3.idheader and v3.dzt_name = 'DZT_NAME' and v3.DSE_ID = 'MODELLI'  and v1.Row = v3.Row
						inner join LIB_Dictionary d with(nolock) on d.DZT_Name = v3.value 
						-- questa cross join sostituisce le 3 union che erano state fatte in precedenza. questa modifica decima il tempo complessivo della query precedente.
						cross join ( select '' as tipo union select '_MONOLOTTO' as Tipo union select '_COMPLEX' as Tipo ) as a 
					where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0 and ( M.id = @IdDoc or @IdDoc <= 0 )

				) as a 


	-- vecchia query lasciata solo a scopo documentativo

	--select  * from (
	--	select 
	--	  9 as DMV_DM_ID  ,
	--	  Titolo + '.' + d.DZT_Name as  DMV_Cod ,
	--	   '' as DMV_Father ,
	--	   0 as DMV_Level ,
	--	   v1.Value as DMV_DescML ,
	--	   '' as DMV_Image ,
	--	   0 as DMV_Sort ,
	--	  '' as DMV_CodExt,

	--		v2.DZT_NAME , 
	--		Titolo  as TipoBando ,
	--		DZT_Type,
	--		d.DZT_Name as Attributo,
	--		d.DZT_Format
	--	 from ctl_doc with(nolock)
	--		inner join ctl_doc_value v1 with(nolock) on id = v1.idheader and v1.dzt_name = 'Descrizione' and v1.DSE_ID = 'MODELLI' 
	--		inner join ctl_doc_value v2 with(nolock) on id = v2.idheader and /*v2.dzt_name = 'MOD_OffertaTec' and*/ v2.DSE_ID = 'MODELLI'  and v2.Value in ( 'scrittura' , 'obblig' , 'calc' ) and v1.Row = v2.Row
	--		inner join ctl_doc_value v3 with(nolock) on id = v3.idheader and v3.dzt_name = 'DZT_NAME' and v3.DSE_ID = 'MODELLI'  and v1.Row = v3.Row
	--		inner join LIB_Dictionary d with(nolock) on d.DZT_Name = v3.value 
	--	where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0

	--union all

	--	select 
	--	  9 as DMV_DM_ID  ,
	--	  Titolo + '.' + d.DZT_Name as  DMV_Cod ,
	--	   '' as DMV_Father ,
	--	   0 as DMV_Level ,
	--	   v1.Value as DMV_DescML ,
	--	   '' as DMV_Image ,
	--	   0 as DMV_Sort ,
	--	  '' as DMV_CodExt,

	--		v2.DZT_NAME , 
	--		Titolo + '_COMPLEX'  as TipoBando ,
	--		DZT_Type,
	--		d.DZT_Name as Attributo,
	--		d.DZT_Format
	--	 from ctl_doc with(nolock) 
	--		inner join ctl_doc_value v1 with(nolock) on id = v1.idheader and v1.dzt_name = 'Descrizione' and v1.DSE_ID = 'MODELLI' 
	--		inner join ctl_doc_value v2 with(nolock) on id = v2.idheader and /*v2.dzt_name = 'MOD_OffertaTec' and*/ v2.DSE_ID = 'MODELLI'  and v2.Value in ( 'scrittura' , 'obblig' , 'calc' ) and v1.Row = v2.Row
	--		inner join ctl_doc_value v3 with(nolock) on id = v3.idheader and v3.dzt_name = 'DZT_NAME' and v3.DSE_ID = 'MODELLI'  and v1.Row = v3.Row
	--		inner join LIB_Dictionary d with(nolock) on d.DZT_Name = v3.value 
	--	where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0

	--union all

	--	select 
	--	  9 as DMV_DM_ID  ,
	--	  Titolo + '.' + d.DZT_Name as  DMV_Cod ,
	--	   '' as DMV_Father ,
	--	   0 as DMV_Level ,
	--	   v1.Value as DMV_DescML ,
	--	   '' as DMV_Image ,
	--	   0 as DMV_Sort ,
	--	  '' as DMV_CodExt,

	--		v2.DZT_NAME , 
	--		Titolo + '_MONOLOTTO'  as TipoBando ,
	--		DZT_Type,
	--		d.DZT_Name as Attributo,
	--		d.DZT_Format
	--	 from ctl_doc with(nolock) 
	--		inner join ctl_doc_value v1 with(nolock) on id = v1.idheader and v1.dzt_name = 'Descrizione' and v1.DSE_ID = 'MODELLI' 
	--		inner join ctl_doc_value v2 with(nolock) on id = v2.idheader and /*v2.dzt_name = 'MOD_OffertaTec' and*/ v2.DSE_ID = 'MODELLI'  and v2.Value in ( 'scrittura' , 'obblig' , 'calc' ) and v1.Row = v2.Row
	--		inner join ctl_doc_value v3 with(nolock) on id = v3.idheader and v3.dzt_name = 'DZT_NAME' and v3.DSE_ID = 'MODELLI'  and v1.Row = v3.Row
	--		inner join LIB_Dictionary d with(nolock) on d.DZT_Name = v3.value 
	--	where tipodoc = 'CONFIG_MODELLI_LOTTI' and deleted = 0

	--) as a 
	--where 1 = 1 
	--order by DMV_DescML

end



GO
