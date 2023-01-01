/* Copyright 2023 Ryan E. Anderson
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

/* InformationTechnologyOperationsModule v0.1.0 Command Runtime Proxy Unit Test Suite
 * 
 * By Ryan E. Anderson
 * 
 * Copyright (c) 2023 Ryan E. Anderson
 */
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ItoCommandRuntimeProxy.Test
{
    /// <summary>
    /// This is a suite of unit tests for testing the ItoCommandRuntimeProxy class.
    /// </summary>
    [TestClass]
    public class ItoCommandRuntimeProxyUnitTestSuite
    {
        private const string Query = "Query";
        private const string Caption = "Caption";
        private const string Action = "Action";
        private const string Target = "Target";

        private ItoCommandRuntimeProxy itoCommandRuntimeProxy;

        [TestInitialize]
        public void InitializeTests()
        {
            itoCommandRuntimeProxy = new ItoCommandRuntimeProxy(); // Arrange.
        }

        [TestMethod]
        public void ShouldContinueThrowsArgumentNullExceptionWhenQueryIsNull()
        {
            void actual() => itoCommandRuntimeProxy.ShouldContinue(null, Caption); // Act.

            Assert.ThrowsException<ArgumentNullException>(actual); // Assert.
        }

        [TestMethod]
        public void ShouldContinueThrowsArgumentNullExceptionWhenCaptionIsNull()
        {
            void actual() => itoCommandRuntimeProxy.ShouldContinue(Query, null); // Act.

            Assert.ThrowsException<ArgumentNullException>(actual); // Assert.
        }

        [TestMethod]
        public void ShouldContinueReturnsTrue()
        {
            var actual = itoCommandRuntimeProxy.ShouldContinue(Query, Caption); // Act.

            Assert.IsTrue(actual); // Assert.
        }

        [TestMethod]
        public void ShouldProcessThrowsArgumentNullExceptionWhenTargetIsNull()
        {
            void actual() => itoCommandRuntimeProxy.ShouldProcess(null, Action); // Act.

            Assert.ThrowsException<ArgumentNullException>(actual); // Assert.
        }

        [TestMethod]
        public void ShouldProcessThrowsArgumentNullExceptionWhenActionIsNull()
        {
            void actual() => itoCommandRuntimeProxy.ShouldProcess(Target, null); // Act.

            Assert.ThrowsException<ArgumentNullException>(actual); // Assert.
        }

        [TestMethod]
        public void ShouldProcessReturnsTrue()
        {
            var actual = itoCommandRuntimeProxy.ShouldProcess(Target, Action); // Act.

            Assert.IsTrue(actual); // Assert.
        }
    }
}
