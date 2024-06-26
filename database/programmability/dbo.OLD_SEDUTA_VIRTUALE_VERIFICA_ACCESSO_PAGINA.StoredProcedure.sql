USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_SEDUTA_VIRTUALE_VERIFICA_ACCESSO_PAGINA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO





CREATE PROCEDURE [dbo].[OLD_SEDUTA_VIRTUALE_VERIFICA_ACCESSO_PAGINA]
	( @idDoc int , @IdUser int ,@command as varchar(200) )
AS
BEGIN
	IF @command = 'INFO_AMM'
	BEGIN
		select sv.id ,u.idpfu , op.IdRow , u.pfuIdAzi
			   from CTL_DOC sv  WITH(NOLOCK)
					 inner join ctl_doc b WITH(NOLOCK) on b.id = sv.LinkedDoc
					 inner join Document_Bando BA WITH(NOLOCK) on BA.idHeader = b.Id
					 inner join ctl_doc p WITH(NOLOCK) on b.id = p.LinkedDoc and p.deleted = 0 and p.tipodoc = 'PDA_MICROLOTTI' 
					 inner join Document_Parametri_Sedute_Virtuali psv WITH(NOLOCK) on psv.deleted = 0 

					 inner join CTL_DOC_Destinatari d WITH(NOLOCK) on d.idheader = b.id and sv.Azienda = d.idazi
					 left join Document_PDA_OFFERTE op WITH(NOLOCK) on op.idheader = p.id and op.idAziPartecipante = sv.Azienda and d.idazi = op.idAziPartecipante
					 inner join profiliutente u WITH(NOLOCK) on u.pfuidazi = d.IdAzi and u.pfuDeleted = 0


		 where 
			   (
					 -- se la gara è ad invito ed il paramentro da visibiltà solo agli invitati
					(      
							BA.TipoBandoGara = '3' -- invito
							and 
							psv.Visibilita = 'invitati' 
							and 
							d.idrow is not null -- presenza negli invitati
					 )

					 -- altrimenti la visibilità è data ai soli partecipanti a prescindere dal parametro
					 or
					 (
							op.IdRow is not null -- presenza dell'offerta nella gara
					 )
			   )


			   and    sv.id = @idDoc
			   and u.idpfu = @IdUser

	END

	IF @command = 'INFO_LOTTI'
	BEGIN
		select sv.id
			   from ctl_doc sv
					 inner join ctl_doc b WITH(NOLOCK) on b.id = sv.LinkedDoc
					 inner join ctl_doc p WITH(NOLOCK) on b.id = p.LinkedDoc and p.deleted = 0 and p.tipodoc = 'PDA_MICROLOTTI'
					 left join Document_PDA_OFFERTE op WITH(NOLOCK) on op.idheader = p.id and op.idAziPartecipante = sv.Azienda
					 left join document_microlotti_dettagli lp WITH(NOLOCK) on lp.idheader = b.id and  lp.TipoDoc = b.tipodoc  and lp.Voce = 0
					 left  join document_microlotti_dettagli lo WITH(NOLOCK) on lo.idheader = op.idmsg and  /*lo.TipoDoc = 'OFFERTA' and */ lo.voce = 0  and lo.numerolotto = lp.NumeroLotto
					 left join ctl_doc o WITH(NOLOCK) on b.id = o.LinkedDoc and o.deleted = 0 and o.tipodoc = 'OFFERTA' and op.IdMsg = o.id
					 left join Document_Parametri_Sedute_Virtuali psv WITH(NOLOCK) on psv.deleted = 0 
					 --inner join profiliutente u WITH(NOLOCK) on u.pfuidazi = op.idAziPartecipante and u.pfuDeleted = 0

			   where sv.id = @idDoc	--and u.IdPfu = @IdUser
				 and ( 
							( psv.Visibilita_Lotti = 'tutti' )
							or
							( psv.Visibilita_Lotti = 'partecipanti' and lo.id is not null )
					)	
	END

	IF @command = 'INFO_LOTTO'
	BEGIN
	select distinct lp.numerolotto , lp.Descrizione , lp.StatoRiga , lp.Aggiudicata ,lp.id , u.IdPfu , psv.Visibilita_Lotti
		   from ctl_doc sv WITH(NOLOCK)
				inner join ctl_doc b WITH(NOLOCK) on b.id = sv.LinkedDoc
				inner join Document_Bando BA WITH(NOLOCK) on BA.idHeader = b.Id
				inner join ctl_doc p WITH(NOLOCK) on b.id = p.LinkedDoc and p.deleted = 0 and p.tipodoc = 'PDA_MICROLOTTI'
				inner join CTL_DOC_Destinatari d WITH(NOLOCK) on d.idheader = b.id and sv.Azienda = d.idazi
				left join Document_PDA_OFFERTE op WITH(NOLOCK) on op.idheader = p.id and op.idAziPartecipante = d.idazi -- sv.Azienda 
				inner join document_microlotti_dettagli lp WITH(NOLOCK) on lp.idheader = p.id and  lp.TipoDoc = 'PDA_MICROLOTTI' and lp.Voce = 0
				left  join document_microlotti_dettagli lo WITH(NOLOCK) on lo.idheader = op.idrow and  lo.TipoDoc = 'PDA_OFFERTE' and lo.voce = 0  and lo.numerolotto = lp.NumeroLotto
				inner join ctl_doc o WITH(NOLOCK) on b.id = o.LinkedDoc and o.deleted = 0 and o.tipodoc = 'OFFERTA' and op.IdMsg = o.id
				inner join Document_Parametri_Sedute_Virtuali psv WITH(NOLOCK) on psv.deleted = 0 
				inner join profiliutente u WITH(NOLOCK) on u.pfuidazi = d.IdAzi and u.pfuDeleted = 0

		   where 	
		   (
						-- se la gara è ad invito ed il paramentro da visibiltà solo agli invitati
						(      
								BA.TipoBandoGara = '3' -- invito
								and 
								psv.Visibilita = 'invitati' 
								and 
								d.idrow is not null -- presenza negli invitati
						)

						-- altrimenti la visibilità è data ai soli partecipanti a prescindere dal parametro
						or
						(
								op.IdRow is not null -- presenza dell'offerta nella gara
						)
				)


						-- i dati dei lotti visibili
				and 
				( 
						( psv.Visibilita_Lotti = 'tutti' )
						or
						( psv.Visibilita_Lotti = 'partecipanti' and lo.id is not null )
				)


				and
				(sv.id = @idDoc or lp.id=@idDoc) --201465
				and
				u.IdPfu = @IdUser

	END
END



GO
