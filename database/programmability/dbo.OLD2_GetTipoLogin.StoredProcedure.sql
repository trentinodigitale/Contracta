USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[OLD2_GetTipoLogin]    Script Date: 5/16/2024 2:38:56 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[OLD2_GetTipoLogin] 
 (@CurAziLog           AS char(7), 
  @CurLoginName        AS NVARCHAR (50),  
  @CurPassword         AS NVARCHAR (250),
  @CurMPLog            AS NVARCHAR (12),
  @CurIdAzi            AS INTeger OUTPUT,
  @CurPfuFunzionalita  AS VARCHAR  (400) OUTPUT,
  @CurRagSoc           AS NVARCHAR (80)OUTPUT, 
  @CurTipoLogin        AS INTeger OUTPUT,
  @CurPfuProfili       AS VARCHAR  (20)  OUTPUT,
  @IdPfu               AS INTeger OUTPUT,
  @sLng                AS VARCHAR  (5)OUTPUT,
  @UserName            AS NVARCHAR (30) OUTPUT)
as
DECLARE @bInStandBy            AS smallint
 DECLARE @bBuyer                AS smallint
 DECLARE @bSupplier             AS smallint
 DECLARE @bProspect             AS smallint
-- DECLARE @IdPfu                 AS INTeger
 DECLARE @aziRagioneSocialeNorm AS NVARCHAR (80)
 DECLARE @PwdOut				AS NVARCHAR(200)
 DECLARE @PwdSaved			    AS NVARCHAR(200)
 
 set @PwdOut=''

 set @CurPfuFunzionalita = ''
 set @CurPfuProfili = ''
 set @sLng = ''
 set @UserName = ''
 SELECT @CurIdAzi              = a.IdAzi, 
        @CurRagSoc             = a.aziRagioneSociale,
        @aziRagioneSocialeNorm = a.aziRagioneSocialeNorm, 
        @bBuyer                = b.mpaAcquirente, 
        @bSupplier             = b.mpaVenditore, 
        @bProspect             = b.mpaProspect,
        @bInStandBy            = b.mpaDeleted
   FROM Aziende a, MPAziende b, MarketPlace c
  WHERE a.aziLog = @CurAziLog 
    AND a.IdAzi = b.mpaIdAzi
    AND c.IdMp = b.mpaIdMp
    AND c.mpLog = @CurMPLog
    AND a.aziDeleted = 0
    AND (b.mpaDeleted = 0 or b.mpaDeleted = 2)
 IF @CurIdAzi IS NULL
    begin
        set @CurTipoLogin = -1
        return
    end
 set @IdPfu = NULL
 
 IF  @bProspect = 1 AND @bInStandBy <> 2
     begin
		
		  SELECT @PwdSaved=a.pfuPassword , @IdPfu = IdPfu, @sLng = b.lngSuffisso
            FROM ProfiliUtente_Prospect a, Lingue b
           WHERE a.pfuIdLng    = b.IdLng
             AND a.pfuIdAzi    = @CurIdazi
             AND a.pfuLogin    = @CurLoginName
             --AND a.pfuPassword = @CurPassword
             AND a.pfuDeleted  = 0
		  
		  IF  @IdPfu IS NULL 
              begin
                    set @CurTipoLogin = -1
                    return 
              end
		  
		  --cifro la pwd in input e la confronto con quella salvata sull'utente
		  exec 	EncryptPwdUser @IdPfu, @CurPassword , @PwdOut output	  
		  if @PwdSaved <> @PwdOut 
			  begin
                    set @CurTipoLogin = -1
                    return 
              end

          set @CurTipoLogin = 3
          return 
     end
 IF @bInStandBy <> 2 AND @bProspect = 0
    begin
         SELECT @PwdSaved=a.pfuPassword,@IdPfu = a.IdPfu, 
                @CurPfuFunzionalita = a.pfuFunzionalita, 
                @CurPfuProfili = a.pfuProfili, 
                @UserName = a.pfuNome,
                @sLng = b.lngSuffisso         
          FROM ProfiliUtente a, Lingue b
         WHERE a.pfuIdLng    = b.IdLng
           AND a.pfuIdAzi    = @CurIdazi
           AND a.pfuLogin    = @CurLoginName
           --AND a.pfuPassword = @CurPassword
           AND a.pfuDeleted  = 0
        IF  @IdPfu IS NULL 
            begin
                 set @CurTipoLogin = -1
                 return 
            end

		--cifro la pwd in input e la confronto con quella salvata sull'utente
		exec 	EncryptPwdUser @IdPfu, @CurPassword , @PwdOut output	  
		if @PwdSaved <> @PwdOut 
			begin
                set @CurTipoLogin = -1
                return 
			end


 end
   IF @bInStandBy = 2
       begin
             set @CurTipoLogin = -2
             return 
       end
      
   IF @bBuyer   = 3 AND @bSupplier = 3
       begin
             set @CurTipoLogin = 2
             return 
       end
   IF @bBuyer = 0 AND @bSupplier = 3
       begin
             set @CurTipoLogin = 1
             return 
       end
   IF @bBuyer   = 3  AND @bSupplier = 0
       begin
             set @CurTipoLogin = 0
             return 
       end
   IF @bBuyer   = 2 AND @bSupplier = 2
       begin
             set @CurTipoLogin = 6
             return 
       end
   IF @bBuyer = 0 AND @bSupplier = 2
       begin
             set @CurTipoLogin = 5
             return 
       end
   IF @bBuyer   = 2  AND @bSupplier = 0
       begin
             set @CurTipoLogin = 4
             return 
       end

GO
