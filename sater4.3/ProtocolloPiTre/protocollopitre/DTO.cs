
public class recGetToken
{
    public string Code { get; set; }
    public string Token { get; set; }
    public string ErrorMessage { get; set; }
}

public class InfoRec
{
    public int IdAziEnte { get; set; }
    public int IdAziOE { get; set; }
    public string RagSocEnte { get; set; }
    public string RagSocOE { get; set; }
    public string CFEnte { get; set; }
    public string CFOE { get; set; }
    public string PivaEnte { get; set; }
    public string PivaOE { get; set; }
    public string titolo { get; set; }
    public string TipoProtocollo { get; set; }
    public string CodeSender { get; set; }
}

public class InfoDoc
{
    public string Id { get; set; }
    public string TipoDoc { get; set; }
    public string Data { get; set; }   
    public string titolo { get; set; }
    public string Oggetto { get; set; }
}


public class recGetActiveClassificationScheme
{
    public Classificationscheme ClassificationScheme { get; set; }
    public string ErrorMessage { get; set; }
    public string Code { get; set; }
}

public class Classificationscheme
{
    public string Id { get; set; }
    public string Description { get; set; }
    public bool Active { get; set; }
}


public class recProject
{
    public Project Project { get; set; }
    public string ErrorMessage { get; set; }
    public string Code { get; set; }
}

public class Project
{
    public string Id { get; set; }
    public string Code { get; set; }
    public string Description { get; set; }
    public bool Private { get; set; }
    public bool Paper { get; set; }
    public string CollocationDate { get; set; }
    public string PhysicsCollocation { get; set; }
    public string CreationDate { get; set; }
    public string OpeningDate { get; set; }
    public string ClosureDate { get; set; }
    public bool Open { get; set; }
    public string IdParent { get; set; }
    public Classificationscheme ClassificationScheme { get; set; }
    public Template Template { get; set; }
    public object Note { get; set; }
    public string Type { get; set; }
    public string Number { get; set; }
    public bool Controlled { get; set; }
    public object CodeNodeClassification { get; set; }
    public Register Register { get; set; }
}



public class Template
{
    public string Id { get; set; }
    public string Name { get; set; }
    public Field[] Fields { get; set; }
    public object StateDiagram { get; set; }
    public object Type { get; set; }
}

public class Field
{
    public string Id { get; set; }
    public string Name { get; set; }
    public bool Required { get; set; }
    public string Value { get; set; }
    public object MultipleChoice { get; set; }
    public string Type { get; set; }
    public bool CounterToTrigger { get; set; }
    public object CodeRegisterOrRF { get; set; }
    public object Rights { get; set; }
}

public class Register
{
    public string Id { get; set; }
    public string Code { get; set; }
    public bool IsRF { get; set; }
    public string State { get; set; }
    public string Description { get; set; }
}




public class recSearchCorrespondents
{
    public Correspondent[] Correspondents { get; set; }
    public string ErrorMessage { get; set; }
    public string Code { get; set; }
}

public class Correspondent
{
    public string Id { get; set; }
    public string Description { get; set; }
    public string Code { get; set; }
    public object Address { get; set; }
    public object Cap { get; set; }
    public object City { get; set; }
    public object Province { get; set; }
    public object Location { get; set; }
    public object Nation { get; set; }
    public object PhoneNumber { get; set; }
    public object PhoneNumber2 { get; set; }
    public object Fax { get; set; }
    public object NationalIdentificationNumber { get; set; }
    public object VatNumber { get; set; }
    public object Email { get; set; }
    public object OtherEmails { get; set; }
    public object AOOCode { get; set; }
    public object AdmCode { get; set; }
    public object Note { get; set; }
    public string Type { get; set; }
    public object CodeRegisterOrRF { get; set; }
    public string CorrespondentType { get; set; }
    public object PreferredChannel { get; set; }
    public string Name { get; set; }
    public string Surname { get; set; }
    public bool IsCommonAddress { get; set; }
}



public class recGetRegisterOrRF
{
    public Register Register { get; set; }
    public string ErrorMessage { get; set; }
    public string Code { get; set; }
}


