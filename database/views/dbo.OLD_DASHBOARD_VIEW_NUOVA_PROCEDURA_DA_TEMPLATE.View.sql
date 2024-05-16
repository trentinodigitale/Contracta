USE [AFLink_TND]
GO
/****** Object:  View [dbo].[OLD_DASHBOARD_VIEW_NUOVA_PROCEDURA_DA_TEMPLATE]    Script Date: 5/16/2024 2:46:00 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[OLD_DASHBOARD_VIEW_NUOVA_PROCEDURA_DA_TEMPLATE]
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
         , dbo.HTML_Encode(Cdv1.[Value]) AS DescrizioneEstesa
         , Cdv2.[Value] AS Versione
         , Cdv3.[Value] AS Note
         , dbo.GetDescTipoProcedura(Cd.Tipodoc, Db.TipoProceduraCaratteristica, Db.ProceduraGara, Db.TipoBandoGara) AS DescTipoProcedura -- GetDescTipoProcedura è una FUNCTION
         , ISNULL(Db.TipoProceduraCaratteristica,'') AS TipoProceduraCaratteristica
         , ISNULL(Db.TipoSceltaContraente,'') AS TipoSceltaContraente
		     , Cd.IdPfu AS [Owner]
         , Cd.TipoDoc AS OPEN_DOC_NAME
         , Cd.[Data]

  FROM CTL_DOC Cd WITH(NOLOCK)
			--INNER JOIN ProfiliUtente PA WITH(NOLOCK) ON  SUBSTRING(PA.pfuFunzionalita,543,1)=1 
			INNER JOIN ProfiliUtente compilatore  WITH(NOLOCK) ON  compilatore.idpfu = cd.idpfu
			INNER JOIN ProfiliUtente PA WITH(NOLOCK) ON  pa.pfuvenditore = 0 
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
			cross JOIN ( select top 1 MP.mpIdAziMaster  from MarketPlace MP WITH (NOLOCK) ) as mp
  
  WHERE Cd.TipoDoc = 'TEMPLATE_GARA'
        AND Cd.Deleted = 0
		and 
			(
				-- il compilatore è un utente dell'azienda master
				compilatore.pfuidazi  = MP.mpIdAziMaster  
				or
				-- il compilatore è un utente della mia azienda
				compilatore.pfuidazi  = PA.pfuidazi
			)

		and cd.statofunzionale = 'Pubblicato'

        --AND (Cd.IdPfu = (SELECT mpIdAziMaster FROM MarketPlace WITH (NOLOCK)) OR Cd.IdPfu = PA.IdPfu)


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
--    INNER JOIN ProfiliUtente PA WITH(NOLOCK) ON SUBSTRING(PA.pfuFunzionalita,541,1)=1
--                                                AND SUBSTRING(PA.pfuFunzionalita,543,1)=0
--		INNER JOIN Document_Bando Db WITH(NOLOCK) ON Cd.Id = Db.IdHeader
--		INNER JOIN CTL_DOC_Value Cdv1 WITH(NOLOCK) ON Cd.Id = Cdv1.IdHeader
--														                      AND Cdv1.DSE_ID = 'INFO_TEMPLATE'
--														                      AND Cdv1.DZT_Name = 'DescrizioneEstesa'
--		INNER JOIN CTL_DOC_Value Cdv2 WITH(NOLOCK) ON Cd.Id = Cdv2.IdHeader
--														                      AND Cdv2.DSE_ID = 'INFO_TEMPLATE'
--														                      AND Cdv2.DZT_Name = 'Versione'
--		LEFT JOIN CTL_DOC_Value Cdv3 WITH(NOLOCK) ON Cd.Id = Cdv3.IdHeader
--															                   AND Cdv3.DSE_ID = 'INFO_TEMPLATE'
--															                   AND Cdv3.DZT_Name = 'Note'
--		LEFT JOIN CTL_DOC N WITH(NOLOCK) ON N.tipodoc = Cd.TipoDoc
--                                        AND N.statofunzionale IN ( 'InLavorazione' )
--                                        AND N.PrevDoc = Cd.id
--                                        AND N.deleted = 0
--                                        AND ISNULL(n.LinkedDoc,0) = 0
--  WHERE Cd.TipoDoc = 'TEMPLATE_GARA'
--        AND Cd.Deleted = 0
--		    AND	Cd.StatoFunzionale ='Pubblicato' --solo gli utenti con il profilo GestoreTemplateGara
--        --AND (Cd.IdPfu = (SELECT mpIdAziMaster FROM MarketPlace WITH (NOLOCK)) OR Cd.IdPfu = PA.IdPfu)

--GO


GO
