namespace eProcurementNext.Security
{
    public interface IValidation
    {
        bool validate(Session.ISession session, string nomeParametro, string valoreDaValidare, int tipoDaValidare, int sottoTipoDaValidare = 0, string regExp = "");
    }
}
