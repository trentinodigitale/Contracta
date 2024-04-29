namespace eProcurementNext.BizDB
{
    public interface IDbProfiler
    {
        public void endProfiler();
        public void startProfiler();
        //public void traceDbProfiler(string strSql);
        //public void attivazioneProfiler();
        //public void disattivazioneProfiler();
        void traceDbProfiler(string strSql, string? parConnection);
    }
}
