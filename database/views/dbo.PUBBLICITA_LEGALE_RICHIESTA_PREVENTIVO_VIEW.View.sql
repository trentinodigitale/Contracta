USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PUBBLICITA_LEGALE_RICHIESTA_PREVENTIVO_VIEW]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO







CREATE VIEW [dbo].[PUBBLICITA_LEGALE_RICHIESTA_PREVENTIVO_VIEW] AS


	select 
			C.*,
			CV.Value as Not_Editable,
			D.SIGN_ATTACH,
			D.NOTE,
			cds.F1_SIGN_ATTACH,cds.F1_SIGN_HASH,cds.F1_SIGN_LOCK,
			cds.F2_SIGN_ATTACH,cds.F2_SIGN_HASH,cds.F2_SIGN_LOCK
		from Document_RicPrevPubblic  C WITH (NOLOCK)  
			left join CTL_DOC_Value CV WITH (NOLOCK)   on CV.IdHeader=C.IdHeader and CV.DSE_ID='NOT_EDITABLE' and CV.DZT_Name='Not_Editable'
			LEFT JOIN  CTL_DOC D WITH (NOLOCK)  ON C.IDHEADER=D.ID
			left join  CTL_DOC_SIGN cds with(nolock) on cds.idHeader=d.id
GO
