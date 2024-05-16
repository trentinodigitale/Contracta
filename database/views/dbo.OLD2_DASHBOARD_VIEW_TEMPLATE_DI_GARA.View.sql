USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD2_DASHBOARD_VIEW_TEMPLATE_DI_GARA]    Script Date: 5/16/2024 2:46:01 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD2_DASHBOARD_VIEW_TEMPLATE_DI_GARA]
AS
  SELECT Cd.Id
         , PA.IdPfu AS Idpfu
         , Cd.Protocollo
         , Cd.DataInvio
         , Cd.StatoFunzionale
         , Db.TipoAppaltoGara
         , Db.ProceduraGara
         , Db.TipoBandoGara
         , Db.Divisione_lotti
         , Db.CriterioAggiudicazioneGara
         , Db.CriterioFormulazioneOfferte
         , Db.Conformita
         --, Cdv1.[Value] AS DescrizioneEstesa
         , CASE WHEN N.id IS NULL THEN Cdv1.[Value] ELSE '<b>( In Modifica )</b> ' + dbo.HTML_Encode(Cdv1.[Value]) END AS DescrizioneEstesa
         , Cdv2.[Value] AS Versione
         , Cdv3.[Value] AS Note
         , dbo.GetDescTipoProcedura(Cd.Tipodoc, Db.TipoProceduraCaratteristica, Db.ProceduraGara, Db.TipoBandoGara) AS DescTipoProcedura -- GetDescTipoProcedura è una FUNCTION
         , ISNULL(Db.TipoProceduraCaratteristica,'') AS TipoProceduraCaratteristica
         , ISNULL(Db.TipoSceltaContraente,'') AS TipoSceltaContraente
		     , Cd.IdPfu AS [Owner]
         , Cd.TipoDoc AS OPEN_DOC_NAME
         , Cd.[Data]

  FROM CTL_DOC Cd WITH(NOLOCK)
			
			--INNER JOIN
			--		 ProfiliUtente PA WITH(NOLOCK) ON  SUBSTRING(PA.pfuFunzionalita,543,1)=1 
			cross JOIN ProfiliUtente PA WITH(NOLOCK) 
				--	ProfiliUtenteAttrib PA with (nolock) on PA.dztNome  = 'Profilo' and PA.attValue  = 'GestoreTemplateGara'
					

			--left join
			--		ProfiliUtenteAttrib PA1 with (nolock) on PA.dztNome  = 'Profilo' and PA.attValue  = 'ConsultazioneTemplateGara'
			INNER JOIN Document_Bando Db WITH (NOLOCK) ON Cd.Id = Db.IdHeader
			INNER JOIN CTL_DOC_Value Cdv1 WITH (NOLOCK) ON Cd.Id = Cdv1.IdHeader
															                    AND Cdv1.DSE_ID = 'INFO_TEMPLATE'
															                    AND Cdv1.DZT_Name = 'DescrizioneEstesa'
			INNER JOIN CTL_DOC_Value Cdv2 WITH (NOLOCK) ON Cd.Id = Cdv2.IdHeader
															                    AND Cdv2.DSE_ID = 'INFO_TEMPLATE'
															                    AND Cdv2.DZT_Name = 'Versione'
			LEFT JOIN CTL_DOC_Value Cdv3 WITH (NOLOCK) ON Cd.Id = Cdv3.IdHeader
															                   AND Cdv3.DSE_ID = 'INFO_TEMPLATE'
															                   AND Cdv3.DZT_Name = 'Note'
			LEFT JOIN CTL_DOC N WITH (NOLOCK) ON N.tipodoc = Cd.TipoDoc
                                        AND N.statofunzionale IN ( 'InLavorazione'  )
                                        AND N.PrevDoc = Cd.id
                                        AND N.deleted = 0
                                        AND ISNULL(n.LinkedDoc,0) = 0

  WHERE Cd.TipoDoc = 'TEMPLATE_GARA'
        AND Cd.Deleted = 0
		and
		(
			SUBSTRING(PA.pfuFunzionalita,543,1)=1 
			or
			Cd.StatoFunzionale ='Pubblicato'
		)


		    --AND 
		    --	(	
		    --		possono vedere tutti
		    --		Cd.StatoFunzionale ='Pubblicato' 
		    --		or
		    --		solo gli utenti con il profilo GestoreTemplateGara
		    --		( Cd.StatoFunzionale ='InLavorazione' and PA.IdUsAttr is not null )
		    --	)


