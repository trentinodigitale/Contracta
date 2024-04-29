Public Class MainUtils
    
    'Private shared readonly property codiceAttivazioneChilkat As String = "AFSLZN.CBX012020_qnMbzzsEprmC"

    Public shared Sub UnlockChilkat(Dbm As CTLDB.DatabaseManager)
        Dim glob As new Chilkat.Global
        'if Not glob.UnlockBundle("Start my 30-day Trial") Then Dbm.RunException("Unable to Unlock Chilkcat Crypt2")
        if Not glob.UnlockBundle(afcommon.Statics.codiceAttivazioneChilkat) Then Dbm.RunException("Unable to Unlock Chilkcat Crypt2 With Key: " & afcommon.Statics.codiceAttivazioneChilkat,New Exception("Unable to Unlock Chilkcat Crypt2 With Key: " & afcommon.Statics.codiceAttivazioneChilkat))
        'If Not C.UnlockComponent("AFSOLUCrypt_kBFfOFAyUJJG") Then Dbm.RunException("Unable to Unlock Chilkcat Crypt2")  
    End Sub
End Class
