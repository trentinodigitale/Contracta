using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace EprocNext.CtlProcess
{
    public interface IDbProfiler
    {
        public void endProfiler();
        public void startProfiler();
        public void traceDbProfiler(string strSql);
        public void attivazioneProfiler();
        public void disattivazioneProfiler();
    }
}
