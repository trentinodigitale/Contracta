USE [AFLink_TND]
GO
/****** Object:  View [dbo].[VIEW_OE_DA_CONTROLLARE_DOCUMENT]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE VIEW [dbo].[VIEW_OE_DA_CONTROLLARE_DOCUMENT] AS
select
	C.*,
	CV.Value as numIscrittiME,
	CV1.Value as Tipo_Estrazione,
	CV2.Value as Perc_Soggetti,
	CV3.Value as Num_estrazione_mista,
	Numero_OE_Estratti,
	ISNULL(Numero_Controlli_Effettuati,0) as Numero_Controlli_Effettuati,
	
	case when ISNULL(Numero_Controlli_Effettuati,0)=0 then 0
		 else Numero_Controlli_Effettuati/convert(decimal(10,2), Numero_OE_Estratti) * 100
  	end	 as Percentuale	

	from CTL_DOC C with(nolock)
		inner join CTL_DOC_Value CV with(nolock) on CV.IdHeader=C.id and CV.DSE_ID='DOCUMENT' and CV.DZT_Name='numIscrittiME' and CV.Row=0 
		inner join CTL_DOC_Value CV1 with(nolock) on CV1.IdHeader=C.id and CV1.DSE_ID='DOCUMENT' and CV1.DZT_Name='Tipo_Estrazione' and CV1.Row=0 
		inner join CTL_DOC_Value CV2 with(nolock) on CV2.IdHeader=C.id and CV2.DSE_ID='DOCUMENT' and CV2.DZT_Name='Perc_Soggetti' and CV2.Row=0 
		inner join CTL_DOC_Value CV3 with(nolock) on CV2.IdHeader=C.id and CV3.DSE_ID='DOCUMENT' and CV3.DZT_Name='Num_estrazione_mista' and CV3.Row=0 
		inner join ( select max(LinkedDoc) as LinkedDoc,COUNT(*) as Numero_OE_Estratti from CTL_DOC where TipoDoc='CONTROLLI_OE' and Deleted=0 group by LinkedDoc ) W on W.LinkedDoc=C.id
		left join ( select max(LinkedDoc) as LinkedDoc,COUNT(*) as Numero_Controlli_Effettuati from CTL_DOC where TipoDoc='CONTROLLI_OE' and Deleted=0 and StatoFunzionale = 'Confermato' group by LinkedDoc ) K on K.LinkedDoc=C.id
		where C.TipoDoc='OE_DA_CONTROLLARE'
GO
