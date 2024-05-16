USE [AFLink_TND]
GO
/****** Object:  View [dbo].[DWH_Get_Lotti]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE view [dbo].[DWH_Get_Lotti]
as

	select 
		distinct
			DC.numord as [Numero Convenzione],
			a.NumeroLotto as [Numero Lotto],
			a.Descrizione as [Descrizione Lotto],

			isnull([Estensione Lotto],0) as [Estensione Lotto],

			isnull([Decurtazione Lotto],0) as [Decurtazione Lotto],

			DC.CIG_MADRE as [CIG],

			a.importo as [Totale Lotto],
			a.impegnato as [Totale ordinativi],
			cast(a.residuo as float) as [Residuo lotto],
			a.Tot_Altri_Ordinativi_Lotto as [Tot Altri Ordinativi su Lotto]

			

		from CONVENZIONE_CAPIENZA_LOTTI_VIEW  a
		    inner join Document_Convenzione DC with(nolock) on DC.id=a.idheader		
			inner join ctl_doc c with(nolock) on c.id=a.idheader
			LEFT OUTER JOIN (

					select d.linkeddoc ,l.numerolotto 
							, sum( case when d.tipodoc = 'CONVENZIONE_VALORE' then  ISNULL(  l.Estensione , 0 )  else 0 end ) as [Estensione Lotto] 
							, sum( case when d.tipodoc = 'CONVENZIONE_DECURTAZIONE' then  ISNULL(  l.Estensione , 0 )  else 0 end ) as [Decurtazione Lotto]
						from ctl_doc d  with(nolock) 
							inner join Document_Convenzione_Lotti l  with(nolock) on d.id = idheader 
						where d.tipodoc in ( 'CONVENZIONE_VALORE' , 'CONVENZIONE_DECURTAZIONE' ) 
							and d.statodoc = 'Sended' and d.deleted = 0
							GROUP BY d.linkeddoc ,l.numerolotto
						) AS S on S.linkeddoc = DC.id and a.numerolotto = S.numerolotto


		where c.tipodoc = 'CONVENZIONE'
			and c.deleted = 0 and dc.Deleted = 0
			and c.StatoFunzionale <> 'InLavorazione'



GO
