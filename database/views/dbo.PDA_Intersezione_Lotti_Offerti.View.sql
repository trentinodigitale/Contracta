USE [AFLink_TND]
GO
/****** Object:  View [dbo].[PDA_Intersezione_Lotti_Offerti]    Script Date: 5/16/2024 2:45:58 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE  view [dbo].[PDA_Intersezione_Lotti_Offerti] as 

				select t1.idrow as idRowOfferta ,  t2.* , o.aziRagioneSociale , o.ProtocolloOfferta
					from PDA_Intersezione_Lotti_Offerti_sub t1 
						inner join PDA_Intersezione_Lotti_Offerti_sub t2 on t1.IdRow <> t2.IdRow and t1.NumeroLotto = t2.NumeroLotto and t1.idPda = t2.idPda and t1.CodiceFiscale  = t2.CodiceFiscale  and  not  ( t1.tiporiferimento = 'SUBAPPALTO' and t2.tiporiferimento = 'SUBAPPALTO' )
						inner join Document_PDA_OFFERTE o on o.idrow = t2.idrow
					where  t2.statopda in ( '2' , '22' , '8' , '9' , '222' ,'1')
					
						--t1.idPda = @idPda and t1.idAzi = @idAzi
						--	 and t2.idPda = @idPda and t2.idAzi = @idAzi
				
						--	and t1.IdRow = @idRow
GO
