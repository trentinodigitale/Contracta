USE [AFLink_TND]
GO
/****** Object:  StoredProcedure [dbo].[Test_Logon]    Script Date: 5/16/2024 2:38:57 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
CREATE PROCEDURE [dbo].[Test_Logon] AS
DECLARE @myAziCod char(7)
DECLARE @myPfuLogin NVARCHAR(12)
DECLARE @myPassword NVARCHAR(12)
DECLARE @myIdAzi INT
DECLARE @myIdPfu INT
DECLARE @myIdLng INT
SELECT @myAziCod = 'AA000AB'
SELECT @myPfuLogin = 'Ff'
SELECT @myPassword = 'TestPwd'
EXEC BOLogon_Check @myAziCod, @myPfuLogin, @myPassword, @myIdAzi OUTPUT, @myIdPfu OUTPUT, @myIdLng OUTPUT
SELECT @myIdAzi AS IdAzi, @myIdPfu AS IdPfu, @myIdLng AS IdLng
GO
