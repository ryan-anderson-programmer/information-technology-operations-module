using System;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace ItoCommandRuntimeProxy
{
    /// <summary>
    /// This is a proxy of the ICommandRuntime interface for PowerShell commandlets.
    /// </summary>
    public class ItoCommandRuntimeProxy : ICommandRuntime
    {
        public PSTransactionContext CurrentPSTransaction => throw new NotImplementedException();

        public PSHost Host => throw new NotImplementedException();

        public bool ShouldContinue(string query, string caption)
        {
            if (query == null) throw new ArgumentNullException("query");

            if (caption == null) throw new ArgumentNullException("caption");

            return true;
        }

        public bool ShouldContinue(string query, string caption, ref bool yesToAll, ref bool noToAll)
        {
            throw new NotImplementedException();
        }

        public bool ShouldProcess(string target)
        {
            throw new NotImplementedException();
        }

        public bool ShouldProcess(string target, string action)
        {
            if (target == null) throw new ArgumentNullException("target");

            if (action == null) throw new ArgumentNullException("action");

            return true;
        }

        public bool ShouldProcess(string verboseDescription, string verboseWarning, string caption)
        {
            throw new NotImplementedException();
        }

        public bool ShouldProcess(string verboseDescription, string verboseWarning, string caption, out ShouldProcessReason shouldProcessReason)
        {
            throw new NotImplementedException();
        }

        public void ThrowTerminatingError(ErrorRecord errorRecord)
        {
            throw new NotImplementedException();
        }

        public bool TransactionAvailable()
        {
            throw new NotImplementedException();
        }

        public void WriteCommandDetail(string text)
        {
            throw new NotImplementedException();
        }

        public void WriteDebug(string text)
        {
            throw new NotImplementedException();
        }

        public void WriteError(ErrorRecord errorRecord)
        {
            throw new NotImplementedException();
        }

        public void WriteObject(object sendToPipeline)
        {
            throw new NotImplementedException();
        }

        public void WriteObject(object sendToPipeline, bool enumerateCollection)
        {
            throw new NotImplementedException();
        }

        public void WriteProgress(ProgressRecord progressRecord)
        {
            throw new NotImplementedException();
        }

        public void WriteProgress(long sourceId, ProgressRecord progressRecord)
        {
            throw new NotImplementedException();
        }

        public void WriteVerbose(string text)
        {
            throw new NotImplementedException();
        }

        public void WriteWarning(string text)
        {
            throw new NotImplementedException();
        }
    }
}