--  UNION ALL

       
--	SELECT Cd.Id
--         , PA.IdPfu AS Idpfu
--         , Cd.Protocollo
--         , Cd.DataInvio
--         , Cd.StatoFunzionale
--         , Db.TipoAppaltoGara
--         , Db.ProceduraGara
--         , Db.TipoBandoGara
--         , Db.Divisione_lotti
--         , Db.CriterioAggiudicazioneGara
--         , Db.CriterioFormulazioneOfferte
--         , Db.Conformita
--         --, Cdv1.[Value] AS DescrizioneEstesa
--		     , CASE WHEN N.id IS NULL THEN Cdv1.[Value] ELSE '<b>( In Modifica )</b> ' + dbo.HTML_Encode(Cdv1.[Value]) END AS DescrizioneEstesa
--         , Cdv2.[Value] AS Versione
--         , Cdv3.[Value] AS Note
--         , dbo.GetDescTipoProcedura (Cd.Tipodoc, Db.TipoProceduraCaratteristica, Db.ProceduraGara, Db.TipoBandoGara) AS DescTipoProcedura -- GetDescTipoProcedura è una FUNCTION
--         , ISNULL(Db.TipoProceduraCaratteristica,'') AS TipoProceduraCaratteristica
--         , ISNULL(Db.TipoSceltaContraente,'') AS TipoSceltaContraente
--  		   , Cd.IdPfu AS [Owner]
--         , Cd.TipoDoc AS OPEN_DOC_NAME
--         , Cd.[Data]

--FROM CTL_DOC Cd WITH (NOLOCK)
--		INNER JOIN
--				--ProfiliUtenteAttrib PA with (nolock) on PA.dztNome  = 'Profilo' and PA.attValue  = 'ConsultazioneTemplateGara'
--				ProfiliUtente PA WITH(NOLOCK) ON SUBSTRING(PA.pfuFunzionalita,541,1)=1 and SUBSTRING(PA.pfuFunzionalita,543,1)=0
--		INNER JOIN Document_Bando Db WITH(NOLOCK) ON Cd.Id = Db.IdHeader
--		INNER JOIN CTL_DOC_Value Cdv1 WITH(NOLOCK) ON Cd.Id = Cdv1.IdHeader
--														AND Cdv1.DSE_ID = 'INFO_TEMPLATE'
--														AND Cdv1.DZT_Name = 'DescrizioneEstesa'
--		INNER JOIN CTL_DOC_Value Cdv2 WITH(NOLOCK) ON Cd.Id = Cdv2.IdHeader
--														AND Cdv2.DSE_ID = 'INFO_TEMPLATE'
--														AND Cdv2.DZT_Name = 'Versione'
--		LEFT JOIN CTL_DOC_Value Cdv3 WITH(NOLOCK) ON Cd.Id = Cdv3.IdHeader
--															AND Cdv3.DSE_ID = 'INFO_TEMPLATE'
--															AND Cdv3.DZT_Name = 'Note'

--		LEFT JOIN CTL_DOC N WITH(NOLOCK) ON N.tipodoc = Cd.TipoDoc AND N.statofunzionale IN ( 'InLavorazione'  ) AND N.PrevDoc = Cd.id AND N.deleted = 0 AND ISNULL(n.LinkedDoc,0) = 0
--  WHERE 
--		Cd.TipoDoc = 'TEMPLATE_GARA'
--        AND Cd.Deleted = 0
--		    AND	Cd.StatoFunzionale ='Pubblicato'	--solo gli utenti con il profilo GestoreTemplateGara
	
GO
