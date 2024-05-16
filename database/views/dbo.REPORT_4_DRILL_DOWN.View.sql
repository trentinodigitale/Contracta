USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_4_DRILL_DOWN]    Script Date: 5/16/2024 2:46:02 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE VIEW [dbo].[REPORT_4_DRILL_DOWN] AS
SELECT     

      1 as N_Bandi
     , case Rettifica 
            when 'si' then 1 
            else 0
       end as N_Rettifiche
     , case Annullamento 
            when 'si' then 1 
            else 0
       end as N_Annullamenti
     , case Ricorso 
            when 'si' then 1 
            else 0
       end as N_Ricorsi
     , case Deserta_MaiIndetta 
            when '1' then 1 
            --when '2' then 1 
            else 0
       end as N_Deserte
		,
			case 
				when REL_Type is null then '  Tradizionali' 
				else '  Telematiche' 
			end as TipoGara
			,descrizione 
			,  substring(protocollobando,1,4) as NumeroBando, substring(protocollobando,6,4) as AnnoBando, a.IdRow, a.IdProgetto, 
           a.Lotto, a.ScadenzaIstanza, a.ScadenzaOfferta, 
           case 
                when cast(isnull(a.Importo,0) as varchar) = '0' or b.NumLotti in (0, 1)  then '-' 
                else cast(a.Importo as varchar) 
           end as Importo, 
           b.IdProgetto AS Expr1, b.StatoProgetto, b.DataInvio, b.Protocol, b.UserDirigente, b.Peg, b.Importo AS ImportoProcedura, b.Tipologia, 
           b.TipoProcedura, b.CriterioAggiudicazione, b.NumLotti, b.Oggetto, b.Versione, b.NumDetermina, b.DataDetermina, 
                      b.ProtocolloBando, b.ReferenteUffAppalti, b.UserProvveditore, b.AllegatoDpe, b.NoteProgetto, b.DataCompilazione, b.Storico, b.DataOperazione, 
                      b.[User], b.Deleted, b.LinkModified, b.Pratica,substring(programma,6,len(programma)) as programma,
                      a.notelotto,a.dataconsegnaverbale,a.rettifica,a.annullamento,a.ricorso,a.Deserta_MaiIndetta,a.DataTrasmContratto,a.DataAvvioIstr,a.DurataIstruttoria,a.NoteAggiudicazione,
					  b.NumDeterminaAggiudica,b.DataDeterminaAggiudica, dbo.GetDittaAggiudicataria(a.IdRow,a.annullamento,a.Deserta_MaiIndetta) as DittaAggiudicataria

FROM         dbo.Document_Progetti_Lotti AS a INNER JOIN
                      dbo.Document_Progetti AS b ON a.IdProgetto = b.IdProgetto
						cross join peg
						left outer join CTL_Relations on REL_Type = 'GARE_TELEMATICHE' and TipoProcedura = REL_ValueInput
						cross join  Document_Report_Periodi 
 
where TipoAnalisi = 'REPORT_4' 
   and Document_Report_Periodi.Used = 1 
   and Document_Report_Periodi.deleted = 0
   and convert(char(10), DataI, 121) <= convert(char(10), DataInvio, 121) 
   and convert(char(10), DataInvio, 121) <= convert(char(10), DataF, 121)
   and propro=substring(peg, charindex('#~#', peg) + 3, 10)

GO
