USE [AFLink_TND]
GO
/****** Object:  View [dbo].[REPORT_6_DRILL_DOWN]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE View [dbo].[REPORT_6_DRILL_DOWN] as 

select a.* , b.* , c.Peg , c.UserDirigente , c.ReferenteUffAppalti from 
(
		select Descrizione 
			 , Direzione + ' - ' + Dirigente as DirezioneRep
			 ,  (N_Bandi)                  as N_Bandi
			 ,  (N_Aperta)                 as N_Aperta
			 ,  (N_Asta_Tel)               as N_Asta_Tel
			 ,  (N_Ristretta)              as N_Ristretta
			 ,  (N_Tel_Ap)                 as N_Tel_Ap
			 ,  (N_Tel_EC)                 as N_Tel_EC
			 ,  (N_Tel_Ris)                as N_Tel_Ris
			 ,  (N_Gara_Ec)                as N_Gara_Ec
			 ,  (N_Ric_Prev)               as N_Ric_Prev
			 ,  (N_Proc_Neg)               as N_Proc_Neg
			 ,  (N_Tel_Proc_Neg)           as N_Tel_Proc_Neg
			, IdProgetto	as RepIdProgetto
			,ProtocolloBando
		  from REPORT_6_Dati_Base d
			 , Document_Report_Periodi 
		 where TipoAnalisi = 'REPORT_6' 
		   and Used = 1 
		   and deleted = 0
		   and convert(char(10), DataI, 121) <= Periodo 
		   and Periodo <= convert(char(10), DataF, 121)

		union all

		select v.Descrizione
			 , v.DirezioneRep
			 ,  (N_Bandi)                  as N_Bandi
			 ,  (N_Aperta)                 as N_Aperta
			 ,  (N_Asta_Tel)               as N_Asta_Tel
			 ,  (N_Ristretta)              as N_Ristretta
			 ,  (N_Tel_Ap)                 as N_Tel_Ap
			 ,  (N_Tel_EC)                 as N_Tel_EC
			 ,  (N_Tel_Ris)                as N_Tel_Ris
			 ,  (N_Gara_Ec)                as N_Gara_Ec
			 ,  (N_Ric_Prev)               as N_Ric_Prev
			 ,  (N_Proc_Neg)               as N_Proc_Neg
			 ,  (N_Tel_Proc_Neg)           as N_Tel_Proc_Neg
			,IdProgetto as RepIdProgetto
			,ProtocolloBando
		  from (
				 select Descrizione 
					  , 'ZZZZZZTotale'	                    as DirezioneRep
					  , isnull(N_Bandi, 0)                  as N_Bandi
					  , isnull(N_Aperta, 0)                 as N_Aperta
					  , isnull(N_Asta_Tel, 0)               as N_Asta_Tel
					  , isnull(N_Ristretta, 0)              as N_Ristretta
					  , isnull(N_Tel_Ap, 0)                 as N_Tel_Ap
					  , isnull(N_Tel_EC, 0)                 as N_Tel_EC
					  , isnull(N_Tel_Ris, 0)                as N_Tel_Ris
					  , isnull(N_Gara_Ec, 0)                as N_Gara_Ec
					  , isnull(N_Ric_Prev, 0)               as N_Ric_Prev
					  , isnull(N_Proc_Neg, 0)               as N_Proc_Neg
					  , isnull(N_Tel_Proc_Neg, 0)           as N_Tel_Proc_Neg
					 ,IdProgetto
					 ,ProtocolloBando
				   from REPORT_6_Dati_Base d
					  , Document_Report_Periodi  
				  where TipoAnalisi = 'REPORT_6' 
					and Used = 1 
					and deleted = 0
					and convert(char(10), DataI, 121) <= Periodo 
					and Periodo <= convert(char(10), DataF, 121)
			   ) v

) as a
inner join dbo.Document_Progetti_Lotti b on  RepIdProgetto = b.IdProgetto
inner join dbo.Document_Progetti c on  c.IdProgetto = b.IdProgetto

GO
