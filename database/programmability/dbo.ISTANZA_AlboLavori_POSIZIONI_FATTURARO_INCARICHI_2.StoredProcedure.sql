USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[ISTANZA_AlboLavori_POSIZIONI_FATTURARO_INCARICHI_2]    Script Date: 5/16/2024 2:38:54 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO



CREATE proc [dbo].[ISTANZA_AlboLavori_POSIZIONI_FATTURARO_INCARICHI_2]( @idDoc as int  ) 
as

--valorizzo la tabella nella ctl_doc_Value "POSIZIONI_FATTURARO_INCARICHI" a partire dal campo ATTIVITAPROFESSIONALEISTANZA




declare @id int
declare @categorie nvarchar(max)
set @categorie=''
set @id=@idDoc

select * into #temp 
	from CTL_DOC_Value with(nolock)
		where IdHeader=@id and DSE_ID='POSIZIONI_FATTURARO_INCARICHI'

delete from CTL_DOC_Value where IdHeader=@id and DSE_ID='POSIZIONI_FATTURARO_INCARICHI'

select @categorie=value 
	from CTL_DOC_Value CV with(nolock)
		where CV.IdHeader=@id and CV.DSE_ID='DISPLAY_CLASSI' and CV.DZT_Name in ('ClassificazioneSOA') 


insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
	select @id,'POSIZIONI_FATTURARO_INCARICHI',ROW_NUMBER() OVER(order BY DMV_Cod ASC) -1 as Row,'ClassificazioneSOA','###' + DMV_Cod + '###'
		from dbo.Split(@categorie,'###')
			inner join GerarchicoSOA_ML_LNG on ML_LNG = 'I' and DMV_Cod=items and DMV_DescML like '%NO SOA%'

insert into CTL_DOC_Value (IdHeader,DSE_ID,Row,DZT_Name,Value)
	select @id,'POSIZIONI_FATTURARO_INCARICHI',CV.Row,'Importo',T2.Value
		from CTL_DOC_Value CV
			inner join #temp T on T.IdHeader=CV.IdHeader and CV.DSE_ID=T.DSE_ID and T.DZT_Name='ClassificazioneSOA' and T.Value=CV.Value
			inner join #temp T2 on T2.IdHeader=CV.IdHeader and CV.DSE_ID=T2.DSE_ID and T2.DZT_Name='Importo' and T.Row=T2.Row
				where CV.IdHeader=@id and CV.DSE_ID='POSIZIONI_FATTURARO_INCARICHI' and CV.DZT_Name='ClassificazioneSOA'






GO
