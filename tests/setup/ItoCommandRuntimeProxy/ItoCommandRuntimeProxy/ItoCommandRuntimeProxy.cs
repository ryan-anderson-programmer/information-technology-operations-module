/* Copyright 2022 Ryan E. Anderson
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/* InformationTechnologyOperationsModule v0.1.0 Command Runtime Proxy
 * 
 * By Ryan E. Anderson
 * 
 * Copyright (c) 2022 Ryan E. Anderson
 */
using System;
using System.Management.Automation;
using System.Management.Automation.Host;

namespace ItoCommandRuntimeProxy
{
    /// <summary>
    /// This is a proxy of the ICommandRuntime interface for PowerShell commandlets. This
    /// class should only be used for testing purposes.
    /// </summary>
    public class ItoCommandRuntimeProxy : ICommandRuntime
    {
        public PSTransactionContext CurrentPSTransaction => throw new NotImplementedException();

        public PSHost Host => throw new NotImplementedException();

        /// <summary>
        /// This method overrides the original functionality for prompting a user to confirm whether
        /// an operation should continue. This method always returns true.
        /// </summary>
        /// <param name="query">This is a query of whether an action should be performed.</param>
        /// <param name="caption">This is a caption that appears on the window of a prompt.</param>
        /// <returns>The result of this method is always true.</returns>
        /// <exception cref="ArgumentNullException">This exception is thrown if an argument is null.</exception>
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

        /// <summary>
        /// This method overrides the original functionality for prompting a user to confirm whether
        /// processing should be performed. This method always returns true.
        /// </summary>
        /// <param name="target">This is the name of the target resource that is undergoing an operation.</param>
        /// <param name="action">This is the name of the action that is being performed.</param>
        /// <returns>The result of this method is always true.</returns>
        /// <exception cref="ArgumentNullException">This exception is thrown if an argument is null.</exception>
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
