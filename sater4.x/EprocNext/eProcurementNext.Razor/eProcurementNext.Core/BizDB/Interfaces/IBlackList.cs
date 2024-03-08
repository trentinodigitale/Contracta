using Microsoft.AspNetCore.Http;

namespace eProcurementNext.BizDB
{
    public interface IBlackList
    {
        //void setSession(Session.ISession session);  // metodo aggiunto per settare la sessione

        void addIp(Dictionary<string, dynamic> attackInfo, Session.ISession session, string strConnectionString);
        //void addIp(Dictionary<string, dynamic> AttackInfo); // RICHIEDE VALORI DA SESSION E CONNECTIONSTRING DA GESTIRE CON DI?
        Dictionary<string, dynamic> getInfoBlock(string strIp, string strConnectionString); // RICHIEDE VALORI DA SESSION E CONNECTIONSTRING DA GESTIRE CON DI?
        void removeIp(string strIp, string strConnectionString); // RICHIEDE VALORI DA SESSION E CONNECTIONSTRING DA GESTIRE CON DI?
        Dictionary<string, dynamic> getListIp(); // RICHIEDE VALORI DA SESSION E CONNECTIONSTRING DA GESTIRE CON DI?

        void loadBlackListInMem(string strConnectionString, ref Dictionary<string, dynamic> colBlackList); // RICHIEDE VALORI DA SESSION E CONNECTIONSTRING DA GESTIRE CON DI?

        Dictionary<string, dynamic> getAttackInfo(HttpContext httpContext, dynamic sessionUser, string strCausa);
        //Dictionary<string, dynamic> getAttackInfo(string causa); // RICHIEDE VALORI DA SESSION DA GESTIRE CON DI?
        //Dictionary<string, dynamic> getAttackInfo(Session.ISession session, string causa)

        bool isOwnerObblig(string oggettosql); // RICHIEDE VALORI DA SESSION DA GESTIRE CON DI?
        void loadOwnersInMem(string strConnectionString, Dictionary<string, dynamic> colOwners); // vedi sopra
        bool isDevMode(Session.ISession session); //vedi sopra per la sessionw
        string getIpByGuid(string guid, string strConnectionString); // vedi sopra per la session
        //void addLogAttack(Dictionary<string, dynamic> attackInfo); // vedi sopra per session e connection string
    }
}