public class recCreateDocument
{
    public Document Document { get; set; }
    public string Code { get; set; }
    public string ErrorMessage { get; set; }
}

public class Document
{
    public string Id { get; set; }
    public string DocNumber { get; set; }
    public string Object { get; set; }
    public string CreationDate { get; set; }
    public string DocumentType { get; set; }
    public bool PrivateDocument { get; set; }
    public bool PersonalDocument { get; set; }
    public bool IsAttachments { get; set; }
    public bool Predisposed { get; set; }
    public string Signature { get; set; }
    public bool Annulled { get; set; }
    public object MeansOfSending { get; set; }
    public bool InBasket { get; set; }
    public object ProtocolDate { get; set; }
    public object ProtocolNumber { get; set; }
    public object ProtocolYear { get; set; }
    public object ConsolidationState { get; set; }
    public object ProtocolSender { get; set; }
    public object DataProtocolSender { get; set; }
    public object ArrivalDate { get; set; }
    public Sender Sender { get; set; }
    public Recipient[] Recipients { get; set; }
    public object RecipientsCC { get; set; }
    public object MultipleSenders { get; set; }
    public object Template { get; set; }
    public object Note { get; set; }
    public Maindocument MainDocument { get; set; }
    public object Attachments { get; set; }
    public Register Register { get; set; }
    public object IdParent { get; set; }
    public object ParentDocument { get; set; }
    public object LinkedDocuments { get; set; }
}

public class Sender
{
    public string Id { get; set; }
    public string Description { get; set; }
    public string Code { get; set; }
    public string Address { get; set; }
    public string Cap { get; set; }
    public string City { get; set; }
    public string Province { get; set; }
    public string Location { get; set; }
    public string Nation { get; set; }
    public string PhoneNumber { get; set; }
    public string PhoneNumber2 { get; set; }
    public string Fax { get; set; }
    public string NationalIdentificationNumber { get; set; }
    public string VatNumber { get; set; }
    public string Email { get; set; }
    public object[] OtherEmails { get; set; }
    public string AOOCode { get; set; }
    public string AdmCode { get; set; }
    public string Note { get; set; }
    public string Type { get; set; }
    public object CodeRegisterOrRF { get; set; }
    public string CorrespondentType { get; set; }
    public object PreferredChannel { get; set; }
    public object Name { get; set; }
    public object Surname { get; set; }
    public bool IsCommonAddress { get; set; }
}

public class Maindocument
{
    public string Id { get; set; }
    public string Description { get; set; }
    public object Content { get; set; }
    public string MimeType { get; set; }
    public string VersionId { get; set; }
    public object Name { get; set; }
}

//public class Register
//{
//    public string Id { get; set; }
//    public string Code { get; set; }
//    public bool IsRF { get; set; }
//    public string State { get; set; }
//    public string Description { get; set; }
//}

public class Recipient
{
    public string Id { get; set; }
    public string Description { get; set; }
    public string Code { get; set; }
    public string Address { get; set; }
    public string Cap { get; set; }
    public string City { get; set; }
    public string Province { get; set; }
    public string Location { get; set; }
    public string Nation { get; set; }
    public string PhoneNumber { get; set; }
    public string PhoneNumber2 { get; set; }
    public string Fax { get; set; }
    public string NationalIdentificationNumber { get; set; }
    public string VatNumber { get; set; }
    public object Email { get; set; }
    public object[] OtherEmails { get; set; }
    public object AOOCode { get; set; }
    public object AdmCode { get; set; }
    public string Note { get; set; }
    public object Type { get; set; }
    public object CodeRegisterOrRF { get; set; }
    public string CorrespondentType { get; set; }
    public object PreferredChannel { get; set; }
    public object Name { get; set; }
    public object Surname { get; set; }
    public bool IsCommonAddress { get; set; }
}


public class recUpload
{
    public string ErrorMessage { get; set; }
    public string Code { get; set; }
    public string ResultMessage { get; set; }
}

////////////////////////////////////////////


