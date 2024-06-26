USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD_DASHBOARD_SP_LISTA_ATTIVITA]    Script Date: 5/16/2024 2:38:55 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE proc [dbo].[OLD_DASHBOARD_SP_LISTA_ATTIVITA] 
(@IdPfu							int,
 @AttrName						varchar(8000),
 @AttrValue						varchar(8000),
 @AttrOp 						varchar(8000),
 @Filter                        varchar(8000),
 @Sort                          varchar(8000),
 @Top                           int,
 @Cnt                           int output
)
as
	declare @Param						varchar(8000)
	declare @IdentificativoIniziativa	varchar(250)
	declare @Convenzione				varchar(250)
	declare @Codice						varchar(250)
	declare @Descrizione				varchar(250)
	declare @Macro_Convenzione			varchar(250)
	declare @Convenzione_Lotto			varchar(8000)
	declare @ambito						varchar(250)
	declare @SQLCmd						nvarchar(max)
	declare @SQLWhere					nvarchar(max)

	set nocount on

	set @Param = @AttrName + '#~#' + @AttrValue + '#~#' + @AttrOp
	
	set @SQLWhere = dbo.GetWhere( 'LISTA_ATTIVITA' , 'V', @AttrName ,  @AttrValue ,  @AttrOp )

	declare @CrLf varchar (10)
	set @CrLf = '
	'
	set @SQLCmd =  
	'select top 0 
		 ATV_IDDOC                                AS Id
		 , ATV_Object                               AS Oggetto
		 , ATV_IdPfu                                AS Owner
		 , ATV_DateInsert                           AS Data
		 , ATV_ExpiryDate                           AS DataScadenza
		 , ATV_ExpiryDate                           AS DataScadenzaA
		 , Cast(ATV_Obbligatory as varchar(200))    AS Urgente
		 , Cast(ATV_DocumentName as varchar(500))                         AS OPEN_DOC_NAME
		 , ATV_Execute
		 , ATV_IdPfu 
		 , ATV_IdAzi 
		 , ATV_obbligatory
		 , ATV_DocumentName
		 , ATV_IDDOC
		 ,cast('''' as nvarchar(max))  as Notacom
		 , ATV_Allegato as allegato
		 , ATV_Object 
		 , cast('''' as nvarchar(max)) as ispublic
		 , cast('''' as nvarchar(max)) as StatoDoc
		 into #tmp_ATTIVITA
		  from ctl_attivita with(nolock)

insert into #tmp_ATTIVITA
	SELECT distinct ATV_IDDOC                                AS Id
			 , ATV_Object                               AS Oggetto
			 , ATV_IdPfu                                AS Owner
			 , ATV_DateInsert                           AS Data
			 , ATV_ExpiryDate                           AS DataScadenza
			 , ATV_ExpiryDate                           AS DataScadenzaA
			 , ATV_Obbligatory                          AS Urgente
			 , ATV_DocumentName                         AS OPEN_DOC_NAME
			 , ATV_Execute
			 , ATV_IdPfu 
			 , ATV_IdAzi 
			 , ATV_obbligatory
			 , ATV_DocumentName
			 , ATV_IDDOC
			 , NotaCom
			 , ATV_Allegato as allegato
			 , ATV_Object 		 
			 , ispublic
 			 , ''Sended'' as StatoDoc
		  
		  FROM CTL_Attivita WITH (NOLOCK)
			 , Aziende  A WITH (NOLOCK)
			 , MPAziende WITH (NOLOCK)
			 , ProfiliUtente WITH (NOLOCK)
			 , Document_Com_DPE_Fornitori  WITH (NOLOCK)
			 , Document_Com_DPE  WITH (NOLOCK)
     
		 WHERE ATV_IdPfu = IdPfu
		   AND pfuIdAzi = A.IdAzi
		   AND A.IdAzi = mpaIdAzi
		   AND aziDeleted = 0 
		   AND mpaDeleted = 0
		   AND mpaIdMp = 1
		   AND ATV_Execute = ''No''
		   and Document_Com_DPE_Fornitori.IdComFor=ATV_IDDOC
		   and Document_Com_DPE.IdCom=Document_Com_DPE_Fornitori.IdCom
		  -- and ispublic=1
		   and isnull( ATV_ExpiryDate , convert( datetime , ''3000-01-01 00:00:00'' , 121 ) )  >= getdate()
		   and Document_Com_DPE.StatoCom <> ''Richiamata''
		   and pfuDeleted=0
			and ATV_IdPfu=' + cast( @IdPfu as varchar(20)) +


'insert into #tmp_ATTIVITA
	SELECT distinct ATV_IDDOC                                AS Id
			 , ATV_Object                               AS Oggetto
			 , ATV_IdPfu                                AS Owner
			 , ATV_DateInsert                           AS Data
			 , ATV_ExpiryDate                           AS DataScadenza
			 , ATV_ExpiryDate                           AS DataScadenzaA
			 , ATV_Obbligatory                          AS Urgente
			 , ATV_DocumentName                         AS OPEN_DOC_NAME
			 , ATV_Execute
			 , ATV_IdPfu 
			 , ATV_IdAzi 
			 , ATV_obbligatory
			 , ATV_DocumentName
			 , ATV_IDDOC
			 , NotaCom
			 , ATV_Allegato as allegato
			 , ATV_Object 		 
			 , ispublic
 			 , ''Sended'' as StatoDoc
		  
		  FROM CTL_Attivita WITH (NOLOCK)
			 , Aziende  A WITH (NOLOCK)
			 , MPAziende WITH (NOLOCK)
			 , ProfiliUtente WITH (NOLOCK)
			 , Document_Com_DPE_Enti  WITH (NOLOCK)
			 , Document_Com_DPE  WITH (NOLOCK)
     
		 WHERE ATV_IdPfu = IdPfu
		   AND pfuIdAzi = A.IdAzi
		   AND A.IdAzi = mpaIdAzi
		   AND aziDeleted = 0 
		   AND mpaDeleted = 0
		   AND mpaIdMp = 1
		   AND ATV_Execute = ''No''
		   and Document_Com_DPE_Enti.IdComEnte=ATV_IDDOC
		   and Document_Com_DPE.IdCom=Document_Com_DPE_Enti.IdCom
		   --and ispublic=1
		   and isnull( ATV_ExpiryDate , convert( datetime , ''3000-01-01 00:00:00'' , 121 ) )  >= getdate()
		   and Document_Com_DPE.StatoCom <> ''Richiamata''
		   and pfuDeleted=0
			and ATV_IdPfu=' + cast( @IdPfu as varchar(20)) +

'insert into #tmp_ATTIVITA
	SELECT
			   case when ATV_DocumentName in ( ''RELEASE_NOTES_IA'', ''FORMULARI_IA'')
					then ATV_ID
					else ATV_IDDOC
			   end AS Id		 
			 , ATV_Object AS oggetto
			 , isnull( IdPfu , ATV_IdPfu )				AS Owner
			 , ATV_DateInsert                           AS Data
			 , ATV_ExpiryDate                           AS DataScadenza
			 , ATV_ExpiryDate                           AS DataScadenzaA
			 , case when ATV_DocumentName in ( ''RELEASE_NOTES_IA'')
					then ''no_release_notes''
					else ATV_Obbligatory
			   end AS Urgente
			 , case when ATV_DocumentName=''SCRITTURA_PRIVATA'' then ''SCRITTURA_PRIVATA_FORN'' 
					--when ATV_DocumentName=''CONTRATTO_GARA'' then ''CONTRATTO_GARA_FORN'' 
					else ATV_DocumentName end           AS OPEN_DOC_NAME
			 , ATV_Execute
			 , ATV_IdPfu 
			 , ATV_IdAzi 
			 , ATV_obbligatory
			 , ATV_DocumentName
			 , ATV_IDDOC
			 , '''' as Notacom
			 , ATV_Allegato as allegato
			 , ATV_Object
			 , 0 as ispublic
			 , ''Sended'' as StatoDoc

		  FROM CTL_Attivita  a WITH (NOLOCK)
			 inner join  Aziende  WITH (NOLOCK) on ATV_IdAzi = IdAzi 	   AND aziDeleted = 0 
			 inner join  MPAziende  WITH (NOLOCK) on IdAzi = mpaIdAzi  AND mpaDeleted = 0 AND mpaIdMp = 1
			 left outer join  ProfiliUtente  WITH (NOLOCK) on pfuIdAzi = IdAzi and pfuDeleted=0 and ATV_IdPfu is null
			 --left outer join ProfiliUtente on pfuIdAzi = ATV_IdAzi

		 WHERE 
			ATV_Execute = ''no''
		  and isnull( ATV_ExpiryDate , convert( datetime , ''3000-01-01 00:00:00'' , 121 ) )  >= getdate()
		 -- and IdPfu=35845
		  and ATV_DocumentName <> ''CHANGE_PWD_OBBLIG''
		  and isnull( IdPfu , ATV_IdPfu )	=' + cast( @IdPfu as varchar(20)) +





	  '--RIGHE PER IL CAMBIO PWD
insert into #tmp_ATTIVITA
	SELECT distinct 
			ATV_IDDOC                                AS Id
		 , ATV_Object                               AS Oggetto
		 , ATV_IdPfu                                AS Owner
		 , ATV_DateInsert                           AS Data
		 , ATV_ExpiryDate                           AS DataScadenza
		 , ATV_ExpiryDate                           AS DataScadenzaA
		 , ATV_Obbligatory                          AS Urgente
		 , ATV_DocumentName + ''.760.450''                    AS OPEN_DOC_NAME
		 , ATV_Execute
		 , ATV_IdPfu 
		 , ATV_IdAzi 
		 , ATV_obbligatory
		 , ATV_DocumentName
		 , ATV_IDDOC
		 , '''' as NotaCom
		 , '''' as allegato
		 , titolo  as ATV_Object
		 , 0  as ispublic
		 , ''Sended'' as StatoDoc

	  FROM CTL_Attivita WITH (NOLOCK)
		 , ctl_doc WITH (NOLOCK)
	 WHERE 
		ATV_IdPfu = ctl_doc.IdPfu
	   AND ATV_Execute = ''No''
	   and id=ATV_IDDOC
	   and tipodoc=''CHANGE_PWD_OBBLIG''
	   and ATV_IdPfu=' + cast( @IdPfu as varchar(20)) + @CrLf +
	
' select a.* 
	from	#tmp_ATTIVITA a
		--CONCETTO VALIDO SOLO PER LE ATTIVITA'' RIVOLTE ALLE AZIENDE
		left join CTL_DOC_READ rd  WITH (NOLOCK) ON a.id = rd.id_doc and rd.DOC_NAME = ''LISTA_ATTIVITA''
	where rd.id is null'
---drop table #tmp_ATTIVITA	



	if @Filter <> '' 
		set @SQLCmd = @SQLCmd + ' and ( ' + @Filter + ' ) ' + @CrLf


	if @Sort <> ''
		set @SQLCmd = @SQLCmd + ' ORDER BY ' + @Sort  + @CrLf

	exec (@SQLCmd)
	--select  @SQLCmd






GO
