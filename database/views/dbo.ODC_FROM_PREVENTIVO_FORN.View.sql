USE [AFLink_TND]
GO
/****** Object:  View [dbo].[ODC_FROM_PREVENTIVO_FORN]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO
---------------------------------------------------------------
--Prelevato il campo TipoOrdine direttamente dalla convenzione
---------------------------------------------------------------

CREATE view [dbo].[ODC_FROM_PREVENTIVO_FORN] as
SELECT   b.id as ID_FROM 
                    , p.strutturaAziendale as Plant 
					, cast( v.Value as int ) as Id_Convenzione
					, c.NumOrd as NumeroConvenzione
					, p.Destinatario_Azi as IdAziDest
					, 0 as IVA
--					, 'B' as TipoOrdine
					, c.TipoOrdine
					,  v1.Value as ODC_PEG
					, p.Body as RDA_Object
					,  v2.Value as RefOrd
					,  v3.Value as RefOrdInd
					,  v4.Value as RefOrdTel
					,  v5.Value as RefOrdEMail
					, p.id      as Id_Preventivo 

FROM    CTL_DOC b
	inner join CTL_DOC p on b.LinkedDoc = p.id
	inner join CTL_DOC_Value v on v.IdHeader = p.id and v.DZT_Name = 'Id_Convenzione'
	inner join CTL_DOC_Value v1 on v1.IdHeader = p.id and v1.DZT_Name = 'ODC_PEG'
	inner join CTL_DOC_Value v2 on v2.IdHeader = p.id and v2.DZT_Name = 'RefOrd'
	inner join CTL_DOC_Value v3 on v3.IdHeader = p.id and v3.DZT_Name = 'RefOrdInd'
	inner join CTL_DOC_Value v4 on v4.IdHeader = p.id and v4.DZT_Name = 'RefOrdTel'
	inner join CTL_DOC_Value v5 on v5.IdHeader = p.id and v5.DZT_Name = 'RefOrdEMail'
	inner join Document_Convenzione c on v.Value = c.id


GO
